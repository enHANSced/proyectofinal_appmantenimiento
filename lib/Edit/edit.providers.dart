import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProviderPage extends StatefulWidget {
  final Map<String, dynamic> providerData;

  const EditProviderPage({super.key, required this.providerData});

  @override
  _EditProviderPageState createState() => _EditProviderPageState();
}

class _EditProviderPageState extends State<EditProviderPage> {
  late TextEditingController nombreController;
  late TextEditingController contactoController;
  late TextEditingController direccionController;
  late TextEditingController telefonoController;
  late TextEditingController correoController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.providerData['nombre']);
    contactoController = TextEditingController(text: widget.providerData['contacto']);
    direccionController = TextEditingController(text: widget.providerData['direccion']);
    telefonoController = TextEditingController(text: widget.providerData['telefono']);
    correoController = TextEditingController(text: widget.providerData['correo']);
  }

  Future<void> updateProvider() async {
    if (_formKey.currentState!.validate()) {
      String apiUrl = 'https://finalprojectbackend-production-a933.up.railway.app/api/proveedores/${widget.providerData['id']}';
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'nombre': nombreController.text,
          'contacto': contactoController.text,
          'direccion': direccionController.text,
          'telefono': telefonoController.text,
          'correo': correoController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proveedor actualizado correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el proveedor')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Proveedor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Nombre', nombreController),
              _buildTextField('Contacto', contactoController),
              _buildTextField('Dirección', direccionController),
              _buildTextField('Teléfono', telefonoController),
              _buildTextField('Correo', correoController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateProvider,
                child: Text('Actualizar'),
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
