class User {
  final int id;
  final String name;
  final String email;
  String? address;
  String? districtId;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.address,
    this.districtId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? "User",
      email: json['email'] ?? "",
      address: json['address'],
      districtId: json['district_id'],
    );
  }
}
