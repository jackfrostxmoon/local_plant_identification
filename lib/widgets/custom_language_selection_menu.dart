// widgets/language_selection_menu.dart
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
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLangCode = localeProvider.locale.languageCode;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      // Use localized tooltip
      tooltip: l10n.selectLanguageTooltip, // Use the key from .arb file
      onSelected: (String langCode) {
        // Only update if a different language is selected
        if (langCode != currentLangCode) {
          print('Language selected: $langCode');
          // Get the provider (listen: false because we're in a callback)
          final provider = Provider.of<LocaleProvider>(context, listen: false);
          // Update the locale
          provider.setLocale(Locale(langCode));
        }
      },
      // Use CheckedPopupMenuItem to indicate the current selection
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        CheckedPopupMenuItem<String>(
          value: 'en',
          // Check if this item's value matches the current language code
          checked: currentLangCode == 'en',
          child: Text(l10n.languageEnglish), // Localized text
        ),
        CheckedPopupMenuItem<String>(
          value: 'ms',
          checked: currentLangCode == 'ms',
          child: Text(l10n.languageMalay), // Localized text
        ),
        CheckedPopupMenuItem<String>(
          value: 'zh',
          checked: currentLangCode == 'zh',
          child: Text(l10n.languageChinese), // Localized text
        ),
      ],
    );
  }
}
