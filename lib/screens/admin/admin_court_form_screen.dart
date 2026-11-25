import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_config.dart';
import '../../constants/app_icons.dart';
import '../../constants/app_images.dart';
import '../../data/court_repository.dart';
import '../../models/court.dart';
import '../../theme/app_theme.dart';
import '../../utils/price_format_helper.dart';
import '../../utils/price_input_formatter.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_image.dart';
import '../../widgets/app_info_notice.dart';
import '../../widgets/app_modal.dart';
import '../../widgets/app_sticky_bottom_bar.dart';
import '../../widgets/availability_card.dart';
import '../../widgets/court_photo_bottom_sheet.dart';
import '../../widgets/facility_bottom_sheet.dart';

/// Admin Screen for adding or editing a Court (Tambah Lapangan & Edit Lapangan)
class AdminCourtFormScreen extends StatefulWidget {
  final Court? court;
  final CourtRepository? courtRepository;

  const AdminCourtFormScreen({
    super.key,
    this.court,
    this.courtRepository,
  });

  @override
  State<AdminCourtFormScreen> createState() => _AdminCourtFormScreenState();
}

class _AdminCourtFormScreenState extends State<AdminCourtFormScreen> {
  late final CourtRepository _repository;
  late final bool _isEditMode;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategory;
  late List<String> _facilities;
  late bool _isActive;
  String? _imageUrl;

  // Initial values for change tracking
  late final String _initialName;
  late final String? _initialCategory;
  late final String _initialPrice;
  late final String _initialDescription;
  late final List<String> _initialFacilities;
  late final bool _initialIsActive;

  // Validation errors
  String? _nameError;
  String? _categoryError;
  String? _priceError;
  String? _descriptionError;
  String? _facilityError;

  bool _isSubmitting = false;

  final List<String> _availableCategories = const [
    'Futsal',
    'Voli',
    'Basket',
    'Badminton',
  ];

  @override
  void initState() {
    super.initState();
    _repository = widget.courtRepository ?? AppConfig.courtRepository;
    _isEditMode = widget.court != null;

    if (_isEditMode) {
      final court = widget.court!;
      _initialName = court.name;
      _initialCategory = court.category;
      _initialPrice = PriceFormatHelper.formatPriceNumber(court.pricePerHour);
      _initialDescription = court.description;
      _initialFacilities = List.from(court.facilities);
      _initialIsActive = court.isActive;
      _imageUrl = court.imageUrl;
    } else {
      _initialName = '';
      _initialCategory = null;
      _initialPrice = '';
      _initialDescription = '';
      _initialFacilities = [];
      _initialIsActive = true;
      _imageUrl = null;
    }

    _nameController.text = _initialName;
    _selectedCategory = _initialCategory;
    _priceController.text = _initialPrice;
    _descriptionController.text = _initialDescription;
    _facilities = List.from(_initialFacilities);
    _isActive = _initialIsActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    if (!_isEditMode) {
      return _nameController.text.trim().isNotEmpty ||
          _selectedCategory != null ||
          _priceController.text.trim().isNotEmpty ||
          _descriptionController.text.trim().isNotEmpty ||
          _facilities.isNotEmpty ||
          !_isActive;
    }

    final priceInt = PriceFormatHelper.parsePrice(_priceController.text) ?? 0;
    final initialPriceInt = PriceFormatHelper.parsePrice(_initialPrice) ?? 0;

    return _nameController.text.trim() != _initialName.trim() ||
        _selectedCategory != _initialCategory ||
        priceInt != initialPriceInt ||
        _descriptionController.text.trim() != _initialDescription.trim() ||
        _facilities.length != _initialFacilities.length ||
        !_areFacilitiesEqual(_facilities, _initialFacilities) ||
        _isActive != _initialIsActive;
  }

  bool _areFacilitiesEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldPop = await AppModal.show<bool>(
      context: context,
      iconPath: AppIcons.circleAlert,
      iconColor: context.appColors.dangerForeground,
      title: 'Buang Perubahan?',
      message: 'Perubahan yang belum disimpan akan hilang.',
      primaryButtonLabel: 'Ya, Buang',
      onPrimaryPressed: () => Navigator.of(context).pop(true),
      secondaryButtonLabel: 'Kembali',
      onSecondaryPressed: () => Navigator.of(context).pop(false),
    );

