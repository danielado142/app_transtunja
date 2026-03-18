class MapSummaryModel {
  final String stopName;
  final String etaText;
  final String routeName;

  const MapSummaryModel({
    required this.stopName,
    required this.etaText,
    required this.routeName,
  });

  MapSummaryModel copyWith({
    String? stopName,
    String? etaText,
    String? routeName,
  }) {
    return MapSummaryModel(
      stopName: stopName ?? this.stopName,
      etaText: etaText ?? this.etaText,
      routeName: routeName ?? this.routeName,
    );
  }

  factory MapSummaryModel.fromJson(Map<String, dynamic> json) {
    return MapSummaryModel(
      stopName: json['stopName'] ?? '',
      etaText: json['etaText'] ?? '',
      routeName: json['routeName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'stopName': stopName, 'etaText': etaText, 'routeName': routeName};
  }
}
