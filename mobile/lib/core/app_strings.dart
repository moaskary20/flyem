/// نصوص التطبيق — العربية والإنجليزية حسب [setLanguageCode].
class AppStrings {
  AppStrings._();

  static String _code = 'ar';

  static void setLanguageCode(String c) {
    _code = c == 'en' ? 'en' : 'ar';
  }

  static bool get isArabic => _code == 'ar';
  static bool get isEnglish => _code == 'en';

  static bool get _en => _code == 'en';

  // Navbar
  static String get navSearch => _en ? 'Search' : 'البحث';
  static String get navShipments => _en ? 'Shipments' : 'شحنات';
  static String get navShipmentsTab => _en ? 'My shipments' : 'شحناتي';
  static String get navTrips => _en ? 'Trips' : 'رحلات';
  static String get navMessages => _en ? 'Messages' : 'الرسائل';
  static String get navRequests => _en ? 'Requests' : 'الطلبات';
  static String get tabNews => _en ? 'News' : 'الاخبار';
  static String get tabMatches => _en ? 'Matches' : 'تطابقات';
  static String get tabAgreements => _en ? 'Agreements' : 'اتفاقات';
  static String get tabConversations => _en ? 'Conversations' : 'المحادثات';
  static String get messagesEmptyState =>
      _en ? 'Nothing here yet.' : 'ليس لدينا أي شيء هنا الآن.';
  static String get navMore => _en ? 'More' : 'المزيد';

  // Search form
  static String get fromHint => _en ? 'From (city, country)' : 'من (المدينة، الدولة)';
  static String get toHint => _en ? 'To (city, country)' : 'إلى (المدينة، الدولة)';
  static String get searchCountryLabel => _en ? 'Country' : 'الدولة';
  static String get searchCountryHint => _en ? 'Select country' : 'اختر الدولة';
  static String get searchCityLabel => _en ? 'City' : 'المدينة';
  static String get searchCityHint => _en ? 'Select city' : 'اختر المدينة';
  static String get cityPlaceholder => _en ? 'City' : 'المدينة';
  static String get allCitiesSearch => _en ? 'All cities' : 'كل المدن';
  static String get allDates => _en ? 'All dates' : 'كل التواريخ';
  static String get allWeights => _en ? 'All weights' : 'كل الأوزان';
  static String get shipments => _en ? 'Shipments' : 'شحنات';
  static String get trips => _en ? 'Trips' : 'رحلات';
  static String get search => _en ? 'Search' : 'بحث';

  // Results
  static String get shipmentsFound => _en ? 'Shipment available' : 'شحنة موجودة';
  static String get shipmentsFoundCount => _en ? 'Shipment available' : 'شحنة موجودة';
  static String shipmentsFoundWithCount(int n) =>
      _en ? '$n shipments found' : '$n شحنة موجودة';
  static String tripsFoundWithCount(int n) => _en ? '$n trips' : '$n رحلة';
  static String get sendRequest => _en ? 'Send request' : 'إرسال طلب';
  static String get cannotRequestOwnListing =>
      _en ? 'You cannot send a request on your own listing' : 'لا يمكن إرسال طلب على إعلانك الخاص';
  static String get sendingRequest => _en ? 'Sending request…' : 'جاري إرسال الطلب...';
  static String get requestSentMatches => _en
      ? 'Request sent. Open Requests → Outgoing; it stays pending until the shipper accepts.'
      : 'تم إرسال الطلب. تجده في الطلبات ← تبويب «صادر» حتى يقبل صاحب الشحنة.';
  static String get viewRequestsOutgoing => _en ? 'Open outgoing' : 'فتح صادر';
  static String get tripRequiredGateTitle =>
      _en ? 'Add your trip first' : 'أضف رحلتك أولاً';
  static String get tripRequiredGateBody => _en
      ? 'To request a shipment you need at least one trip listing. Add your trip details so shippers can match with you.'
      : 'لإرسال طلب على شحنة يجب أن يكون لديك رحلة مسجّلة على الأقل. أدخل بيانات رحلتك ليتمكن الشاحنون من التوافق معك.';
  static String get tripRequiredAddTripAction =>
      _en ? 'Add trip' : 'إدخال بيانات الرحلة';
  static String get tripRequiredLater => _en ? 'Not now' : 'ليس الآن';
  static String get tripRequiredToRequestShipment => _en
      ? 'Add a trip listing before you can send a request on this shipment.'
      : 'أضف رحلة من قائمة رحلاتي قبل إرسال طلب على هذه الشحنة.';
  static String get reward => _en ? 'Reward' : 'المكافأة';
  static String get before => _en ? 'Before' : 'قبل';
  static String get deliveryBefore => _en ? 'Pickup before' : 'الاستلام قبل';
  static String get kg => _en ? 'kg' : 'كجم';

