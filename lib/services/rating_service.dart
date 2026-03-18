import '../models/rating_model.dart';

class RatingService {
  static final List<RatingModel> _ratings = [];

  Future<void> submitRating(RatingModel rating) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ratings.add(rating);
  }

  Future<List<RatingModel>> getRatings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_ratings);
  }
}
