// screens/login_and_registration/welcome.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/login_and_registration/login.dart';
import 'package:local_plant_identification/screens/login_and_registration/signup.dart';
import 'package:local_plant_identification/widgets/custom_scaffold_background.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:local_plant_identification/main.dart'; // Import main for LocaleProvider
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.title});

  // Title is already passed localized from main.dart, so we use it directly
  final String title;

  @override
  Widget build(BuildContext context) {
    // Get AppLocalizations instance
    final l10n = AppLocalizations.of(context)!;
    // Get LocaleProvider for language menu state
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLangCode = localeProvider.locale.languageCode;

    return CustomScaffold(
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_florist, size: 100, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  // Use the title passed from main.dart (already localized)
                  title,
                  // OR use a specific key if you prefer: l10n.welcomeGreeting,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center, // Ensure title centers if long
                ),
                const SizedBox(height: 40),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 15),
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    l10n.welcomeSignInButton, // Localized
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Signup()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    l10n.welcomeSignUpButton, // Localized
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.language, color: Colors.white),
              tooltip: l10n.selectLanguageTooltip, // Localized tooltip
              onSelected: (String langCode) {
                // Only update if a different language is selected
                if (langCode != currentLangCode) {
                  // Get provider without listening in callback
                  final provider = Provider.of<LocaleProvider>(
                    context,
                    listen: false,
                  );
                  provider.setLocale(Locale(langCode));
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'en',
                  child: Text(l10n.languageEnglish), // Localized
                ),
                PopupMenuItem<String>(
                  value: 'ms',

                  child: Text(l10n.languageMalay), // Localized
                ),
                PopupMenuItem<String>(
                  value: 'zh',
                  child: Text(l10n.languageChinese), // Localized
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
