import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditVehiclePage extends StatefulWidget {
  final Map<String, dynamic> vehicleData;

  const EditVehiclePage({super.key, required this.vehicleData});

  @override
  _EditVehiclePageState createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  late TextEditingController marcaController;
  late TextEditingController modeloController;
  late TextEditingController anioController;
  late TextEditingController kilometrajeController;
  late TextEditingController fotoController;
  late TextEditingController idConductorAsignadoController;

  @override
  void initState() {
    super.initState();
    marcaController = TextEditingController(text: widget.vehicleData['marca']);
    modeloController = TextEditingController(text: widget.vehicleData['modelo']);
    anioController = TextEditingController(text: widget.vehicleData['anio'].toString());
    kilometrajeController = TextEditingController(text: widget.vehicleData['kilometraje'].toString());
    fotoController = TextEditingController(text: widget.vehicleData['foto']);
    idConductorAsignadoController = TextEditingController(text: widget.vehicleData['idConductorAsignado']);
  }

  Future<void> updateVehicle() async {
    String apiUrl = 'https://finalprojectbackend-production-a933.up.railway.app/api/Vehiculos/${widget.vehicleData['id']}';
    final response = await http.patch(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'marca': marcaController.text,
        'modelo': modeloController.text,
        'anio': anioController.text,
        'kilometraje': kilometrajeController.text,
        'foto': fotoController.text,
        'idConductorAsignado': idConductorAsignadoController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo actualizado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el vehículo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Vehículo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              _buildTextField('Marca', marcaController),
              _buildTextField('Modelo', modeloController),
              _buildTextField('Año', anioController),
              _buildTextField('Kilometraje', kilometrajeController),
              _buildTextField('Foto', fotoController),
              _buildTextField('ID de Conductor Asignado', idConductorAsignadoController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateVehicle,
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
