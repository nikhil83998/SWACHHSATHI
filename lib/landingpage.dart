import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unknown/LocationPage.dart';
import 'package:unknown/OnDemand.dart';
import 'package:unknown/RequestPage.dart';
import 'package:unknown/Reward.dart';
import 'package:unknown/SpecialPick.dart';
import 'package:unknown/account.dart';
import 'package:unknown/notificationpage.dart';
import 'package:unknown/utils/app_settings.dart';
import 'package:unknown/utils/app_theme.dart';

class Landingpage extends StatefulWidget {
  final String username;
  const Landingpage({super.key, required this.username});

  @override
  State<Landingpage> createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage> {
  String username = "User";
  String weatherUpdate = "Loading weather...";
  IconData weatherIcon = Icons.cloud;
  int _currentIndex = 0;

  IconData _getWeatherIcon(String mainCondition, double temperature) {
    switch (mainCondition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
        return Icons.water_drop;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'fog':
        return Icons.dehaze;
      default:
        if (temperature > 28) return Icons.wb_sunny;
        if (temperature > 18) return Icons.cloud_queue;
        return Icons.cloud;
    }
  }

  @override
  void initState() {
    super.initState();
    username = widget.username;
    _getLocationAndWeather();
  }

  Future<void> _getLocationAndWeather() async {
    try {
      Position? position;
      try {
        position = await _determinePosition();
      } catch (locErr) {
        debugPrint("Location service/permission unavailable, using default: $locErr");
      }

      final double lat = position?.latitude ?? 28.6139;
      final double lon = position?.longitude ?? 77.2090;

      final weatherData = await _fetchWeather(lat, lon);

      if (!mounted) return;
      setState(() {
        weatherUpdate = weatherData['formatted'];
        weatherIcon = _getWeatherIcon(
          weatherData['condition'] as String,
          weatherData['temp'] as double,
        );
      });
    } catch (e) {
      debugPrint("Error fetching weather: $e");
      if (!mounted) return;
      setState(() {
        weatherUpdate = "Weather unavailable";
        weatherIcon = Icons.cloud_off;
      });
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      timeLimit: const Duration(seconds: 5),
    );
  }

  Future<Map<String, dynamic>> _fetchWeather(double latitude, double longitude) async {
    const String apiKey = "29446311c4058dd1162a24123cbe4190";
    final String apiUrl =
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey";

    final response = await http.get(Uri.parse(apiUrl)).timeout(
      const Duration(seconds: 8),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String condition = data["weather"]?[0]?["main"] ?? "Clear";
      final String description = data["weather"]?[0]?["description"] ?? "Clear";
      final double temperature =
          (data["main"]?["temp"] as num?)?.toDouble() ?? 25.0;
      final String cityName = data["name"] ?? "";

      final String capitalizedDesc = description.isNotEmpty
          ? "${description[0].toUpperCase()}${description.substring(1)}"
          : "Clear";

      final String formatted = cityName.isNotEmpty
          ? "$capitalizedDesc, ${temperature.toStringAsFixed(1)}°C ($cityName)"
          : "$capitalizedDesc, ${temperature.toStringAsFixed(1)}°C";

      return {
        'condition': condition,
        'description': description,
        'temp': temperature,
        'formatted': formatted,
      };
    } else {
      throw Exception("Failed to fetch weather data: ${response.statusCode}");
    }
  }

  void _showPopupMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppSettings.instance.tr('more_options'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                      children: [
                        _buildMenuItem(
                            Icons.recycling, AppSettings.instance.tr('recycle'), Colors.green),
                        _buildMenuItem(
                            Icons.location_on, AppSettings.instance.tr('nearby'), Colors.red),
                        _buildMenuItem(
                            Icons.school, AppSettings.instance.tr('education'), Colors.indigo),
                        _buildMenuItem(
                            Icons.shopping_bag, AppSettings.instance.tr('shopping'), Colors.blue),
                        _buildMenuItem(
                            Icons.article, AppSettings.instance.tr('news'), Colors.purple),
                        _buildMenuItem(
                            Icons.favorite, AppSettings.instance.tr('donation'), Colors.pink),
                        _buildMenuItem(
                            Icons.people, AppSettings.instance.tr('community'), Colors.teal),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        debugPrint("$label clicked");
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: screenWidth * 0.065,
            backgroundColor: color.withValues(alpha: isDark ? 0.25 : 0.15),
            child: Icon(
              icon,
              color: color,
              size: screenWidth * 0.07,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF2E7D32);
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final itemColor = isSelected ? activeColor : inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor.withValues(alpha: isDark ? 0.2 : 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  size: 24,
                  color: itemColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: itemColor,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Container(
              width: double.infinity,
              height: screenHeight * 0.32,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/s.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Content
          Positioned(
            top: screenHeight * 0.27,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  AppSettings.instance.tr('selection'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34.0,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.greenAccent : AppTheme.primaryGreen,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppSettings.instance.tr('choose_service'),
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: screenHeight * 0.40,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2820) : const Color(0xFFF1F8F1),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: isDark
                      ? Colors.green.withValues(alpha: 0.25)
                      : Colors.green.shade200,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.95,
                children: [
                  _buildOptionItem(
                    imagePath: 'assets/images/reuse.png',
                    label: AppSettings.instance.tr('on_demand_pickup'),
                    context: context,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Ondemand()),
                      );
                    },
                  ),
                  _buildOptionItem(
                    imagePath: 'assets/images/recycle-sign.png',
                    label: AppSettings.instance.tr('special_pickup'),
                    context: context,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Specialpick()),
                      );
                    },
                  ),
                  _buildOptionItem(
                    imagePath: 'assets/images/activities.png',
                    label: AppSettings.instance.tr('request_history'),
                    context: context,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Requestpage()),
                      );
                    },
                  ),
                  _buildOptionItem(
                    imagePath: 'assets/images/chat-bubble.png',
                    label: AppSettings.instance.tr('reward_points'),
                    context: context,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RewardPage()),
                      );
                    },
                  ),
                  _buildOptionItem(
                    imagePath: 'assets/images/comment.png',
                    label: AppSettings.instance.tr('location'),
                    context: context,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Locationpage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Custom AppBar and Weather Header
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.eco,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppSettings.instance.tr('app_name'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 20),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Weather Update Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2D3748) : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                        blurRadius: 10.0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(weatherIcon, color: Colors.blue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${AppSettings.instance.tr('welcome')}, $username",
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              weatherUpdate,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF4ADE80), const Color(0xFF22C55E)]
                : [const Color(0xFF2E7D32), const Color(0xFF388E3C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? const Color(0xFF4ADE80) : const Color(0xFF2E7D32))
                  .withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            _showPopupMenu(context);
          },
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.grid_view_rounded, size: 28),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: isDark ? const Color(0xFF1A241C) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 12,
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left pair: Home and Activities
            Expanded(
              child: Row(
                children: [
                  _buildNavItem(
                    activeIcon: Icons.home_rounded,
                    inactiveIcon: Icons.home_outlined,
                    label: AppSettings.instance.tr('home'),
                    isSelected: _currentIndex == 0,
                    onTap: () {
                      setState(() => _currentIndex = 0);
                    },
                  ),
                  _buildNavItem(
                    activeIcon: Icons.receipt_long_rounded,
                    inactiveIcon: Icons.receipt_long_outlined,
                    label: AppSettings.instance.tr('activities'),
                    isSelected: _currentIndex == 1,
                    onTap: () {
                      setState(() => _currentIndex = 1);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Requestpage()),
                      ).then((_) {
                        if (mounted) setState(() => _currentIndex = 0);
                      });
                    },
                  ),
                ],
              ),
            ),

            // Gap for docked Center FloatingActionButton
            const SizedBox(width: 64),

            // Right pair: Notifications and Account
            Expanded(
              child: Row(
                children: [
                  _buildNavItem(
                    activeIcon: Icons.notifications_rounded,
                    inactiveIcon: Icons.notifications_outlined,
                    label: AppSettings.instance.tr('notifications'),
                    isSelected: _currentIndex == 2,
                    onTap: () {
                      setState(() => _currentIndex = 2);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationPage(),
                        ),
                      ).then((_) {
                        if (mounted) setState(() => _currentIndex = 0);
                      });
                    },
                  ),
                  _buildNavItem(
                    activeIcon: Icons.person_rounded,
                    inactiveIcon: Icons.person_outline_rounded,
                    label: AppSettings.instance.tr('account'),
                    isSelected: _currentIndex == 3,
                    onTap: () {
                      setState(() => _currentIndex = 3);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountPage()),
                      ).then((_) {
                        if (mounted) setState(() => _currentIndex = 0);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildOptionItem({
  required String imagePath,
  required String label,
  required BuildContext context,
  required VoidCallback onTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final onSurface = Theme.of(context).colorScheme.onSurface;

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF253327) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334A36) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 36.0,
            height: 36.0,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);

    var firstControlPoint = Offset(size.width / 4, size.height - 50);
    var firstEndPoint = Offset(size.width / 2, size.height - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 4), size.height - 50);
    var secondEndPoint = Offset(size.width, size.height);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
