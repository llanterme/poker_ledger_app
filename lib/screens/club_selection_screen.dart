import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_ledger/models/user_club.dart';
import 'package:poker_ledger/providers/club_provider.dart';
import 'package:poker_ledger/screens/home_screen.dart';
import 'package:poker_ledger/theme/app_theme.dart';
import 'package:poker_ledger/widgets/custom_button.dart';
import 'package:poker_ledger/widgets/loading_indicator.dart';

class ClubSelectionScreen extends ConsumerStatefulWidget {
  final List<UserClub> clubs;

  const ClubSelectionScreen({super.key, required this.clubs});

  @override
  ConsumerState<ClubSelectionScreen> createState() =>
      _ClubSelectionScreenState();
}

class _ClubSelectionScreenState extends ConsumerState<ClubSelectionScreen> {
  UserClub? _selectedClub;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If there's only one club, preselect it
    if (widget.clubs.length == 1) {
      _selectedClub = widget.clubs.first;
    }
  }

  Future<void> _selectClub() async {
    if (_selectedClub == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a club to continue'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the club details from the API
      final clubNotifier = ref.read(clubStateProvider.notifier);
      final club = await clubNotifier.getClubById(_selectedClub!.id);

      // Set it as the current club
      clubNotifier.setCurrentClub(club);

      if (mounted) {
        // Navigate to the home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting club: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Club'),
        automaticallyImplyLeading: false, // Disable back button
      ),
      body:
          _isLoading
              ? const LoadingIndicator(message: 'Setting up your club...')
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Please select a club to continue:',
                      style: AppTheme.titleMedium,
                    ),
                    SizedBox(height: 24),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.clubs.length,
                        itemBuilder: (context, index) {
                          final club = widget.clubs[index];
                          final isSelected = _selectedClub?.id == club.id;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color:
                                    isSelected
                                        ? AppTheme.primaryColor
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedClub = club;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? AppTheme.primaryColor
                                                : AppTheme.surfaceColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child:
                                          isSelected
                                              ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                              )
                                              : Icon(
                                                Icons.groups,
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                              ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            club.clubName,
                                            style: AppTheme.titleMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              if (club.isClubOwner)
                                                _buildRoleBadge(
                                                  'Owner',
                                                  AppTheme.successColor,
                                                ),
                                              if (club.isClubOwner &&
                                                  club.isAdmin)
                                                const SizedBox(width: 8),
                                              if (club.isAdmin &&
                                                  !club.isClubOwner)
                                                _buildRoleBadge(
                                                  'Admin',
                                                  AppTheme.primaryColor,
                                                ),
                                              if (!club.isAdmin &&
                                                  !club.isClubOwner)
                                                _buildRoleBadge(
                                                  'Member',
                                                  Colors.grey,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Radio<UserClub>(
                                      value: club,
                                      groupValue: _selectedClub,
                                      onChanged: (UserClub? value) {
                                        setState(() {
                                          _selectedClub = value;
                                        });
                                      },
                                      activeColor: AppTheme.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'CONTINUE',
                      onPressed: _selectClub,
                      gradient: AppTheme.primaryGradient,
                      icon: Icons.arrow_forward,
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildRoleBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
