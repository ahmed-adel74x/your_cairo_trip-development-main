import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncherHelper {
  MapLauncherHelper._();

  /// يفتح Google Maps بالـ coordinates
  static Future<void> openGoogleMaps({
    required BuildContext context,
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    // ── أول محاولة: فتح الـ Google Maps App مباشرة ──
    final googleMapsAppUrl = Uri.parse(
      'comgooglemaps://?q=$latitude,$longitude&zoom=15',
    );

    // ── تاني محاولة: فتح Google Maps في المتصفح ──
    final googleMapsWebUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    // ── تالت محاولة: geo URI (بيفتح أي تطبيق خرائط على الجهاز) ──
    final geoUrl = Uri.parse(
      label != null
          ? 'geo:$latitude,$longitude?q=$latitude,$longitude($label)'
          : 'geo:$latitude,$longitude?q=$latitude,$longitude',
    );

    try {
      // ── جرب الـ geo URI الأول (بيفتح Google Maps أو أي Maps app) ──
      if (await canLaunchUrl(geoUrl)) {
        await launchUrl(geoUrl);
        return;
      }

      // ── لو مش شغال جرب Google Maps App ──
      if (await canLaunchUrl(googleMapsAppUrl)) {
        await launchUrl(googleMapsAppUrl);
        return;
      }

      // ── لو مش شغال افتح في المتصفح ──
      if (await canLaunchUrl(googleMapsWebUrl)) {
        await launchUrl(googleMapsWebUrl, mode: LaunchMode.externalApplication);
        return;
      }

      // ── لو كل حاجة فشلت ──
      if (context.mounted) {
        _showErrorSnackBar(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showErrorSnackBar(context);
      }
    }
  }

  static void _showErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.mounted ? 'تعذر فتح الخريطة' : 'Could not open maps',
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
