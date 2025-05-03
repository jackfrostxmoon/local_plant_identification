// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'web_scraping.dart';
import 'models.dart';

class APIIntegration {
  final String apiKey = '';

  /// Function to identify a plant using the Plant.id API
  Future<List<Plant>?> identifyPlant(String base64Image) async {
    final webScraping = WebScraping();
    const apiUrl = 'https://plant.id/api/v3/identification';
    final headers = {
      'Api-Key': apiKey,
      'Content-Type': 'application/json',
    };
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode({
          'images': [base64Image],
          'similar_images': true
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        print(jsonResponse);

        if (jsonResponse['result']['is_plant']['probability'] as double >=
            0.1) {
          final suggestions =
              jsonResponse['result']['classification']['suggestions'];
          final identifiedPlants = <Plant>[];
          for (var suggestion in suggestions) {
            Map<String, dynamic> plant = suggestion as Map<String, dynamic>;
            String name = plant['name'] as String;
            String plantUrl = plant['similar_images'][0]['url'];
            identifiedPlants.add(Plant(
              id: plant['id'] as String,
              probability: (plant['probability'] as double),
              plantName: name,
              imagePath: plantUrl,
            ));
          }
          print(identifiedPlants[0]);
          return identifiedPlants;
        } else {
          return [];
        }
      } else {
        print('API request failed with status code ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
}
