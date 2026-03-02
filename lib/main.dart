import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:therapy_companion/screens/home_screen.dart';
import 'package:therapy_companion/services/database_service.dart';
import 'package:therapy_companion/screens/agreement_screen.dart'; // Added import for AgreementScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.init();
  runApp(const TherapyCompanionApp());
}

class TherapyCompanionApp extends StatelessWidget {
  const TherapyCompanionApp({super.key});

  Future<bool> _checkAgreementAccepted() async { // Renamed method and updated key
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('agreement_accepted') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Therapy Companion',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32), // Forest Green
        scaffoldBackgroundColor: const Color(0xFFFBFFE4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          secondary: const Color(0xFF81C784), // Pastel Green
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFBFFE4),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: _checkAgreementAccepted(), // Using the updated method
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Centered loading indicator
          } else {
            if (snapshot.hasData && snapshot.data == true) {
              return const HomeScreen();
            } else {
              // Navigate to AgreementScreen if agreement is not accepted
              return const AgreementScreen();
            }
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
