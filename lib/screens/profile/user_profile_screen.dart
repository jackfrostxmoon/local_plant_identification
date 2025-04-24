import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:local_plant_identification/screens/profile/account_details_card.dart';
import 'package:local_plant_identification/screens/profile/media_card.dart';
import 'package:local_plant_identification/screens/profile/profile_header.dart';
import 'package:local_plant_identification/widgets/custom_loading_indicator.dart';

// Import your service
import '../../services/firestore_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  // --- Controllers ---
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // --- Editing State Flags ---
  bool _isEditingUsername = false;
  bool _isEditingFullName = false;
  bool _isEditingDob = false;
  bool _isEditingAddress = false;

  // --- Current Values ---
  String _currentUsername = '';
  String _currentFullName = '';
  String _currentDob = '';
  Timestamp? _currentDobTimestamp;
  String _currentAddress = '';
  String? _currentPhotoURL; // Store photo URL

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- Generic Update Function ---
  Future<void> _updateField(
    String fieldKey,
    dynamic newValue,
    dynamic currentLocalValue, // Can be String or Timestamp
    VoidCallback exitEditingMode,
  ) async {
    // Allow empty strings for name/address, but not username
    bool isEmptyString = newValue is String && newValue.trim().isEmpty;
    bool isUsername = fieldKey == 'username';

    // Prevent update if value is unchanged OR if it's an empty username
    if (newValue == currentLocalValue || (isEmptyString && isUsername)) {
      exitEditingMode();
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text('Updating ${fieldKey.toLowerCase()}...')),
    );

    try {
      await _firestoreService.updateUserProfileField(
        user.uid,
        fieldKey,
        newValue,
      );
      setState(() {
        switch (fieldKey) {
          case 'username':
            _currentUsername = newValue as String;
            break;
          case 'fullname':
            _currentFullName = newValue as String;
            break;
          case 'dateOfBirth':
            _currentDobTimestamp = newValue as Timestamp?;
            _currentDob = _formatDate(newValue);
            _dobController.text = _currentDob;
            break;
          case 'address':
            _currentAddress = newValue as String;
            break;
        }
        exitEditingMode();
      });

      if (mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('${_capitalize(fieldKey)} updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to update $fieldKey: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // --- Toggle Edit Functions ---
  void _toggleEditUsername() {
    setState(() {
      _isEditingUsername = !_isEditingUsername;
      if (_isEditingUsername) {
        _usernameController.text =
            _currentUsername == 'N/A' ? '' : _currentUsername;
        _isEditingFullName = false;
        _isEditingDob = false;
        _isEditingAddress = false;
      } else {
        _usernameController.clear();
      }
    });
  }

  void _toggleEditFullName() {
    setState(() {
      _isEditingFullName = !_isEditingFullName;
      if (_isEditingFullName) {
        _fullNameController.text =
            _currentFullName == 'Not Set' ? '' : _currentFullName;
        _isEditingUsername = false;
        _isEditingDob = false;
        _isEditingAddress = false;
      } else {
        _fullNameController.clear();
      }
    });
  }

  void _toggleEditDob() {
    setState(() {
      if (_isEditingDob) {
        _isEditingDob = false;
        return;
      }
      _isEditingDob = true;
      _isEditingUsername = false;
      _isEditingFullName = false;
      _isEditingAddress = false;
      _selectDate(context);
    });
  }

  void _toggleEditAddress() {
    setState(() {
      _isEditingAddress = !_isEditingAddress;
      if (_isEditingAddress) {
        _addressController.text =
            _currentAddress == 'Not Set' ? '' : _currentAddress;
        _isEditingUsername = false;
        _isEditingFullName = false;
        _isEditingDob = false;
      } else {
        _addressController.clear();
      }
    });
  }

  // --- Date Picker ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentDobTimestamp?.toDate() ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _currentDobTimestamp?.toDate()) {
      final newTimestamp = Timestamp.fromDate(picked);
      // Pass _currentDobTimestamp for comparison in _updateField
      await _updateField('dateOfBirth', newTimestamp, _currentDobTimestamp, () {
        setState(() => _isEditingDob = false);
      });
    } else {
      setState(() => _isEditingDob = false);
    }
  }

  // --- Helper Functions ---
  String _formatDate(dynamic dateValue) {
    if (dateValue is Timestamp) {
      try {
        return DateFormat.yMMMd().format(dateValue.toDate());
      } catch (e) {
        return 'Invalid Date';
      }
    }
    return 'Not Set';
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    final spaced = s.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => ' ${match.group(0)}',
    );
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  void _viewGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Gallery Screen...')),
    );
    // Navigator.of(context).pushNamed('/gallery');
  }

  // --- Reusable Widget Builder for Editable Fields ---
  Widget _buildEditableField({
    required String label,
    required String value,
    required IconData icon,
    required bool isEditing,
    required TextEditingController controller,
    required VoidCallback toggleEdit,
    required VoidCallback updateAction,
    TextInputType keyboardType = TextInputType.text,
    bool isMultiline = false,
  }) {
    // (Implementation remains the same as before)
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title:
          isEditing
              ? TextFormField(
                controller: controller,
                autofocus: true,
                keyboardType: keyboardType,
                maxLines: isMultiline ? null : 1,
                decoration: InputDecoration(
                  hintText: 'Enter $label',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onFieldSubmitted: (_) => updateAction(),
              )
              : Text(label),
      subtitle:
          !isEditing
              ? Text(
                value.isEmpty || value == 'Not Set' || value == 'N/A'
                    ? 'Not Set'
                    : value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: isMultiline ? 3 : 1,
                overflow: TextOverflow.ellipsis,
              )
              : null,
      trailing:
          isEditing
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green[600]),
                    tooltip: 'Save $label',
                    onPressed: updateAction,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    tooltip: 'Cancel Edit',
                    onPressed: toggleEdit,
                  ),
                ],
              )
              : IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                tooltip: 'Edit $label',
                onPressed: toggleEdit,
              ),
      isThreeLine: isMultiline && !isEditing && value.length > 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(body: Center(child: Text('Redirecting...')));
    }

    // Update photoURL from user object (can also be stored in Firestore)
    _currentPhotoURL = user.photoURL;

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.getUserStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Handle profile creation if document doesn't exist yet
          if (!snapshot.hasData || !snapshot.data!.exists) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Attempt creation, no need to await here, stream will update
              _firestoreService.createBasicUserProfileIfNeeded(
                user,
                user.email ??
                    user.phoneNumber ??
                    user.uid, // Provide identifier
              );
            });
            return const Center(
              child: Text('Loading profile...'),
            ); // Show loading
          }

          final userData = snapshot.data!.data() ?? {};

          // Update local state only if not currently editing that field
          if (!_isEditingUsername)
            _currentUsername = userData['username'] as String? ?? 'N/A';
          if (!_isEditingFullName)
            _currentFullName = userData['fullname'] as String? ?? 'Not Set';
          if (!_isEditingDob) {
            _currentDobTimestamp = userData['dateOfBirth'] as Timestamp?;
            _currentDob = _formatDate(_currentDobTimestamp);
            _dobController.text = _currentDob;
          }
          if (!_isEditingAddress)
            _currentAddress = userData['address'] as String? ?? 'Not Set';

          final email = user.email ?? userData['email'] as String? ?? 'N/A';

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- Use Extracted Widgets ---
                ProfileHeader(
                  displayName:
                      _currentFullName.isNotEmpty &&
                              _currentFullName != 'Not Set'
                          ? _currentFullName
                          : _currentUsername,
                  email: email,
                  photoURL: _currentPhotoURL, // Pass photoURL
                ),
                const SizedBox(height: 30),

                AccountDetailsCard(
                  buildEditableField: _buildEditableField,
                  // Pass all required props...
                  currentFullName: _currentFullName,
                  isEditingFullName: _isEditingFullName,
                  fullNameController: _fullNameController,
                  toggleEditFullName: _toggleEditFullName,
                  updateFullNameAction:
                      () => _updateField(
                        'fullname',
                        _fullNameController.text.trim(),
                        _currentFullName,
                        _toggleEditFullName,
                      ),
                  currentUsername: _currentUsername,
                  isEditingUsername: _isEditingUsername,
                  usernameController: _usernameController,
                  toggleEditUsername: _toggleEditUsername,
                  updateUsernameAction:
                      () => _updateField(
                        'username',
                        _usernameController.text.trim(),
                        _currentUsername,
                        _toggleEditUsername,
                      ),
                  email: email,
                  currentDob: _currentDob,
                  isEditingDob: _isEditingDob,
                  toggleEditDob: _toggleEditDob,
                  currentAddress: _currentAddress,
                  isEditingAddress: _isEditingAddress,
                  addressController: _addressController,
                  toggleEditAddress: _toggleEditAddress,
                  updateAddressAction:
                      () => _updateField(
                        'address',
                        _addressController.text.trim(),
                        _currentAddress,
                        _toggleEditAddress,
                      ),
                ),
                const SizedBox(height: 30),

                MediaCard(onViewGallery: _viewGallery),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
