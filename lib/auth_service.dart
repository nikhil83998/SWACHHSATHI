import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleSignIn? _googleSignIn;
  GoogleSignIn get googleSignIn => _googleSignIn ??= GoogleSignIn();

  // Sign up with email, password, and additional user data
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(), // Optional: Add a timestamp
      });
    } catch (e) {
      debugPrint("Error during signup: $e");
      rethrow; // Rethrow the error to handle it in the UI
    }
  }

  // Log in with email and password
  Future<UserCredential> logIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      debugPrint("Error during login: $e");
      rethrow; // Rethrow the error to handle it in the UI
    }
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Trigger the authentication flow for Mobile (Android/iOS)
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        // If user cancels the sign-in flow
        if (googleUser == null) {
          throw Exception('Google sign in was cancelled by user');
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        userCredential = await _auth.signInWithCredential(credential);
      }

      // Check if it's a new user and save data to Firestore if needed
      final user = userCredential.user;
      if (user != null) {
        final userDocRef = _firestore.collection('users').doc(user.uid);
        final userDoc = await userDocRef.get();

        if (!userDoc.exists) {
          String displayName = user.displayName ?? '';
          List<String> nameParts = displayName.trim().split(' ');
          String firstName = nameParts.isNotEmpty ? nameParts.first : '';
          String lastName =
              nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

          // Save basic user profile from Google to Firestore
          await userDocRef.set({
            'email': user.email ?? '',
            'username':
                user.displayName ?? user.email?.split('@').first ?? 'User',
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': user.phoneNumber ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } catch (e) {
      debugPrint("Error during Google sign in: $e");
      rethrow; // Rethrow the error to handle it in the UI
    }
  }

  // Fetch user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      return null;
    }
  }

  // Get the current user's UID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Sign out the user
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in with Google
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }

      // Sign out from Facebook if signed in with Facebook
      try {
        await FacebookAuth.instance.logOut();
      } catch (e) {
        debugPrint("Facebook sign out skipped: $e");
      }

      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error during sign out: $e");
      rethrow; // Rethrow the error to handle it in the UI
    }
  }
}
