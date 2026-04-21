// lib/features/profile/data/models/booking_list_model.dart

class BookingListLocalizedModel {
  final String ar;
  final String en;

  BookingListLocalizedModel({required this.ar, required this.en});

  factory BookingListLocalizedModel.fromJson(Map<String, dynamic> json) {
    return BookingListLocalizedModel(
      ar: json['ar']?.toString() ?? '',
      en: json['en']?.toString() ?? '',
    );
  }

  String localized(String langCode) => langCode == 'ar' ? ar : en;
}

// ── Deposit Info ──
class DepositInfoModel {
  final bool required;
  final double amount;
  final int? percentage;
  final String? amountAr;
  final String? amountEn;
  final BookingListLocalizedModel? note;

  DepositInfoModel({
    required this.required,
    required this.amount,
    this.percentage,
    this.amountAr,
    this.amountEn,
    this.note,
  });

  factory DepositInfoModel.fromJson(Map<String, dynamic> json) {
    return DepositInfoModel(
      required: json['required'] ?? false,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: json['percentage'],
      amountAr: json['amount_ar'],
      amountEn: json['amount_en'],
      note: json['note'] != null
          ? BookingListLocalizedModel.fromJson(json['note'])
          : null,
    );
  }

  String localizedAmount(String langCode) =>
      langCode == 'ar' ? (amountAr ?? '') : (amountEn ?? '');
}

// ── Booking Place ──
class BookingListPlaceModel {
  final int id;
  final BookingListLocalizedModel name;
  final String imageUrl;
  final BookingListLocalizedModel location;

  BookingListPlaceModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.location,
  });

  factory BookingListPlaceModel.fromJson(Map<String, dynamic> json) {
    return BookingListPlaceModel(
      id: json['id'] ?? 0,
      name: BookingListLocalizedModel.fromJson(json['name'] ?? {}),
      imageUrl: json['image_url'] ?? '',
      location: BookingListLocalizedModel.fromJson(json['location'] ?? {}),
    );
  }
}

// ── Booking ──
class BookingListModel {
  final int id;
  final BookingListPlaceModel place;
  final String bookingDate;
  final int personCount;
  final BookingListLocalizedModel totalPrice;
  final double totalPriceNumber;
  final String status;
  final BookingListLocalizedModel statusLabel;
  final String createdAt;

  // ── Payment Fields ──
  final String placeType;
  final BookingListLocalizedModel? placeTypeLabel;
  final double depositAmount;
  final DepositInfoModel? depositInfo;
  final String paymentStatus;
  final BookingListLocalizedModel? paymentStatusLabel;
  final double amountPaid;
  final double remainingAmount;

  BookingListModel({
    required this.id,
    required this.place,
    required this.bookingDate,
    required this.personCount,
    required this.totalPrice,
    required this.totalPriceNumber,
    required this.status,
    required this.statusLabel,
    required this.createdAt,
    required this.placeType,
    this.placeTypeLabel,
    required this.depositAmount,
    this.depositInfo,
    required this.paymentStatus,
    this.paymentStatusLabel,
    required this.amountPaid,
    required this.remainingAmount,
  });

  // ── Helpers ──
  bool get isLandmark => placeType == 'landmark';
  bool get isHotel => placeType == 'hotel';
  bool get isRestaurant => placeType == 'restaurant';
  bool get needsDeposit => depositInfo?.required ?? false;
  bool get isPaid => paymentStatus == 'fully_paid';
  bool get isUnpaid => paymentStatus == 'unpaid';
  bool get canPay => (status == 'pending' || status == 'confirmed') && isUnpaid;

  // ── Amount to Pay ──
  double get amountToPay {
    if (isLandmark) return totalPriceNumber;
    return depositAmount;
  }

  factory BookingListModel.fromJson(Map<String, dynamic> json) {
    return BookingListModel(
      id: json['id'] ?? 0,
      place: BookingListPlaceModel.fromJson(json['place'] ?? {}),
      bookingDate: json['booking_date'] ?? '',
      personCount: json['person_count'] ?? 0,
      totalPrice: BookingListLocalizedModel.fromJson(json['total_price'] ?? {}),
      totalPriceNumber: (json['total_price_number'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      statusLabel: BookingListLocalizedModel.fromJson(
        json['status_label'] ?? {},
      ),
      createdAt: json['created_at'] ?? '',
      placeType: json['place_type'] ?? 'landmark',
      placeTypeLabel: json['place_type_label'] != null
          ? BookingListLocalizedModel.fromJson(json['place_type_label'])
          : null,
      depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 0.0,
      depositInfo: json['deposit_info'] != null
          ? DepositInfoModel.fromJson(json['deposit_info'])
          : null,
      paymentStatus: json['payment_status'] ?? 'unpaid',
      paymentStatusLabel: json['payment_status_label'] != null
          ? BookingListLocalizedModel.fromJson(json['payment_status_label'])
          : null,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
