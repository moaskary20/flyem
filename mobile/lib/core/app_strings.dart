/// نصوص التطبيق - العربية (الرئيسية)
class AppStrings {
  AppStrings._();

  // Navbar
  static const String navSearch = 'البحث';
  static const String navShipments = 'شحنات';
  static const String navTrips = 'رحلات';
  static const String navMessages = 'الرسائل';
  static const String tabNews = 'الاخبار';
  static const String tabMatches = 'تطابقات';
  static const String tabAgreements = 'اتفاقات';
  static const String tabConversations = 'المحادثات';
  static const String messagesEmptyState = 'ليس لدينا أي شيء هنا الآن.';
  static const String navMore = 'المزيد';

  // Search form
  static const String fromHint = 'من (المدينة، الدولة)';
  static const String toHint = 'إلى (المدينة، الدولة)';
  static const String allDates = 'كل التواريخ';
  static const String allWeights = 'كل الأوزان';
  static const String shipments = 'شحنات';
  static const String trips = 'رحلات';
  static const String search = 'بحث';

  // Results
  static const String shipmentsFound = 'شحنة موجودة';
  static const String shipmentsFoundCount = 'شحنة موجودة'; // سيتم استبدال العدد
  static String shipmentsFoundWithCount(int n) => '$n شحنة موجودة';
  static const String sendRequest = 'إرسال طلب';
  static const String sendingRequest = 'جاري إرسال الطلب...';
  static const String requestSentMatches =
      'تم إرسال الطلب. ستظهر في تطابقات حتى يقبل صاحب الشحنة.';
  static const String reward = 'المكافأة';
  static const String before = 'قبل';
  static const String deliveryBefore = 'الاستلام قبل';
  static const String kg = 'كجم';

  // Trip/Shipment details
  static const String expectedOn = 'متوقع في';
  static const String allowShippingCompanies = 'السماح للنقل عبر شركات الشحن';
  static const String postedBy = 'منشور بواسطة';
  static const String visitLink = 'زيارة الرابط';
  static const String weightOfSingleItem = 'وزن السلعة الواحدة';
  static const String productQuantity = 'كمية المنتج';
  static const String itemCategory = 'فئة السلعة';
  static const String travelerProfit = 'مكسب المسافر';
  static const String travelerReward = 'مكافأة المسافر (السعر)';
  /// تحت حقل مكافأة المسافر: جملة واحدة فيها الحد الأدنى (الرقم من لوحة التحكم) وزيادة فرصة إنجاز العملية.
  static String minRewardDisclaimer(double minValue) =>
      'مع العلم أن الحد الأدنى ($minValue) وزيادة التكلفة عنه تزيد من فرصة إنجاز العملية.';
  static const String minRewardDisclaimerNoMin =
      'مع العلم أن زيادة التكلفة تزيد من فرصة إنجاز العملية.';

  // Requests (تطابقات)
  static const String requestStatusPending = 'قيد الانتظار';
  static const String requestStatusAccepted = 'مقبول';
  static const String requestStatusRejected = 'مرفوض';
  static const String payNow = 'ادفع الآن';
  static const String accept = 'قبول';
  static const String reject = 'رفض';
  static const String noRequests = 'لا توجد طلبات';

  // Filter
  static const String filterTitle = 'فلتر';
  static const String applyFilter = 'تطبيق الفلتر';
  static const String clearFilter = 'مسح الفلتر';

  // My Shipments
  static const String sort = 'تصنيف';
  static const String noShipments = 'لا يوجد لديك أي شحنات';
  static const String addNow = 'أضف الآن';
  static const String addYourShipment = 'أضف شحنتك';

  // Trips (empty state)
  static const String tripsEmptyLine1 = 'ليس لديك أي رحلات أضف رحلة';
  static const String tripsEmptyLine2 = 'وابدأ في جني الأموال من السفر';
  static const String addYourTrip = 'أضف رحلتك';
  static const String notBookedYet = 'لم تحجز بعد؟';

  // Add trip - Passport upload bottom sheet
  static const String passportSheetLine1 = 'لتربح مزيدًا من المال يجب عليك أن تكسب';
  static const String passportSheetLine2 = 'ثقة الشاحنين';
  static const String passportSheetLine3 = 'من فضلك قم برفع صورة جواز السفر حتى';
  static const String passportSheetLine4 = 'تتمكن من استكمال الصفقة بنجاح.';
  static const String continueBtn = 'إستمرار';

