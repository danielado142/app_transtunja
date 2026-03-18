class DestinationSuggestionModel {
  final String text;

  const DestinationSuggestionModel({required this.text});

  DestinationSuggestionModel copyWith({String? text}) {
    return DestinationSuggestionModel(text: text ?? this.text);
  }

  factory DestinationSuggestionModel.fromJson(Map<String, dynamic> json) {
    return DestinationSuggestionModel(text: json['text'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'text': text};
  }
}
