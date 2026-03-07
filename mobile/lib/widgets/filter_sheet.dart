import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/place.dart';
import 'package:flyem_app/services/places_service.dart';

/// نتيجة فلتر للرحلات أو الشحنات
class TripsFilterResult {
  final Place? fromPlace;
  final Place? toPlace;
  final DateTime? departureAfter;
  const TripsFilterResult({this.fromPlace, this.toPlace, this.departureAfter});
  String? get departureAfterStr {
    if (departureAfter == null) return null;
    final d = departureAfter!;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class ShipmentsFilterResult {
  final Place? fromPlace;
  final Place? toPlace;
  final DateTime? deadlineAfter;
  const ShipmentsFilterResult({
    this.fromPlace,
    this.toPlace,
    this.deadlineAfter,
  });
  String? get deadlineAfterStr {
    if (deadlineAfter == null) return null;
    final d = deadlineAfter!;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

/// عرض ورقة فلتر الرحلات ثم استدعاء onApply بالنتيجة أو null عند المسح.
Future<void> showTripsFilterSheet(
  BuildContext context, {
  TripsFilterResult? initial,
  required void Function(TripsFilterResult?) onApply,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _TripsFilterSheet(
      initial: initial,
      onApply: onApply,
    ),
  );
}

/// عرض ورقة فلتر الشحنات ثم استدعاء onApply بالنتيجة أو null عند المسح.
Future<void> showShipmentsFilterSheet(
  BuildContext context, {
  ShipmentsFilterResult? initial,
  required void Function(ShipmentsFilterResult?) onApply,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ShipmentsFilterSheet(
      initial: initial,
      onApply: onApply,
    ),
  );
}

class _TripsFilterSheet extends StatefulWidget {
  const _TripsFilterSheet({this.initial, required this.onApply});

  final TripsFilterResult? initial;
  final void Function(TripsFilterResult?) onApply;

  @override
  State<_TripsFilterSheet> createState() => _TripsFilterSheetState();
}

class _TripsFilterSheetState extends State<_TripsFilterSheet> {
  Place? _from;
  Place? _to;
  DateTime? _departureAfter;

  @override
  void initState() {
    super.initState();
    _from = widget.initial?.fromPlace;
    _to = widget.initial?.toPlace;
    _departureAfter = widget.initial?.departureAfter;
  }

  void _apply() {
    widget.onApply(TripsFilterResult(
      fromPlace: _from,
      toPlace: _to,
      departureAfter: _departureAfter,
    ));
    Navigator.of(context).pop();
  }

  void _clear() {
    widget.onApply(null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${AppStrings.filterTitle} - ${AppStrings.trips}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _PlacePicker(
              hint: AppStrings.fromHint,
              icon: Icons.flight_takeoff,
              selected: _from,
              onSelected: (p) => setState(() => _from = p),
            ),
            const SizedBox(height: 12),
            _PlacePicker(
              hint: AppStrings.toHint,
              icon: Icons.flight_land,
              selected: _to,
              onSelected: (p) => setState(() => _to = p),
            ),
            const SizedBox(height: 12),
            _DateChip(
              label: _departureAfter != null
                  ? '${_departureAfter!.day}/${_departureAfter!.month}/${_departureAfter!.year}'
                  : AppStrings.allDates,
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _departureAfter ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (d != null && mounted) setState(() => _departureAfter = d);
              },
              onClear: () => setState(() => _departureAfter = null),
              showClear: _departureAfter != null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clear,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: Text(AppStrings.clearFilter),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _apply,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(AppStrings.applyFilter),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShipmentsFilterSheet extends StatefulWidget {
  const _ShipmentsFilterSheet({this.initial, required this.onApply});

  final ShipmentsFilterResult? initial;
  final void Function(ShipmentsFilterResult?) onApply;

  @override
  State<_ShipmentsFilterSheet> createState() => _ShipmentsFilterSheetState();
}

class _ShipmentsFilterSheetState extends State<_ShipmentsFilterSheet> {
  Place? _from;
  Place? _to;
  DateTime? _deadlineAfter;

  @override
  void initState() {
    super.initState();
    _from = widget.initial?.fromPlace;
    _to = widget.initial?.toPlace;
    _deadlineAfter = widget.initial?.deadlineAfter;
  }

  void _apply() {
    widget.onApply(ShipmentsFilterResult(
      fromPlace: _from,
      toPlace: _to,
      deadlineAfter: _deadlineAfter,
    ));
    Navigator.of(context).pop();
  }

  void _clear() {
    widget.onApply(null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${AppStrings.filterTitle} - ${AppStrings.shipments}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _PlacePicker(
              hint: AppStrings.fromHint,
              icon: Icons.flight_takeoff,
              selected: _from,
              onSelected: (p) => setState(() => _from = p),
            ),
            const SizedBox(height: 12),
            _PlacePicker(
              hint: AppStrings.toHint,
              icon: Icons.flight_land,
              selected: _to,
              onSelected: (p) => setState(() => _to = p),
            ),
            const SizedBox(height: 12),
            _DateChip(
              label: _deadlineAfter != null
                  ? '${_deadlineAfter!.day}/${_deadlineAfter!.month}/${_deadlineAfter!.year}'
                  : AppStrings.allDates,
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _deadlineAfter ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (d != null && mounted) setState(() => _deadlineAfter = d);
              },
              onClear: () => setState(() => _deadlineAfter = null),
              showClear: _deadlineAfter != null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clear,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: Text(AppStrings.clearFilter),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _apply,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(AppStrings.applyFilter),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlacePicker extends StatefulWidget {
  const _PlacePicker({
    required this.hint,
    required this.icon,
    this.selected,
    required this.onSelected,
  });

  final String hint;
  final IconData icon;
  final Place? selected;
  final ValueChanged<Place?> onSelected;

  @override
  State<_PlacePicker> createState() => _PlacePickerState();
}

class _PlacePickerState extends State<_PlacePicker> {
  final TextEditingController _controller = TextEditingController();
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
  void didUpdateWidget(covariant _PlacePicker oldWidget) {
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
        widget.onSelected(null);
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _fetch(q));
  }

  Future<void> _fetch(String q) async {
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

  void _select(Place p) {
    _controller.text = p.display;
    setState(() => _suggestions = []);
    widget.onSelected(p);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
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
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(widget.icon, size: 20, color: Colors.grey[700]),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          onTap: () {
            if (_controller.text.trim().isNotEmpty && _suggestions.isEmpty && !_loading) {
              _fetch(_controller.text.trim());
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
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (_, i) {
                  final p = _suggestions[i];
                  return ListTile(
                    dense: true,
                    title: Text(p.display, style: const TextStyle(fontSize: 14)),
                    onTap: () => _select(p),
                  );
                },
              ),
            ),
          ),
        ],
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: SizedBox(height: 20, child: Center(child: LinearProgressIndicator())),
          ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.onTap,
    required this.onClear,
    required this.showClear,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showClear)
                GestureDetector(
                  onTap: onClear,
                  child: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