    return shouldPop ?? false;
  }

  void _validateAndSave() async {
    if (_isSubmitting) return;

    final nameTrimmed = _nameController.text.trim();
    final priceVal = PriceFormatHelper.parsePrice(_priceController.text) ?? 0;
    final descriptionTrimmed = _descriptionController.text.trim();

    String? nameErr;
    String? categoryErr;
    String? priceErr;
    String? descriptionErr;
    String? facilityErr;

    if (nameTrimmed.isEmpty) {
      nameErr = 'Nama lapangan wajib diisi.';
    }

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      categoryErr = 'Pilih kategori olahraga.';
    }

    if (priceVal <= 0) {
      priceErr = 'Harga per jam wajib diisi.';
    }

    if (descriptionTrimmed.isEmpty) {
      descriptionErr = 'Deskripsi wajib diisi.';
    }

    if (_facilities.isEmpty) {
      facilityErr = 'Tambahkan minimal 1 fasilitas.';
    }

    if (nameErr != null ||
        categoryErr != null ||
        priceErr != null ||
        descriptionErr != null ||
        facilityErr != null) {
      setState(() {
        _nameError = nameErr;
        _categoryError = categoryErr;
        _priceError = priceErr;
        _descriptionError = descriptionErr;
        _facilityError = facilityErr;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final effectiveImageUrl = (_imageUrl != null && _imageUrl!.isNotEmpty)
        ? _imageUrl!
        : AppImages.soccer;

    try {
      if (_isEditMode) {
        final updatedCourt = widget.court!.copyWith(
          name: nameTrimmed,
          category: _selectedCategory!,
          pricePerHour: priceVal,
          description: descriptionTrimmed,
          facilities: List.from(_facilities),
          isActive: _isActive,
          imageUrl: effectiveImageUrl,
        );
        await _repository.updateCourt(updatedCourt);
      } else {
        final adminVenue = AppConfig.authRepository.currentUser?.venue;
        if (adminVenue == null) {
          throw const CourtServerException('Venue data is missing');
        }
        final newCourt = Court(
          id: 'court_${DateTime.now().millisecondsSinceEpoch}',
          name: nameTrimmed,
          category: _selectedCategory!,
          venue: adminVenue,
          pricePerHour: priceVal,
          rating: 0.0,
          reviewCount: 0,
          imageUrl: effectiveImageUrl,
          facilities: List.from(_facilities),
          description: descriptionTrimmed,
          isActive: _isActive,
          dayStatus: CourtDayStatus.none,
        );
        await _repository.addCourt(newCourt);
      }

      if (!mounted) return;

      final snackMessage = _isEditMode
          ? 'Perubahan disimpan.'
          : 'Lapangan berhasil ditambahkan.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: AppInfoNotice(
            message: snackMessage,
            iconPath: AppIcons.circleCheck,
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop(true);
    } on CourtDuplicateNameException {
      if (!mounted) return;
      setState(() {
        _nameError = 'Nama lapangan sudah digunakan.';
        _isSubmitting = false;
      });
    } on CourtNetworkException {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
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
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
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
  }

  void _openFacilityBottomSheet() {
    FacilityBottomSheet.show(
      context: context,
      existingFacilities: _facilities,
      onFacilityAdded: (facility) {
        setState(() {
          _facilities.add(facility);
          _facilityError = null;
        });
      },
    );
  }

  void _openPhotoBottomSheet() {
    CourtPhotoBottomSheet.show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final pageTitle = _isEditMode ? 'Edit Lapangan' : 'Tambah Lapangan';
    final buttonLabel = _isEditMode ? 'Simpan Perubahan' : 'Simpan Lapangan';

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
                child: AppHeader(
                  title: pageTitle,
                  showBackButton: true,
                  onBackTap: () async {
                    if (await _onWillPop() && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),

              // Scrollable Content
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingXLarge,
                    vertical: AppTheme.paddingMedium,
                  ),
                  children: [
                    // Top Intro text / Notice
                    if (_isEditMode) ...[
                      AppInfoNotice(
                        message:
                            'Mengedit $_initialName • ${widget.court?.venue.name ?? 'Sportiva Center'}',
                        iconPath: AppIcons.circleCheck,
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),
                    ] else ...[
                      Text(
                        'Lengkapi informasi agar pengguna mudah menemukan lapanganmu.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.0,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),
                    ],

                    // 1. Nama Lapangan
                    AppField(
                      label: 'Nama lapangan',
                      controller: _nameController,
                      hintText: 'Masukkan nama lapangan',
                      maxLength: 40,
                      errorText: _nameError,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        if (_nameError != null) {
                          setState(() => _nameError = null);
                        }
                      },
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),

                    // 2. Kategori Olahraga & Harga per jam (Row)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kategori Dropdown
                        Expanded(
                          child: PopupMenuButton<String>(
                            tooltip: '',
                            position: PopupMenuPosition.under,
                            onSelected: (cat) {
                              setState(() {
                                _selectedCategory = cat;
                                _categoryError = null;
                              });
                            },
                            itemBuilder: (context) => _availableCategories
                                .map(
                                  (cat) => PopupMenuItem<String>(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                )
                                .toList(),
                            child: AppField(
                              label: 'Kategori olahraga',
                              trailingIconPath: AppIcons.chevronDown,
                              errorText: _categoryError,
                              child: Text(
                                _selectedCategory ?? 'Pilih kategori',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: _selectedCategory != null
                                      ? colors.textPrimary
                                      : colors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.paddingMedium),

                        // Harga per jam (Rp)
                        Expanded(
                          child: AppField(
                            label: 'Harga per jam (Rp)',
                            controller: _priceController,
                            hintText: 'Contoh: 150.000',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              PriceInputFormatter(maxDigits: 7),
                            ],
                            errorText: _priceError,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) {
                              if (_priceError != null) {
                                setState(() => _priceError = null);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),

                    // 3. Deskripsi Lapangan
                    AppField(
                      label: 'Deskripsi',
                      controller: _descriptionController,
                      hintText:
                          'Tuliskan keunggulan dan informasi lapangan',
                      maxLines: null,
                      minLines: 2,
                      maxLength: 300,
                      errorText: _descriptionError,
                      onChanged: (_) {
                        if (_descriptionError != null) {
                          setState(() => _descriptionError = null);
                        }
                      },
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),

                    // 4. Fasilitas Lapangan (Chips + Add Button)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fasilitas',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Facility chips
                            ..._facilities.map((facility) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _facilities.remove(facility);
                                  });
                                },
                                borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusPill,
                                ),
                                child: AppBadge(
                                  label: '✓ $facility',
                                  variant: AppBadgeVariant.success,
                                ),
                              );
                            }),

                            // "+ Tambah fasilitas" badge (if < 5)
                            if (_facilities.length < 5)
                              InkWell(
                                onTap: _openFacilityBottomSheet,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusPill,
                                ),
                                child: const AppBadge(
                                  label: '+ Tambah fasilitas',
                                  variant: AppBadgeVariant.neutral,
                                ),
                              ),
                          ],
                        ),
                        if (_facilityError != null && _facilityError!.isNotEmpty) ...[
                          const SizedBox(height: 4.0),
                          Text(
                            _facilityError!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.dangerForeground,
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),

                    // 5. Foto Lapangan
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Foto lapangan',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'JPG / PNG • maksimal 5 MB',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontSize: 10.4,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),

                        // Image Preview or Upload Box
                        if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
                          // Photo preview
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 160.0,
                              child: AppImage(
                                imagePath: _imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          // Edit Foto outline button
                          OutlinedButton.icon(
                            onPressed: _openPhotoBottomSheet,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.textPrimary,
                              side: BorderSide(
                                color: colors.borderDefault,
                                width: 1.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusSmall,
                                ),
                              ),
                              minimumSize: const Size(double.infinity, 44.0),
                            ),
                            icon: SvgPicture.asset(
                              AppIcons.camera,
                              width: AppTheme.iconSizeMedium,
                              height: AppTheme.iconSizeMedium,
                              colorFilter: ColorFilter.mode(
                                colors.textPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                            label: Text(
                              'Edit Foto',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ] else ...[
                          // Upload box state (no photo)
                          InkWell(
                            onTap: () {
                              // Unggah belum berfungsi
                            },
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: 120.0,
                              decoration: BoxDecoration(
                                color: colors.surfaceCard,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusMedium,
                                ),
                                border: Border.all(
                                  color: colors.borderDefault,
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    AppIcons.imagePlus,
                                    width: 28.0,
                                    height: 28.0,
                                    colorFilter: ColorFilter.mode(
                                      colors.textSecondary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Unggah foto lapangan',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),

                    // 6. Availability Card
                    AvailabilityCard(
                      isActive: _isActive,
                      isEditMode: _isEditMode,
                      onChanged: (val) {
                        setState(() {
                          _isActive = val;
                        });
                      },
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),

              // 7. Sticky Bottom Bar
              AppStickyBottomBar(
                child: AppButton(
                  label: buttonLabel,
                  leadingIconPath: AppIcons.check,
                  onPressed: _isSubmitting ? null : _validateAndSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
