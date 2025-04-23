import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_ledger/models/game.dart';
import 'package:poker_ledger/models/game_summary.dart';
import 'package:poker_ledger/models/game_user.dart';
import 'package:poker_ledger/models/transaction.dart';
import 'package:poker_ledger/models/user.dart';
import 'package:poker_ledger/providers/auth_provider.dart';
import 'package:poker_ledger/services/api_service.dart';

// Games Provider
final gamesProvider = StateNotifierProvider<GamesNotifier, GamesState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return GamesNotifier(apiService);
});

// Current Game Provider
final currentGameProvider =
    StateNotifierProvider<CurrentGameNotifier, CurrentGameState>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      return CurrentGameNotifier(apiService);
    });

// Game Users Provider
final gameUsersProvider =
    StateNotifierProvider<GameUsersNotifier, GameUsersState>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      return GameUsersNotifier(apiService);
    });

// Game Transactions Provider
final gameTransactionsProvider =
    StateNotifierProvider<GameTransactionsNotifier, GameTransactionsState>((
      ref,
    ) {
      final apiService = ref.watch(apiServiceProvider);
      return GameTransactionsNotifier(apiService);
    });

// Users Provider
final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UsersNotifier(apiService);
});

// Games State
class GamesState {
  final bool isLoading;
  final List<Game> games;
  final String? error;

  GamesState({this.isLoading = false, this.games = const [], this.error});

  GamesState copyWith({bool? isLoading, List<Game>? games, String? error}) {
    return GamesState(
      isLoading: isLoading ?? this.isLoading,
      games: games ?? this.games,
      error: error != null ? error : null,
    );
  }
}

// Games Notifier
class GamesNotifier extends StateNotifier<GamesState> {
  final ApiService _apiService;

  GamesNotifier(this._apiService) : super(GamesState());

  Future<void> loadGames({int? clubId}) async {
    state = state.copyWith(isLoading: true);

    try {
      final games = await _apiService.getGames(clubId: clubId);
      state = state.copyWith(isLoading: false, games: games);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load games: $e',
      );
    }
  }

  Future<void> loadOpenGames({int? clubId}) async {
    state = state.copyWith(isLoading: true);

    try {
      final games = await _apiService.getGamesByStatus(GameStatus.open, clubId: clubId);
      state = state.copyWith(isLoading: false, games: games);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load open games: $e',
      );
    }
  }

  Future<Game?> createGame(int userId, int clubId) async {
    state = state.copyWith(isLoading: true);

    try {
      final game = await _apiService.createGame(userId, clubId);

      // Update games list
      final updatedGames = [...state.games, game];

      state = state.copyWith(isLoading: false, games: updatedGames);

      return game;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create game: $e',
      );
      return null;
    }
  }
}

// Current Game State
class CurrentGameState {
  final bool isLoading;
  final Game? game;
  final GameSummary? summary;
  final String? error;

  CurrentGameState({
    this.isLoading = false,
    this.game,
    this.summary,
    this.error,
  });

  CurrentGameState copyWith({
    bool? isLoading,
    Game? game,
    GameSummary? summary,
    String? error,
  }) {
    return CurrentGameState(
      isLoading: isLoading ?? this.isLoading,
      game: game ?? this.game,
      summary: summary ?? this.summary,
      error: error != null ? error : null,
    );
  }
}

// Current Game Notifier
class CurrentGameNotifier extends StateNotifier<CurrentGameState> {
  final ApiService _apiService;

  CurrentGameNotifier(this._apiService) : super(CurrentGameState());

  Future<void> loadGame(int gameId) async {
    state = state.copyWith(isLoading: true);

    try {
      final game = await _apiService.getGameById(gameId);
      state = state.copyWith(isLoading: false, game: game);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load game: $e',
      );
    }
  }

  Future<void> loadGameSummary(int gameId) async {
    state = state.copyWith(isLoading: true);

    try {
      final summary = await _apiService.getGameSummary(gameId);
      state = state.copyWith(isLoading: false, summary: summary);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load game summary: $e',
      );
    }
  }

  Future<void> closeGame() async {
    if (state.game == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final updatedGame = await _apiService.closeGame(state.game!.id!);
      state = state.copyWith(isLoading: false, game: updatedGame);

      // Load summary after closing the game
      await loadGameSummary(updatedGame.id!);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to close game: $e',
      );
    }
  }

  void clearCurrentGame() {
    state = CurrentGameState();
  }
}

// Game Users State
class GameUsersState {
  final bool isLoading;
  final List<GameUser> gameUsers;
  final Map<int, User> userDetails;
  final String? error;

