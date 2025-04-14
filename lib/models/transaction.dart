import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

enum TransactionType {
  @JsonValue('BUY_IN')
  buyIn,
  
  @JsonValue('GAME_END_AMOUNT')
  gameEndAmount,
  
  @JsonValue('ADD_ON')
  addOn
}

@JsonSerializable()
class Transaction extends Equatable {
  final int? id;
  final int gameId;
  final int userId;
  final TransactionType type;
  final double amount;
  final DateTime? createdAt;

  const Transaction({
    this.id,
    required this.gameId,
    required this.userId,
    required this.type,
    required this.amount,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
  
  Transaction copyWith({
    int? id,
    int? gameId,
    int? userId,
    TransactionType? type,
    double? amount,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  List<Object?> get props => [id, gameId, userId, type, amount, createdAt];
}
