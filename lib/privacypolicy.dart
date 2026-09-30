import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Last Updated: [Date]",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            const Text(
              "1. Introduction\n"
              "Welcome to SwachhSathi (the \"App\"). This Privacy Policy explains how we collect, use, store, and protect your personal information when you use our App. By using the App, you agree to the practices described in this Privacy Policy.\n\n"
              "2. Information We Collect\n"
              "We collect the following types of information:\n"
              "- Name\n"
              "- Email address\n"
              "- Phone number\n"
              "- Address (for waste pickup services)\n"
              "- Location data\n"
              "- Device information\n"
              "- Usage data\n\n"
              "3. How We Use Your Information\n"
              "We use your information for the following purposes:\n"
              "- To provide and improve our services.\n"
              "- To communicate with you.\n"
              "- To analyze App usage and improve user experience.\n"
              "- To comply with legal obligations.\n\n"
              "4. Data Sharing\n"
              "We may share your information with:\n"
              "- Service Providers (e.g., Firebase, Google Maps).\n"
              "- Legal authorities if required by law.\n\n"
              "5. Data Storage and Security\n"
              "Your data is stored securely using encryption and other industry-standard measures.\n\n"
              "6. Your Rights\n"
              "You have the right to access, update, or delete your personal information. Contact us at support@swachhsathi.com to exercise these rights.\n\n"
              "7. Cookies and Tracking\n"
              "We may use cookies or similar technologies to collect usage data and improve your experience.\n\n"
              "8. Third-Party Services\n"
              "The App uses third-party services like Firebase and Google Maps. Their privacy policies can be found here:\n"
              "- [Firebase Privacy Policy](https://firebase.google.com/support/privacy)\n"
              "- [Google Maps Privacy Policy](https://policies.google.com/privacy)\n\n"
              "9. Children’s Privacy\n"
              "The App is not intended for children under 13. We do not knowingly collect personal information from children.\n\n"
              "10. Changes to This Privacy Policy\n"
              "We may update this Privacy Policy from time to time. You will be notified of any changes.\n\n"
              "11. Contact Us\n"
              "If you have any questions or concerns about this Privacy Policy, please contact us at:\n"
              "Email: support@swachhsathi.com\n"
              "Address: [Your Company Address]\n"
              "Phone: +91 1234567890",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous screen
                },
                child: const Text("I Agree"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}