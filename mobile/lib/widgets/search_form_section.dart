import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/city.dart';
import 'package:flyem_app/models/country.dart';
import 'package:flyem_app/models/place.dart';
import 'package:flyem_app/services/shipments_service.dart';

enum SearchType { shipments, trips }

class SearchFormSection extends StatefulWidget {
  const SearchFormSection({
    super.key,
    required this.searchType,
    required this.onSearchTypeChanged,
    required this.onSearchPressed,
    this.fromPlace,
    this.toPlace,
    this.selectedDate,
    this.onFromPlaceSelected,
    this.onToPlaceSelected,
    this.onDateSelected,
  });

  final SearchType searchType;
  final ValueChanged<SearchType> onSearchTypeChanged;
  final VoidCallback onSearchPressed;
  final Place? fromPlace;
  final Place? toPlace;
  final DateTime? selectedDate;
  final ValueChanged<Place?>? onFromPlaceSelected;
  final ValueChanged<Place?>? onToPlaceSelected;
  final ValueChanged<DateTime?>? onDateSelected;

  @override
  State<SearchFormSection> createState() => _SearchFormSectionState();
}

class _SearchFormSectionState extends State<SearchFormSection> {
  List<Country> _countries = [];
  bool _loadingCountries = true;

  Country? _fromCountry;
  List<City> _fromCities = [];
  City? _fromCity;

  Country? _toCountry;
  List<City> _toCities = [];
  City? _toCity;

