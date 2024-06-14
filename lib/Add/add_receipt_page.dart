// lib/adds/add_receipt_page.dart

import 'package:flutter/material.dart';

class AddReceiptPage extends StatefulWidget {
  @override
  _AddReceiptPageState createState() => _AddReceiptPageState();
}

class _AddReceiptPageState extends State<AddReceiptPage> {
  final _formKey = GlobalKey<FormState>();

  
  final TextEditingController _workOrderIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _paymentStatusController = TextEditingController();
  final TextEditingController _dateIssuedController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ingresar Recibo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('ID de Orden de Trabajo', _workOrderIdController),
              _buildTextField('Monto', _amountController, isNumeric: true),
              _buildTextField('Estado de Pago', _paymentStatusController),
              _buildTextField('Fecha de Emisión', _dateIssuedController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveReceipt,
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

  void _saveReceipt() {
    if (_formKey.currentState!.validate()) {
      // Guardar el recibo en la base de datos
      Navigator.pop(context);
    }
  }
}
