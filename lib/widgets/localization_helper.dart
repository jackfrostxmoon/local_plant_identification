// lib/utils/localization_helper.dart
import 'package:flutter/material.dart';

/// Fetches a localized string value from a data map based on the current locale.
///
/// This helper function is designed to work with data structures (like those
/// fetched from Appwrite) where localized fields follow a convention:
/// - Base field name (e.g., 'Name') for the default language (English).
/// - Field name with language suffix (e.g., 'Name_MS', 'Name_CN') for other languages.
///
/// Args:
///   context: The BuildContext used to determine the current locale.
///   data: The map containing the data fields (e.g., a plant data map).
///   baseKey: The base key for the field (e.g., 'Name', 'Description').
///
/// Returns:
///   The localized string value if found, falling back to the base language
///   value, or 'N/A' if neither is found or valid.
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

  // --- Fallback Logic ---

  // 1. Try fetching the locale-specific value first.
  // Check if the key exists, the value is not null, and it's not an empty string.
  if (data.containsKey(localeKey) &&
      data[localeKey] != null &&
      data[localeKey].toString().isNotEmpty) {
    return data[localeKey].toString();
  }

  // 2. If locale-specific value is missing or empty, fallback to the base key (English).
  // Check if the base key exists, the value is not null, and it's not an empty string.
  if (data.containsKey(baseKey) &&
      data[baseKey] != null &&
      data[baseKey].toString().isNotEmpty) {
    // Optionally, log a warning if a specific locale was expected but not found
    // if (langCode != 'en') {
    //   print("Warning: Locale '$langCode' requested for key '$baseKey', but value for '$localeKey' was missing or empty. Falling back to base.");
    // }
    return data[baseKey].toString();
  }

  // 3. If even the base value is missing or empty, return a placeholder.
  // Optionally, log an error here as data seems incomplete.
  // print("Error: Missing value for base key '$baseKey' and locale key '$localeKey'.");
  return 'N/A'; // Or return baseKey, or an empty string '', etc.
}
