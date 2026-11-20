import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../constants/app_icons.dart';
import '../../data/court_repository.dart';
import '../../models/court.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_court_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_info_notice.dart';
import '../../widgets/app_modal.dart';
import '../../widgets/app_sticky_bottom_bar.dart';
import 'admin_court_form_screen.dart';

enum CourtFilter { semua, aktif, nonaktif }

/// Admin Screen for Court Management (Manajemen Lapangan)
class AdminCourtsScreen extends StatefulWidget {
  final CourtRepository? courtRepository;

  const AdminCourtsScreen({
    super.key,
    this.courtRepository,
  });

  @override
  State<AdminCourtsScreen> createState() => _AdminCourtsScreenState();
}

class _AdminCourtsScreenState extends State<AdminCourtsScreen> {
  late final CourtRepository _repository;
  CourtFilter _selectedFilter = CourtFilter.semua;
  List<Court> _allCourts = [];
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.courtRepository ?? AppConfig.courtRepository;
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final courts = await _repository.getAdminCourts();
      if (!mounted) return;
      setState(() {
        _allCourts = courts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e is CourtNetworkException
            ? 'Gagal memuat lapangan. Periksa jaringan internet Anda.'
            : 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
      });
    }
  }

  List<Court> get _filteredCourts {
    switch (_selectedFilter) {
      case CourtFilter.semua:
        return _allCourts;
      case CourtFilter.aktif:
        return _allCourts.where((c) => c.isActive).toList();
      case CourtFilter.nonaktif:
        return _allCourts.where((c) => !c.isActive).toList();
    }
  }

  void _showDeleteConfirmationModal(Court court) {
    AppModal.show(
      context: context,
      iconPath: AppIcons.circleAlert,
      iconColor: context.appColors.dangerForeground,
      title: 'Hapus Lapangan?',
      message: 'Lapangan akan dihapus. Anda dapat menambahkan kembali kapan saja.',
      primaryButtonLabel: 'Ya, Hapus',
      onPrimaryPressed: () async {
        if (_isDeleting) return;
        _isDeleting = true;
        Navigator.pop(context); // Close modal
        try {
          await _repository.deleteCourt(court.id);
          _isDeleting = false;
          if (!mounted) return;
          await _loadCourts(); // Refresh court list
        } on CourtNetworkException {
          _isDeleting = false;
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 0,
              content: AppInfoNotice(
                message: 'Koneksi terputus. Periksa jaringan internet Anda.',
                iconPath: AppIcons.circleAlert,
              ),
              duration: Duration(seconds: 3),
            ),
          );
        } catch (_) {
          _isDeleting = false;
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 0,
              content: AppInfoNotice(
                message: 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.',
                iconPath: AppIcons.circleAlert,
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      secondaryButtonLabel: 'Kembali',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  Future<void> _navigateToForm({Court? court}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AdminCourtFormScreen(
          court: court,
          courtRepository: _repository,
        ),
      ),
    );

    if (result == true && mounted) {
      _loadCourts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final displayedCourts = _filteredCourts;
    final courtCountText = '${displayedCourts.length} lapangan terdaftar';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingXLarge,
                vertical: AppTheme.paddingSmall,
              ),
              child: const AppHeader(
                title: 'Manajemen Lapangan',
                showNotificationBell: true,
              ),
            ),

            // Scrollable content area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              _errorMessage!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: AppTheme.paddingXLarge,
                        right: AppTheme.paddingXLarge,
                        top: 8.0,
                        bottom: 96.0, // Space for sticky bottom button
                      ),
                      children: [
                        // Filter status chips (Semua, Aktif, Nonaktif)
                        Row(
                          children: [
                            Expanded(
                              child: AppChip(
                                label: 'Semua',
                                size: AppChipSize.compact,
                                isSelected: _selectedFilter == CourtFilter.semua,
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = CourtFilter.semua;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: AppChip(
                                label: 'Aktif',
                                size: AppChipSize.compact,
                                isSelected: _selectedFilter == CourtFilter.aktif,
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = CourtFilter.aktif;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: AppChip(
                                label: 'Nonaktif',
                                size: AppChipSize.compact,
                                isSelected: _selectedFilter == CourtFilter.nonaktif,
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = CourtFilter.nonaktif;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),

                        // Count info header
                        Text(
                          courtCountText,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12.0),

                        // List of Court Cards or Empty State
                        if (displayedCourts.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48.0),
                            child: Center(
                              child: Text(
                                'Tidak ada lapangan',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          ...displayedCourts.map((court) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: AdminCourtCard(
                                court: court,
                                onEdit: () => _navigateToForm(court: court),
                                onDelete: () => _showDeleteConfirmationModal(court),
                              ),
                            );
                          }),
                      ],
                    ),
            ),

            // Sticky Bottom Button: Tambah Lapangan
            AppStickyBottomBar(
              child: AppButton(
                label: 'Tambah Lapangan',
                leadingIconPath: AppIcons.plus,
                onPressed: () => _navigateToForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
