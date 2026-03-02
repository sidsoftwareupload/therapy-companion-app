import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBodyText(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

   Widget _buildListItem(BuildContext context, String boldText, String normalText) {
    final bodyTextStyle = Theme.of(context).textTheme.bodyMedium;
    final boldBodyTextStyle = bodyTextStyle?.copyWith(fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: boldBodyTextStyle), // Bullet point
          Expanded(
            child: RichText(
              text: TextSpan(
                style: bodyTextStyle,
                children: <TextSpan>[
                  TextSpan(text: boldText, style: boldBodyTextStyle),
                  TextSpan(text: normalText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // New method to build the content widget
  Widget buildContent(BuildContext context) {
    final bodyTextStyle = Theme.of(context).textTheme.bodyMedium;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Last updated: October 23, 2023',
            style: bodyTextStyle,
          ),
          const SizedBox(height: 16.0),
          _buildBodyText(context, '''Therapy Companion ("us", "we", or "our") operates the Therapy Companion mobile application (the "Service").'''),
          _buildBodyText(context, '''This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.'''),
          _buildBodyText(context, '''We are committed to protecting your privacy. All data you enter into the Therapy Companion app, such as episode details, triggers, coping strategies, and journal entries, is stored exclusively on your local device. This data is not transmitted to, collected by, or stored by us or any third party.'''),
          
          _buildSectionTitle(context, 'Information Collection and Use'),
          _buildBodyText(context, '''Since all data is stored locally on your device, we do not collect any personally identifiable information from you. The app processes the information you provide solely for its intended functionality on your device.'''),
          
          _buildSectionTitle(context, 'Log Data'),
          _buildBodyText(context, '''We do not collect Log Data. The app operates entirely on your device.'''),

          _buildSectionTitle(context, 'Data Storage and Privacy'),
          _buildListItem(context, 'Local Storage: ', '''All data you input into the Therapy Companion app (including but not limited to your mood logs, journal entries, trigger details, and coping strategies) is stored directly and solely on your local device (e.g., your phone or tablet).'''),
          _buildListItem(context, 'No Transmission: ', '''Your personal data is not transmitted to any external servers, cloud services, or third parties. We do not have access to your data.'''),
          _buildListItem(context, 'User Control: ', '''You have full control over your data. You can add, modify, or delete your data within the app at any time. If you uninstall the app, the data stored by the app will typically be removed from your device as per standard operating system behavior, but this can vary by OS.'''),
          _buildListItem(context, 'Device Security: ', '''You are responsible for maintaining the security of your own device.'''),

          _buildSectionTitle(context, 'How We Use Your Information'),
          _buildBodyText(context, '''The information you enter into the app is used to:'''),
          _buildListItem(context, '', '''Provide you with the app's features, such as tracking mood episodes, identifying triggers, and suggesting coping strategies.'''),
          _buildListItem(context, '', '''Allow you to review your history and progress.'''),
          _buildListItem(context, '', '''Enable you to personalize your experience.'''),
          _buildBodyText(context, '''All processing of this information occurs on your device.'''),

          _buildSectionTitle(context, 'Data Sharing and Disclosure'),
          _buildBodyText(context, '''We do not share any personally identifying information publicly or with third parties because all your data is stored locally on your device and is not accessible to us. We will not sell, trade, or rent your personal information.'''),
          _buildBodyText(context, '''We may only disclose your information if required to by law, which is highly unlikely given the local storage model.'''),

          _buildSectionTitle(context, 'Security of Data'),
          _buildBodyText(context, '''The security of your data relies on the security of your device. We encourage you to use device-level security features such as passcodes, fingerprint ID, or face ID to protect access to your device and, consequently, the data stored within apps like Therapy Companion. While we design the app with privacy in mind, no method of electronic storage is 100% secure if the device itself is compromised.'''),

          _buildSectionTitle(context, 'Service Providers'),
          _buildBodyText(context, '''We do not employ third-party companies or individuals to facilitate our Service ("Service Providers"), provide the Service on our behalf, perform Service-related services, or assist us in analyzing how our Service is used, as all data and operations are local to your device.'''),

          _buildSectionTitle(context, 'Links to Other Sites'),
          _buildBodyText(context, '''Our Service may contain links to other sites that are not operated by us (e.g., links to mental health resources). If you click on a third-party link, you will be directed to that third party's site. We strongly advise you to review the Privacy Policy of every site you visit. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.'''),

          _buildSectionTitle(context, 'Children\'s Privacy'),
          _buildBodyText(context, '''Our Service does not address anyone under the age of 13 ("Children"). As we do not collect personally identifiable information, we do not knowingly collect it from children under 13. If you are a parent or guardian and you are aware that your Children has provided us with Personal Data (which would not be possible through the app itself, but perhaps via email contact), please contact us.'''),

          _buildSectionTitle(context, 'Your Data Rights'),
          _buildBodyText(context, '''Since all data is stored locally on your device, you have direct control over it. You can access, modify, and delete your data at any time through the app\'s interface.'''),

          _buildSectionTitle(context, 'Changes to This Privacy Policy'),
          _buildBodyText(context, '''We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page within the app.'''),
          _buildBodyText(context, '''We will let you know via a prominent notice within the app, prior to the change becoming effective and update the "last updated" date at the top of this Privacy Policy.'''),
          _buildBodyText(context, '''You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.'''),

          _buildSectionTitle(context, 'Contact Us'),
          _buildBodyText(context, '''If you have any questions about this Privacy Policy, please contact us:'''),
          _buildListItem(context, 'By email: ', '''organic.studios.reachout@gmail.com'''),
          
          const SizedBox(height: 16.0),
          Text(
            'This policy is effective as of October 23, 2023.',
            style: bodyTextStyle,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: buildContent(context), // Call the new method here
    );
  }
}
