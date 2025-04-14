// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerSummary _$PlayerSummaryFromJson(Map<String, dynamic> json) =>
    PlayerSummary(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      buyInTotal: (json['buyInTotal'] as num).toDouble(),
      endAmount: (json['endAmount'] as num).toDouble(),
      netProfit: (json['netProfit'] as num).toDouble(),
    );

Map<String, dynamic> _$PlayerSummaryToJson(PlayerSummary instance) =>
    <String, dynamic>{
      'user': instance.user,
      'buyInTotal': instance.buyInTotal,
      'endAmount': instance.endAmount,
      'netProfit': instance.netProfit,
    };

GameSummary _$GameSummaryFromJson(Map<String, dynamic> json) => GameSummary(
  gameId: (json['gameId'] as num).toInt(),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  closedAt:
      json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
  playerSummaries:
      (json['playerSummaries'] as List<dynamic>)
          .map((e) => PlayerSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
  totalBuyIns: (json['totalBuyIns'] as num).toDouble(),
  totalEndAmount: (json['totalEndAmount'] as num).toDouble(),
);

Map<String, dynamic> _$GameSummaryToJson(GameSummary instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'closedAt': instance.closedAt?.toIso8601String(),
      'playerSummaries': instance.playerSummaries,
      'totalBuyIns': instance.totalBuyIns,
      'totalEndAmount': instance.totalEndAmount,
    };
