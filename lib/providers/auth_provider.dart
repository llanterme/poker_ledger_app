import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_ledger/models/auth.dart';
import 'package:poker_ledger/models/user.dart';
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

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error != null ? error : null, // Clear error if new error is provided
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
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

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: '');
    
    try {
      final AuthResponse response = await _apiService.login(email, password);
      
      // Save user
      await _authService.saveUser(response.user);
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: response.user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed: ${e.toString()}',
      );
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

  bool get isAdmin => state.user?.isAdmin ?? false;
}
