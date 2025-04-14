// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: (json['id'] as num?)?.toInt(),
  gameId: (json['gameId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toDouble(),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gameId': instance.gameId,
      'userId': instance.userId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.buyIn: 'BUY_IN',
  TransactionType.gameEndAmount: 'GAME_END_AMOUNT',
  TransactionType.addOn: 'ADD_ON',
};
