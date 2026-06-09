// lib/core/constants/app_endpoints.dart

class AppEndpoints {
  AppEndpoints._();

  static const String baseUrl =
      'https://cairo-trip-main-production-893b.up.railway.app/api';

  // ── Auth ──
  static const String login = '/auth/login';
  static const String signUp = '/auth/register';
  static const String profile = '/auth/profile';
  static const String logout = '/auth/logout';

  // ── Places ──
  static const String budget = '/budget/calculate';

  // ── Booking ──
  static const String createBooking = '/bookings';
  static const String getBookings = '/bookings';
  static String cancelBooking(int bookingId) => '/bookings/$bookingId/cancel';
  static String payBooking(int bookingId) => '/bookings/$bookingId/pay';

  // ── Explore ──
  static const String explore = '/explore';
  static const String exploreSearch = '/explore/search';
  static const String exploreFilter = '/explore/filter';

  // ── Favourites ──
  static const String getFavourites = '/favourites';
  static String favouriteToggle(int placeId) => '/favourites/$placeId/toggle';

  // ── Trips ──
  static const String getTrips = '/trips';
  static const String getCompletedTrips = '/trips/completed';
  static const String getUpcomingTrips = '/trips/upcoming';

  // ── Ratings ──
  static const String rateTrip = '/ratings';

  // ── Support ──
  static const String support = '/support';

  // ── Paymob ──
  static const String paymobAuthUrl =
      'https://accept.paymob.com/api/auth/tokens';
  static const String paymobOrderUrl =
      'https://accept.paymob.com/api/ecommerce/orders';
  static const String paymobPaymentKeyUrl =
      'https://accept.paymob.com/api/acceptance/payment_keys';
  static const String paymobIframeBaseUrl =
      'https://accept.paymob.com/api/acceptance/iframes/';
}
