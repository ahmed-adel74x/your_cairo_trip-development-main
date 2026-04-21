// lib/features/profile/data/models/favourite_model.dart

class FavouriteLocalizedModel {
  final String ar;
  final String en;

  FavouriteLocalizedModel({required this.ar, required this.en});

  factory FavouriteLocalizedModel.fromJson(Map<String, dynamic> json) {
    return FavouriteLocalizedModel(
      ar: json['ar']?.toString() ?? '',
      en: json['en']?.toString() ?? '',
    );
  }

  String localized(String langCode) => langCode == 'ar' ? ar : en;
}

// ── Coordinates ──
class FavouriteCoordinatesModel {
  final double latitude;
  final double longitude;

  FavouriteCoordinatesModel({required this.latitude, required this.longitude});

  factory FavouriteCoordinatesModel.fromJson(Map<String, dynamic> json) {
    return FavouriteCoordinatesModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ── Favourite Place ──
class FavouritePlaceModel {
  final int id;
  final FavouriteLocalizedModel name;
  final FavouriteLocalizedModel description;
  final String imageUrl;
  final bool isFree;
  final FavouriteLocalizedModel price;
  final double priceNumber;
  final FavouriteLocalizedModel location;
  final double ratingAvg;
  final int totalBookings;
  final bool isBooked;

  // ── جديد ──
  final FavouriteCoordinatesModel? coordinates;
  final String? category;
  final FavouriteLocalizedModel? categoryLabel;

  FavouritePlaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.isFree,
    required this.price,
    required this.priceNumber,
    required this.location,
    required this.ratingAvg,
    required this.totalBookings,
    this.isBooked = false,
    // ── جديد ──
    this.coordinates,
    this.category,
    this.categoryLabel,
  });

  factory FavouritePlaceModel.fromJson(Map<String, dynamic> json) {
    return FavouritePlaceModel(
      id: json['id'] ?? 0,
      name: FavouriteLocalizedModel.fromJson(json['name'] ?? {}),
      description: FavouriteLocalizedModel.fromJson(json['description'] ?? {}),
      imageUrl: json['image_url'] ?? '',
      isFree: json['is_free'] ?? false,
      price: FavouriteLocalizedModel.fromJson(json['price'] ?? {}),
      priceNumber: (json['price_number'] as num?)?.toDouble() ?? 0.0,
      location: FavouriteLocalizedModel.fromJson(json['location'] ?? {}),
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0.0,
      totalBookings: json['total_bookings'] ?? 0,
      isBooked: json['is_booked'] ?? false,
      // ── جديد ──
      coordinates: json['coordinates'] != null
          ? FavouriteCoordinatesModel.fromJson(json['coordinates'])
          : null,
      category: json['category']?.toString(),
      categoryLabel: json['category_label'] != null
          ? FavouriteLocalizedModel.fromJson(json['category_label'])
          : null,
    );
  }
}

// ── Favourite ──
class FavouriteModel {
  final int id;
  final FavouritePlaceModel place;
  final String createdAt;

  FavouriteModel({
    required this.id,
    required this.place,
    required this.createdAt,
  });

  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    return FavouriteModel(
      id: json['id'] ?? 0,
      place: FavouritePlaceModel.fromJson(json['place'] ?? {}),
      createdAt: json['created_at'] ?? '',
    );
  }
}