  bool _syncingFromParent = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  @override
  void didUpdateWidget(covariant SearchFormSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fromPlace != oldWidget.fromPlace || widget.toPlace != oldWidget.toPlace) {
      _applyPlacesFromParent();
    }
  }

  Future<void> _loadCountries() async {
    try {
      final list = await ShipmentsService.getCountries();
      if (!mounted) return;
      setState(() {
        _countries = list;
        _loadingCountries = false;
      });
      _applyPlacesFromParent();
    } catch (_) {
      if (mounted) setState(() => _loadingCountries = false);
    }
  }

  Future<void> _applyPlacesFromParent() async {
    if (_countries.isEmpty || _loadingCountries) return;
    final fp = widget.fromPlace;
    final tp = widget.toPlace;
    _syncingFromParent = true;
    try {
      if (fp == null) {
        if (mounted) {
          setState(() {
            _fromCountry = null;
            _fromCities = [];
            _fromCity = null;
          });
        }
      } else {
        Country? fc;
        try {
          fc = _countries.firstWhere((c) => c.id == fp.countryId);
        } catch (_) {
          fc = null;
        }
        if (fc != null) {
          final cities = await ShipmentsService.getCities(fc.id);
          if (!mounted) return;
          City? fcity;
          if (fp.cityId != null) {
            try {
              fcity = cities.firstWhere((c) => c.id == fp.cityId);
            } catch (_) {}
          }
          setState(() {
            _fromCountry = fc;
            _fromCities = cities;
            _fromCity = fcity;
          });
        }
      }
      if (tp == null) {
        if (mounted) {
          setState(() {
            _toCountry = null;
            _toCities = [];
            _toCity = null;
          });
        }
      } else {
        Country? tc;
        try {
          tc = _countries.firstWhere((c) => c.id == tp.countryId);
        } catch (_) {
          tc = null;
        }
        if (tc != null) {
          final cities = await ShipmentsService.getCities(tc.id);
          if (!mounted) return;
          City? tcity;
          if (tp.cityId != null) {
            try {
              tcity = cities.firstWhere((c) => c.id == tp.cityId);
            } catch (_) {}
          }
          setState(() {
            _toCountry = tc;
            _toCities = cities;
            _toCity = tcity;
          });
        }
      }
    } finally {
      _syncingFromParent = false;
    }
  }

  void _emitFromPlace() {
    if (_syncingFromParent) return;
    if (_fromCountry == null) {
      widget.onFromPlaceSelected?.call(null);
      return;
    }
    final display = _fromCity != null
        ? '${_fromCity!.displayName}، ${_fromCountry!.displayName}'
        : _fromCountry!.displayName;
    widget.onFromPlaceSelected?.call(Place(
      countryId: _fromCountry!.id,
      cityId: _fromCity?.id,
      display: display,
    ));
  }

  void _emitToPlace() {
    if (_syncingFromParent) return;
    if (_toCountry == null) {
      widget.onToPlaceSelected?.call(null);
      return;
    }
    final display = _toCity != null
        ? '${_toCity!.displayName}، ${_toCountry!.displayName}'
        : _toCountry!.displayName;
    widget.onToPlaceSelected?.call(Place(
      countryId: _toCountry!.id,
      cityId: _toCity?.id,
      display: display,
    ));
  }

  Future<void> _onFromCountryChanged(Country? c) async {
    setState(() {
      _fromCountry = c;
      _fromCities = [];
      _fromCity = null;
    });
    if (c != null) {
      final list = await ShipmentsService.getCities(c.id);
      if (mounted) setState(() => _fromCities = list);
    }
    _emitFromPlace();
  }

  Future<void> _onToCountryChanged(Country? c) async {
    setState(() {
      _toCountry = c;
      _toCities = [];
      _toCity = null;
    });
    if (c != null) {
      final list = await ShipmentsService.getCities(c.id);
      if (mounted) setState(() => _toCities = list);
    }
    _emitToPlace();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.searchCardBg,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.flight_takeoff, size: 20, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  AppStrings.fromCityCountry,
                  style: TextStyle(fontSize: 13, color: Colors.grey[800], fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loadingCountries)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              _buildCountryCityRow(
                country: _fromCountry,
                cities: _fromCities,
                city: _fromCity,
                onCountry: _onFromCountryChanged,
                onCity: (City? c) {
                  setState(() => _fromCity = c);
                  _emitFromPlace();
                },
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.flight_land, size: 20, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  AppStrings.toCityCountry,
                  style: TextStyle(fontSize: 13, color: Colors.grey[800], fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!_loadingCountries)
              _buildCountryCityRow(
                country: _toCountry,
                cities: _toCities,
                city: _toCity,
                onCountry: _onToCountryChanged,
                onCity: (City? c) {
                  setState(() => _toCity = c);
                  _emitToPlace();
                },
              ),
            const SizedBox(height: 12),
            _buildDateChip(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTypeSelector(),
                ),
                const SizedBox(width: 12),
                _buildSearchButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryCityRow({
    required Country? country,
    required List<City> cities,
    required City? city,
    required ValueChanged<Country?> onCountry,
    required ValueChanged<City?> onCity,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropdownButtonFormField<Country>(
            value: country,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: AppStrings.searchCountryLabel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            hint: Text(AppStrings.searchCountryHint),
            items: _countries
                .map((c) => DropdownMenuItem(value: c, child: Text(c.displayName, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: onCountry,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<City?>(
            value: city,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: AppStrings.searchCityLabel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            hint: Text(AppStrings.searchCityHint),
            items: [
              DropdownMenuItem<City?>(
                value: null,
                child: Text(AppStrings.allCitiesSearch, overflow: TextOverflow.ellipsis),
              ),
              ...cities.map(
                (c) => DropdownMenuItem(value: c, child: Text(c.displayName, overflow: TextOverflow.ellipsis)),
              ),
            ],
            onChanged: country == null ? null : onCity,
          ),
        ),
      ],
    );
  }

  Widget _buildDateChip() {
    final label = widget.selectedDate != null
        ? '${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year}'
        : AppStrings.allDates;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: widget.selectedDate ?? DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          );
          if (picked != null && mounted) {
            widget.onDateSelected?.call(picked);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.selectedDate != null)
                GestureDetector(
                  onTap: () => widget.onDateSelected?.call(null),
                  child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeSegment(
              label: AppStrings.shipments,
              isSelected: widget.searchType == SearchType.shipments,
              onTap: () => widget.onSearchTypeChanged(SearchType.shipments),
            ),
          ),
          Expanded(
            child: _TypeSegment(
              label: AppStrings.trips,
              isSelected: widget.searchType == SearchType.trips,
              onTap: () => widget.onSearchTypeChanged(SearchType.trips),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return Material(
      color: AppColors.buttonDark,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: widget.onSearchPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            AppStrings.search,
            style: const TextStyle(
              color: AppColors.primaryYellow,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeSegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeSegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.buttonDark : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
