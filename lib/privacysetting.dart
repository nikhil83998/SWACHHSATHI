import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.greenAccent : const Color(0xFF2E7D32);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Privacy Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Manage Permissions
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.security, color: primaryColor),
              title: const Text(
                'Manage Permissions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Handle permissions logic
              },
            ),
          ),

          // Clear Search History
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: primaryColor),
              title: const Text(
                'Clear Search History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showClearHistoryDialog(context);
              },
            ),
          ),

          // Allow Notifications Toggle
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: SwitchListTile(
              secondary: Icon(Icons.notifications_none, color: primaryColor),
              title: const Text(
                'Allow Notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              value: true,
              activeColor: primaryColor,
              onChanged: (value) {
                // Update notification preference
              },
            ),
          ),
        ],
      ),
    );
  }

  // Show Dialog for Clearing Search History
  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Search History'),
          content: const Text('Are you sure you want to clear your search history?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnackbar(context, 'Search history cleared');
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  // Show Snackbar for Confirmation
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
