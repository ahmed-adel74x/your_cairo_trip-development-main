// lib/features/explore/presentation/cubit/explore_cubit.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_cairo_trip/core/error/failures.dart';
import '../../../../core/constants/app_translation_keys.dart';
import '../../../../core/storage/token_manager.dart';
import '../../data/models/explore_place_model.dart';
import '../../data/repositories/explore_repository.dart';
import 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  final ExploreRepository _repository;

  // ── القائمة الأصلية الكاملة ──
  List<ExplorePlaceModel> _allPlaces = [];

  String _activeCategory = 'all';

  ExploreCubit(this._repository) : super(ExploreInitial());

  // ── جلب كل الأماكن ──
  Future<void> getPlaces() async {
    emit(ExploreLoading());
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        emit(ExploreFailure('يجب تسجيل الدخول أولاً'));
        return;
      }
      _allPlaces = await _repository.getPlaces(token);
      _activeCategory = 'all';
      emit(ExploreSuccess(places: _allPlaces, activeCategory: _activeCategory));
    } on ServerFailure catch (e) {
      emit(ExploreFailure(e.message));
    } on NetworkFailure catch (_) {
      emit(ExploreFailure(AppTranslationKeys.noInternet.tr()));
    } catch (_) {
      emit(ExploreFailure(AppTranslationKeys.exploreUnexpectedError.tr()));
    }
  }

  // ── السيرش ──
  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      _applyFilters();
      return;
    }

    emit(ExploreLoading());
    try {
      final token = await TokenManager.getToken();
      if (token == null) return;

      final results = await _repository.searchPlaces(query, token);
      emit(ExploreSuccess(places: results, activeCategory: _activeCategory));
    } on ServerFailure catch (e) {
      emit(ExploreFailure(e.message));
    } on NetworkFailure catch (_) {
      emit(ExploreFailure(AppTranslationKeys.noInternet.tr()));
    } catch (_) {
      emit(ExploreFailure(AppTranslationKeys.exploreUnexpectedError.tr()));
    }
  }

  // ── فلتر الـ Category (locally) ──
  void filterByCategory(String category) {
    _activeCategory = category;
    _applyFilters();
  }

  // ── تطبيق الـ Category filter ──
  void _applyFilters() {
    List<ExplorePlaceModel> result = List.from(_allPlaces);

    if (_activeCategory != 'all') {
      result = result
          .where((place) => place.category == _activeCategory)
          .toList();
    }

    emit(ExploreSuccess(places: result, activeCategory: _activeCategory));
  }

  // ── Toggle Favourite ──
  Future<void> toggleFavourite(int placeId) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) return;

      final isFavourite = await _repository.toggleFavourite(placeId, token);

      for (final place in _allPlaces) {
        if (place.id == placeId) {
          place.isFavourite = isFavourite;
          break;
        }
      }

      emit(ExploreFavouriteUpdated(placeId: placeId, isFavourite: isFavourite));
      _applyFilters();
    } catch (_) {}
  }

  // ── تحديث الحجز محلياً فوراً بدون API call ──
  void markAsBooked(int placeId) {
    final allIndex = _allPlaces.indexWhere((p) => p.id == placeId);
    if (allIndex != -1) {
      _allPlaces[allIndex] = _createBookedCopy(_allPlaces[allIndex]);
    }

    _applyFilters();
  }

  // ── Helper: نسخة جديدة من الـ place بـ isBooked = true ──
  ExplorePlaceModel _createBookedCopy(ExplorePlaceModel place) {
    return ExplorePlaceModel(
      id: place.id,
      name: place.name,
      description: place.description,
      imageUrl: place.imageUrl,
      isFree: place.isFree,
      price: place.price,
      priceNumber: place.priceNumber,
      workingHours: place.workingHours,
      location: place.location,
      ratingAvg: place.ratingAvg,
      totalBookings: place.totalBookings,
      activities: place.activities,
      isFavourite: place.isFavourite,
      isBooked: true,
      coordinates: place.coordinates,
      category: place.category,
      categoryLabel: place.categoryLabel,
    );
  }
}
