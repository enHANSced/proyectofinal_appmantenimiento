// lib/show_provider.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Widget para mostrar los detalles de un proveedor.
///
/// Recibe como parámetro el ID del proveedor que se desea mostrar.
class ShowProvider extends StatefulWidget {
  final String providerId;

  /// Construye un widget para mostrar los detalles de un proveedor.
  ///
  /// El parámetro [providerId] es el ID del proveedor que se desea mostrar.
  const ShowProvider({super.key, required this.providerId});

  @override
  _ShowProviderState createState() => _ShowProviderState();
}

class _ShowProviderState extends State<ShowProvider> {
  // Futura que se encargará de obtener los datos del proveedor desde la API
  late Future<dynamic> providerData;

  @override
  void initState() {
    super.initState();
    // Inicializamos la futura que obtendrá los datos del proveedor
    providerData = fetchProviderData();
  }

  /// Función que obtiene los datos del proveedor desde la API.
  ///
  /// Devuelve un [Future] que contiene los datos del proveedor en formato JSON.
  Future<dynamic> fetchProviderData() async {
    // Construimos la URL de la API utilizando el ID del proveedor recibido como parámetro
    String apiUrl =
        'https://finalprojectbackend-production-a933.up.railway.app/api/proveedores/${widget.providerId}';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      // Si la respuesta es exitosa, decodificamos los datos en formato JSON
      return jsonDecode(response.body);
    } else {
      // Si la respuesta es erronea, lanzamos una excepción
      print('Failed to load provider: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load provider');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: providerData,
      builder: (context, snapshot) {
        // Si la futura aún no ha finalizado, mostramos un indicador de carga
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            // Si los datos han sido obtenidos exitosamente, mostramos los detalles del proveedor
            return _buildProviderDetailsDialog(context, snapshot.data);
          } else if (snapshot.hasError) {
            // Si ha ocurrido un error, mostramos el mensaje de error
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

  /// Función que construye un diálogo para mostrar los detalles del proveedor.
  ///
  /// El parámetro [context] es el contexto de la build, y [providerData] es el objeto JSON que contiene los detalles del proveedor.
  Widget _buildProviderDetailsDialog(BuildContext context, dynamic providerData) {
    return AlertDialog(
      title: const Text('Datos del Proveedor'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            // Mostramos los detalles del proveedor
            ListTile(
              leading: const Icon(Icons.business),
              title: Text('Nombre: ${providerData['nombre']}'),
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone),
              title: Text('Contacto: ${providerData['contacto']}'),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text('Dirección: ${providerData['direccion']}'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text('Teléfono: ${providerData['telefono']}'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text('Correo Electrónico: ${providerData['correo']}'),
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
        // Botón para eliminar el proveedor
        TextButton(
          onPressed: () => deleteProvider(context),
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  /// Función que elimina el proveedor.
  ///
  /// Muestra un diálogo de confirmación antes de eliminar el proveedor. Si el usuario confirma la eliminación, se realiza una solicitud HTTP DELETE a la API para eliminar el proveedor.
  Future<void> deleteProvider(BuildContext context) async {
    // Mostramos un diálogo de confirmación antes de eliminar el proveedor
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: const Text('¿Estás seguro de que deseas eliminar este proveedor?'),
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

    // Si el usuario confirma la eliminación, realizamos una solicitud HTTP DELETE a la API para eliminar el proveedor
    String apiUrl =
        'https://finalprojectbackend-production-a933.up.railway.app/api/proveedores/${widget.providerId}';
    final response = await http.delete(Uri.parse(apiUrl));
    if (response.statusCode == 204) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Proveedor eliminado correctamente, recarga la página para ver los cambios')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el proveedor')),
      );
    }
  }
}