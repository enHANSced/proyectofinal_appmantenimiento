import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:proyecto_app_mantenimiento/monthName.dart';

class ShowDriver extends StatefulWidget {
  final String driverId;

  const ShowDriver({super.key, required this.driverId});

  @override
  _ShowDriverState createState() => _ShowDriverState();
}

class _ShowDriverState extends State<ShowDriver> {
  final String apiUrl = 'https://finalprojectbackend-production-a933.up.railway.app/api/conductores';

  late Future<dynamic> _driverData;

  @override
  void initState() {
    super.initState();
    _driverData = fetchDriverData();
  }

  Future<dynamic> fetchDriverData() async {
    final response = await http.get(Uri.parse('$apiUrl/${widget.driverId}'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar los detalles del conductor');
    }
  }

  String getFormattedDate(String date) {
    final dateTime = DateTime.parse(date);
    return '${dateTime.day} de ${getMonthName(dateTime.month)} de ${dateTime.year}';
    
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _driverData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return _buildDriverDetailsDialog(context, snapshot.data);
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

  Widget _buildDriverDetailsDialog(BuildContext context, dynamic driverData) {
    return AlertDialog(
      title: const Text('Detalles del Conductor'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('ID: ${driverData['id']}'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('Nombre: ${driverData['nombre']}'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text('Teléfono: ${driverData['telefono']}'),
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: Text('Vehículo Asignado: ${driverData['conductorAsignado']}'),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: Text('Número de Licencia: ${driverData['numeroLicencia']}'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('Expiración de Licencia:\n${getFormattedDate(driverData['expiracionLicencia'])}'),
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
          onPressed: () => deleteDriver(context),
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Future<void> deleteDriver(BuildContext context) async {
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: const Text('¿Estás seguro de que deseas eliminar este conductor?'),
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

    final response = await http.delete(Uri.parse('$apiUrl/${widget.driverId}'));
    if (response.statusCode == 204) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conductor eliminado correctamente, recarga la página para ver los cambios')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el conductor')),
      );
    }
  }
}
