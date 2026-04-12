import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/screens/search_screen.dart';
import 'package:flyem_app/screens/my_shipments_screen.dart';
import 'package:flyem_app/screens/trips_screen.dart';
import 'package:flyem_app/screens/chat_screen.dart';
import 'package:flyem_app/screens/requests_hub_screen.dart';
import 'package:flyem_app/services/push_messaging_service.dart';
import 'package:flyem_app/screens/more_screen.dart';
import 'package:flyem_app/widgets/rive_nav_item.dart';

/// مسار ملف Rive للأيقونات
/// إما ملف واحد nav_icons.riv يحتوي artboards: search, shipments, trips, messages, more
/// أو ملفات منفصلة: search.riv, shipments.riv, trips.riv, messages.riv, more.riv
/// مسار بدون بادئة assets/ لتجنب تكرار assets/assets على الويب
const String _riveSingleFile = 'rive/nav_icons.riv';
/// على الويب لا نستخدم Rive (مشكلة 404 مع مسار الـ asset)
bool get _useRiveIcons => !kIsWeb;

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key, this.initialIndex = 0, this.openConversationId, this.openConversationName});

  final int initialIndex;
  final int? openConversationId;
  final String? openConversationName;

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _currentIndex;

  late List<Widget> _screens;

  void _initScreens() {
    _screens = [
      SearchScreen(),
      MyShipmentsScreen(),
      TripsScreen(),
      RequestsHubScreen(),
      MoreScreen(),
    ];
  }

  void _onAppLocale() {
    if (!mounted) return;
    _initScreens();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initScreens();
    AppLocale.notifier.addListener(_onAppLocale);
    _currentIndex = widget.initialIndex;
    if (widget.openConversationId != null && widget.openConversationName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: widget.openConversationId!,
              otherUserName: widget.openConversationName!,
            ),
          ),
        );
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PushMessagingService.syncTokenWithBackend();
    });
  }

  @override
  void dispose() {
    AppLocale.notifier.removeListener(_onAppLocale);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.navBarBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RiveNavItem(
                    label: AppStrings.navSearch,
                    isSelected: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0),
                    riveAsset: _useRiveIcons ? _riveSingleFile : null,
                    artboardName: _useRiveIcons ? 'search' : null,
                    fallbackIcon: Icons.search,
                  ),
                  RiveNavItem(
                    label: AppStrings.navShipmentsTab,
                    isSelected: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1),
                    riveAsset: _useRiveIcons ? _riveSingleFile : null,
                    artboardName: _useRiveIcons ? 'shipments' : null,
                    fallbackIcon: Icons.inventory_2_outlined,
                  ),
                  RiveNavItem(
                    label: AppStrings.navTrips,
                    isSelected: _currentIndex == 2,
                    onTap: () => setState(() => _currentIndex = 2),
                    riveAsset: _useRiveIcons ? _riveSingleFile : null,
                    artboardName: _useRiveIcons ? 'trips' : null,
                    fallbackIcon: Icons.luggage_outlined,
                  ),
                  RiveNavItem(
                    label: AppStrings.navRequests,
                    isSelected: _currentIndex == 3,
                    onTap: () => setState(() => _currentIndex = 3),
                    riveAsset: _useRiveIcons ? _riveSingleFile : null,
                    artboardName: _useRiveIcons ? 'messages' : null,
                    fallbackIcon: Icons.assignment_turned_in_outlined,
                  ),
                  RiveNavItem(
                    label: AppStrings.navMore,
                    isSelected: _currentIndex == 4,
                    onTap: () => setState(() => _currentIndex = 4),
                    riveAsset: _useRiveIcons ? _riveSingleFile : null,
                    artboardName: _useRiveIcons ? 'more' : null,
                    fallbackIcon: Icons.person_outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
