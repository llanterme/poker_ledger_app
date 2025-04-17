import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:poker_ledger/models/auth.dart';
import 'package:poker_ledger/models/club.dart';
import 'package:poker_ledger/models/game.dart';
import 'package:poker_ledger/models/game_summary.dart';
import 'package:poker_ledger/models/game_user.dart';
import 'package:poker_ledger/models/transaction.dart';
import 'package:poker_ledger/models/user.dart';
import 'package:poker_ledger/models/user_club.dart';
import 'package:poker_ledger/services/auth_service.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:8080/api';
  // We keep the AuthService as a dependency for future authentication needs
  final AuthService _authService;

  ApiService(this._authService) {
    // Initialize authentication if needed in the future
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

      throw Exception(
        '$fallbackMessage. Please check your connection and try again.',
      );
    }

    throw Exception('$fallbackMessage. An unexpected error occurred.');
  }

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

      // Parse the response data
      // This would normally come from the backend, but we're simulating it for now
      final userData = response.data as Map<String, dynamic>;

      // Create a user object from the response data
      final user = User(
        id: userData['userId'] ?? 1,
        firstName: userData['firstName'] ?? 'Admin',
        lastName: userData['lastName'] ?? 'User',
        email: email,
        isAdmin: userData['isAdmin'] ?? true,
      );

      // Parse clubs data if available
      List<UserClub> clubs = [];
      if (userData.containsKey('clubs') && userData['clubs'] is List) {
        clubs =
            (userData['clubs'] as List)
                .map(
                  (clubData) => UserClub(
                    id: clubData['id'],
                    clubName: clubData['clubName'],
                    isAdmin: clubData['isAdmin'] ?? false,
                    isClubOwner: clubData['isClubOwner'] ?? false,
                  ),
                )
                .toList();
      }

      // Store the user in the auth service for future reference
      await _authService.saveUser(user);

      return AuthResponse(
        user: user,
        clubs: clubs,
        message: userData['message'],
      );
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
  Future<User> createUser(User user, {int? clubId}) async {
    try {
      // Create a map from the user object
      final userData = user.toJson();

      // Add clubId if provided
      if (clubId != null) {
        userData['clubId'] = clubId;
      }

      final response = await _dio.post('$_baseUrl/users', data: userData);

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

  // Club Management
  Future<List<Club>> getClubs() async {
    try {
      final response = await _dio.get('$_baseUrl/clubs');

      if (response.data == null) {
        return [];
      }

      return (response.data as List)
          .map((club) => Club.fromJson(club))
          .toList();
    } catch (e) {
      _handleApiError(e, 'Failed to get clubs');
      return [];
    }
  }

  Future<Club> getClubById(int clubId) async {
    try {
      final response = await _dio.get('$_baseUrl/clubs/$clubId');

      if (response.data == null) {
        throw Exception('Invalid response from server');
      }

      return Club.fromJson(response.data);
    } catch (e) {
      _handleApiError(e, 'Failed to get club');
      rethrow;
    }
  }

  Future<List<Club>> getClubsByUserId(int userId) async {
    try {
      final response = await _dio.get('$_baseUrl/clubs/user/$userId');

      if (response.data == null) {
        return [];
      }

      return (response.data as List)
          .map((club) => Club.fromJson(club))
          .toList();
    } catch (e) {
      _handleApiError(e, 'Failed to get user clubs');
      return [];
    }
  }

  // Club Users Management
  Future<List<User>> getUsersByClubId(int clubId) async {
    try {
      final response = await _dio.get('$_baseUrl/club-users/club/$clubId');

      if (response.data == null) {
        return [];
      }

      return (response.data as List)
          .map((user) => User.fromJson(user))
          .toList();
    } catch (e) {
      _handleApiError(e, 'Failed to get club users');
      return [];
    }
  }

  Future<void> associateUserWithClub(
    int clubId,
    String email,
    bool isAdmin,
    bool isClubOwner,
  ) async {
    try {
      await _dio.post(
        '$_baseUrl/club-users',
        data: {
          'clubId': clubId,
          'email': email,
          'isAdmin': isAdmin,
          'isClubOwner': isClubOwner,
        },
      );
    } catch (e) {
      _handleApiError(e, 'Failed to associate user with club');
      rethrow;
    }
  }

  Future<bool> checkIfUserIsInClub(int userId, int clubId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/club-users/check',
        queryParameters: {'userId': userId, 'clubId': clubId},
      );

      return response.data == true;
    } catch (e) {
      _handleApiError(e, 'Failed to check if user is in club');
      return false;
    }
  }

  Future<bool> checkIfUserIsAdminInClub(int userId, int clubId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/club-users/check/admin',
        queryParameters: {'userId': userId, 'clubId': clubId},
      );

      return response.data == true;
    } catch (e) {
      _handleApiError(e, 'Failed to check if user is admin in club');
      return false;
    }
  }

  Future<bool> checkIfUserIsOwnerOfClub(int userId, int clubId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/club-users/check/owner',
        queryParameters: {'userId': userId, 'clubId': clubId},
      );

      return response.data == true;
    } catch (e) {
      _handleApiError(e, 'Failed to check if user is owner of club');
      return false;
    }
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

  // Game Management
  Future<List<Game>> getGames({int? clubId}) async {
    try {
      final String url =
          clubId != null ? '$_baseUrl/games/club/$clubId' : '$_baseUrl/games';

      final response = await _dio.get(url);

      if (response.data == null) {
        return [];
      }

      return (response.data as List)
          .map((game) => Game.fromJson(game))
          .toList();
    } catch (e) {
      _handleApiError(e, 'Failed to get games');
      return [];
    }
  }

  Future<Game> getGameById(int gameId) async {
    try {
      final response = await _dio.get('$_baseUrl/games/$gameId');

      if (response.data == null) {
        throw Exception('Invalid response from server');
      }

      return Game.fromJson(response.data);
    } catch (e) {
      _handleApiError(e, 'Failed to get game');
      rethrow;
    }
  }

  Future<List<Game>> getGamesByStatus(GameStatus status, {int? clubId}) async {
    try {
      final statusStr = status.toString().split('.').last.toUpperCase();
      final String url =
          clubId != null
              ? '$_baseUrl/games/club/$clubId/status/$statusStr'
              : '$_baseUrl/games/status/$statusStr';

      final response = await _dio.get(url);

      if (response.data == null) {
        return [];
      }

      return (response.data as List)
          .map((game) => Game.fromJson(game))
          .toList();
    } catch (e) {
      _handleApiError(e, 'Failed to get games by status');
      return [];
    }
  }

  Future<Game> createGame(int userId, int clubId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/games',
        data: {'createdBy': userId, 'clubId': clubId},
      );

      if (response.data == null) {
        throw Exception('Invalid response from server');
      }

      return Game.fromJson(response.data);
    } catch (e) {
      _handleApiError(e, 'Failed to create game');
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