  // Trip/Shipment details
  /// اتجاه المسار دائماً من اليسار إلى اليمين مع سهم (وضوح: من → إلى).
  static String get routeLabelFrom => _en ? 'From' : 'من';
  static String get routeLabelTo => _en ? 'To' : 'إلى';
  static String get expectedOn => _en ? 'Expected on' : 'متوقع في';
  static String get allowShippingCompanies =>
      _en ? 'Allow delivery via shipping companies' : 'السماح للنقل عبر شركات الشحن';
  static String get postedBy => _en ? 'Posted by' : 'منشور بواسطة';
  static String get visitLink => _en ? 'Visit link' : 'زيارة الرابط';
  static String get weightOfSingleItem =>
      _en ? 'Weight per item' : 'وزن السلعة الواحدة';
  static String get productQuantity => _en ? 'Product quantity' : 'كمية المنتج';
  static String get itemCategory => _en ? 'Item category' : 'فئة السلعة';
  static String get travelerProfit => _en ? 'Traveler earnings' : 'مكسب المسافر';
  static String get travelerReward => _en ? 'Traveler reward (price)' : 'مكافأة المسافر (السعر)';
  static String minRewardDisclaimer(double minValue) => _en
      ? 'Note: the minimum is ($minValue). Offering more improves the chance of completion.'
      : 'مع العلم أن الحد الأدنى ($minValue) وزيادة التكلفة عنه تزيد من فرصة إنجاز العملية.';
  static String get minRewardDisclaimerNoMin => _en
      ? 'Note: a higher reward improves the chance of completion.'
      : 'مع العلم أن زيادة التكلفة تزيد من فرصة إنجاز العملية.';

  // Requests (matches)
  static String get requestStatusPending => _en ? 'Pending' : 'قيد الانتظار';
  static String get requestStatusAccepted => _en ? 'Accepted' : 'مقبول';
  static String get requestStatusRejected => _en ? 'Rejected' : 'مرفوض';
  static String get payNow => _en ? 'Pay now' : 'ادفع الآن';
  static String get accept => _en ? 'Accept' : 'قبول';
  static String get reject => _en ? 'Reject' : 'رفض';
  static String get noRequests => _en ? 'No requests' : 'لا توجد طلبات';
  static String get tabIncomingRequests => _en ? 'Incoming' : 'وارد';
  static String get tabOutgoingRequests => _en ? 'Outgoing' : 'صادر';
  static String get tabPendingPayment => _en ? 'Pending pay' : 'قيد الدفع';
  static String get tabPaidRequests => _en ? 'Paid' : 'مدفوع';
  static String get listingTypeShipment => _en ? 'Shipment' : 'شحنة';
  static String get listingTypeTrip => _en ? 'Trip' : 'رحلة';
  static String get requestPartyRequester => _en ? 'Requester' : 'مرسل الطلب';
  static String get requestPartyTraveler => _en ? 'Traveler' : 'المسافر';
  static String get requestPartySender => _en ? 'Sender' : 'الراسل';
  static String get requestPartyListingOwner => _en ? 'Listing owner' : 'صاحب الإعلان';
  static String get menuDeleteRequest => _en ? 'Delete request' : 'حذف الطلب';
  static String get menuCancelRequest => _en ? 'Cancel request' : 'إلغاء الطلب';
  static String get confirmDeleteRequestTitle => _en ? 'Delete this request?' : 'حذف هذا الطلب؟';
  static String get confirmCancelRequestTitle => _en ? 'Cancel this request?' : 'إلغاء هذا الطلب؟';
  static String get openChat => _en ? 'Chat' : 'تواصل';
  static String get counterpartyDetails => _en ? 'Contact details' : 'بيانات الطرف الآخر';
  static String get openWhatsapp => _en ? 'WhatsApp' : 'واتساب';
  static String get noPhoneForWhatsapp => _en ? 'No phone number' : 'لا يوجد رقم';
  static String get custodyConfirmPrompt =>
      _en ? 'Confirm you received the shipment into your custody?' : 'هل استلمت الشحنة وأصبحت في عهدتك؟';
  static String get deliveryConfirmPrompt =>
      _en ? 'Confirm the shipment was delivered successfully?' : 'هل تم توصيل الشحنة بنجاح؟';
  static String get confirmYes => _en ? 'Yes, confirm' : 'نعم، تأكيد';

  // Filter
  static String get filterTitle => _en ? 'Filter' : 'فلتر';
  static String get applyFilter => _en ? 'Apply filter' : 'تطبيق الفلتر';
  static String get clearFilter => _en ? 'Clear filter' : 'مسح الفلتر';

