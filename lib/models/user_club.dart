import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_club.g.dart';

@JsonSerializable()
class UserClub extends Equatable {
  final int id;
  final String clubName;
  final bool isAdmin;
  final bool isClubOwner;

  const UserClub({
    required this.id,
    required this.clubName,
    required this.isAdmin,
    required this.isClubOwner,
  });

  factory UserClub.fromJson(Map<String, dynamic> json) => _$UserClubFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserClubToJson(this);
  
  UserClub copyWith({
    int? id,
    String? clubName,
    bool? isAdmin,
    bool? isClubOwner,
  }) {
    return UserClub(
      id: id ?? this.id,
      clubName: clubName ?? this.clubName,
      isAdmin: isAdmin ?? this.isAdmin,
      isClubOwner: isClubOwner ?? this.isClubOwner,
    );
  }
  
  @override
  List<Object?> get props => [id, clubName, isAdmin, isClubOwner];
}
