import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';

/// شاشة تفاصيل الدفع: اختيار طريقة الدفع المفضلة وحفظ.
class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({super.key});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  String? _selectedMethod;

  static const Color _headerDark = Color(0xFF2C2C2E);
  static const Color _contentBg = Color(0xFFF5F0E6);

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.paymentMethodHint,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMethodDropdown(),
                const Spacer(),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMethod,
          isExpanded: true,
          hint: Text(
            AppStrings.chooseMethod,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          items: const [
            DropdownMenuItem(value: 'bank', child: Text('تحويل بنكي')),
            DropdownMenuItem(value: 'wallet', child: Text('محفظة إلكترونية')),
            DropdownMenuItem(value: 'cash', child: Text('نقداً عند الاستلام')),
          ],
          onChanged: (value) {
            setState(() => _selectedMethod = value);
          },
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم الحفظ')),
          );
        },
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryYellow,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(AppStrings.save),
      ),
    );
  }
}
