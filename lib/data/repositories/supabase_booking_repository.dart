import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/booking.dart';
import '../../models/court.dart';
import '../../models/unavailable_time_slot.dart';
import '../../utils/date_format_helper.dart';
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

      final json = response as Map<String, dynamic>;

      final id = json['id'] as String;
      final bookingCode = json['kode_booking'] as String;
      final userId = json['user_id'] as String?;
      final tanggalStr = json['tanggal'] as String; // YYYY-MM-DD
      final jamMulai = (json['jam_mulai'] as num).toInt();
      final durasiJam = (json['durasi_jam'] as num).toInt();
      final hargaPerJam = (json['harga_per_jam'] as num).toInt();
      final biayaLayanan = (json['biaya_layanan'] as num).toInt();
      final total = (json['total'] as num).toInt();
      final batasBayarStr = json['batas_bayar'] as String?;
      final namaPemesan = json['nama_pemesan'] as String?;
      final teleponPemesan = json['telepon_pemesan'] as String?;
      final emailPemesan = json['email_pemesan'] as String?;
      final dibuatPadaStr = json['dibuat_pada'] as String?;

      // Correction #1: playDateTime built from tanggal + jam_mulai
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

      // Correction #2: Text formatting for Booking object
      final dateText = DateFormatHelper.formatShortDate(playDateTime);
      final fullDateText = DateFormatHelper.formatDateMonthYear(playDateTime);
      final ticketDateText = DateFormatHelper.formatFullDate(playDateTime);

      String? paymentDeadline;
      if (batasBayarStr != null && batasBayarStr.isNotEmpty) {
        final wibDeadline = DateFormatHelper.parseUtcToWib(batasBayarStr);
        paymentDeadline = DateFormatHelper.formatPaymentDeadline(wibDeadline);
      }

      String? createdDateText;
      if (dibuatPadaStr != null && dibuatPadaStr.isNotEmpty) {
        final wibCreated = DateFormatHelper.parseUtcToWib(dibuatPadaStr);
        createdDateText = DateFormatHelper.formatShortDateWithTime(wibCreated);
      }

      return Booking(
        id: id,
        bookingCode: bookingCode,
        courtName: court.name,
        date: dateText,
        timeRange: timeRange,
        totalPayment: total,
        status: BookingStatus.belumBayar,
        paymentMethod: null, // "Belum memilih metode pembayaran"
        paymentDeadline: paymentDeadline,
        playDateTime: playDateTime,
        userId: userId,
        pricePerHour: hargaPerJam,
        serviceFee: biayaLayanan,
        durationHours: durasiJam,
        createdDateText: createdDateText,
        paymentStatusText: 'Belum bayar',
        userName: namaPemesan,
        userPhone: teleponPemesan,
        userEmail: emailPemesan,
        venueName: court.venue.name,
        facilitiesText: court.facilities.join(' • '),
        courtImageUrl: court.imageUrl,
        fullDateText: fullDateText,
        ticketDateText: ticketDateText,
      );
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
}
