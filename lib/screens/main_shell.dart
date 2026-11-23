import 'package:flutter/material.dart';
import '../constants/app_icons.dart';
import '../data/court_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/nav_item.dart';
import 'court_screen.dart';
import 'home_screen.dart';
import 'order_screen.dart';
import 'profile_screen.dart';

/// MainShell manages the persistent fixed bottom navigation bar and page switching.
class MainShell extends StatefulWidget {
  final CourtRepository repository;

  /// Notifier to request tab switching from anywhere in the app
  static final ValueNotifier<int?> tabRequest = ValueNotifier<int?>(null);

  const MainShell({
    super.key,
    required this.repository,
  });

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final GlobalKey<OrderScreenState> _orderScreenKey = GlobalKey<OrderScreenState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    MainShell.tabRequest.addListener(_handleTabRequest);
    _pages = [
      HomeScreen(
        repository: widget.repository,
        onNavigateTab: _onTabTapped,
      ),
      CourtScreen(
        repository: widget.repository,
      ),
      OrderScreen(
        key: _orderScreenKey,
        onNavigateTab: _onTabTapped,
      ),
      ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    MainShell.tabRequest.removeListener(_handleTabRequest);
    super.dispose();
  }

  void _handleTabRequest() {
    final targetIndex = MainShell.tabRequest.value;
    if (targetIndex != null) {
      selectTab(targetIndex);
      MainShell.tabRequest.value = null;
    }
  }

  void selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 2) {
      _orderScreenKey.currentState?.reloadBookings();
    }
  }

  void _onTabTapped(int index) {
    selectTab(index);
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
                iconPath: AppIcons.house,
                label: 'Beranda',
                isActive: _currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
              NavItem(
                iconPath: AppIcons.search,
                label: 'Lapangan',
                isActive: _currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),
              NavItem(
                iconPath: AppIcons.cart,
                label: 'Pemesanan',
                isActive: _currentIndex == 2,
                onTap: () => _onTabTapped(2),
              ),
              NavItem(
                iconPath: AppIcons.userRound,
                label: 'Profil',
                isActive: _currentIndex == 3,
                onTap: () => _onTabTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
