class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.region,
    this.district,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;

  /// The viloyat / tuman chosen at registration; empty/null if not chosen yet.
  final String? region;
  final String? district;

  bool get hasLocation =>
      (region ?? '').isNotEmpty && (district ?? '').isNotEmpty;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'].toString(),
    email: json['email'] as String,
    fullName: json['full_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    region: json['region'] as String?,
    district: json['district'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'region': region,
    'district': district,
  };

  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? region,
    String? district,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      region: region ?? this.region,
      district: district ?? this.district,
    );
  }
}
