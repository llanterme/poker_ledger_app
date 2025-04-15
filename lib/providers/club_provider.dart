import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_ledger/models/club.dart';
import 'package:poker_ledger/providers/auth_provider.dart';
import 'package:poker_ledger/services/api_service.dart';

// Club State
class ClubState {
  final bool isLoading;
  final List<Club> clubs;
  final Club? currentClub;
  final String? error;

  ClubState({
    this.isLoading = false,
    this.clubs = const [],
    this.currentClub,
    this.error,
  });

  ClubState copyWith({
    bool? isLoading,
    List<Club>? clubs,
    Club? currentClub,
    String? error,
  }) {
    return ClubState(
      isLoading: isLoading ?? this.isLoading,
      clubs: clubs ?? this.clubs,
      currentClub: currentClub ?? this.currentClub,
      error: error != null ? error : null, // Clear error if new error is provided
    );
  }
}

// Club Notifier
class ClubNotifier extends StateNotifier<ClubState> {
  final ApiService _apiService;

  ClubNotifier(this._apiService) : super(ClubState());

  Future<Club> createClub(String clubName, int creatorUserId) async {
    state = state.copyWith(isLoading: true, error: '');
    
    try {
      final club = await _apiService.createClub(clubName, creatorUserId);
      
      // Update clubs list
      final updatedClubs = [...state.clubs, club];
      
      state = state.copyWith(
        isLoading: false,
        clubs: updatedClubs,
        currentClub: club,
      );
      
      return club;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> loadClubs() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // This would be implemented when the API supports getting clubs
      // For now, we'll just use the clubs we have in state
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load clubs: $e',
      );
    }
  }

  void setCurrentClub(Club club) {
    state = state.copyWith(currentClub: club);
  }
}

// Club Provider
final clubStateProvider = StateNotifierProvider<ClubNotifier, ClubState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ClubNotifier(apiService);
});

// Use the existing apiServiceProvider from auth_provider.dart
