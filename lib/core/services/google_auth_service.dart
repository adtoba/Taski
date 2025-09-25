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

    await _googleSignIn.signOut(); 
    try {
      List<String> scopes = [     
        'https://www.googleapis.com/auth/userinfo.profile',
        'https://www.googleapis.com/auth/calendar',
        'https://www.googleapis.com/auth/gmail.send',   
        'openid',
        'email',
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
        
      // Request accessToken for gmail.send
      final bool needsInteraction = _googleSignIn.authorizationRequiresUserInteraction();

    String? accessToken;
    if (needsInteraction) {
      // Interactive authorization (prompts user)
      final GoogleSignInClientAuthorization? authorization = await googleUser
          .authorizationClient
          .authorizeScopes(scopes);
      accessToken = authorization?.accessToken;
    } else {
      // Silent authorization
      final GoogleSignInClientAuthorization? authorization = await googleUser
          .authorizationClient
          .authorizationForScopes(scopes);
      accessToken = authorization?.accessToken;
    }

    if (accessToken != null) {
      logger.i('Access Token: $accessToken');
      // Test the Gmail API
    } else {
      print('Failed to get access token');
    }
 

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
      logger.e("Error: $errorMessage");
      
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
      await GoogleSignIn.instance.signOut();
      await GoogleSignIn.instance.disconnect();
      await firebaseAuth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }


}