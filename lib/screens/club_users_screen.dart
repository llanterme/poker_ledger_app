import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poker_ledger/models/club_user.dart';
import 'package:poker_ledger/providers/auth_provider.dart';
import 'package:poker_ledger/providers/club_provider.dart';
import 'package:poker_ledger/theme/app_theme.dart';
import 'package:poker_ledger/widgets/loading_indicator.dart';

// Use the existing apiServiceProvider from auth_provider.dart
final clubUsersProvider = FutureProvider.autoDispose
    .family<List<ClubUser>, int>((ref, clubId) async {
      final apiService = ref.watch(apiServiceProvider);
      return await apiService.getClubUsers(clubId);
    });

class ClubUsersScreen extends ConsumerWidget {
  const ClubUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubState = ref.watch(clubStateProvider);
    final currentClub = clubState.currentClub;

    if (currentClub == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Club Users')),
        body: const Center(child: Text('No club selected')),
      );
    }

    // Use the getCurrentClubId method to get a non-null club ID
    final clubId = ref.read(clubStateProvider.notifier).getCurrentClubId();
    final clubUsersAsync = ref.watch(clubUsersProvider(clubId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Users'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: clubUsersAsync.when(
        data: (clubUsers) => _buildUsersList(clubUsers),
        loading: () => const Center(child: LoadingIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Text(
                'Error loading club users: $error',
                style: AppTheme.bodyLarge.copyWith(color: AppTheme.errorColor),
                textAlign: TextAlign.center,
              ),
            ),
      ),
    );
  }

  Widget _buildUsersList(List<ClubUser> users) {
    if (users.isEmpty) {
      return Center(
        child: Text('No users found for this club', style: AppTheme.bodyLarge),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final dateFormat = DateFormat('MMM d, yyyy');
        final formattedDate = dateFormat.format(user.joinedOn);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      child: Text(
                        '${user.firstName[0]}${user.lastName[0]}',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: AppTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Joined: $formattedDate',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (user.isClubOwner)
                      _buildRoleBadge('Owner', AppTheme.accentColor),
                    if (user.isClubOwner && user.isAdmin)
                      const SizedBox(width: 8),
                    if (user.isAdmin)
                      _buildRoleBadge('Admin', AppTheme.primaryColor),
                    if (!user.isAdmin && !user.isClubOwner)
                      _buildRoleBadge('Member', Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(String role, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        role,
        style: AppTheme.labelLarge.copyWith(color: color, fontSize: 12),
      ),
    );
  }
}
