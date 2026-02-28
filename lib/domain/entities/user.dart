class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final UserRole role;
  final DateTime createdAt;
  final bool isEmailVerified;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    required this.isEmailVerified,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    DateTime? createdAt,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, role: $role)';
}

enum UserRole { parent, child, admin, volunteer }