  // Add Trip form
  static const String tripDetailsSection = 'تفاصيل الرحلة';
  static const String travelTypeSection = 'نوع السفر';
  static const String bookingInfoSection = 'معلومات الحجز';
  static const String availableWeightHint = 'الوزن المتاح';
  static const String departureHint = 'المغادرة (التاريخ والوقت)';
  static const String pricePerKgHint = 'السعر للكيلو (اختياري)';
  static const String priceHintOptional = 'السعر (اختياري)';
  static const String airlineHint = 'خط الطيران';
  static const String bookingRefHint = 'مرجع الحجز';
  static const String firstNameBookingHint = 'الاسم الأول (على بطاقة الحجز)';
  static const String lastNameBookingHint = 'الاسم الأخير (على بطاقة الحجز)';
  static const String categoriesDontWantToCarry = 'الفئات التي لا ترغب في حملها';
  static const String addNewTrip = 'إضافة رحلة جديدة';
  static const String departsOn = 'يغادر في';
  static const String profit = 'مكسب';
  static const String confirmedDeals = 'الصفقات المؤكدة';
  static const String minTripPriceLabel = 'الحد الأدنى للرحلات';
  // خيارات الاستلام والتسليم (داخل الرحلة)
  static const String pickupDeliveryOptionsTitle = 'خيارات الاستلام والتسليم';
  static const String canPickupInCurrentCountry = 'استلام الشحنة في الدولة الحالية';
  static const String canDeliverInOtherCountry = 'تسليم الشحنة في الدولة الأخرى';
  static const String canReturnOnCancel = 'إرجاع الشحنة عند الإلغاء قبل يوم';
  static String returnBeforeDaysLabel(int days) => 'إرجاع قبل $days يوم';

  // Add Shipment (step 1)
  static const String addDetails = 'إضافة التفاصيل';
  static const String review = 'مراجعة';
  static const String details = 'التفاصيل';
  static const String fromCityCountry = 'من (مدينة - بلد)';
  static const String toCityCountry = 'إلى (مدينة - بلد)';
  static const String cityCountryHint = 'مدينة - بلد';
  static const String beforeDate = 'قبل تاريخ';
  static const String shipmentName = 'اسم الشحنة';
  static const String notes = 'ملاحظات';
  static const String shoppingItems = 'سلع التسوق';
  static const String addNewShipment = 'أضف شحنة جديدة';
  static const String chooseFromWishlist = 'اختار من قائمة الرغبات';
  static const String next = 'التالي';
  static const String cancel = 'إلغاء';
  static const String confirmAndCreate = 'تأكيد وإنشاء';
  static const String edit = 'تعديل';

  // Add Shopping Item (شحنة تسوق)
  static const String addShoppingShipment = 'إضافة شحنة تسوق';
  static const String productDetails = 'تفاصيل المنتج';
  static const String productLinkHint = 'لينك المنتج';
  static const String productNameHint = 'اسم المنتج';
  static const String pricePerItem = 'سعر السلعة الواحدة';
  static const String weightPerItem = 'وزن السلعة الواحدة';
  static const String total = 'المجموع';
  static String totalWithCount(int n) => 'المجموع ($n)';
  static const String category = 'الفئة';
  static const String selectCategory = 'اختر الفئة';
  static const String shipmentPhotos = 'صور الشحنة';
  static const String done = 'تم';

  // My Shipment (after publish) - tabs
  static const String tabDeals = 'الصفقات';
  static const String tabSuitableTrips = 'الرحلات المناسبة';
  static const String tabDetails = 'التفاصيل';
  static const String editShipment = 'تعديل الشحنة';
  static const String deleteShipment = 'حذف الشحنة';
  static const String deleteTrip = 'حذف الرحلة';
  static const String reportShipment = 'ابلاغ عن الشحنة';
  static const String confirmDeleteShipment = 'هل تريد حذف هذه الشحنة؟';
  static const String confirmDeleteTrip = 'هل تريد حذف هذه الرحلة؟';
  static const String delete = 'حذف';
  static const String costInfoText =
      'تعتمد التكلفة على رسوم السوق، نحن أرخص بنسبة ٥٠٪–٧٠٪';
  static const String insuranceDisclaimer =
      'أقر بأن جميع تفاصيل هذه الشحنة صحيحة وأن أي تفاصيل غير صحيحة أو غير واضحة أو مفقودة قد تؤدي إلى أخطاء في عملية التسليم ولا نتحمل نتيجة ذلك.';
  static const String totalOrdersLabel = 'مجموع الطلبات';
  static const String totalWeightLabel = 'الوزن الكلي';
  static const String travelerRewardLabel = 'مكافأة المسافر';
  static const String companyFeesLabel = 'رسوم الشركة';
  static const String publishShipment = 'نشر الشحنة';
  static const String haveQuestions = 'هل عندك استفسارات؟';
  static const String back = 'رجوع';

