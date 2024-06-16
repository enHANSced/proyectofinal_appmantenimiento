// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto_app_mantenimiento/Add/add_receipt_page.dart';
import 'dart:convert';
import 'package:proyecto_app_mantenimiento/Show/show_receipt.dart';
import 'package:proyecto_app_mantenimiento/monthName.dart';

class ReceiptsPage extends StatefulWidget {
  const ReceiptsPage({super.key});

  @override
  _ReceiptsPageState createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  final String apiUrl = 'https://finalprojectbackend-production-a933.up.railway.app/api/recibos';

  List<dynamic> _recibos = [];

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
          _recibos = jsonDecode(response.body);
        });
      } else {
        throw Exception('No se pudieron cargar los recibos');
      }
    } catch (e) {
      print('Error al cargar los recibos: $e');
    }
  }
  String getFormattedDate(String date) {
    final dateTime = DateTime.parse(date);
    return '${dateTime.day} de ${getMonthName(dateTime.month)} de ${dateTime.year}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestor de Recibos')),
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
                  'Ingrese los recibos que quiera mantener en la base de datos rellenando un formulario predeterminado.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _recibos.length,
                  itemBuilder: (context, index) {
                    final recibo = _recibos[index];
                    return _buildReceiptCard(
                      context,
                      'Recibo ${recibo["id"]}',
                      'Monto: ${recibo["monto"]}' '\nFecha: ${getFormattedDate(recibo["fechaEmision"])}',
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
            MaterialPageRoute(builder: (context) => AddReceiptPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context, String title, String subtitle, int index) {
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
                Icon(Icons.receipt, size: 40, color: Colors.white),
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
                      builder: (context) => ShowReceipt(receiptId: _recibos[index]["id"]),
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
