import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_ledger/models/user.dart';
import 'package:poker_ledger/providers/auth_provider.dart';
import 'package:poker_ledger/screens/register_club_screen.dart';
import 'package:poker_ledger/theme/app_theme.dart';
import 'package:poker_ledger/widgets/custom_button.dart';
import 'package:poker_ledger/widgets/custom_text_field.dart';

class RegisterUserScreen extends ConsumerStatefulWidget {
  const RegisterUserScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends ConsumerState<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isRegistering = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isRegistering = true;
      });

      try {
        // Create user
        final apiService = ref.read(apiServiceProvider);
        final newUser = await apiService.createUser(
          User(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            isAdmin: true,
            password: _passwordController.text,
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User ${newUser.fullName} created successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );

          // Navigate to club registration screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RegisterClubScreen(newUser: newUser),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to register user: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isRegistering = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF121212),
              Color(0xFF1E1E1E),
              Color(0xFF2C2C2C),
            ],
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
                    // Icon and Title
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
                        Icons.person_add,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'CREATE ACCOUNT',
                      style: AppTheme.headlineLarge.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Register as a club admin to manage poker games',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // First Name Field
                    CustomTextField(
                      label: 'First Name',
                      hint: 'Enter your first name',
                      controller: _firstNameController,
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Last Name Field
                    CustomTextField(
                      label: 'Last Name',
                      hint: 'Enter your last name',
                      controller: _lastNameController,
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Email Field
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email address';
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
                      suffixIcon: _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      onSuffixIconPressed: _togglePasswordVisibility,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Confirm Password Field
                    CustomTextField(
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      onSuffixIconPressed: _toggleConfirmPasswordVisibility,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Register Button
                    CustomButton(
                      text: 'REGISTER',
                      onPressed: _registerUser,
                      isLoading: _isRegistering,
                      gradient: AppTheme.primaryGradient,
                      icon: Icons.app_registration,
                    ),
                    
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Already have an account? Login',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.secondaryColor,
                          decoration: TextDecoration.underline,
                        ),
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