  // My Shipments
  static String get sort => _en ? 'Sort' : 'تصنيف';
  static String get noShipments => _en ? 'You have no shipments' : 'لا يوجد لديك أي شحنات';
  static String get addNow => _en ? 'Add now' : 'أضف الآن';
  static String get addYourShipment => _en ? 'Add your shipment' : 'أضف شحنتك';

  // Trips (empty state)
  static String get tripsEmptyLine1 =>
      _en ? 'You have no trips — add a trip' : 'ليس لديك أي رحلات أضف رحلة';
  static String get tripsEmptyLine2 => _en
      ? 'and start earning from travel'
      : 'وابدأ في جني الأموال من السفر';
  static String get addYourTrip => _en ? 'Add your trip' : 'أضف رحلتك';
  static String get notBookedYet => _en ? 'Not booked yet?' : 'لم تحجز بعد؟';

  // Passport sheet
  static String get passportSheetLine1 =>
      _en ? 'To earn more you need to earn' : 'لتربح مزيدًا من المال يجب عليك أن تكسب';
  static String get passportSheetLine2 => _en ? 'shippers’ trust' : 'ثقة الشاحنين';
  static String get passportSheetLine3 => _en
      ? 'Please upload a passport photo so you can'
      : 'من فضلك قم برفع صورة جواز السفر حتى';
  static String get passportSheetLine4 =>
      _en ? 'complete deals successfully.' : 'تتمكن من استكمال الصفقة بنجاح.';
  static String get continueBtn => _en ? 'Continue' : 'إستمرار';

  // Add Trip form
  static String get tripDetailsSection => _en ? 'Trip details' : 'تفاصيل الرحلة';
  static String get travelTypeSection => _en ? 'Travel type' : 'نوع السفر';
  static String get bookingInfoSection => _en ? 'Booking info' : 'معلومات الحجز';
  static String get availableWeightHint => _en ? 'Available weight' : 'الوزن المتاح';
  static String get departureHint =>
      _en ? 'Departure (date & time)' : 'المغادرة (التاريخ والوقت)';
  static String get pricePerKgHint =>
      _en ? 'Price per kg (optional)' : 'السعر للكيلو (اختياري)';
  static String get priceHintOptional => _en ? 'Price (optional)' : 'السعر (اختياري)';
  static String get airlineHint => _en ? 'Airline' : 'خط الطيران';
  static String get bookingRefHint => _en ? 'Booking reference' : 'مرجع الحجز';
  static String get firstNameBookingHint =>
      _en ? 'First name (on booking)' : 'الاسم الأول (على بطاقة الحجز)';
  static String get lastNameBookingHint =>
      _en ? 'Last name (on booking)' : 'الاسم الأخير (على بطاقة الحجز)';
  static String get categoriesDontWantToCarry =>
      _en ? 'Categories you prefer not to carry' : 'الفئات التي لا ترغب في حملها';
  static String get addNewTrip => _en ? 'Add new trip' : 'إضافة رحلة جديدة';
  static String get departsOn => _en ? 'Departs on' : 'يغادر في';
  static String get profit => _en ? 'Profit' : 'مكسب';
  static String get confirmedDeals => _en ? 'Confirmed deals' : 'الصفقات المؤكدة';
  static String get minTripPriceLabel => _en ? 'Minimum trip price' : 'الحد الأدنى للرحلات';
  static String get pickupDeliveryOptionsTitle =>
      _en ? 'Pickup & delivery options' : 'خيارات الاستلام والتسليم';
  static String get canPickupInCurrentCountry =>
      _en ? 'Pick up shipment in current country' : 'استلام الشحنة في الدولة الحالية';
  static String get canDeliverInOtherCountry =>
      _en ? 'Deliver shipment in the other country' : 'تسليم الشحنة في الدولة الأخرى';
  static String get canReturnOnCancel =>
      _en ? 'Return shipment if cancelled before one day' : 'إرجاع الشحنة عند الإلغاء قبل يوم';
  static String returnBeforeDaysLabel(int days) =>
      _en ? 'Return before $days days' : 'إرجاع قبل $days يوم';

