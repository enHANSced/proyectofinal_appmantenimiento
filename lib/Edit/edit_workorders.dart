import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditWorkOrderPage extends StatefulWidget {
  final Map<String, dynamic> workOrderData;

  const EditWorkOrderPage({super.key, required this.workOrderData, required orderData});

  @override
  _EditWorkOrderPageState createState() => _EditWorkOrderPageState();
}

class _EditWorkOrderPageState extends State<EditWorkOrderPage> {
  late TextEditingController vehiculoIdController;
  late TextEditingController proveedorIdController;
  late TextEditingController fechaEmisionController;
  late TextEditingController detallesController;
  late TextEditingController costoController;
  late TextEditingController estadoPagoController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    vehiculoIdController = TextEditingController(text: widget.workOrderData['vehiculoId']);
    proveedorIdController = TextEditingController(text: widget.workOrderData['proveedorId'].toString());
    fechaEmisionController = TextEditingController(text: widget.workOrderData['fechaEmision']);
    detallesController = TextEditingController(text: widget.workOrderData['detalles']);
    costoController = TextEditingController(text: widget.workOrderData['costo'].toString());
    estadoPagoController = TextEditingController(text: widget.workOrderData['estadoPago']);
  }

  Future<void> updateWorkOrder() async {
    if (_formKey.currentState!.validate()) {
      String apiUrl = 'https://finalprojectbackend-production-a933.up.railway.app/api/ordenesdetrabajo/${widget.workOrderData['id']}';
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          //'vehiculoId': vehiculoIdController.text,
          //'proveedorId': proveedorIdController.text,
          //'fechaEmision': fechaEmisionController.text,
          'detalles': detallesController.text,
          'costo': costoController.text,
          'estadoPago': estadoPagoController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orden de trabajo actualizada correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar la orden de trabajo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Orden de Trabajo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('ID del Vehículo', vehiculoIdController),
              _buildTextField('ID del Proveedor', proveedorIdController, isNumeric: true),
              _buildTextField('Fecha de Emisión', fechaEmisionController),
              _buildTextField('Detalles', detallesController),
              _buildTextField('Costo', costoController, isNumeric: true),
              _buildTextField('Estado de Pago', estadoPagoController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateWorkOrder,
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
