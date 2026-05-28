class PDF {
  final String id;
  final String title;
  final String filePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  PDF({
    required this.id,
    required this.title,
    required this.filePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PDF.fromJson(Map<String, dynamic> json) {
    return PDF(
      id: json['id'],
      title: json['title'],
      filePath: json['filePath'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