  // Add Shipment
  static String get addDetails => _en ? 'Add details' : 'إضافة التفاصيل';
  static String get review => _en ? 'Review' : 'مراجعة';
  static String get details => _en ? 'Details' : 'التفاصيل';
  static String get fromCityCountry => _en ? 'From (city – country)' : 'من (مدينة - بلد)';
  static String get toCityCountry => _en ? 'To (city – country)' : 'إلى (مدينة - بلد)';
  static String get cityCountryHint => _en ? 'City – country' : 'مدينة - بلد';
  static String get beforeDate => _en ? 'Before date' : 'قبل تاريخ';
  static String get shipmentName => _en ? 'Shipment name' : 'اسم الشحنة';
  static String get notes => _en ? 'Notes' : 'ملاحظات';
  static String get shoppingItems => _en ? 'Shopping items' : 'سلع التسوق';
  static String get addNewShipment => _en ? 'Add new shipment' : 'أضف شحنة جديدة';
  static String get chooseFromWishlist =>
      _en ? 'Choose from wishlist' : 'اختار من قائمة الرغبات';
  static String get next => _en ? 'Next' : 'التالي';
  static String get cancel => _en ? 'Cancel' : 'إلغاء';
  static String get confirmAndCreate => _en ? 'Confirm & create' : 'تأكيد وإنشاء';
  static String get edit => _en ? 'Edit' : 'تعديل';
  static String get editProfileScreenTitle => _en ? 'Edit profile' : 'تعديل الملف الشخصي';

  // Shopping shipment
  static String get addShoppingShipment => _en ? 'Add shopping shipment' : 'إضافة شحنة تسوق';
  static String get productDetails => _en ? 'Product details' : 'تفاصيل المنتج';
  static String get productLinkHint => _en ? 'Product link' : 'لينك المنتج';
  static String get productNameHint => _en ? 'Product name' : 'اسم المنتج';
  static String get pricePerItem => _en ? 'Price per item' : 'سعر السلعة الواحدة';
  static String get weightPerItem => _en ? 'Weight per item' : 'وزن السلعة الواحدة';
  static String get total => _en ? 'Total' : 'المجموع';
  static String totalWithCount(int n) => _en ? 'Total ($n)' : 'المجموع ($n)';
  static String get category => _en ? 'Category' : 'الفئة';
  static String get selectCategory => _en ? 'Select category' : 'اختر الفئة';
  static String get shipmentPhotos => _en ? 'Shipment photos' : 'صور الشحنة';
  static String get done => _en ? 'Done' : 'تم';

  // My Shipment tabs
  static String get tabDeals => _en ? 'Deals' : 'الصفقات';
  static String get tabSuitableTrips => _en ? 'Suitable trips' : 'الرحلات المناسبة';
  static String get tabDetails => _en ? 'Details' : 'التفاصيل';
  static String get editShipment => _en ? 'Edit shipment' : 'تعديل الشحنة';
  static String get deleteShipment => _en ? 'Delete shipment' : 'حذف الشحنة';
  static String get deleteTrip => _en ? 'Delete trip' : 'حذف الرحلة';
  static String get reportShipment => _en ? 'Report shipment' : 'ابلاغ عن الشحنة';
  static String get confirmDeleteShipment =>
      _en ? 'Delete this shipment?' : 'هل تريد حذف هذه الشحنة؟';
  static String get confirmDeleteTrip =>
      _en ? 'Delete this trip?' : 'هل تريد حذف هذه الرحلة؟';
  static String get delete => _en ? 'Delete' : 'حذف';
  static String get insuranceDisclaimer => _en
      ? 'I confirm all shipment details are correct. Incorrect or unclear details may affect delivery; we are not liable for resulting issues.'
      : 'أقر بأن جميع تفاصيل هذه الشحنة صحيحة وأن أي تفاصيل غير صحيحة أو غير واضحة أو مفقودة قد تؤدي إلى أخطاء في عملية التسليم ولا نتحمل نتيجة ذلك.';
  static String get totalOrdersLabel => _en ? 'Total orders' : 'مجموع الطلبات';
  static String get totalWeightLabel => _en ? 'Total weight' : 'الوزن الكلي';
  static String get travelerRewardLabel => _en ? 'Traveler reward' : 'مكافأة المسافر';
  static String get companyFeesLabel => _en ? 'Company fees' : 'رسوم الشركة';
  static String get publishShipment => _en ? 'Publish shipment' : 'نشر الشحنة';
  static String get haveQuestions => _en ? 'Any questions?' : 'هل عندك استفسارات؟';
  static String get back => _en ? 'Back' : 'رجوع';
  static String get goBack => _en ? 'Go back' : 'رجوع';

  // Publish dialog
  static String get shippingMethodDialogMessage => _en
      ? 'The traveler may deliver via local shipping companies instead of meeting in person (extra fees may apply). Do you prefer this?'
      : 'قد يقوم المسافر بتسليم طلبك عن طريق شركات الشحن المحلي بدل المقابلة الشخصية '
          '(مع العلم أنه سيتم تطبيق رسوم إضافية للتوصيل طبقاً للشركة المختارة). هل تفضل هذه الطريقة؟';
  static String get yes => _en ? 'Yes' : 'نعم';
  static String get no => _en ? 'No' : 'لا';

