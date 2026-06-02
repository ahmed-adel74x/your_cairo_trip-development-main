// lib/features/home/presentation/screens/home_screen.dart

import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../places/presentation/cubit/places_cubit.dart';
import '../../../places/presentation/cubit/places_state.dart';
import '../../../places/presentation/screens/places_list_screen.dart';
import '../widgets/top_bar_widget.dart';
import '../widgets/image_carousel_widget.dart';
import '../widgets/badge_widget.dart';
import '../widgets/headline_widget.dart';
import '../widgets/budget_card_widget.dart';
import '../../data/models/place_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _personCountController = TextEditingController(
    text: '1',
  );

  final List<PlaceModel> _places = PlacesData.cairoPlaces;
  bool _showEmergencyMenu = false;

  // ── بيانات الطوارئ ──
  final Map<String, Map<String, String>> _emergencyContacts = {
    'ambulance': {
      'ar': 'الإسعاف',
      'en': 'Ambulance',
      'number': '123',
    },
    'police': {
      'ar': 'الشرطة',
      'en': 'Police',
      'number': '122',
    },
    'fire': {
      'ar': 'المطافئ',
      'en': 'Fire',
      'number': '180',
    },
  };

  @override
  void dispose() {
    _budgetController.dispose();
    _personCountController.dispose();
    super.dispose();
  }

  // ── دالة لفتح الاتصال ──
  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.locale.languageCode == 'ar'
                  ? 'لا يمكن إجراء المكالمة'
                  : 'Cannot make call',
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
    final isAr = langCode == 'ar';

    return BlocProvider(
      create: (_) => sl<PlacesCubit>(),
      child: BlocConsumer<PlacesCubit, PlacesState>(
        listener: (context, state) {
          if (state is PlacesSuccess) {
            final placesCubit = context.read<PlacesCubit>();

            Navigator.push(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: '/places'),
                builder: (_) => BlocProvider.value(
                  value: placesCubit,
                  child: PlacesListScreen(budgetResponse: state.budgetResponse),
                ),
              ),
            );
          }
          if (state is PlacesFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is PlacesLoading;

          return Directionality(
            textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: Stack(
                children: [
                  // ── Background ──
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.26,
                      child: Image.asset(
                        'assets/images/background_mosque.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Column(
                        children: [
                          // ── Top Bar ──
                          const TopBarWidget(),

                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Image Carousel ──
                                  ImageCarouselWidget(places: _places),

                                  SizedBox(height: 20.h),

                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // ── Badge ──
                                        const BadgeWidget(),

                                        SizedBox(height: 12.h),

                                        // ── Headline ──
                                        const HeadlineWidget(),

                                        SizedBox(height: 20.h),

                                        // ── Budget Card ──
                                        BudgetCardWidget(
                                          budgetController: _budgetController,
                                          personCountController:
                                              _personCountController,
                                          isLoading: isLoading,
                                          onDiscover: () =>
                                              _onDiscover(context),
                                        ),

                                        SizedBox(height: 24.h),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── زر الطوارئ العائم ──
                  Positioned(
                    bottom: 24.h,
                    right: isAr ? 20.w : null,
                    left: isAr ? null : 20.w,
                    child: AnimatedOpacity(
                      opacity: _showEmergencyMenu ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: _showEmergencyMenu
                          ? _buildEmergencyMenuContainer(isAr, langCode)
                          : SizedBox.shrink(),
                    ),
                  ),

                  // ── زر الطوارئ الرئيسي ──
                  Positioned(
                    bottom: _showEmergencyMenu ? 340.h : 24.h,
                    right: isAr ? 20.w : null,
                    left: isAr ? null : 20.w,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _buildEmergencyButton(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── بناء زر الطوارئ ──
  Widget _buildEmergencyButton() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _showEmergencyMenu = !_showEmergencyMenu;
        });
      },
      backgroundColor: Colors.red,
      elevation: 8,
      child: AnimatedRotation(
        turns: _showEmergencyMenu ? 0.125 : 0,
        duration: const Duration(milliseconds: 300),
        child: const Icon(Icons.emergency, color: Colors.white, size: 28),
      ),
    );
  }

  // ── بناء كونتينر قائمة الطوارئ ──
  Widget _buildEmergencyMenuContainer(bool isAr, String langCode) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // ── العنوان ──
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Text(
              langCode == 'ar' ? 'حالات الطوارئ' : 'Emergency Services',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // ── خط فاصل ──
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Divider(
              color: Colors.grey[300],
              thickness: 1,
            ),
          ),

          // ── أزرار الطوارئ ──
          ..._emergencyContacts.entries.map((entry) {
            final key = entry.key;
            final data = entry.value;
            final label = langCode == 'ar' ? data['ar']! : data['en']!;
            final number = data['number']!;

            IconData icon;
            Color buttonColor;

            switch (key) {
              case 'ambulance':
                icon = Icons.medical_services;
                buttonColor = Colors.red;
                break;
              case 'police':
                icon = Icons.security;
                buttonColor = Colors.blue;
                break;
              case 'fire':
                icon = Icons.fire_truck;
                buttonColor = Colors.orange;
                break;
              default:
                icon = Icons.help;
                buttonColor = Colors.grey;
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: GestureDetector(
                onTap: () {
                  _makeCall(number);
                  setState(() {
                    _showEmergencyMenu = false;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: buttonColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: buttonColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection:
                        isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      SizedBox(width: 12.w),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isAr
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              number,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: buttonColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.phone,
                        color: buttonColor,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _onDiscover(BuildContext context) async {
    final token = await TokenManager.getToken();

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.locale.languageCode == 'ar'
                  ? 'يجب تسجيل الدخول أولاً'
                  : 'You must login first',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (mounted) {
      context.read<PlacesCubit>().getBudgetPlaces(
        budget: _budgetController.text.trim(),
        personCount: _personCountController.text.trim(),
        token: token,
      );
    }
  }
}