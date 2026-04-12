import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/widgets/add_trip_passport_sheet.dart';

/// تطلب من المسافر إضافة رحلة قبل تصفح/طلب الشحنات.
class AddTripRequiredScreen extends StatelessWidget {
  const AddTripRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.navBarBackground,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            AppStrings.tripRequiredGateTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.flight_takeoff, size: 64, color: AppColors.primaryYellow),
                const SizedBox(height: 24),
                Text(
                  AppStrings.tripRequiredGateTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.tripRequiredGateBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    showAddTripPassportThenTripForm(
                      context,
                      useFullScreenForm: true,
                      onTripCreated: (added) {
                        if (context.mounted && added) {
                          Navigator.of(context).pop(true);
                        }
                      },
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
                  child: Text(
                    AppStrings.tripRequiredAddTripAction,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppStrings.tripRequiredLater),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
