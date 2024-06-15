// lib/adds/add_provider_page.dart
// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddProviderPage extends StatefulWidget {
  @override
  _AddProviderPageState createState() => _AddProviderPageState();
}

class _AddProviderPageState extends State<AddProviderPage> {
  final _formKey = GlobalKey<FormState>();

  final String apiProveedores = 'https://finalprojectbackend-production-a933.up.railway.app/api/proveedores';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _saveProvider() async {
    try {
      if (_formKey.currentState!.validate()) {
        final String nombre = _nameController.text;
        final String contacto = _contactController.text;
        final String direccion = _addressController.text;
        final String telefono = _phoneController.text;
        final String correo = _emailController.text;

        final response = await http.post(
          Uri.parse(apiProveedores),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'nombre': nombre,
            'contacto': contacto,
            'direccion': direccion,
            'telefono': telefono,
            'correo': correo,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Se ha guardado el proveedor correctamente')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar el proveedor')),
          );
        }
      }
    } catch (ex) {
      print("error: $ex");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ingresar Proveedor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Nombre', _nameController),
              _buildTextField('Contacto', _contactController),
              _buildTextField('Dirección', _addressController),
              _buildTextField('Teléfono', _phoneController, isNumeric: true),
              _buildTextField('Correo Electrónico', _emailController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProvider,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumeric ? TextInputType.phone : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese $label';
        }
        return null;
      },
    );
  }
  
}