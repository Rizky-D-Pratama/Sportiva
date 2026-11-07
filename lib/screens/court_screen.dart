import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../data/court_repository.dart';
import '../models/court.dart';
import '../theme/app_theme.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/court_card.dart';
import '../widgets/dropdown_chip.dart';
import '../widgets/price_range_bottom_sheet.dart';
import '../widgets/rating_bottom_sheet.dart';
import '../widgets/search_bar_widget.dart';

/// Screen for Lapangan (Court) catalog/search tab
class CourtScreen extends StatefulWidget {
  final CourtRepository repository;

  const CourtScreen({
    super.key,
    required this.repository,
  });

  @override
  State<CourtScreen> createState() => _CourtScreenState();
}

class _CourtScreenState extends State<CourtScreen> {
  late Future<List<Court>> _courtsFuture;

  // Filter & Sort state
  String _searchQuery = '';
  String? _selectedCategory; // 'Futsal', 'Voli', 'Basket', 'Badminton', or null
  int? _minPrice;
  int? _maxPrice;
  RatingSortType? _ratingSort;

  @override
  void initState() {
    super.initState();
    _loadCourts();
  }

  void _loadCourts() {
    _courtsFuture = widget.repository.getAllCourts();
  }

  void _onCategoryTapped(String category) {
    setState(() {
      if (_selectedCategory?.toLowerCase() == category.toLowerCase()) {
        _selectedCategory = null; // Toggle off on re-tap
      } else {
        _selectedCategory = category;
      }
    });
  }

  void _openPriceRangeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PriceRangeBottomSheet(
          initialMinPrice: _minPrice,
          initialMaxPrice: _maxPrice,
          onApply: (min, max) {
            setState(() {
              _minPrice = min;
              _maxPrice = max;
            });
          },
        );
      },
    );
  }

  void _openRatingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return RatingBottomSheet(
          initialSort: _ratingSort,
          onApply: (sortType) {
            setState(() {
              _ratingSort = sortType;
            });
          },
        );
      },
    );
  }

  List<Court> _filterAndSortCourts(List<Court> allCourts) {
    var result = allCourts.where((court) {
      // 1. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = court.name.toLowerCase().contains(q);
        final matchVenue = court.venue.name.toLowerCase().contains(q);
        final matchLocation = court.venue.location.toLowerCase().contains(q);
        final matchCategory = court.category.toLowerCase().contains(q);
        if (!matchName && !matchVenue && !matchLocation && !matchCategory) {
          return false;
        }
      }

      // 2. Category Filter
      if (_selectedCategory != null) {
        if (court.category.toLowerCase() !=
            _selectedCategory!.toLowerCase()) {
          return false;
        }
      }

      // 3. Price Range Filter
      if (_minPrice != null && court.pricePerHour < _minPrice!) {
        return false;
      }
      if (_maxPrice != null && court.pricePerHour > _maxPrice!) {
        return false;
      }

      return true;
    }).toList();

    // 4. Rating Sorting
    if (_ratingSort != null) {
      if (_ratingSort == RatingSortType.highest) {
        result.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (_ratingSort == RatingSortType.lowest) {
        result.sort((a, b) => a.rating.compareTo(b.rating));
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>();

    final textPrimary =
        customColors?.textPrimary ?? theme.colorScheme.onSurface;
    final textSecondary =
        customColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant;

    final isPriceFiltered = _minPrice != null || _maxPrice != null;
    final isRatingSorted = _ratingSort != null;

    String ratingLabel = 'Rating';
    if (_ratingSort == RatingSortType.highest) {
      ratingLabel = 'Rating: Tertinggi';
    } else if (_ratingSort == RatingSortType.lowest) {
      ratingLabel = 'Rating: Terendah';
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingXLarge,
        vertical: AppTheme.paddingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. App Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Temukan Lapangan',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  AppIcons.bell,
                  width: AppTheme.iconSizeMedium,
                  height: AppTheme.iconSizeMedium,
                  colorFilter: ColorFilter.mode(
                    textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // 2. Search Bar
          SearchBarWidget(
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
          const SizedBox(height: 16.0),

          // 3. Sport Category Filter Chips (Futsal, Voli, Basket, Badminton)
          Row(
            children: [
              Expanded(
                child: CategoryFilterChip(
                  iconPath: AppIcons.soccerBall,
                  label: 'Futsal',
                  isSelected:
                      _selectedCategory?.toLowerCase() == 'futsal',
                  onTap: () => _onCategoryTapped('Futsal'),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: CategoryFilterChip(
                  iconPath: AppIcons.volleyball,
                  label: 'Voli',
                  isSelected:
                      _selectedCategory?.toLowerCase() == 'voli',
                  onTap: () => _onCategoryTapped('Voli'),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: CategoryFilterChip(
                  iconPath: AppIcons.basketBall,
                  label: 'Basket',
                  isSelected:
                      _selectedCategory?.toLowerCase() == 'basket',
                  onTap: () => _onCategoryTapped('Basket'),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: CategoryFilterChip(
                  iconPath: AppIcons.shuttlecock,
                  label: 'Badminton',
                  isSelected:
                      _selectedCategory?.toLowerCase() == 'badminton',
                  onTap: () => _onCategoryTapped('Badminton'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // 4. Dropdown Filter Chips (Rentang harga & Rating)
          Row(
            children: [
              DropdownChip(
                label: 'Rentang harga',
                isActive: isPriceFiltered,
                onTap: _openPriceRangeBottomSheet,
              ),
              const SizedBox(width: 6.0),
              DropdownChip(
                label: ratingLabel,
                isActive: isRatingSorted,
                onTap: _openRatingBottomSheet,
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // 5. Courts List
          FutureBuilder<List<Court>>(
            future: _courtsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final allCourts = snapshot.data ?? [];
              final filteredCourts = _filterAndSortCourts(allCourts);

              if (filteredCourts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'Tidak ada lapangan ditemukan.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: filteredCourts.map((court) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CourtCard(
                      court: court,
                      onTap: () {},
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
