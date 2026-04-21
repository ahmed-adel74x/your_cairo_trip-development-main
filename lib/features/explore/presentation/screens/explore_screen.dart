// lib/features/explore/presentation/screens/explore_screen.dart

import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_translation_keys.dart';
import '../../../../core/di/service_locator.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';
import '../widgets/explore_search_bar_widget.dart';
import '../widgets/explore_category_tabs_widget.dart';
import '../widgets/explore_place_card_widget.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExploreCubit>()..getPlaces(),
      child: const _ExploreView(),
    );
  }
}

class _ExploreView extends StatefulWidget {
  const _ExploreView();

  @override
  State<_ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<_ExploreView> {
  String _activeCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;
    final isAr = langCode == 'ar';

    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            AppTranslationKeys.exploreTitle.tr(),
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
          ),
        ),
        body: Column(
          children: [
            // ── Search Bar ──
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: ExploreSearchBarWidget(
                onSearch: (query) {
                  context.read<ExploreCubit>().searchPlaces(query);
                },
                onClear: () {
                  context.read<ExploreCubit>().getPlaces();
                },
              ),
            ),

            // ── Category Tabs ──
            BlocBuilder<ExploreCubit, ExploreState>(
              buildWhen: (prev, curr) =>
                  curr is ExploreSuccess || curr is ExploreLoading,
              builder: (context, state) {
                final activeCategory = state is ExploreSuccess
                    ? state.activeCategory
                    : _activeCategory;

                return ExploreCategoryTabsWidget(
                  activeCategory: activeCategory,
                  onCategoryChanged: (category) {
                    _activeCategory = category;
                    context.read<ExploreCubit>().filterByCategory(category);
                  },
                );
              },
            ),

            // ── Places List ──
            Expanded(
              child: BlocConsumer<ExploreCubit, ExploreState>(
                listener: (context, state) {
                  if (state is ExploreFavouriteUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.isFavourite
                              ? AppTranslationKeys.exploreFavouriteAdded.tr()
                              : AppTranslationKeys.exploreFavouriteRemoved.tr(),
                        ),
                        backgroundColor: state.isFavourite
                            ? Colors.green.shade600
                            : Colors.red.shade400,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  // ── Loading ──
                  if (state is ExploreLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  // ── Failure ──
                  if (state is ExploreFailure) {
                    return _buildError(context, state.message);
                  }

                  // ── Success ──
                  if (state is ExploreSuccess) {
                    if (state.places.isEmpty) {
                      return const _EmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () => context.read<ExploreCubit>().getPlaces(),
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.r),
                        itemCount: state.places.length,
                        itemBuilder: (context, index) {
                          return ExplorePlaceCardWidget(
                            place: state.places[index],
                          );
                        },
                      ),
                    );
                  }

                  if (state is ExploreFavouriteUpdated) {
                    return const SizedBox.shrink();
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error Widget ──
  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.red.shade300, size: 70.sp),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: () => context.read<ExploreCubit>().getPlaces(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: Icon(Icons.refresh_rounded, size: 18.sp),
            label: Text(
              AppTranslationKeys.loading.tr(),
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64.sp,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16.h),
          Text(
            AppTranslationKeys.exploreNoResults.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
