import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowWorkOrder extends StatefulWidget {
  final int orderId;

  const ShowWorkOrder({super.key, required this.orderId});

  @override
  _ShowWorkOrderState createState() => _ShowWorkOrderState();
}

class _ShowWorkOrderState extends State<ShowWorkOrder> {
  late Future<dynamic> orderData;

  @override
  void initState() {
    super.initState();
    orderData = fetchOrderData();
  }

  Future<dynamic> fetchOrderData() async {
    String apiUrl =
        'https://finalprojectbackend-production-a933.up.railway.app/api/ordenesDeTrabajo/${widget.orderId}';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to load work order: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Esta orden de trabajo ya no existe');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: orderData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return _buildWorkOrderDetailsDialog(context, snapshot.data);
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

  Widget _buildWorkOrderDetailsDialog(BuildContext context, dynamic orderData) {
    return AlertDialog(
      title: const Text('Detalles de la Orden de Trabajo'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            ListTile(
              leading: const Icon(Icons.directions_car),
              title:
                  Text('ID del Vehículo: ${orderData['vehiculoId'] ?? 'N/A'}'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                  'ID del Proveedor: ${orderData['proveedorId'] ?? 'N/A'}'),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: Text(
                  'Fecha de Emisión: ${orderData['fechaEmision'] ?? 'N/A'}'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: Text('Detalles: ${orderData['detalles'] ?? 'N/A'}'),
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: Text('Costo: ${orderData['costo']?.toString() ?? 'N/A'}'),
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title:
                  Text('Estado de Pago: ${orderData['estadoPago'] ?? 'N/A'}'),
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
          onPressed: () => deleteWorkOrder(context),
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Future<void> deleteWorkOrder(BuildContext context) async {
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar esta orden de trabajo?'),
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

    String apiUrl =
        'https://finalprojectbackend-production-a933.up.railway.app/api/ordenesDeTrabajo/${widget.orderId}';
    final response = await http.delete(Uri.parse(apiUrl));
    if (response.statusCode == 204) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Orden de trabajo eliminada correctamente, recarga la página para ver los cambios'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar la orden de trabajo')),
      );
    }
  }
}
