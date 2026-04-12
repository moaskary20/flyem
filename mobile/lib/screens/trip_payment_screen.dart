import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/models/trip_item.dart';
import 'package:flyem_app/screens/main_nav_screen.dart';
import 'package:flyem_app/services/content_service.dart';
import 'package:flyem_app/services/payment_methods_service.dart';
import 'package:flyem_app/services/trips_service.dart';
import 'package:flyem_app/core/api_client.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/services/local_notification_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// شاشة الدفع لإرسال طلب على رحلة: اختيار وسيلة الدفع ثم إتمام الدفع.
/// بعد النجاح يتم التوجيه إلى شاشة الرسائل وفتح المحادثة مع صاحب الرحلة.
class TripPaymentScreen extends StatefulWidget {
  const TripPaymentScreen({super.key, required this.tripId, required this.trip});

  final int tripId;
  final TripDetails trip;

  @override
  State<TripPaymentScreen> createState() => _TripPaymentScreenState();
}

class _TripPaymentScreenState extends State<TripPaymentScreen> {
  List<PaymentMethodItem> _methods = [];
  bool _loading = true;
  bool _paying = false;
  String? _error;
  int? _selectedMethodId;

  /// الحد الأدنى لسعر الرحلة من لوحة التحكم — يُعرض ويُطبّق في الدفع.
  double? _minTripPrice;

  /// بعد إنشاء طلب PayPal من الخادم؛ يُمرَّر لـ [TripsService.sendRequest] عند الالتقاط.
  String? _paypalOrderId;

  @override
  void initState() {
    super.initState();
    _loadMethods();
    _loadMinTripPrice();
  }

  Future<void> _loadMinTripPrice() async {
    try {
      final settings = await ContentService.getSettings();
      final v = settings['min_trip_price'];
      if (v != null) {
        final s = v is String ? v : v.toString();
        final d = double.tryParse(s.trim());
        if (mounted && d != null && d >= 0) setState(() => _minTripPrice = d);
      }
    } catch (_) {}
  }

  Future<void> _loadMethods() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await PaymentMethodsService.getPaymentMethods();
      if (mounted) setState(() {
        _methods = list;
        _loading = false;
        if (list.isNotEmpty && _selectedMethodId == null) _selectedMethodId = list.first.id;
      });
    } catch (_) {
      if (mounted) setState(() {
        _loading = false;
        _error = AppStrings.loadFailedPaymentMethods;
      });
    }
  }

  PaymentMethodItem? _selectedMethod() {
    for (final m in _methods) {
      if (m.id == _selectedMethodId) return m;
    }
    return null;
  }

  Future<void> _onPay() async {
    if (_selectedMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.selectPaymentMethod)));
      return;
    }
    setState(() {
      _paying = true;
      _error = null;
    });
    try {
      final method = _selectedMethod();
      if (method != null && method.code == 'paypal') {
        if (_paypalOrderId == null || _paypalOrderId!.isEmpty) {
          final order = await TripsService.createPayPalOrderForTrip(widget.tripId);
          if (!mounted) return;
          setState(() {
            _paypalOrderId = order.orderId;
            _paying = false;
          });
          final uri = Uri.parse(order.approveUrl);
          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (mounted) {
            if (!launched) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.cannotOpenBrowserTryCopy)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.paypalCompleteSnack),
                ),
              );
            }
          }
          return;
        }
      }

      final result = await TripsService.sendRequest(
        tripId: widget.tripId,
        paymentMethodId: _selectedMethodId!,
        paypalOrderId: _paypalOrderId,
      );
      if (!mounted) return;
      setState(() => _paying = false);
      await LocalNotificationService.showNotification(
        id: LocalNotificationService.uniqueNotificationId(),
        title: AppStrings.notificationRequestSent,
        body: AppStrings.notificationRequestSent,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainNavScreen(
            initialIndex: 3,
            openConversationId: result.conversationId,
            openConversationName: result.otherUserName,
          ),
        ),
        (_) => false,
      );
    } catch (e) {
      if (mounted) setState(() {
        _paying = false;
        _error = e is DuplicateRequestException
            ? e.message
            : e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    final amount = (_minTripPrice != null && _minTripPrice! > 0)
        ? _minTripPrice!
        : (t.pricePerKg > 0 ? t.pricePerKg : 1.0);
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.navBarBackground,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(AppStrings.paymentScreenTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(AppStrings.tripSummary, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      const SizedBox(height: 12),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.routeLabelFrom,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                                  ),
                                  Text(t.fromDisplay, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
                              child: Icon(Icons.arrow_forward, size: 22, color: AppColors.primaryYellow),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    AppStrings.routeLabelTo,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                                  ),
                                  Text(
                                    t.toDisplay,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.end,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.paymentApproximateAmount(t.currencySymbol, amount.toStringAsFixed(1)),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.paymentMethod,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                ),
                const SizedBox(height: 12),
                if (_loading)
                  const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
                else if (_error != null && _methods.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        TextButton(onPressed: _loadMethods, child: Text(AppStrings.retry)),
                      ],
                    ),
                  )
                else
                  ..._methods.map((m) => _PaymentMethodTile(
                        name: m.nameAr,
                        isSelected: _selectedMethodId == m.id,
                        onTap: () => setState(() {
                          _selectedMethodId = m.id;
                          if (m.code != 'paypal') _paypalOrderId = null;
                        }),
                      )),
                if (_error != null && _methods.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
                if (_selectedMethod()?.code == 'paypal') ...[
                  const SizedBox(height: 12),
                  Text(
                    _paypalOrderId == null || _paypalOrderId!.isEmpty
                        ? AppStrings.paypalOpenHint
                        : AppStrings.paypalCompleteHintTrip,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.35),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (_loading || _paying || _selectedMethodId == null) ? null : _onPay,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _paying
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _selectedMethod()?.code == 'paypal' &&
                                    (_paypalOrderId == null || _paypalOrderId!.isEmpty)
                                ? AppStrings.continueToPayPal
                                : AppStrings.completePayment,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({required this.name, required this.isSelected, required this.onTap});

  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryYellow : AppColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? AppColors.primaryYellow : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
