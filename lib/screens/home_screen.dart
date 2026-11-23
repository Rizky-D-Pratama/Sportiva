import 'package:flutter/material.dart';
import '../constants/app_images.dart';
import '../data/court_repository.dart';
import '../data/mock_data.dart';
import '../models/court.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/app_notification_bell.dart';
import '../widgets/court_card.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/sport_chip.dart';
import 'booking_history_screen.dart';
import 'court_detail_screen.dart';
import 'court_schedule_screen.dart';

/// HomeScreen displaying vertical scrollable content for Sportiva Home
class HomeScreen extends StatefulWidget {
  final CourtRepository repository;
  final ValueChanged<int>? onNavigateTab;
  final VoidCallback? onSearchTap;

  const HomeScreen({
    super.key,
    required this.repository,
    this.onNavigateTab,
    this.onSearchTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Court>> _popularCourtsFuture;
  late Future<String> _userNameFuture;
  late Future<String> _greetingFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _popularCourtsFuture = widget.repository.getPopularCourts();
    _userNameFuture = widget.repository.getUserName();
    _greetingFuture = widget.repository.getGreeting();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final textPrimary =
        colors.textPrimary;
    final textSecondary =
        colors.textSecondary;
    final successForeground =
        colors.successForeground;
    final bannerBg = colors.successBackground;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingXLarge,
        vertical: AppTheme.paddingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Home Header
          FutureBuilder<List<String>>(
            future: Future.wait([_greetingFuture, _userNameFuture]),
            builder: (context, snapshot) {
              final greeting = snapshot.data?[0] ?? MockData.welcomeGreeting;
              final name = snapshot.data?[1] ?? MockData.userName;

              return Row(
                children: [
                  // Profile Photo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22.0),
                    child: SizedBox(
                      width: 44.0,
                      height: 44.0,
                      child: AppImage(
                        imagePath: MockData.profilePhotoUrl,
                        fit: BoxFit.cover,
                        defaultFallback: AppImages.blankProfile,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),

                  // Greeting & Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Bell Notification Icon
                  const AppNotificationBell(),
                ],
              );
            },
          ),
          const SizedBox(height: 16.0),

          // 2. Search Bar
          AppSearchBar(
            readOnly: true,
            onTap: widget.onSearchTap,
          ),
          const SizedBox(height: 16.0),

          // 3. Promotional Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            decoration: BoxDecoration(
              color: bannerBg,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MockData.bannerTagline,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: successForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  MockData.bannerTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12.0),
                InkWell(
                  onTap: () {
                    widget.onNavigateTab?.call(1); // Navigate to Lapangan tab
                  },
                  child: Text(
                    MockData.bannerActionText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: successForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // 4. Shortcut Grid (SportChip)
          Column(
            children: [
              // Row 1: Futsal, Voli, Basket
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: SportChip(
                      icon: MockData.sportCategories[0]['icon'],
                      label: MockData.sportCategories[0]['label'],
                      onTap: () => widget.onNavigateTab?.call(1),
                    ),
                  ),
                  Expanded(
                    child: SportChip(
                      icon: MockData.sportCategories[1]['icon'],
                      label: MockData.sportCategories[1]['label'],
                      onTap: () => widget.onNavigateTab?.call(1),
                    ),
                  ),
                  Expanded(
                    child: SportChip(
                      icon: MockData.sportCategories[2]['icon'],
                      label: MockData.sportCategories[2]['label'],
                      onTap: () => widget.onNavigateTab?.call(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // Row 2: Badminton, Jadwal Lapangan, Riwayat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: SportChip(
                      icon: MockData.sportCategories[3]['icon'],
                      label: MockData.sportCategories[3]['label'],
                      onTap: () => widget.onNavigateTab?.call(1),
                    ),
                  ),
                  Expanded(
                    child: SportChip(
                      icon: MockData.sportCategories[4]['icon'],
                      label: MockData.sportCategories[4]['label'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CourtScheduleScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: SportChip(
                      icon: MockData.sportCategories[5]['icon'],
                      label: MockData.sportCategories[5]['label'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BookingHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // 5. Popular Court Header (Lapangan Populer)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lapangan Populer',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: () => widget.onNavigateTab?.call(1),
                child: Text(
                  'Lihat Semua',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: successForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // 6. Popular Courts List (CourtCard)
          FutureBuilder<List<Court>>(
            future: _popularCourtsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                final errorMsg = snapshot.error is CourtNetworkException
                    ? 'Gagal memuat lapangan. Periksa jaringan internet Anda.'
                    : 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      errorMsg,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final courts = snapshot.data ?? [];
              return Column(
                children: courts.map((court) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CourtCard(
                      court: court,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                CourtDetailScreen(court: court),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
