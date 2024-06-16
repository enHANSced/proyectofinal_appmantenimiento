import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditReceiptPage extends StatefulWidget {
  final Map<String, dynamic> receiptData;

  const EditReceiptPage({super.key, required this.receiptData});

  @override
  _EditReceiptPageState createState() => _EditReceiptPageState();
}

class _EditReceiptPageState extends State<EditReceiptPage> {
  late TextEditingController ordenTrabajoIdController;
  late TextEditingController fechaEmisionController;
  late TextEditingController montoController;
  late TextEditingController estadoPagoController;
  late TextEditingController detallesPagoIdController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    ordenTrabajoIdController = TextEditingController(text: widget.receiptData['ordenTrabajoId'].toString());
    fechaEmisionController = TextEditingController(text: widget.receiptData['fechaEmision']);
    montoController = TextEditingController(text: widget.receiptData['monto'].toString());
    estadoPagoController = TextEditingController(text: widget.receiptData['estadoPago']);
    detallesPagoIdController = TextEditingController(text: widget.receiptData['detallesPagoId'].toString());
  }

  Future<void> updateReceipt() async {
    if (_formKey.currentState!.validate()) {
      String apiUrl = 'https://finalprojectbackend-production-a933.up.railway.app/api/Recibos/${widget.receiptData['id']}';
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          //'ordenTrabajoId': ordenTrabajoIdController.text,
          //'fechaEmision': fechaEmisionController.text,
          'monto': montoController.text,
          'estadoPago': estadoPagoController.text,
          //'detallesPagoId': int.parse(detallesPagoIdController.text),
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recibo actualizado correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el recibo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Recibo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('ID de Orden de Trabajo', ordenTrabajoIdController, isNumeric: true),
              _buildTextField('Fecha de Emisión', fechaEmisionController),
              _buildTextField('Monto', montoController, isNumeric: true),
              _buildTextField('Estado de Pago', estadoPagoController),
              _buildTextField('ID de Detalles de Pago', detallesPagoIdController, isNumeric: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateReceipt,
                child: Text('Actualizar'),
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
        if (isNumeric && double.tryParse(value) == null) {
          return 'Por favor, ingrese un número válido';
        }
        return null;
      },
    );
  }
}
