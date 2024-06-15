import 'package:flutter/material.dart';
import 'package:proyecto_app_mantenimiento/Add/add_vehicle_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:proyecto_app_mantenimiento/Show/show_vehicle.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  _VehiclesPageState createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  final String apiVehiclesUrl =
      'https://finalprojectbackend-production-a933.up.railway.app/api/Vehiculos';
  final String apiDriversUrl =
      'https://finalprojectbackend-production-a933.up.railway.app/api/conductores';

  List vehiculos = [];
  Map<String, String> conductoresMap = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future fetchData() async {
    await Future.wait([fetchVehicles(), fetchConductores()]);
    setState(() {});
  }

  Future fetchVehicles() async {
    final response = await http.get(Uri.parse(apiVehiclesUrl));
    if (response.statusCode == 200) {
      setState(() {
        vehiculos = jsonDecode(response.body);
      });
    }
  }

  Future fetchConductores() async {
    final response = await http.get(Uri.parse(apiDriversUrl));
    if (response.statusCode == 200) {
      List conductores = jsonDecode(response.body);
      setState(() {
        conductoresMap = {
          for (var conductor in conductores) conductor['id'].toString(): conductor['nombre']
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de Vehículos')),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingrese los vehículos que quiera mantener en la base de datos.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vehiculos.length,
                  itemBuilder: (context, index) => _buildVehicleCard(
                    context,
                    '${vehiculos[index]["marca"]} ${vehiculos[index]["modelo"]}',
                    'Placa: ${vehiculos[index]["id"]}' '\nConductor: ${conductoresMap[vehiculos[index]["idConductorAsignado"]?.toString()] ?? 'No asignado'}',
                    index,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgregarVehiculo()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildVehicleCard(
      BuildContext context, String title, String subtitle, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, size: 40, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          ShowVehicle(vehicleId: vehiculos[index]["id"]));
                },
                child: const Text('Más Información'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
