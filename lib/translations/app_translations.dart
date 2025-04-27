import 'package:flutter/material.dart';

class AppTranslations {
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'appName': 'Local Plant Identification',
      'welcome': 'Welcome',
      'login': 'Login',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password?',
      'dashboard': 'Dashboard',
      'search': 'Search',
      'settings': 'Settings',
      'language': 'Language',
      'logout': 'Logout',
      'name': 'Name',
      'description': 'Description',
      'growthHabit': 'Growth Habit',
      'interestingFact': 'Interesting Fact',
      'toxicity': 'Toxicity to Humans and Pets',
    },
    'my': {
      'appName': 'Pengenalan Tumbuhan Tempatan',
      'welcome': 'Selamat Datang',
      'login': 'Log Masuk',
      'signup': 'Daftar',
      'email': 'Emel',
      'password': 'Kata Laluan',
      'confirmPassword': 'Sahkan Kata Laluan',
      'forgotPassword': 'Lupa Kata Laluan?',
      'dashboard': 'Papan Pemuka',
      'search': 'Cari',
      'settings': 'Tetapan',
      'language': 'Bahasa',
      'logout': 'Log Keluar',
      'name': 'Nama',
      'description': 'Penerangan',
      'growthHabit': 'Tabiat Pertumbuhan',
      'interestingFact': 'Fakta Menarik',
      'toxicity': 'Ketoksikan kepada Manusia dan Haiwan',
    },
    'cn': {
      'appName': '本地植物识别',
      'welcome': '欢迎',
      'login': '登录',
      'signup': '注册',
      'email': '电子邮件',
      'password': '密码',
      'confirmPassword': '确认密码',
      'forgotPassword': '忘记密码？',
      'dashboard': '仪表板',
      'search': '搜索',
      'settings': '设置',
      'language': '语言',
      'logout': '登出',
      'name': '名称',
      'description': '描述',
      'growthHabit': '生长习性',
      'interestingFact': '有趣的事实',
      'toxicity': '对人类和宠物的毒性',
    },
  };

  static String translate(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    return _translations[locale]?[key] ?? _translations['en']![key]!;
  }
}
