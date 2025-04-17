import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_ledger/models/game.dart';
import 'package:poker_ledger/providers/auth_provider.dart';
import 'package:poker_ledger/providers/club_provider.dart';
import 'package:poker_ledger/providers/game_provider.dart';
import 'package:poker_ledger/screens/game_detail_screen.dart';
import 'package:poker_ledger/screens/login_screen.dart';
import 'package:poker_ledger/screens/new_game_screen.dart';
import 'package:poker_ledger/screens/register_club_user_screen.dart';
import 'package:poker_ledger/theme/app_theme.dart';
import 'package:poker_ledger/widgets/custom_button.dart';
import 'package:poker_ledger/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load games when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clubState = ref.read(clubStateProvider);
      if (clubState.currentClub != null) {
        ref.read(gamesProvider.notifier).loadGames(clubId: clubState.currentClub!.id);
      } else {
        // If no club is selected, try to load clubs first
        ref.read(clubStateProvider.notifier).loadClubs().then((_) {
          final updatedClubState = ref.read(clubStateProvider);
          if (updatedClubState.currentClub != null) {
            ref.read(gamesProvider.notifier).loadGames(clubId: updatedClubState.currentClub!.id);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() async {
    await ref.read(authStateProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _navigateToNewGame() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const NewGameScreen()));
  }

  void _navigateToGameDetail(Game game) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameDetailScreen(gameId: game.id!),
      ),
    );
  }

  void _navigateToRegisterClubUser() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterClubUserScreen()),
    );
  }

  Widget _buildDrawer(AuthState authState, bool isAdmin) {
    final clubState = ref.watch(clubStateProvider);
    final currentClub = clubState.currentClub;
    final clubName = currentClub?.clubName ?? 'Your Club';

    return Drawer(
      child: Container(
        color: AppTheme.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.casino, size: 25, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    clubName,
                    style: AppTheme.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (authState.user != null)
                    Text(
                      authState.user!.fullName,
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    isAdmin ? 'Admin' : 'Member',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isAdmin) ...[
              ListTile(
                leading: const Icon(
                  Icons.person_add,
                  color: AppTheme.accentColor,
                ),
                title: const Text('Register Club User'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  _navigateToRegisterClubUser();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.add_circle,
                  color: AppTheme.primaryColor,
                ),
                title: const Text('Create New Game'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  _navigateToNewGame();
                },
              ),
            ],
            const Divider(color: Colors.white24),
            ListTile(
              leading: Icon(
                authState.isAuthenticated ? Icons.logout : Icons.login,
                color: Colors.white70,
              ),
              title: Text(
                authState.isAuthenticated ? 'Logout' : 'Login',
                style: AppTheme.bodyLarge.copyWith(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                if (authState.isAuthenticated) {
                  _logout();
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final gamesState = ref.watch(gamesProvider);
    final isAdmin = authState.user?.isAdmin ?? false;

    final openGames =
        gamesState.games
            .where((game) => game.status == GameStatus.open)
            .toList();
    final closedGames =
        gamesState.games
            .where((game) => game.status == GameStatus.closed)
            .toList();

    return Scaffold(
      drawer: _buildDrawer(authState, isAdmin),
      appBar: AppBar(
        title: const Text('Poker Ledger'),
        actions: [
          if (authState.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          if (!authState.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              tooltip: 'Login',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'ACTIVE GAMES'), Tab(text: 'COMPLETED GAMES')],
          labelStyle: AppTheme.labelLarge,
          unselectedLabelStyle: AppTheme.labelLarge.copyWith(
            fontWeight: FontWeight.normal,
          ),
          indicatorColor: AppTheme.secondaryColor,
          indicatorWeight: 3,
        ),
      ),
      body:
          gamesState.isLoading
              ? const LoadingIndicator(message: 'Loading games...')
              : TabBarView(
                controller: _tabController,
                children: [
                  // Active Games Tab
                  _buildGamesList(openGames, isAdmin, true),

                  // Completed Games Tab
                  _buildGamesList(closedGames, isAdmin, false),
                ],
              ),
      floatingActionButton:
          isAdmin
              ? FloatingActionButton.extended(
                onPressed: _navigateToNewGame,
                icon: const Icon(Icons.add),
                label: const Text('NEW GAME'),
                backgroundColor: AppTheme.accentColor,
              )
              : null,
    );
  }

  Widget _buildGamesList(List<Game> games, bool isAdmin, bool isActive) {
    if (games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.casino : Icons.history,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active games found' : 'No completed games found',
              style: AppTheme.titleMedium.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            if (isAdmin && isActive)
              CustomButton(
                text: 'Create New Game',
                onPressed: _navigateToNewGame,
                isFullWidth: false,
                icon: Icons.add,
                gradient: AppTheme.accentGradient,
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
        final formattedDate =
            game.createdAt != null
                ? dateFormat.format(game.createdAt!)
                : 'Date unknown';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color:
                  isActive
                      ? AppTheme.primaryColor.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () => _navigateToGameDetail(game),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Game #${game.id}', style: AppTheme.titleLarge),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isActive
                                  ? AppTheme.successColor.withOpacity(0.2)
                                  : AppTheme.errorColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isActive
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isActive ? 'ACTIVE' : 'COMPLETED',
                          style: AppTheme.labelLarge.copyWith(
                            color:
                                isActive
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Created: $formattedDate',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Created by: ${game.createdByName ?? 'User #${game.createdBy}'}',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
