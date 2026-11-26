import '../models/admin_dashboard_data.dart';
import '../models/booking.dart';
import '../models/court.dart';
import '../models/reschedule_option.dart';
import '../models/unavailable_time_slot.dart';

/// Payment session response model returned from Edge Function create-booking-payment
class PaymentSession {
  final String orderId;
  final String token;
  final String redirectUrl;

  const PaymentSession({
    required this.orderId,
    required this.token,
    required this.redirectUrl,
  });
}

/// Base sealed class for Payment Exceptions
sealed class PaymentException implements Exception {
  final String? message;
  const PaymentException([this.message]);
}

class PaymentExpiredException extends PaymentException {
  const PaymentExpiredException([super.message]);
}

class PaymentNotPayableException extends PaymentException {
  const PaymentNotPayableException([super.message]);
}

class PaymentUnauthorizedException extends PaymentException {
  const PaymentUnauthorizedException([super.message]);
}

class PaymentNetworkException extends PaymentException {
  const PaymentNetworkException([super.message]);
}

class PaymentServerException extends PaymentException {
  const PaymentServerException([super.message]);
}

/// Exceptions thrown by BookingRepository
sealed class BookingException implements Exception {
  final String? message;
  const BookingException([this.message]);
}

class BookingUnavailableException extends BookingException {
  final String errorCode; // BK001, BK002, BK004
  const BookingUnavailableException(this.errorCode, [super.message]);
}

class BookingSlotClosedException extends BookingException {
  const BookingSlotClosedException([super.message]);
}

class BookingNetworkException extends BookingException {
  const BookingNetworkException([super.message]);
}

class BookingServerException extends BookingException {
  final String? errorCode; // BK003, BK005, BK006, BK007, or generic server error
  const BookingServerException([this.errorCode, super.message]);
}

class BookingNotCancellableException extends BookingException {
  const BookingNotCancellableException([super.message]);
}

class BookingNotFoundException extends BookingException {
  const BookingNotFoundException([super.message]);
}

class BookingUnauthorizedException extends BookingException {
  const BookingUnauthorizedException([super.message]);
}

class BookingNotAdminException extends BookingException {
  const BookingNotAdminException([super.message]);
}

class BookingNotReschedulableException extends BookingException {
  const BookingNotReschedulableException([super.message]);
}

class BookingInvalidInputException extends BookingException {
  const BookingInvalidInputException([super.message]);
}

class BookingDateOutOfRangeException extends BookingException {
  const BookingDateOutOfRangeException([super.message]);
}

/// Interface for Booking repository operations
abstract class BookingRepository {
  /// Fetches bookings for the current logged-in user using RPC `get_my_bookings`
  Future<List<Booking>> getMyBookings();

  /// Creates a booking on the server using RPC `create_booking`
  Future<Booking> createBooking({
    required Court court,
    required DateTime date,
    required int startHour,
    required int durationHours,
  });

  /// Fetches availability for all courts in a venue on a given date using RPC `get_venue_availability`
  /// If [courtId] is provided, filters slots for that court only.
  Future<List<UnavailableTimeSlot>> getVenueAvailability({
    required String venueId,
    required DateTime date,
    String? courtId,
  });

  /// Creates a Midtrans payment session for a booking using Edge Function `create-booking-payment`
  Future<PaymentSession> createPaymentSession(String bookingId);

  /// Cancels a booking using RPC `cancel_booking`
  Future<void> cancelBooking(String bookingId);

  /// Fetches bookings for admin management using RPC `get_admin_bookings`
  Future<List<Booking>> getAdminBookings({
    DateTime? tanggal,
    String? courtId,
    String? status,
    String? search,
  });

  /// Fetches dashboard summary statistics and recent bookings using RPC `get_admin_dashboard`
  Future<AdminDashboardData> getAdminDashboard();

  /// Fetches reschedule options for admin using RPC `get_reschedule_options`
  Future<List<RescheduleOption>> getRescheduleOptions({
    required String bookingId,
    required DateTime date,
  });

  /// Reschedules a booking for admin using RPC `reschedule_booking`
  Future<RescheduleResult> rescheduleBooking({
    required String bookingId,
    required DateTime date,
    required int startHour,
  });
}
