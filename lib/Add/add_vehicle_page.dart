import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

/// Página de Flutter que permite agregar un nuevo vehículo al sistema.
class AgregarVehiculo extends StatefulWidget {
  const AgregarVehiculo({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AgregarVehiculoState createState() => _AgregarVehiculoState();
}

class _AgregarVehiculoState extends State<AgregarVehiculo> {
  // Dirección de la API para agregar vehículos.
  final String apiVehiculos =
      'https://finalprojectbackend-production-a933.up.railway.app/api/vehiculos';
  // Dirección de la API para obtener conductores.
  final String apiConductores =
      'https://finalprojectbackend-production-a933.up.railway.app/api/conductores';

  // Controlador de formulario.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores de campos de texto.
  final TextEditingController _controladorMarca = TextEditingController();
  final TextEditingController _controladorModelo = TextEditingController();
  final TextEditingController _controladorAnio = TextEditingController();
  final TextEditingController _controladorKilometraje = TextEditingController();
  final TextEditingController _controladorPlaca = TextEditingController();

  // Controlador de imagen.
  final ImagePicker _imagePicker = ImagePicker();
  File? _imageFile;

  // Lista de conductores.
  List<dynamic> _conductores = [];
  // Conductor seleccionado.
  String? _conductorSeleccionado;
  // URL de la imagen
  String? _urlImagen;

  // Obtiene la lista de conductores de la API.
  Future<void> _obtenerConductores() async {
    try {
      final response = await http.get(Uri.parse(apiConductores));
      if (response.statusCode == 200) {
        setState(() {
          _conductores = jsonDecode(response.body);
        });
      } else {
        throw Exception('No se pudieron cargar los conductores');
      }
    } catch (e) {
      print('Error al cargar los conductores: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _obtenerConductores();
  }

  // Envía el formulario a la API.
  Future<void> _enviarFormulario() async {
    try {
      if (_formKey.currentState!.validate()) {
        final String placa = _controladorPlaca.text;
        final String marca = _controladorMarca.text;
        final String modelo = _controladorModelo.text;
        final String anio = _controladorAnio.text;
        final double kilometraje = double.parse(_controladorKilometraje.text);
        final String conductorAsignado = _conductorSeleccionado ?? '';
        final String urlImagen = _urlImagen ?? '';

        final response = await http.post(
          Uri.parse(apiVehiculos),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'id': placa,
            'marca': marca,
            'modelo': modelo,
            'anio': anio,
            'kilometraje': kilometraje.toString(),
            'foto': urlImagen,
            'idConductorAsignado': conductorAsignado,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Se ha guardado el vehículo correctamente')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Error al guardar el vehículo, es posible que el vehículo ya exista')),
          );
        }
      }
    } catch (ex) {
      print("error: $ex");
    }
  }

  // Cargar imagen
  Future<void> _verificarYsolicitarPermisos() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> _cargarImagen() async {
    await _verificarYsolicitarPermisos(); // Asegúrate de llamar a esta función antes de intentar cargar la imagen

    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      // Subir la imagen a Firebase Storage
      String filePath = 'images/${_controladorPlaca.text}.png';
      TaskSnapshot snapshot =
          await FirebaseStorage.instance.ref().child(filePath).putFile(file);

      // Obtener la URL de la imagen
      String imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _urlImagen = imageUrl;
        _imageFile = file;
      });
      print("URL de la imagen: $imageUrl");
    } else {
      print("No se seleccionó ninguna imagen.");
    }
  }

  // Construye la interfaz de usuario.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresar Vehículo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _construirCampoDeTexto('Placa', _controladorPlaca),
              _construirCampoDeTexto('Marca', _controladorMarca),
              _construirCampoDeTexto('Modelo', _controladorModelo),
              _construirCampoDeTexto('Año', _controladorAnio, isNumeric: true),
              _construirCampoDeTexto('Kilometraje', _controladorKilometraje,
                  isNumeric: true),
              const SizedBox(height: 20),
              _construirDropdownDeConductores(),
              const SizedBox(height: 20),
              // cargar imagen
              ElevatedButton(
                onPressed: _cargarImagen,
                child: const Text('Cargar Imagen'),
              ),
              if (_urlImagen !=
                  null) // Mostrar la imagen si _urlImagen no es nulo
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                      height: 200,
                    ),
                  ),
                ),
              //const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _enviarFormulario,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye un campo de texto con la etiqueta especificada.
  Widget _construirCampoDeTexto(String label, TextEditingController controlador,
      {bool isNumeric = false}) {
    return TextFormField(
      controller: controlador,
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

  /// Construye un dropdown de conductores (como un select).
  Widget _construirDropdownDeConductores() {
    return InputDecorator(
      decoration: const InputDecoration(
          labelText: 'Conductor Asignado',
          hintText: 'Seleccione un conductor',
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _conductorSeleccionado,
          borderRadius: BorderRadius.circular(15),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: (String? newValue) {
            setState(() {
              _conductorSeleccionado = newValue;
              print("Conductor seleccionado: $_conductorSeleccionado");
            });
          },
          items:
              _conductores.map<DropdownMenuItem<String>>((dynamic conductor) {
            return DropdownMenuItem<String>(
              value: conductor['id'],
              child: Text(conductor['nombre']),
            );
          }).toList(),
        ),
      ),
    );
  }
}
