import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:unknown/landingpage.dart';

class AppUser {
  final String name;
  final String address;
  final String phone;
  final String? specialInstructions;

  AppUser({
    required this.name,
    required this.address,
    required this.phone,
    this.specialInstructions,
  });
}

class ConfirmationPage extends StatefulWidget {
  final AppUser? user;
  final String wasteType;
  final String pickupShift;
  final String pickUpDate;
  final String estimatedWeight;
  final String additionalInfo;

  const ConfirmationPage({
    super.key,
    this.user,
    required this.wasteType,
    required this.pickupShift,
    required this.pickUpDate,
    required this.estimatedWeight,
    required this.additionalInfo,
  });

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Trigger animation after build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[700]!, Colors.green[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal:
                isLargeScreen ? MediaQuery.of(context).size.width * 0.1 : 20,
            vertical: 20,
          ),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeaderSection(theme, isLargeScreen),
                  const SizedBox(height: 24),
                  _buildConfirmationCard(theme, colorScheme, isLargeScreen),
                  const SizedBox(height: 32),
                  _buildActionButtons(context, isLargeScreen),
                  const SizedBox(height: 20),
                  _buildNextStepsInfo(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme, bool isLargeScreen) {
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2E1C) : Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.green.withValues(alpha: 0.3) : Colors.green.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF254827) : Colors.green[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: isLargeScreen ? 48 : 40,
              color: isDark ? Colors.greenAccent : Colors.green[700],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Request Submitted!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: isLargeScreen ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.greenAccent : Colors.green[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your special pickup has been scheduled',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onSurface.withValues(alpha: 0.75),
              fontSize: isLargeScreen ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCard(
      ThemeData theme, ColorScheme colorScheme, bool isLargeScreen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.green.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pickup Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              icon: Icons.recycling,
              title: 'Waste Type',
              value: widget.wasteType,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildDetailItem(
              icon: Icons.access_time,
              title: 'Pickup Shift',
              value: widget.pickupShift,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildDetailItem(
              icon: Icons.calendar_today,
              title: 'Pickup Date',
              value: widget.pickUpDate,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildDetailItem(
              icon: Icons.scale,
              title: 'Estimated Weight',
              value: widget.estimatedWeight,
              theme: theme,
            ),
            if (widget.additionalInfo.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailItem(
                icon: Icons.note,
                title: 'Additional Notes',
                value: widget.additionalInfo,
                theme: theme,
                isMultiline: true,
              ),
            ],
            const SizedBox(height: 16),
            Divider(
              color: Colors.grey[300],
              height: 1,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'You will receive a confirmation email with pickup details.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required ThemeData theme,
    bool isMultiline = false,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Row(
      crossAxisAlignment:
          isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF254827) : Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? Colors.greenAccent : Colors.green[700],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onSurface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 4),
              isMultiline
                  ? Text(
                      value,
                      style: theme.textTheme.bodyMedium,
                    )
                  : Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLargeScreen) {
    return Row(
      children: [
        if (isLargeScreen) const Spacer(),
        Expanded(
          flex: isLargeScreen ? 2 : 1,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.green[700]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('EDIT REQUEST'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: isLargeScreen ? 2 : 1,
          child: FilledButton.icon(
            onPressed: () {
              _showConfirmationDialog();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text(
              'CONFIRM',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        if (isLargeScreen) const Spacer(),
      ],
    );
  }

  Widget _buildNextStepsInfo(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162536) : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.blue.withValues(alpha: 0.3) : Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: isDark ? Colors.lightBlueAccent : Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'What happens next?',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.lightBlueAccent : Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._buildNextStepsItems(theme),
        ],
      ),
    );
  }

  List<Widget> _buildNextStepsItems(ThemeData theme) {
    return [
      _buildNextStepItem(
        '1. You will receive a confirmation email within 15 minutes',
        theme,
      ),
      _buildNextStepItem(
        '2. Our team will review your request and contact you if needed',
        theme,
      ),
      _buildNextStepItem(
        '3. A collector will arrive during your selected time window',
        theme,
      ),
      _buildNextStepItem(
        '4. You can track the pickup status in your dashboard',
        theme,
      ),
    ];
  }

  Widget _buildNextStepItem(String text, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8, color: isDark ? Colors.lightBlueAccent : Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? onSurface : Colors.blue[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmationDialog() async {
    // First check if user details are complete
    final userComplete = await _checkUserDetailsComplete();

    if (!mounted) return;

    if (!userComplete) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Profile Incomplete'),
          content: const Text(
            'Please complete your account details before scheduling a pickup. '
            'We need this information for proper service delivery.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('LATER'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _navigateToProfilePage();
              },
              child: const Text('UPDATE NOW'),
            ),
          ],
        ),
      );
      return;
    }

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Pickup'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Are you sure you want to confirm this pickup request?'),
                const SizedBox(height: 16),
                _buildUserDetailPreview(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('CONFIRM'),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted) return;

    if (confirmed) {
      _processConfirmedPickup();
    }
  }

  Widget _buildUserDetailPreview() {
    if (widget.user == null) {
      return const Text('User information not available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Name', widget.user!.name),
        _buildDetailRow('Address', widget.user!.address),
        _buildDetailRow('Contact', widget.user!.phone),
        if (widget.user!.specialInstructions?.isNotEmpty ?? false)
          _buildDetailRow('Notes', widget.user!.specialInstructions!),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<bool> _checkUserDetailsComplete() async {
   // First check if user object exists
  if (widget.user == null) {
    return false;
  }

  // Check each required field with null safety
  final hasName = widget.user?.name.isNotEmpty ?? false;
  final hasAddress = widget.user?.address.isNotEmpty ?? false;
  final hasPhone = widget.user?.phone.isNotEmpty ?? false;

  return hasName && hasAddress && hasPhone;
  }

  void _navigateToProfilePage() {
    String username = "";
    if (FirebaseAuth.instance.currentUser != null) {
      username = FirebaseAuth.instance.currentUser!.displayName ?? "";
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => ProfilePage(username: username)),
    ).then((_) {
      if (mounted) {
        _showConfirmationDialog();
      }
    });
  }

  void _processConfirmedPickup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pickup scheduled successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (ctx) => const Landingpage(username: '')),
      (route) => false,
    );
  }
}

// Temporary placeholder for ProfilePage - replace with your actual implementation
class ProfilePage extends StatelessWidget {
   final String username;
  const ProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body:  Center(child: Text('Profile Page for $username')),
    );
  }
}
