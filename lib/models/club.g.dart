// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Club _$ClubFromJson(Map<String, dynamic> json) => Club(
  id: (json['id'] as num?)?.toInt(),
  clubName: json['clubName'] as String,
  creatorUserId: (json['creatorUserId'] as num?)?.toInt(),
);

Map<String, dynamic> _$ClubToJson(Club instance) => <String, dynamic>{
  'id': instance.id,
  'clubName': instance.clubName,
  'creatorUserId': instance.creatorUserId,
};
