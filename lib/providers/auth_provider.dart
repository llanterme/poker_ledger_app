import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_ledger/models/auth.dart';
import 'package:poker_ledger/models/user.dart';
import 'package:poker_ledger/models/user_club.dart';
import 'package:poker_ledger/services/api_service.dart';
import 'package:poker_ledger/services/auth_service.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ApiService(authService);
});

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(authService, apiService);
});

// Auth State
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isAuthenticated;
  final List<UserClub> clubs;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
    this.clubs = const [],
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool? isAuthenticated,
    List<UserClub>? clubs,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error != null ? error : null, // Clear error if new error is provided
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      clubs: clubs ?? this.clubs,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final ApiService _apiService;

  AuthNotifier(this._authService, this._apiService) : super(AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      final user = await _authService.getUser();
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: isAuthenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize authentication: $e',
      );
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: '');
    
    try {
      final AuthResponse response = await _apiService.login(email, password);
      
      // Save user
      await _authService.saveUser(response.user);
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: response.user,
        clubs: response.clubs,
      );
      
      return response;
    } catch (e) {
      // Extract clean error message without the Exception prefix
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _authService.logout();
      
      state = AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Logout failed: ${e.toString()}',
      );
    }
  }
  
  // Update the current user
  Future<void> updateUser(User updatedUser) async {
    try {
      // Save updated user to secure storage
      await _authService.saveUser(updatedUser);
      
      // Update state with the new user
      state = state.copyWith(
        user: updatedUser,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update user: ${e.toString()}',
      );
    }
  }

  bool get isAdmin => state.user?.isAdmin ?? false;
}
