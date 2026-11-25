import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_config.dart';
import '../../constants/app_constants.dart';
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

  @override
  Future<List<VenueClosure>> getVenueClosures({
    required String venueId,
    required DateTime date,
  }) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      final response = await Supabase.instance.client
          .from('closures')
          .select()
          .eq('venue_id', venueId)
          .isFilter('court_id', null)
          .eq('tanggal', dateStr)
          .order('jam_mulai', ascending: true);

      final list = response as List<dynamic>;
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return VenueClosure(
          id: map['id'] as String,
          venueId: map['venue_id'] as String,
          courtId: map['court_id'] as String?,
          date: DateTime.parse(map['tanggal'] as String),
          startHour: (map['jam_mulai'] as num).toInt(),
          endHour: (map['jam_selesai'] as num).toInt(),
          reason: (map['alasan'] as String? ?? '').trim(),
        );
      }).toList();
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in getVenueClosures: message=${e.message}, code=${e.code}');
      throw CourtServerException(e.message);
    } catch (e) {
      _log('SUPABASE Exception in getVenueClosures: $e');
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
  Future<List<UnavailableTimeSlot>> getMergedUnavailableSlots({
    required String courtId,
    required DateTime date,
  }) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      final courtRes = await Supabase.instance.client
          .from('courts')
          .select('venue_id, venues(nama)')
          .eq('id', courtId)
          .maybeSingle();

      final venueId = courtRes?['venue_id'] as String? ??
          AppConfig.authRepository.currentUser?.venue?.id ??
          '';

      final venueMap = courtRes?['venues'] as Map<String, dynamic>?;
      final fetchedVenueName = (venueMap?['nama'] as String?)?.trim();
      final venueName = (fetchedVenueName != null && fetchedVenueName.isNotEmpty)
          ? fetchedVenueName
          : (AppConfig.authRepository.currentUser?.venue?.name.trim() ?? 'venue');

      final slots = <UnavailableTimeSlot>[];

      if (venueId.isNotEmpty) {
        final availabilitySlots = await AppConfig.bookingRepository.getVenueAvailability(
          venueId: venueId,
          date: date,
          courtId: courtId,
        );
        for (final s in availabilitySlots) {
          if (s.statusType == SlotStatusType.booked || s.statusType == SlotStatusType.onHold) {
            slots.add(s);
          }
        }
      }

      final closuresRes = await Supabase.instance.client
          .from('closures')
          .select()
          .eq('venue_id', venueId)
          .eq('tanggal', dateStr);

      final closuresList = closuresRes as List<dynamic>;
      for (final item in closuresList) {
        final map = item as Map<String, dynamic>;
        final itemCourtId = map['court_id'] as String?;

        if (itemCourtId != null && itemCourtId != courtId) {
          continue;
        }

        final isWholeVenue = itemCourtId == null;
        final startH = (map['jam_mulai'] as num).toInt();
        final endH = (map['jam_selesai'] as num).toInt();
        final reason = (map['alasan'] as String? ?? '').trim();

        final noteText = isWholeVenue
            ? (reason.isNotEmpty
                ? '$reason • Seluruh $venueName ditutup'
                : 'Seluruh $venueName ditutup')
            : (reason.isNotEmpty ? reason : 'Ditutup');

        slots.add(UnavailableTimeSlot(
          courtId: itemCourtId,
          startHour: startH,
          endHour: endH,
          statusLabel: 'Ditutup',
          note: noteText,
          statusType: SlotStatusType.closed,
          closureId: map['id'] as String,
          sourceMark: isWholeVenue ? SlotSourceMark.venue : SlotSourceMark.court,
        ));
      }

      slots.sort((a, b) => a.startHour.compareTo(b.startHour));
      return slots;
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in getMergedUnavailableSlots: message=${e.message}, code=${e.code}');
      throw CourtServerException(e.message);
    } catch (e) {
      _log('SUPABASE Exception in getMergedUnavailableSlots: $e');
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
  Future<ClosureSaveResult> addVenueClosure(
    VenueClosure closure, {
    bool confirmed = false,
  }) async {
    final dateStr =
        '${closure.date.year}-${closure.date.month.toString().padLeft(2, '0')}-${closure.date.day.toString().padLeft(2, '0')}';

    try {
      final response = await Supabase.instance.client.rpc(
        'create_closure',
        params: {
          'p_court_id': closure.courtId,
          'p_tanggal': dateStr,
          'p_jam_mulai': closure.startHour,
          'p_jam_selesai': closure.endHour,
          'p_alasan': closure.reason,
          'p_konfirmasi': confirmed,
        },
      );

      final resMap = Map<String, dynamic>.from(response as Map<String, dynamic>);
      final dibuat = resMap['dibuat'] as bool? ?? false;
      final benturan = (resMap['benturan'] as num? ?? 0).toInt();
      final id = resMap['id'] as String?;

      return ClosureSaveResult(
        saved: dibuat,
        conflictCount: benturan,
        closureId: id,
      );
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in addVenueClosure: code=${e.code}, message=${e.message}');
      if (e.code == 'BK012') {
        throw const ClosureOverlapException();
      }
      if (e.code == 'BK010') {
        throw const ClosureNotAdminException();
      }
      throw CourtServerException(e.message);
    } catch (e) {
      _log('SUPABASE Exception in addVenueClosure: $e');
      if (isNetworkError(e)) {
        throw const CourtNetworkException();
      }
      if (e is CourtServerException ||
          e is ClosureOverlapException ||
          e is ClosureNotAdminException) {
        rethrow;
      }
      throw CourtServerException(e.toString());
    }
  }

  @override
  Future<void> deleteVenueClosure(String closureId) async {
    try {
      final response = await Supabase.instance.client.rpc(
        'delete_closure',
        params: {
          'p_id': closureId,
        },
      );
      _log('SUPABASE deleteVenueClosure response: $response');
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in deleteVenueClosure: code=${e.code}, message=${e.message}');
      throw CourtServerException(e.message);
    } catch (e) {
      _log('SUPABASE Exception in deleteVenueClosure: $e');
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
  Future<bool> isFullDayVenueClosed({
    required String venueId,
    required DateTime date,
  }) async {
    final closures = await getVenueClosures(venueId: venueId, date: date);
    return closures.any((vc) => vc.isFullDay);
  }

  @override
  Future<bool> isFullDayCourtClosed({
    required String courtId,
    required DateTime date,
  }) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      final response = await Supabase.instance.client
          .from('closures')
          .select()
          .eq('court_id', courtId)
          .eq('tanggal', dateStr);

      final list = response as List<dynamic>;
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final startH = (map['jam_mulai'] as num).toInt();
        final endH = (map['jam_selesai'] as num).toInt();
        if (startH <= AppConstants.operationalStartHour &&
            endH >= AppConstants.operationalEndHour) {
          return true;
        }
      }
      return false;
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in isFullDayCourtClosed: message=${e.message}, code=${e.code}');
      throw CourtServerException(e.message);
    } catch (e) {
      _log('SUPABASE Exception in isFullDayCourtClosed: $e');
      if (isNetworkError(e)) {
        throw const CourtNetworkException();
      }
      if (e is CourtServerException) {
        rethrow;
      }
      throw CourtServerException(e.toString());
    }
  }
}
