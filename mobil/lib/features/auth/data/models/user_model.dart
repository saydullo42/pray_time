class UserModel {
  const UserModel({
    required this.id,
    required this.phoneNumber,
    this.fullName,
    this.avatarUrl,
    this.isProfileComplete = false,
  });

  final String id;
  final String phoneNumber;
  final String? fullName;
  final String? avatarUrl;
  final bool isProfileComplete;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        phoneNumber: json['phone_number'] as String,
        fullName: json['full_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        isProfileComplete: json['is_profile_complete'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone_number': phoneNumber,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'is_profile_complete': isProfileComplete,
      };

  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
    bool? isProfileComplete,
  }) {
    return UserModel(
      id: id,
      phoneNumber: phoneNumber,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
