// widgets/logout_button.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // For localized strings

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the localization strings
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      tooltip: l10n.logoutTooltip, // Use localized tooltip
      icon: const Icon(Icons.logout),
      onPressed: () async {
        // Store context before async gap
        final navigator = Navigator.of(context);
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        try {
          await FirebaseAuth.instance.signOut();
          // Check if the widget is still mounted before using context
          // Use the stored navigator
          navigator.pushNamedAndRemoveUntil(
            '/login',
            (Route<dynamic> route) => false, // Remove all previous routes
          );
        } catch (e) {
          print("Error during logout: $e");
          // Use the stored scaffoldMessenger
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}
