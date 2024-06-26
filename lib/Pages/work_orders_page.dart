// ignore_for_file: prefer_const_constructors, sort_child_properties_last, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto_app_mantenimiento/Add/add_work_order_page.dart';
import 'dart:convert';
import 'package:proyecto_app_mantenimiento/Show/Show_work_order.dart'; // Asegúrate de crear esta página para mostrar más información sobre la orden de trabajo

class WorkOrdersPage extends StatefulWidget {
  const WorkOrdersPage({super.key});

  @override
  _WorkOrdersPageState createState() => _WorkOrdersPageState();
}

class _WorkOrdersPageState extends State<WorkOrdersPage> {
  final String apiUrl =
      'https://finalprojectbackend-production-a933.up.railway.app/api/ordenesDeTrabajo';

  List ordenesTrabajo = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        ordenesTrabajo = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestor de Órdenes de Trabajo')),
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
                  'Ingrese las órdenes de trabajo que quiera mantener en la base de datos rellenando un formulario predeterminado.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap:
                      true, // Importante para usar dentro de SingleChildScrollView
                  physics:
                      NeverScrollableScrollPhysics(), // Para evitar el scroll dentro del ListView
                  itemCount: ordenesTrabajo.length,
                  itemBuilder: (context, index) => _buildWorkOrderCard(
                      context,
                      'Orden de Trabajo ${index + 1}',
                      'Detalles: ${ordenesTrabajo[index]["detalles"]}' '\nCosto: ${ordenesTrabajo[index]["costo"]}',
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
            MaterialPageRoute(builder: (context) => AddWorkOrderPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Modifica la firma del método _buildWorkOrderCard para incluir el parámetro index
  Widget _buildWorkOrderCard(
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
                Icon(Icons.work, size: 40, color: Colors.white),
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
                          ShowWorkOrder(orderId: ordenesTrabajo[index]["id"]));
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
