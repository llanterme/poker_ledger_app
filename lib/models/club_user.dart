import 'package:equatable/equatable.dart';

class ClubUser extends Equatable {
  final int id;
  final int clubId;
  final int userId;
  final String firstName;
  final String lastName;
  final bool isAdmin;
  final bool isClubOwner;
  final DateTime joinedOn;

  const ClubUser({
    required this.id,
    required this.clubId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.isAdmin,
    required this.isClubOwner,
    required this.joinedOn,
  });

  String get fullName => '$firstName $lastName';

  factory ClubUser.fromJson(Map<String, dynamic> json) => ClubUser(
        id: json['id'] as int,
        clubId: json['clubId'] as int,
        userId: json['userId'] as int,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        isAdmin: json['isAdmin'] as bool,
        isClubOwner: json['isClubOwner'] as bool,
        joinedOn: DateTime.parse(json['joinedOn'] as String),
      );
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'clubId': clubId,
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'isAdmin': isAdmin,
        'isClubOwner': isClubOwner,
        'joinedOn': joinedOn.toIso8601String(),
      };
  
  ClubUser copyWith({
    int? id,
    int? clubId,
    int? userId,
    String? firstName,
    String? lastName,
    bool? isAdmin,
    bool? isClubOwner,
    DateTime? joinedOn,
  }) {
    return ClubUser(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isAdmin: isAdmin ?? this.isAdmin,
      isClubOwner: isClubOwner ?? this.isClubOwner,
      joinedOn: joinedOn ?? this.joinedOn,
    );
  }
  
  @override
  List<Object?> get props => [id, clubId, userId, firstName, lastName, isAdmin, isClubOwner, joinedOn];
}
