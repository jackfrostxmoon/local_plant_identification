// lib/utils/localization_helper.dart
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
        PopupMenuItem<String>(
          value: 'en',
          // Check if this item's value matches the current language code
          child: Text(l10n.languageEnglish), // Localized text
        ),
        PopupMenuItem<String>(
          value: 'ms',
          child: Text(l10n.languageMalay), // Localized text
        ),
        PopupMenuItem<String>(
          value: 'zh',
          child: Text(l10n.languageChinese), // Localized text
        ),
      ],
    );
  }
}

String getLocalizedValue(
  BuildContext context,
  Map<String, dynamic> data,
  String baseKey,
) {
  // Get the current locale from the context
  final locale = Localizations.localeOf(context);
  // Get the language code (e.g., 'en', 'ms', 'zh')
  final langCode = locale.languageCode;

  String localeKey;

  // Determine the locale-specific key based on the language code
  switch (langCode) {
    case 'ms': // Malay
      localeKey = '${baseKey}_MS'; // Use the _MS suffix for Malay
      break;
    case 'zh': // Chinese
      localeKey = '${baseKey}_ZH'; // Use the _CN suffix for Chinese
      break;
    default: // Default to English (or if langCode is 'en')
      localeKey = baseKey;
      break;
  }

  if (data.containsKey(localeKey) &&
      data[localeKey] != null &&
      data[localeKey].toString().isNotEmpty) {
    return data[localeKey].toString();
  }

  if (data.containsKey(baseKey) &&
      data[baseKey] != null &&
      data[baseKey].toString().isNotEmpty) {
    return data[baseKey].toString();
  }

  return 'N/A';
}
