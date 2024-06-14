// ignore_for_file: prefer_const_constructors, sort_child_properties_last
import 'package:flutter/material.dart';
import 'Pages/vehicles_page.dart'; 
import 'Pages/providers_page.dart'; 
import 'Pages/work_orders_page.dart'; 
import 'Pages/receipts_page.dart'; 
import 'Pages/drivers_page.dart'; 

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'Inicio',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Seleccione alguna pestaña a la que le gustaria ingresar.',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              _buildMenuCard(
                context,
                'Gestor de Vehículos',
                Icons.directions_car,
                Colors.red,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VehiclesPage()),
                  );
                },
              ),
              _buildMenuCard(
                context,
                'Gestor de Proveedores',
                Icons.business,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProvidersPage()),
                  );
                },
              ),
              _buildMenuCard(
                context,
                'Gestor de Órdenes de Trabajo',
                Icons.work,
                Color.fromARGB(255, 106, 189, 109),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WorkOrdersPage()),
                  );
                },
              ),
              _buildMenuCard(
                context,
                'Gestor de Recibos',
                Icons.receipt,
                Color.fromARGB(255, 205, 49, 211),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReceiptsPage()),
                  );
                },
              ),
              _buildMenuCard(
                context,
                'Gestor de Conductores',
                Icons.person,
                Color.fromARGB(255, 218, 158, 48),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DriversPage()),
                  );
                },
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 180,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 40, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: onTap,
                child: Text('Ingresar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
