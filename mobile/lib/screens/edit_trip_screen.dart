import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/city.dart';
import 'package:flyem_app/models/country.dart';
import 'package:flyem_app/models/trip_item.dart';
import 'package:flyem_app/services/shipments_service.dart';
import 'package:flyem_app/services/trips_service.dart';
import 'package:flyem_app/widgets/city_picker_sheet.dart';

/// شاشة تعديل الرحلة - تعرض بيانات الرحلة كاملة وتسمح بتعديلها ثم حفظ.
class EditTripScreen extends StatefulWidget {
  const EditTripScreen({
    super.key,
    required this.tripId,
    this.onUpdated,
  });

  final int tripId;
  final VoidCallback? onUpdated;

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  TripDetails? _trip;
  bool _loading = true;
  String? _error;

  List<Country> _countries = [];
  List<City> _fromCities = [];
  List<City> _toCities = [];
  Country? _fromCountry;
  City? _fromCity;
  Country? _toCountry;
  City? _toCity;

  int _travelTypeIndex = 2;
  DateTime? _departureDate;
  DateTime? _returnDate;
  final _notesController = TextEditingController();

  bool _canPickupInCurrentCountry = false;
  bool _canDeliverInOtherCountry = false;
  bool _canReturnOnCancel = false;
  int _returnBeforeDays = 1;

  bool _saving = false;

