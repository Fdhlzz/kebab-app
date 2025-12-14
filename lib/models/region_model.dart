class District {
  final String id; // ✅ Changed from int to String
  final String name;

  District({required this.id, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['code'].toString(), // ✅ Map 'code' from DB to 'id' in App
      name: json['name'],
    );
  }
}
