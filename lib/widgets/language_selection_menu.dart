// lib/widgets/language_selection_menu.dart
import 'package:flutter/material.dart';
import 'package:local_plant_identification/main.dart'; // Assuming LocaleProvider is in main.dart
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // For localized strings

class LanguageSelectionMenu extends StatelessWidget {
  const LanguageSelectionMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the localization strings
    final l10n = AppLocalizations.of(context)!;
    // Get the LocaleProvider to know the current locale
    // listen: true ensures the checkmark updates if locale changes elsewhere
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLangCode = localeProvider.locale.languageCode;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      // Use localized tooltip (ensure 'selectLanguageTooltip' key exists in your .arb files)
      tooltip: l10n.selectLanguageTooltip,
      onSelected: (String langCode) {
        // Only update if a different language is selected
        if (langCode != currentLangCode) {
          print('Language selected: $langCode');
          // Get the provider (listen: false because we're in a callback, not rebuilding based on this action here)
          final provider = Provider.of<LocaleProvider>(context, listen: false);
          // Update the application's locale
          provider.setLocale(Locale(langCode));
        }
      },
      // Use CheckedPopupMenuItem to visually indicate the current selection
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'en',
          // Show checkmark if English is the current language

          child: Text(l10n.languageEnglish), // Localized text
        ),
        PopupMenuItem<String>(
          value: 'ms',
          // Show checkmark if Malay is the current language

          child: Text(l10n.languageMalay), // Localized text
        ),
        PopupMenuItem<String>(
          value: 'zh',
          // Show checkmark if Chinese is the current language

          child: Text(l10n.languageChinese), // Localized text
        ),
      ],
      // Optional: Customize shape if needed
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(10.0),
      // ),
    );
  }
}
