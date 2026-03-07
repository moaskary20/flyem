import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/place.dart';
import 'package:flyem_app/services/places_service.dart';

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
            _PlaceAutocomplete(
              hint: AppStrings.fromHint,
              icon: Icons.flight_takeoff,
              selected: widget.fromPlace,
              onSelected: widget.onFromPlaceSelected,
            ),
            const SizedBox(height: 12),
            _PlaceAutocomplete(
              hint: AppStrings.toHint,
              icon: Icons.flight_land,
              selected: widget.toPlace,
              onSelected: widget.onToPlaceSelected,
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
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            AppStrings.search,
            style: TextStyle(
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

class _PlaceAutocomplete extends StatefulWidget {
  const _PlaceAutocomplete({
    required this.hint,
    required this.icon,
    this.selected,
    this.onSelected,
  });

  final String hint;
  final IconData icon;
  final Place? selected;
  final ValueChanged<Place?>? onSelected;

  @override
  State<_PlaceAutocomplete> createState() => _PlaceAutocompleteState();
}

class _PlaceAutocompleteState extends State<_PlaceAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Place> _suggestions = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.selected != null) _controller.text = widget.selected!.display;
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant _PlaceAutocomplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _controller.text = widget.selected?.display ?? '';
    }
  }

  void _onTextChanged() {
    _debounce?.cancel();
    final q = _controller.text.trim();
    if (q.isEmpty) {
      setState(() {
        _suggestions = [];
        widget.onSelected?.call(null);
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _fetchPlaces(q));
  }

  Future<void> _fetchPlaces(String q) async {
    setState(() => _loading = true);
    try {
      final list = await PlacesService.getPlaces(q);
      if (mounted) setState(() {
        _suggestions = list;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _suggestions = [];
        _loading = false;
      });
    }
  }

  void _selectPlace(Place place) {
    _controller.text = place.display;
    _focusNode.unfocus();
    setState(() => _suggestions = []);
    widget.onSelected?.call(place);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
            prefixIcon: Icon(widget.icon, size: 20, color: Colors.black87),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          onTap: () {
            if (_controller.text.trim().isNotEmpty && _suggestions.isEmpty && !_loading) {
              _fetchPlaces(_controller.text.trim());
            }
          },
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (_, i) {
                  final p = _suggestions[i];
                  return ListTile(
                    dense: true,
                    title: Text(p.display, style: const TextStyle(fontSize: 14)),
                    onTap: () => _selectPlace(p),
                  );
                },
              ),
            ),
          ),
        ],
        if (_loading) const Padding(
          padding: EdgeInsets.only(top: 8),
          child: SizedBox(height: 24, child: Center(child: LinearProgressIndicator())),
        ),
      ],
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
