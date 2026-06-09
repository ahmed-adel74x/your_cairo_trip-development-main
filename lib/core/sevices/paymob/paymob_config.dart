// lib/core/constants/paymob_config.dart

class PaymobConfig {
  PaymobConfig._();

  static const String apiKey =
      'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRFMU5URTNNU3dpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS5lTExpRmFPYS1LTk5hejBORWJRRUZsdkczV0N6V1FlV21aTE4yWGUzUlIwUnhnZnJnZEd5dTVaZGc2RDRjVW53Wl82MHdvUlJIQmgzbDRWTUI4S3g3UQ==';

  static const int integrationId = 5625702;
  static const int iframeId = 1035411;

  // ── Currency ──
  static const String currency = 'EGP';

  // ── Amount Multiplier (Paymob بيشتغل بالقروش) ──
  static int toPaymobAmount(double amount) => (amount * 100).round();
}
