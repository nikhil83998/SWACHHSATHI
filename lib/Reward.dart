import 'package:flutter/material.dart';
import 'package:unknown/utils/app_settings.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int userPoints = 350; // Example: fetch from user profile

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppSettings.instance.tr('eco_rewards')),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppSettings.instance.tr('my_rewards')),
            Tab(text: AppSettings.instance.tr('redeem')),
            Tab(text: AppSettings.instance.tr('history')),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: isDark ? Colors.greenAccent : Colors.white,
          indicatorWeight: 3,
        ),
      ),
      body: Column(
        children: [
          // Points summary banner
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B2E1C) : Colors.green.shade50,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.green.shade200,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppSettings.instance.tr('your_recycling_points'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.greenAccent : Colors.green.shade800,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.eco,
                          color: isDark ? Colors.greenAccent : Colors.green.shade700,
                          size: 26,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          userPoints.toString(),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.greenAccent : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: userPoints / 1000,
                    minHeight: 8,
                    backgroundColor:
                        isDark ? Colors.grey.shade800 : Colors.green.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.greenAccent : Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tier: Eco Enthusiast',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                    Text(
                      '650 pts to next tier',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyRewardsTab(context),
                _buildRedeemTab(context),
                _buildHistoryTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRewardsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildAchievementBadge(context, 'Paper Recycler', Icons.description, true),
              _buildAchievementBadge(context, 'Plastic Hero', Icons.local_drink, true),
              _buildAchievementBadge(context, 'E-Waste Expert', Icons.devices, false),
              _buildAchievementBadge(context, '1-Month Streak', Icons.calendar_month, true),
              _buildAchievementBadge(context, 'Zero Waste', Icons.delete_outline, false),
              _buildAchievementBadge(context, 'Community Leader', Icons.people, false),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Current Challenges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildChallengeCard(
            context,
            'Weekly Paper Challenge',
            'Recycle 5kg of paper this week',
            '3.2/5 kg',
            0.64,
            '2 days left',
          ),
          const SizedBox(height: 12),
          _buildChallengeCard(
            context,
            'Community Challenge',
            'Help your neighborhood reach 1000kg recycled',
            '780/1000 kg',
            0.78,
            '5 days left',
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Environmental Impact',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildImpactMetric(context, '120 kg', 'Waste Recycled', Icons.delete_outline),
              _buildImpactMetric(context, '15 kg', 'CO₂ Saved', Icons.cloud_outlined),
              _buildImpactMetric(context, '5', 'Trees Saved', Icons.forest),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: true,
                onSelected: (bool selected) {},
                backgroundColor: isDark ? const Color(0xFF1E2E20) : Colors.green.shade50,
                selectedColor: isDark ? Colors.greenAccent : Colors.green.shade100,
                checkmarkColor: isDark ? Colors.black : Colors.green,
              ),
              FilterChip(
                label: const Text('Discounts'),
                selected: false,
                onSelected: (bool selected) {},
              ),
              FilterChip(
                label: const Text('Products'),
                selected: false,
                onSelected: (bool selected) {},
              ),
              FilterChip(
                label: const Text('Donations'),
                selected: false,
                onSelected: (bool selected) {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRewardItem(
            context,
            'Pickup Discount',
            '20% off your next pickup',
            200,
            Icons.local_shipping,
          ),
          _buildRewardItem(
            context,
            'Eco-Friendly Tote Bag',
            'Reusable shopping bag made from recycled materials',
            300,
            Icons.shopping_bag,
          ),
          _buildRewardItem(
            context,
            'Plant a Tree',
            'We\'ll plant a tree on your behalf',
            400,
            Icons.forest,
          ),
          _buildRewardItem(
            context,
            'Compost Bin',
            'High-quality home composting bin',
            750,
            Icons.compost,
          ),
          _buildRewardItem(
            context,
            'Monthly Subscription',
            'Free pickup subscription for 1 month',
            1000,
            Icons.calendar_month,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildHistoryItem(
          context,
          'Points Earned',
          '50 points for paper recycling',
          '12 Apr 2025',
          isEarned: true,
        ),
        _buildHistoryItem(
          context,
          'Reward Redeemed',
          'Pickup Discount (200 points)',
          '10 Apr 2025',
          isEarned: false,
        ),
        _buildHistoryItem(
          context,
          'Challenge Completed',
          '100 points for Weekly Challenge',
          '7 Apr 2025',
          isEarned: true,
        ),
        _buildHistoryItem(
          context,
          'Points Earned',
          '75 points for plastic recycling',
          '3 Apr 2025',
          isEarned: true,
        ),
        _buildHistoryItem(
          context,
          'Reward Redeemed',
          'Eco-Friendly Tote Bag (300 points)',
          '28 Mar 2025',
          isEarned: false,
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(
      BuildContext context, String title, IconData icon, bool unlocked) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: unlocked
                ? (isDark ? const Color(0xFF1B3D20) : Colors.green.shade100)
                : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200),
            shape: BoxShape.circle,
            border: Border.all(
              color: unlocked
                  ? (isDark ? Colors.greenAccent : Colors.green.shade700)
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: unlocked
                ? (isDark ? Colors.greenAccent : Colors.green.shade700)
                : (isDark ? Colors.grey.shade500 : Colors.grey.shade500),
            size: 30,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: unlocked ? onSurface : onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard(BuildContext context, String title, String description,
      String progress, double progressValue, String timeLeft) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B3D20) : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    timeLeft,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.greenAccent : Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.greenAccent : Colors.green,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  progress,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Reward: 100 points',
                  style: TextStyle(
                    color: isDark ? Colors.greenAccent : Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactMetric(
      BuildContext context, String value, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B3D20) : Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.greenAccent : Colors.green.shade800,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardItem(BuildContext context, String title, String description,
      int pointsCost, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    bool canAfford = userPoints >= pointsCost;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B3D20) : Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.greenAccent : Colors.green.shade800,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.eco,
                            size: 16,
                            color: isDark ? Colors.greenAccent : Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$pointsCost points',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.greenAccent
                                  : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: canAfford ? () {} : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.greenAccent : Colors.green,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                        ),
                        child: Text(AppSettings.instance.tr('redeem')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
      BuildContext context, String title, String description, String date,
      {required bool isEarned}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isEarned
                    ? (isDark ? const Color(0xFF1B3D20) : Colors.green.shade100)
                    : (isDark ? const Color(0xFF3D2A1B) : Colors.orange.shade100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEarned ? Icons.add : Icons.remove,
                color: isEarned
                    ? (isDark ? Colors.greenAccent : Colors.green.shade800)
                    : Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              date,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}