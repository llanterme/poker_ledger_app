import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'club.g.dart';

@JsonSerializable()
class Club extends Equatable {
  final int? id;
  final String clubName;
  
  @JsonKey(name: 'creatorUserId')
  final int? creatorUserId;
  
  const Club({
    this.id,
    required this.clubName,
    this.creatorUserId,
  });

  factory Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);
  
  Map<String, dynamic> toJson() => _$ClubToJson(this);
  
  Club copyWith({
    int? id,
    String? clubName,
    int? creatorUserId,
  }) {
    return Club(
      id: id ?? this.id,
      clubName: clubName ?? this.clubName,
      creatorUserId: creatorUserId ?? this.creatorUserId,
    );
  }
  
  @override
  List<Object?> get props => [id, clubName, creatorUserId];
}
