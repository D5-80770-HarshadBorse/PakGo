class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"].toString(),
      fullName: json["fullName"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      role: json["role"] ?? "user",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "email": email,
      "phone": phone,
      "role": role,
    };
  }
}
