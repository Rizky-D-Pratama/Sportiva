import 'package:flutter/material.dart';
import '../../constants/app_icons.dart';
import '../../theme/app_theme.dart';
import '../../widgets/nav_item.dart';
import 'admin_dashboard_screen.dart';
import 'admin_profile_screen.dart';
import 'admin_report_screen.dart';

/// AdminShell manages the persistent bottom navigation bar and page switching for Admin side.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminDashboardScreen(),
      // TODO: Replace with real Lapangan management screen in future sessions.
      _buildPlaceholderPage('Manajemen Lapangan'),
      // TODO: Replace with real Booking management screen in future sessions.
      _buildPlaceholderPage('Manajemen Booking'),
      const AdminReportScreen(),
      const AdminProfileScreen(),
    ];
  }

  Widget _buildPlaceholderPage(String title) {
    return Scaffold(
      body: Center(
        child: Text(
          '$title\n(Segera Hadir)',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final navBg = colors.surfaceNavigation;
    final borderColor = colors.borderDefault;

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          constraints: const BoxConstraints(minHeight: 66.0),
          decoration: BoxDecoration(
            color: navBg,
            border: Border(
              top: BorderSide(
                color: borderColor,
                width: 1.0,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(
                iconPath: AppIcons.layoutDashboard,
                label: 'Dashboard',
                isActive: _currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
              NavItem(
                iconPath: AppIcons.soccerField,
                label: 'Lapangan',
                isActive: _currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),
              NavItem(
                iconPath: AppIcons.calendar,
                label: 'Booking',
                isActive: _currentIndex == 2,
                onTap: () => _onTabTapped(2),
              ),
              NavItem(
                iconPath: AppIcons.chart,
                label: 'Laporan',
                isActive: _currentIndex == 3,
                onTap: () => _onTabTapped(3),
              ),
              NavItem(
                iconPath: AppIcons.userRound,
                label: 'Profil',
                isActive: _currentIndex == 4,
                onTap: () => _onTabTapped(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
