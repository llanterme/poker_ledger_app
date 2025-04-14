import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poker_ledger/models/game.dart';
import 'package:poker_ledger/models/transaction.dart';
import 'package:poker_ledger/models/user.dart';
import 'package:poker_ledger/providers/auth_provider.dart';
import 'package:poker_ledger/providers/game_provider.dart';
import 'package:poker_ledger/screens/add_player_screen.dart';
import 'package:poker_ledger/screens/add_transaction_screen.dart';
import 'package:poker_ledger/theme/app_theme.dart';
import 'package:poker_ledger/widgets/custom_button.dart';
import 'package:poker_ledger/widgets/loading_indicator.dart';

class GameDetailScreen extends ConsumerStatefulWidget {
  final int gameId;

  const GameDetailScreen({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends ConsumerState<GameDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isClosingGame = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load game data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGameData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadGameData() async {
    // Load game details
    await ref.read(currentGameProvider.notifier).loadGame(widget.gameId);
    
    // Load game users
    await ref.read(gameUsersProvider.notifier).loadGameUsers(widget.gameId);
    
    // Load game transactions
    await ref.read(gameTransactionsProvider.notifier).loadTransactions(widget.gameId);
    
    // If game is closed, load summary
    final gameState = ref.read(currentGameProvider);
    if (gameState.game?.status == GameStatus.closed) {
      await ref.read(currentGameProvider.notifier).loadGameSummary(widget.gameId);
    }
  }
  
  void _navigateToAddPlayer() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPlayerScreen(gameId: widget.gameId),
      ),
    );
    
