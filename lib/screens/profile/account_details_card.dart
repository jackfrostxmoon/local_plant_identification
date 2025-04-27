// widgets/account_details_card.dart
import 'package:flutter/material.dart';
// --- Import AppLocalizations ---
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Define a type for the buildEditableField function signature
typedef EditableFieldBuilder = Widget Function({
  required String label, // Label will be passed localized
  required String value,
  required IconData icon,
  required bool isEditing,
  required TextEditingController controller,
  required VoidCallback toggleEdit,
  required VoidCallback updateAction,
  TextInputType keyboardType,
  bool isMultiline,
});

/// Displays the card containing user account details (editable/read-only fields).
class AccountDetailsCard extends StatelessWidget {
  // Need to pass all state and callbacks required by the fields
  final EditableFieldBuilder buildEditableField;
  final String currentFullName;
  final bool isEditingFullName;
  final TextEditingController fullNameController;
  final VoidCallback toggleEditFullName;
  final VoidCallback updateFullNameAction;

  final String currentUsername;
  final bool isEditingUsername;
  final TextEditingController usernameController;
  final VoidCallback toggleEditUsername;
  final VoidCallback updateUsernameAction;

  final String email;

  final String currentDob;
  final bool isEditingDob;
  final VoidCallback toggleEditDob;

  final String currentAddress;
  final bool isEditingAddress;
  final TextEditingController addressController;
  final VoidCallback toggleEditAddress;
  final VoidCallback updateAddressAction;

  const AccountDetailsCard({
    super.key,
    required this.buildEditableField,
    required this.currentFullName,
    required this.isEditingFullName,
    required this.fullNameController,
    required this.toggleEditFullName,
    required this.updateFullNameAction,
    required this.currentUsername,
    required this.isEditingUsername,
    required this.usernameController,
    required this.toggleEditUsername,
    required this.updateUsernameAction,
    required this.email,
    required this.currentDob,
    required this.isEditingDob,
    required this.toggleEditDob,
    required this.currentAddress,
    required this.isEditingAddress,
    required this.addressController,
    required this.toggleEditAddress,
    required this.updateAddressAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme for convenience
    // --- Get AppLocalizations instance ---
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Localized Title ---
        Text(l10n.accountDetailsTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias, // Improves rendering with dividers
          child: Column(
            children: [
              // --- Full Name (Editable) ---
              buildEditableField(
                label: l10n.profileFullNameLabel, // Localized label
                value: currentFullName,
                icon: Icons.badge_outlined,
                isEditing: isEditingFullName,
                controller: fullNameController,
                toggleEdit: toggleEditFullName,
                updateAction: updateFullNameAction,
                keyboardType: TextInputType.name,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),

              // --- Username (Editable) ---
              buildEditableField(
                label: l10n.profileUsernameLabel, // Localized label
                value: currentUsername,
                icon: Icons.account_circle_outlined,
                isEditing: isEditingUsername,
                controller: usernameController,
                toggleEdit: toggleEditUsername,
                updateAction: updateUsernameAction,
                keyboardType: TextInputType.text,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),

              // --- Email (Read-Only) ---
              ListTile(
                leading: Icon(
                  Icons.email_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(l10n.profileEmailLabel), // Localized label
                subtitle: Text(
                  email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                // No edit action for email
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),

              // --- Date of Birth (Editable via Picker) ---
              ListTile(
                leading: Icon(
                  Icons.cake_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(l10n.profileDobLabel), // Localized label
                subtitle: Text(
                  currentDob, // Display formatted date
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    isEditingDob ? Icons.close : Icons.edit_outlined,
                    color: isEditingDob
                        ? theme.colorScheme.error
                        : theme.colorScheme.secondary,
                  ),
                  // --- Localized Tooltips ---
                  tooltip:
                      isEditingDob ? l10n.tooltipCancel : l10n.tooltipEditDob,
                  onPressed: toggleEditDob,
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),

              // --- Address (Editable) ---
              buildEditableField(
                label: l10n.profileAddressLabel, // Localized label
                value: currentAddress,
                icon: Icons.location_on_outlined,
                isEditing: isEditingAddress,
                controller: addressController,
                toggleEdit: toggleEditAddress,
                updateAction: updateAddressAction,
                keyboardType: TextInputType.streetAddress,
                isMultiline: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
