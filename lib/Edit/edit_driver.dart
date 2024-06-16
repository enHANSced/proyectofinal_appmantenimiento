import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditDriverPage extends StatefulWidget {
  final Map<String, dynamic> driverData;

  const EditDriverPage({super.key, required this.driverData});

  @override
  _EditDriverPageState createState() => _EditDriverPageState();
}

class _EditDriverPageState extends State<EditDriverPage> {
  late TextEditingController nombreController;
  late TextEditingController telefonoController;
  late TextEditingController numeroLicenciaController;
  late TextEditingController expiracionLicenciaController;
  late TextEditingController notasController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.driverData['nombre']);
    telefonoController = TextEditingController(text: widget.driverData['telefono']);
    numeroLicenciaController = TextEditingController(text: widget.driverData['numeroLicencia']);
    expiracionLicenciaController = TextEditingController(text: widget.driverData['expiracionLicencia']);
    notasController = TextEditingController(text: widget.driverData['notas']);
  }

  Future<void> updateDriver() async {
    if (_formKey.currentState!.validate()) {
      String apiUrl = 'https://finalprojectbackend-production-a933.up.railway.app/api/Conductores/${widget.driverData['id']}';
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'nombre': nombreController.text,
          'telefono': telefonoController.text,
          'numeroLicencia': numeroLicenciaController.text,
          //'expiracionLicencia': expiracionLicenciaController.text,
          //'foto': "Something else",
          //'notas': "Something else",
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conductor actualizado correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el conductor')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Conductor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Nombre', nombreController),
              _buildTextField('Teléfono', telefonoController),
              _buildTextField('Número de Licencia', numeroLicenciaController),
              _buildTextField('Expiración de Licencia', expiracionLicenciaController),
              //_buildTextField('Notas', notasController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateDriver,
                child: const Text('Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese $label';
        }
        return null;
      },
    );
  }
}
