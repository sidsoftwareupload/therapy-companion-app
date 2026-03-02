import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:therapy_companion/screens/home_screen.dart'; // Assuming you have a HomeScreen
import 'package:therapy_companion/screens/privacy_policy_screen.dart';
import 'package:therapy_companion/screens/terms_of_service_screen.dart';

class AgreementScreen extends StatefulWidget {
  const AgreementScreen({super.key});

  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  bool _agreed = false;

  Future<void> _setAgreed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('agreement_accepted', true); // Changed key to 'agreement_accepted'
  }

  void _onContinue() {
    if (_agreed) {
      _setAgreed().then((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()), // Replace with your main screen
        );
      });
    } else {
      // Show a snackbar or alert dialog if not agreed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must accept the terms and privacy policy to continue.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Agreement'),
        automaticallyImplyLeading: false, // Prevents a back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1.0),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                padding: const EdgeInsets.all(8.0), // Padding inside the border
                child: Scrollbar(
                  thumbVisibility: true, // Always show scrollbar
                  child: PrivacyPolicyScreen().buildContent(context),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Terms of Service',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1.0),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                padding: const EdgeInsets.all(8.0), // Padding inside the border
                child: Scrollbar(
                  thumbVisibility: true, // Always show scrollbar
                  child: TermsOfServiceScreen().buildContent(context),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (bool? value) {
                    setState(() {
                      _agreed = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text('I have read and agree to the Privacy Policy and Terms of Service.'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
