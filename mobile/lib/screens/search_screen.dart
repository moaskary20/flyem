import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/place.dart';
import 'package:flyem_app/screens/shipment_details_screen.dart';
import 'package:flyem_app/screens/trip_details_screen.dart';
import 'package:flyem_app/services/content_service.dart';
import 'package:flyem_app/services/shipments_service.dart';
import 'package:flyem_app/services/trips_service.dart';
import 'package:flyem_app/widgets/banner_slider.dart';
import 'package:flyem_app/widgets/search_form_section.dart';
import 'package:flyem_app/widgets/shipment_result_card.dart';
import 'package:flyem_app/widgets/trip_result_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<List<BannerItem>> _bannersFuture;

  SearchType _searchType = SearchType.shipments;
  Place? _fromPlace;
  Place? _toPlace;
  DateTime? _selectedDate;

  bool _loading = true;
  String? _error;
  ShipmentsListResponse? _shipmentsResult;
  TripsListResponse? _tripsResult;

  @override
  void initState() {
    super.initState();
    _bannersFuture = ContentService.getBanners();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final dateStr = _selectedDate != null
        ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
        : null;
    // عدم فلترة بعملة معينة لعرض كل الشحنات/الرحلات المتاحة
    const int? currencyId = null;

    if (_searchType == SearchType.shipments) {
      ShipmentsService.getShipments(
        perPage: 20,
        fromCountryId: _fromPlace?.countryId,
        toCountryId: _toPlace?.countryId,
        fromCityId: _fromPlace?.cityId,
        toCityId: _toPlace?.cityId,
        deadlineAfter: dateStr,
        currencyId: currencyId,
      ).then((res) {
        if (mounted) {
          setState(() {
            _shipmentsResult = res;
            _tripsResult = null;
            _loading = false;
          });
        }
      }).catchError((e) {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = e.toString();
          });
        }
      });
    } else {
      TripsService.getTripsForSearch(
        fromCountryId: _fromPlace?.countryId,
        toCountryId: _toPlace?.countryId,
        fromCityId: _fromPlace?.cityId,
        toCityId: _toPlace?.cityId,
        departureAfter: dateStr,
        currencyId: currencyId,
        perPage: 20,
      ).then((res) {
        if (mounted) {
          setState(() {
            _tripsResult = res;
            _shipmentsResult = null;
            _loading = false;
          });
        }
      }).catchError((e) {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = e.toString();
          });
        }
      });
    }
  }

  void _onSearchTypeChanged(SearchType type) {
    setState(() => _searchType = type);
    _load();
  }

  void _onSearchPressed() {
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.searchCardBg,
                child: FutureBuilder<List<BannerItem>>(
                  future: _bannersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BannerSlider(
                              banners: snapshot.data!,
                              height: 180,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child:               SearchFormSection(
                searchType: _searchType,
                onSearchTypeChanged: _onSearchTypeChanged,
                onSearchPressed: _onSearchPressed,
                fromPlace: _fromPlace,
                toPlace: _toPlace,
                selectedDate: _selectedDate,
                onFromPlaceSelected: (p) => setState(() => _fromPlace = p),
                onToPlaceSelected: (p) => setState(() => _toPlace = p),
                onDateSelected: (d) => setState(() => _selectedDate = d),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red[700], fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _load,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_searchType == SearchType.shipments && _shipmentsResult != null)
              _buildShipmentsResults(_shipmentsResult!)
            else if (_searchType == SearchType.trips && _tripsResult != null)
              _buildTripsResults(_tripsResult!)
            else
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShipmentsResults(ShipmentsListResponse res) {
    final list = res.data;
    final total = res.total;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              AppStrings.shipmentsFoundWithCount(total),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (list.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('لا توجد شحنات')),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = list[index];
                return ShipmentResultCard(
                  productName: item.title,
                  fromCode: item.fromCode,
                  toCode: item.toCode,
                  date: item.deadlineFormatted ?? '',
                  userName: item.user?.name ?? '',
                  rewardAmount: '${item.currencySymbol}${item.priceMin}',
                  rating: item.user?.rating ?? 0,
                  imageUrl: item.imageUrl,
                  userPhotoUrl: item.user?.profilePhoto,
                  shipmentId: item.id,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ShipmentDetailsScreen(shipmentId: item.id),
                      ),
                    );
                  },
                );
              },
              childCount: list.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildTripsResults(TripsListResponse res) {
    final list = res.data;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '${list.length} رحلة',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (list.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('لا توجد رحلات')),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = list[index];
                return TripResultCard(
                  item: item,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TripDetailsScreen(tripId: item.id),
                      ),
                    );
                  },
                );
              },
              childCount: list.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

}
