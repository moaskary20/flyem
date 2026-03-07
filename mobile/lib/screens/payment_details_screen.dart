import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/services/auth_service.dart';

/// شاشة تفاصيل الدفع: طريقة الدفع المتاحة هي السحاب البنكي فقط.
/// يعرض جدولاً (IBAN - اسم البنك - اسم العميل بالبنك) مع إمكانية الحفظ في الحساب.
class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({super.key});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  static const Color _headerDark = Color(0xFF2C2C2E);
  static const Color _contentBg = Color(0xFFF5F0E6);

  final _ibanController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await AuthService.getCurrentUser();
      if (mounted) {
        _ibanController.text = user?.bankIban ?? '';
        _bankNameController.text = user?.bankName ?? '';
        _accountHolderController.text = user?.bankAccountHolder ?? '';
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'فشل تحميل البيانات');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _ibanController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final user = await AuthService.getCurrentUser();
      await AuthService.updateProfile(
        homeCountryId: user?.homeCountryId,
        homeCityId: user?.homeCityId,
        travelCountryId: user?.travelCountryId,
        travelCityId: user?.travelCityId,
        bankIban: _ibanController.text.trim().isEmpty ? null : _ibanController.text.trim(),
        bankName: _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim(),
        bankAccountHolder: _accountHolderController.text.trim().isEmpty ? null : _accountHolderController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ')));
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('AuthException: ', ''));
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _contentBg,
        appBar: AppBar(
          backgroundColor: _headerDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            AppStrings.paymentDetails,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'طريقة الدفع المتاحة: السحاب البنكي. أدخل بيانات الحساب البنكي لحفظها في ملفك الشخصي.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildBankCard(),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ],
                      const Spacer(),
                      _buildSaveButton(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBankCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'السحاب البنكي',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ibanController,
            decoration: const InputDecoration(
              labelText: 'IBAN',
              border: OutlineInputBorder(),
              filled: true,
            ),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bankNameController,
            decoration: const InputDecoration(
              labelText: 'اسم البنك',
              border: OutlineInputBorder(),
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _accountHolderController,
            decoration: const InputDecoration(
              labelText: 'اسم العميل بالبنك',
              border: OutlineInputBorder(),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _saving ? null : _save,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryYellow,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _saving
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(AppStrings.save),
      ),
    );
  }
}
