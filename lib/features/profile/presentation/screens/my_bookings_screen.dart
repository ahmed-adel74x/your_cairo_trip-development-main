// lib/features/profile/presentation/screens/my_bookings_screen.dart

import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_translation_keys.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/booking_list_model.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..getBookings(),
      child: const _MyBookingsView(),
    );
  }
}

class _MyBookingsView extends StatelessWidget {
  const _MyBookingsView();

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
            AppTranslationKeys.myBookingsTitle.tr(),
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
            // ── Cancel Success ──
            if (state is BookingCancelSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  content: Text(
                    AppTranslationKeys.myBookingsCancelSuccess.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            // ── Cancel Error ──
            if (state is BookingCancelError) {
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

            // ── Payment URL Ready → Open WebView ──
            if (state is PaymentUrlReady) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProfileCubit>(),
                    child: _PaymentWebView(
                      url: state.paymentUrl,
                      booking: state.booking,
                    ),
                  ),
                ),
              ).then((_) {
                // ← لما اليوزر يرجع من WebView بأي طريقة
                if (context.mounted) {
                  context.read<ProfileCubit>().resetToBookings();
                }
              });
            }

            // ── Payment Success ──
            if (state is PaymentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  content: Text(
                    AppTranslationKeys.myBookingsPaymentSuccess.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            // ── Payment Error ──
            if (state is PaymentError) {
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
            // ── Full Screen Loading (أول تحميل بس) ──
            if (state is BookingsLoading &&
                context.read<ProfileCubit>().cachedBookings.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            // ── Error (لو مفيش cache) ──
            if (state is BookingsError &&
                context.read<ProfileCubit>().cachedBookings.isEmpty) {
              return _buildError(context, state.message);
            }

            // ── جيب الـ bookings من الـ state أو الـ cache ──
            final List<BookingListModel> bookings;
            if (state is BookingsLoaded) {
              bookings = state.bookings;
            } else {
              bookings = context.read<ProfileCubit>().cachedBookings;
            }

            // ── Empty ──
            if (bookings.isEmpty) {
              return _buildEmptyState();
            }

            // ── List + Loading Overlay ──
            return Stack(
              children: [
                RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context.read<ProfileCubit>().getBookings(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.r),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return _BookingCard(
                        booking: booking,
                        onCancel:
                            booking.status == 'pending' ||
                                booking.status == 'confirmed'
                            ? () => _showCancelDialog(context, booking.id)
                            : null,
                        onPay: booking.canPay && booking.amountToPay > 0
                            ? () => _onPayPressed(context, booking)
                            : null,
                      );
                    },
                  ),
                ),

                // ── Payment Loading Overlay ──
                if (state is PaymentLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(24.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              langCode == 'ar'
                                  ? 'جاري تحضير الدفع...'
                                  : 'Preparing payment...',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Pay Pressed ──
  void _onPayPressed(BuildContext context, BookingListModel booking) {
    _showPaymentInfoDialog(context, booking, context.locale.languageCode);
  }

  // ── Payment Info Dialog ──
  void _showPaymentInfoDialog(
    BuildContext context,
    BookingListModel booking,
    String langCode,
  ) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: langCode == 'ar'
            ? ui.TextDirection.rtl
            : ui.TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.payment_rounded,
                color: AppColors.primary,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                AppTranslationKeys.myBookingsPayNow.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.place.name.localized(langCode),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Text(
                      booking.isLandmark
                          ? AppTranslationKeys.myBookingsFullPayment.tr()
                          : AppTranslationKeys.myBookingsDepositPayment.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textLight,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${booking.amountToPay.toStringAsFixed(0)} ${langCode == 'ar' ? 'جنيه' : 'EGP'}',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (!booking.isLandmark && booking.depositInfo != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        booking.depositInfo!.note?.localized(langCode) ?? '',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                langCode == 'ar' ? 'إلغاء' : 'Cancel',
                style: TextStyle(color: AppColors.textLight, fontSize: 14.sp),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _proceedToPayment(context, booking);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: Icon(Icons.credit_card_rounded, size: 16.sp),
              label: Text(
                AppTranslationKeys.myBookingsPayNow.tr(),
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Proceed to Payment ──
  void _proceedToPayment(BuildContext context, BookingListModel booking) async {
    final userInfo = await context.read<ProfileCubit>().getTokenForPayment();

    if (context.mounted) {
      context.read<ProfileCubit>().initiatePayment(
        booking: booking,
        userEmail: userInfo?['email'] ?? 'user@example.com',
        userName: userInfo?['name'] ?? 'User',
        userPhone: userInfo?['phone'] ?? '01000000000',
      );
    }
  }

  // ── Cancel Dialog ──
  void _showCancelDialog(BuildContext context, int bookingId) {
    final langCode = context.locale.languageCode;
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: langCode == 'ar'
            ? ui.TextDirection.rtl
            : ui.TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            AppTranslationKeys.myBookingsCancel.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          content: Text(
            AppTranslationKeys.myBookingsCancelConfirm.tr(),
            style: TextStyle(fontSize: 14.sp, color: AppColors.textLight),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                langCode == 'ar' ? 'تراجع' : 'Keep',
                style: TextStyle(color: AppColors.textLight, fontSize: 14.sp),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<ProfileCubit>().cancelBooking(bookingId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                AppTranslationKeys.myBookingsCancel.tr(),
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: AppColors.textLight,
            size: 70.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            AppTranslationKeys.myBookingsNoBookings.tr(),
            style: TextStyle(fontSize: 16.sp, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  // ── Error State ──
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
            onPressed: () => context.read<ProfileCubit>().getBookings(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
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

// ─── Payment WebView ──────────────────────────────────────────────────────────

class _PaymentWebView extends StatefulWidget {
  final String url;
  final BookingListModel booking;

  const _PaymentWebView({required this.url, required this.booking});

  @override
  State<_PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<_PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _paymentHandled = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
            _checkPaymentResult(url);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  // ── Check Payment Result ──
  void _checkPaymentResult(String url) {
    if (_paymentHandled) return;

    final isSuccess =
        url.contains('success=true') ||
        url.contains('txn_response_code=APPROVED');
    final isFailure =
        url.contains('success=false') ||
        url.contains('txn_response_code=DECLINED');

    if (isSuccess) {
      _paymentHandled = true;
      context.read<ProfileCubit>().confirmPayment(
        bookingId: widget.booking.id,
        amountPaid: widget.booking.amountToPay,
      );
      if (mounted) Navigator.pop(context);
    } else if (isFailure) {
      _paymentHandled = true;
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.locale.languageCode == 'ar'
                  ? 'فشل الدفع، يرجى المحاولة مرة أخرى'
                  : 'Payment failed, please try again',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _showExitConfirmDialog(context, langCode);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            AppTranslationKeys.myBookingsPayNow.tr(),
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () => _showExitConfirmDialog(context, langCode),
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.white,
              size: 22.sp,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }

  // ── Exit Confirm Dialog ──
  void _showExitConfirmDialog(BuildContext context, String langCode) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: langCode == 'ar'
            ? ui.TextDirection.rtl
            : ui.TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            langCode == 'ar' ? 'إلغاء الدفع؟' : 'Cancel Payment?',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            langCode == 'ar'
                ? 'هل أنت متأكد من الخروج؟ لن يتم تأكيد الدفع.'
                : 'Are you sure? Payment will not be confirmed.',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textLight),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                langCode == 'ar' ? 'متابعة الدفع' : 'Continue',
                style: TextStyle(color: AppColors.primary, fontSize: 14.sp),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _paymentHandled = true; // ← منع أي معالجة تانية
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close webview
                // ← الـ .then() في الـ listener هيعمل resetToBookings
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                langCode == 'ar' ? 'خروج' : 'Exit',
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Booking Card ─────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final BookingListModel booking;
  final VoidCallback? onCancel;
  final VoidCallback? onPay;

  const _BookingCard({required this.booking, this.onCancel, this.onPay});

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;
    final statusConfig = _getStatusConfig(booking.status);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          // ── Image + Badges ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: Image.network(
                  _fixImageUrl(booking.place.imageUrl),
                  height: 150.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150.h,
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

              // ── Status Badge ──
              Positioned(
                top: 10.h,
                left: langCode == 'ar' ? null : 10.w,
                right: langCode == 'ar' ? 10.w : null,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusConfig['color'] as Color,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusConfig['icon'] as IconData,
                        color: Colors.white,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        booking.statusLabel.localized(langCode),
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

              // ── Payment Status Badge ──
              Positioned(
                top: 10.h,
                right: langCode == 'ar' ? null : 10.w,
                left: langCode == 'ar' ? 10.w : null,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: booking.isPaid ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        booking.isPaid
                            ? Icons.check_circle_rounded
                            : Icons.payment_rounded,
                        color: Colors.white,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        booking.paymentStatusLabel?.localized(langCode) ?? '',
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

          // ── Content ──
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Place Name + Type ──
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking.place.name.localized(langCode),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getPlaceTypeColor(
                          booking.placeType,
                        ).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPlaceTypeIcon(booking.placeType),
                            size: 11.sp,
                            color: _getPlaceTypeColor(booking.placeType),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            booking.placeTypeLabel?.localized(langCode) ?? '',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: _getPlaceTypeColor(booking.placeType),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                // ── Location ──
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textLight,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        booking.place.location.localized(langCode),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // ── Info Chips ──
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_today_rounded,
                      label: booking.bookingDate,
                    ),
                    _InfoChip(
                      icon: Icons.people_rounded,
                      label:
                          '${booking.personCount} ${langCode == 'ar' ? 'أفراد' : 'People'}',
                    ),
                    _InfoChip(
                      icon: Icons.payments_outlined,
                      label: booking.totalPrice.localized(langCode),
                    ),
                  ],
                ),

                // ── Deposit Info ──
                if (!booking.isLandmark &&
                    booking.depositInfo != null &&
                    booking.depositInfo!.required &&
                    !booking.isPaid) ...[
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.orange,
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            booking.depositInfo!.note?.localized(langCode) ??
                                '',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Buttons ──
                if (onPay != null || onCancel != null) ...[
                  SizedBox(height: 12.h),
                  const Divider(color: Color(0xFFEEEEEE)),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      if (onPay != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onPay,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            icon: Icon(Icons.credit_card_rounded, size: 16.sp),
                            label: Text(
                              AppTranslationKeys.myBookingsPayNow.tr(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      if (onPay != null && onCancel != null)
                        SizedBox(width: 8.w),

                      if (onCancel != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            icon: Icon(Icons.cancel_outlined, size: 16.sp),
                            label: Text(
                              AppTranslationKeys.myBookingsCancel.tr(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'confirmed':
        return {'color': Colors.green, 'icon': Icons.check_circle_rounded};
      case 'cancelled':
        return {'color': Colors.red, 'icon': Icons.cancel_rounded};
      case 'completed':
        return {'color': Colors.blue, 'icon': Icons.done_all_rounded};
      default:
        return {'color': Colors.orange, 'icon': Icons.hourglass_empty_rounded};
    }
  }

  Color _getPlaceTypeColor(String placeType) {
    switch (placeType) {
      case 'hotel':
        return Colors.blue;
      case 'restaurant':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _getPlaceTypeIcon(String placeType) {
    switch (placeType) {
      case 'hotel':
        return Icons.hotel_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      default:
        return Icons.place_rounded;
    }
  }
}

// ─── Info Chip ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}

String _fixImageUrl(String url) {
  return url.replaceFirst('http://', 'https://');
}
