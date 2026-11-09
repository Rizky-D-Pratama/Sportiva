/// Types of notifications supported in Sportiva app
enum NotificationType {
  pembayaranDikonfirmasi,
  bookingMenungguPembayaran,
  jamOperasionalBerubah,
  pesananOtomatisDibatalkan,
  informasiLayanan,
}

/// Model representing a notification item
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? content,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
