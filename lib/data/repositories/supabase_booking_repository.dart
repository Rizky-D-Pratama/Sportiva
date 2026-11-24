import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/admin_dashboard_data.dart';
import '../../models/booking.dart';
import '../../models/court.dart';
import '../../models/unavailable_time_slot.dart';
import '../../utils/date_format_helper.dart';
import '../../utils/payment_method_helper.dart';
import '../booking_repository.dart';
import 'supabase_auth_repository.dart';

/// Supabase implementation of BookingRepository
class SupabaseBookingRepository implements BookingRepository {
  /// Helper to log debug messages in kDebugMode only
  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Maps a JSON row (from get_my_bookings or create_booking RPC) to a Booking model
  Booking _mapJsonToBooking(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final bookingCode = json['kode_booking'] as String;
    final statusStr = json['status'] as String?;
    final courtId = json['court_id'] as String?;
    final venueId = json['venue_id'] as String?;
    final courtName = json['nama_lapangan'] as String? ?? '';
    final kategori = json['kategori'] as String? ?? '';
    final fasilitasRaw = json['fasilitas'];
    List<String> fasilitas = [];
    if (fasilitasRaw is List) {
      fasilitas = fasilitasRaw.map((e) => e.toString()).toList();
    }
    final foto = json['foto'] as String?;
    final venueName = json['nama_venue'] as String? ?? '';
    final tanggalStr = json['tanggal'] as String; // YYYY-MM-DD
    final jamMulai = (json['jam_mulai'] as num).toInt();
    final durasiJam = (json['durasi_jam'] as num).toInt();
    final hargaPerJam = (json['harga_per_jam'] as num).toInt();
    final biayaLayanan = (json['biaya_layanan'] as num).toInt();
    final total = (json['total'] as num).toInt();
    final batasBayarStr = json['batas_bayar'] as String?;
    final dibuatPadaStr = json['dibuat_pada'] as String?;
    final namaPemesan = json['nama_pemesan'] as String?;
    final teleponPemesan = json['telepon_pemesan'] as String?;
    final emailPemesan = json['email_pemesan'] as String?;
    final userId = json['user_id'] as String?;

    // Optional new fields (can be absent e.g. from create_booking)
    final metodePembayaran = json['metode_pembayaran'] as String?;
    final detailMetode = json['detail_metode'] as String?;
    final dibayarPadaStr = json['dibayar_pada'] as String?;

    final paymentMethod = PaymentMethodHelper.getLabel(metodePembayaran, detailMetode);

    DateTime? paidAt;
    if (dibayarPadaStr != null && dibayarPadaStr.isNotEmpty) {
      paidAt = DateFormatHelper.parseUtcToWib(dibayarPadaStr);
    }

    // Date & Time formatting
    final dateParts = tanggalStr.split('-');
    final playDateTime = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      jamMulai,
    );

    final endHour = jamMulai + durasiJam;
    final timeRange =
        '${jamMulai.toString().padLeft(2, '0')}.00 – ${endHour.toString().padLeft(2, '0')}.00 WIB';

    final dateText = DateFormatHelper.formatShortDate(playDateTime);
    final fullDateText = DateFormatHelper.formatDateMonthYear(playDateTime);
    final ticketDateText = DateFormatHelper.formatFullDate(playDateTime);

    String? paymentDeadline;
    if (batasBayarStr != null && batasBayarStr.isNotEmpty) {
      final wibDeadline = DateFormatHelper.parseUtcToWib(batasBayarStr);
      paymentDeadline = DateFormatHelper.formatPaymentDeadline(wibDeadline);
    }

    DateTime? createdAt;
    String? createdDateText;
    if (dibuatPadaStr != null && dibuatPadaStr.isNotEmpty) {
      createdAt = DateFormatHelper.parseUtcToWib(dibuatPadaStr);
      createdDateText = DateFormatHelper.formatShortDateWithTime(createdAt);
    }

    // Status Mapping: kedaluwarsa -> dibatalkan
    final status = switch (statusStr) {
      'belum_bayar' => BookingStatus.belumBayar,
      'sudah_bayar' => BookingStatus.sudahBayar,
      'selesai' => BookingStatus.selesai,
      'dibatalkan' || 'kedaluwarsa' => BookingStatus.dibatalkan,
      _ => BookingStatus.belumBayar,
    };

