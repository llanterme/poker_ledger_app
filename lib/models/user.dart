import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final bool isAdmin;
  
  final String? password;

  const User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isAdmin,
    this.password,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  
  Map<String, dynamic> toJson() {
    final json = _$UserToJson(this);
    if (password != null) {
      json['password'] = password;
    }
    return json;
  }
  
  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    bool? isAdmin,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      password: password ?? this.password,
    );
  }
  
  @override
  List<Object?> get props => [id, firstName, lastName, email, isAdmin];
}
