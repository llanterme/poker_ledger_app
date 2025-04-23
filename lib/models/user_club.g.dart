// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_club.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserClub _$UserClubFromJson(Map<String, dynamic> json) => UserClub(
  id: (json['id'] as num).toInt(),
  clubName: json['clubName'] as String,
  isAdmin: json['isAdmin'] as bool,
  isClubOwner: json['isClubOwner'] as bool,
);

Map<String, dynamic> _$UserClubToJson(UserClub instance) => <String, dynamic>{
  'id': instance.id,
  'clubName': instance.clubName,
  'isAdmin': instance.isAdmin,
  'isClubOwner': instance.isClubOwner,
};
