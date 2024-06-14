// lib/adds/add_work_order_page.dart

// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';

class AddWorkOrderPage extends StatefulWidget {
  @override
  _AddWorkOrderPageState createState() => _AddWorkOrderPageState();
}

class _AddWorkOrderPageState extends State<AddWorkOrderPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _vehicleIdController = TextEditingController();
  final TextEditingController _providerIdController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _paymentStatusController = TextEditingController();
  final TextEditingController _dateIssuedController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ingresar Orden de Trabajo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('ID del Vehículo', _vehicleIdController),
              _buildTextField('ID del Proveedor', _providerIdController),
              _buildTextField('Detalles', _detailsController),
              _buildTextField('Costo', _costController, isNumeric: true),
              _buildTextField('Estado de Pago', _paymentStatusController),
              _buildTextField('Fecha de Emisión', _dateIssuedController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveWorkOrder,
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
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese $label';
        }
        return null;
      },
    );
  }

  void _saveWorkOrder() {
    if (_formKey.currentState!.validate()) {
     
      Navigator.pop(context);
    }
  }
}
