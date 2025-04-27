import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import localization delegates
import 'package:local_plant_identification/firebase_options.dart';
import 'package:local_plant_identification/screens/dashboard/dashboard_screen.dart';
import 'package:local_plant_identification/screens/login_and_registration/login.dart';
import 'package:local_plant_identification/screens/login_and_registration/signup.dart';
import 'package:local_plant_identification/screens/login_and_registration/welcome.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import generated localizations

// --- LocaleProvider to manage the app's current locale ---
class LocaleProvider extends ChangeNotifier {
  // Default to English. Consider loading user preference or device default here.
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    // Optional: Check if the locale is supported before setting
    // if (!AppLocalizations.supportedLocales.contains(locale)) return;

    _locale = locale;
    notifyListeners(); // Notify listeners to rebuild widgets with the new locale
  }
}
// --- End LocaleProvider ---

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the app, providing the LocaleProvider to the widget tree
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the LocaleProvider
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      // TODO: Localize the app title using AppLocalizations if needed.
      // This often requires a Builder widget to get the correct context
      // or handling it differently depending on where the title is displayed.
      title: 'Local Plant Identification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA8E6A2)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFA8E6A2),
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        // Add other theme properties if needed
      ),

      // --- Localization Configuration ---
      locale: localeProvider.locale, // Set the app's locale from the provider
      localizationsDelegates: const [
        AppLocalizations.delegate, // Delegate for your app's specific strings
        GlobalMaterialLocalizations.delegate, // Localizes Material widgets
        GlobalWidgetsLocalizations
            .delegate, // Localizes basic text directionality, etc.
        GlobalCupertinoLocalizations
            .delegate, // Localizes Cupertino widgets (iOS style)
      ],
      supportedLocales: AppLocalizations
          .supportedLocales, // Locales generated from .arb files
      // --- End Localization Configuration ---

      // Determine the initial route based on user login status
      initialRoute:
          FirebaseAuth.instance.currentUser != null ? '/dashboard' : '/welcome',

      // Define the app's routes
      routes: {
        '/welcome': (context) => WelcomeScreen(
              // Localize the title passed to the WelcomeScreen
              // Assumes you have a key 'welcomeScreenTitle' in your .arb files
              title: AppLocalizations.of(context)!.welcomeScreenTitle,
            ),
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/dashboard': (context) => const DashboardScreen(),
        // Add other routes as needed
      },
    );
  }
}
