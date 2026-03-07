import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/services/auth_service.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/city.dart';
import 'package:flyem_app/models/country.dart';
import 'package:flyem_app/services/shipments_service.dart';
import 'package:flyem_app/widgets/city_picker_sheet.dart';

class AddShipmentScreen extends StatefulWidget {
  const AddShipmentScreen({super.key});

  @override
  State<AddShipmentScreen> createState() => _AddShipmentScreenState();
}

class _AddShipmentScreenState extends State<AddShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _rewardController = TextEditingController();

  List<Country> _countries = [];
  List<City> _fromCities = [];
  List<City> _toCities = [];
  bool _loadingCountries = true;
  bool _submitting = false;
  String? _loadError;

  Country? _fromCountry;
  City? _fromCity;
  Country? _toCountry;
  City? _toCity;
  DateTime? _deadlineDate;

  /// 0 = إضافة التفاصيل، 1 = مراجعة
  int _currentStep = 0;
  bool _insuranceChecked = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final list = await ShipmentsService.getCountries();
      if (mounted) {
        setState(() {
          _countries = list;
          _loadingCountries = false;
          _loadError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingCountries = false;
          _loadError = e.toString();
        });
      }
    }
  }

  Future<void> _loadFromCities(int countryId) async {
    final list = await ShipmentsService.getCities(countryId);
    if (mounted) {
      setState(() {
        _fromCities = list;
        _fromCity = null;
      });
    }
  }

  Future<void> _loadToCities(int countryId) async {
    final list = await ShipmentsService.getCities(countryId);
    if (mounted) {
      setState(() {
        _toCities = list;
        _toCity = null;
      });
    }
  }

  /// فتح شاشة اختيار المدينة من كل مدن البلد مع بحث
  Future<void> _showCityPicker({
    required List<City> cities,
    required String title,
    required void Function(City?) onSelected,
  }) async {
    await showCityPickerSheet(context, title: title, cities: cities, onSelected: onSelected);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadlineDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _deadlineDate = picked);
    }
  }

  void _onPublishTap() {
    bool? preferCompanyDelivery;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.shippingMethodDialogMessage,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setDialogState(() => preferCompanyDelivery = false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: preferCompanyDelivery == false
                                ? AppColors.primaryYellow.withValues(alpha: 0.2)
                                : null,
                          ),
                          child: const Text(AppStrings.no),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setDialogState(() => preferCompanyDelivery = true),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: preferCompanyDelivery == true
                                ? AppColors.primaryYellow.withValues(alpha: 0.2)
                                : null,
                          ),
                          child: const Text(AppStrings.yes),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _submit();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(AppStrings.done),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _goToReview() {
    if (!_formKey.currentState!.validate()) return;
    if (_fromCountry == null || _fromCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر مدينة وبلد المنشأ')),
      );
      return;
    }
    if (_toCountry == null || _toCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر مدينة وبلد الوجهة')),
      );
      return;
    }
    setState(() => _currentStep = 1);
  }

  Future<void> _submit() async {
    final userId = await AuthService.getUserId();
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
        );
      }
      return;
    }
    setState(() => _submitting = true);
    try {
      final rewardStr = _rewardController.text.trim();
      final priceMin = rewardStr.isEmpty
          ? null
          : double.tryParse(rewardStr.replaceFirst(',', '.'));
      await ShipmentsService.createShipment(
        userId: userId,
        title: _titleController.text.trim(),
        description: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        fromCountryId: _fromCountry!.id,
        fromCityId: _fromCity!.id,
        toCountryId: _toCountry!.id,
        toCityId: _toCity!.id,
        deadlineDate: _deadlineDate?.toIso8601String().substring(0, 10),
        priceMin: priceMin,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحفظ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
          title: const Text(AppStrings.addDetails),
        ),
        body: _loadingCountries
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_loadError!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _loadCountries,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildStepper(),
                        Expanded(
                          child: _currentStep == 0
                              ? SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        AppStrings.details,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildFromField(),
                                      const SizedBox(height: 12),
                                      _buildToField(),
                                      const SizedBox(height: 12),
                                      _buildDeadlineField(),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _rewardController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          labelText: AppStrings.travelerReward,
                                          hintText: '0',
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          prefixIcon: Icon(Icons.payments_outlined),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) return null;
                                          final n = double.tryParse(v.trim().replaceFirst(',', '.'));
                                          if (n != null && n < 0) return 'أدخل رقماً صحيحاً';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _titleController,
                                        decoration: const InputDecoration(
                                          labelText: AppStrings.shipmentName,
                                          border: OutlineInputBorder(),
                                          filled: true,
                                        ),
                                        validator: (v) =>
                                            v == null || v.trim().isEmpty ? 'أدخل اسم الشحنة' : null,
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _notesController,
                                        decoration: const InputDecoration(
                                          labelText: AppStrings.notes,
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          alignLabelWithHint: true,
                                        ),
                                        maxLines: 3,
                                      ),
                                    ],
                                  ),
                                )
                              : _buildReviewStep(),
                        ),
                        _buildBottomBar(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildStepper() {
    final isStep1 = _currentStep == 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isStep1 ? Colors.grey[300] : AppColors.primaryYellow,
            child: isStep1
                ? Icon(Icons.check, color: Colors.grey[600], size: 22)
                : const Text(
                    '1',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          Container(
            width: 32,
            height: 2,
            color: Colors.grey[300],
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: isStep1 ? AppColors.primaryYellow : Colors.grey[300],
            child: Text(
              '2',
              style: TextStyle(
                color: isStep1 ? Colors.black87 : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppStrings.addDetails,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isStep1 ? Colors.grey[600] : Colors.black87,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppStrings.review,
            style: TextStyle(
              color: isStep1 ? Colors.black87 : Colors.grey[600],
              fontSize: 14,
              fontWeight: isStep1 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    const totalOrders = 1;
    final travelerReward = double.tryParse(_rewardController.text.trim().replaceFirst(',', '.')) ?? 0.0;
    const companyFees = 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryYellow.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _reviewSummaryRow(AppStrings.totalOrdersLabel, '$totalOrders'),
                const SizedBox(height: 12),
                _reviewSummaryRow(
                  AppStrings.travelerRewardLabel,
                  '\$${travelerReward.toStringAsFixed(1)}',
                  valueColor: AppColors.primaryYellow,
                ),
                const SizedBox(height: 12),
                _reviewSummaryRow(
                  AppStrings.companyFeesLabel,
                  '\$${companyFees.toStringAsFixed(2)}',
                  valueColor: AppColors.primaryYellow,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => setState(() => _insuranceChecked = !_insuranceChecked),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0E6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _insuranceChecked ? Icons.check_box : Icons.check_box_outline_blank,
                    color: _insuranceChecked ? AppColors.primaryYellow : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppStrings.insuranceDisclaimer,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _insuranceChecked && !_submitting ? _onPublishTap : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black54,
                      ),
                    )
                  : const Text(AppStrings.publishShipment),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                AppStrings.haveQuestions,
                style: TextStyle(
                  color: Colors.blue[700],
                  decoration: TextDecoration.underline,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _reviewSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildFromField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(AppStrings.fromCityCountry),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.flight, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<Country>(
                value: _fromCountry,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text(AppStrings.cityCountryHint),
                items: _countries
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.displayName)))
                    .toList(),
                onChanged: (c) {
                  setState(() {
                    _fromCountry = c;
                    if (c != null) _loadFromCities(c.id);
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<City>(
                value: _fromCity,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('المدينة'),
                items: _fromCities
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.displayName)))
                    .toList(),
                onChanged: (c) => setState(() => _fromCity = c),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(AppStrings.toCityCountry),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.flight, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<Country>(
                value: _toCountry,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text(AppStrings.cityCountryHint),
                items: _countries
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.displayName)))
                    .toList(),
                onChanged: (c) {
                  setState(() {
                    _toCountry = c;
                    if (c != null) _loadToCities(c.id);
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: _toCountry == null
                    ? null
                    : () => _showCityPicker(
                          cities: _toCities,
                          title: 'اختر مدينة الوجهة',
                          onSelected: (c) => setState(() => _toCity = c),
                        ),
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text(
                    _toCity?.displayName ?? 'المدينة',
                    style: TextStyle(
                      color: _toCity != null ? Colors.black87 : Colors.grey[600],
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeadlineField() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: AppStrings.beforeDate,
          border: OutlineInputBorder(),
          filled: true,
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _deadlineDate != null
              ? '${_deadlineDate!.year}-${_deadlineDate!.month.toString().padLeft(2, '0')}-${_deadlineDate!.day.toString().padLeft(2, '0')}'
              : '',
          style: TextStyle(
            color: _deadlineDate != null ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_currentStep == 0) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        color: AppColors.primaryYellow,
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    AppStrings.cancel,
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: _goToReview,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: AppColors.primaryYellow,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('${AppStrings.next} <'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      color: AppColors.primaryYellow,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton(
              onPressed: _submitting ? null : () => setState(() => _currentStep = 0),
              child: Text(
                '${AppStrings.back} >',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

