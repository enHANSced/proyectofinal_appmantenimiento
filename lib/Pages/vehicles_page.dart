// lib/vehicles_page.dart

// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:proyecto_app_mantenimiento/Add/add_vehicle_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:proyecto_app_mantenimiento/Show/show_vehicle.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  _VehiclesPageState createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  final String apiUrl =
      'https://cjl22d1j-3000.use2.devtunnels.ms/api/vehiculos';

  List vehiculos = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        vehiculos = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestor de Vehículos')),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: SingleChildScrollView(
          physics:
              AlwaysScrollableScrollPhysics(), // Asegura que siempre se pueda desplazar
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingrese los vehículos que quiera mantener en la base de datos rellenando un formulario predeterminado.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap:
                      true, // Importante para usar dentro de SingleChildScrollView
                  physics:
                      NeverScrollableScrollPhysics(), // Para evitar el scroll dentro del ListView
                  itemCount: vehiculos.length,
                  itemBuilder: (context, index) => _buildVehicleCard(
                      context,
                      '${vehiculos[index]["marca"]} ${vehiculos[index]["modelo"]}',
                      '${vehiculos[index]["anio"]}',
                      index), // Pasando index aquí
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgregarVehiculo()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Modifica la firma del método _buildVehicleCard para incluir el parámetro index
  Widget _buildVehicleCard(
      BuildContext context, String title, String subtitle, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 180,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, size: 40, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          ShowVehicle(vehicleId: vehiculos[index]["id"]));
                },
                child: Text('Más Información'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey[800],
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
