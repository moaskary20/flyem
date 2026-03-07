import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:flyem_app/core/app_theme.dart';

/// عنصر في الـ NavBar يعرض أيقونة Rive متحركة أو أيقونة عادية كبديل
class RiveNavItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  /// مسار ملف .riv (مثل assets/rive/search.riv)
  /// إذا كان null أو الملف غير موجود يُستخدم [fallbackIcon]
  final String? riveAsset;

  /// اسم الـ artboard داخل الملف (غالباً "Main" أو اسم الأيقونة)
  final String? artboardName;

  /// اسم الـ State Machine داخل الـ artboard (غالباً "State Machine")
  final String? stateMachineName;

  /// اسم الـ input البولياني للتفعيل (غالباً "active" أو "isActive")
  final String? activeInputName;

  final IconData fallbackIcon;

  const RiveNavItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.riveAsset,
    this.artboardName,
    this.stateMachineName = 'State Machine',
    this.activeInputName = 'active',
    this.fallbackIcon = Icons.circle_outlined,
  });

  @override
  State<RiveNavItem> createState() => _RiveNavItemState();
}

class _RiveNavItemState extends State<RiveNavItem> {
  StateMachineController? _controller;
  SMIBool? _activeInput;
  bool _riveAvailable = false;
  bool _riveChecked = false;

  @override
  void initState() {
    super.initState();
    _checkRiveAsset();
  }

  /// مفتاح الـ asset في Flutter (لـ rootBundle)
  String get _assetKey =>
      widget.riveAsset!.startsWith('assets/') ? widget.riveAsset! : 'assets/${widget.riveAsset!}';

  /// مسار يُمرّر لـ Rive: على الويب بدون assets/ لتجنب 404 (assets/assets/...)
  String get _riveAssetPath => kIsWeb ? widget.riveAsset! : _assetKey;

  Future<void> _checkRiveAsset() async {
    if (widget.riveAsset == null) {
      if (mounted) setState(() { _riveChecked = true; _riveAvailable = false; });
      return;
    }
    try {
      await rootBundle.load(_assetKey);
      if (mounted) setState(() { _riveAvailable = true; _riveChecked = true; });
    } catch (_) {
      if (mounted) setState(() { _riveAvailable = false; _riveChecked = true; });
    }
  }

  @override
  void didUpdateWidget(covariant RiveNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.riveAsset != widget.riveAsset) _checkRiveAsset();
    if (oldWidget.isSelected != widget.isSelected) _updateActive();
  }

  void _onRiveInit(Artboard artboard) {
    try {
      final name = widget.stateMachineName ?? 'State Machine';
      _controller = StateMachineController.fromArtboard(artboard, name);
      if (_controller == null) return;
      artboard.addController(_controller!);
      _activeInput = _controller!.getBoolInput(widget.activeInputName ?? 'active');
      _updateActive();
    } catch (_) {
      // إذا لم يُعثر على State Machine أو الـ input نترك _activeInput = null
    }
  }

  void _updateActive() {
    _activeInput?.value = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected ? AppColors.navBarSelected : AppColors.navBarUnselected;

    Widget iconWidget;
    if (_riveChecked && _riveAvailable && widget.riveAsset != null) {
      iconWidget = SizedBox(
        width: 28,
        height: 28,
        child: RiveAnimation.asset(
          _riveAssetPath,
          artboard: widget.artboardName,
          onInit: _onRiveInit,
          fit: BoxFit.contain,
        ),
      );
      // تطبيق اللون عبر ColorFiltered لأن Rive يرسم بألوانه الداخلية
      iconWidget = ColorFiltered(
        colorFilter: ColorFilter.mode(
          color,
          BlendMode.srcIn,
        ),
        child: iconWidget,
      );
    } else {
      // أيقونة عادية مع حركة اختيار (scale + لمعان)
      iconWidget = AnimatedScale(
        scale: widget.isSelected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Icon(widget.fallbackIcon, size: 26, color: color),
      );
    }

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
