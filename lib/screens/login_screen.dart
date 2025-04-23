import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_ledger/models/auth.dart';
import 'package:poker_ledger/providers/auth_provider.dart';
import 'package:poker_ledger/screens/club_selection_screen.dart';
import 'package:poker_ledger/screens/home_screen.dart';
import 'package:poker_ledger/screens/register_user_screen.dart';
import 'package:poker_ledger/theme/app_theme.dart';
import 'package:poker_ledger/widgets/custom_button.dart';
import 'package:poker_ledger/widgets/custom_text_field.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final AuthResponse response = await ref
            .read(authStateProvider.notifier)
            .login(_emailController.text.trim(), _passwordController.text);

        if (mounted && response.clubs.isNotEmpty) {
          // Navigate to club selection screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ClubSelectionScreen(clubs: response.clubs),
            ),
          );
        }
      } catch (e) {
        // Error is already handled in the auth notifier
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Redirect to club selection if authenticated and has clubs
    if (authState.isAuthenticated && authState.clubs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ClubSelectionScreen(clubs: authState.clubs),
          ),
        );
      });
    }
    // Redirect to home if authenticated but no clubs (fallback)
    else if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF121212), Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo and Title
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.casino,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'POKER LEDGER',
                      style: AppTheme.headlineLarge.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Track your poker games with style',
                          textStyle: AppTheme.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                    const SizedBox(height: 48),

                    // Admin Login Form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin Login', style: AppTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(
                            'Only admin users can log in to manage games',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email Field
                          CustomTextField(
                            label: 'Email',
                            hint: 'Enter your email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          CustomTextField(
                            label: 'Password',
                            hint: 'Enter your password',
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            prefixIcon: Icons.lock,
                            suffixIcon:
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                            onSuffixIconPressed: _togglePasswordVisibility,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Error Message
                          if (authState.error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.errorColor.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppTheme.errorColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authState.error!,
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppTheme.errorColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Login Button
                          CustomButton(
                            text: 'LOGIN',
                            onPressed: _login,
                            isLoading: authState.isLoading,
                            gradient: AppTheme.primaryGradient,
                            icon: Icons.login,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Register a New Club link
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterUserScreen(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_business,
                            color: AppTheme.accentColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Register a New Club',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
