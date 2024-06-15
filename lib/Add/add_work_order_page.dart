// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddWorkOrderPage extends StatefulWidget {
  const AddWorkOrderPage({super.key});

  @override
  _AddWorkOrderPageState createState() => _AddWorkOrderPageState();
}

class _AddWorkOrderPageState extends State<AddWorkOrderPage> {
  final String apiProveedores = 'https://finalprojectbackend-production-a933.up.railway.app/api/proveedores';
  final String apiVehiculos = 'https://finalprojectbackend-production-a933.up.railway.app/api/Vehiculos';
  final String apiOrdenesTrabajo = 'https://finalprojectbackend-production-a933.up.railway.app/api/ordenesDeTrabajo';

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _dateIssuedController = TextEditingController();

  List<dynamic> _proveedor = [];
  List<dynamic> _vehiculos = [];
  String? _proveedorSeleccionado;
  String? _vehiculoSeleccionado;
  String? _estadoPagoSeleccionado;

  Future<void> _obtenerProveedores() async {
    try {
      final response = await http.get(Uri.parse(apiProveedores));
      if (response.statusCode == 200) {
        setState(() {
          _proveedor = jsonDecode(response.body);
        });
      } else {
        throw Exception('No se pudieron cargar los Conductores');
      }
    } catch (e) {
      print('Error al cargar los Conductores: $e');
    }
  }

  Future<void> _obtenerVehiculos() async {
    try {
      final response = await http.get(Uri.parse(apiVehiculos));
      if (response.statusCode == 200) {
        setState(() {
          _vehiculos = jsonDecode(response.body);
        });
      } else {
        throw Exception('No se pudieron cargar los Vehiculos');
      }
    } catch (e) {
      print('Error al cargar los Vehiculos: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _obtenerProveedores();
    _obtenerVehiculos();
  }

  Future<void> _enviarFormulario() async {
    try {
      if (_formKey.currentState!.validate()) {
        final String idVehicle = _vehiculoSeleccionado ?? '';
        final String idProvider =  _proveedorSeleccionado ?? '';
        final String details = _detailsController.text;
        final String cost = _costController.text;
        final String paymentStatus = _estadoPagoSeleccionado ?? '';
        final String dateIssued = _dateIssuedController.text;

        final response = await http.post(
          Uri.parse(apiOrdenesTrabajo),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'vehiculoId': idVehicle,
            'proveedorId': idProvider,
            'fechaEmision': dateIssued,
            'detalles': details,
            'costo': cost,
            'estadoPago': paymentStatus,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Se ha guardado la orden de tarea correctamente')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar la orden de tarea.')),
          );
        }
      }
    } catch (ex) {
      print("error: $ex");
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
      appBar: AppBar(title: Text('Ingresar Orden de Trabajo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Detalles', _detailsController),
              _buildTextField('Costo', _costController, isNumeric: true),
              const SizedBox(height: 10),
              _construirDropdownEstadoPago(),
              const SizedBox(height: 10),
              _buildDateField('Fecha de Emisión', _dateIssuedController, context),
              const SizedBox(height: 10),
              _construirDropdownDeproveedores(),
              const SizedBox(height: 10),
              _construirDropdownDeVehiculos(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _enviarFormulario();
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
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

  Widget _buildDateField(String label, TextEditingController controller, BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Seleccione una fecha',
          contentPadding: EdgeInsets.symmetric(vertical: 20),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey),
            SizedBox(width: 10),
            Text(
              controller.text.isEmpty ? 'Seleccione una fecha' : controller.text,
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirDropdownDeproveedores() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Proveedor Asignado',
        hintText: 'Seleccione un Proveedor',
        contentPadding: EdgeInsets.symmetric(vertical: 10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _proveedorSeleccionado,
          borderRadius: BorderRadius.circular(15),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: (String? newValue) {
            setState(() {
              _proveedorSeleccionado = newValue;
            });
          },
          items: _proveedor.map<DropdownMenuItem<String>>((dynamic proveedores) {
            return DropdownMenuItem<String>(
              value: proveedores['id'].toString(),
              child: Text(proveedores['nombre'] ?? 'Sin nombre'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _construirDropdownDeVehiculos() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Vehículo Asignado',
        hintText: 'Seleccione un vehículo',
        contentPadding: EdgeInsets.symmetric(vertical: 10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _vehiculoSeleccionado,
          borderRadius: BorderRadius.circular(15),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: (String? newValue) {
            setState(() {
              _vehiculoSeleccionado = newValue;
            });
          },
          items: _vehiculos.map<DropdownMenuItem<String>>((dynamic vehiculo) {
            return DropdownMenuItem<String>(
              value: vehiculo['id'] ?? '',
              child: Text(vehiculo['modelo'] ?? 'Sin nombre'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _construirDropdownEstadoPago() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Estado de Pago',
        hintText: 'Seleccione un estado de pago',
        contentPadding: EdgeInsets.symmetric(vertical: 10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _estadoPagoSeleccionado ?? 'Pendiente',
          borderRadius: BorderRadius.circular(15),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: (String? newValue) {
            setState(() {
              _estadoPagoSeleccionado = newValue;
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