  GameUsersState({
    this.isLoading = false,
    this.gameUsers = const [],
    this.userDetails = const {},
    this.error,
  });

  GameUsersState copyWith({
    bool? isLoading,
    List<GameUser>? gameUsers,
    Map<int, User>? userDetails,
    String? error,
  }) {
    return GameUsersState(
      isLoading: isLoading ?? this.isLoading,
      gameUsers: gameUsers ?? this.gameUsers,
      userDetails: userDetails ?? this.userDetails,
      error: error != null ? error : null,
    );
  }
}

// Game Users Notifier
class GameUsersNotifier extends StateNotifier<GameUsersState> {
  final ApiService _apiService;

  GameUsersNotifier(this._apiService) : super(GameUsersState());

  Future<void> loadGameUsers(int gameId) async {
    state = state.copyWith(isLoading: true);

    try {
      final gameUsers = await _apiService.getUsersByGameId(gameId);

      // Load user details for each game user
      final Map<int, User> userDetails = {};
      for (final gameUser in gameUsers) {
        final user = await _apiService.getUserById(gameUser.userId);
        userDetails[user.id!] = user;
      }

      state = state.copyWith(
        isLoading: false,
        gameUsers: gameUsers,
        userDetails: userDetails,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load game users: $e',
      );
    }
  }

  Future<void> addUserToGame(int gameId, int userId) async {
    state = state.copyWith(isLoading: true);

    try {
      final gameUser = await _apiService.addUserToGame(gameId, userId);
      final user = await _apiService.getUserById(userId);

      // Update state
      final updatedGameUsers = [...state.gameUsers, gameUser];
      final updatedUserDetails = {...state.userDetails, userId: user};

      state = state.copyWith(
        isLoading: false,
        gameUsers: updatedGameUsers,
        userDetails: updatedUserDetails,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add user to game: $e',
      );
    }
  }

  Future<void> removeUserFromGame(int gameId, int userId) async {
    state = state.copyWith(isLoading: true);

    try {
      await _apiService.removeUserFromGame(gameId, userId);

      // Update state
      final updatedGameUsers =
          state.gameUsers
              .where(
                (gameUser) =>
                    !(gameUser.gameId == gameId && gameUser.userId == userId),
              )
              .toList();

      state = state.copyWith(isLoading: false, gameUsers: updatedGameUsers);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to remove user from game: $e',
      );
    }
  }
}

// Game Transactions State
class GameTransactionsState {
  final bool isLoading;
  final List<Transaction> transactions;
  final String? error;

  GameTransactionsState({
    this.isLoading = false,
    this.transactions = const [],
    this.error,
  });

  GameTransactionsState copyWith({
    bool? isLoading,
    List<Transaction>? transactions,
    String? error,
  }) {
    return GameTransactionsState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      error: error != null ? error : null,
    );
  }
}

// Game Transactions Notifier
class GameTransactionsNotifier extends StateNotifier<GameTransactionsState> {
  final ApiService _apiService;

  GameTransactionsNotifier(this._apiService) : super(GameTransactionsState());

  Future<void> loadTransactions(int gameId) async {
    state = state.copyWith(isLoading: true);

    try {
      final transactions = await _apiService.getTransactionsByGameId(gameId);
      state = state.copyWith(isLoading: false, transactions: transactions);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load transactions: $e',
      );
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    state = state.copyWith(isLoading: true);

    try {
      final newTransaction = await _apiService.createTransaction(transaction);

      // Update state
      final updatedTransactions = [...state.transactions, newTransaction];

      state = state.copyWith(
        isLoading: false,
        transactions: updatedTransactions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add transaction: $e',
      );
    }
  }
}

// Users State
class UsersState {
  final bool isLoading;
  final List<User> users;
  final String? error;

  UsersState({this.isLoading = false, this.users = const [], this.error});

  UsersState copyWith({bool? isLoading, List<User>? users, String? error}) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      error: error != null ? error : null,
    );
  }
}

// Users Notifier
class UsersNotifier extends StateNotifier<UsersState> {
  final ApiService _apiService;

  UsersNotifier(this._apiService) : super(UsersState());

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true);

    try {
      final users = await _apiService.getAllUsers();
      state = state.copyWith(isLoading: false, users: users);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load users: $e',
      );
    }
  }

  Future<User?> createUser(User user) async {
    state = state.copyWith(isLoading: true);

    try {
      final newUser = await _apiService.createUser(user);

      // Update state
      final updatedUsers = [...state.users, newUser];

      state = state.copyWith(isLoading: false, users: updatedUsers);

      return newUser;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create user: $e',
      );
      return null;
    }
  }
}
