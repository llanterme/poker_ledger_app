import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_user.g.dart';

@JsonSerializable()
class GameUser extends Equatable {
  final int? id;
  final int gameId;
  final int userId;

  const GameUser({
    this.id,
    required this.gameId,
    required this.userId,
  });

  factory GameUser.fromJson(Map<String, dynamic> json) => _$GameUserFromJson(json);
  
  Map<String, dynamic> toJson() => _$GameUserToJson(this);
  
  GameUser copyWith({
    int? id,
    int? gameId,
    int? userId,
  }) {
    return GameUser(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      userId: userId ?? this.userId,
    );
  }
  
  @override
  List<Object?> get props => [id, gameId, userId];
}
