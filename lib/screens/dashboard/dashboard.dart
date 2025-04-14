//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:local_plant_identification/screens/login_and_registration/login.dart';
import 'package:local_plant_identification/screens/models/plant.dart';
import 'package:local_plant_identification/services/plant_service.dart';
//import 'package:local_plant_identification/widgets/custom_bottom_navbar.dart';
//import 'package:local_plant_identification/widgets/custom_scaffold_background.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final PlantService _plantService = PlantService();
  List<Plant> _plants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    try {
      final plants = await _plantService.getPlants();
      setState(() {
        _plants = plants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading plants: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPlantDialog(context),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _plants.length,
                itemBuilder: (context, index) {
                  final plant = _plants[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(plant.name),
                      subtitle: Text(plant.description),
                      onTap: () => _showPlantDetails(context, plant),
                    ),
                  );
                },
              ),
    );
  }

  void _showPlantDetails(BuildContext context, Plant plant) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(plant.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description: ${plant.description}'),
                const SizedBox(height: 8),
                Text('Care Instructions: ${plant.careInstructions}'),
                Text('Watering: ${plant.wateringFrequency}'),
                Text('Sunlight: ${plant.sunlightNeeds}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showAddPlantDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final careController = TextEditingController();
    final wateringController = TextEditingController();
    final sunlightController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Plant'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Plant Name'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: careController,
                    decoration: const InputDecoration(
                      labelText: 'Care Instructions',
                    ),
                  ),
                  TextField(
                    controller: wateringController,
                    decoration: const InputDecoration(
                      labelText: 'Watering Frequency',
                    ),
                  ),
                  TextField(
                    controller: sunlightController,
                    decoration: const InputDecoration(
                      labelText: 'Sunlight Needs',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _plantService.addPlant(
                      name: nameController.text,
                      description: descriptionController.text,
                      careInstructions: careController.text,
                      wateringFrequency: wateringController.text,
                      sunlightNeeds: sunlightController.text,
                    );
                    Navigator.pop(context);
                    _loadPlants();
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}
