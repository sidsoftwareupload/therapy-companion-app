import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  // New method to build the content widget
  Widget buildContent(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Text(
        '''
Last updated: October 23, 2023

Please read these terms and conditions carefully before using Our Service.

Interpretation and Definitions
==============================

Interpretation
--------------

The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.

Definitions
-----------

For the purposes of these Terms and Conditions:

*   "Application" means the software program provided by the Company downloaded by You on any electronic device, named Therapy Companion

*   "Application Store" means the digital distribution service operated and developed by Apple Inc. (Apple App Store) or Google Inc. (Google Play Store) in which the Application has been downloaded.

*   "Company" (referred to as either "the Company", "We", "Us" or "Our" in this Agreement) refers to Organic Studios.

*   "Device" means any device that can access the Service such as a computer, a cellphone or a digital tablet.

*   "Service" refers to the Application.

*   "Terms and Conditions" (also referred as "Terms") mean these Terms and Conditions that form the entire agreement between You and the Company regarding the use of the Service.

*   "You" means the individual accessing or using the Service, or the company, or other legal entity on behalf of which such individual is accessing or using the Service, as applicable.

Acknowledgment
==============

These are the Terms and Conditions governing the use of this Service and the agreement that operates between You and the Company. These Terms and Conditions set out the rights and obligations of all users regarding the use of the Service.

Your access to and use of the Service is conditioned on Your acceptance of and compliance with these Terms and Conditions. These Terms and Conditions apply to all visitors, users and others who access or use the Service.

By accessing or using the Service You agree to be bound by these Terms and Conditions. If You disagree with any part of these Terms and Conditions then You may not access the Service.

You represent that you are over the age of 18. The Company does not permit those under 18 to use the Service.

Your access to and use of the Service is also conditioned on Your acceptance of and compliance with the Privacy Policy of the Company. Our Privacy Policy describes Our policies and procedures on how your data is handled (stored locally on your device) when You use the Application and tells You about Your privacy rights. Please read Our Privacy Policy carefully before using Our Service.

4. Data Storage and User Responsibility
======================================

All data created by You within the Application (including but not limited to mood logs, journal entries, trigger details, and coping strategies) is stored solely on Your local Device. The Company has no access to this data. You are solely responsible for the maintenance, security, and backup of Your data and Your Device. The Company shall not be liable for any loss or corruption of data.

Links to Other Websites
======================

Our Service may contain links to third-party web sites or services that are not owned or controlled by the Company.

The Company has no control over, and assumes no responsibility for, the content, privacy policies, or practices of any third-party web sites or services. You further acknowledge and agree that the Company shall not be responsible or liable, directly or indirectly, for any damage or loss caused or alleged to be caused by or in connection with the use of or reliance on any such content, goods or services available on or through any such web sites or services.

We strongly advise You to read the terms and conditions and privacy policies of any third-party web sites or services that You visit.

Termination
===========

We may terminate or suspend Your access immediately, without prior notice or liability, for any reason whatsoever, including without limitation if You breach these Terms and Conditions.

Upon termination, Your right to use the Service will cease immediately.

Limitation of Liability
=======================

Notwithstanding any damages that You might incur, the entire liability of the Company and any of its suppliers under any provision of this Terms and Your exclusive remedy for all of the foregoing shall be limited to the amount actually paid by You through the Service or 0 USD if You haven't purchased anything through the Service (as the app is intended to be free and data is local).

To the maximum extent permitted by applicable law, in no event shall the Company or its suppliers be liable for any special, incidental, indirect, or consequential damages whatsoever (including, but not limited to, damages for loss of profits, loss of data or other information, for business interruption, for personal injury, loss of privacy arising out of or in any way related to the use of or inability to use the Service, third-party software and/or third-party hardware used with the Service, or otherwise in connection with any provision of this Terms), even if the Company or any supplier has been advised of the possibility of such damages and even if the remedy fails of its essential purpose.

"AS IS" and "AS AVAILABLE" Disclaimer
=====================================

The Service is provided to You "AS IS" and "AS AVAILABLE" and with all faults and defects without warranty of any kind. To the maximum extent permitted under applicable law, the Company, on its own behalf and on behalf of its Affiliates and its and their respective licensors and service providers, expressly disclaims all warranties, whether express, implied, statutory or otherwise, with respect to the Service, including all implied warranties of merchantability, fitness for a particular purpose, title and non-infringement, and warranties that may arise out of course of dealing, course of performance, usage or trade practice.

Without limitation to the foregoing, the Company provides no warranty or undertaking, and makes no representation of any kind that the Service will meet Your requirements, achieve any intended results, be compatible or work with any other software, applications, systems or services, operate without interruption, meet any performance or reliability standards or be error free or that any errors or defects can or will be corrected.

Governing Law
=============

These Terms and Conditions and Your use of the Service will be governed by and construed in accordance with the laws of the United Arab Emirates, without regard to its conflict of law principles. Any disputes arising from or relating to these Terms or the Service shall be subject to the exclusive jurisdiction of the courts of the United Arab Emirates.

Disputes Resolution
===================

If You have any concern or dispute about the Service, You agree to first try to resolve the dispute informally by contacting the Company.

Changes to These Terms and Conditions
=====================================

We reserve the right, at Our sole discretion, to modify or replace these Terms at any time. If a revision is material We will make reasonable efforts to provide at least 30 days' notice prior to any new terms taking effect. What constitutes a material change will be determined at Our sole discretion.

By continuing to access or use Our Service after those revisions become effective, You agree to be bound by the revised terms. If You do not agree to the new terms, in whole or in part, please stop using the Service.

Contact Us
==========

If you have any questions about these Terms and Conditions, You can contact us:

*   By email: organic.studios.reachout@gmail.com
          '''
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: buildContent(context), // Call the new method here
    );
  }
}