  // More / settings
  static String get personalPage => _en ? 'Profile' : 'الصفحة الشخصية';
  static String get settings => _en ? 'Settings' : 'الإعدادات';
  static String get notifications => _en ? 'Notifications' : 'التنبيهات';
  static String get shippingOrTripNotifications => _en
      ? 'Shipment or trip availability alerts'
      : 'تنبيهات الشحنات أو الرحلات المتاحة';
  static String get chatNotifications => _en ? 'Chat notifications' : 'إشعارات الدردشة';
  static String get appCurrency => _en ? 'App currency' : 'عملة التطبيق';
  static String get appCurrencyHint => _en
      ? 'Show shipments and trips in the selected currency'
      : 'عرض الشحنات والرحلات بالعملة المختارة';
  static String get allCurrencies => _en ? 'All currencies' : 'كل العملات';
  static String get chooseLanguage => _en ? 'Choose language' : 'اختر اللغة';
  static String get language => _en ? 'Language' : 'اللغة';
  static String get languageArabic => _en ? 'Arabic' : 'اللغة العربية (Arabic)';
  static String get languageEnglishLabel => _en ? 'English' : 'الإنجليزية (English)';
  /// عناوين مختصرة لقائمة اختيار اللغة.
  static String get languageOptionArabic => _en ? 'Arabic' : 'العربية';
  static String get languageOptionEnglish => _en ? 'English' : 'الإنجليزية';
  static String get logout => _en ? 'Log out' : 'تسجيل الخروج';
  static String get logoutSuccess => _en ? 'Signed out' : 'تم تسجيل الخروج';
  static String get signInTitle => _en ? 'Sign in' : 'تسجيل الدخول';
  static String get guestUserLabel => _en ? 'Guest' : 'زائر';
  /// بند المزيد وشاشة إدارة حسابات السحب.
  static String get paymentDetails =>
      _en ? 'Withdrawal details' : 'تفاصيل سحب الأموال';
  static String get withdrawalPayoutScreenTitle =>
      _en ? 'Withdrawal accounts' : 'تفاصيل سحب الأموال';
  static String get payoutIntroHint => _en
      ? 'Add one or more payout accounts (IBAN / bank). Mark one as primary for withdrawals.'
      : 'أضف بطاقة أو أكثر لبيانات السحب (آيبان / بنك). عيّن حساباً رئيسياً لاستلام التحويلات.';
  static String get payoutEmptyState =>
      _en ? 'No payout accounts yet. Tap below to add one.' : 'لا توجد بطاقات بعد. اضغط أدناه للإضافة.';
  static String get payoutAddCardTitle => _en ? 'Add account' : 'إضافة بطاقة';
  static String get payoutEditCardTitle => _en ? 'Edit account' : 'تعديل البطاقة';
  static String get payoutCardNickname => _en ? 'Label (optional)' : 'اسم للبطاقة (اختياري)';
  static String get payoutIbanLabel => _en ? 'IBAN' : 'رقم الآيبان';
  static String get payoutBankNameLabel => _en ? 'Bank name' : 'اسم البنك';
  static String get payoutAccountHolderLabel => _en ? 'Account holder' : 'اسم صاحب الحساب';
  static String get payoutSetAsPrimary => _en ? 'Set as primary' : 'تعيين كحساب رئيسي';
  static String get payoutPrimaryBadge => _en ? 'Primary' : 'الحساب الرئيسي';
  static String get payoutUnnamedCard => _en ? 'Payout account' : 'حساب سحب';
  static String get payoutNeedOneField => _en
      ? 'Enter at least IBAN, bank name, or account holder.'
      : 'أدخل على الأقل الآيبان أو اسم البنك أو صاحب الحساب.';
  static String get payoutDeleteTitle => _en ? 'Delete account?' : 'حذف البطاقة؟';
  static String get payoutDeleteMessage => _en
      ? 'This payout account will be removed.'
      : 'سيتم حذف بيانات السحب هذه.';
  /// وسيلة الدفع عند دفع شحنة (طلب مقبول): تسمية المحفظة الداخلية.
  static String get paymentMethodFlyEmWallet =>
      _en ? 'FlyEm wallet' : 'محفظة فلاي إم';
  static String get paymentMethodHint => _en
      ? 'Choose your preferred payment method as a traveler'
      : 'اختر طريقة الدفع المفضلة لديك كمسافر';
  static String get chooseMethod => _en ? 'Choose method' : 'اختر طريقة';
  static String get save => _en ? 'Save' : 'حفظ';
  static String get currentCode => _en ? 'Current code:' : 'الكود الحالي:';
  static String get code => _en ? 'Code' : 'الكود';
  static String get value => _en ? 'Value' : 'القيمة';
  static String get expiresOn => _en ? 'Expires on' : 'ينتهي في';
  static String get enterPromoCode => _en ? 'Enter promo code' : 'اكتب الرمز الترويجي';
  static String get wishlist => _en ? 'Wishlist' : 'قائمة الأمنيات';
  static String get faq => _en ? 'FAQ' : 'الأسئلة الشائعة';
  static String get privacyAndTerms => _en ? 'Privacy & terms' : 'الخصوصية وشروط الاستخدام';
  static String get technicalSupport => _en ? 'Support' : 'الدعم الفني';
  static String get suggestToUs => _en ? 'Suggest to us' : 'اقترح علينا';
  static String get suggestToUsIntro => _en
      ? 'Your feedback inspires us — we’re glad to hear from you.'
      : 'قد يكون رأيك الشخصي مصدر إلهام لنا، وسعداء بمشاركتنا رأيك.';
  static String get suggestToUsHint =>
      _en ? 'Write your suggestion or note here…' : 'اكتب اقتراحك أو ملاحظتك هنا…';
  static String get suggestToUsSent =>
      _en ? 'Thanks — we received your message.' : 'شكراً لك، وصلتنا رسالتك.';
  static String get suggestWriteSomething =>
      _en ? 'Please enter your suggestion' : 'يرجى كتابة الاقتراح';
  static String get loginToViewProfile => _en
      ? 'Sign in to view this user’s public profile'
      : 'سجّل الدخول لعرض الملف العام للمستخدم';
  static String get publicProfileTitle => _en ? 'Public profile' : 'الملف العام';
  static String get publicProfilePhoneLabel => _en ? 'Phone / WhatsApp' : 'الهاتف / واتساب';
  static String get homeCountryLabel => _en ? 'Country (home)' : 'البلد (المنزل)';
  static String get travelCountryLabel => _en ? 'Country (travel)' : 'البلد (السفر)';
  static String get lastNameHidden => _en ? 'Last name' : 'اسم العائلة';
  static String get supportSubjectLabel => _en ? 'Subject' : 'النص';
  static String get supportDetailsHint =>
      _en ? 'Please describe the issue' : 'يرجى كتابة التفاصيل';
  static String get send => _en ? 'Send' : 'إرسال';
  static String get shareApp => _en ? 'Share the app with friends' : 'شارك التطبيق مع أصدقائك';
  static String get aboutApp => _en ? 'About' : 'حول التطبيق';

