class UserProfile {
  final String id;
  final String? name;
  final String email;
  final String? role; // 'passenger' | 'driver'
  final String? vehicleType; // 'ev' | 'normal'
  final int tokenBalance;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.vehicleType,
    required this.tokenBalance,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String?,
      email: map['email'] as String? ?? '',
      role: map['role'] as String?,
      vehicleType: map['vehicle_type'] as String?,
      tokenBalance: (map['token_balance'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'vehicle_type': vehicleType,
      'token_balance': tokenBalance,
    };
  }
}
