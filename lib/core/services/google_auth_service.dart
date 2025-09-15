import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taski/core/services/google_calendar_service.dart';
import 'package:taski/core/utils/navigator.dart';
import 'package:taski/main.dart';
import 'package:taski/presentation/features/dashboard/screens/dashboard_layout.dart';

class GoogleAuthService {

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static final firebaseAuth = FirebaseAuth.instance;

  static Future<void> signIn(BuildContext context) async {
    try {
      List<String> scopes = [
        'https://www.googleapis.com/auth/calendar',
        'openid',
        'email',
        'profile',
      ];

      final iosClientId = dotenv.env['IOS_CLIENT_ID'];
      final webClientId = dotenv.env['WEB_CLIENT_ID'];

      if (iosClientId == null || webClientId == null) {
        throw 'Google Sign-In configuration is missing. Please check your environment variables.';
      }

      _googleSignIn.initialize(
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      final googleUser = await _googleSignIn.authenticate(
        scopeHint: scopes,
      );
    

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Failed to get authentication token. Please try again.';
      }

      // Sign in to firebase with Google token
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );
      
      await firebaseAuth.signInWithCredential(credential);
 

      // // Sign in to Supabase with Google token
      // await supabase.auth.signInWithIdToken(
      //   provider: OAuthProvider.google,
      //   idToken: idToken,
      // );

      if (context.mounted) {
        try {
          await GoogleCalendarService.instance.listEvents();
        } catch (e) {
          // Calendar access failed, but user is still signed in
          print('Calendar access failed: $e');
        }
        pushAndRemoveUntil(const DashboardLayout());
      }

    } on GoogleSignInException catch (e) {
      String errorMessage;
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
          errorMessage = 'Sign-in was cancelled. Please try again.';
          break;
        default:
          errorMessage = 'Sign-in failed. Please try again.';
      }
      
      if (context.mounted) {
        _showErrorDialog(context, 'Google Sign-In Error', errorMessage);
      }
      
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('Account reauth failed')) {
        errorMessage = 'Account reauthorization failed. Please try signing in again or check your Google account settings.';
      } else if (e.toString().contains('No Access Token found')) {
        errorMessage = 'Authentication failed. Please try again.';
      } else {
        errorMessage = 'An unexpected error occurred: ${e.toString()}';
      }
      log('Error: $errorMessage');
      
      if (context.mounted) {
        _showErrorDialog(context, 'Authentication Error', errorMessage);
      }
    }
  }

  static void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Retry sign-in
                signIn(context);
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await firebaseAuth.signOut();
      await supabase.auth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }


}