import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:poker_ledger/models/user.dart';

part 'auth.g.dart';

@JsonSerializable()
class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
  
  @override
  List<Object?> get props => [email, password];
}

@JsonSerializable()
class AuthResponse extends Equatable {
  final User user;

  const AuthResponse({
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
  
  @override
  List<Object?> get props => [user];
}