  // Personal profile
  static String get pendingVerification =>
      _en ? 'Verification pending' : 'في انتظار التوثيق';
  static String get pendingPhoneVerification =>
      _en ? 'Phone verification pending' : 'في انتظار التحقق من الهاتف';
  static String get documentsVerified =>
      _en ? 'Documents verified' : 'تم التحقق من الوثائق';
  static String get phoneVerified => _en ? 'Phone verified' : 'تم التحقق من الهاتف';
  static String get dealsCount => _en ? 'Deals' : 'الصفقات';
  static String get shipmentsCount => _en ? 'Shipments' : 'شحنة';
  static String get tripsCount => _en ? 'Trips' : 'الرحلات';
  static String get basicInfo => _en ? 'Basic info' : 'المعلومات الأساسية';
  static String get walletProfileTitle => _en ? 'Wallet' : 'المحفظة';
  static String get walletProfileHint =>
      _en ? 'Your balance in the app' : 'رصيدك داخل التطبيق';
  static String get walletWithdrawMyMoney => _en ? 'Withdraw my money' : 'سحب أموالي';
  static String get emailLabel => _en ? 'Email' : 'البريد الإلكتروني';
  static String get phoneLabel => _en ? 'Phone' : 'رقم الهاتف';
  static String get noPhoneEntered => _en ? 'No phone entered' : 'No phone entered';
  static String get phoneNumbersLabel => _en
      ? 'Phone numbers (account & profile)'
      : 'أرقام الهواتف (مرتبطة بالحساب والملف الشخصي)';
  static String get phoneForHomeland =>
      _en ? 'Phone (home country)' : 'رقم الهاتف (الدولة الأم)';
  static String get phoneForTravel =>
      _en ? 'Phone (travel country)' : 'رقم الهاتف (الدولة السفر)';
  static String get ratingsSection => _en ? 'Ratings' : 'تقييم';
  static String get myRatingLabel => _en ? 'My rating' : 'تقييمي';
  static String get travelerRating => _en ? 'Traveler rating' : 'تقييم المسافر';
  static String get shipperRating => _en ? 'Shipper rating' : 'تقييم الشاحن';
  static String get noRatings => _en ? 'No ratings yet' : 'لا يوجد تقييمات';
  static String get rateUser => _en ? 'Rate' : 'قيّم';
  static String get rateUserTitle => _en ? 'Rate the other party' : 'تقييم الطرف الآخر';
  static String get rateCommentHint => _en ? 'Comment (optional)' : 'تعليق (اختياري)';
  static String get submitRating => _en ? 'Submit rating' : 'إرسال التقييم';
  static String get ratingSent => _en ? 'Rating submitted' : 'تم إرسال التقييم';

