// screens/login_and_registration/welcome.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/login_and_registration/login.dart';
import 'package:local_plant_identification/screens/login_and_registration/signup.dart';
import 'package:local_plant_identification/widgets/custom_scaffold_background.dart';
import 'package:provider/provider.dart'; // Import Provider for state management.
import 'package:local_plant_identification/main.dart'; // Import main for LocaleProvider (assuming it's defined there).
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations for localization.

// The welcome screen displayed when the app starts, allowing users to log in or sign up.
class WelcomeScreen extends StatelessWidget {
  // The title for the screen, passed in and assumed to be already localized.
  final String title;

  // Constructor for the WelcomeScreen.
  const WelcomeScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Get the AppLocalizations instance for accessing localized strings.
    final l10n = AppLocalizations.of(context)!;
    // Get the LocaleProvider to manage and access the current locale state.
    final localeProvider = Provider.of<LocaleProvider>(context);
    // Get the language code of the current locale.
    final currentLangCode = localeProvider.locale.languageCode;

    return CustomScaffold(
      // Custom background scaffold.
      child: Stack(
        // Use a Stack to position the language selection button.
        children: [
          Center(
            // Center the main content (icon, title, buttons).
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Make the column take minimum vertical space.
              children: [
                // App icon.
                const Icon(Icons.local_florist, size: 100, color: Colors.white),
                const SizedBox(height: 20), // Vertical space.
                // Welcome title.
                Text(
                  title, // Use the title passed from main.dart (already localized).
                  // OR use a specific key if preferred: l10n.welcomeGreeting,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign:
                      TextAlign.center, // Ensure the title centers if long.
                ),
                const SizedBox(height: 40), // Vertical space.
                // "Sign In" button.
                OutlinedButton(
                  onPressed: () {
                    // Navigate to the Login screen.
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 15), // Padding for the button.
                    side:
                        const BorderSide(color: Colors.white), // White border.
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Rounded corners.
                    ),
                  ),
                  child: Text(
                    l10n.welcomeSignInButton, // Localized text for "Sign In".
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20), // Vertical space.
                // "Sign Up" button.
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the Signup screen.
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Signup()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // White background color.
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 15), // Padding for the button.
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Rounded corners.
                    ),
                  ),
                  child: Text(
                    l10n.welcomeSignUpButton, // Localized text for "Sign Up".
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 40), // Vertical space.
              ],
            ),
          ),
          // Language selection button positioned at the top right.
          Positioned(
            top: 10,
            right: 10,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.language,
                  color: Colors.white), // Language icon.
              tooltip: l10n
                  .selectLanguageTooltip, // Localized tooltip for the button.
              onSelected: (String langCode) {
                // Update the locale only if a different language is selected.
                if (langCode != currentLangCode) {
                  // Get the provider without listening in the callback to avoid issues.
                  final provider = Provider.of<LocaleProvider>(
                    context,
                    listen: false,
                  );
                  // Set the new locale using the provider.
                  provider.setLocale(Locale(langCode));
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                // Menu item for English.
                PopupMenuItem<String>(
                  value: 'en',
                  child:
                      Text(l10n.languageEnglish), // Localized text for English.
                ),
                // Menu item for Malay.
                PopupMenuItem<String>(
                  value: 'ms',
                  child: Text(l10n.languageMalay), // Localized text for Malay.
                ),
                // Menu item for Chinese.
                PopupMenuItem<String>(
                  value: 'zh',
                  child:
                      Text(l10n.languageChinese), // Localized text for Chinese.
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
