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

  static Future<void> signIn(BuildContext context) async {
    List<String> scopes = [
      'https://www.googleapis.com/auth/calendar',
      'openid',
      'email',
      'profile',
    ];

    final iosClientId = dotenv.env['IOS_CLIENT_ID'];
    final webClientId = dotenv.env['WEB_CLIENT_ID'];

    _googleSignIn.initialize(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    final googleUser = await _googleSignIn.authenticate(scopeHint: scopes);
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw 'No Access Token found.';
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    if (context.mounted) {
      GoogleCalendarService.instance.listEvents();
      pushAndRemoveUntil(const DashboardLayout());
    }

  }
}