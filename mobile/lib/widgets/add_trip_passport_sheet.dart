import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:flyem_app/core/app_strings.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/auth_guard.dart';
import 'package:flyem_app/screens/add_trip_form_screen.dart';
import 'package:image_picker/image_picker.dart';

/// يعرض أولاً شيت صورة جواز السفر وتذكرة الطيران، ثم نموذج إضافة الرحلة.
void showAddTripPassportThenTripForm(
  BuildContext hostContext, {
  VoidCallback? onTripAdded,
  /// إن كان true يُفتح النموذج كصفحة كاملة (مناسب لشاشة «أضف رحلتك أولاً» وتفاصيل الشحنة).
  bool useFullScreenForm = false,
  /// يُستدعى عند إتمام إضافة الرحلة بنجاح (قيمة true)؛ اختياري عند الإلغاء.
  ValueChanged<bool>? onTripCreated,
}) {
  Future<void> run() async {
    final loggedIn = await ensureLoggedIn(hostContext);
    if (!loggedIn || !hostContext.mounted) return;
    if (!hostContext.mounted) return;
    showModalBottomSheet<void>(
      context: hostContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => AddTripPassportSheet(
        onContinue: () {
          Navigator.of(sheetCtx).pop();
          Future.microtask(() {
            if (!hostContext.mounted) return;
            if (useFullScreenForm) {
              Navigator.of(hostContext)
                  .push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (_) => AddTripFormScreen(onTripAdded: onTripAdded),
                    ),
                  )
                  .then((ok) {
                    if (!hostContext.mounted) return;
                    if (ok == true) {
                      onTripCreated?.call(true);
                    }
                  });
            } else {
              showAddTripFormFromBottom(
                hostContext,
                onTripAdded: () {
                  onTripAdded?.call();
                  onTripCreated?.call(true);
                },
              );
            }
          });
        },
      ),
    );
  }

  run();
}

/// شيت رفع صورة جواز السفر وتذكرة الطيران قبل إدخال بيانات الرحلة.
class AddTripPassportSheet extends StatefulWidget {
  const AddTripPassportSheet({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<AddTripPassportSheet> createState() => _AddTripPassportSheetState();
}

class _AddTripPassportSheetState extends State<AddTripPassportSheet> {
  Uint8List? _passportImageBytes;
  Uint8List? _flightTicketImageBytes;
  bool _isPickingPassport = false;
  bool _isPickingTicket = false;

  bool get _isPicking => _isPickingPassport || _isPickingTicket;

  Future<void> _pickImage(bool forPassport) async {
    if (_isPicking) return;

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('الكاميرا'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    if (forPassport) {
      setState(() => _isPickingPassport = true);
    } else {
      setState(() => _isPickingTicket = true);
    }
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        final bytes = await file.readAsBytes();
        setState(() {
          if (forPassport) {
            _passportImageBytes = bytes;
          } else {
            _flightTicketImageBytes = bytes;
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingPassport = false;
          _isPickingTicket = false;
        });
      }
    }
  }

  void _onContinue() {
    if (_passportImageBytes == null || _flightTicketImageBytes == null) return;
    widget.onContinue();
  }

  Widget _buildImageSlot({
    required String label,
    required Uint8List? imageBytes,
    required bool isLoading,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isPicking ? null : onTap,
      child: SizedBox(
        height: 100,
        child: imageBytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(imageBytes, fit: BoxFit.cover),
                  Positioned(
                    bottom: 6,
                    left: 0,
                    right: 0,
                    child: Text(
                      'اضغط لتغيير الصورة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    const SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(icon, size: 36, color: Colors.grey[500]),
                  if (!isLoading) ...[
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 28,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.passportSheetLine1,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            Text(
              AppStrings.passportSheetLine2,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.passportSheetLine3,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            Text(
              AppStrings.passportSheetLine4,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildImageSlot(
                    label: 'صورة جواز السفر',
                    imageBytes: _passportImageBytes,
                    isLoading: _isPickingPassport,
                    icon: Icons.badge_outlined,
                    onTap: () => _pickImage(true),
                  ),
                  Container(height: 1, color: Colors.grey.shade300),
                  _buildImageSlot(
                    label: 'تذكرة الطيران',
                    imageBytes: _flightTicketImageBytes,
                    isLoading: _isPickingTicket,
                    icon: Icons.confirmation_number_outlined,
                    onTap: () => _pickImage(false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_passportImageBytes != null && _flightTicketImageBytes != null) ? _onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppStrings.continueBtn,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppStrings.cancel,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