  static const List<String> _travelMethods = ['car', 'train', 'flight'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tripFuture = TripsService.getTrip(widget.tripId);
      final countriesFuture = ShipmentsService.getCountries();
      final trip = await tripFuture;
      final countries = await countriesFuture;
      if (!mounted) return;

      List<City> fromCities = [];
      List<City> toCities = [];
      if (trip.fromCountryId != null) {
        fromCities = await ShipmentsService.getCities(trip.fromCountryId!);
      }
      if (trip.toCountryId != null) {
        toCities = await ShipmentsService.getCities(trip.toCountryId!);
      }
      if (!mounted) return;

      Country? fc;
      for (final c in countries) {
        if (c.id == trip.fromCountryId) {
          fc = c;
          break;
        }
      }
      Country? tc;
      for (final c in countries) {
        if (c.id == trip.toCountryId) {
          tc = c;
          break;
        }
      }
      City? fromCity;
      for (final c in fromCities) {
        if (c.id == trip.fromCityId) {
          fromCity = c;
          break;
        }
      }
      City? toCity;
      for (final c in toCities) {
        if (c.id == trip.toCityId) {
          toCity = c;
          break;
        }
      }

      final travelIndex = _travelMethods.indexOf(trip.travelMethod);
      final dep = trip.departureDate != null ? _parseDateTime(trip.departureDate!) : null;
      final ret = trip.returnDate != null ? _parseDateTime(trip.returnDate!) : null;

      _notesController.text = trip.notes ?? '';

      setState(() {
        _trip = trip;
        _countries = countries;
        _fromCities = fromCities;
        _toCities = toCities;
        _fromCountry = fc;
        _fromCity = fromCity;
        _toCountry = tc;
        _toCity = toCity;
        _travelTypeIndex = travelIndex >= 0 ? travelIndex : 2;
        _departureDate = dep;
        _returnDate = ret;
        _canPickupInCurrentCountry = trip.canPickupInCurrentCountry;
        _canDeliverInOtherCountry = trip.canDeliverInOtherCountry;
        _canReturnOnCancel = trip.canReturnOnCancel;
        _returnBeforeDays = trip.returnBeforeDays ?? 1;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  DateTime? _parseDateTime(String s) {
    if (s.isEmpty) return null;
    final parts = s.split(' ');
    if (parts.isEmpty) return null;
    final dateParts = parts[0].split('-');
    if (dateParts.length < 3) return null;
    final y = int.tryParse(dateParts[0]);
    final m = int.tryParse(dateParts[1]);
    final d = int.tryParse(dateParts[2]);
    if (y == null || m == null || d == null) return null;
    int h = 0, min = 0;
    if (parts.length >= 2) {
      final timeParts = parts[1].split(':');
      if (timeParts.length >= 2) {
        h = int.tryParse(timeParts[0]) ?? 0;
        min = int.tryParse(timeParts[1]) ?? 0;
      }
    }
    return DateTime(y, m, d, h, min);
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

  Future<void> _pickReturnDateTime() async {
    final initial = _returnDate ?? _departureDate ?? DateTime.now().add(const Duration(days: 2));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _departureDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_returnDate ?? date),
    );
    if (time == null || !mounted) return;
    setState(() {
      _returnDate = DateTime(
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

  String get _returnDisplay {
    if (_returnDate == null) return '';
    final d = _returnDate!;
    final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final timeStr = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$dateStr  $timeStr';
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

  Future<void> _onSave() async {
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
    setState(() => _saving = true);
    try {
      final departureStr = _departureDate!.toIso8601String();
      final returnStr = _returnDate?.toIso8601String();

      await TripsService.updateTrip(
        tripId: widget.tripId,
        travelMethod: _travelMethods[_travelTypeIndex],
        fromCountryId: _fromCountry!.id,
        fromCityId: _fromCity!.id,
        toCountryId: _toCountry!.id,
        toCityId: _toCity!.id,
        departureDate: departureStr,
        returnDate: returnStr?.isNotEmpty == true ? returnStr : null,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        canPickupInCurrentCountry: _canPickupInCurrentCountry,
        canDeliverInOtherCountry: _canDeliverInOtherCountry,
        canReturnOnCancel: _canReturnOnCancel,
        returnBeforeDays: _canReturnOnCancel ? _returnBeforeDays.clamp(1, 30) : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التعديلات')),
      );
      widget.onUpdated?.call();
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحفظ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.buttonDark,
            foregroundColor: Colors.white,
            title: const Text('تعديل الرحلة'),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_error != null || _trip == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.buttonDark,
            foregroundColor: Colors.white,
            title: const Text('تعديل الرحلة'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _error ?? 'لا يمكن تحميل الرحلة',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loadData,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.buttonDark,
          foregroundColor: Colors.white,
          title: const Text('تعديل الرحلة'),
        ),
        body: SingleChildScrollView(
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
              const SizedBox(height: 12),
              _buildReturnField(),
              const SizedBox(height: 24),
              _buildSectionTitle(AppStrings.travelTypeSection),
              const SizedBox(height: 12),
              _buildTravelTypeSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('خيارات الاستلام والتسليم'),
              const SizedBox(height: 12),
              _buildOptionCheckbox(
                value: _canPickupInCurrentCountry,
                label: 'استطيع الذهاب إلى استلام الشحنة في الدولة الحالية',
                onChanged: (v) => setState(() => _canPickupInCurrentCountry = v ?? false),
              ),
              const SizedBox(height: 10),
              _buildOptionCheckbox(
                value: _canDeliverInOtherCountry,
                label: 'الذهاب لتسليم الشحنة في الدولة الأخرى',
                onChanged: (v) => setState(() => _canDeliverInOtherCountry = v ?? false),
              ),
              const SizedBox(height: 10),
              _buildOptionCheckbox(
                value: _canReturnOnCancel,
                label: 'استطيع إرجاع الشحنة للراسل في حالة إلغاء الشحنة قبل يوم',
                onChanged: (v) => setState(() => _canReturnOnCancel = v ?? false),
              ),
              if (_canReturnOnCancel) ...[
                const SizedBox(height: 8),
                _buildReturnBeforeDaysField(),
              ],
              const SizedBox(height: 24),
              _buildSectionTitle(AppStrings.notes),
              const SizedBox(height: 12),
              _buildNotesField(),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'حفظ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
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
            Icon(Icons.calendar_today_outlined, size: 22, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnField() {
    return InkWell(
      onTap: _pickReturnDateTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _returnDisplay.isEmpty ? 'تاريخ العودة (اختياري)' : _returnDisplay,
                style: TextStyle(
                  fontSize: 15,
                  color: _returnDisplay.isEmpty ? Colors.grey[600] : Colors.black87,
                ),
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 22, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0E6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnBeforeDaysField() {
    return Padding(
      padding: const EdgeInsets.only(right: 12, left: 12),
      child: Row(
        children: [
          Text(
            'حتى تاريخ:',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () async {
                final initial = DateTime.now().add(Duration(days: _returnBeforeDays));
                final date = await showDatePicker(
                  context: context,
                  initialDate: initial,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null && mounted) {
                  final diff = date.difference(DateTime.now()).inDays;
                  setState(() => _returnBeforeDays = diff > 0 ? diff : 1);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'بعد $_returnBeforeDays يوم',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
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