    if (result == true) {
      // Reload game users if a player was added
      await ref.read(gameUsersProvider.notifier).loadGameUsers(widget.gameId);
    }
  }
  
  void _navigateToAddTransaction(User user) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          gameId: widget.gameId,
          userId: user.id!,
          userName: user.fullName,
        ),
      ),
    );
    
    if (result == true) {
      // Reload game transactions if a transaction was added
      await ref.read(gameTransactionsProvider.notifier).loadTransactions(widget.gameId);
    }
  }
  
  Future<void> _closeGame() async {
    final gameState = ref.read(currentGameProvider);
    if (gameState.game == null) return;
    
    // Check if all players have end game amounts
    final transactionsState = ref.read(gameTransactionsProvider);
    final gameUsersState = ref.read(gameUsersProvider);
    
    final allUserIds = gameUsersState.gameUsers.map((gu) => gu.userId).toList();
    final usersWithEndAmounts = transactionsState.transactions
        .where((t) => t.type == TransactionType.gameEndAmount)
        .map((t) => t.userId)
        .toList();
    
    final missingEndAmounts = allUserIds.where((id) => !usersWithEndAmounts.contains(id)).toList();
    
    if (missingEndAmounts.isNotEmpty) {
      final missingUsers = missingEndAmounts.map((id) {
        final user = gameUsersState.userDetails[id];
        return user?.fullName ?? 'User #$id';
      }).join(', ');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot close game: Missing end amounts for $missingUsers'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    // Show confirmation dialog
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Game'),
        content: const Text(
          'Are you sure you want to close this game? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('CLOSE GAME'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!shouldClose) return;
    
    setState(() {
      _isClosingGame = true;
    });
    
    try {
      await ref.read(currentGameProvider.notifier).closeGame();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Game closed successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to close game: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isClosingGame = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final gameState = ref.watch(currentGameProvider);
    final gameUsersState = ref.watch(gameUsersProvider);
    final transactionsState = ref.watch(gameTransactionsProvider);
    
    final isAdmin = authState.user?.isAdmin ?? false;
    final isLoading = gameState.isLoading || gameUsersState.isLoading || transactionsState.isLoading;
    final game = gameState.game;
    final isGameClosed = game?.status == GameStatus.closed;
    
    // Group transactions by user
    final transactionsByUser = <int, List<Transaction>>{};
    for (final transaction in transactionsState.transactions) {
      if (!transactionsByUser.containsKey(transaction.userId)) {
        transactionsByUser[transaction.userId] = [];
      }
      transactionsByUser[transaction.userId]!.add(transaction);
    }
    
    // Calculate totals for each user
    final userTotals = <int, Map<String, double>>{};
    for (final userId in transactionsByUser.keys) {
      final transactions = transactionsByUser[userId]!;
      
      double buyInTotal = 0;
      double endAmount = 0;
      
      for (final transaction in transactions) {
        if (transaction.type == TransactionType.buyIn || transaction.type == TransactionType.addOn) {
          buyInTotal += transaction.amount;
        } else if (transaction.type == TransactionType.gameEndAmount) {
          endAmount = transaction.amount;
        }
      }
      
      userTotals[userId] = {
        'buyInTotal': buyInTotal,
        'endAmount': endAmount,
        'netProfit': endAmount - buyInTotal,
      };
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(game != null ? 'Game #${game.id}' : 'Game Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'PLAYERS'),
            Tab(text: 'SUMMARY'),
          ],
          labelStyle: AppTheme.labelLarge,
          unselectedLabelStyle: AppTheme.labelLarge.copyWith(
            fontWeight: FontWeight.normal,
          ),
          indicatorColor: AppTheme.secondaryColor,
          indicatorWeight: 3,
        ),
      ),
      body: isLoading
          ? const LoadingIndicator(message: 'Loading game data...')
          : game == null
              ? const Center(child: Text('Game not found'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Players Tab
                    _buildPlayersTab(
                      gameUsersState,
                      transactionsByUser,
                      userTotals,
                      isAdmin,
                      isGameClosed,
                    ),
                    
                    // Summary Tab
                    _buildSummaryTab(
                      gameState,
                      gameUsersState,
                      userTotals,
                      isGameClosed,
                    ),
                  ],
                ),
      bottomNavigationBar: isLoading || game == null
          ? null
          : _buildBottomBar(isAdmin, isGameClosed),
    );
  }
  
  Widget _buildPlayersTab(
    GameUsersState gameUsersState,
    Map<int, List<Transaction>> transactionsByUser,
    Map<int, Map<String, double>> userTotals,
    bool isAdmin,
    bool isGameClosed,
  ) {
    if (gameUsersState.gameUsers.isEmpty) {
      return Center(
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
              'No players in this game yet',
              style: AppTheme.titleMedium.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            if (isAdmin && !isGameClosed)
              CustomButton(
                text: 'Add Player',
                onPressed: _navigateToAddPlayer,
                isFullWidth: false,
                icon: Icons.person_add,
                gradient: AppTheme.secondaryGradient,
              ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: gameUsersState.gameUsers.length,
      itemBuilder: (context, index) {
        final gameUser = gameUsersState.gameUsers[index];
        final user = gameUsersState.userDetails[gameUser.userId];
        
        if (user == null) {
          return const SizedBox.shrink();
        }
        
        final transactions = transactionsByUser[user.id] ?? [];
        final totals = userTotals[user.id] ?? {
          'buyInTotal': 0.0,
          'endAmount': 0.0,
          'netProfit': 0.0,
        };
        
        final buyInTotal = totals['buyInTotal'] ?? 0.0;
        final endAmount = totals['endAmount'] ?? 0.0;
        final netProfit = totals['netProfit'] ?? 0.0;
        
        final hasEndAmount = transactions.any((t) => t.type == TransactionType.gameEndAmount);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        user.fullName,
                        style: AppTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isAdmin && !isGameClosed)
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: AppTheme.accentColor),
                        onPressed: () => _navigateToAddTransaction(user),
                        tooltip: 'Add Transaction',
                      ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                
                // Transactions summary
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAmountDisplay(
                          'Total Buy-ins',
                          '\$${buyInTotal.toStringAsFixed(2)}',
                          AppTheme.secondaryColor,
                        ),
                        if (hasEndAmount)
                          _buildAmountDisplay(
                            'End Amount',
                            '\$${endAmount.toStringAsFixed(2)}',
                            endAmount >= 0 ? AppTheme.primaryColor : AppTheme.errorColor,
                          ),
                      ],
                    ),
                    
                    if (hasEndAmount) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: netProfit >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Game Result Calculation:',
                              style: AppTheme.labelLarge.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              'End Amount:',
                              '\$${endAmount.toStringAsFixed(2)}',
                              valueColor: endAmount >= 0 ? AppTheme.primaryColor : AppTheme.errorColor,
                            ),
                            _buildInfoRow(
                              'Total Buy-ins:',
                              '-\$${buyInTotal.toStringAsFixed(2)}',
                              valueColor: AppTheme.secondaryColor,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              'Net Profit:',
                              '\$${netProfit.toStringAsFixed(2)}',
                              valueColor: netProfit >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                Text(
                  'Transactions',
                  style: AppTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                
                // Transaction list
                if (transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No transactions yet',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ...transactions.map((transaction) {
                    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
                    final formattedDate = transaction.createdAt != null
                        ? dateFormat.format(transaction.createdAt!)
                        : 'Date unknown';
                    
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: _getTransactionColor(transaction.type).withOpacity(0.2),
                        child: Icon(
                          _getTransactionIcon(transaction.type),
                          color: _getTransactionColor(transaction.type),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        _getTransactionTitle(transaction.type),
                        style: AppTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        formattedDate,
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      trailing: Text(
                        '\$${transaction.amount.toStringAsFixed(2)}',
                        style: AppTheme.titleMedium.copyWith(
                          color: _getTransactionColor(transaction.type),
                        ),
                      ),
                    );
                  }).toList(),
                
                if (isAdmin && !isGameClosed && !hasEndAmount)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: CustomButton(
                      text: 'Add End Amount',
                      onPressed: () => _navigateToAddTransaction(user),
                      gradient: AppTheme.primaryGradient,
                      icon: Icons.monetization_on,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSummaryTab(
    CurrentGameState gameState,
    GameUsersState gameUsersState,
    Map<int, Map<String, double>> userTotals,
    bool isGameClosed,
  ) {
    final game = gameState.game!;
    final summary = gameState.summary;
    
    // Calculate total buy-ins and total end amounts
    double totalBuyIns = 0;
    double totalEndAmounts = 0;
    
    userTotals.forEach((userId, totals) {
      totalBuyIns += totals['buyInTotal'] ?? 0;
      totalEndAmounts += totals['endAmount'] ?? 0;
    });
    
    // Format dates
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final createdDate = game.createdAt != null
        ? dateFormat.format(game.createdAt!)
        : 'Unknown';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game info card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Game #${game.id}',
                        style: AppTheme.titleLarge,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isGameClosed
                              ? AppTheme.errorColor.withOpacity(0.2)
                              : AppTheme.successColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isGameClosed
                                ? AppTheme.errorColor
                                : AppTheme.successColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isGameClosed ? 'CLOSED' : 'ACTIVE',
                          style: AppTheme.labelLarge.copyWith(
                            color: isGameClosed
                                ? AppTheme.errorColor
                                : AppTheme.successColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Created', createdDate),
                  if (summary?.closedAt != null)
                    _buildInfoRow('Closed', dateFormat.format(summary!.closedAt!)),
                  _buildInfoRow('Created By', 'User #${game.createdBy}'),
                  _buildInfoRow('Players', '${gameUsersState.gameUsers.length}'),
                  const Divider(height: 32),
                  _buildInfoRow(
                    'Total Buy-ins',
                    '\$${totalBuyIns.toStringAsFixed(2)}',
                    valueColor: AppTheme.secondaryColor,
                  ),
                  _buildInfoRow(
                    'Total End Amounts',
                    '\$${totalEndAmounts.toStringAsFixed(2)}',
                    valueColor: AppTheme.primaryColor,
                  ),
                  _buildInfoRow(
                    'Difference',
                    '\$${(totalEndAmounts - totalBuyIns).toStringAsFixed(2)}',
                    valueColor: totalEndAmounts >= totalBuyIns
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Text(
            'Player Results',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          // Player results
          if (gameUsersState.gameUsers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No players in this game yet',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            )
          else
            ...gameUsersState.gameUsers.map((gameUser) {
              final user = gameUsersState.userDetails[gameUser.userId];
              if (user == null) return const SizedBox.shrink();
              
              final totals = userTotals[user.id] ?? {
                'buyInTotal': 0.0,
                'endAmount': 0.0,
                'netProfit': 0.0,
              };
              
              final buyInTotal = totals['buyInTotal'] ?? 0.0;
              final endAmount = totals['endAmount'] ?? 0.0;
              final netProfit = totals['netProfit'] ?? 0.0;
              
              final hasEndAmount = endAmount > 0;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: netProfit >= 0
                              ? AppTheme.successColor.withOpacity(0.2)
                              : AppTheme.errorColor.withOpacity(0.2),
                          child: Icon(
                            netProfit >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                            color: netProfit >= 0 ? AppTheme.successColor : AppTheme.errorColor,
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
                              if (hasEndAmount)
                                Text(
                                  netProfit >= 0 ? 'Won' : 'Lost',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: netProfit >= 0
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (hasEndAmount)
                          Text(
                            '\$${netProfit.abs().toStringAsFixed(2)}',
                            style: AppTheme.titleLarge.copyWith(
                              color: netProfit >= 0
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                            ),
                          ),
                      ],
                    ),
                    if (hasEndAmount) ...[
                      const Divider(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Calculation:',
                              style: AppTheme.labelLarge.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              'End Amount:',
                              '\$${endAmount.toStringAsFixed(2)}',
                              valueColor: endAmount >= 0 ? AppTheme.primaryColor : AppTheme.errorColor,
                            ),
                            _buildInfoRow(
                              'Total Buy-ins:',
                              '-\$${buyInTotal.toStringAsFixed(2)}',
                              valueColor: AppTheme.secondaryColor,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              'Net Profit:',
                              '\$${netProfit.toStringAsFixed(2)}',
                              valueColor: netProfit >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildBottomBar(bool isAdmin, bool isGameClosed) {
    if (!isAdmin || isGameClosed) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'ADD PLAYER',
              onPressed: _navigateToAddPlayer,
              gradient: AppTheme.secondaryGradient,
              icon: Icons.person_add,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'END GAME',
              onPressed: _closeGame,
              isLoading: _isClosingGame,
              gradient: AppTheme.accentGradient,
              icon: Icons.stop_circle,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAmountDisplay(String label, String amount, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: AppTheme.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper methods for transaction display
  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.buyIn:
        return AppTheme.secondaryColor;
      case TransactionType.addOn:
        return AppTheme.warningColor;
      case TransactionType.gameEndAmount:
        return AppTheme.primaryColor;
    }
  }
  
  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.buyIn:
        return Icons.arrow_downward;
      case TransactionType.addOn:
        return Icons.add_circle;
      case TransactionType.gameEndAmount:
        return Icons.arrow_upward;
    }
  }
  
  String _getTransactionTitle(TransactionType type) {
    switch (type) {
      case TransactionType.buyIn:
        return 'Buy-in';
      case TransactionType.addOn:
        return 'Add-on';
      case TransactionType.gameEndAmount:
        return 'End Amount';
    }
  }
}
