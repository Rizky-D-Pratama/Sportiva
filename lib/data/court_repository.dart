import '../models/court.dart';
import 'mock_data.dart';

/// Abstract repository contract for Court (Lapangan) data operations
abstract class CourtRepository {
  Future<List<Court>> getAllCourts();
  Future<List<Court>> getPopularCourts();
  Future<List<Court>> getCourtsByCategory(String category);
  Future<List<Court>> searchCourts(String query);
  Future<String> getUserName();
  Future<String> getGreeting();
}

/// Fake implementation of CourtRepository using MockData
class FakeCourtRepository implements CourtRepository {
  @override
  Future<List<Court>> getAllCourts() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return MockData.allCourts;
  }

  @override
  Future<List<Court>> getPopularCourts() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return MockData.popularCourts;
  }

  @override
  Future<List<Court>> getCourtsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return MockData.allCourts
        .where((c) => c.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<List<Court>> searchCourts(String query) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (query.isEmpty) return MockData.allCourts;
    return MockData.allCourts.where((c) {
      final q = query.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.venue.name.toLowerCase().contains(q) ||
          c.venue.location.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<String> getUserName() async {
    return MockData.userName;
  }

  @override
  Future<String> getGreeting() async {
    return MockData.welcomeGreeting;
  }
}
