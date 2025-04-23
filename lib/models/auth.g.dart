// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  clubs:
      (json['clubs'] as List<dynamic>?)
          ?.map((e) => UserClub.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  message: json['message'] as String?,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'clubs': instance.clubs,
      'message': instance.message,
    };
