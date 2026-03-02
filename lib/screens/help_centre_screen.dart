import 'package:flutter/material.dart';

class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Centre'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const <Widget>[
          Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ListTile(
            title: Text('Where is my data stored?'),
            subtitle: Text('All the data you enter into Therapy Companion is stored securely and privately on your local device. We do not collect or transmit your personal data to any external servers.'),
          ),
          ExpansionTile(
            title: Text('How do I record a new episode?'),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                    'To record a new episode, navigate to the Summary screen and tap the "Record Episode" button (or similar, based on your UI flow). Fill in the details about the episode and save.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How do I add or manage triggers?'),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                    'You can add triggers when you are recording a new episode. You can view and manage your list of common triggers in the "Triggers" section, usually accessible from the main navigation.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Where can I see my episode history?'),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                    'Your episode history is available on the "History" screen, accessible from the bottom navigation bar.'),
              ),
            ],
          ),
          // Add more FAQs as needed
          SizedBox(height: 24),
          Text(
            'Contact Support',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'If you need further assistance or have questions not covered here, please contact us:',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'organic.studios.reachout@gmail.com',
            style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
          ),
           SizedBox(height: 24),
          Text(
            'Help Centre Last Updated: October 23, 2023',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
