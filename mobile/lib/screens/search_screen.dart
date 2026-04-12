import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/models/place.dart';
import 'package:flyem_app/screens/add_trip_required_screen.dart';
import 'package:flyem_app/screens/shipment_details_screen.dart';
import 'package:flyem_app/screens/trip_details_screen.dart';
import 'package:flyem_app/services/content_service.dart';
import 'package:flyem_app/services/shipments_service.dart';
import 'package:flyem_app/services/trips_service.dart';
import 'package:flyem_app/widgets/banner_slider.dart';
import 'package:flyem_app/widgets/search_form_section.dart';
import 'package:flyem_app/widgets/shipment_result_card.dart';
import 'package:flyem_app/widgets/trip_result_card.dart';
import 'package:flyem_app/services/auth_service.dart';

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

  int? _currentUserId;

  /// مرة واحدة لكل جلسة: تنبيه المسافر بإضافة رحلة عند تصفح تبويب الشحنات.
  bool _shipmentsTripGateShownThisSession = false;

  @override
  void initState() {
    super.initState();
    _bannersFuture = ContentService.getBanners();
    AuthService.getUserId().then((id) {
      if (!mounted) {
        return;
      }
      setState(() => _currentUserId = id);
      if (_searchType == SearchType.shipments &&
          _shipmentsResult != null &&
          !_loading) {
        _maybeShowTripRequiredGate();
      }
    });
    _loadInitial();
  }

  /// تحميل الشحنات والرحلات معاً عند أول فتح حتى يظهر تبويب الرحلات ممتلئاً دون انتظار بحث.
  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final dateStr = _selectedDate != null
        ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
        : null;
    const int? currencyId = null;
    const int tripsPerPage = 100;

    try {
      final results = await Future.wait<Object>([
        ShipmentsService.getShipments(
          perPage: 20,
          fromCountryId: _fromPlace?.countryId,
          toCountryId: _toPlace?.countryId,
          fromCityId: _fromPlace?.cityId,
          toCityId: _toPlace?.cityId,
          deadlineAfter: dateStr,
          currencyId: currencyId,
        ),
        TripsService.getTripsForSearch(
          fromCountryId: _fromPlace?.countryId,
          toCountryId: _toPlace?.countryId,
          fromCityId: _fromPlace?.cityId,
          toCityId: _toPlace?.cityId,
          departureAfter: dateStr,
          currencyId: currencyId,
          perPage: tripsPerPage,
        ),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _shipmentsResult = results[0] as ShipmentsListResponse;
        _tripsResult = results[1] as TripsListResponse;
        _loading = false;
      });
      _maybeShowTripRequiredGate();
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
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
            _loading = false;
          });
          _maybeShowTripRequiredGate();
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
        perPage: 100,
      ).then((res) {
        if (mounted) {
          setState(() {
            _tripsResult = res;
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

  Future<void> _maybeShowTripRequiredGate() async {
    if (!mounted ||
        _searchType != SearchType.shipments ||
        _shipmentsTripGateShownThisSession ||
        _currentUserId == null) {
      return;
    }
    final hasTrip = await TripsService.currentUserHasAtLeastOneTrip();
    if (!mounted || hasTrip) {
      return;
    }
    _shipmentsTripGateShownThisSession = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          fullscreenDialog: true,
          builder: (_) => const AddTripRequiredScreen(),
        ),
      );
    });
  }

  Future<void> _openShipmentDetails(int shipmentId) async {
    if (_currentUserId != null) {
      final hasTrip = await TripsService.currentUserHasAtLeastOneTrip();
      if (!mounted) {
        return;
      }
      if (!hasTrip) {
        final added = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            fullscreenDialog: true,
            builder: (_) => const AddTripRequiredScreen(),
          ),
        );
        if (added != true || !mounted) {
          return;
        }
      }
    }
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ShipmentDetailsScreen(shipmentId: shipmentId),
      ),
    );
  }

  void _onSearchPressed() {
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
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
              child: SearchFormSection(
                searchType: _searchType,
                onSearchTypeChanged: _onSearchTypeChanged,
                onSearchPressed: _onSearchPressed,
                fromPlace: _fromPlace,
                toPlace: _toPlace,
                selectedDate: _selectedDate,
                onFromPlaceSelected: (p) {
                  setState(() => _fromPlace = p);
                  _load();
                },
                onToPlaceSelected: (p) {
                  setState(() => _toPlace = p);
                  _load();
                },
                onDateSelected: (d) {
                  setState(() => _selectedDate = d);
                  _load();
                },
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
                        child: Text(AppStrings.retry),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(AppStrings.noShipmentsInSearch)),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = list[index];
                final isOwn = _currentUserId != null &&
                    item.user?.id != null &&
                    item.user!.id == _currentUserId;
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
                  appListingNumber: item.id,
                  publisherUserId: item.user?.id,
                  isOwner: isOwn,
                  onTap: () => _openShipmentDetails(item.id),
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
              AppStrings.tripsFoundWithCount(list.length),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (list.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(AppStrings.noTripsInSearch)),
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
