// lib/utils/localization_helper.dart
import 'package:flutter/material.dart';

/// Fetches a localized string value from a data map based on the current locale.
String getLocalizedValue(
  BuildContext context,
  Map<String, dynamic> data,
  String baseKey, {
  String fallbackValue = 'N/A',
}) {
  final locale = Localizations.localeOf(context);
  final langCode = locale.languageCode;

  String localeKey;
  switch (langCode) {
    case 'ms':
      localeKey = '${baseKey}_MS';
      break;
    case 'zh':
      // --- CORRECTION: Use _CN as per your Appwrite attributes ---
      localeKey = '${baseKey}_ZH';
      break;
    default:
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

  return fallbackValue;
}

/// Fetches a localized list of strings from a data map based on the current locale.
List<String> getLocalizedList(
  BuildContext context,
  Map<String, dynamic> data,
  String baseKey, {
  List<String> fallbackValue = const [],
}) {
  final locale = Localizations.localeOf(context);
  final langCode = locale.languageCode;

  String localeKey;
  switch (langCode) {
    case 'ms':
      localeKey = '${baseKey}_MS';
      break;
    case 'zh':
      // --- CORRECTION: Use _CN as per your Appwrite attributes ---
      localeKey = '${baseKey}_ZH';
      break;
    default:
      localeKey = baseKey;
      break;
  }

  List<String> _safelyCastList(dynamic listData) {
    if (listData is List) {
      try {
        return List<String>.from(listData.map((item) => item.toString()));
      } catch (e) {
        print(
            "Warning: Could not cast list elements for key '$localeKey' or '$baseKey'. Error: $e");
        return [];
      }
    }
    return [];
  }

  if (data.containsKey(localeKey) && data[localeKey] is List) {
    List<String> localizedList = _safelyCastList(data[localeKey]);
    if (localizedList.isNotEmpty) {
      return localizedList;
    }
  }

  if (data.containsKey(baseKey) && data[baseKey] is List) {
    List<String> baseList = _safelyCastList(data[baseKey]);
    if (baseList.isNotEmpty) {
      return baseList;
    }
  }

  return fallbackValue;
}
