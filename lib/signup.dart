import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:unknown/auth_service.dart';
import 'package:unknown/landingpage.dart';
import 'package:unknown/privacypolicy.dart';
import 'package:unknown/utils/app_settings.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool _isChecked = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscureText = true;
  bool _isLoading = false;
  final _mobileController = TextEditingController();

  void _navigateToPrivacyPolicy() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
  }

  void _navigateToTermsOfUse() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const TermsOfUseScreen()));
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();

      String? uid = _authService.getCurrentUserId();
      if (uid == null) throw Exception("User UID is null after Google sign-in");

      Map<String, dynamic>? userData;
      try {
        userData = await _authService.getUserData(uid);
      } catch (e) {
        logger.w("Failed to fetch user data after Google sign-in: $e");
      }

      String username = userData?['username'] ??
          FirebaseAuth.instance.currentUser?.displayName ??
          FirebaseAuth.instance.currentUser?.email?.split('@').first ??
          "User";

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Landingpage(username: username),
          ),
        );
      }
    } catch (e) {
      logger.e("Google Sign-In Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google sign-in failed. Please try again.")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      if (!_isChecked) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Please agree to the Privacy Policy and Terms of use')),
          );
        }
        return;
      }
      setState(() => _isLoading = true);
      try {
        await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          username: _usernameController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _mobileController.text.trim(),
        );
        if (mounted) {
          final String username = _usernameController.text.trim().isNotEmpty
              ? _usernameController.text.trim()
              : 'User';
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => Landingpage(username: username),
            ),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        logger.e("FirebaseAuthException: ${e.message}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Account creation failed')),
          );
        }
      } catch (e) {
        logger.e("Unexpected error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('An unexpected error occured')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppSettings.instance.tr('welcome'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.greenAccent : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppSettings.instance.tr('app_name'),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: onSurface,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppSettings.instance.tr('create_account_subtitle'),
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.65),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                labelText: AppSettings.instance.tr('first_name'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter first name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                labelText: AppSettings.instance.tr('last_name'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter last name';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: AppSettings.instance.tr('username'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: const Icon(Icons.alternate_email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: AppSettings.instance.tr('email'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          final cleanNumber = value
                              .trim()
                              .replaceAll(RegExp(r'[\s\-()]'), '');
                          if (!RegExp(r'^(?:\+91|91|0)?[6-9]\d{9}$')
                              .hasMatch(cleanNumber)) {
                            return 'Please enter a valid 10-digit mobile number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: AppSettings.instance.tr('phone_number'),
                          hintText: 'e.g. 9876543210',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          } else if (!RegExp(r'(?=.*?[A-Z])')
                              .hasMatch(value)) {
                            return 'Must contain at least one uppercase letter';
                          } else if (!RegExp(r'(?=.*?[a-z])')
                              .hasMatch(value)) {
                            return 'Must contain at least one lowercase letter';
                          } else if (!RegExp(r'(?=.*?[0-9])')
                              .hasMatch(value)) {
                            return 'Must contain at least one digit';
                          } else if (!RegExp(r'(?=.*?[!@#\$&*~])')
                              .hasMatch(value)) {
                            return 'Must contain at least one special character';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: AppSettings.instance.tr('password'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _isChecked,
                              activeColor: isDark ? Colors.greenAccent : Colors.green,
                              checkColor: isDark ? Colors.black : Colors.white,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isChecked = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: onSurface.withValues(alpha: 0.8),
                                ),
                                children: [
                                  TextSpan(text: AppSettings.instance.tr('agree_terms')),
                                  TextSpan(
                                    text: AppSettings.instance.tr('privacy_policy'),
                                    style: TextStyle(
                                      color: isDark ? Colors.greenAccent : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationColor: isDark ? Colors.greenAccent : Colors.green,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _navigateToPrivacyPolicy,
                                  ),
                                  TextSpan(text: AppSettings.instance.tr('and')),
                                  TextSpan(
                                    text: AppSettings.instance.tr('terms_of_use'),
                                    style: TextStyle(
                                      color: isDark ? Colors.greenAccent : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationColor: isDark ? Colors.greenAccent : Colors.green,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _navigateToTermsOfUse,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              (_isChecked && !_isLoading) ? _createAccount : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.greenAccent : Colors.green,
                            disabledBackgroundColor:
                                isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade300,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            disabledForegroundColor:
                                isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  AppSettings.instance.tr('create_account'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        color: theme.dividerColor,
                        thickness: 1,
                        indent: 10,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        AppSettings.instance.tr('or_continue_with'),
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: theme.dividerColor,
                        thickness: 1,
                        endIndent: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: _isLoading ? null : _signInWithGoogle,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          border: Border.all(
                            color: isDark ? const Color(0xFF404040) : Colors.grey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/google.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          border: Border.all(
                            color: isDark ? const Color(0xFF404040) : Colors.grey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/fb.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dummy Terms of Use Screen
class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppSettings.instance.tr('terms_of_use'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppSettings.instance.tr('terms_of_use'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "By using SwachhSathi, you agree to comply with our community guidelines and local waste disposal regulations.\n\n"
              "1. Responsible Recycling\n"
              "Users agree to accurately categorize waste materials before requesting pickups.\n\n"
              "2. Account Security\n"
              "You are responsible for maintaining the confidentiality of your account credentials.\n\n"
              "3. Service Availability\n"
              "Pickups and reward distributions are subject to local operations schedule and driver availability.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Understood"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
