import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Define a type alias for the function signature used to build editable fields.
typedef EditableFieldBuilder = Widget Function({
  required String label, // The localized label for the field.
  required String value, // The current value of the field.
  required IconData icon, // The icon to display next to the field.
  required bool
      isEditing, // Flag indicating if the field is currently in edit mode.
  required TextEditingController
      controller, // Controller for the text field when editing.
  required VoidCallback toggleEdit, // Callback to toggle the edit mode.
  required VoidCallback
      updateAction, // Callback to save changes when editing is done.
  TextInputType keyboardType, // The type of keyboard to use for the text field.
  bool
      isMultiline, // Flag indicating if the text field should support multiple lines.
});

/// Displays the card containing user account details.
/// It includes fields for full name, username, email, date of birth, and address.
/// Some fields are editable, utilizing a provided builder function.
class AccountDetailsCard extends StatelessWidget {
  // All the necessary state and callbacks for each editable field are passed in.
  final EditableFieldBuilder
      buildEditableField; // Builder function for editable fields.

  // Full Name field properties and callbacks.
  final String currentFullName;
  final bool isEditingFullName;
  final TextEditingController fullNameController;
  final VoidCallback toggleEditFullName;
  final VoidCallback updateFullNameAction;

  // Username field properties and callbacks.
  final String currentUsername;
  final bool isEditingUsername;
  final TextEditingController usernameController;
  final VoidCallback toggleEditUsername;
  final VoidCallback updateUsernameAction;

  // Email field (read-only).
  final String email;

  // Date of Birth field (editable via picker, hence different callbacks).
  final String currentDob;
  final bool isEditingDob;
  final VoidCallback toggleEditDob; // Toggles the date picker.

  // Address field properties and callbacks.
  final String currentAddress;
  final bool isEditingAddress;
  final TextEditingController addressController;
  final VoidCallback toggleEditAddress;
  final VoidCallback updateAddressAction;

  // Constructor for the AccountDetailsCard.
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
    final theme = Theme.of(context); // Get the current theme for styling.
    // Get the AppLocalizations instance for accessing localized strings.
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align children to the start (left).
      children: [
        // Localized title for the account details section.
        Text(l10n.accountDetailsTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8), // Space below the title.
        Card(
          elevation: 2, // Add a slight shadow to the card.
          clipBehavior: Clip
              .antiAlias, // Ensures content is clipped correctly, especially with dividers.
          child: Column(
            children: [
              // Full Name field, built using the provided buildEditableField function.
              buildEditableField(
                label:
                    l10n.profileFullNameLabel, // Localized label for Full Name.
                value: currentFullName, // Current value of the Full Name.
                icon: Icons.badge_outlined, // Icon for Full Name.
                isEditing: isEditingFullName, // Editing state for Full Name.
                controller:
                    fullNameController, // Text controller for Full Name.
                toggleEdit:
                    toggleEditFullName, // Toggle edit callback for Full Name.
                updateAction:
                    updateFullNameAction, // Update action callback for Full Name.
                keyboardType:
                    TextInputType.name, // Keyboard type suitable for names.
              ),
              const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16), // Divider between fields.

              // Username field, built using the provided buildEditableField function.
              buildEditableField(
                label:
                    l10n.profileUsernameLabel, // Localized label for Username.
                value: currentUsername, // Current value of the Username.
                icon: Icons.account_circle_outlined, // Icon for Username.
                isEditing: isEditingUsername, // Editing state for Username.
                controller: usernameController, // Text controller for Username.
                toggleEdit:
                    toggleEditUsername, // Toggle edit callback for Username.
                updateAction:
                    updateUsernameAction, // Update action callback for Username.
                keyboardType: TextInputType.text, // Standard text keyboard.
              ),
              const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16), // Divider between fields.

              // Email field (Read-Only). Displayed using a standard ListTile.
              ListTile(
                leading: Icon(
                  Icons.email_outlined, // Icon for Email.
                  color: theme.colorScheme.primary, // Icon color from theme.
                ),
                title:
                    Text(l10n.profileEmailLabel), // Localized label for Email.
                subtitle: Text(
                  email, // The user's email address.
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme
                        .colorScheme.onSurfaceVariant, // Subtitle text style.
                  ),
                ),
                // No trailing widget or action as it's read-only.
              ),
              const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16), // Divider between fields.

              // Date of Birth field (Editable via Picker). Displayed using a standard ListTile with a trailing IconButton.
              ListTile(
                leading: Icon(
                  Icons.cake_outlined, // Icon for Date of Birth.
                  color: theme.colorScheme.primary, // Icon color from theme.
                ),
                title: Text(
                    l10n.profileDobLabel), // Localized label for Date of Birth.
                subtitle: Text(
                  currentDob, // Display the formatted date of birth.
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme
                        .colorScheme.onSurfaceVariant, // Subtitle text style.
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    // Change icon based on editing state.
                    isEditingDob ? Icons.close : Icons.edit_outlined,
                    // Change icon color based on editing state.
                    color: isEditingDob
                        ? theme.colorScheme.error
                        : theme.colorScheme.secondary,
                  ),
                  // Localized tooltips for the edit/cancel action.
                  tooltip:
                      isEditingDob ? l10n.tooltipCancel : l10n.tooltipEditDob,
                  onPressed:
                      toggleEditDob, // Execute the toggleEditDob callback.
                ),
              ),
              const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16), // Divider between fields.

              // Address field, built using the provided buildEditableField function.
              buildEditableField(
                label: l10n.profileAddressLabel, // Localized label for Address.
                value: currentAddress, // Current value of the Address.
                icon: Icons.location_on_outlined, // Icon for Address.
                isEditing: isEditingAddress, // Editing state for Address.
                controller: addressController, // Text controller for Address.
                toggleEdit:
                    toggleEditAddress, // Toggle edit callback for Address.
                updateAction:
                    updateAddressAction, // Update action callback for Address.
                keyboardType: TextInputType
                    .streetAddress, // Keyboard type suitable for addresses.
                isMultiline:
                    true, // Allow multiple lines for the address field.
              ),
            ],
          ),
        ),
      ],
    );
  }
}
