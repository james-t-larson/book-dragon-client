import '../models/tourney.dart';
import '../services/tourney_service.dart';

class TourneyRepository {
  final TourneyService _service;

  TourneyRepository({required TourneyService service}) : _service = service;

  Future<Tourney?> getActiveTourney() async {
    return await _service.getActiveTourney();
  }

  Future<Tourney> joinTourney(String inviteCode) async {
    return await _service.joinTourney(inviteCode);
  }

  Future<Tourney> createTourney(CreateTourneyRequest request) async {
    return await _service.createTourney(request);
  }
}
