class Report {
  final String id;
  final String title;
  final String category;
  final String description;
  final String location;
  final DateTime dateCreated;
  final String status; // HILANG, DITEMUKAN, DIVERIFIKASI
  final String userId;
  final String? imageUrl;

  Report({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.dateCreated,
    required this.status,
    required this.userId,
    this.imageUrl,
  });

  // Convert to JSON untuk storage/API
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'description': description,
    'location': location,
    'dateCreated': dateCreated.toIso8601String(),
    'status': status,
    'userId': userId,
    'imageUrl': imageUrl,
  };

  // Create from JSON
  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    category: json['category'] ?? '',
    description: json['description'] ?? '',
    location: json['location'] ?? '',
    dateCreated: DateTime.parse(json['dateCreated'] ?? DateTime.now().toIso8601String()),
    status: json['status'] ?? 'HILANG',
    userId: json['userId'] ?? '',
    imageUrl: json['imageUrl'],
  );
}
