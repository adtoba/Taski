import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taski/core/services/google_auth_service.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';
import 'package:taski/presentation/features/dashboard/screens/dashboard_layout.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String? userId;
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }
  
  Future<void> _checkAuth() async {
    supabase.auth.onAuthStateChange.listen((event) {
      setState(() {
        userId = event.session?.user.id;
      });
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      await GoogleAuthService.signIn(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: config.sw(24)),
          child: Column(
            children: [
              // Top section with logo and hero text
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      padding: EdgeInsets.all(config.sw(24)),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.task_alt,
                        size: config.sw(80),
                        color: Colors.blue.shade600,
                      ),
                    ),
                    YMargin(40),
                    
                    // Hero title
                    Text(
                      "Welcome to Taski",
                      style: textTheme.headlineLarge?.copyWith(
                        fontSize: config.sp(32),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    YMargin(12),
                    
                    // Subtitle
                    Text(
                      "Your AI-powered productivity companion",
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: config.sp(16),
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    Text(
                      userId != null ? "Logged in as $userId" : "Not logged in",
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: config.sp(16),
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Bottom section with auth button
              Column(
                children: [
                  // Google Sign In Button
                  Container(
                    width: double.infinity,
                    height: config.sh(56),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.black : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _isSigningIn ? null : _handleGoogleSignIn,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: config.sw(20)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/pngs/google.png",
                                width: config.sw(24),
                                height: config.sh(24),
                              ),
                              XMargin(12),
                              _isSigningIn
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          isDark ? Colors.white : Colors.blue.shade600,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "Continue with Google",
                                      style: textTheme.titleMedium?.copyWith(
                                        fontSize: config.sp(16),
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  YMargin(24),
                  
                  // Terms and Privacy
                  Text(
                    "By continuing, you agree to our Terms of Service and Privacy Policy",
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: config.sp(12),
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  YMargin(32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
