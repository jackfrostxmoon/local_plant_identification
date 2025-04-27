import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:local_plant_identification/firebase_options.dart';
import 'package:local_plant_identification/screens/dashboard/dashboard_screen.dart';
import 'package:local_plant_identification/screens/login_and_registration/login.dart';
import 'package:local_plant_identification/screens/login_and_registration/signup.dart';
import 'package:local_plant_identification/screens/login_and_registration/welcome.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// --- LocaleProvider to manage the app's current locale ---
class LocaleProvider extends ChangeNotifier {
  // Default to English. Consider loading user preference or device default here.
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners(); // Notify listeners to rebuild widgets with the new locale
  }
}

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
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // Determine the initial route based on user login status
      initialRoute:
          FirebaseAuth.instance.currentUser != null ? '/dashboard' : '/welcome',

      // Define the app's routes
      routes: {
        '/welcome': (context) => WelcomeScreen(
              title: AppLocalizations.of(context)!.welcomeScreenTitle,
            ),
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
