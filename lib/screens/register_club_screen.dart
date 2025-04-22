import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_ledger/models/user.dart';
import 'package:poker_ledger/models/user_club.dart';
import 'package:poker_ledger/providers/auth_provider.dart';
import 'package:poker_ledger/providers/club_provider.dart';
import 'package:poker_ledger/screens/home_screen.dart';
import 'package:poker_ledger/theme/app_theme.dart';
import 'package:poker_ledger/widgets/custom_button.dart';
import 'package:poker_ledger/widgets/custom_text_field.dart';

class RegisterClubScreen extends ConsumerStatefulWidget {
  final User? newUser;

  const RegisterClubScreen({Key? key, this.newUser}) : super(key: key);

  @override
  ConsumerState<RegisterClubScreen> createState() => _RegisterClubScreenState();
}

class _RegisterClubScreenState extends ConsumerState<RegisterClubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clubNameController = TextEditingController();
  bool _isRegistering = false;

  @override
  void dispose() {
    _clubNameController.dispose();
    super.dispose();
  }

  Future<void> _registerClub() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isRegistering = true;
      });

      try {
        // Create club using the newly registered user's ID
        final clubProvider = ref.read(clubStateProvider.notifier);
        final authNotifier = ref.read(authStateProvider.notifier);
        final userId = widget.newUser?.id;

        if (userId == null) {
          throw Exception('User ID is required to create a club');
        }

        final club = await clubProvider.createClub(
          _clubNameController.text.trim(),
          userId,
        );

        // Add this new club to the user's club list with admin privileges
        final authState = ref.read(authStateProvider);
        final userClub = UserClub(
          id: club.id!,
          clubName: club.clubName,
          isAdmin: true, // Creator is always an admin
          isClubOwner: true, // Creator is always the owner
        );

        // Update the clubs list with the new club
        final updatedClubs = [...authState.clubs, userClub];

        // Update the auth state with the updated clubs list
        await authNotifier.updateClubsList(updatedClubs);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Club "${club.clubName}" created successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );

          // Navigate to home screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create club: ${e.toString()}'),
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
      appBar: AppBar(title: const Text('Create Your Club')),
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
                        Icons.groups,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'CREATE YOUR CLUB',
                      style: AppTheme.headlineLarge.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set up your poker club to manage games and players',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Club Name Field
                    CustomTextField(
                      label: 'Club Name',
                      hint: 'Enter your club name',
                      controller: _clubNameController,
                      prefixIcon: Icons.business,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a club name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Create Club Button
                    CustomButton(
                      text: 'CREATE CLUB',
                      onPressed: _registerClub,
                      isLoading: _isRegistering,
                      gradient: AppTheme.primaryGradient,
                      icon: Icons.add_business,
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
