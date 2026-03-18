import '../models/rating_model.dart';
import '../repositories/rating_repository.dart';

class RatingService {
  final RatingRepository _repository = RatingRepository();

  Future<void> submitRating(RatingModel rating) {
    return _repository.submitRating(rating);
  }

  Future<List<RatingModel>> getRatings() {
    return _repository.getRatings();
  }
}