    // Image URL resolution
    final courtImageUrl = (foto != null && foto.isNotEmpty)
        ? foto
        : DateFormatHelper.getCategoryImageUrl(kategori);

    return Booking(
      id: id,
      bookingCode: bookingCode,
      courtName: courtName,
      date: dateText,
      timeRange: timeRange,
      totalPayment: total,
      status: status,
      paymentMethod: paymentMethod,
      paymentDeadline: paymentDeadline,
      playDateTime: playDateTime,
      userId: userId,
      courtId: courtId,
      venueId: venueId,
      createdAt: createdAt,
      paidAt: paidAt,
      pricePerHour: hargaPerJam,
      serviceFee: biayaLayanan,
      durationHours: durasiJam,
      createdDateText: createdDateText,
      paymentStatusText: null,
      userName: namaPemesan,
      userPhone: teleponPemesan,
      userEmail: emailPemesan,
      venueName: venueName,
      facilitiesText: fasilitas.isNotEmpty ? fasilitas.join(' • ') : null,
      courtImageUrl: courtImageUrl,
      fullDateText: fullDateText,
      ticketDateText: ticketDateText,
    );
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await Supabase.instance.client.rpc('get_my_bookings');
      final list = response as List<dynamic>;
      return list
          .map((item) => _mapJsonToBooking(item as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in getMyBookings: code=${e.code}, message=${e.message}');
      throw BookingServerException(e.code, e.message);
    } catch (e) {
      _log('SUPABASE Exception in getMyBookings: $e');
      if (isNetworkError(e)) {
        throw const BookingNetworkException();
      }
      if (e is BookingException) {
        rethrow;
      }
      throw BookingServerException(null, e.toString());
    }
  }

  @override
  Future<Booking> createBooking({
    required Court court,
    required DateTime date,
    required int startHour,
    required int durationHours,
  }) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      final response = await Supabase.instance.client.rpc(
        'create_booking',
        params: {
          'p_court_id': court.id,
          'p_tanggal': dateStr,
          'p_jam_mulai': startHour,
          'p_durasi': durationHours,
        },
      );

      final json = Map<String, dynamic>.from(response as Map<String, dynamic>);
      json['court_id'] = court.id;
      json['venue_id'] = court.venue.id;
      json['nama_lapangan'] = court.name;
      json['kategori'] = court.category;
      json['fasilitas'] = court.facilities;
      json['foto'] = court.imageUrl;
      json['nama_venue'] = court.venue.name;
      json['status'] = 'belum_bayar';

