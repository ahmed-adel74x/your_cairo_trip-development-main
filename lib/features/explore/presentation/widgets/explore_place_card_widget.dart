// lib/features/explore/presentation/widgets/explore_place_card_widget.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_translation_keys.dart';
import '../../../../core/utils/map_launcher_helper.dart';
import '../../../booking/presentation/screens/booking_screen.dart';
import '../../../places/presentation/widgets/place_details_bottom_sheet.dart';
import '../../../places/data/model/budget_response_model.dart';
import '../../data/models/explore_place_model.dart';
import '../cubit/explore_cubit.dart';

class ExplorePlaceCardWidget extends StatelessWidget {
  final ExplorePlaceModel place;

  const ExplorePlaceCardWidget({super.key, required this.place});

  PlaceItemResponseModel _toPlaceItemResponseModel() {
    return PlaceItemResponseModel(
      id: place.id,
      name: place.name,
      description: place.description,
      imageUrl: place.imageUrl,
      isFree: place.isFree,
      priceLocalized: place.price,
      priceNumber: place.priceNumber,
      location: place.location,
      workingHours: place.workingHours,
      activities: place.activities,
      ratingAvg: place.ratingAvg,
      totalBookings: place.totalBookings,
      canAfford: true,
      pricePerPerson: place.priceNumber,
      totalCost: place.priceNumber,
      coordinates: place.coordinates,
      category: place.category,
      categoryLabel: place.categoryLabel,
    );
  }

  // ── Category Color & Icon ──
  Color _getCategoryColor() {
    switch (place.category) {
      case 'restaurant':
        return Colors.orange.shade700;
      case 'hotel':
        return Colors.purple.shade600;
      case 'attraction':
      default:
        return Colors.blue.shade600;
    }
  }

  IconData _getCategoryIcon() {
    switch (place.category) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      case 'attraction':
      default:
        return Icons.account_balance_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;
    final priceText = place.getPrice(langCode);
    final categoryColor = _getCategoryColor();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 15.r,
            spreadRadius: 1.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image Section ──
          _ImageSection(place: place, categoryColor: categoryColor),

          // ── Content ──
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title + Favourite + Details ──
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        place.name.localized(langCode),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _FavouriteButton(place: place),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => PlaceDetailsBottomSheet.show(
                        context,
                        _toPlaceItemResponseModel(),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 22.sp,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            AppTranslationKeys.placesDetails.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // ── Category Badge + Location + Rating ──
                Row(
                  children: [
                    // ── Category Badge ──
                    if (place.categoryLabel != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: categoryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(),
                              color: categoryColor,
                              size: 11.sp,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              place.categoryLabel!.localized(langCode),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: categoryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(width: 8.w),

                    // ── Location (Clickable لو فيه coordinates) ──
                    if (place.location != null)
                      Expanded(
                        child: GestureDetector(
                          onTap: place.coordinates != null
                              ? () => MapLauncherHelper.openGoogleMaps(
                                  context: context,
                                  latitude: place.coordinates!.latitude,
                                  longitude: place.coordinates!.longitude,
                                  label: place.name.localized(langCode),
                                )
                              : null,
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: AppColors.primary,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  place.location!.localized(langCode),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: place.coordinates != null
                                        ? AppColors.primary
                                        : AppColors.textLight,
                                    decoration: place.coordinates != null
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                    decorationColor: AppColors.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // ── أيقونة صغيرة لو فيه خريطة ──
                              if (place.coordinates != null) ...[
                                SizedBox(width: 2.w),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  color: AppColors.primary,
                                  size: 10.sp,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                    // ── Rating ──
                    _StarRating(rating: place.ratingAvg),
                  ],
                ),

                SizedBox(height: 8.h),

                // ── Price Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: place.isFree
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: place.isFree
                          ? Colors.green.withOpacity(0.4)
                          : Colors.red.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    place.isFree
                        ? AppTranslationKeys.exploreFree.tr()
                        : (priceText ?? AppTranslationKeys.explorePaid.tr()),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: place.isFree
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // ── Book Button ──
                SizedBox(
                  width: double.infinity,
                  child: place.isBooked
                      ? ElevatedButton.icon(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.grey.shade600,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          icon: Icon(Icons.check_circle_rounded, size: 18.sp),
                          label: Text(
                            AppTranslationKeys.exploreBooked.tr(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingScreen(
                                  placeId: place.id,
                                  placeName: place.name.localized(langCode),
                                  placeImage: place.imageUrl,
                                  onBookingSuccess: () {
                                    context.read<ExploreCubit>().markAsBooked(
                                      place.id,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          icon: Icon(Icons.calendar_month_rounded, size: 18.sp),
                          label: Text(
                            AppTranslationKeys.exploreBook.tr(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Image Section ────────────────────────────────────────────────────────────

class _ImageSection extends StatelessWidget {
  final ExplorePlaceModel place;
  final Color categoryColor;

  const _ImageSection({required this.place, required this.categoryColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          child: place.imageUrl != null && place.imageUrl!.isNotEmpty
              ? Image.network(
                  _fixImageUrl(place.imageUrl!),
                  height: 180.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _LoadingWidget();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _ErrorWidget();
                  },
                )
              : _ImagePlaceholder(),
        ),

        // ── Booked Badge ──
        if (place.isBooked)
          Positioned(
            top: 12.h,
            right: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 12.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    context.locale.languageCode == 'ar' ? 'تم الحجز' : 'Booked',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Widgets مساعدة ──

class _LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.h,
      color: const Color(0xFFF5F5F5),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.h,
      color: const Color(0xFFE8D5B0),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.grey.shade600,
          size: 40.sp,
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.h,
      color: const Color(0xFFE8D5B0),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: 48.sp,
        ),
      ),
    );
  }
}

class _FavouriteButton extends StatelessWidget {
  final ExplorePlaceModel place;

  const _FavouriteButton({required this.place});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ExploreCubit>().toggleFavourite(place.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: place.isFavourite
              ? Colors.red.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          place.isFavourite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: place.isFavourite ? Colors.red : Colors.grey,
          size: 20.sp,
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;

  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final starValue = i + 1;
          if (rating >= starValue) {
            return Icon(
              Icons.star_rounded,
              color: AppColors.rating,
              size: 16.sp,
            );
          } else if (rating >= starValue - 0.5) {
            return Icon(
              Icons.star_half_rounded,
              color: AppColors.rating,
              size: 16.sp,
            );
          } else {
            return Icon(
              Icons.star_outline_rounded,
              color: AppColors.rating,
              size: 16.sp,
            );
          }
        }),
        SizedBox(width: 4.w),
        Text(
          rating > 0 ? rating.toStringAsFixed(1) : '0.0',
          style: TextStyle(fontSize: 11.sp, color: AppColors.textLight),
        ),
      ],
    );
  }
}

String _fixImageUrl(String url) {
  return url.replaceFirst('http://', 'https://');
}
