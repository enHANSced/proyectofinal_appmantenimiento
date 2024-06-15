// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 

/// Widget para mostrar los detalles de un vehículo.
///
/// Recibe como parámetro el ID del vehículo que se desea mostrar.
class ShowVehicle extends StatefulWidget {
  final String vehicleId;

  /// Construye un widget para mostrar los detalles de un vehículo.
  ///
  /// El parámetro [vehicleId] es el ID del vehículo que se desea mostrar.
  const ShowVehicle({super.key, required this.vehicleId});

  @override
  _ShowVehicleState createState() => _ShowVehicleState();
}

class _ShowVehicleState extends State<ShowVehicle> {
  // Futura que se encargará de obtener los datos del vehículo desde la API
  late Future<dynamic> vehicleData;

  @override
  void initState() {
    super.initState();
    // Inicializamos la futura que obtendrá los datos del vehículo
    vehicleData = fetchVehicleData();
  }

  /// Función que obtiene los datos del vehículo desde la API.
  ///
  /// Devuelve un [Future] que contiene los datos del vehículo en formato JSON.
  Future<dynamic> fetchVehicleData() async {
    // Construimos la URL de la API utilizando el ID del vehículo recibido como parámetro
    String apiUrl =
        'https://finalprojectbackend-production-a933.up.railway.app/api/vehiculos/${widget.vehicleId}';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      // Si la respuesta es exitosa, decodificamos los datos en formato JSON
      return jsonDecode(response.body);
    } else {
      // Si la respuesta es erronea, lanzamos una excepción
      throw Exception('Failed to load vehicle');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: vehicleData,
      builder: (context, snapshot) {
        // Si la futura aún no ha finalizado, mostramos un indicador de carga
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            // Si los datos han sido obtenidos exitosamente, mostramos los detalles del vehículo
            return _buildVehicleDetailsDialog(context, snapshot.data);
          } else if (snapshot.hasError) {
            // Si ha ocurrido un error, mostramos el mensaje de error
            return Text("${snapshot.error}");
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  /// Función que construye un diálogo para mostrar los detalles del vehículo.
  ///
  /// El parámetro [context] es el contexto de la build, y [vehicleData] es el objeto JSON que contiene los detalles del vehículo.
  Widget _buildVehicleDetailsDialog(BuildContext context, dynamic vehicleData) {
    return AlertDialog(
      title: const Text('Datos del Vehículo'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            // Si el vehículo tiene una foto, mostramos la imagen
            vehicleData["foto"] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(vehicleData["foto"]),
                  )
                : const SizedBox(),
            // Mostramos los detalles del vehículo
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: Text('Modelo: ${vehicleData['modelo']}'),
            ),
            ListTile(
              leading: const Icon(Icons.branding_watermark),
              title: Text('Marca: ${vehicleData['marca']}'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('Año: ${vehicleData['anio']}'),
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: Text('Placa: ${vehicleData['id']}'),
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: Text('Kilometraje: ${vehicleData['kilometraje']}'),
            ),
          ],
        ),
      ),
      actions: [
        // Botón para cerrar el diálogo
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        // Botón para eliminar el vehículo
        TextButton(
          onPressed: () => deleteVehicle(context),
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  /// Función que elimina el vehículo.
  ///
  /// Muestra un diálogo de confirmación antes de eliminar el vehículo. Si el usuario confirma la eliminación, se realiza una solicitud HTTP DELETE a la API para eliminar el vehículo.
  Future<void> deleteVehicle(BuildContext context) async {
    // Mostramos un diálogo de confirmación antes de eliminar el vehículo
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: const Text('¿Estás seguro de que deseas eliminar este vehículo?'),
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

    // Si el usuario confirma la eliminación, realizamos una solicitud HTTP DELETE a la API para eliminar el vehículo
    String apiUrl =
        'https://finalprojectbackend-production-a933.up.railway.app/api/vehiculos/${widget.vehicleId}';
    final response = await http.delete(Uri.parse(apiUrl));
    if (response.statusCode == 204) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Vehículo eliminado correctamente, recarga la página para ver los cambios')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el vehículo')),
      );
    }
  }
}

