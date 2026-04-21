// lib/features/explore/presentation/widgets/explore_category_tabs_widget.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class ExploreCategoryTabsWidget extends StatelessWidget {
  final String activeCategory;
  final ValueChanged<String> onCategoryChanged;

  const ExploreCategoryTabsWidget({
    super.key,
    required this.activeCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;
    final isAr = langCode == 'ar';

    final categories = [
      _CategoryItem(
        key: 'all',
        labelAr: 'الكل',
        labelEn: 'All',
        icon: Icons.grid_view_rounded,
        color: AppColors.primary,
      ),
      _CategoryItem(
        key: 'attraction',
        labelAr: 'معالم سياحية',
        labelEn: 'Attractions',
        icon: Icons.account_balance_rounded,
        color: Colors.blue.shade600,
      ),
      _CategoryItem(
        key: 'restaurant',
        labelAr: 'مطاعم',
        labelEn: 'Restaurants',
        icon: Icons.restaurant_rounded,
        color: Colors.orange.shade700,
      ),
      _CategoryItem(
        key: 'hotel',
        labelAr: 'فنادق',
        labelEn: 'Hotels',
        icon: Icons.hotel_rounded,
        color: Colors.purple.shade600,
      ),
    ];

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
          SizedBox(
            height: 80.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              itemCount: categories.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isActive = activeCategory == cat.key;

                return GestureDetector(
                  onTap: () => onCategoryChanged(cat.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? cat.color.withOpacity(0.12)
                          : Colors.grey.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isActive
                            ? cat.color
                            : Colors.grey.withOpacity(0.2),
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat.icon,
                          color: isActive ? cat.color : AppColors.textLight,
                          size: 18.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          isAr ? cat.labelAr : cat.labelEn,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isActive ? cat.color : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
        ],
      ),
    );
  }
}

class _CategoryItem {
  final String key;
  final String labelAr;
  final String labelEn;
  final IconData icon;
  final Color color;

  const _CategoryItem({
    required this.key,
    required this.labelAr,
    required this.labelEn,
    required this.icon,
    required this.color,
  });
}
