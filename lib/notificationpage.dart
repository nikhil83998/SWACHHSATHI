import 'package:flutter/material.dart';
import 'package:unknown/utils/app_settings.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    final notifications = [
      {
        'title': 'Pickup Confirmed',
        'message': 'Your on-demand recyclable waste pickup is scheduled for today at 2:00 PM.',
        'time': '10m ago',
        'icon': Icons.local_shipping_outlined,
        'color': Colors.green,
      },
      {
        'title': 'Eco Points Credited',
        'message': 'Congratulations! +50 Eco Points have been credited to your rewards wallet.',
        'time': '2h ago',
        'icon': Icons.stars_rounded,
        'color': Colors.amber,
      },
      {
        'title': 'Community Challenge',
        'message': 'Your neighborhood is only 220kg away from achieving the monthly recycling goal!',
        'time': '1d ago',
        'icon': Icons.groups_rounded,
        'color': Colors.blue,
      },
      {
        'title': 'Daily Waste Tip',
        'message': 'Rinse clean all plastic milk pouches and containers before depositing.',
        'time': '2d ago',
        'icon': Icons.tips_and_updates_outlined,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppSettings.instance.tr('notifications')),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          final Color iconColor = item['color'] as Color;

          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? const Color(0xFF2D3748) : Colors.grey.shade200,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: isDark ? 0.25 : 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: onSurface,
                              ),
                            ),
                            Text(
                              item['time'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['message'] as String,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: onSurface.withValues(alpha: 0.75),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
