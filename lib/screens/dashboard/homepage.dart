import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/login_and_registration/login.dart';
import 'package:local_plant_identification/widgets/custom_bottom_navbar.dart';
import 'package:local_plant_identification/widgets/custom_scaffold_background.dart';

// Extracted Widget: Custom Text Button
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color; // Optional: if it needs a specific color override

  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme data

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor:
            color ??
            theme.textTheme.labelLarge?.color, // Access color from theme
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      ),
    );
  }
}

// Extracted Widget: Category Section
class CategorySection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const CategorySection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Colors.black;
    const Color textColor = Colors.black;

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 2.0),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.85,
            ),
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = items[index];
              final String itemName = item['name'] as String? ?? 'Unknown';
              final String? itemImageUrl = item['imageUrl'] as String?;
              final bool usePlaceholder =
                  item['usePlaceholder'] as bool? ??
                  (itemImageUrl == null || itemImageUrl.isEmpty);

              return _PlantItem(
                name: itemName,
                imageUrl: itemImageUrl,
                usePlaceholder: usePlaceholder,
              );
            },
          ),
        ],
      ),
    );
  }
}

// Extracted Plant Item
class _PlantItem extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool usePlaceholder;

  const _PlantItem({
    required this.name,
    this.imageUrl,
    this.usePlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Colors.black;
    const Color textColor = Colors.black;
    const Color placeholderColor = Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              clipBehavior: Clip.antiAlias,
              child:
                  usePlaceholder || imageUrl == null || imageUrl!.isEmpty
                      ? Icon(
                        Icons.image_outlined,
                        size: 50,
                        color: placeholderColor,
                      )
                      : Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              color: placeholderColor,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading image: $error");
                          return Icon(
                            Icons.broken_image_outlined,
                            size: 50,
                            color: placeholderColor,
                          );
                        },
                      ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: borderColor, width: 1.5)),
            ),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class HomePageAlt2 extends StatefulWidget {
  const HomePageAlt2({super.key});

  @override
  State<HomePageAlt2> createState() => _HomePageAlt2State();
}

class _HomePageAlt2State extends State<HomePageAlt2> {
  late Future<String> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = loadUsername();
  }

  Future<String> loadUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    String fetchedUsername = 'User';

    if (user != null) {
      try {
        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        if (userSnapshot.exists && userSnapshot.data() != null) {
          final data = userSnapshot.data() as Map<String, dynamic>;
          fetchedUsername = data['username'] ?? fetchedUsername;
        } else {
          fetchedUsername =
              user.displayName ?? user.email?.split('@')[0] ?? 'User';
        }
      } catch (e) {
        print("Error loading user data: $e");
        fetchedUsername =
            user.displayName ?? user.email?.split('@')[0] ?? 'User';
      }
    }
    return fetchedUsername;
  }

  void _onFabPressed() {
    print('Camera FAB pressed!');
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera Action Triggered!')));
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget searchScreenContent = SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 80.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Plants or Symptoms',
                      hintStyle: const TextStyle(color: Colors.black54),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black54,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  print("Filter tapped");
                },
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Text(
                'Plant Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 8),
              Expanded(child: Divider(color: Colors.black, thickness: 1.0)),
            ],
          ),
          const SizedBox(height: 16),
          const CategorySection(
            title: 'Flowers',
            items: [
              {'name': 'Daisy', 'imageUrl': ''},
              {'name': 'Dandelion', 'imageUrl': ''},
            ],
          ),
          const CategorySection(
            title: 'Herbs',
            items: [
              {'name': 'Mint', 'usePlaceholder': true},
              {'name': 'Basil', 'usePlaceholder': true},
            ],
          ),
        ],
      ),
    );

    return CustomScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: const Border(
            bottom: BorderSide(color: Colors.black, width: 1.5),
          ),
          automaticallyImplyLeading: false,
          title: FutureBuilder<String>(
            future: _userDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading...");
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                return Text(
                  "Welcome, ${snapshot.data}!",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                );
              }
            },
          ),
          titleSpacing: 16.0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CustomTextButton(
                text: 'Sign out',
                onPressed: _signOut,
                color: Colors.black54, // Specify color
              ),
            ),
          ],
        ),
        body: searchScreenContent,
        floatingActionButton: FloatingActionButton(
          onPressed: _onFabPressed,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Colors.black, width: 1.5),
          ),
          child: const Icon(Icons.camera_alt_outlined),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: 1,
          onItemTapped: (int index) {},
          backgroundColor: const Color(0xFFF0F4C3),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          items: const [],
        ),
      ),
    );
  }
}
