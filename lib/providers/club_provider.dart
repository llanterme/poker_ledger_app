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
    state = state.copyWith(isLoading: true, error: '');
    
    try {
      final clubs = await _apiService.getClubs();
      
      // If we have clubs but no current club is set, set the first one as current
      final newCurrentClub = state.currentClub ?? (clubs.isNotEmpty ? clubs.first : null);
      
      state = state.copyWith(
        isLoading: false,
        clubs: clubs,
        currentClub: newCurrentClub,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load clubs: ${e.toString()}',
      );
    }
  }

  void setCurrentClub(Club club) {
    state = state.copyWith(currentClub: club);
  }
  
  // Get the current club ID or throw an exception if none is selected
  int getCurrentClubId() {
    final clubId = state.currentClub?.id;
    if (clubId == null) {
      throw Exception('No club selected');
    }
    return clubId;
  }
  
  // Load clubs for a specific user
  Future<List<Club>> loadUserClubs(int userId) async {
    state = state.copyWith(isLoading: true, error: '');
    
    try {
      final clubs = await _apiService.getClubsByUserId(userId);
      
      // If we have clubs but no current club is set, set the first one as current
      final newCurrentClub = state.currentClub ?? (clubs.isNotEmpty ? clubs.first : null);
      
      state = state.copyWith(
        isLoading: false,
        clubs: clubs,
        currentClub: newCurrentClub,
      );
      
      return clubs;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load user clubs: ${e.toString()}',
      );
      return [];
    }
  }
  
  // Get a club by ID
  Future<Club> getClubById(int clubId) async {
    try {
      return await _apiService.getClubById(clubId);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to get club: ${e.toString()}',
      );
      rethrow;
    }
  }
}

// Club Provider
final clubStateProvider = StateNotifierProvider<ClubNotifier, ClubState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ClubNotifier(apiService);
});

// Use the existing apiServiceProvider from auth_provider.dart
