// screens/profile/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:local_plant_identification/screens/profile/account_details_card.dart';
import 'package:local_plant_identification/screens/profile/media_card.dart';
import 'package:local_plant_identification/screens/profile/profile_header.dart';
import 'package:local_plant_identification/widgets/custom_loading_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

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
  String? _currentPhotoURL;

  // --- Localized Default Value ---
  // Helper to get the localized "Not Set" string easily (Key exists in template)
  String _notSet(BuildContext context) =>
      AppLocalizations.of(context)!.profileNotSet;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- Get Update Messages (Hardcoded English - Keys missing) ---
  String _getUpdatingMessage(String fieldKey) {
    return 'Updating ${fieldKey.toLowerCase()}...';
  }

  String _getUpdateSuccessMessage(String fieldKey) {
    // Basic capitalization for display
    String capitalizedField = fieldKey[0].toUpperCase() + fieldKey.substring(1);
    return '$capitalizedField updated successfully!';
  }

  String _getUpdateFailedMessage(String fieldKey, String error) {
    return 'Failed to update $fieldKey: $error';
  }
  // --- End Hardcoded Messages ---

  // --- Generic Update Function (Uses Hardcoded Messages) ---
  Future<void> _updateField(
    String fieldKey,
    dynamic newValue,
    dynamic currentLocalValue,
    VoidCallback exitEditingMode,
  ) async {
    if (!mounted) return;
    // final l10n = AppLocalizations.of(context)!; // Not needed for hardcoded messages
    final messenger = ScaffoldMessenger.of(context);

    bool isEmptyString = newValue is String && newValue.trim().isEmpty;
    bool isUsername = fieldKey == 'username';

    if (newValue == currentLocalValue || (isEmptyString && isUsername)) {
      exitEditingMode();
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(_getUpdatingMessage(fieldKey))), // Hardcoded
    );

    try {
      await _firestoreService.updateUserProfileField(
        user.uid,
        fieldKey,
        newValue,
      );

      if (!mounted) return;
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
            _currentDob = _formatDate(context, newValue); // Pass context
            _dobController.text = _currentDob;
            break;
          case 'address':
            _currentAddress = newValue as String;
            break;
        }
        exitEditingMode();
      });

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(_getUpdateSuccessMessage(fieldKey)), // Hardcoded
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(_getUpdateFailedMessage(
            fieldKey,
            e.toString(),
          )), // Hardcoded
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // --- Toggle Edit Functions ---
  void _toggleEditUsername() {
    setState(() {
      _isEditingUsername = !_isEditingUsername;
      if (_isEditingUsername) {
        _usernameController.text = _currentUsername == 'N/A'
            ? ''
            : _currentUsername; // N/A isn't localized usually
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
        // Use helper for localized "Not Set" (Key exists)
        _fullNameController.text =
            _currentFullName == _notSet(context) ? '' : _currentFullName;
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
        // Use helper for localized "Not Set" (Key exists)
        _addressController.text =
            _currentAddress == _notSet(context) ? '' : _currentAddress;
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
    final currentContext = context;
    final currentDobTimestamp = _currentDobTimestamp;

    final DateTime? picked = await showDatePicker(
      context: currentContext,
      initialDate: currentDobTimestamp?.toDate() ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: Localizations.localeOf(currentContext),
    );

    if (!mounted) return;

    if (picked != null && picked != currentDobTimestamp?.toDate()) {
      final newTimestamp = Timestamp.fromDate(picked);
      await _updateField('dateOfBirth', newTimestamp, currentDobTimestamp, () {
        if (mounted) setState(() => _isEditingDob = false);
      });
    } else {
      setState(() => _isEditingDob = false);
    }
  }

  // --- Helper Functions ---
  String _formatDate(BuildContext context, dynamic dateValue) {
// Still needed for other keys
    if (dateValue is Timestamp) {
      try {
        final currentLocale = Localizations.localeOf(context);
        return DateFormat.yMMMd(currentLocale.languageCode)
            .format(dateValue.toDate());
      } catch (e) {
        return 'Invalid Date';
      }
    }
    return _notSet(context);
  }

  Widget _buildEditableField({
    required String label, // Expect localized label from caller
    required String value,
    required IconData icon,
    required bool isEditing,
    required TextEditingController controller,
    required VoidCallback toggleEdit,
    required VoidCallback updateAction,
    TextInputType keyboardType = TextInputType.text,
    bool isMultiline = false,
    // Pass specific keys for hints and tooltips (These keys exist in template)
    required String editHintKey,
    required String saveTooltipKey,
    required String editTooltipKey,
  }) {
    if (!mounted) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Helper to get text based on key (Keys exist in template)
    String getText(String key) {
      final Map<String, String Function()> keyMap = {
        'profileEditHintFullName': () => l10n.profileEditHintFullName,
        'profileEditHintUsername': () => l10n.profileEditHintUsername,
        'profileEditHintAddress': () => l10n.profileEditHintAddress,
        'profileSaveTooltipFullName': () => l10n.profileSaveTooltipFullName,
        'profileSaveTooltipUsername': () => l10n.profileSaveTooltipUsername,
        'profileSaveTooltipAddress': () => l10n.profileSaveTooltipAddress,
        'profileEditTooltipFullName': () => l10n.profileEditTooltipFullName,
        'profileEditTooltipUsername': () => l10n.profileEditTooltipUsername,
        'profileEditTooltipAddress': () => l10n.profileEditTooltipAddress,
      };
      return keyMap[key]?.call() ?? key;
    }

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: isEditing
          ? TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: keyboardType,
              maxLines: isMultiline ? null : 1,
              decoration: InputDecoration(
                hintText: getText(editHintKey), // Localized hint
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onFieldSubmitted: (_) => updateAction(),
            )
          : Text(label), // Display the localized label passed in
      subtitle: !isEditing
          ? Text(
              value.isEmpty || value == _notSet(context)
                  ? _notSet(context) // Use helper for localized "Not Set"
                  : value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: isMultiline ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: isEditing
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green[600]),
                  tooltip: getText(saveTooltipKey), // Localized tooltip
                  onPressed: updateAction,
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.error),
                  tooltip: l10n
                      .profileCancelEditTooltip, // Localized tooltip (Key exists)
                  onPressed: toggleEdit,
                ),
              ],
            )
          : IconButton(
              icon:
                  Icon(Icons.edit_outlined, color: theme.colorScheme.secondary),
              tooltip: getText(editTooltipKey), // Localized tooltip
              onPressed: toggleEdit,
            ),
      isThreeLine: isMultiline &&
          !isEditing &&
          value.isNotEmpty &&
          value != _notSet(context) &&
          value.length > 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Needed for existing keys
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      });
      // --- Hardcoded English (key missing) ---
      return const Scaffold(
        body: Center(child: Text('Redirecting...')),
      );
    }

    _currentPhotoURL = user.photoURL;

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.getUserStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _firestoreService.createBasicUserProfileIfNeeded(
                  user,
                  user.email ?? user.phoneNumber ?? user.uid,
                );
              }
            });
            return const Center(child: Text('Loading profile...'));
          }

          final userData = snapshot.data!.data() ?? {};

          final String localizedNotSet = _notSet(context);
          if (!_isEditingUsername) {
            _currentUsername = userData['username'] as String? ?? 'N/A';
          }
          if (!_isEditingFullName) {
            _currentFullName =
                userData['fullname'] as String? ?? localizedNotSet;
          }
          if (!_isEditingDob) {
            _currentDobTimestamp = userData['dateOfBirth'] as Timestamp?;
            _currentDob = _formatDate(context, _currentDobTimestamp);
            _dobController.text = _currentDob;
          }
          if (!_isEditingAddress) {
            _currentAddress = userData['address'] as String? ?? localizedNotSet;
          }

          final email = user.email ?? userData['email'] as String? ?? 'N/A';

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ProfileHeader(
                  displayName: _currentFullName.isNotEmpty &&
                          _currentFullName != localizedNotSet
                      ? _currentFullName
                      : _currentUsername,
                  email: email,
                  photoURL: _currentPhotoURL,
                ),
                const SizedBox(height: 30),

                AccountDetailsCard(
                  // Pass the _buildEditableField method reference
                  buildEditableField: (
                      { // Destructure args
                      required String label,
                      required String value,
                      required IconData icon,
                      required bool isEditing,
                      required TextEditingController controller,
                      required VoidCallback toggleEdit,
                      required VoidCallback updateAction,
                      TextInputType keyboardType = TextInputType.text,
                      bool isMultiline = false}) {
                    // Determine specific keys based on the localized label
                    // Use l10n from the outer build scope
                    String editHintKey = '';
                    String saveTooltipKey = '';
                    String editTooltipKey = '';
                    if (label == l10n.profileFullNameLabel) {
                      // Key exists
                      editHintKey = 'profileEditHintFullName';
                      saveTooltipKey = 'profileSaveTooltipFullName';
                      editTooltipKey = 'profileEditTooltipFullName';
                    } else if (label == l10n.profileUsernameLabel) {
                      // Key exists
                      editHintKey = 'profileEditHintUsername';
                      saveTooltipKey = 'profileSaveTooltipUsername';
                      editTooltipKey = 'profileEditTooltipUsername';
                    } else if (label == l10n.profileAddressLabel) {
                      // Key exists
                      editHintKey = 'profileEditHintAddress';
                      saveTooltipKey = 'profileSaveTooltipAddress';
                      editTooltipKey = 'profileEditTooltipAddress';
                    }
                    // Call the actual builder function from the state class
                    return _buildEditableField(
                      label: label,
                      value: value,
                      icon: icon,
                      isEditing: isEditing,
                      controller: controller,
                      toggleEdit: toggleEdit,
                      updateAction: updateAction,
                      keyboardType: keyboardType,
                      isMultiline: isMultiline,
                      editHintKey: editHintKey,
                      saveTooltipKey: saveTooltipKey,
                      editTooltipKey: editTooltipKey,
                    );
                  },
                  // Pass other props...
                  currentFullName: _currentFullName,
                  isEditingFullName: _isEditingFullName,
                  fullNameController: _fullNameController,
                  toggleEditFullName: _toggleEditFullName,
                  updateFullNameAction: () => _updateField(
                    'fullname',
                    _fullNameController.text.trim(),
                    _currentFullName,
                    _toggleEditFullName,
                  ),
                  currentUsername: _currentUsername,
                  isEditingUsername: _isEditingUsername,
                  usernameController: _usernameController,
                  toggleEditUsername: _toggleEditUsername,
                  updateUsernameAction: () => _updateField(
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
                  updateAddressAction: () => _updateField(
                    'address',
                    _addressController.text.trim(),
                    _currentAddress,
                    _toggleEditAddress,
                  ),
                ),
                const SizedBox(height: 30),

                const MediaCard(), // Assumes MediaCard uses keys from template
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
