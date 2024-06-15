import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class AddDriverPage extends StatefulWidget {
  @override
  _AddDriverPageState createState() => _AddDriverPageState();
}

class _AddDriverPageState extends State<AddDriverPage> {
  final _formKey = GlobalKey<FormState>();

  final String apiDrivers = 'https://finalprojectbackend-production-a933.up.railway.app/api/conductores';
  final String apiVehicles = 'https://finalprojectbackend-production-a933.up.railway.app/api/Vehiculos';

  final TextEditingController _identidadController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _licenseExpiryController = TextEditingController();

  List<dynamic> _vehiculos = [];
  String? _vehiculoSeleccionado;

  Future<void> _fetchVehicles() async {
    try {
      final response = await http.get(Uri.parse(apiVehicles));
      if (response.statusCode == 200) {
        setState(() {
          _vehiculos = jsonDecode(response.body);
        });
      } else {
        throw Exception('No se pudieron cargar los vehículos');
      }
    } catch (e) {
      print('Error al cargar los vehículos: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _saveDriver() async {
    if (_formKey.currentState!.validate()) {
      try {
        final String id = _identidadController.text;
        final String nombre = _nameController.text;
        final String telefono = _contactController.text;
        final String conductorAsignado = _vehiculoSeleccionado ?? '';
        final String numeroLicencia = _licenseNumberController.text;
        final String expiracionLicencia = _licenseExpiryController.text;

        final response = await http.post(
          Uri.parse(apiDrivers),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'id': id,
            'nombre': nombre,
            'telefono': telefono,
            'conductorAsignado': conductorAsignado,
            'numeroLicencia': numeroLicencia,
            'expiracionLicencia': expiracionLicencia,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Se ha guardado el conductor correctamente')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar el conductor')),
          );
        }
      } catch (ex) {
        print("Error: $ex");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de red al guardar el conductor')),
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
        _licenseExpiryController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Conductor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('ID de Identidad', _identidadController, isNumeric: true),
              _buildTextField('Nombre', _nameController),
              _buildTextField('Teléfono', _contactController, isNumeric: true),
              _buildDropdownField('Vehículo Asignado', _vehiculoSeleccionado, _vehiculos.map<DropdownMenuItem<String>>((dynamic vehiculo) {
                return DropdownMenuItem<String>(
                  value: vehiculo['id'].toString(),
                  child: Text('Vehículo ${vehiculo['modelo']}'),
                );
              }).toList(), (String? newValue) {
                setState(() {
                  _vehiculoSeleccionado = newValue;
                });
              }),
              _buildTextField('Número de Licencia', _licenseNumberController, isNumeric: true),
              _buildDateField('Expiración de Licencia', _licenseExpiryController, context),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveDriver,
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
      inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
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
}
