import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/models/trip_item.dart';
import 'package:flyem_app/screens/main_nav_screen.dart';
import 'package:flyem_app/services/payment_methods_service.dart';
import 'package:flyem_app/services/trips_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMethods();
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
        _error = 'فشل تحميل وسائل الدفع';
      });
    }
  }

  Future<void> _onPay() async {
    if (_selectedMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر وسيلة الدفع')));
      return;
    }
    setState(() {
      _paying = true;
      _error = null;
    });
    try {
      final result = await TripsService.sendRequest(
        tripId: widget.tripId,
        paymentMethodId: _selectedMethodId!,
      );
      if (!mounted) return;
      setState(() => _paying = false);
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
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    final amount = t.pricePerKg * (t.availableWeight > 0 ? t.availableWeight : 1);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.navBarBackground,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('شاشة الدفع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
                      Text('ملخص الرحلة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: Text(t.fromDisplay, style: const TextStyle(fontWeight: FontWeight.w600))),
                          Icon(Icons.flight, size: 20, color: AppColors.primaryYellow),
                          Expanded(child: Text(t.toDisplay, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.end)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${t.currencySymbol}${amount.toStringAsFixed(1)} — المبلغ التقريبي', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'وسيلة الدفع',
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
                        TextButton(onPressed: _loadMethods, child: const Text('إعادة المحاولة')),
                      ],
                    ),
                  )
                else
                  ..._methods.map((m) => _PaymentMethodTile(
                        name: m.nameAr,
                        isSelected: _selectedMethodId == m.id,
                        onTap: () => setState(() => _selectedMethodId = m.id),
                      )),
                if (_error != null && _methods.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
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
                        : const Text('إتمام الدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
