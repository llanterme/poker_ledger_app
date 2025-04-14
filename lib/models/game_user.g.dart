// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameUser _$GameUserFromJson(Map<String, dynamic> json) => GameUser(
  id: (json['id'] as num?)?.toInt(),
  gameId: (json['gameId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
);

Map<String, dynamic> _$GameUserToJson(GameUser instance) => <String, dynamic>{
  'id': instance.id,
  'gameId': instance.gameId,
  'userId': instance.userId,
};
