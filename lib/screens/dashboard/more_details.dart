import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String plantName;
  final String plantImage;

  DetailPage({required this.plantName, required this.plantImage});

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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              AspectRatio(
                                aspectRatio: 1.2,
                                child:
                                    plantImage == 'assets/placeholder.jpg'
                                        ? Icon(Icons.image, size: 100)
                                        : Image.asset(
                                          plantImage,
                                          fit: BoxFit.cover,
                                        ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.favorite_border),
                              ),
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.black),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                plantName,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.black),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'This is a sample description for the ${plantName.toLowerCase()}. '
                                  'It includes information about the plant characteristics, growth habits, '
                                  'and various uses.',
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Step to Nurture:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '1. Plant in well-draining soil\n'
                                  '2. Water regularly, but avoid overwatering\n'
                                  '3. Place in a location with appropriate sunlight\n'
                                  '4. Fertilize monthly during growing season\n'
                                  '5. Prune as needed to maintain shape',
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
}
