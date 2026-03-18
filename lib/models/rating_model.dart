class RatingModel {
  final String id;
  final String busId;
  final String route;
  final int stars;
  final List<String> tags;
  final String comment;
  final DateTime createdAt;

  RatingModel({
    required this.id,
    required this.busId,
    required this.route,
    required this.stars,
    required this.tags,
    required this.comment,
    required this.createdAt,
  });

  RatingModel copyWith({
    String? id,
    String? busId,
    String? route,
    int? stars,
    List<String>? tags,
    String? comment,
    DateTime? createdAt,
  }) {
    return RatingModel(
      id: id ?? this.id,
      busId: busId ?? this.busId,
      route: route ?? this.route,
      stars: stars ?? this.stars,
      tags: tags ?? this.tags,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] ?? '',
      busId: json['busId'] ?? '',
      route: json['route'] ?? '',
      stars: json['stars'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busId': busId,
      'route': route,
      'stars': stars,
      'tags': tags,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