      return _mapJsonToBooking(json);
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in createBooking: code=${e.code}, message=${e.message}');
      final code = e.code;
      if (code == 'BK001' || code == 'BK002' || code == 'BK004') {
        throw BookingUnavailableException(code ?? 'BK_UNAVAILABLE', e.message);
      }
      throw BookingServerException(code, e.message);
    } catch (e) {
      _log('SUPABASE Exception in createBooking: $e');
      if (isNetworkError(e)) {
        throw const BookingNetworkException();
      }
      if (e is BookingException) {
        rethrow;
      }
      throw BookingServerException(null, e.toString());
    }
  }

  @override
  Future<List<UnavailableTimeSlot>> getVenueAvailability({
    required String venueId,
    required DateTime date,
    String? courtId,
  }) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      final response = await Supabase.instance.client.rpc(
        'get_venue_availability',
        params: {
          'p_venue_id': venueId,
          'p_tanggal': dateStr,
        },
      );

      final list = response as List<dynamic>;
      final result = <UnavailableTimeSlot>[];

      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final itemCourtId = map['court_id'] as String?;

        if (courtId != null && itemCourtId != courtId) {
          continue;
        }

        final startHour = (map['jam_mulai'] as num).toInt();
        final endHour = (map['jam_selesai'] as num).toInt();
        final status = map['status'] as String?;

        if (status == 'dipesan') {
          result.add(UnavailableTimeSlot(
            courtId: itemCourtId,
            startHour: startHour,
            endHour: endHour,
            statusLabel: 'Dipesan',
            note: 'Tidak dapat dibooking',
            statusType: SlotStatusType.booked,
          ));
        } else if (status == 'belum_bayar') {
          result.add(UnavailableTimeSlot(
            courtId: itemCourtId,
            startHour: startHour,
            endHour: endHour,
            statusLabel: 'Ditahan Sementara',
            note: 'Menunggu pembayaran - tidak dapat dipesan',
            statusType: SlotStatusType.onHold,
          ));
        }
      }

      return result;
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in getVenueAvailability: code=${e.code}, message=${e.message}');
      throw BookingServerException(e.code, e.message);
    } catch (e) {
      _log('SUPABASE Exception in getVenueAvailability: $e');
      if (isNetworkError(e)) {
        throw const BookingNetworkException();
      }
      if (e is BookingException) {
        rethrow;
      }
      throw BookingServerException(null, e.toString());
    }
  }

  @override
  Future<PaymentSession> createPaymentSession(String bookingId) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'create-booking-payment',
        body: {'booking_id': bookingId},
      );

      final status = response.status;
      final data = response.data;

      if (status == 200 && data is Map<String, dynamic>) {
        final orderId = data['order_id'] as String?;
        final token = data['token'] as String?;
        final redirectUrl = data['redirect_url'] as String?;
        if (orderId != null && token != null && redirectUrl != null) {
          return PaymentSession(
            orderId: orderId,
            token: token,
            redirectUrl: redirectUrl,
          );
        }
      }

      String? errorCode;
      if (data is Map<String, dynamic> && data.containsKey('error')) {
        errorCode = data['error'] as String?;
      } else if (data is String && data.isNotEmpty) {
        try {
          final parsed = jsonDecode(data);
          if (parsed is Map<String, dynamic>) {
            errorCode = parsed['error'] as String?;
          }
        } catch (_) {}
      }

      _mapErrorCodeToPaymentException(errorCode, status);
    } on FunctionException catch (e) {
      _log('SUPABASE FunctionException in createPaymentSession: status=${e.status}, details=${e.details}');
      String? errorCode;
      final details = e.details;
      if (details is Map<String, dynamic>) {
        errorCode = details['error'] as String?;
      } else if (details is String && details.isNotEmpty) {
        try {
          final parsed = jsonDecode(details);
          if (parsed is Map<String, dynamic>) {
            errorCode = parsed['error'] as String?;
          }
        } catch (_) {}
      }
      _mapErrorCodeToPaymentException(errorCode, e.status);
    } catch (e) {
      _log('SUPABASE Exception in createPaymentSession: $e');
      if (isNetworkError(e)) {
        throw const PaymentNetworkException();
      }
      if (e is PaymentException) {
        rethrow;
      }
      throw PaymentServerException(e.toString());
    }
  }

  Never _mapErrorCodeToPaymentException(String? errorCode, int? httpStatus) {
    if (errorCode != null && errorCode.isNotEmpty) {
      switch (errorCode) {
        case 'expired':
        case 'time_too_short':
          throw const PaymentExpiredException();
        case 'not_payable':
          throw const PaymentNotPayableException();
        case 'unauthorized':
          throw const PaymentUnauthorizedException();
        case 'midtrans_error':
        case 'server_error':
        case 'invalid_request':
        case 'not_found':
          throw const PaymentServerException();
        default:
          throw const PaymentServerException();
      }
    }

    if (httpStatus == 401) {
      throw const PaymentUnauthorizedException();
    }
    throw const PaymentServerException();
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      final response = await Supabase.instance.client.rpc(
        'cancel_booking',
        params: {'p_booking_id': bookingId},
      );
      _log('SUPABASE cancelBooking response: $response');
      if (response == 'dibatalkan') {
        unawaited(_cancelPaymentTransaction(bookingId));
      }
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in cancelBooking: code=${e.code}, message=${e.message}');
      final code = e.code;
      if (code == 'BK009') {
        throw BookingNotCancellableException(e.message);
      }
      if (code == 'BK008') {
        throw BookingNotFoundException(e.message);
      }
      if (code == 'BK007') {
        throw BookingUnauthorizedException(e.message);
      }
      throw BookingServerException(code, e.message);
    } catch (e) {
      _log('SUPABASE Exception in cancelBooking: $e');
      if (isNetworkError(e)) {
        throw const BookingNetworkException();
      }
      if (e is BookingException) {
        rethrow;
      }
      throw BookingServerException(null, e.toString());
    }
  }

  /// Helper to invoke Edge Function `cancel-payment-transaction` in a best-effort manner.
  /// All errors are swallowed internally and never rethrown or propagated.
  Future<void> _cancelPaymentTransaction(String bookingId) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'cancel-payment-transaction',
        body: {'booking_id': bookingId},
      );
      _log('SUPABASE cancelPaymentTransaction status: ${response.status}');
    } catch (e) {
      _log('SUPABASE Exception in cancelPaymentTransaction: ${e.runtimeType}');
    }
  }

  @override
  Future<List<Booking>> getAdminBookings({
    DateTime? tanggal,
    String? courtId,
    String? status,
    String? search,
  }) async {
    final isSearchActive = search != null && search.trim().isNotEmpty;
    final dateStr = isSearchActive || tanggal == null
        ? null
        : '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';

    try {
      final response = await Supabase.instance.client.rpc(
        'get_admin_bookings',
        params: {
          'p_tanggal': dateStr,
          'p_court_id': (courtId != null && courtId.isNotEmpty) ? courtId : null,
          'p_status': (status != null && status.isNotEmpty) ? status : null,
          'p_search': isSearchActive ? search.trim() : null,
        },
      );

      final list = response as List<dynamic>;
      return list
          .map((item) => _mapJsonToBooking(item as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in getAdminBookings: code=${e.code}, message=${e.message}');
      if (e.code == 'BK007') {
        throw const BookingUnauthorizedException();
      }
      if (e.code == 'BK010') {
        throw const BookingNotAdminException();
      }
      throw BookingServerException(e.code, e.message);
    } catch (e) {
      _log('SUPABASE Exception in getAdminBookings: $e');
      if (isNetworkError(e)) {
        throw const BookingNetworkException();
      }
      if (e is BookingException) {
        rethrow;
      }
      throw BookingServerException(null, e.toString());
    }
  }

  @override
  Future<AdminDashboardData> getAdminDashboard() async {
    try {
      final response = await Supabase.instance.client.rpc('get_admin_dashboard');
      final json = Map<String, dynamic>.from(response as Map<String, dynamic>);

      final totalBookingMonth = (json['total_booking_bulan'] as num).toInt();
      final todayBookingCount = (json['booking_hari_ini'] as num).toInt();
      final totalCourtsCount = (json['total_lapangan'] as num).toInt();
      final monthlyRevenue = (json['pendapatan_bulan'] as num).toInt();

      final bookingMingguRaw = json['booking_minggu'] as List<dynamic>? ?? [];
      final weeklyBookingCounts = bookingMingguRaw.map((e) => (e as num).toInt()).toList();

      final bookingTerbaruRaw = json['booking_terbaru'] as List<dynamic>? ?? [];
      final recentBookings = bookingTerbaruRaw
          .map((item) => _mapJsonToBooking(item as Map<String, dynamic>))
          .toList();

      return AdminDashboardData(
        totalBookingMonth: totalBookingMonth,
        todayBookingCount: todayBookingCount,
        totalCourtsCount: totalCourtsCount,
        monthlyRevenueRupiah: monthlyRevenue,
        weeklyBookingCounts: weeklyBookingCounts,
        recentBookings: recentBookings,
      );
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in getAdminDashboard: code=${e.code}, message=${e.message}');
      if (e.code == 'BK007') {
        throw const BookingUnauthorizedException();
      }
      if (e.code == 'BK010') {
        throw const BookingNotAdminException();
      }
      throw BookingServerException(e.code, e.message);
    } catch (e) {
      _log('SUPABASE Exception in getAdminDashboard: $e');
      if (isNetworkError(e)) {
        throw const BookingNetworkException();
      }
      if (e is BookingException) {
        rethrow;
      }
      throw BookingServerException(null, e.toString());
    }
  }
}
