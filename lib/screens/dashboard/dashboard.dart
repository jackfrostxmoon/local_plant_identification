// main.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/dashboard/more_details.dart';

void main() {
  runApp(PlantApp());
}

class PlantApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Identification App',
      theme: ThemeData(
        primaryColor: Colors.green,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF009900),
          secondary: Colors.white,
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome User!'),
        backgroundColor: Color(0xFF009900),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Sign out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                        IconButton(icon: Icon(Icons.search), onPressed: () {}),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.filter_alt_outlined),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Plant Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Flowers section
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Flowers',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => DetailPage(
                                                plantName: 'Daisy',
                                                plantImage:
                                                    'https://fra.cloud.appwrite.io/v1/storage/buckets/67fc68bc003416307fcf/files/67fef36e000ca498294e/view?project=67f50b9d003441bfb6ac&mode=admin',
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1,
                                            child: Image.network(
                                              'https://fra.cloud.appwrite.io/v1/storage/buckets/67fc68bc003416307fcf/files/67fef36e000ca498294e/view?project=67f50b9d003441bfb6ac&mode=admin',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Daisy'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => DetailPage(
                                                plantName: 'Dandelion',
                                                plantImage:
                                                    'assets/images/dandelion.jpg',
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1,
                                            child: Image.asset(
                                              'assets/images/dandelion.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Dandelion'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Herbs section
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Herbs',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => DetailPage(
                                                plantName: 'Daisy',
                                                plantImage:
                                                    'assets/placeholder.jpg',
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1,
                                            child: Icon(Icons.image, size: 50),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Daisy'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => DetailPage(
                                                plantName: 'Dandelion',
                                                plantImage:
                                                    'assets/placeholder.jpg',
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1,
                                            child: Icon(Icons.image, size: 50),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Dandelion'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // New Trees section
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Trees',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => DetailPage(
                                                plantName: 'Oak',
                                                plantImage:
                                                    'assets/placeholder.jpg',
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1,
                                            child: Icon(Icons.nature, size: 50),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Oak'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => DetailPage(
                                                plantName: 'Maple',
                                                plantImage:
                                                    'assets/placeholder.jpg',
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1,
                                            child: Icon(Icons.park, size: 50),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Maple'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF009900),
                shape: CircleBorder(),
                padding: EdgeInsets.all(16),
              ),
              onPressed: () {},
              child: Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.grey[200],
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourite',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
      ),
    );
  }
}

class MoreInfoPage extends StatelessWidget {
  final String plantName;

  MoreInfoPage({required this.plantName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome User!'),
        backgroundColor: Color(0xFF009900),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Sign out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interesting Fact:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Divider(thickness: 1),
                        Text(getInterestingFacts(plantName)),
                        SizedBox(height: 16),
                        Text(
                          'Mostly Found Areas:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Divider(thickness: 1),
                        Text(getFoundAreas(plantName)),
                        SizedBox(height: 16),
                        Text(
                          'Hazard to Human & Pet:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Divider(thickness: 1),
                        Text(getHazardInfo(plantName)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            currentIndex: 2,
            onTap: (index) {
              if (index == 0) {
                Navigator.popUntil(context, (route) => route.isFirst);
              } else if (index == 1) {
                // Go back to detail page
                Navigator.pop(context);
              }
            },
            backgroundColor: Colors.grey[200],
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favourite',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: -30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF009900),
                shape: CircleBorder(),
                padding: EdgeInsets.all(16),
              ),
              onPressed: () {
                print('Camera button pressed!');
              },
              child: Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String getInterestingFacts(String plantName) {
    if (plantName == 'Daisy') {
      return 'Daisies are actually composed of two types of flowers – a center disc of tubular flowers surrounded by petal-like ray flowers. They belong to one of the largest plant families, Asteraceae. The name "daisy" comes from "day\'s eye" because the flowers open at dawn and close at dusk.';
    } else if (plantName == 'Dandelion') {
      return 'Every part of a dandelion is useful: the roots, leaves, and flowers are all edible and have medicinal properties. Dandelions can tell the time - they open in the morning and close in the evening. Their seed heads (the "puffballs") can contain up to 200 seeds that can travel up to 5 miles from their origin.';
    } else if (plantName == 'Oak') {
      return 'Oak trees can live for over 1,000 years and support more than 500 different species of wildlife. A single oak can produce up to 10 million acorns in its lifetime. The oak is considered sacred in many cultures and is often associated with strength, endurance, and wisdom.';
    } else if (plantName == 'Maple') {
      return 'Maple trees are best known for their vibrant autumn colors and sweet sap that produces maple syrup. It takes about 40 gallons of maple sap to make just 1 gallon of maple syrup. The maple leaf is the national symbol of Canada and appears on their flag.';
    } else {
      return 'This plant has unique characteristics and properties that make it special in the plant kingdom. More specific information will be added soon.';
    }
  }

  String getFoundAreas(String plantName) {
    if (plantName == 'Daisy') {
      return 'Daisies are native to Europe and temperate regions of Asia but have been naturalized across North America and Australia. They thrive in meadows, grasslands, and lawns, preferring sunny locations with well-draining soil.';
    } else if (plantName == 'Dandelion') {
      return 'Dandelions are found worldwide in temperate regions. They grow practically anywhere with sun exposure - meadows, lawns, gardens, roadsides, and even in cracks in pavement or walls. They are incredibly adaptable and can thrive in various soil conditions.';
    } else if (plantName == 'Oak') {
      return 'Oak trees are found throughout the Northern Hemisphere, including North America, Europe, and Asia. Different species are adapted to various climates, from Mediterranean to cold temperate forests. They typically prefer well-drained soils and full sun exposure.';
    } else if (plantName == 'Maple') {
      return 'Maple trees are primarily found in Asia, Europe, northern Africa, and North America. They thrive in temperate regions with distinct seasons. Different species have adapted to various environments, from mountains to valleys, but most prefer moist, well-drained soil.';
    } else {
      return 'This plant can be found in various regions depending on climate conditions. Specific geographical distribution information will be updated soon.';
    }
  }

  String getHazardInfo(String plantName) {
    if (plantName == 'Daisy') {
      return 'Daisies are generally considered non-toxic to humans and most pets. However, some people may experience contact dermatitis if they have sensitive skin or allergies. Some animals, particularly grazing livestock, might experience mild digestive upset if they consume large quantities.';
    } else if (plantName == 'Dandelion') {
      return 'Dandelions are not toxic to humans or pets - in fact, they\'re edible and nutritious. Some people may have allergic reactions to the milky sap if they have latex allergies. No significant hazards are associated with dandelions for most people and animals.';
    } else if (plantName == 'Oak') {
      return 'Oak trees are generally safe, but acorns and young leaves contain tannins that can be toxic if consumed in large quantities, especially to livestock and pets. The pollen can cause allergic reactions in sensitive individuals. Oak processionary moth caterpillars that inhabit oak trees can cause skin irritation.';
    } else if (plantName == 'Maple') {
      return 'Maple trees are generally non-toxic to humans. However, horses that consume wilted maple leaves can develop a potentially fatal condition called Equine Maple Toxicosis. For most pets and humans, maple trees pose minimal risk, though the helicopter-like seeds might cause mild choking hazards for small pets.';
    } else {
      return 'Information about potential hazards to humans and pets is currently being researched. Always exercise caution with unfamiliar plants.';
    }
  }
}
