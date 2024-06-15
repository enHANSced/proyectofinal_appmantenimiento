// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddReceiptPage extends StatefulWidget {
  @override
  _AddReceiptPageState createState() => _AddReceiptPageState();
}

class _AddReceiptPageState extends State<AddReceiptPage> {
  final _formKey = GlobalKey<FormState>();

  final String apiReceipts = 'https://finalprojectbackend-production-a933.up.railway.app/api/Recibos';
  final String apiWorkOrders = 'https://finalprojectbackend-production-a933.up.railway.app/api/ordenesDeTrabajo';

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateIssuedController = TextEditingController();

  List<dynamic> _workOrders = [];
  String? _selectedWorkOrder;
  String? _paymentStatus;

  @override
  void initState() {
    super.initState();
    _fetchWorkOrders();
  }

  Future<void> _fetchWorkOrders() async {
    final response = await http.get(Uri.parse(apiWorkOrders));
    if (response.statusCode == 200) {
      setState(() {
        _workOrders = jsonDecode(response.body);
      });
    } else {
      throw Exception('Error al cargar las órdenes de trabajo');
    }
  }

  Future<void> _saveReceipt() async {
    if (_formKey.currentState!.validate()) {
      try {
        final String amount = _amountController.text;
        final String dateIssued = _dateIssuedController.text;
        final String workOrderId = _selectedWorkOrder ?? '';
        final String paymentStatus = _paymentStatus ?? '';

        final response = await http.post(
          Uri.parse(apiReceipts),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'monto': amount,
            'fechaEmision': dateIssued,
            'ordenTrabajoId': workOrderId,
            'estadoPago': paymentStatus,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Se ha guardado el recibo correctamente')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar el recibo')),
          );
        }
      } catch (ex) {
        print("Error: $ex");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de red al guardar el recibo')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateIssuedController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

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
              _buildAmountField('Monto', _amountController),
              _buildDropdownField('Orden de Trabajo', _selectedWorkOrder, _workOrders.map<DropdownMenuItem<String>>((dynamic workOrder) {
                return DropdownMenuItem<String>(
                  value: workOrder['id'].toString(),
                  child: Text('${workOrder['detalles']}'),
                );
              }).toList(), (String? newValue) {
                setState(() {
                  _selectedWorkOrder = newValue;
                });
              }),
              _buildPaymentStatusDropdown(),
              _buildDateField('Fecha de Emisión', _dateIssuedController, context),
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

  Widget _buildAmountField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Seleccione una fecha',
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey),
            SizedBox(width: 10),
            Text(
              controller.text.isEmpty ? 'Seleccione una fecha' : controller.text,
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String label,
      String? value,
      List<DropdownMenuItem<String>> items,
      void Function(String?)? onChanged,
  ) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: onChanged,
          items: items,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusDropdown() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Estado de Pago',
        hintText: 'Seleccione un estado de pago',
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _paymentStatus,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: (String? newValue) {
            setState(() {
              _paymentStatus = newValue ?? 'Pagado';
            });
          },
          items: ['Pendiente', 'Pagado'].map<DropdownMenuItem<String>>((String estado) {
            return DropdownMenuItem<String>(
              value: estado,
              child: Text(estado),
            );
          }).toList(),
        ),
      ),
    );
  }
}
