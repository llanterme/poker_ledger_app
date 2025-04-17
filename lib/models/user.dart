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
  final bool isClubOwner;
  
  final String? password;

  const User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isAdmin,
    this.isClubOwner = false,
    this.password,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) => User(
  id: json['id'] as int?,
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  email: json['email'] as String? ?? '',
  isAdmin: json['isAdmin'] as bool? ?? false,
  isClubOwner: json['isClubOwner'] as bool? ?? false,
  password: json['password'] as String?,
);
  
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
    bool? isClubOwner,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      isClubOwner: isClubOwner ?? this.isClubOwner,
      password: password ?? this.password,
    );
  }
  
  @override
  List<Object?> get props => [id, firstName, lastName, email, isAdmin, isClubOwner];
}
