import '../constants/app_constants.dart';
import '../models/booking.dart';
import '../models/court.dart';
import '../models/unavailable_time_slot.dart';
import '../models/venue_closure.dart';
import 'repositories/auth_repository_impl.dart';
import 'mock_data.dart';

/// Abstract repository contract for Court (Lapangan) & Schedule Closure data operations
abstract class CourtRepository {
  Future<List<Court>> getAllCourts();
  Future<List<Court>> getPopularCourts();
  Future<List<Court>> getCourtsByCategory(String category);
  Future<List<Court>> searchCourts(String query);
  Future<List<Court>> getAdminCourts();
  Future<void> addCourt(Court court);
  Future<void> updateCourt(Court court);
  Future<void> deleteCourt(String courtId);
  Future<String> getUserName();
  Future<String> getGreeting();

  // Venue & Court Closures Management
  Future<List<VenueClosure>> getVenueClosures({
    required String venueId,
    required DateTime date,
  });

  Future<List<UnavailableTimeSlot>> getMergedUnavailableSlots({
    required String courtId,
    required DateTime date,
  });

  Future<void> addVenueClosure(VenueClosure closure);
  Future<void> deleteVenueClosure(String closureId);

  Future<int> countConflictingBookings({
    String? courtId,
    required DateTime date,
    required int startHour,
    required int endHour,
  });

  Future<bool> hasOverlappingClosure({
    String? courtId,
    required DateTime date,
    required int startHour,
    required int endHour,
  });

  Future<bool> isFullDayVenueClosed({
    required String venueId,
    required DateTime date,
  });

  Future<bool> isFullDayCourtClosed({
    required String courtId,
    required DateTime date,
  });
}

/// Helper to compare dates ignoring time component
bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Fake implementation of CourtRepository using MockData
class FakeCourtRepository implements CourtRepository {
  /// In-memory storage of admin venue courts
  static final List<Court> _adminCourts = List.from(MockData.allCourts);

  /// In-memory storage of venue and court closures
  static final List<VenueClosure> _venueClosures = _initMockClosures();

