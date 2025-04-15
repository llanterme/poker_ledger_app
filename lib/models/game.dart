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
  
  @JsonKey(name: 'createdByName')
  final String? createdByName;
  
  @JsonKey(name: 'createdOn')
  final DateTime? createdAt;
  
  @JsonKey(defaultValue: GameStatus.open)
  final GameStatus status;

  const Game({
    this.id,
    required this.createdBy,
    this.createdByName,
    this.createdAt,
    this.status = GameStatus.open,
  });

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  
  Map<String, dynamic> toJson() => _$GameToJson(this);
  
  Game copyWith({
    int? id,
    int? createdBy,
    String? createdByName,
    DateTime? createdAt,
    GameStatus? status,
  }) {
    return Game(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
  
  @override
  List<Object?> get props => [id, createdBy, createdByName, createdAt, status];
}
