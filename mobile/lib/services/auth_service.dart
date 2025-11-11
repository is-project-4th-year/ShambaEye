import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String fullName;
  final String location;
  final double farmSize;
  final String preferredLanguage;

  UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.location,
    required this.farmSize,
    required this.preferredLanguage,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'location': location,
      'farmSize': farmSize,
      'preferredLanguage': preferredLanguage,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      location: map['location'] ?? '',
      farmSize: (map['farmSize'] ?? 0.0).toDouble(),
      preferredLanguage: map['preferredLanguage'] ?? 'English',
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to track authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

Future<void> createUserProfile(UserProfile profile) async {
  try {
    print('🔄 Creating user profile in Firestore: ${profile.uid}');
    print('📝 Profile data: ${profile.toMap()}');
    
    await _firestore
        .collection('users')
        .doc(profile.uid)
        .set(profile.toMap());
        
    print('✅ User profile created successfully in Firestore');
  } catch (e) {
    print('❌ Failed to create user profile in Firestore: $e');
    throw Exception('Failed to create user profile: $e');
  }
}

  Future<UserProfile?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
Future<bool> isUserLoggedIn() async {
  try {
    final user = _auth.currentUser;
    final isLoggedIn = user != null;
    print('🔐 Firebase current user: ${user?.uid}');
    print('🔐 Is user logged in: $isLoggedIn');
    return isLoggedIn;
  } catch (e) {
    print('❌ Error checking login status: $e');
    return false;
  }
}

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Email address is invalid.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  // Password reset functionality
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }
}