  static List<VenueClosure> _initMockClosures() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));

    return [
      // 1. Penutupan satu lapangan hari ini (Arena Futsal A, 13.00 - 14.00, Perawatan)
      VenueClosure(
        id: 'closure_today_futsal',
        venueId: MockData.sportivaCenter.id,
        courtId: 'court_1',
        date: today,
        startHour: 13,
        endHour: 14,
        reason: 'Perawatan',
      ),
      // 2. Penutupan satu lapangan besok (Arena Futsal A, 13.00 - 14.00, Perawatan)
      VenueClosure(
        id: 'closure_tomorrow_futsal',
        venueId: MockData.sportivaCenter.id,
        courtId: 'court_1',
        date: tomorrow,
        startHour: 13,
        endHour: 14,
        reason: 'Perawatan',
      ),
      // 3. Penutupan venue seharian lusa (Seluruh Sportiva Center, 08.00 - 24.00, Acara internal)
      VenueClosure(
        id: 'closure_lusa_venue',
        venueId: MockData.sportivaCenter.id,
        courtId: null,
        date: dayAfterTomorrow,
        startHour: AppConstants.operationalStartHour,
        endHour: AppConstants.operationalEndHour,
        reason: 'Acara internal',
      ),
    ];
  }

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
  Future<void> addCourt(Court court) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // TODO: Di server ini disimpan di database dan foto di storage.
    _adminCourts.add(court);
  }

  @override
  Future<void> updateCourt(Court court) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // TODO: Di server ini disimpan di database dan foto di storage.
    final index = _adminCourts.indexWhere((c) => c.id == court.id);
    if (index != -1) {
      _adminCourts[index] = court;
    }
  }

  @override
  Future<void> deleteCourt(String courtId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // TODO: Di server hapus = soft delete dan booking tetap valid.
    _adminCourts.removeWhere((c) => c.id == courtId);
  }

  @override
  Future<String> getUserName() async {
    final active = FakeAuthRepository().currentUser ?? FakeAuthRepository.seedUser;
    return active.name;
  }

  @override
  Future<String> getGreeting() async {
    return MockData.welcomeGreeting;
  }

  // --- VENUE & COURT CLOSURES IMPLEMENTATION ---

  @override
  Future<List<VenueClosure>> getVenueClosures({
    required String venueId,
    required DateTime date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // TODO: Di server ini mengambil data dari tabel venue_closures dengan filter venue_id, date, dan court_id IS NULL.
    return _venueClosures
        .where((vc) =>
            vc.venueId == venueId &&
            vc.isWholeVenue &&
            _isSameDate(vc.date, date))
        .toList();
  }

  @override
  Future<List<UnavailableTimeSlot>> getMergedUnavailableSlots({
    required String courtId,
    required DateTime date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // TODO: Di server ini fungsi/RPC database yang menggabungkan:
    // (1) active bookings dari tabel bookings,
    // (2) penutupan lapangan dari court_closures,
    // (3) penutupan venue dari venue_closures.
    // Layar pengguna (Detail Lapangan, Jadwal Lapangan) akan disambungkan ke fungsi ini di sesi terpisah.

    final targetCourt = _adminCourts.firstWhere(
      (c) => c.id == courtId,
      orElse: () => MockData.allCourts.first,
    );

    final List<UnavailableTimeSlot> slots = [];

    // 1. Booking dari MockData.mockAdminBookings
    final activeBookings = MockData.mockAdminBookings.where((b) {
      if (b.status == BookingStatus.dibatalkan) return false;
      if (b.courtName.toLowerCase() != targetCourt.name.toLowerCase()) return false;
      return _isSameDate(b.playDateTime, date);
    });

    for (final booking in activeBookings) {
      final startH = booking.playDateTime.hour;
      final endH = startH + booking.durationHours;

      if (booking.status == BookingStatus.sudahBayar ||
          booking.status == BookingStatus.selesai) {
        slots.add(UnavailableTimeSlot(
          startHour: startH,
          endHour: endH,
          statusLabel: 'Dipesan',
          note: 'Booking sudah dibayar',
          statusType: SlotStatusType.booked,
          sourceMark: SlotSourceMark.court,
        ));
      } else if (booking.status == BookingStatus.belumBayar) {
        slots.add(UnavailableTimeSlot(
          startHour: startH,
          endHour: endH,
          statusLabel: 'Ditahan sementara',
          note: 'Menunggu pembayaran',
          statusType: SlotStatusType.onHold,
          sourceMark: SlotSourceMark.court,
        ));
      }
    }

    // 2. Penutupan Lapangan
    final courtClosures = _venueClosures.where((vc) =>
        vc.courtId == courtId && _isSameDate(vc.date, date));
    for (final closure in courtClosures) {
      slots.add(UnavailableTimeSlot(
        startHour: closure.startHour,
        endHour: closure.endHour,
        statusLabel: 'Ditutup',
        note: closure.reason,
        statusType: SlotStatusType.closed,
        closureId: closure.id,
        sourceMark: SlotSourceMark.court,
      ));
    }

    // 3. Penutupan Venue (Seluruh Venue)
    final venueClosures = _venueClosures.where((vc) =>
        vc.isWholeVenue &&
        vc.venueId == targetCourt.venue.id &&
        _isSameDate(vc.date, date));
    for (final closure in venueClosures) {
      slots.add(UnavailableTimeSlot(
        startHour: closure.startHour,
        endHour: closure.endHour,
        statusLabel: 'Ditutup',
        note: '${closure.reason} • Seluruh ${MockData.sportivaCenter.name} ditutup',
        statusType: SlotStatusType.closed,
        closureId: closure.id,
        sourceMark: SlotSourceMark.venue,
      ));
    }

    // Urutkan berdasarkan jam mulai naik
    slots.sort((a, b) => a.startHour.compareTo(b.startHour));
    return slots;
  }

  @override
  Future<void> addVenueClosure(VenueClosure closure) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // TODO: Di server simpan ke tabel venue_closures / court_closures.
    _venueClosures.add(closure);
  }

  @override
  Future<void> deleteVenueClosure(String closureId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // TODO: Di server hapus record dari tabel venue_closures.
    _venueClosures.removeWhere((vc) => vc.id == closureId);
  }

  @override
  Future<int> countConflictingBookings({
    String? courtId,
    required DateTime date,
    required int startHour,
    required int endHour,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // TODO: Di server ini menghitung jumlah booking aktif yang tumpang tindih dengan rentang jam pada cakupan.
    int count = 0;
    for (final booking in MockData.mockAdminBookings) {
      if (booking.status == BookingStatus.dibatalkan) continue;
      if (!_isSameDate(booking.playDateTime, date)) continue;

      if (courtId != null && courtId.isNotEmpty) {
        final court = _adminCourts.firstWhere(
          (c) => c.id == courtId,
          orElse: () => MockData.allCourts.first,
        );
        if (booking.courtName.toLowerCase() != court.name.toLowerCase()) continue;
      }

      final bStart = booking.playDateTime.hour;
      final bEnd = bStart + booking.durationHours;

      // Overlap condition: bStart < endHour && bEnd > startHour
      if (bStart < endHour && bEnd > startHour) {
        count++;
      }
    }
    return count;
  }

  @override
  Future<bool> hasOverlappingClosure({
    String? courtId,
    required DateTime date,
    required int startHour,
    required int endHour,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // TODO: Di server periksa tumpang tindih penutupan pada cakupan yang SAMA.
    for (final vc in _venueClosures) {
      if (!_isSameDate(vc.date, date)) continue;

      final isSameScope = (courtId == null || courtId.isEmpty)
          ? vc.isWholeVenue
          : vc.courtId == courtId;

      if (!isSameScope) continue;

      if (vc.startHour < endHour && vc.endHour > startHour) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<bool> isFullDayVenueClosed({
    required String venueId,
    required DateTime date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // TODO: Di server periksa apakah ada SATU penutupan venue yang meliputi seluruh jam operasional.
    return _venueClosures.any((vc) =>
        vc.venueId == venueId &&
        vc.isWholeVenue &&
        _isSameDate(vc.date, date) &&
        vc.isFullDay);
  }

  @override
  Future<bool> isFullDayCourtClosed({
    required String courtId,
    required DateTime date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // TODO: Di server periksa apakah ada SATU penutupan lapangan yang meliputi seluruh jam operasional.
    return _venueClosures.any((vc) =>
        vc.courtId == courtId &&
        _isSameDate(vc.date, date) &&
        vc.isFullDay);
  }
}
