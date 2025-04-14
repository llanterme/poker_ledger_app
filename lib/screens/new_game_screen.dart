import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_ledger/models/game.dart';
import 'package:poker_ledger/providers/auth_provider.dart';
import 'package:poker_ledger/providers/game_provider.dart';
import 'package:poker_ledger/screens/game_detail_screen.dart';
import 'package:poker_ledger/theme/app_theme.dart';
import 'package:poker_ledger/widgets/custom_button.dart';
import 'package:poker_ledger/widgets/loading_indicator.dart';

class NewGameScreen extends ConsumerStatefulWidget {
  const NewGameScreen({super.key});

  @override
  ConsumerState<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends ConsumerState<NewGameScreen> {
  bool _isCreating = false;
  bool _isSuccess = false;
  Game? _createdGame;

  Future<void> _createGame() async {
    final authState = ref.read(authStateProvider);
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a game'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final createdGame = await ref.read(gamesProvider.notifier).createGame(
            authState.user!.id!,
          );

      if (createdGame != null) {
        setState(() {
          _isCreating = false;
          _isSuccess = true;
          _createdGame = createdGame;
        });

        // Wait for animation to complete before navigating
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => GameDetailScreen(gameId: createdGame.id!),
            ),
          );
        }
      } else {
        setState(() {
          _isCreating = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create game'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isCreating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Game'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isCreating) ...[
                const LoadingIndicator(
                  message: 'Creating new game...',
                  size: 60,
                ),
              ] else if (_isSuccess) ...[
                // Success animation
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.successColor.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Game Created Successfully!',
                  style: AppTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Game #${_createdGame?.id} has been created.\nRedirecting to game details...',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                // New game form
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.casino,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Start a New Poker Game',
                  style: AppTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ready to track your poker game? Create a new game session and start adding players and transactions.',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'CREATE GAME',
                  onPressed: _createGame,
                  gradient: AppTheme.accentGradient,
                  icon: Icons.add_circle,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'CANCEL',
                  onPressed: () => Navigator.of(context).pop(),
                  isOutlined: true,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'After creating a game, you\'ll be able to:',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem('Add players to the game'),
                      _buildInfoItem('Record buy-ins for each player'),
                      _buildInfoItem('Track end-game amounts'),
                      _buildInfoItem('View game summary and statistics'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.secondaryColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
