import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/models/city.dart';

/// عرض ورقة اختيار المدينة من قائمة مع إمكانية البحث.
Future<void> showCityPickerSheet(
  BuildContext context, {
  required String title,
  required List<City> cities,
  required void Function(City?) onSelected,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _CityPickerSheet(
      title: title,
      cities: cities,
      onSelected: (c) {
        onSelected(c);
        Navigator.of(ctx).pop();
      },
    ),
  );
}

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet({
    required this.title,
    required this.cities,
    required this.onSelected,
  });

  final String title;
  final List<City> cities;
  final void Function(City?) onSelected;

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<City> get _filtered {
    if (_query.isEmpty) return widget.cities;
    final q = _query.toLowerCase();
    return widget.cities.where((c) {
      return c.nameAr.toLowerCase().contains(q) || c.nameEn.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث عن مدينة...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.cities.isEmpty
                  ? Center(
                      child: Text(
                        'اختر البلد أولاً لظهور المدن',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : _filtered.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد نتائج',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final city = _filtered[i];
                            return ListTile(
                              title: Text(city.displayName),
                              onTap: () => widget.onSelected(city),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
