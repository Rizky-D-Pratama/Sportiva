import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../data/mock_data.dart';
import '../models/notification_item.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

/// Screen for Notifications list
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(MockData.mockNotifications);
  }

  void _markAllAsRead() {
    if (_notifications.any((n) => !n.isRead)) {
      setState(() {
        _notifications =
            _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
    }
  }

  void _markAsRead(int index) {
    if (!_notifications[index].isRead) {
      setState(() {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. App Header with "Tandai dibaca semua" action
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingXLarge,
                vertical: 4.0,
              ),
              child: AppHeader(
                title: 'Notifikasi',
                showBackButton: true,
                action: InkWell(
                  onTap: _markAllAsRead,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    child: Text(
                      'Tandai dibaca semua',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: colors.successForeground,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12.0),

            // 2. Notifications List or Empty State
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada notifikasi',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.paddingXLarge,
                        0,
                        AppTheme.paddingXLarge,
                        28.0,
                      ),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16.0),
                      itemBuilder: (context, index) {
                        final item = _notifications[index];
                        return _buildNotificationCard(context, item, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationItem item,
    int index,
  ) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final cardBgColor =
        item.isRead ? colors.surfaceCard : colors.successBackground;

    final categoryConfig = _getCategoryConfig(item.type, colors);

    return Material(
      color: cardBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        side: BorderSide(color: colors.borderDefault, width: 1.0),
      ),
      child: InkWell(
        onTap: () => _markAsRead(index),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon Box
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: categoryConfig.backgroundColor,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  categoryConfig.iconPath,
                  width: 19.0,
                  height: 19.0,
                  colorFilter: ColorFilter.mode(
                    categoryConfig.iconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),

              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Unread Dot
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        if (!item.isRead) ...[
                          const SizedBox(width: 8.0),
                          Container(
                            width: 6.0,
                            height: 6.0,
                            decoration: BoxDecoration(
                              color: colors.successForeground,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5.0),

                    // Content text
                    Text(
                      item.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 5.0),

                    // Timestamp text
                    Text(
                      MockData.formatNotificationDateTime(item.timestamp),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w400,
                        color: colors.successForeground,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _CategoryIconConfig _getCategoryConfig(
    NotificationType type,
    AppCustomColors colors,
  ) {
    switch (type) {
      case NotificationType.pembayaranDikonfirmasi:
        return _CategoryIconConfig(
          iconPath: AppIcons.circleCheck,
          backgroundColor: colors.successBackground,
          iconColor: colors.successForeground,
        );
      case NotificationType.bookingMenungguPembayaran:
        return _CategoryIconConfig(
          iconPath: AppIcons.calendar,
          backgroundColor: colors.warningBackground,
          iconColor: colors.warningForeground,
        );
      case NotificationType.jamOperasionalBerubah:
        return _CategoryIconConfig(
          iconPath: AppIcons.clock,
          backgroundColor: colors.successBackground,
          iconColor: colors.successForeground,
        );
      case NotificationType.pesananOtomatisDibatalkan:
        return _CategoryIconConfig(
          iconPath: AppIcons.calendarX,
          backgroundColor: colors.dangerBackground,
          iconColor: colors.dangerForeground,
        );
      case NotificationType.informasiLayanan:
        return _CategoryIconConfig(
          iconPath: AppIcons.info,
          backgroundColor: colors.successBackground,
          iconColor: colors.successForeground,
        );
    }
  }
}

class _CategoryIconConfig {
  final String iconPath;
  final Color backgroundColor;
  final Color iconColor;

  const _CategoryIconConfig({
    required this.iconPath,
    required this.backgroundColor,
    required this.iconColor,
  });
}
