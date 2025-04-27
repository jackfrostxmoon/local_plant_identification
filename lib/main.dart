import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_plant_identification/screens/dashboard/dashboard_screen.dart';
import 'package:local_plant_identification/screens/login_and_registration/login.dart';
import 'package:local_plant_identification/screens/login_and_registration/signup.dart';
import 'package:local_plant_identification/screens/login_and_registration/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

//test

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are ready
  await Firebase.initializeApp(
    // Initialize Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
      title: 'Local Plant Identification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      initialRoute:
          FirebaseAuth.instance.currentUser != null ? '/dashboard' : '/welcome',
      routes: {
        '/welcome':
            (context) => const WelcomeScreen(
              title: 'Welcome to Local Plant Identification',
            ),
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
