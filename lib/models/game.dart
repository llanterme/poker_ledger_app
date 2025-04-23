import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

enum GameStatus {
  @JsonValue('OPEN')
  open,
  
  @JsonValue('CLOSED')
  closed
}

@JsonSerializable()
class Game extends Equatable {
  final int? id;
  final int createdBy;
  final int clubId;
  
  @JsonKey(name: 'createdByName')
  final String? createdByName;
  
  @JsonKey(name: 'createdOn')
  final DateTime? createdAt;
  
  @JsonKey(defaultValue: GameStatus.open)
  final GameStatus status;

  const Game({
    this.id,
    required this.createdBy,
    required this.clubId,
    this.createdByName,
    this.createdAt,
    this.status = GameStatus.open,
  });

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  
  Map<String, dynamic> toJson() => _$GameToJson(this);
  
  Game copyWith({
    int? id,
    int? createdBy,
    int? clubId,
    String? createdByName,
    DateTime? createdAt,
    GameStatus? status,
  }) {
    return Game(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      clubId: clubId ?? this.clubId,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
  
  @override
  List<Object?> get props => [id, createdBy, clubId, createdByName, createdAt, status];
}
