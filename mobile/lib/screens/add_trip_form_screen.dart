import 'package:flutter/material.dart';
import 'package:flyem_app/core/api_config.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/city.dart';
import 'package:flyem_app/models/country.dart';
import 'package:flyem_app/services/auth_service.dart';
import 'package:flyem_app/services/shipments_service.dart';
import 'package:flyem_app/services/trips_service.dart';
import 'package:flyem_app/widgets/city_picker_sheet.dart';

/// شاشة نموذج "أضف رحلتك" - تُعرض من الأسفل (bottom sheet أو route)
class AddTripFormScreen extends StatefulWidget {
  const AddTripFormScreen({super.key, this.onTripAdded});

  /// يُستدعى عند الضغط على "تم" بعد إضافة الرحلة (للتحديث في شاشة الرحلات)
  final VoidCallback? onTripAdded;

  @override
  State<AddTripFormScreen> createState() => _AddTripFormScreenState();
}

class _AddTripFormScreenState extends State<AddTripFormScreen> {
  int _travelTypeIndex = 2; // 0 car, 1 train, 2 plane (محدد افتراضياً)
  bool _submitting = false;

  List<Country> _countries = [];
  List<City> _fromCities = [];
  List<City> _toCities = [];
  bool _loadingCountries = true;
  Country? _fromCountry;
  City? _fromCity;
  Country? _toCountry;
  City? _toCity;
  DateTime? _departureDate;
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  /// القيم المقبولة في الـ API: flight, car, train, bus, ship, other
  static const List<String> _travelMethods = ['car', 'train', 'flight'];

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    try {
      final list = await ShipmentsService.getCountries();
      if (mounted) {
        setState(() {
          _countries = list;
          _loadingCountries = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingCountries = false);
    }
  }

  Future<void> _loadFromCities(int countryId) async {
    final list = await ShipmentsService.getCities(countryId);
    if (mounted) setState(() {
      _fromCities = list;
      _fromCity = null;
    });
  }

  Future<void> _loadToCities(int countryId) async {
    final list = await ShipmentsService.getCities(countryId);
    if (mounted) setState(() {
      _toCities = list;
      _toCity = null;
    });
  }

  Future<void> _pickDepartureDateTime() async {
    final initial = _departureDate ?? DateTime.now().add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_departureDate ?? date),
    );
    if (time == null || !mounted) return;
    setState(() {
      _departureDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String get _departureDisplay {
    if (_departureDate == null) return '';
    final d = _departureDate!;
    final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final timeStr = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$dateStr  $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle(AppStrings.tripDetailsSection),
                    const SizedBox(height: 12),
                    _buildFromField(),
                    const SizedBox(height: 12),
                    _buildToField(),
                    const SizedBox(height: 12),
                    _buildDepartureField(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(AppStrings.travelTypeSection),
                    const SizedBox(height: 12),
                    _buildTravelTypeSelector(),
                    const SizedBox(height: 24),
                    // معلومات الحجز تظهر فقط عند اختيار الطائرة
                    if (_travelTypeIndex == 2) ...[
                      _buildSectionTitle(AppStrings.bookingInfoSection),
                      const SizedBox(height: 12),
                      _buildInput(
                        hint: AppStrings.airlineHint,
                        trailing: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryYellow, size: 28),
                      ),
                      const SizedBox(height: 12),
                      _buildInput(hint: AppStrings.bookingRefHint),
                      const SizedBox(height: 12),
                      _buildInput(hint: AppStrings.firstNameBookingHint),
                      const SizedBox(height: 12),
                      _buildInput(hint: AppStrings.lastNameBookingHint),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          AppStrings.notBookedYet,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.grey[800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionTitle(AppStrings.categoriesDontWantToCarry),
                    const SizedBox(height: 12),
                    _buildInput(hint: AppStrings.categoriesDontWantToCarry),
                    const SizedBox(height: 24),
                    _buildSectionTitle(AppStrings.notes),
                    const SizedBox(height: 12),
                    _buildNotesField(),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _onDone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                AppStrings.done,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _onDone() async {
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
    if (_departureDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر تاريخ ووقت المغادرة')),
      );
      return;
    }
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
      final priceStr = _priceController.text.trim();
      final pricePerKg = priceStr.isEmpty
          ? null
          : double.tryParse(priceStr.replaceFirst(',', '.'));
      final departureStr = _departureDate!.toIso8601String();
      await TripsService.createTrip(
        userId: userId,
        travelMethod: _travelMethods[_travelTypeIndex],
        fromCountryId: _fromCountry!.id,
        fromCityId: _fromCity!.id,
        toCountryId: _toCountry!.id,
        toCityId: _toCity!.id,
        departureDate: departureStr,
        pricePerKg: pricePerKg,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الرحلة')),
      );
      widget.onTripAdded?.call();
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إضافة الرحلة: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: AppColors.buttonDark,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 12,
        right: 12,
        bottom: 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Text(
            'أضف رحلتك',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.upload, color: Colors.white, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildFromField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.fromCityCountry,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.flight_takeoff, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<Country>(
                value: _fromCountry,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              child: InkWell(
                onTap: _fromCountry == null
                    ? null
                    : () => showCityPickerSheet(
                          context,
                          title: 'اختر مدينة المنشأ',
                          cities: _fromCities,
                          onSelected: (c) => setState(() => _fromCity = c),
                        ),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  child: Text(
                    _fromCity?.displayName ?? 'المدينة',
                    style: TextStyle(
                      color: _fromCity != null ? Colors.black87 : Colors.grey[600],
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

  Widget _buildToField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.toCityCountry,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.flight_land, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<Country>(
                value: _toCountry,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    : () => showCityPickerSheet(
                          context,
                          title: 'اختر مدينة الوجهة',
                          cities: _toCities,
                          onSelected: (c) => setState(() => _toCity = c),
                        ),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

  Widget _buildDepartureField() {
    return InkWell(
      onTap: _pickDepartureDateTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _departureDisplay.isEmpty ? AppStrings.departureHint : _departureDisplay,
                style: TextStyle(
                  fontSize: 15,
                  color: _departureDisplay.isEmpty ? Colors.grey[600] : Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.calendar_today_outlined, size: 22, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String hint,
    Widget? trailing,
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: trailing != null ? Padding(padding: const EdgeInsets.only(left: 12), child: trailing) : null,
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: AppStrings.notes,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  Widget _buildTravelTypeSelector() {
    return Row(
      children: [
        _travelTypeChip(0, Icons.directions_car_outlined),
        const SizedBox(width: 8),
        _travelTypeChip(1, Icons.train_outlined),
        const SizedBox(width: 8),
        _travelTypeChip(2, Icons.flight),
      ],
    );
  }

  Widget _travelTypeChip(int index, IconData icon) {
    final isSelected = _travelTypeIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _travelTypeIndex = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryYellow : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryYellow : Colors.grey.shade300,
              ),
            ),
            child: Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

void showAddTripFormFromBottom(
  BuildContext context, {
  VoidCallback? onTripAdded,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => AddTripFormScreen(onTripAdded: onTripAdded),
  );
}
