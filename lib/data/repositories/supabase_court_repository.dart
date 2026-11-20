import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_config.dart';
import '../../constants/app_images.dart';
import '../../models/court.dart';
import '../../models/unavailable_time_slot.dart';
import '../../models/venue.dart';
import '../../models/venue_closure.dart';
import '../court_repository.dart';
import '../mock_data.dart';
import 'supabase_auth_repository.dart';

/// Supabase implementation of CourtRepository for Sportiva
class SupabaseCourtRepository implements CourtRepository {
  /// Instance of FakeCourtRepository for temporary write operations and closures
  final FakeCourtRepository _fakeRepo = FakeCourtRepository();

  /// Logs debug messages in kDebugMode only
  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Maps category string to corresponding asset image path in AppImages
  String _getCategoryImageUrl(String category) {
    final catLower = category.toLowerCase().trim();
    switch (catLower) {
      case 'futsal':
        return AppImages.soccer;
      case 'voli':
        return AppImages.volleyball;
      case 'basket':
        return AppImages.basket;
      case 'badminton':
        return AppImages.badminton;
      default:
        throw CourtServerException('Unknown court category: $category');
    }
  }

  /// Maps a single JSON row from Supabase courts join venues table to a Court model
  Court _mapJsonToCourt(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final name = json['nama'] as String?;
    final category = json['kategori'] as String?;
    final pricePerHour = json['harga_per_jam'] as num?;

    if (id == null || name == null || category == null || pricePerHour == null) {
      throw const CourtServerException('Missing required court data from server');
    }

    final venueMap = json['venues'] as Map<String, dynamic>?;
    if (venueMap == null) {
      throw const CourtServerException('Venue data is missing');
    }

    final venueId = venueMap['id'] as String?;
    final venueName = venueMap['nama'] as String?;
    final venueLocation = venueMap['alamat'] as String?;

    if (venueId == null || venueName == null) {
      throw const CourtServerException('Missing required venue fields from server');
    }

    final venue = Venue(
      id: venueId,
      name: venueName,
      location: venueLocation ?? '',
    );

    final rating = (json['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = (json['jumlah_ulasan'] as num?)?.toInt() ?? 0;
    final facilitiesRaw = json['fasilitas'] as List?;
    final facilities = facilitiesRaw?.map((e) => e.toString()).toList() ?? [];
    final description = json['deskripsi'] as String? ?? '';
    final isActive = json['is_active'] as bool? ?? true;

    final imageUrl = _getCategoryImageUrl(category);

    return Court(
      id: id,
      name: name,
      category: category,
      venue: venue,
      pricePerHour: pricePerHour.toInt(),
      rating: rating,
      reviewCount: reviewCount,
      imageUrl: imageUrl,
      isFullToday: false, // SEMENTARA irisan 3
      isActive: isActive,
      facilities: facilities,
      description: description,
      unavailableTimeSlots: const [], // SEMENTARA irisan 3
    );
  }

  /// Helper to handle PostgrestException for write operations
  void _handlePostgrestException(PostgrestException e, String contextMessage) {
    _log('SUPABASE PostgrestException in $contextMessage: message=${e.message}, code=${e.code}, details=${e.details}');
    final msgLower = e.message.toLowerCase();
    final detailsLower = e.details?.toString().toLowerCase() ?? '';
    if (e.code == '23505' &&
        (msgLower.contains('courts_venue_nama_uq') || detailsLower.contains('courts_venue_nama_uq'))) {
      throw const CourtDuplicateNameException();
    }
    throw CourtServerException(e.message);
  }

  @override
  Future<List<Court>> getAllCourts() async {
    try {
      final response = await Supabase.instance.client
          .from('courts')
          .select('*, venues(*)')
          .eq('is_active', true)
          .isFilter('dihapus_pada', null)
          .order('created_at', ascending: true);

      final list = response as List<dynamic>;
      return list.map((item) => _mapJsonToCourt(item as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in getAllCourts: message=${e.message}, code=${e.code}');
      throw CourtServerException(e.message);
    } catch (e) {
      _log('SUPABASE Exception in getAllCourts: $e');
      if (isNetworkError(e)) {
        throw const CourtNetworkException();
      }
      if (e is CourtServerException) {
        rethrow;
      }
      throw CourtServerException(e.toString());
    }
  }

  @override
  Future<List<Court>> getPopularCourts() async {
    // SEMENTARA irisan 3: aturan popularitas berdasar booking dibayar
    try {
      final response = await Supabase.instance.client
          .from('courts')
          .select('*, venues(*)')
          .eq('is_active', true)
          .isFilter('dihapus_pada', null)
          .order('rating', ascending: false)
          .order('jumlah_ulasan', ascending: false)
          .order('nama', ascending: true)
          .limit(2);

      final list = response as List<dynamic>;
      return list.map((item) => _mapJsonToCourt(item as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in getPopularCourts: message=${e.message}, code=${e.code}');
      throw CourtServerException(e.message);
    } catch (e) {
      _log('SUPABASE Exception in getPopularCourts: $e');
      if (isNetworkError(e)) {
        throw const CourtNetworkException();
      }
      if (e is CourtServerException) {
        rethrow;
      }
      throw CourtServerException(e.toString());
    }
  }

  @override
  Future<List<Court>> getCourtsByCategory(String category) async {
    try {
      final response = await Supabase.instance.client
          .from('courts')
          .select('*, venues(*)')
          .eq('is_active', true)
          .isFilter('dihapus_pada', null)
          .eq('kategori', category)
          .order('created_at', ascending: true);

      final list = response as List<dynamic>;
      return list.map((item) => _mapJsonToCourt(item as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in getCourtsByCategory: message=${e.message}, code=${e.code}');
      throw CourtServerException(e.message);
    } catch (e) {
      _log('SUPABASE Exception in getCourtsByCategory: $e');
      if (isNetworkError(e)) {
        throw const CourtNetworkException();
      }
      if (e is CourtServerException) {
        rethrow;
      }
      throw CourtServerException(e.toString());
    }
  }

  @override
  Future<List<Court>> searchCourts(String query) async {
    // Client-side filtering over active courts to prevent query string injection
    // Fields filtered are identical to FakeCourtRepository: name, venue.name, venue.location, category
    final activeCourts = await getAllCourts();
    if (query.trim().isEmpty) return activeCourts;
    final q = query.trim().toLowerCase();
    return activeCourts.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.venue.name.toLowerCase().contains(q) ||
          c.venue.location.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<List<Court>> getAdminCourts() async {
    final adminVenue = AppConfig.authRepository.currentUser?.venue;
    if (adminVenue == null) {
      // Admin without venue returns empty list
      return [];
    }

    try {
      final response = await Supabase.instance.client
          .from('courts')
          .select('*, venues(*)')
          .eq('venue_id', adminVenue.id)
          .isFilter('dihapus_pada', null)
          .order('created_at', ascending: true);

      final list = response as List<dynamic>;
      return list.map((item) => _mapJsonToCourt(item as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in getAdminCourts: message=${e.message}, code=${e.code}');
      throw CourtServerException(e.message);
    } catch (e) {
      _log('SUPABASE Exception in getAdminCourts: $e');
      if (isNetworkError(e)) {
        throw const CourtNetworkException();
      }
      if (e is CourtServerException) {
        rethrow;
      }
      throw CourtServerException(e.toString());
    }
  }

  @override
  Future<void> addCourt(Court court) async {
    final venueId = AppConfig.authRepository.currentUser?.venue?.id;
    if (venueId == null) {
      throw const CourtServerException('Venue data is missing');
    }

    try {
      final response = await Supabase.instance.client.from('courts').insert({
        'venue_id': venueId,
        'nama': court.name.trim(),
        'kategori': court.category,
        'harga_per_jam': court.pricePerHour,
        'fasilitas': court.facilities,
        'deskripsi': court.description,
        'is_active': court.isActive,
        'foto': null,
      }).select();

      final list = response as List<dynamic>;
      if (list.length != 1) {
        throw const CourtServerException('Gagal menambahkan lapangan');
      }
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'addCourt');
    } catch (e) {
      _log('SUPABASE Exception in addCourt: $e');
      if (isNetworkError(e)) {
        throw const CourtNetworkException();
      }
      if (e is CourtServerException || e is CourtDuplicateNameException) {
        rethrow;
      }
      throw CourtServerException(e.toString());
    }
  }

  @override
  Future<void> updateCourt(Court court) async {
    try {
      final response = await Supabase.instance.client
          .from('courts')
          .update({
            'nama': court.name.trim(),
            'kategori': court.category,
            'harga_per_jam': court.pricePerHour,
            'fasilitas': court.facilities,
            'deskripsi': court.description,
            'is_active': court.isActive,
          })
          .eq('id', court.id)
          .select();

      final list = response as List<dynamic>;
      if (list.length != 1) {
        throw const CourtServerException('Gagal memperbarui lapangan');
      }
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'updateCourt');
    } catch (e) {
      _log('SUPABASE Exception in updateCourt: $e');
      if (isNetworkError(e)) {
        throw const CourtNetworkException();
      }
      if (e is CourtServerException || e is CourtDuplicateNameException) {
        rethrow;
      }
      throw CourtServerException(e.toString());
    }
  }

  @override
  Future<void> deleteCourt(String courtId) async {
    try {
      final response = await Supabase.instance.client
          .from('courts')
          .update({
            'dihapus_pada': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', courtId)
          .select();

      final list = response as List<dynamic>;
      if (list.length != 1) {
        throw const CourtServerException('Gagal menghapus lapangan');
      }
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in deleteCourt: message=${e.message}, code=${e.code}');
      throw CourtServerException(e.message);
    } catch (e) {
      _log('SUPABASE Exception in deleteCourt: $e');
      if (isNetworkError(e)) {
        throw const CourtNetworkException();
      }
      if (e is CourtServerException) {
        rethrow;
      }
      throw CourtServerException(e.toString());
    }
  }

  @override
  Future<String> getUserName() async {
    final active = AppConfig.authRepository.currentUser;
    return active?.name ?? 'Pengguna';
  }

  @override
  Future<String> getGreeting() async {
    return MockData.welcomeGreeting;
  }

  // SEMENTARA irisan 3: Closures & availability management delegates to FakeCourtRepository
  @override
  Future<List<VenueClosure>> getVenueClosures({
    required String venueId,
    required DateTime date,
  }) async {
    return _fakeRepo.getVenueClosures(venueId: venueId, date: date);
  }

  @override
  Future<List<UnavailableTimeSlot>> getMergedUnavailableSlots({
    required String courtId,
    required DateTime date,
  }) async {
    return _fakeRepo.getMergedUnavailableSlots(courtId: courtId, date: date);
  }

  @override
  Future<void> addVenueClosure(VenueClosure closure) async {
    await _fakeRepo.addVenueClosure(closure);
  }

  @override
  Future<void> deleteVenueClosure(String closureId) async {
    await _fakeRepo.deleteVenueClosure(closureId);
  }

  @override
  Future<int> countConflictingBookings({
    String? courtId,
    required DateTime date,
    required int startHour,
    required int endHour,
  }) async {
    return _fakeRepo.countConflictingBookings(
      courtId: courtId,
      date: date,
      startHour: startHour,
      endHour: endHour,
    );
  }

  @override
  Future<bool> hasOverlappingClosure({
    String? courtId,
    required DateTime date,
    required int startHour,
    required int endHour,
  }) async {
    return _fakeRepo.hasOverlappingClosure(
      courtId: courtId,
      date: date,
      startHour: startHour,
      endHour: endHour,
    );
  }

  @override
  Future<bool> isFullDayVenueClosed({
    required String venueId,
    required DateTime date,
  }) async {
    return _fakeRepo.isFullDayVenueClosed(venueId: venueId, date: date);
  }

  @override
  Future<bool> isFullDayCourtClosed({
    required String courtId,
    required DateTime date,
  }) async {
    return _fakeRepo.isFullDayCourtClosed(courtId: courtId, date: date);
  }
}
