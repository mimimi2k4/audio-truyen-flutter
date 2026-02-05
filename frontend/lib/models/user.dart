class User {
  final int id;
  final String email;
  final String? name;
  final String? phone;
  final DateTime? birthday;
  final String? gender;
  final String? address;
  final String? avatar;
  final String role;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.birthday,
    this.gender,
    this.address,
    this.avatar,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      gender: json['gender'],
      address: json['address'],
      avatar: json['avatar'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'birthday': birthday?.toIso8601String().split('T')[0],
      'gender': gender,
      'address': address,
      'avatar': avatar,
      'role': role,
    };
  }

  bool get isAdmin => role == 'ADMIN';
}
