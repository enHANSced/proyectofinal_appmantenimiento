// ignore_for_file: prefer_const_constructors, sort_child_properties_last, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:proyecto_app_mantenimiento/Add/add_driver_page.dart';
import 'package:proyecto_app_mantenimiento/Show/show_driver.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  _DriversPageState createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  final String apiUrl = 'https://finalprojectbackend-production-a933.up.railway.app/api/conductores';

  List<dynamic> _conductores = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _conductores = jsonDecode(response.body);
        });
      } else {
        throw Exception('No se pudieron cargar los conductores');
      }
    } catch (e) {
      print('Error al cargar los conductores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestor de Conductores')),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingrese los conductores que quiera mantener en la base de datos rellenando un formulario predeterminado.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _conductores.length,
                  itemBuilder: (context, index) {
                    final conductor = _conductores[index];
                    return _buildDriverCard(
                      context,
                      'Conductor ${conductor["nombre"]}',
                      'Teléfono: ${conductor["telefono"]}' '\nIdentidad: ${conductor["id"]}',
                      index,
                    );
                  },
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
            MaterialPageRoute(builder: (context) => AddDriverPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, String title, String subtitle, int index) {
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
                Icon(Icons.person, size: 40, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
                    builder: (context) => ShowDriver(driverId: _conductores[index]["id"]),
                  );
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
