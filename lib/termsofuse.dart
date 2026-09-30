import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Use"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Terms of Use",
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
              "Welcome to SwachhSathi (the \"App\"). By accessing or using the App, you agree to be bound by these Terms of Use (\"Terms\"). If you do not agree to these Terms, you may not use the App.\n\n"
              "2. Eligibility\n"
              "To use the App, you must:\n"
              "- Be at least 13 years old.\n"
              "- Have the legal capacity to enter into a binding agreement.\n\n"
              "3. Account Registration\n"
              "To access certain features of the App, you may need to create an account. You agree to:\n"
              "- Provide accurate and complete information during registration.\n"
              "- Keep your login credentials secure.\n"
              "- Notify us immediately if you suspect unauthorized access to your account.\n\n"
              "4. User Responsibilities\n"
              "You agree not to:\n"
              "- Use the App for any illegal or unauthorized purpose.\n"
              "- Misuse the App by engaging in harmful, abusive, or disruptive behavior.\n"
              "- Attempt to reverse engineer, decompile, or hack the App.\n"
              "- Share inappropriate or offensive content through the App.\n\n"
              "5. Intellectual Property\n"
              "All content, logos, designs, and features of the App are owned by SwachhSathi or its licensors. You may not:\n"
              "- Copy, distribute, or modify any part of the App without our permission.\n"
              "- Use our trademarks or branding without prior written consent.\n\n"
              "6. Services Provided\n"
              "The App provides waste management services, including but not limited to:\n"
              "- Scheduling waste pickups.\n"
              "- Locating nearby recycling centers.\n"
              "- Providing educational resources on waste management.\n\n"
              "7. Limitations of Liability\n"
              "To the fullest extent permitted by law, SwachhSathi shall not be liable for:\n"
              "- Any direct, indirect, or consequential damages arising from your use of the App.\n"
              "- Loss of data, profits, or business opportunities.\n"
              "- Any issues caused by third-party services or external factors beyond our control.\n\n"
              "8. Termination\n"
              "We reserve the right to terminate or suspend your access to the App at any time, without notice, for any reason, including but not limited to:\n"
              "- Violation of these Terms.\n"
              "- Engaging in fraudulent or harmful activities.\n\n"
              "9. Changes to Terms\n"
              "We may update these Terms from time to time. If we make significant changes, we will notify you through the App or via email. Your continued use of the App after the changes take effect constitutes your acceptance of the updated Terms.\n\n"
              "10. Governing Law\n"
              "These Terms are governed by and construed in accordance with the laws of India. Any disputes arising from these Terms shall be resolved in the courts of India.\n\n"
              "11. Contact Us\n"
              "If you have any questions or concerns about these Terms, please contact us at:\n"
              "Email: support@swachhsathi.com\n"
              "Address: [Your Company Address]\n"
              "Phone: +91 1234567890",
              style: TextStyle(fontSize: 16),
            // const SizedBox(height: 20),
            // Center(
            //   child: ElevatedButton(
            //     onPressed: () {
            //       Navigator.pop(context); // Go back to the previous screen
            //     },
            //     child: const Text("I Agree"),
            //   ),
            ),
          ],
        ),
      ),
    );
  }
}