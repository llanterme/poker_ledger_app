// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
  id: (json['id'] as num?)?.toInt(),
  createdBy: (json['createdBy'] as num).toInt(),
  createdByName: json['createdByName'] as String?,
  createdAt:
      json['createdOn'] == null
          ? null
          : DateTime.parse(json['createdOn'] as String),
  status:
      $enumDecodeNullable(_$GameStatusEnumMap, json['status']) ??
      GameStatus.open,
);

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
  'id': instance.id,
  'createdBy': instance.createdBy,
  'createdByName': instance.createdByName,
  'createdOn': instance.createdAt?.toIso8601String(),
  'status': _$GameStatusEnumMap[instance.status]!,
};

const _$GameStatusEnumMap = {
  GameStatus.open: 'OPEN',
  GameStatus.closed: 'CLOSED',
};
