/// Global constants for Sportiva app
class AppConstants {
  /// Maximum duration in hours allowed for a single court booking
  static const int maxBookingDurationHours = 5;

  /// Minimum lead time in minutes required before court booking start time
  static const int minBookingLeadTimeMinutes = 30;

  /// Operational start hour (08.00 WIB)
  static const int operationalStartHour = 8;

  /// Operational end hour (24.00 WIB)
  static const int operationalEndHour = 24;

  /// Maximum advance booking days allowed (14 days from today)
  static const int maxAdvanceBookingDays = 14;

  /// Maximum advance venue/court closure days allowed (90 days from today)
  static const int maxVenueClosureAdvanceDays = 90;

  /// Maximum character length allowed for closure reason
  static const int maxClosureReasonLength = 40;

  /// App version
  static const String appVersion = '1.0.0';

  /// Formatted app name and version string
  static const String appTitleWithVersion = 'Sportiva • Versi $appVersion';
}
