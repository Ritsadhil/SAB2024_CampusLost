class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final String? address;
  final int totalReports;
  final int foundCount;
  final int claimedCount;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    this.address,
    this.totalReports = 0,
    this.foundCount = 0,
    this.claimedCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'profileImage': profileImage,
    'address': address,
    'totalReports': totalReports,
    'foundCount': foundCount,
    'claimedCount': claimedCount,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'],
    profileImage: json['profileImage'],
    address: json['address'],
    totalReports: json['totalReports'] ?? 0,
    foundCount: json['foundCount'] ?? 0,
    claimedCount: json['claimedCount'] ?? 0,
  );
}