  // Publish shipment dialog
  static const String shippingMethodDialogMessage =
      'قد يقوم المسافر بتسليم طلبك عن طريق شركات الشحن المحلي بدل المقابلة الشخصية '
      '(مع العلم أنه سيتم تطبيق رسوم إضافية للتوصيل طبقاً للشركة المختارة). هل تفضل هذه الطريقة؟';
  static const String yes = 'نعم';
  static const String no = 'لا';

  // More screen
  static const String personalPage = 'الصفحة الشخصية';
  static const String settings = 'الإعدادات';
  static const String notifications = 'التنبيهات';
  static const String shippingOrTripNotifications = 'تنبيهات الشحنات أو الرحالات المتاحة';
  static const String chatNotifications = 'إشعارات الدردشة';
  static const String appCurrency = 'عملة التطبيق';
  static const String appCurrencyHint = 'عرض الشحنات والرحلات بالعملة المختارة';
  static const String allCurrencies = 'كل العملات';
  static const String chooseLanguage = 'اختر اللغة';
  static const String language = 'اللغة';
  static const String languageArabic = 'اللغة العربية (Arabic)';
  static const String logout = 'تسجيل الخروج';
  static const String paymentDetails = 'تفاصيل الدفع';
  static const String paymentMethodHint = 'اختر طريقة الدفع المفضلة لديك كمسافر';
  static const String chooseMethod = 'اختر طريقة';
  static const String save = 'حفظ';
  static const String currentCode = 'الكود الحالي:';
  static const String code = 'الكود';
  static const String value = 'القيمة';
  static const String expiresOn = 'ينتهي في';
  static const String enterPromoCode = 'اكتب الرمز الترويجي';
  static const String wishlist = 'قائمة الأمنيات';
  static const String faq = 'الأسئلة الشائعة';
  static const String privacyAndTerms = 'الخصوصية وشروط الاستخدام';
  static const String technicalSupport = 'الدعم الفني';
  static const String supportSubjectLabel = 'النص';
  static const String supportDetailsHint = 'يرجى كتابة التفاصيل';
  static const String send = 'إرسال';
  static const String shareApp = 'شارك التطبيق مع أصدقائك';
  static const String aboutApp = 'حول التطبيق';

  // Personal profile screen
  static const String pendingVerification = 'في انتظار التوثيق';
  static const String pendingPhoneVerification = 'في انتظار التحقق من الهاتف';
  static const String documentsVerified = 'تم التحقق من الوثائق';
  static const String phoneVerified = 'تم التحقق من الهاتف';
  static const String dealsCount = 'الصفقات';
  static const String shipmentsCount = 'شحنة';
  static const String tripsCount = 'الرحلات';
  static const String basicInfo = 'المعلومات الأساسية';
  static const String emailLabel = 'البريد الإلكتروني';
  static const String phoneLabel = 'رقم الهاتف';
  static const String noPhoneEntered = 'No phone entered';
  static const String phoneNumbersLabel = 'أرقام الهواتف (مرتبطة بالحساب والملف الشخصي)';
  static const String phoneForHomeland = 'رقم الهاتف (الدولة الأم)';
  static const String phoneForTravel = 'رقم الهاتف (الدولة السفر)';
  static const String ratingsSection = 'تقييم';
  static const String myRatingLabel = 'تقييمي';
  static const String travelerRating = 'تقييم المسافر';
  static const String shipperRating = 'تقييم الشاحن';
  static const String noRatings = 'لا يوجد تقييمات';
  static const String rateUser = 'قيّم';
  static const String rateUserTitle = 'تقييم الطرف الآخر';
  static const String rateCommentHint = 'تعليق (اختياري)';
  static const String submitRating = 'إرسال التقييم';
  static const String ratingSent = 'تم إرسال التقييم';
}
