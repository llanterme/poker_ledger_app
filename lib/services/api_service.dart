import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:poker_ledger/models/auth.dart';
import 'package:poker_ledger/models/club.dart';
import 'package:poker_ledger/models/game.dart';
import 'package:poker_ledger/models/game_summary.dart';
import 'package:poker_ledger/models/game_user.dart';
import 'package:poker_ledger/models/transaction.dart';
import 'package:poker_ledger/models/user.dart';
import 'package:poker_ledger/services/auth_service.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:8080/api';

  ApiService(AuthService authService) {}

  // Authentication
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: LoginRequest(email: email, password: password).toJson(),
      );

      // Check if response data is valid
      if (response.data == null) {
        throw Exception('Invalid response from server');
      }

      // Create a user object directly since we're not using the backend auth
      // This is a temporary solution until the backend auth is implemented
      final user = User(
        id: 1,
        firstName: 'Admin',
        lastName: 'User',
        email: email,
        isAdmin: true,
      );

      return AuthResponse(user: user);
    } catch (e) {
      debugPrint('Login error: $e');

      // Extract clean error message from DioException
      if (e is DioException) {
        debugPrint('DioException response: ${e.response?.data}');

        if (e.response != null && e.response!.data != null) {
          // The response data is already a Map with the error details
          final errorData = e.response!.data;

          if (errorData is Map && errorData.containsKey('message')) {
            // Extract the message directly from the response
            throw Exception(errorData['message']);
          } else {
            // Fallback if message field is not found
            throw Exception('Login failed. Please try again.');
          }
        } else {
          // No response data available (likely a network error)
          throw Exception(
            'Login failed. Please check your connection and try again.',
          );
        }
      }

      // For other types of errors
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // User Registration
  Future<User> createUser(User user) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/users',
        data: user.toJson(),
      );

      if (response.data == null) {
        throw Exception('Invalid response from server');
      }

      return User.fromJson(response.data);
    } catch (e) {
      _handleApiError(e, 'Failed to create user');
      rethrow;
    }
  }

  // Club Registration
  Future<Club> createClub(String clubName, int creatorUserId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/clubs',
        queryParameters: {'creatorUserId': creatorUserId},
        data: {'clubName': clubName},
      );

      if (response.data == null) {
        throw Exception('Invalid response from server');
      }

      return Club.fromJson(response.data);
    } catch (e) {
      _handleApiError(e, 'Failed to create club');
      rethrow;
    }
  }

  // Helper method to handle API errors consistently
  void _handleApiError(dynamic e, String fallbackMessage) {
    debugPrint('API error: $e');
    
    if (e is DioException) {
      debugPrint('DioException response: ${e.response?.data}');
      
      if (e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        }
      }
      
      throw Exception('$fallbackMessage. Please check your connection and try again.');
    }
    
    throw Exception('$fallbackMessage. An unexpected error occurred.');
  }

  // Users
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _dio.get('$_baseUrl/users');
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Get all users error: $e');
      rethrow;
    }
  }

  Future<User> getUserById(int userId) async {
    try {
      final response = await _dio.get('$_baseUrl/users/$userId');
      return User.fromJson(response.data);
    } catch (e) {
      debugPrint('Get user by ID error: $e');
      rethrow;
    }
  }

  Future<User> registerUserLegacy(User user) async {
    try {
      final response = await _dio.post('$_baseUrl/users', data: user.toJson());
      return User.fromJson(response.data);
    } catch (e) {
      debugPrint('Create user error: $e');
      rethrow;
    }
  }

  // Games
  Future<List<Game>> getAllGames() async {
    try {
      final response = await _dio.get('$_baseUrl/games');
      return (response.data as List)
          .map((json) => Game.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Get all games error: $e');
      rethrow;
    }
  }

  Future<Game> getGameById(int gameId) async {
    try {
      final response = await _dio.get('$_baseUrl/games/$gameId');
      return Game.fromJson(response.data);
    } catch (e) {
      debugPrint('Get game by ID error: $e');
      rethrow;
    }
  }

  Future<List<Game>> getGamesByStatus(GameStatus status) async {
    try {
      final statusString = status.toString().split('.').last.toUpperCase();
      final response = await _dio.get('$_baseUrl/games/status/$statusString');
      return (response.data as List)
          .map((json) => Game.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Get games by status error: $e');
      rethrow;
    }
  }

  Future<Game> createGame(int createdBy) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/games',
        data: {'createdBy': createdBy},
      );
      return Game.fromJson(response.data);
    } catch (e) {
      debugPrint('Create game error: $e');
      rethrow;
    }
  }

  Future<Game> closeGame(int gameId) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/games/$gameId',
        data: {'status': 'CLOSED'},
      );
      return Game.fromJson(response.data);
    } catch (e) {
      debugPrint('Close game error: $e');
      rethrow;
    }
  }

  // Game Users
  Future<List<GameUser>> getUsersByGameId(int gameId) async {
    try {
      final response = await _dio.get('$_baseUrl/game-users/game/$gameId');
      return (response.data as List)
          .map((json) => GameUser.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Get users by game ID error: $e');
      rethrow;
    }
  }

  Future<GameUser> addUserToGame(int gameId, int userId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/game-users',
        data: {'gameId': gameId, 'userId': userId},
      );
      return GameUser.fromJson(response.data);
    } catch (e) {
      debugPrint('Add user to game error: $e');
      rethrow;
    }
  }

  Future<void> removeUserFromGame(int gameId, int userId) async {
    try {
      await _dio.delete('$_baseUrl/game-users/game/$gameId/user/$userId');
    } catch (e) {
      debugPrint('Remove user from game error: $e');
      rethrow;
    }
  }

  // Transactions
  Future<List<Transaction>> getTransactionsByGameId(int gameId) async {
    try {
      final response = await _dio.get('$_baseUrl/transactions/game/$gameId');
      return (response.data as List)
          .map((json) => Transaction.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Get transactions by game ID error: $e');
      rethrow;
    }
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/transactions',
        data: transaction.toJson(),
      );
      return Transaction.fromJson(response.data);
    } catch (e) {
      debugPrint('Create transaction error: $e');
      rethrow;
    }
  }

  // Game Summaries
  Future<GameSummary> getGameSummary(int gameId) async {
    try {
      final response = await _dio.get('$_baseUrl/game-summaries/$gameId');
      return GameSummary.fromJson(response.data);
    } catch (e) {
      debugPrint('Get game summary error: $e');
      rethrow;
    }
  }
}
