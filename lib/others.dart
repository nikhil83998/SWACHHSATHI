import 'package:flutter/material.dart';

class OtherOptionsPage extends StatelessWidget {
  const OtherOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Calculate crossAxisCount dynamically for responsiveness
    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("More Options"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          children: [
            _buildOptionItem(
                context, Icons.book, "Library", Colors.brown, _onLibraryTap),
            _buildOptionItem(context, Icons.settings, "Settings", Colors.blue,
                _onSettingsTap),
            _buildOptionItem(
                context, Icons.map, "Maps", Colors.green, _onMapsTap),
            _buildOptionItem(context, Icons.contact_page, "Contacts",
                Colors.purple, _onContactsTap),
            _buildOptionItem(
                context, Icons.camera, "Camera", Colors.orange, _onCameraTap),
            _buildOptionItem(
                context, Icons.gamepad, "Games", Colors.red, _onGamesTap),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2D3748) : Colors.grey.shade200,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: isDark ? 0.25 : 0.15),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handlers for tap events
  void _onLibraryTap() {
    debugPrint("Library clicked");
  }

  void _onSettingsTap() {
    debugPrint("Settings clicked");
  }

  void _onMapsTap() {
    debugPrint("Maps clicked");
  }

  void _onContactsTap() {
    debugPrint("Contacts clicked");
  }

  void _onCameraTap() {
    debugPrint("Camera clicked");
  }

  void _onGamesTap() {
    debugPrint("Games clicked");
  }
}