  // Local notifications
  static String get notificationShipmentAdded =>
      _en ? 'Shipment added' : 'تمت إضافة الشحنة';
  static String get notificationShipmentUpdated =>
      _en ? 'Shipment updated' : 'تم تحديث الشحنة';
  static String get notificationTripAdded => _en ? 'Trip added' : 'تمت إضافة الرحلة';
  static String get notificationTripUpdated =>
      _en ? 'Trip changes saved' : 'تم حفظ تعديلات الرحلة';
  static String get notificationRequestSent =>
      _en ? 'Request sent' : 'تم إرسال الطلب';
  static String get notificationProfileSaved =>
      _en ? 'Profile saved' : 'تم حفظ الملف الشخصي';
  static String get notificationShipmentDeleted =>
      _en ? 'Shipment deleted' : 'تم حذف الشحنة';
  static String get notificationTripDeleted => _en ? 'Trip deleted' : 'تم حذف الرحلة';

  // Common UI (screens with hardcoded Arabic)
  static String get retry => _en ? 'Retry' : 'إعادة المحاولة';
  static String get requestAlreadySent => _en ? 'Request already sent' : 'تم إرسال طلب مسبقاً';
  static String get loadFailedTrip =>
      _en ? 'Failed to load trip details' : 'فشل تحميل تفاصيل الرحلة';
  static String get loadFailedChat => _en ? 'Failed to load chat' : 'فشل تحميل المحادثة';
  static String get messageSendFailed =>
      _en ? 'Failed to send message' : 'فشل إرسال الرسالة';
  static String get conversation => _en ? 'Chat' : 'محادثة';
  static String get noMessagesYet => _en
      ? 'No messages yet. Start the conversation.'
      : 'لا توجد رسائل بعد. ابدأ المحادثة.';
  static String get typeMessageHint => _en ? 'Type a message…' : 'اكتب رسالة...';
  static String get loadFailedPaymentMethods =>
      _en ? 'Failed to load payment methods' : 'فشل تحميل وسائل الدفع';
  static String get selectPaymentMethod =>
      _en ? 'Select a payment method' : 'اختر وسيلة الدفع';
  static String get cannotOpenBrowser =>
      _en ? 'Could not open the browser.' : 'تعذّر فتح المتصفح.';
  static String get cannotOpenBrowserTryCopy => _en
      ? 'Could not open the browser. Try copying the link from device settings.'
      : 'تعذّر فتح المتصفح. جرّب نسخ الرابط من إعدادات الجهاز.';
  static String get paypalCompleteSnack => _en
      ? 'Complete payment in PayPal, return to the app and tap “Complete payment” again.'
      : 'أكمل الدفع في PayPal، ثم ارجع إلى التطبيق واضغط «إتمام الدفع» مرة أخرى.';
  static String get paymentScreenTitle => _en ? 'Payment' : 'شاشة الدفع';
  static String get shipmentSummary => _en ? 'Shipment summary' : 'ملخص الشحنة';
  static String get tripSummary => _en ? 'Trip summary' : 'ملخص الرحلة';
  static String get paymentMethod => _en ? 'Payment method' : 'وسيلة الدفع';
  static String get paypalOpenHint => _en
      ? 'PayPal will open in the browser. After approving, return and tap the button again.'
      : 'سيتم فتح PayPal في المتصفح. بعد الموافقة على الدفع، ارجع واضغط الزر مرة أخرى.';
  static String get paypalCompleteHintShipment => _en
      ? 'If you finished paying in PayPal, tap below to complete.'
      : 'إذا أكملت الدفع في PayPal، اضغط الزر أدناه لإنهاء الطلب.';
  static String get paypalCompleteHintTrip => _en
      ? 'PayPal was opened. If you completed payment, tap below to finish.'
      : 'تم فتح PayPal. إذا أكملت الدفع، اضغط الزر أدناه لإنهاء الطلب.';
  static String get continueToPayPal => _en ? 'Continue to PayPal' : 'متابعة إلى PayPal';
  static String get completePayment => _en ? 'Complete payment' : 'إتمام الدفع';
  static String paymentApproximateAmount(String currencySymbol, String amount) => _en
      ? '$currencySymbol$amount — approximate amount'
      : '$currencySymbol$amount — المبلغ التقريبي';
  static String paymentShipmentAmountLine(String currencySymbol, String amount) => _en
      ? '$currencySymbol$amount — amount'
      : '$currencySymbol$amount — المبلغ';
  static String get statusInProgress => _en ? 'In progress' : 'قيد التنفيذ';
  static String get statusDelivered => _en ? 'Delivered' : 'تم التوصيل';
  static String get statusCancelled => _en ? 'Cancelled' : 'ملغى';
  static String get confirmAction => _en ? 'Confirm' : 'تأكيد';
  static String get loadFailedGeneric => _en ? 'Could not load' : 'تعذّر التحميل';
  static String get requestAccepted => _en ? 'Request accepted' : 'تم قبول الطلب';
  static String get requestRejected => _en ? 'Request rejected' : 'تم رفض الطلب';
  static String get shipmentGeneric => _en ? 'Shipment' : 'شحنة';
  static String get userGeneric => _en ? 'User' : 'مستخدم';
  static String get loadFailedConversations =>
      _en ? 'Failed to load conversations' : 'فشل تحميل المحادثات';
  static String get noData => _en ? 'No data' : 'لا توجد بيانات';
  static String get fetchDetailsFailed =>
      _en ? 'Failed to load details' : 'فشل جلب التفاصيل';
  static String get shipmentDeleted => _en ? 'Shipment deleted' : 'تم حذف الشحنة';
  static String get shipmentMissingFromTo => _en
      ? 'Shipment has no from/to'
      : 'الشحنة لا تحتوي على من/إلى';
  static String get noShipmentsAddFirst => _en
      ? 'No shipments. Add one first.'
      : 'لا توجد شحنات. أضف شحنة أولاً.';
  static String get selectShipmentLabel => _en ? 'Select shipment' : 'اختر الشحنة';
  static String suitableTripsHeader(String from, String to) => _en
      ? 'Trips matching your shipment: $from → $to'
      : 'رحلات مناسبة لشحنتك: من $from إلى $to';
  static String tripsLoadError(String err) => _en
      ? 'Error loading trips: $err'
      : 'حدث خطأ أثناء جلب الرحلات: $err';
  static String get noSuitableTrips =>
      _en ? 'No suitable trips right now' : 'لا توجد رحلات مناسبة في الوقت الحالي';
  static String get noShipmentsInSearch =>
      _en ? 'No shipments found' : 'لا توجد شحنات';
  static String get noTripsInSearch => _en ? 'No trips found' : 'لا توجد رحلات';

