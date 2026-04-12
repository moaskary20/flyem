import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_locale.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flyem_app/core/app_theme.dart';
import 'package:flyem_app/core/app_strings.dart';

/// شاشة إضافة شحنة تسوق (تفاصيل المنتج).
/// عند الضغط على "تم" تُرجع اسم المنتج إلى الشاشة السابقة.
class AddShoppingShipmentScreen extends StatefulWidget {
  const AddShoppingShipmentScreen({super.key});

  @override
  State<AddShoppingShipmentScreen> createState() => _AddShoppingShipmentScreenState();
}

class _AddShoppingShipmentScreenState extends State<AddShoppingShipmentScreen> {
  final _productLinkController = TextEditingController();
  final _productNameController = TextEditingController();
  final _unitPriceController = TextEditingController();
  int _quantity = 1;
  String? _selectedCategory;
  final List<String> _photoPaths = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _productLinkController.dispose();
    _productNameController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  double? get _unitPrice => double.tryParse(_unitPriceController.text.trim().replaceFirst(',', '.'));

  Future<void> _pickPhotoFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        setState(() => _photoPaths.add(photo.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التقاط الصورة: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() => _photoPaths.removeAt(index));
  }

  void _onDone() {
    final productName = _productNameController.text.trim();
    Navigator.of(context).pop(<String, dynamic>{
      'productName': productName.isEmpty ? null : productName,
      'photoPaths': List<String>.from(_photoPaths),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
          title: Text(
            AppStrings.addShoppingShipment,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.productDetails,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productLinkController,
                decoration: InputDecoration(
                  hintText: AppStrings.productLinkHint,
                  border: OutlineInputBorder(),
                  filled: true,
                  prefixIcon: Icon(Icons.link, color: AppColors.primaryYellow),
                  suffixIcon: Icon(Icons.content_paste_outlined, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  hintText: AppStrings.productNameHint,
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.productQuantity,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    AppStrings.totalWithCount(_quantity),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  _quantityButton(Icons.remove, () {
                    if (_quantity > 1) setState(() => _quantity--);
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _quantityButton(Icons.add, () => setState(() => _quantity++)),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitPriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: AppStrings.pricePerItem,
                  border: OutlineInputBorder(),
                  filled: true,
                  suffixIcon: Icon(Icons.attach_money, color: AppColors.primaryYellow),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  AppStrings.totalWithCount(
                    _unitPrice != null ? (_unitPrice! * _quantity).round() : 0,
                  ),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.category,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  hintText: AppStrings.selectCategory,
                  border: OutlineInputBorder(),
                  filled: true,
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                items: ['إلكترونيات', 'ملابس', 'أحذية', 'إكسسوارات', 'أخرى']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.shipmentPhotos,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _pickPhotoFromCamera,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryYellow, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.camera_alt, size: 40, color: AppColors.primaryYellow),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < _photoPaths.length; i++) ...[
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_photoPaths[i]),
                                  width: 88,
                                  height: 88,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -6,
                                left: -6,
                                child: GestureDetector(
                                  onTap: () => _removePhoto(i),
                                  child: const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _onDone,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppStrings.done),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: AppColors.primaryYellow,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: Colors.black87),
        ),
      ),
    );
  }
}
