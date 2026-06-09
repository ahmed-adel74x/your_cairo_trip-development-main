// lib/features/profile/presentation/screens/favourites_screen.dart

import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_translation_keys.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/sevices/map_launcher_helper.dart';
import '../../../booking/presentation/screens/booking_screen.dart';
import '../../../places/data/model/budget_response_model.dart';
import '../../../places/presentation/widgets/place_details_bottom_sheet.dart';
import '../../data/models/favourite_model.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..getFavourites(),
      child: const _FavouritesView(),
    );
  }
}

class _FavouritesView extends StatelessWidget {
  const _FavouritesView();

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;

    return Directionality(
      textDirection: langCode == 'ar'
          ? ui.TextDirection.rtl
          : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppTranslationKeys.favouritesTitle.tr(),
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.white,
              size: 20.sp,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
          ),
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is FavouriteToggleSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  content: Text(
                    AppTranslationKeys.favouritesRemoved.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.sp),
                  ),
                ),
              );
            }
            if (state is FavouriteToggleError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            // ── Loading ──
            if (state is FavouritesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            // ── Error ──
            if (state is FavouritesError) {
              return _buildError(context, state.message);
            }

            // ── Loaded ──
            if (state is FavouritesLoaded) {
              if (state.favourites.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => context.read<ProfileCubit>().getFavourites(),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.r),
                  itemCount: state.favourites.length,
                  itemBuilder: (context, index) {
                    return _FavouriteCard(
                      favourite: state.favourites[index],
                      onRemove: () => context
                          .read<ProfileCubit>()
                          .toggleFavourite(state.favourites[index].place.id),
                    );
                  },
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            color: AppColors.textLight,
            size: 70.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            AppTranslationKeys.favouritesEmpty.tr(),
            style: TextStyle(fontSize: 16.sp, color: AppColors.textLight),
          ),
          SizedBox(height: 8.h),
          Text(
            AppTranslationKeys.favouritesEmptySubtitle.tr(),
            style: TextStyle(fontSize: 13.sp, color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red, size: 60.sp),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<ProfileCubit>().getFavourites(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(AppTranslationKeys.loading.tr()),
          ),
        ],
      ),
    );
  }
}

// ─── Favourite Card ───────────────────────────────────────────────────────────

class _FavouriteCard extends StatelessWidget {
  final FavouriteModel favourite;
  final VoidCallback onRemove;

  const _FavouriteCard({required this.favourite, required this.onRemove});

  // ── Category Color ──
  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'restaurant':
        return Colors.orange.shade700;
      case 'hotel':
        return Colors.purple.shade600;
      case 'attraction':
      default:
        return Colors.blue.shade600;
    }
  }

  // ── Category Icon ──
  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      case 'attraction':
      default:
        return Icons.account_balance_rounded;
    }
  }

  // ── تحويل FavouritePlaceModel إلى PlaceItemResponseModel للـ BottomSheet ──
  PlaceItemResponseModel _toPlaceItemResponseModel() {
    final place = favourite.place;
    return PlaceItemResponseModel(
      id: place.id,
      name: LocalizedTextModel(ar: place.name.ar, en: place.name.en),
      description: LocalizedTextModel(
        ar: place.description.ar,
        en: place.description.en,
      ),
      imageUrl: place.imageUrl,
      isFree: place.isFree,
      priceLocalized: LocalizedTextModel(
        ar: place.price.ar,
        en: place.price.en,
      ),
      priceNumber: place.priceNumber,
      location: LocalizedTextModel(
        ar: place.location.ar,
        en: place.location.en,
      ),
      ratingAvg: place.ratingAvg,
      totalBookings: place.totalBookings,
      isBooked: place.isBooked,
      coordinates: place.coordinates != null
          ? CoordinatesModel(
              latitude: place.coordinates!.latitude,
              longitude: place.coordinates!.longitude,
            )
          : null,
      category: place.category,
      categoryLabel: place.categoryLabel != null
          ? LocalizedTextModel(
              ar: place.categoryLabel!.ar,
              en: place.categoryLabel!.en,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;
    final place = favourite.place;
    final categoryColor = _getCategoryColor(place.category);
    final isBooked = place.isBooked;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Image Section ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                child: Image.network(
                  _fixImageUrl(place.imageUrl),
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 160.h,
                      color: const Color(0xFFF5F5F5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: 160.h,
                    color: const Color(0xFFE8D5B0),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 30.sp,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Remove (Favourite) Button ──
              Positioned(
                top: 10.h,
                left: langCode == 'ar' ? 10.w : null,
                right: langCode == 'ar' ? null : 10.w,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 38.w,
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Booked Badge على الصورة ──
              if (isBooked)
                Positioned(
                  bottom: 10.h,
                  right: langCode == 'ar' ? null : 10.w,
                  left: langCode == 'ar' ? 10.w : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6.r,
                        ),
                      ],
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
                          langCode == 'ar' ? 'تم الحجز' : 'Booked',
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
          ),

          // ── Content Section ──
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name + Details Button ──
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

                    // ── Details Button ──
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
                            size: 16.sp,
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

                SizedBox(height: 6.h),

                // ── Location Row ──
                if (place.location.ar.isNotEmpty ||
                    place.location.en.isNotEmpty)
                  GestureDetector(
                    onTap: place.coordinates != null
                        ? () => MapLauncherHelper.openGoogleMaps(
                            context: context,
                            latitude: place.coordinates!.latitude,
                            longitude: place.coordinates!.longitude,
                            label: place.name.localized(langCode),
                          )
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                          size: 14.sp,
                        ),
                        SizedBox(width: 3.w),
                        Flexible(
                          child: Text(
                            place.location.localized(langCode),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textMedium,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (place.coordinates != null) ...[
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.open_in_new_rounded,
                            color: AppColors.primary,
                            size: 11.sp,
                          ),
                        ],
                      ],
                    ),
                  ),

                SizedBox(height: 8.h),

                // ── Category Badge + Price Badge + Rating ──
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
                              _getCategoryIcon(place.category),
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

                    // ── Price Badge ──
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: place.isFree
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: place.isFree ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Text(
                        place.price.localized(langCode),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: place.isFree ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ── Rating ──
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.rating,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          place.ratingAvg > 0
                              ? place.ratingAvg.toStringAsFixed(1)
                              : langCode == 'ar'
                              ? 'لا يوجد'
                              : 'N/A',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // ── Description ──
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    place.description.localized(langCode),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textMedium,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                SizedBox(height: 12.h),

                // ── Book Button أو Booked Button ──
                SizedBox(
                  width: double.infinity,
                  child: isBooked
                      // ── تم الحجز ──
                      ? ElevatedButton.icon(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade50,
                            foregroundColor: Colors.green.shade700,
                            disabledBackgroundColor: Colors.green.shade50,
                            disabledForegroundColor: Colors.green.shade700,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(color: Colors.green.shade300),
                            ),
                            elevation: 0,
                          ),
                          icon: Icon(Icons.check_circle_rounded, size: 18.sp),
                          label: Text(
                            langCode == 'ar' ? 'تم الحجز ✓' : 'Booked ✓',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      // ── احجز ──
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
                                    context
                                        .read<ProfileCubit>()
                                        .getFavourites();
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          icon: Icon(Icons.calendar_month_rounded, size: 18.sp),
                          label: Text(
                            langCode == 'ar' ? 'احجز' : 'Book',
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

String _fixImageUrl(String url) {
  return url.replaceFirst('http://', 'https://');
}
