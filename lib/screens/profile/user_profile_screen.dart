import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cached_network_image/cached_network_image.dart'; // Removed
import 'edit_profile_screen.dart'; // Import the edit screen

class UserProfileScreen extends StatefulWidget {
  final String userId; // User ID to display

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<DocumentSnapshot<Map<String, dynamic>>>? _userDocFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Initial load
  }

  // Function to load or reload user data
  void _loadUserData() {
    if (widget.userId.isNotEmpty) {
      setState(() {
        _userDocFuture =
            _userDocFuture =
                _firestore.collection('users').doc(widget.userId).get();
      });
    } else {
      setState(() {
        _userDocFuture = Future.error('User ID is empty.');
      });
    }
  }

  // Navigate to edit screen and reload data if changes were saved
  Future<void> _navigateToEditProfile(
    BuildContext context,
    Map<String, dynamic> currentUserData,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditProfileScreen(
              userId: widget.userId,
              initialData: currentUserData,
            ),
      ),
    );

    if (result == true && mounted) {
      _loadUserData();
    }
  }

  // Placeholder for Gallery button action
  void _openGallery() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Gallery button tapped!')));
    print('Gallery button tapped for user: ${widget.userId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('User Profile')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userDocFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error fetching user data: ${snapshot.error}');
            return Center(
              child: Text('Error loading profile: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User profile not found.'));
          }

          Map<String, dynamic> userData = snapshot.data!.data()!;
          return _buildProfileView(context, userData);
        },
      ),
    );
  }

  Widget _buildProfileView(
    BuildContext context,
    Map<String, dynamic> userData,
  ) {
    // Provide default values for potentially missing fields
    String name = userData['name'] ?? 'N/A';
    String dob = userData['dob'] ?? 'Not set';
    String email = userData['email'] ?? 'No email';
    String address = userData['address'] ?? 'No address provided';
    // String photoUrl = userData['photoUrl'] ?? ''; // Removed photoUrl

    return RefreshIndicator(
      onRefresh: () async {
        _loadUserData();
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // --- Profile Picture Section Removed ---
          // const SizedBox(height: 20), // Adjust or remove spacing if needed

          // --- Profile Details ---
          _buildProfileDetailRow('Full Name:', name),
          _buildProfileDetailRow('Date of Birth:', dob),
          _buildProfileDetailRow('Email:', email),
          _buildProfileDetailRow('Address:', address, isMultiline: true),

          const SizedBox(height: 30),

          // --- Action Buttons ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                onPressed: _openGallery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                onPressed: () => _navigateToEditProfile(context, userData),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for displaying profile details consistently
  Widget _buildProfileDetailRow(
    String label,
    String value, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
            softWrap: isMultiline,
          ),
          const Divider(),
        ],
      ),
    );
  }
}
