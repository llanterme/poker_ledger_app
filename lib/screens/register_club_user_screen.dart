import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_ledger/models/user.dart';
import 'package:poker_ledger/providers/auth_provider.dart';
import 'package:poker_ledger/providers/club_provider.dart';
import 'package:poker_ledger/theme/app_theme.dart';
import 'package:poker_ledger/widgets/custom_button.dart';
import 'package:poker_ledger/widgets/custom_text_field.dart';

class RegisterClubUserScreen extends ConsumerStatefulWidget {
  const RegisterClubUserScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterClubUserScreen> createState() => _RegisterClubUserScreenState();
}

class _RegisterClubUserScreenState extends ConsumerState<RegisterClubUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isAdmin = false;
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

  Future<void> _registerClubUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isRegistering = true;
      });

      try {
        // Get current club ID
        final clubState = ref.read(clubStateProvider);
        final clubId = clubState.currentClub?.id;
        
        if (clubId == null) {
          throw Exception('No club selected. Please select a club first.');
        }
        
        // Create user with club ID
        final apiService = ref.read(apiServiceProvider);
        final newUser = await apiService.createUser(
          User(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            isAdmin: _isAdmin,
            password: _passwordController.text,
          ),
          clubId: clubId,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User ${newUser.fullName} created successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );

          // Clear form
          _formKey.currentState!.reset();
          _firstNameController.clear();
          _lastNameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          setState(() {
            _isAdmin = false;
          });
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
    final clubState = ref.watch(clubStateProvider);
    final clubName = clubState.currentClub?.clubName ?? 'Your Club';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Club User'),
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
                      'ADD USER TO $clubName',
                      style: AppTheme.headlineMedium.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Register a new user for your club',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // First Name Field
                    CustomTextField(
                      label: 'First Name',
                      hint: 'Enter first name',
                      controller: _firstNameController,
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Last Name Field
                    CustomTextField(
                      label: 'Last Name',
                      hint: 'Enter last name',
                      controller: _lastNameController,
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Email Field
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter email address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
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
                      hint: 'Enter password',
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
                      hint: 'Confirm password',
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      onSuffixIconPressed: _toggleConfirmPasswordVisibility,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Admin Checkbox
                    CheckboxListTile(
                      title: const Text('Admin User', style: TextStyle(color: Colors.white)),
                      value: _isAdmin,
                      onChanged: (value) {
                        setState(() {
                          _isAdmin = value ?? false;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                      checkColor: Colors.white,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 32),
                    
                    // Register Button
                    CustomButton(
                      text: 'REGISTER USER',
                      onPressed: _registerClubUser,
                      isLoading: _isRegistering,
                      gradient: AppTheme.primaryGradient,
                      icon: Icons.person_add,
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
