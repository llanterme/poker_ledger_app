import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:poker_ledger/models/user.dart';

part 'game_summary.g.dart';

@JsonSerializable()
class PlayerSummary extends Equatable {
  final User user;
  final double buyInTotal;
  final double endAmount;
  final double netProfit;

  const PlayerSummary({
    required this.user,
    required this.buyInTotal,
    required this.endAmount,
    required this.netProfit,
  });

  factory PlayerSummary.fromJson(Map<String, dynamic> json) => _$PlayerSummaryFromJson(json);
  
  Map<String, dynamic> toJson() => _$PlayerSummaryToJson(this);
  
  @override
  List<Object?> get props => [user, buyInTotal, endAmount, netProfit];
}

@JsonSerializable()
class GameSummary extends Equatable {
  final int gameId;
  final DateTime? createdAt;
  final DateTime? closedAt;
  final List<PlayerSummary> playerSummaries;
  final double totalBuyIns;
  final double totalEndAmount;

  const GameSummary({
    required this.gameId,
    this.createdAt,
    this.closedAt,
    required this.playerSummaries,
    required this.totalBuyIns,
    required this.totalEndAmount,
  });

  factory GameSummary.fromJson(Map<String, dynamic> json) => _$GameSummaryFromJson(json);
  
  Map<String, dynamic> toJson() => _$GameSummaryToJson(this);
  
  @override
  List<Object?> get props => [gameId, createdAt, closedAt, playerSummaries, totalBuyIns, totalEndAmount];
}
