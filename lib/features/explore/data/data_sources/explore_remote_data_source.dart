// lib/features/explore/data/data_sources/explore_remote_data_source.dart

import 'package:dio/dio.dart';
import '../../../../core/constants/app_endpoints.dart';
import '../models/explore_place_model.dart';

class ExploreRemoteDataSource {
  final Dio _dio;

  ExploreRemoteDataSource(this._dio);

  Options _authOptions(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  // ── جلب كل الأماكن (attractions + restaurants + hotels) ──
  Future<List<ExplorePlaceModel>> getPlaces(String token) async {
    final response = await _dio.get(
      AppEndpoints.explore,
      options: _authOptions(token),
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final List<ExplorePlaceModel> allPlaces = [];

    // ── attractions ──
    final attractions = data['attractions'] as List? ?? [];
    allPlaces.addAll(
      attractions.map(
        (e) => ExplorePlaceModel.fromJson(
          e as Map<String, dynamic>,
          defaultCategory: 'attraction',
        ),
      ),
    );

    // ── restaurants ──
    final restaurants = data['restaurants'] as List? ?? [];
    allPlaces.addAll(
      restaurants.map(
        (e) => ExplorePlaceModel.fromJson(
          e as Map<String, dynamic>,
          defaultCategory: 'restaurant',
        ),
      ),
    );

    // ── hotels ──
    final hotels = data['hotels'] as List? ?? [];
    allPlaces.addAll(
      hotels.map(
        (e) => ExplorePlaceModel.fromJson(
          e as Map<String, dynamic>,
          defaultCategory: 'hotel',
        ),
      ),
    );

    return allPlaces;
  }

  // ── السيرش ──
  Future<List<ExplorePlaceModel>> searchPlaces(
    String query,
    String token,
  ) async {
    final response = await _dio.get(
      AppEndpoints.exploreSearch,
      queryParameters: {'q': query},
      options: _authOptions(token),
    );

    final data = response.data['data'];

    // ── لو الريسبونس فيه categories ──
    if (data is Map<String, dynamic> &&
        (data.containsKey('attractions') ||
            data.containsKey('restaurants') ||
            data.containsKey('hotels'))) {
      final List<ExplorePlaceModel> allPlaces = [];

      final attractions = data['attractions'] as List? ?? [];
      allPlaces.addAll(
        attractions.map(
          (e) => ExplorePlaceModel.fromJson(e, defaultCategory: 'attraction'),
        ),
      );

      final restaurants = data['restaurants'] as List? ?? [];
      allPlaces.addAll(
        restaurants.map(
          (e) => ExplorePlaceModel.fromJson(e, defaultCategory: 'restaurant'),
        ),
      );

      final hotels = data['hotels'] as List? ?? [];
      allPlaces.addAll(
        hotels.map(
          (e) => ExplorePlaceModel.fromJson(e, defaultCategory: 'hotel'),
        ),
      );

      return allPlaces;
    }

    // ── لو الريسبونس list عادية ──
    if (data is List) {
      return data
          .map((e) => ExplorePlaceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  // ── الفلتر ──
  Future<List<ExplorePlaceModel>> filterPlaces({
    required String token,
    bool? isFree,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (isFree != null) queryParams['is_free'] = isFree;

    final response = await _dio.get(
      AppEndpoints.exploreFilter,
      queryParameters: queryParams,
      options: _authOptions(token),
    );

    final data = response.data['data'];

    if (data is Map<String, dynamic>) {
      final List<ExplorePlaceModel> allPlaces = [];

      final attractions = data['attractions'] as List? ?? [];
      allPlaces.addAll(
        attractions.map(
          (e) => ExplorePlaceModel.fromJson(e, defaultCategory: 'attraction'),
        ),
      );

      final restaurants = data['restaurants'] as List? ?? [];
      allPlaces.addAll(
        restaurants.map(
          (e) => ExplorePlaceModel.fromJson(e, defaultCategory: 'restaurant'),
        ),
      );

      final hotels = data['hotels'] as List? ?? [];
      allPlaces.addAll(
        hotels.map(
          (e) => ExplorePlaceModel.fromJson(e, defaultCategory: 'hotel'),
        ),
      );

      return allPlaces;
    }

    if (data is List) {
      return data
          .map((e) => ExplorePlaceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  // ── Toggle Favourite ──
  Future<bool> toggleFavourite(int placeId, String token) async {
    final response = await _dio.post(
      AppEndpoints.favouriteToggle(placeId),
      options: _authOptions(token),
    );
    return response.data['data']['is_favourite'] ?? false;
  }
}
