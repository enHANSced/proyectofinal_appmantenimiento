import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto_app_mantenimiento/Edit/edit_receipts.dart';
import 'dart:convert';

import 'package:proyecto_app_mantenimiento/monthName.dart';

class ShowReceipt extends StatefulWidget {
  final int receiptId;

  const ShowReceipt({super.key, required this.receiptId});

  @override
  _ShowReceiptState createState() => _ShowReceiptState();
}

class _ShowReceiptState extends State<ShowReceipt> {
  final String apiUrl =
      'https://finalprojectbackend-production-a933.up.railway.app/api/Recibos';

  late Future<dynamic> _receiptData;

  @override
  void initState() {
    super.initState();
    _receiptData = fetchReceiptData();
  }

  Future<dynamic> fetchReceiptData() async {
    final response = await http.get(Uri.parse('$apiUrl/${widget.receiptId}'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar los detalles del recibo');
    }
  }

  String getFormattedDate(String date) {
    final dateTime = DateTime.parse(date);
    return '${dateTime.day} de ${getMonthName(dateTime.month)} de ${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _receiptData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return _buildReceiptDetailsDialog(context, snapshot.data);
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text("${snapshot.error}"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildReceiptDetailsDialog(BuildContext context, dynamic receiptData) {
    return AlertDialog(
      title: const Text('Detalles del Recibo'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            ListTile(
              leading: const Icon(Icons.receipt),
              title: Text('ID: ${receiptData['id'].toString()}'),
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: Text(
                  'ID de Orden de Trabajo: ${receiptData['ordenTrabajoId'].toString()}'),
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: Text('Monto: ${receiptData['monto'].toString()}'),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: Text(
                  'Fecha de Emisión: ${getFormattedDate(receiptData['fechaEmision'])}'),
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: Text('Estado de Pago: ${receiptData['estadoPago']}'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditReceiptPage(receiptData: receiptData)),
            );
          },
          child: const Text('Editar', style: TextStyle(color: Colors.blue)),
        ),
        TextButton(
          onPressed: () => deleteReceipt(context),
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Future<void> deleteReceipt(BuildContext context) async {
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este recibo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );

    if (!confirmDelete) return;

    final response =
        await http.delete(Uri.parse('$apiUrl/${widget.receiptId}'));
    if (response.statusCode == 204) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Recibo eliminado correctamente, recarga la página para ver los cambios')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el recibo')),
      );
    }
  }
}
