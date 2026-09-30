import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unknown/landingpage.dart';
import 'package:unknown/utils/app_settings.dart';
import 'auth_service.dart';
import 'package:logger/logger.dart';

class Login extends StatefulWidget {
  const Login({super.key});  

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final Logger logger = Logger();
  bool _obscureText = true;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _authService.logIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        String? uid = _authService.getCurrentUserId();
        if (uid == null) throw Exception("User UID is null");

        Map<String, dynamic>? userData;
        try {
          userData = await _authService.getUserData(uid);
        } catch (e) {
          logger.w("Failed to fetch user data: $e");
        }

        String username = userData?['username'] ??
            _emailController.text
                .split('@')
                .first;

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => Landingpage(username: username),
            ),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        logger.e("FirebaseAuthException: ${e.code} - ${e.message}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_getFriendlyAuthError(e))),
          );
        }
      } catch (e) {
        logger.e("Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("An unexpected error occurred")),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _resetPassword() async {
    final emailController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setModalState) {
          return AlertDialog(
            title: Text(AppSettings.instance.tr('forgot_password')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter your email to receive a password reset link'),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: AppSettings.instance.tr('email'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppSettings.instance.tr('cancel')),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (emailController.text.isEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter your email')),
                          );
                          return;
                        }

                        setModalState(() => isLoading = true);
                        final messenger = ScaffoldMessenger.of(dialogContext);
                        final nav = Navigator.of(dialogContext);
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: emailController.text.trim(),
                          );
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Password reset email sent to ${emailController.text}'),
                            ),
                          );
                          nav.pop();
                        } on FirebaseAuthException catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(_getFriendlyAuthError(e)),
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Failed to send reset email. Please try again.'),
                            ),
                          );
                        } finally {
                          setModalState(() => isLoading = false);
                        }
                      },
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(AppSettings.instance.tr('send_request')),
              ),
            ],
          );
        },
      ),
    );
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Landingpage(username: username),
          ),
          (route) => false,
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

  String _getFriendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email. Please register first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later or reset your password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email but different sign-in method.';
      case 'credential-already-in-use':
        return 'This account is already linked with another user.';
      case 'expired-action-code':
        return 'The password reset link has expired. Please request a new one.';
      case 'invalid-action-code':
        return 'The password reset link is invalid. Please request a new one.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password (at least 6 characters).';
      case 'email-already-in-use':
        return 'This email is already registered. Please use another email or login.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please login again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Contact support for help.';
      default:
        return e.message ?? 'An unexpected error occurred. Please try again.';
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.recycling,
                      size: 40,
                      color: isDark ? Colors.greenAccent : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppSettings.instance.tr('app_name'),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.greenAccent : Colors.green,
                        fontSize: 38,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  AppSettings.instance.tr('login'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppSettings.instance.tr('welcome_back'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.65),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: AppSettings.instance.tr('email'),
                          hintText: 'name@example.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: AppSettings.instance.tr('password'),
                          hintText: 'Enter your password',
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          child: Text(
                            AppSettings.instance.tr('forgot_password'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.greenAccent : Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            backgroundColor: isDark ? Colors.greenAccent : Colors.green,
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
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  AppSettings.instance.tr('login'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),
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
                const SizedBox(height: 24),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
