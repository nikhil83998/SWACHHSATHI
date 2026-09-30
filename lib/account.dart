import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unknown/auth_service.dart';
import 'package:unknown/privacypolicy.dart';
import 'package:unknown/utils/app_settings.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AuthService _auth = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Color _primaryGreen = const Color(0xFF2E7D32);
  final Color _accentGreen = const Color(0xFF4CAF50);
  User? _currentUser;
  Map<String, dynamic>? _userData;
  File? _profileImage;
  bool _isUploading = false;

  bool _isValidIndianPhoneNumber(String phone) {
    // Indian phone number regex (10 digits starting with 6-9)
    final indianPhoneRegex = RegExp(r'^[6-9]\d{9}$');
    return indianPhoneRegex.hasMatch(phone);
  }

  String? _validateIndianPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }

    // Remove all non-digit characters
    String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length != 10) {
      return 'Phone number must be 10 digits';
    }

    if (!_isValidIndianPhoneNumber(digitsOnly)) {
      return 'Please enter a valid Indian phone number';
    }

    return null;
  }

  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      setState(() => _currentUser = user);
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data()!;
          _firstNameController.text = _userData?['firstName'] ?? '';
          _lastNameController.text = _userData?['lastName'] ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = user.phoneNumber ?? _userData?['phone'] ?? '';
          _addressController.text = _userData?['address'] ?? '';
        });
      }
    }
  }

  Future<void> _launchContactPicker() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contact = await FlutterContacts.openExternalPick();

        if (contact != null) {
          final fullContact = await FlutterContacts.getContact(contact.id);

          if (fullContact != null && fullContact.phones.isNotEmpty) {
            String? phoneNumber = fullContact.phones.first.number;
            String digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

            if (digits.startsWith('91') && digits.length == 12) {
              digits = digits.substring(2);
            } else if (digits.startsWith('0') && digits.length == 11) {
              digits = digits.substring(1);
            }

            if (digits.length == 10) {
              setState(() {
                _phoneController.text = digits;
              });
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Please select a valid 10-digit Indian number'),
                  ),
                );
              }
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Selected contact has no phone number')),
              );
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact permission denied')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing contacts: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _isUploading = true;
      });

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${_currentUser!.uid}.jpg');
        await storageRef.putFile(_profileImage!);

        final imageUrl = await storageRef.getDownloadURL();

        await _currentUser!.updatePhotoURL(imageUrl);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .update({'photoUrl': imageUrl});

        await _currentUser!.reload();
        _currentUser = FirebaseAuth.instance.currentUser;
        await _loadUserData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile image: $e')),
          );
        }
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();

      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error signing out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallPhone = screenSize.width < 360;
    final isTablet = screenSize.width >= 600;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppSettings.instance.tr('settings'),
          style: TextStyle(
            fontSize: _responsiveSize(18, 20, 22, screenSize.width),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: _responsivePadding(12, 16, 24, screenSize.width),
            vertical: 16,
          ),
          child: Column(
            children: [
              _buildProfileCard(context, isSmallPhone, isTablet, textScale),
              SizedBox(height: _responsiveGap(16, 24, 32, screenSize.width)),
              _buildSettingsSection(
                context: context,
                title: AppSettings.instance.tr('account'),
                options: _accountOptions(),
                screenSize: screenSize,
              ),
              SizedBox(height: _responsiveGap(16, 24, 32, screenSize.width)),
              _buildSettingsSection(
                context: context,
                title: AppSettings.instance.tr('preferences'),
                options: _preferenceOptions(),
                screenSize: screenSize,
              ),
              SizedBox(height: _responsiveGap(16, 24, 32, screenSize.width)),
              _buildSettingsSection(
                context: context,
                title: AppSettings.instance.tr('about_app'),
                options: _aboutOptions(),
                screenSize: screenSize,
              ),
              SizedBox(height: _responsiveGap(24, 32, 40, screenSize.width)),
              _buildLogoutButton(context, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;

    final phoneError = _validateIndianPhoneNumber(_phoneController.text);
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(phoneError)),
      );
      return;
    }

    try {
      setState(() => _isUploading = true);

      String phoneDigits =
          _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phone': phoneDigits,
        'phoneCountry': 'IN',
        'address': _addressController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (_emailController.text.trim() != _currentUser!.email) {
        await _currentUser!.verifyBeforeUpdateEmail(_emailController.text.trim());
      }

      await _currentUser!.reload();
      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppSettings.instance.tr('save_changes'))),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _changePassword(
      String currentPassword, String newPassword) async {
    try {
      setState(() => _isUploading = true);

      final credential = EmailAuthProvider.credential(
        email: _currentUser!.email!,
        password: currentPassword,
      );
      await _currentUser!.reauthenticateWithCredential(credential);

      await _currentUser!.updatePassword(newPassword);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error changing password: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Widget _buildProfileCard(BuildContext context, bool isSmallPhone,
      bool isTablet, double textScale) {
    final avatarSize = isTablet
        ? 100.0
        : isSmallPhone
            ? 70.0
            : 80.0;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_primaryGreen, _accentGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: _isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : _currentUser?.photoURL != null
                              ? ClipOval(
                                  child: Image.network(
                                    _currentUser!.photoURL!,
                                    width: avatarSize,
                                    height: avatarSize,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Text(
                                  _userData?['firstName']
                                          ?.toString()
                                          .substring(0, 1) ??
                                      _currentUser?.email?.substring(0, 1) ??
                                      'U',
                                  style: TextStyle(
                                    fontSize: avatarSize * 0.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                    ),
                  ),
                  if (!_isUploading)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: isTablet ? 24 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userData != null
                        ? '${_userData!['firstName']} ${_userData!['lastName']}'
                        : _currentUser?.displayName ?? 'User',
                    style: TextStyle(
                      fontSize: _responsiveText(16, 18, 20, textScale),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 8 : 4),
                  Text(
                    _currentUser?.email ?? 'No email',
                    style: TextStyle(
                      fontSize: _responsiveText(12, 14, 16, textScale),
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_currentUser?.phoneNumber != null) ...[
                    SizedBox(height: isTablet ? 8 : 4),
                    Text(
                      _currentUser!.phoneNumber!,
                      style: TextStyle(
                        fontSize: _responsiveText(12, 14, 16, textScale),
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required BuildContext context,
    required String title,
    required List<Widget> options,
    required Size screenSize,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.greenAccent : _primaryGreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: _responsivePadding(8, 12, 16, screenSize.width),
            bottom: 8,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: _responsiveText(16, 18, 20, 1.0),
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: options,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Size screenSize,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.greenAccent : _primaryGreen;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: _responsivePadding(12, 16, 24, screenSize.width),
            vertical: screenSize.width > 600 ? 16 : 12,
          ),
          leading: Icon(
            icon,
            size: _responsiveSize(20, 24, 28, screenSize.width),
            color: primaryColor,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: _responsiveText(14, 16, 18, 1.0),
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            size: _responsiveSize(20, 24, 28, screenSize.width),
            color: onSurface.withValues(alpha: 0.4),
          ),
          minVerticalPadding: 0,
          visualDensity: VisualDensity.compact,
          onTap: onTap,
        ),
        Divider(
          height: 1,
          indent: _responsivePadding(12, 16, 24, screenSize.width),
          endIndent: _responsivePadding(12, 16, 24, screenSize.width),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isTablet) {
    return SizedBox(
      width: isTablet ? 400 : double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[400],
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 18 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _signOut,
        icon: Icon(
          Icons.logout,
          size: _responsiveSize(18, 20, 22, MediaQuery.sizeOf(context).width),
        ),
        label: Text(
          AppSettings.instance.tr('sign_out'),
          style: TextStyle(
            fontSize: _responsiveText(14, 16, 18, 1.0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  double _responsiveSize(
      double small, double medium, double large, double width) {
    if (width < 360) return small;
    if (width < 600) return medium;
    return large;
  }

  double _responsivePadding(
      double small, double medium, double large, double width) {
    if (width < 360) return small;
    if (width < 600) return medium;
    return large;
  }

  double _responsiveGap(
      double small, double medium, double large, double width) {
    if (width < 360) return small;
    if (width < 600) return medium;
    return large;
  }

  double _responsiveText(
      double small, double medium, double large, double textScale) {
    double baseSize;
    if (MediaQuery.sizeOf(context).width < 360) {
      baseSize = small;
    } else if (MediaQuery.sizeOf(context).width < 600) {
      baseSize = medium;
    } else {
      baseSize = large;
    }
    return baseSize * textScale;
  }

  List<Widget> _accountOptions() {
    return [
      _buildSettingsTile(
        icon: Icons.person_outline,
        title: AppSettings.instance.tr('profile_info'),
        onTap: () {
          _showProfileInformationDialog(context);
        },
        screenSize: MediaQuery.sizeOf(context),
      ),
      _buildSettingsTile(
        icon: Icons.lock_outline,
        title: AppSettings.instance.tr('privacy_settings'),
        onTap: () => _showPrivacySettingsDialog(context),
        screenSize: MediaQuery.sizeOf(context),
      ),
      _buildSettingsTile(
        icon: Icons.password,
        title: AppSettings.instance.tr('change_password'),
        onTap: () => _showChangePasswordDialog(context),
        screenSize: MediaQuery.sizeOf(context),
      ),
    ];
  }

  List<Widget> _aboutOptions() {
    return [
      _buildSettingsTile(
        icon: Icons.info_outline,
        title: AppSettings.instance.tr('about_app'),
        onTap: () => _showAboutAppDialog(context),
        screenSize: MediaQuery.sizeOf(context),
      ),
      _buildSettingsTile(
        icon: Icons.help_outline,
        title: AppSettings.instance.tr('help_support'),
        onTap: () => _showHelpSupportDialog(context),
        screenSize: MediaQuery.sizeOf(context),
      ),
    ];
  }

  void _showProfileInformationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildResponsiveDialog(
        title: AppSettings.instance.tr('edit_profile'),
        content: Form(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: AppSettings.instance.tr('first_name'),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: AppSettings.instance.tr('last_name'),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: AppSettings.instance.tr('email'),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: AppSettings.instance.tr('phone_number'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone),
                    prefixText: '+91',
                    suffixIcon: IconButton(
                      onPressed: () => _launchContactPicker(),
                      icon: const Icon(Icons.contact_phone),
                    ),
                    errorMaxLines: 2,
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _validateIndianPhoneNumber,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: AppSettings.instance.tr('address'),
                    prefixIcon: const Icon(Icons.home),
                    hintText: 'Enter your full address',
                  ),
                  keyboardType: TextInputType.streetAddress,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                _isUploading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          AppSettings.instance.tr('save_changes'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPrivacySettingsDialog(BuildContext context) {
    bool emailNotifications = true;
    bool pushNotifications = true;
    bool showOnlineStatus = true;
    bool shareProfileData = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return _buildResponsiveDialog(
            title: AppSettings.instance.tr('privacy_settings'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: Text(AppSettings.instance.tr('email_notifications')),
                    value: emailNotifications,
                    onChanged: (value) =>
                        setModalState(() => emailNotifications = value),
                    activeColor: _primaryGreen,
                  ),
                  SwitchListTile(
                    title: Text(AppSettings.instance.tr('push_notifications')),
                    value: pushNotifications,
                    onChanged: (value) =>
                        setModalState(() => pushNotifications = value),
                    activeColor: _primaryGreen,
                  ),
                  SwitchListTile(
                    title: Text(AppSettings.instance.tr('online_status')),
                    value: showOnlineStatus,
                    onChanged: (value) =>
                        setModalState(() => showOnlineStatus = value),
                    activeColor: _primaryGreen,
                  ),
                  SwitchListTile(
                    title: Text(AppSettings.instance.tr('share_profile')),
                    value: shareProfileData,
                    onChanged: (value) =>
                        setModalState(() => shareProfileData = value),
                    activeColor: _primaryGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppSettings.instance.tr('privacy_policy'),
                    style: TextStyle(
                      color: _primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'View our privacy policy',
                      style: TextStyle(
                        color: _primaryGreen,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      _firestore
                          .collection('users')
                          .doc(_currentUser!.uid)
                          .update({
                        'privacySettings': {
                          'emailNotifications': emailNotifications,
                          'pushNotifications': pushNotifications,
                          'showOnlineStatus': showOnlineStatus,
                          'shareProfileData': shareProfileData,
                        },
                        'updatedAt': FieldValue.serverTimestamp(),
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy settings updated'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      AppSettings.instance.tr('save_settings'),
                      style: const TextStyle(color: Colors.white),
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

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => _buildResponsiveDialog(
        title: AppSettings.instance.tr('change_password'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppSettings.instance.tr('current_password'),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppSettings.instance.tr('new_password'),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppSettings.instance.tr('confirm_password'),
                    prefixIcon: const Icon(Icons.lock_reset),
                  ),
                  validator: (value) {
                    if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _isUploading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            _changePassword(
                              currentPasswordController.text,
                              newPasswordController.text,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          AppSettings.instance.tr('change_password'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppSettings.instance.tr('about_app')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  AppSettings.instance.tr('onboarding_subtitle'),
                  style: const TextStyle(height: 1.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Key Features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildFeatureListItem('Cleanliness reporting'),
                _buildFeatureListItem('Community engagement'),
                _buildFeatureListItem('Real-time updates'),
                _buildFeatureListItem('Educational resources'),
                const SizedBox(height: 16),
                const Text(
                  '© 2025 SwachhSathi Team',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppSettings.instance.tr('close')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.check_circle, size: 16, color: Colors.green),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppSettings.instance.tr('help_support')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'We\'re here to help you!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSupportOption(
                  icon: Icons.email,
                  title: 'Email Support',
                  subtitle: 'support@swachhsathi.com',
                  onTap: () {
                    Navigator.pop(context);
                    _launchEmailSupport();
                  },
                ),
                _buildSupportOption(
                  icon: Icons.phone,
                  title: 'Call Support',
                  subtitle: '+91 1800 123 4567',
                  onTap: () {
                    Navigator.pop(context);
                    _launchPhoneCall();
                  },
                ),
                _buildSupportOption(
                  icon: Icons.chat,
                  title: 'Live Chat',
                  subtitle: 'Available 9AM-5PM',
                  onTap: () {
                    Navigator.pop(context);
                    _openLiveChat();
                  },
                ),
                _buildSupportOption(
                  icon: Icons.help_center,
                  title: 'FAQs',
                  subtitle: 'Frequently asked questions',
                  onTap: () {
                    Navigator.pop(context);
                    _openFAQs();
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'For urgent issues, please call our support line.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppSettings.instance.tr('close')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.greenAccent : _primaryGreen;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  void _launchEmailSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@swachhsathi.com',
      queryParameters: {'subject': 'SwachhSathi Support Request'},
    );
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not launch email client')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _launchPhoneCall() async {
    const phoneNumber = 'tel:+9118001234567';
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (await canLaunchUrl(Uri.parse(phoneNumber))) {
        await launchUrl(Uri.parse(phoneNumber));
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not launch phone app')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _openLiveChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening live chat...')),
    );
  }

  void _openFAQs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('FAQs'),
          ),
          body: ListView(
            children: const [
              ExpansionTile(
                title: Text('How do I report an issue?'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('You can report issues via the request form in the app.'),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text('How do I edit my profile?'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Go to Account Settings to update your name, phone, and address.'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _preferenceOptions() {
    return [
      _buildSettingsTile(
        icon: Icons.language,
        title: AppSettings.instance.tr('language'),
        onTap: () => _showLanguageDialog(context),
        screenSize: MediaQuery.sizeOf(context),
      ),
      _buildSettingsTile(
        icon: Icons.dark_mode_outlined,
        title: AppSettings.instance.tr('theme'),
        onTap: () => _showThemeDialog(context),
        screenSize: MediaQuery.sizeOf(context),
      ),
    ];
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildResponsiveDialog(
        title: AppSettings.instance.tr('choose_theme'),
        content: _buildThemeOptions(),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildResponsiveDialog(
        title: AppSettings.instance.tr('choose_language'),
        content: _buildLanguageOptions(),
      ),
    );
  }

  Widget _buildResponsiveDialog({
    required String title,
    required Widget content,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallScreen = screenWidth < 360;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 24,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: _responsiveText(16, 18, 20, 1.0),
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOptions() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(AppSettings.instance.tr('light_mode')),
              value: ThemeMode.light,
              groupValue: AppSettings.instance.themeMode,
              activeColor: _primaryGreen,
              onChanged: (mode) {
                if (mode != null) {
                  AppSettings.instance.setThemeMode(mode);
                  setDialogState(() {});
                  setState(() {});
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppSettings.instance.tr('theme_updated')),
                      backgroundColor: _primaryGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(AppSettings.instance.tr('dark_mode')),
              value: ThemeMode.dark,
              groupValue: AppSettings.instance.themeMode,
              activeColor: _primaryGreen,
              onChanged: (mode) {
                if (mode != null) {
                  AppSettings.instance.setThemeMode(mode);
                  setDialogState(() {});
                  setState(() {});
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppSettings.instance.tr('theme_updated')),
                      backgroundColor: _primaryGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(AppSettings.instance.tr('system_default')),
              value: ThemeMode.system,
              groupValue: AppSettings.instance.themeMode,
              activeColor: _primaryGreen,
              onChanged: (mode) {
                if (mode != null) {
                  AppSettings.instance.setThemeMode(mode);
                  setDialogState(() {});
                  setState(() {});
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppSettings.instance.tr('theme_updated')),
                      backgroundColor: _primaryGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOptions() {
    final languages = [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'hi', 'name': 'Hindi', 'native': 'हिंदी'},
      {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
      {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
      {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
    ];

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.4,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          final isSelected =
              AppSettings.instance.currentLanguage == lang['code'];
          return ListTile(
            leading: Icon(
              isSelected ? Icons.check_circle : Icons.language,
              color: isSelected ? _primaryGreen : Colors.grey,
            ),
            title: Text(
              lang['name']!,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? _primaryGreen : null,
              ),
            ),
            subtitle: Text(lang['native']!),
            onTap: () {
              AppSettings.instance.setLanguage(lang['code']!);
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${AppSettings.instance.tr('language_updated')} ${lang['name']} (${lang['native']})'),
                  backgroundColor: _primaryGreen,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
