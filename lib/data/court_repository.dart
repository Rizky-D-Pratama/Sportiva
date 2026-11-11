import '../models/court.dart';
import 'mock_data.dart';

/// Abstract repository contract for Court (Lapangan) data operations
abstract class CourtRepository {
  Future<List<Court>> getAllCourts();
  Future<List<Court>> getPopularCourts();
  Future<List<Court>> getCourtsByCategory(String category);
  Future<List<Court>> searchCourts(String query);
  Future<List<Court>> getAdminCourts();
  Future<void> deleteCourt(String courtId);
  Future<String> getUserName();
  Future<String> getGreeting();
}

/// Fake implementation of CourtRepository using MockData
class FakeCourtRepository implements CourtRepository {
  /// In-memory storage of admin venue courts
  static final List<Court> _adminCourts = List.from(MockData.allCourts);

  @override
  Future<List<Court>> getAllCourts() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _adminCourts.where((c) => c.isActive).toList();
  }

  @override
  Future<List<Court>> getPopularCourts() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _adminCourts.where((c) => c.isActive).toList();
  }

  @override
  Future<List<Court>> getCourtsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _adminCourts
        .where((c) => c.isActive && c.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<List<Court>> searchCourts(String query) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final activeCourts = _adminCourts.where((c) => c.isActive).toList();
    if (query.isEmpty) return activeCourts;
    return activeCourts.where((c) {
      final q = query.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.venue.name.toLowerCase().contains(q) ||
          c.venue.location.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<List<Court>> getAdminCourts() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List.from(_adminCourts);
  }

  @override
  Future<void> deleteCourt(String courtId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // TODO: Di server hapus = soft delete dan booking tetap valid.
    _adminCourts.removeWhere((c) => c.id == courtId);
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