  // Trip detail sections (labels in UI)
  static String get detailTravelMethod => _en ? 'Travel method' : 'وسيلة السفر';
  static String get detailTripType => _en ? 'Trip type' : 'نوع الرحلة';
  static String get detailDates => _en ? 'Dates' : 'التواريخ';
  static String get detailDepartureDate => _en ? 'Departure date' : 'تاريخ المغادرة';
  static String get detailArrivalDate => _en ? 'Arrival date' : 'تاريخ الوصول';
  static String get detailDeliveryWindow => _en
      ? 'Window for shipment delivery'
      : 'الفترة المتاحة لتسليم الشحنة';
  static String get unspecified => _en ? 'Not set' : 'غير محدد';
  static String get detailPickupAreas => _en ? 'Shipment pickup areas' : 'مناطق تسلم الشحنة';
  static String get labelFrom => _en ? 'From' : 'من';
  static String get labelTo => _en ? 'To' : 'إلى';
  static String get detailNotes => _en ? 'Notes' : 'ملاحظات';

  static String get appTitle => _en ? 'FlyEm' : 'فلاي إم';

  /// Android notification channel (system UI; English when app is EN).
  static String get notificationChannelName =>
      _en ? 'App events' : 'أحداث التطبيق';
  static String get notificationChannelDescription => _en
      ? 'FlyEm event notifications'
      : 'إشعارات أحداث فلاي إم';

  /// مرجع يظهر للمستخدم (يتطابق مع معرّف السجل في التطبيق).
  static String appShipmentNumber(int n) =>
      _en ? 'App shipment no. $n' : 'رقم الشحنة في التطبيق: $n';
  static String appTripNumber(int n) =>
      _en ? 'App trip no. $n' : 'رقم الرحلة في التطبيق: $n';

  static String get profileDataSaved => _en ? 'Saved' : 'تم الحفظ';
}
