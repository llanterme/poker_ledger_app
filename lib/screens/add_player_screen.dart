import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_ledger/models/user.dart';
import 'package:poker_ledger/providers/game_provider.dart';
import 'package:poker_ledger/theme/app_theme.dart';
import 'package:poker_ledger/widgets/custom_button.dart';
import 'package:poker_ledger/widgets/loading_indicator.dart';

class AddPlayerScreen extends ConsumerStatefulWidget {
  final int gameId;

  const AddPlayerScreen({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends ConsumerState<AddPlayerScreen> {
  bool _isLoading = false;
  List<User> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadUsers());
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all users
      await ref.read(usersProvider.notifier).loadUsers();
      
      // Load game users to know which users are already in the game
      await ref.read(gameUsersProvider.notifier).loadGameUsers(widget.gameId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addSelectedPlayersToGame() async {
    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one player'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create a local copy of the users to add
      final usersToAdd = List<User>.from(_selectedUsers);
      
      // Add each user to the game with a small delay between operations
      for (final user in usersToAdd) {
        await ref.read(gameUsersProvider.notifier).addUserToGame(
              widget.gameId,
              user.id!,
            );
        // Add a small delay between operations to avoid state conflicts
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedUsers.length == 1
                  ? '1 player added to the game'
                  : '${_selectedUsers.length} players added to the game',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Return success result and close the screen
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding players: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _toggleUserSelection(User user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersProvider);
    final gameUsersState = ref.watch(gameUsersProvider);
    
    // Get list of user IDs already in the game
    final existingUserIds = gameUsersState.gameUsers.map((gu) => gu.userId).toList();
    
    // Filter out users already in the game
    final availableUsers = usersState.users
        .where((user) => !existingUserIds.contains(user.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Players'),
      ),
      body: _isLoading || usersState.isLoading || gameUsersState.isLoading
          ? const LoadingIndicator(message: 'Loading users...')
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Select players to add to the game',
                    style: AppTheme.titleMedium,
                  ),
                ),
                if (availableUsers.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No more players available to add',
                            style: AppTheme.titleMedium.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: availableUsers.length,
                      itemBuilder: (context, index) {
                        final user = availableUsers[index];
                        final isSelected = _selectedUsers.contains(user);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            onTap: () => _toggleUserSelection(user),
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.surfaceColor,
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      user.firstName[0] + user.lastName[0],
                                      style: AppTheme.labelLarge,
                                    ),
                            ),
                            title: Text(
                              user.fullName,
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              user.email,
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggleUserSelection(user),
                              activeColor: AppTheme.primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_selectedUsers.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Selected ${_selectedUsers.length} player${_selectedUsers.length == 1 ? '' : 's'}',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'CANCEL',
                              onPressed: () => Navigator.of(context).pop(),
                              isOutlined: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomButton(
                              text: 'ADD PLAYERS',
                              onPressed: _addSelectedPlayersToGame,
                              isLoading: _isLoading,
                              gradient: AppTheme.primaryGradient,
                              icon: Icons.add_circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
