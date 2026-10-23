// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'إيفنترا';

  @override
  String get appTagline => 'اكتشف. احجز. عِش اللحظة.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navExplore => 'استكشف';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navTickets => 'التذاكر';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get priceFree => 'مجاني';

  @override
  String distanceKm(String value) {
    return '$value كم';
  }

  @override
  String distanceKmAway(String value) {
    return 'على بعد $value كم';
  }

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get errNetwork => 'تعذّر الوصول إلى إيفنترا. تحقّق من اتصالك.';

  @override
  String get errEventGone => 'هذه الفعالية لم تعد متاحة.';

  @override
  String get errStorage => 'التخزين المحلي غير متاح.';

  @override
  String get errUnknown => 'حدث خطأ ما.';

  @override
  String get errorTitle => 'حدث خطأ ما';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get mapEventLocation => 'موقع الفعالية';

  @override
  String get mapAttribution => '© مساهمو OpenStreetMap';

  @override
  String get yourLocation => 'موقعك';

  @override
  String get catCinema => 'سينما';

  @override
  String get catSports => 'رياضة';

  @override
  String get catSocial => 'اجتماعي';

  @override
  String get catMusic => 'موسيقى';

  @override
  String get catArt => 'فن';

  @override
  String get catTech => 'تقنية';

  @override
  String get catFood => 'طعام';

  @override
  String get catComedy => 'كوميديا';

  @override
  String get intOutdoors => 'الهواء الطلق';

  @override
  String get intNightlife => 'السهر';

  @override
  String get intCharity => 'العمل الخيري';

  @override
  String get intBusiness => 'الأعمال';

  @override
  String get sortRecommended => 'موصى بها';

  @override
  String get sortSoonest => 'الأقرب موعدًا';

  @override
  String get sortNearest => 'الأقرب مسافة';

  @override
  String get sortPriceLow => 'السعر: من الأقل إلى الأعلى';

  @override
  String get sortPopular => 'الأكثر شعبية';

  @override
  String get dateAny => 'أي وقت';

  @override
  String get dateToday => 'اليوم';

  @override
  String get dateTomorrow => 'غدًا';

  @override
  String get dateThisWeekend => 'نهاية هذا الأسبوع';

  @override
  String get dateNext7 => 'الأيام السبعة القادمة';

  @override
  String get datePick => 'اختر التواريخ';

  @override
  String get rowRecommendedForYou => 'مقترحة لك';

  @override
  String rowBecauseYouLike(String interest) {
    return 'لأنك تحب $interest';
  }

  @override
  String reasonBecauseYouLike(String interest) {
    return 'لأنك تحب $interest';
  }

  @override
  String get reasonNearYou => 'بالقرب منك';

  @override
  String get reasonTrending => 'رائج';

  @override
  String get reasonStartsSoon => 'تبدأ قريبًا';

  @override
  String get reasonThisWeek => 'هذا الأسبوع';

  @override
  String get reasonLikeSaves => 'مشابهة لمحفوظاتك';

  @override
  String get homeUpcoming => 'الفعاليات القادمة';

  @override
  String categoryEvents(String category) {
    return 'فعاليات $category';
  }

  @override
  String get filtersTitle => 'عوامل التصفية';

  @override
  String get noEventsMatch => 'لا توجد فعاليات مطابقة';

  @override
  String get loosenFilters => 'خفّف عوامل التصفية لرؤية المزيد من الفعاليات.';

  @override
  String get resetFilters => 'إعادة ضبط عوامل التصفية';

  @override
  String get pickDateRange => 'اختر نطاقًا زمنيًا';

  @override
  String get actionReset => 'إعادة ضبط';

  @override
  String get filtersCategories => 'الفئات';

  @override
  String get filtersAll => 'الكل';

  @override
  String get filtersDate => 'التاريخ';

  @override
  String filtersPriceRange(String min, String max) {
    return 'السعر: $min - $max';
  }

  @override
  String get filtersDistanceAny => 'المسافة: أي مسافة';

  @override
  String filtersDistanceWithin(String km) {
    return 'المسافة: ضمن $km كم';
  }

  @override
  String get filtersAny => 'أي';

  @override
  String filtersKm(String km) {
    return '$km كم';
  }

  @override
  String filtersFrom(String origin) {
    return 'من $origin';
  }

  @override
  String get filtersFreeOnly => 'المجانية فقط';

  @override
  String get filtersHasTickets => 'تذاكر متبقية';

  @override
  String get filtersSortBy => 'ترتيب حسب';

  @override
  String filtersShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عرض $count نتيجة',
      many: 'عرض $count نتيجة',
      few: 'عرض $count نتائج',
      two: 'عرض نتيجتين',
      one: 'عرض نتيجة واحدة',
      zero: 'لا توجد نتائج',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get tryAnotherCategory => 'جرّب فئة أخرى أو أعد ضبط عوامل التصفية.';

  @override
  String get showAllEvents => 'عرض كل الفعاليات';

  @override
  String reasonNearYouKm(String km) {
    return 'بالقرب منك · $km كم';
  }

  @override
  String get homeTrendingWeek => 'الرائج هذا الأسبوع';

  @override
  String nGoing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شخص سيحضرون',
      many: '$count شخصًا سيحضرون',
      few: '$count أشخاص سيحضرون',
      two: 'شخصان سيحضران',
      one: 'شخص واحد سيحضر',
      zero: 'لا أحد بعد',
    );
    return '$_temp0';
  }

  @override
  String get homeFreeEvents => 'فعاليات مجانية';

  @override
  String get openProfile => 'فتح الملف الشخصي';

  @override
  String get notificationsUnread => 'إشعارات غير مقروءة';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get homeHeroTitle => 'اكتشف فعاليات\nمذهلة بالقرب منك';

  @override
  String get searchEvents => 'ابحث عن فعاليات';

  @override
  String get searchHint => 'بحث';

  @override
  String get favUpdateFailed => 'تعذّر تحديث المفضلة. حاول مرة أخرى.';

  @override
  String get favRemove => 'إزالة من المفضلة';

  @override
  String get favSave => 'حفظ في المفضلة';

  @override
  String get openEvent => 'فتح الفعالية';

  @override
  String nParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مشارك',
      many: '$count مشاركًا',
      few: '$count مشاركين',
      two: 'مشاركان',
      one: 'مشارك واحد',
      zero: 'لا مشاركين',
    );
    return '$_temp0';
  }

  @override
  String get friendGoing => 'صديق - سيحضر';

  @override
  String get going => 'سيحضر';

  @override
  String morePeopleGoing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count شخص آخر سيحضرون',
      many: '+$count شخصًا آخر سيحضرون',
      few: '+$count أشخاص آخرين سيحضرون',
      two: '+شخصان آخران سيحضران',
      one: '+شخص آخر سيحضر',
    );
    return '$_temp0';
  }

  @override
  String get inviteFriends => 'دعوة الأصدقاء';

  @override
  String get closePreview => 'إغلاق المعاينة';

  @override
  String get saved => 'محفوظ';

  @override
  String get save => 'حفظ';

  @override
  String get share => 'مشاركة';

  @override
  String get viewEvent => 'عرض الفعالية';

  @override
  String cardDateDistance(String date, String km) {
    return '$date  ·  على بعد $km كم';
  }

  @override
  String shareText(
    String title,
    String date,
    String venue,
    String address,
    String price,
    String link,
  ) {
    return '$title - $date في $venue، $address. $price. $link';
  }

  @override
  String get shareFreeEntry => 'الدخول مجاني';

  @override
  String shareTicketsFrom(String price) {
    return 'التذاكر ابتداءً من $price';
  }

  @override
  String shareInviteText(String title, String date, String link) {
    return 'انضم إليّ في $title يوم $date! $link';
  }

  @override
  String shareInviteSubject(String title) {
    return 'تعال معي إلى $title';
  }

  @override
  String get authWeakPassword => 'اختر كلمة مرور أقوى.';

  @override
  String get authEmailTaken =>
      'يوجد حساب بهذا البريد الإلكتروني بالفعل. سجّل الدخول بدلًا من ذلك.';

  @override
  String get authCodeExpired => 'انتهت صلاحية هذا الرمز. اطلب رمزًا جديدًا.';

  @override
  String get authCodeWrong => 'هذا الرمز غير صحيح. تحقّق منه وحاول مرة أخرى.';

  @override
  String authBadCredentials(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'البريد الإلكتروني أو كلمة المرور غير صحيحة. تبقّت $left محاولة.',
      many: 'البريد الإلكتروني أو كلمة المرور غير صحيحة. تبقّت $left محاولة.',
      few: 'البريد الإلكتروني أو كلمة المرور غير صحيحة. تبقّت $left محاولات.',
      two: 'البريد الإلكتروني أو كلمة المرور غير صحيحة. تبقّت محاولتان.',
      one: 'البريد الإلكتروني أو كلمة المرور غير صحيحة. تبقّت محاولة واحدة.',
      zero: 'البريد الإلكتروني أو كلمة المرور غير صحيحة. لم تتبقَّ محاولات.',
    );
    return '$_temp0';
  }

  @override
  String get authUnverified =>
      'أكّد بريدك الإلكتروني بالرمز الذي أرسلناه لإكمال التسجيل.';

  @override
  String get authCodeInvalid => 'هذا الرمز غير صالح. اطلب رمزًا جديدًا.';

  @override
  String get authUserNotFound => 'لم نعثر على حساب بهذا البريد الإلكتروني.';

  @override
  String authLockedOut(String seconds) {
    return 'محاولات كثيرة جدًا. حاول مرة أخرى بعد $seconds ث.';
  }

  @override
  String get valEnterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get valValidEmail => 'أدخل عنوان بريد إلكتروني صالحًا';

  @override
  String get valEnterName => 'أدخل اسمك';

  @override
  String get valNameShort => 'الاسم قصير جدًا';

  @override
  String get valPhone => 'أدخل رقم هاتف صالحًا';

  @override
  String get valEnterPassword => 'أدخل كلمة المرور';

  @override
  String get valPasswordLength => 'استخدم 8 أحرف على الأقل';

  @override
  String get valPasswordMix => 'أضف أرقامًا أو رموزًا أو أحرفًا كبيرة';

  @override
  String get pwWeak => 'ضعيفة';

  @override
  String get pwFair => 'مقبولة';

  @override
  String get pwGood => 'جيدة';

  @override
  String get pwStrong => 'قوية';

  @override
  String get authEnterCode => 'أدخل الرمز المكوّن من 6 أرقام.';

  @override
  String get authPasswordUpdated =>
      'تم تحديث كلمة المرور. سجّل الدخول بكلمة المرور الجديدة.';

  @override
  String get authSetNewPassword => 'عيّن كلمة مرور جديدة';

  @override
  String get authForgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String authResetCodeSent(String email) {
    return 'أدخل الرمز الذي أرسلناه إلى $email واختر كلمة مرور جديدة.';
  }

  @override
  String get authResetIntro =>
      'أدخل البريد الإلكتروني لحسابك وسنرسل إليك رمز إعادة التعيين.';

  @override
  String get fieldEmail => 'البريد الإلكتروني';

  @override
  String get fieldNewPassword => 'كلمة المرور الجديدة';

  @override
  String get pleaseWait => 'يرجى الانتظار...';

  @override
  String get authUpdatePassword => 'تحديث كلمة المرور';

  @override
  String get authSendResetCode => 'إرسال رمز إعادة التعيين';

  @override
  String get authDemoNotice =>
      'وضع العرض التجريبي: لا تُرسَل الرموز بالبريد الإلكتروني؛ لا شيء يغادر هذا الجهاز.';

  @override
  String get authWelcomeBack => 'مرحبًا بعودتك';

  @override
  String get authLoginToBook => 'سجّل الدخول لحجز التذاكر ومزامنة مفضلتك.';

  @override
  String get authLoginContinue => 'سجّل الدخول لمتابعة ما بدأته.';

  @override
  String get authNewHere => 'جديد هنا؟';

  @override
  String get authSignUp => 'إنشاء حساب';

  @override
  String get fieldPassword => 'كلمة المرور';

  @override
  String authTryAgainIn(String seconds) {
    return 'حاول مرة أخرى بعد $seconds ث';
  }

  @override
  String get authLoggingIn => 'جارٍ تسجيل الدخول...';

  @override
  String get authLogIn => 'تسجيل الدخول';

  @override
  String get authOr => 'أو';

  @override
  String get authTryDemo => 'جرّب الحساب التجريبي';

  @override
  String get authContinueGuest => 'المتابعة كضيف';

  @override
  String authNewCodeSent(String email) {
    return 'أرسلنا رمزًا جديدًا إلى $email';
  }

  @override
  String get authCheckEmail => 'تحقّق من بريدك الإلكتروني';

  @override
  String authOtpSubtitle(String email) {
    return 'أدخل الرمز المكوّن من 6 أرقام الذي أرسلناه إلى $email.';
  }

  @override
  String get authVerifying => 'جارٍ التحقق...';

  @override
  String get authVerify => 'تحقّق';

  @override
  String get authDidntGetIt => 'لم يصلك؟';

  @override
  String authResendIn(String seconds) {
    return 'إعادة الإرسال بعد 0:$seconds';
  }

  @override
  String get authResendCode => 'إعادة إرسال الرمز';

  @override
  String get authCodesExpire => 'تنتهي صلاحية الرموز بعد 10 دقائق.';

  @override
  String get authCreateAccountTitle => 'إنشاء حساب';

  @override
  String get authJoinSubtitle =>
      'انضم إلى إيفنترا لحجز التذاكر ومتابعة المنظّمين.';

  @override
  String get authHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get fieldFullName => 'الاسم الكامل';

  @override
  String get fieldPhoneOptional => 'الهاتف (اختياري)';

  @override
  String get fieldConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get valPasswordsMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authAgreeTerms => 'أوافق على شروط الخدمة وسياسة الخصوصية';

  @override
  String get authCreatingAccount => 'جارٍ إنشاء الحساب...';

  @override
  String get authCreateAccount => 'إنشاء الحساب';

  @override
  String get back => 'رجوع';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get pwStrengthLabel => 'قوة كلمة المرور';

  @override
  String pwStrengthValue(String level) {
    return 'قوة كلمة المرور: $level';
  }

  @override
  String authDebugCode(String code) {
    return 'نسخة تصحيح: الرمز التجريبي هو $code';
  }

  @override
  String get interestsTitle => 'ما الذي يستهويك؟';

  @override
  String interestsSubtitle(String min) {
    return 'اختر $min على الأقل لنخصّص لك المحتوى. يمكنك تغييرها لاحقًا من الملف الشخصي.';
  }

  @override
  String interestsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم تحديد $count',
      many: 'تم تحديد $count',
      few: 'تم تحديد $count',
      two: 'تم تحديد اثنين',
      one: 'تم تحديد واحد',
      zero: 'لم يُحدَّد شيء',
    );
    return '$_temp0';
  }

  @override
  String interestsChooseMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'اختر $count أخرى',
      many: 'اختر $count أخرى',
      few: 'اختر $count أخرى',
      two: 'اختر اثنين آخرين',
      one: 'اختر واحدًا آخر',
    );
    return '$_temp0';
  }

  @override
  String get actionContinue => 'متابعة';

  @override
  String locNearestArea(String city) {
    return 'أقرب منطقة إليك: $city';
  }

  @override
  String get locOff => 'الموقع متوقف، لذا اختر مدينتك أدناه.';

  @override
  String get locWhere => 'أين أنت؟';

  @override
  String get locWhy => 'نستخدمه لعرض الفعاليات القريبة منك وقياس المسافات.';

  @override
  String get locUseCurrent => 'استخدام موقعي الحالي';

  @override
  String get locSkip => 'تخطَّ الآن';

  @override
  String get onb1Title => 'اكتشف الفعاليات القريبة منك';

  @override
  String get onb1Body =>
      'حفلات ومباريات ومحاضرات وأسواق طعام من حولك، مختارة وفق ما تحب.';

  @override
  String get onb2Title => 'احجز في ثوانٍ';

  @override
  String get onb2Body => 'اختر تذاكرك وطبّق رمز الخصم وادفع بلمستين.';

  @override
  String get onb3Title => 'ادخل بلمسة';

  @override
  String get onb3Body => 'تذكرتك برمز QR داخل التطبيق، جاهزة عند الباب.';

  @override
  String get onbSkip => 'تخطٍّ';

  @override
  String onbPageOf(int page, int total) {
    return 'الصفحة $page من $total';
  }

  @override
  String get onbGetStarted => 'ابدأ الآن';

  @override
  String get onbNext => 'التالي';

  @override
  String get exploreDistancesUpdated => 'تم تحديث المسافات بناءً على موقعك';

  @override
  String exploreServicesOff(String place) {
    return 'خدمات الموقع متوقفة. تُعرض المسافات من $place.';
  }

  @override
  String exploreLocationUnavailable(String place) {
    return 'الموقع غير متاح. تُعرض المسافات من $place.';
  }

  @override
  String get exploreShowMyLocation => 'إظهار موقعي';

  @override
  String nUpcomingEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فعالية قادمة',
      many: '$count فعالية قادمة',
      few: '$count فعاليات قادمة',
      two: 'فعاليتان قادمتان',
      one: 'فعالية قادمة واحدة',
      zero: 'لا فعاليات قادمة',
    );
    return '$_temp0';
  }

  @override
  String openNamed(String name) {
    return 'فتح $name';
  }

  @override
  String get exploreNearest => 'أقرب المواقع';

  @override
  String get exploreNoPlaces => 'لا توجد أماكن تطابق بحثك';

  @override
  String get exploreSearchHint => 'ابحث عن موقعك...';

  @override
  String explorePlaceSemantics(String title, String address, String distance) {
    return '$title، $address، على بعد $distance';
  }

  @override
  String get favSortRecent => 'المحفوظة مؤخرًا';

  @override
  String get favSortSoonest => 'التاريخ: الأقرب';

  @override
  String get favSortName => 'الاسم: أ إلى ي';

  @override
  String favRemoved(String title) {
    return 'تمت إزالة $title';
  }

  @override
  String get undo => 'تراجع';

  @override
  String get sort => 'ترتيب';

  @override
  String get favShowGrid => 'عرض كشبكة';

  @override
  String get favShowList => 'عرض كقائمة';

  @override
  String get favEmptyTitle => 'لا توجد مفضلات بعد';

  @override
  String get favEmptyBody => 'انقر على علامة الحفظ في أي فعالية لحفظها هنا.';

  @override
  String get exploreEvents => 'استكشف الفعاليات';

  @override
  String nResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا نتائج',
    );
    return '$_temp0';
  }

  @override
  String get clearFilters => 'مسح عوامل التصفية';

  @override
  String get searchFullHint => 'ابحث عن فعاليات أو أماكن أو مواقع';

  @override
  String get clear => 'مسح';

  @override
  String get recentSearches => 'عمليات البحث الأخيرة';

  @override
  String get recentCleared => 'تم مسح عمليات البحث الأخيرة';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String removedTerm(String term) {
    return 'تمت إزالة \"$term\"';
  }

  @override
  String get trendingSearches => 'عمليات البحث الرائجة';

  @override
  String noResultsFor(String query) {
    return 'لا نتائج لـ \"$query\"';
  }

  @override
  String get searchFiltersHiding =>
      'قد تُخفي عوامل التصفية بعض النتائج. امسحها أو جرّب أحد هذه الاقتراحات:';

  @override
  String get searchCheckSpelling =>
      'تحقّق من الإملاء أو جرّب أحد هذه الاقتراحات:';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get notifRemoved => 'تمت إزالة الإشعار';

  @override
  String get markAllRead => 'تعليم الكل كمقروء';

  @override
  String get notifEmptyTitle => 'لا جديد';

  @override
  String get notifEmptyBody => 'ستظهر التذكيرات والتحديثات الجديدة هنا.';

  @override
  String get earlier => 'سابقًا';

  @override
  String get seedFriendsTitle => 'صديقان سيحضران';

  @override
  String seedFriendsBody(String title) {
    return 'حفظت سارة وليام $title.';
  }

  @override
  String get seedSoonTitle => 'قريبًا';

  @override
  String seedSoonBody(String title) {
    return '$title من الفعاليات القادمة بالقرب منك.';
  }

  @override
  String seedReviewTitle(String title) {
    return 'كيف كانت $title؟';
  }

  @override
  String get seedReviewBody => 'يشارك الحضور تقييماتهم. انقر لقراءتها.';

  @override
  String get seedNewTitle => 'جديد في الموسيقى بالقرب منك';

  @override
  String seedNewBody(String title) {
    return 'تم الإعلان للتو عن $title.';
  }

  @override
  String get seedPriceTitle => 'سعر الحجز المبكر متاح';

  @override
  String seedPriceBody(String title) {
    return 'وفّر 20% على $title طوال فترة الحجز المبكر.';
  }

  @override
  String get detailsTitle => 'تفاصيل الفعالية';

  @override
  String plusParticipants(String count) {
    return '+$count مشارك';
  }

  @override
  String get detailsAbout => 'عن الفعالية';

  @override
  String get detailsLocation => 'الموقع';

  @override
  String get detailsOrganizer => 'المنظِّم';

  @override
  String get detailsLineup => 'البرنامج والجدول';

  @override
  String get detailsPolicy => 'سياسة التذاكر';

  @override
  String get detailsSimilar => 'فعاليات مشابهة';

  @override
  String get shareEvent => 'مشاركة الفعالية';

  @override
  String get soldOut => 'نفدت التذاكر';

  @override
  String get waitlistJoined => 'أنت على قائمة الانتظار. سنخبرك عند توفر مكان.';

  @override
  String get waitlistLeft => 'غادرت قائمة الانتظار.';

  @override
  String get onWaitlist => 'على قائمة الانتظار';

  @override
  String get joinWaitlist => 'انضم إلى قائمة الانتظار';

  @override
  String get verifiedOrganizer => 'منظِّم موثَّق';

  @override
  String organizerFollowers(String followers) {
    return 'المنظِّم - $followers متابع';
  }

  @override
  String get following => 'متابَع';

  @override
  String get follow => 'متابعة';

  @override
  String openMapFor(String venue) {
    return 'افتح خريطة $venue. اضغط مطولًا للحصول على الاتجاهات.';
  }

  @override
  String get seeMore => 'عرض المزيد...';

  @override
  String get seeLess => 'عرض أقل';

  @override
  String get getTicket => 'احصل على تذكرة';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get profileUnavailable => 'الملف الشخصي غير متاح.';

  @override
  String get profileLoginToEdit => 'سجّل الدخول لتعديل ملفك الشخصي.';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي';

  @override
  String get couldNotSave => 'تعذّر الحفظ. يرجى المحاولة مرة أخرى.';

  @override
  String get avatarColor => 'لون الصورة الرمزية';

  @override
  String avatarColorN(String n) {
    return 'لون الصورة الرمزية $n';
  }

  @override
  String get fieldName => 'الاسم';

  @override
  String get fieldCity => 'المدينة';

  @override
  String get fieldCityHint => 'أين تخرج عادةً';

  @override
  String get fieldBio => 'نبذة';

  @override
  String get fieldBioHint => 'سطر عنك';

  @override
  String get saving => 'جارٍ الحفظ...';

  @override
  String get guest => 'ضيف';

  @override
  String get profileGuestPrompt => 'سجّل الدخول لشراء التذاكر ومزامنة المفضلة';

  @override
  String get statTickets => 'التذاكر';

  @override
  String get statSaved => 'المحفوظة';

  @override
  String get statReviews => 'التقييمات';

  @override
  String get loginOrSignup => 'سجّل الدخول أو أنشئ حسابًا';

  @override
  String get myTickets => 'تذاكري';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get inviteFriendsTitle => 'دعوة الأصدقاء';

  @override
  String get inviteShareText =>
      'أجد الفعاليات على إيفنترا - اكتشف. احجز. عِش اللحظة. https://eventra.app';

  @override
  String get interestsTitleShort => 'الاهتمامات';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get logOutQ => 'تسجيل الخروج؟';

  @override
  String get logOutBody => 'تبقى تذاكرك ومفضلتك على هذا الجهاز لحين عودتك.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get setReminders => 'تذكيرات الفعاليات';

  @override
  String get setRemindersSub =>
      'قبل 24 ساعة وساعتين من الفعاليات التي لديك تذاكر لها';

  @override
  String get setOrders => 'تحديثات الطلبات';

  @override
  String get setOrdersSub => 'تأكيدات الحجز والمبالغ المستردة في صندوق الوارد';

  @override
  String get setRecs => 'التوصيات';

  @override
  String get setRecsSub => 'فعاليات جديدة وتخفيضات قد تعجبك';

  @override
  String get setPersonalized => 'محتوى مخصّص';

  @override
  String get setPersonalizedSub => 'استخدام اهتماماتك لترتيب الفعاليات';

  @override
  String get setClearCache => 'مسح ذاكرة التخزين المؤقت';

  @override
  String get setClearCacheSub => 'الصور المخزنة مؤقتًا وعمليات البحث الأخيرة';

  @override
  String get setCacheCleared => 'تم مسح ذاكرة التخزين المؤقت';

  @override
  String get setAbout => 'حول إيفنترا';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountQ => 'حذف حسابك؟';

  @override
  String get deleteAccountBody =>
      'ستُزال بيانات ملفك الشخصي وتذاكرك وتقييماتك وإشعاراتك من هذا الجهاز. لن تُسترد قيمة التذاكر. لا يمكن التراجع عن ذلك.';

  @override
  String get deleteConfirmWord => 'حذف';

  @override
  String typeToConfirm(String word) {
    return 'اكتب $word';
  }

  @override
  String get delete => 'حذف';

  @override
  String get setAppearance => 'المظهر';

  @override
  String get setLanguage => 'اللغة';

  @override
  String get setNotifications => 'الإشعارات';

  @override
  String get setPrivacy => 'الخصوصية';

  @override
  String get setStorage => 'التخزين';

  @override
  String get setAboutSection => 'حول';

  @override
  String get setAccount => 'الحساب';

  @override
  String get sortReviews => 'ترتيب التقييمات';

  @override
  String get revNewest => 'الأحدث';

  @override
  String get revHighest => 'الأعلى تقييمًا';

  @override
  String get revLowest => 'الأدنى تقييمًا';

  @override
  String get revLoadFailed => 'تعذّر تحميل التقييمات.';

  @override
  String get revNoneHere => 'لا توجد تقييمات هنا';

  @override
  String get revTryAnotherStar => 'جرّب عامل تصفية آخر للنجوم.';

  @override
  String nReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تقييم',
      many: '$count تقييمًا',
      few: '$count تقييمات',
      two: 'تقييمان',
      one: 'تقييم واحد',
      zero: 'لا تقييمات',
    );
    return '$_temp0';
  }

  @override
  String revYou(String name) {
    return '$name (أنت)';
  }

  @override
  String get revOptions => 'خيارات التقييم';

  @override
  String get edit => 'تعديل';

  @override
  String get seeAllLower => 'عرض الكل';

  @override
  String get revNoneYet => 'لا توجد تقييمات بعد.';

  @override
  String get revWrite => 'اكتب تقييمًا';

  @override
  String get revEditYours => 'عدّل تقييمك';

  @override
  String get revSignedOut => 'سجّل الدخول بتذكرة لهذه الفعالية لترك تقييم.';

  @override
  String get revOnlyAttendees =>
      'يمكن فقط للحضور الذين لديهم تذكرة تقييم هذه الفعالية.';

  @override
  String get revAfterEnd => 'يمكنك تقييم هذه الفعالية بعد انتهائها.';

  @override
  String get revDeleteQ => 'حذف تقييمك؟';

  @override
  String get cannotUndo => 'لا يمكن التراجع عن ذلك.';

  @override
  String get revDeleted => 'تم حذف التقييم';

  @override
  String get revThanks => 'شكرًا على تقييمك!';

  @override
  String get revUpdated => 'تم تحديث التقييم';

  @override
  String get revRateEvent => 'قيّم هذه الفعالية';

  @override
  String nStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نجمة',
      many: '$count نجمة',
      few: '$count نجوم',
      two: 'نجمتان',
      one: 'نجمة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get revHint => 'ما الذي أعجبك؟ وما الذي يمكن تحسينه؟';

  @override
  String revMinChars(String n) {
    return '$n أحرف على الأقل';
  }

  @override
  String get revPost => 'نشر التقييم';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get revEdited => 'معدَّل';

  @override
  String get revLoginToWrite => 'سجّل الدخول لكتابة تقييم.';

  @override
  String get tkBadQuantity => 'كمية غير صالحة.';

  @override
  String get tkUnknownTier => 'نوع تذكرة غير معروف.';

  @override
  String tkTierMax(String max, String tier) {
    return 'يمكنك شراء $max تذاكر $tier كحد أقصى.';
  }

  @override
  String get tkChooseFirst => 'اختر تذكرة أولًا.';

  @override
  String tkOrderMax(String max) {
    return 'يمكنك شراء $max تذاكر كحد أقصى في الطلب الواحد.';
  }

  @override
  String tkNotEnough(String tier) {
    return 'لم يتبقَّ عدد كافٍ من تذاكر $tier. حدّث اختيارك.';
  }

  @override
  String get tkSelectionLost => 'فُقد اختيارك.';

  @override
  String get tkHoldEnded =>
      'انتهت مدة الحجز المؤقت البالغة 10 دقائق وأُفرج عن التذاكر.';

  @override
  String get tkChoosePay => 'اختر طريقة الدفع.';

  @override
  String get tkPaymentFailed => 'فشلت عملية الدفع.';

  @override
  String get tkSoldOutPaying =>
      'نفدت هذه التذاكر أثناء الدفع. لم يتم خصم أي مبلغ منك.';

  @override
  String get tkOrderNotFound => 'الطلب غير موجود.';

  @override
  String get tkTicketUsed => 'تم استخدام إحدى تذاكر هذا الطلب بالفعل.';

  @override
  String get tkRefundFailed => 'تعذّرت معالجة الاسترداد. حاول مرة أخرى.';

  @override
  String get cardEnterNumber => 'أدخل رقم البطاقة.';

  @override
  String cardIncomplete(String brand) {
    return 'رقم $brand هذا غير مكتمل.';
  }

  @override
  String get cardInvalid => 'رقم البطاقة هذا غير صالح.';

  @override
  String get cardUseMmYy => 'استخدم الصيغة MM/YY.';

  @override
  String get cardExpired => 'انتهت صلاحية هذه البطاقة.';

  @override
  String get cardCheckYear => 'تحقّق من سنة انتهاء الصلاحية.';

  @override
  String cardCvcDigits(String n) {
    return '$n أرقام.';
  }

  @override
  String get cardGeneric => 'بطاقة';

  @override
  String get payAuthCancelled =>
      'أُلغيت مصادقة البطاقة. لم يتم خصم أي مبلغ منك.';

  @override
  String get payDeclined => 'تم رفض بطاقتك. جرّب بطاقة أخرى.';

  @override
  String get payTimeout =>
      'انتهت مهلة الدفع. لم يتم خصم أي مبلغ منك؛ حاول مرة أخرى.';

  @override
  String get promoEmpty => 'أدخل رمز الخصم.';

  @override
  String get promoUnknown => 'هذا الرمز غير موجود.';

  @override
  String get promoNotYet => 'هذا الرمز غير مفعّل بعد.';

  @override
  String get promoExpired => 'انتهت صلاحية هذا الرمز.';

  @override
  String get promoExhausted => 'تم استنفاد هذا الرمز بالكامل.';

  @override
  String get promoUsed => 'لقد استخدمت هذا الرمز من قبل.';

  @override
  String get promoNotApplicable => 'لا ينطبق هذا الرمز على التذاكر المحددة.';

  @override
  String get promoMinSubtotal => 'أضف المزيد من التذاكر لاستخدام هذا الرمز.';

  @override
  String get promoL10 => 'خصم 10%';

  @override
  String get promoL5 => 'خصم 5\$ على طلبك الأول';

  @override
  String get promoL20 => 'خصم 20% على تذاكر VIP';

  @override
  String get promoL25 => 'خصم 25% على فعاليات الصيف';

  @override
  String get promoL50 => 'تخفيضات خاطفة 50%';

  @override
  String get refundSummary =>
      'استرداد كامل عند الإلغاء قبل أكثر من 48 ساعة من بدء الفعالية. لا استرداد خلال 48 ساعة من موعد البدء.';

  @override
  String get refundStarted => 'بدأت هذه الفعالية بالفعل.';

  @override
  String get refundFreeAnyTime =>
      'حجز مجاني: يمكنك الإلغاء في أي وقت قبل الفعالية.';

  @override
  String get refundFullUntil =>
      'الاسترداد الكامل متاح حتى 48 ساعة قبل الفعالية.';

  @override
  String get refundClosed =>
      'تُغلق عمليات الاسترداد قبل 48 ساعة من بدء الفعالية.';

  @override
  String get remChannel => 'تذكيرات الفعاليات';

  @override
  String get remChannelDesc => 'تذكيرات قبل 24 ساعة وساعتين من الفعاليات';

  @override
  String remTitleTomorrow(String title) {
    return '$title تبدأ غدًا';
  }

  @override
  String remTitleSoon(String title) {
    return '$title تبدأ بعد ساعتين';
  }

  @override
  String remBody(String venue) {
    return '$venue. تذكرتك جاهزة في إيفنترا.';
  }

  @override
  String get stValid => 'صالحة';

  @override
  String get stUsed => 'مستخدمة';

  @override
  String get stExpired => 'منتهية';

  @override
  String get stCancelled => 'ملغاة';

  @override
  String get ntBookingConfirmed => 'تم تأكيد الحجز';

  @override
  String ntBookingBody(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تذكرة لـ $title. رمز QR جاهز.',
      many: '$count تذكرة لـ $title. رمز QR جاهز.',
      few: '$count تذاكر لـ $title. رمز QR جاهز.',
      two: 'تذكرتان لـ $title. رمز QR جاهز.',
      one: 'تذكرة واحدة لـ $title. رمز QR جاهز.',
    );
    return '$_temp0';
  }

  @override
  String get ntRefundIssued => 'تم إصدار الاسترداد';

  @override
  String ntRefundBody(String amount, String title) {
    return '$amount مقابل $title في طريقها إلى بطاقتك.';
  }

  @override
  String get bsOrderNotFound => 'الطلب غير موجود';

  @override
  String get bsInMyTickets => 'تذاكرك موجودة في تذاكري.';

  @override
  String get bsLoadFailed => 'تعذّر تحميل طلبك.';

  @override
  String get bsYoureIn => 'أنت مسجَّل!';

  @override
  String bsFreeReserved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم حجز $count مكان مجاني',
      many: 'تم حجز $count مكانًا مجانيًا',
      few: 'تم حجز $count أماكن مجانية',
      two: 'تم حجز مكانين مجانيين',
      one: 'تم حجز مكان مجاني واحد',
    );
    return '$_temp0';
  }

  @override
  String bsPaid(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تذكرة · تم دفع $amount',
      many: '$count تذكرة · تم دفع $amount',
      few: '$count تذاكر · تم دفع $amount',
      two: 'تذكرتان · تم دفع $amount',
      one: 'تذكرة واحدة · تم دفع $amount',
    );
    return '$_temp0';
  }

  @override
  String get bsRemindBoth => 'سنذكّرك قبل 24 ساعة وقبل ساعتين.';

  @override
  String get bsRemind2h => 'سنذكّرك قبل ساعتين.';

  @override
  String get bsViewTickets => 'عرض التذاكر';

  @override
  String get bsViewTicket => 'عرض التذكرة';

  @override
  String get addToCalendar => 'إضافة إلى التقويم';

  @override
  String get done => 'تم';

  @override
  String get coCheckout => 'الدفع';

  @override
  String get coLoadFailed => 'تعذّر تحميل صفحة الدفع.';

  @override
  String get coNotFound => 'صفحة الدفع غير موجودة';

  @override
  String get coSelectionGone =>
      'لم يعد هذا الاختيار متاحًا. اختر تذاكرك مرة أخرى.';

  @override
  String get coAlreadyBooked => 'محجوز مسبقًا';

  @override
  String get coInWallet => 'هذه التذاكر في محفظتك.';

  @override
  String get coLeaveQ => 'مغادرة صفحة الدفع؟';

  @override
  String get coLeaveBody => 'تذاكرك محجوزة لك. المغادرة ستتيحها لمعجبين آخرين.';

  @override
  String get coStay => 'البقاء';

  @override
  String get coRelease => 'إلغاء حجز التذاكر';

  @override
  String get coPriceDetails => 'تفاصيل السعر';

  @override
  String get coAttendee => 'بيانات الحاضر';

  @override
  String get coEnterHolder => 'أدخل الاسم الذي سيظهر على التذاكر.';

  @override
  String get coEmailForTickets => 'البريد الإلكتروني لتذاكرك';

  @override
  String get coValidEmail => 'أدخل بريدًا إلكترونيًا صالحًا.';

  @override
  String get coPromo => 'رمز الخصم';

  @override
  String coPromoSaves(String label, String amount) {
    return '$label · توفير $amount';
  }

  @override
  String get coRemovePromo => 'إزالة رمز الخصم';

  @override
  String get coEnterCode => 'أدخل الرمز';

  @override
  String get coApply => 'تطبيق';

  @override
  String get coPayment => 'طريقة الدفع';

  @override
  String get coDemoMode => 'وضع تجريبي';

  @override
  String get coAddCard => 'إضافة بطاقة جديدة';

  @override
  String get coUseAnother => 'استخدام بطاقة أخرى';

  @override
  String get coConfirmFree => 'تأكيد الحجز المجاني';

  @override
  String coPay(String amount) {
    return 'ادفع $amount';
  }

  @override
  String coExpires(String date) {
    return 'تنتهي في $date';
  }

  @override
  String coNewCardExpires(String date) {
    return 'بطاقة جديدة · تنتهي في $date';
  }

  @override
  String coCardEnding(String brand, String last4) {
    return '$brand تنتهي بـ $last4';
  }

  @override
  String get coHoldExpired => 'انتهى الحجز المؤقت وأُفرج عن التذاكر.';

  @override
  String coHeldFor(String time) {
    return 'التذاكر محجوزة لمدة $time';
  }

  @override
  String get coChooseAgain => 'اختر مرة أخرى';

  @override
  String get co3dsTitle => 'أكّد مع مصرفك';

  @override
  String co3dsBody(String amount, String card) {
    return 'وافق على دفع $amount إلى إيفنترا باستخدام $card. هذا تحقّق 3-D Secure محاكى.';
  }

  @override
  String get coApprove => 'موافقة';

  @override
  String get coPaymentConfirmed => 'تم تأكيد الدفع';

  @override
  String get coProcessing => 'جارٍ معالجة الدفع…';

  @override
  String get coIssuing => 'جارٍ إصدار تذاكرك';

  @override
  String get coKeepOpen => 'يرجى إبقاء التطبيق مفتوحًا';

  @override
  String get tabUpcoming => 'القادمة';

  @override
  String get tabPast => 'السابقة';

  @override
  String get tabCancelled => 'الملغاة';

  @override
  String get mtLoadFailed => 'تعذّر فتح تذاكرك.';

  @override
  String get mtNoUpcoming => 'لا تذاكر قادمة';

  @override
  String get mtNoUpcomingBody =>
      'اعثر على ما تحب وستكون تذاكرك هنا، جاهزة للمسح حتى دون اتصال.';

  @override
  String get mtNoPast => 'لا فعاليات سابقة بعد';

  @override
  String get mtNoPastBody => 'ستُحفظ هنا الفعاليات التي تحضرها.';

  @override
  String get mtNoCancelled => 'لا شيء ملغى';

  @override
  String get mtNoCancelledBody => 'تظهر التذاكر المستردة هنا.';

  @override
  String tabWithCount(String label, String count) {
    return '$label ($count)';
  }

  @override
  String get tdRefundQ => 'طلب استرداد؟';

  @override
  String get tdCancelResQ => 'إلغاء الحجز؟';

  @override
  String tdRefundBody(int count, String amount, String card) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ستُلغى $count تذكرة في هذا الطلب ويُعاد $amount إلى $card.',
      many: 'ستُلغى $count تذكرة في هذا الطلب ويُعاد $amount إلى $card.',
      few: 'ستُلغى $count تذاكر في هذا الطلب ويُعاد $amount إلى $card.',
      two: 'ستُلغى تذكرتا هذا الطلب ويُعاد $amount إلى $card.',
      one: 'ستُلغى تذكرة هذا الطلب ويُعاد $amount إلى $card.',
    );
    return '$_temp0';
  }

  @override
  String tdReleaseBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ستُتاح أماكنك لمعجبين آخرين.',
      one: 'سيُتاح مكانك لمعجبين آخرين.',
    );
    return '$_temp0';
  }

  @override
  String get tdKeep => 'الاحتفاظ بالتذاكر';

  @override
  String get tdRefund => 'استرداد';

  @override
  String get tdCancelRes => 'إلغاء الحجز';

  @override
  String tdRefunded(String amount) {
    return 'تم استرداد $amount. أُلغيت تذاكرك.';
  }

  @override
  String get tdResCancelled => 'تم إلغاء الحجز.';

  @override
  String get tdYourTicket => 'تذكرتك';

  @override
  String get tdLoadFailed => 'تعذّر فتح هذه التذكرة.';

  @override
  String get tdNotFound => 'التذكرة غير موجودة';

  @override
  String get tdOtherAccount => 'ربما تخص حسابًا آخر.';

  @override
  String get tdAddCal => 'إضافة إلى\nالتقويم';

  @override
  String get tdDirections => 'الاتجاهات';

  @override
  String get tdInvite => 'دعوة\nالأصدقاء';

  @override
  String get tdDetails => 'تفاصيل\nالفعالية';

  @override
  String get tdOrder => 'الطلب';

  @override
  String get tdRefundedChip => 'مسترد';

  @override
  String get tdPaid => 'مدفوع';

  @override
  String get tdBooked => 'تاريخ الحجز';

  @override
  String tdPromo(String code) {
    return 'خصم $code';
  }

  @override
  String get feesAndTax => 'الرسوم والضرائب';

  @override
  String get tdTotalPaid => 'إجمالي المدفوع';

  @override
  String get tdPaidWith => 'الدفع عبر';

  @override
  String get tdRefundPolicy => 'سياسة الاسترداد';

  @override
  String get tdProcessing => 'جارٍ المعالجة…';

  @override
  String tdRequestRefund(String amount) {
    return 'طلب استرداد · $amount';
  }

  @override
  String get fDate => 'التاريخ';

  @override
  String get fTime => 'الوقت';

  @override
  String get fVenue => 'المكان';

  @override
  String get fTicket => 'التذكرة';

  @override
  String tdSeqOf(String seq, String count) {
    return '$seq من $count';
  }

  @override
  String get tdWasCancelled => 'أُلغيت هذه التذكرة';

  @override
  String get tdEnded => 'انتهت هذه الفعالية';

  @override
  String get fHolder => 'حامل التذكرة';

  @override
  String get fTier => 'الفئة';

  @override
  String get tdShowCode =>
      'اعرض هذا الرمز عند المدخل. يتغيّر كل 30 ثانية، لذا لن تنفع لقطات الشاشة.';

  @override
  String get tpLoadFailed => 'تعذّر تحميل تذاكر هذه الفعالية.';

  @override
  String get tpStarted => 'بدأت هذه الفعالية؛ لم تعد التذاكر معروضة للبيع.';

  @override
  String tpCapReached(String max) {
    return 'وصلت إلى الحد الأقصى البالغ $max تذاكر للطلب الواحد.';
  }

  @override
  String tpUpTo(String max) {
    return 'حتى $max تذاكر في الطلب الواحد. تُحجز المقاعد لمدة 10 دقائق بعد المتابعة.';
  }

  @override
  String get soldOutLower => 'نفدت';

  @override
  String tpAllGone(String count) {
    return 'نفدت جميع التذاكر البالغة $count';
  }

  @override
  String tpLeftOf(String left, String total) {
    return 'تبقّى $left من $total';
  }

  @override
  String tpOnlyLeft(String left) {
    return 'تبقّى $left فقط';
  }

  @override
  String tpMaxPer(String max) {
    return '$max كحد أقصى لكل طلب';
  }

  @override
  String get tpChooseToSee => 'اختر تذاكرك لرؤية الإجمالي.';

  @override
  String nTickets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تذكرة',
      many: '$count تذكرة',
      few: '$count تذاكر',
      two: 'تذكرتان',
      one: 'تذكرة واحدة',
      zero: 'لا تذاكر',
    );
    return '$_temp0';
  }

  @override
  String get total => 'الإجمالي';

  @override
  String get tpHolding => 'جارٍ حجز مقاعدك…';

  @override
  String get tpContinue => 'المتابعة إلى الدفع';

  @override
  String get cfAddCard => 'إضافة بطاقة';

  @override
  String get cfNumber => 'رقم البطاقة';

  @override
  String get cfName => 'الاسم على البطاقة';

  @override
  String get cfEnterName => 'أدخل الاسم المطبوع على البطاقة.';

  @override
  String get cfDemo =>
      'وضع تجريبي، دون خصم حقيقي. بطاقات الاختبار: 4242 4242 4242 4242 مقبولة، و4000 0000 0000 0002 مرفوضة، و4000 0000 0000 3220 تطلب 3-D Secure. نحتفظ فقط بنوع البطاقة وآخر أربعة أرقام.';

  @override
  String get cfUse => 'استخدام هذه البطاقة';

  @override
  String tvCalDesc(String link) {
    return 'تذكرتك على إيفنترا موجودة في التطبيق. $link';
  }

  @override
  String get tvCalAdded => 'تمت الإضافة إلى تقويمك';

  @override
  String get tvCalFailed => 'تعذّر فتح التقويم.';

  @override
  String tvInviteText(String title, String date, String venue, String link) {
    return 'سأحضر $title يوم $date في $venue. انضم إليّ! $link';
  }

  @override
  String tvMapsFailed(String address) {
    return 'تعذّر فتح الخرائط. $address';
  }

  @override
  String get tvQrLabel => 'رمز QR للتذكرة. يتجدد كل 30 ثانية.';

  @override
  String tvRefreshIn(String seconds) {
    return 'يتجدد الرمز خلال $seconds ث';
  }

  @override
  String get tvQrFailed => 'تعذّر إنشاء الرمز الآمن على هذا الجهاز.';

  @override
  String tvTierSeq(String tier, String seq, String count) {
    return '$tier · التذكرة $seq من $count';
  }

  @override
  String get removeOne => 'إزالة واحدة';

  @override
  String get addOne => 'إضافة واحدة';

  @override
  String subtotalN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'المجموع الفرعي ($count تذكرة)',
      many: 'المجموع الفرعي ($count تذكرة)',
      few: 'المجموع الفرعي ($count تذاكر)',
      two: 'المجموع الفرعي (تذكرتان)',
      one: 'المجموع الفرعي (تذكرة واحدة)',
      zero: 'المجموع الفرعي',
    );
    return '$_temp0';
  }

  @override
  String get serviceFees => 'رسوم الخدمة';

  @override
  String get tax => 'الضريبة';

  @override
  String get valProfileName => 'أدخل اسمك (حرفان على الأقل)';

  @override
  String valUnderN(String n) {
    return 'اجعله أقل من $n حرفًا';
  }

  @override
  String get revValRating => 'اختر تقييمًا من نجمة إلى 5 نجوم.';

  @override
  String revValShort(String n) {
    return 'اكتب $n أحرف على الأقل.';
  }

  @override
  String revValLong(String n) {
    return 'اجعله أقل من $n حرفًا.';
  }

  @override
  String get revDupEdit =>
      'لقد قيّمت هذه الفعالية بالفعل. عدّل تقييمك بدلًا من ذلك.';

  @override
  String get revDup => 'لقد قيّمت هذه الفعالية بالفعل.';

  @override
  String get revNotFound => 'التقييم غير موجود.';

  @override
  String get profOrganizerMode => 'وضع المنظّم';

  @override
  String get profOrganizerModeBody =>
      'انشر الفعاليات وتابع المبيعات وسجّل دخول الضيوف';

  @override
  String get profOrganizerDashboard => 'لوحة المنظّم';

  @override
  String get orgDashboardTitle => 'لوحة التحكم';

  @override
  String get orgCreateEvent => 'إنشاء فعالية';

  @override
  String get orgRevenue => 'الإيرادات';

  @override
  String get orgTicketsSold => 'التذاكر المباعة';

  @override
  String get orgCheckInRate => 'نسبة الدخول';

  @override
  String orgOfCapacity(String sold, String capacity) {
    return '$sold من $capacity';
  }

  @override
  String orgCheckedInOf(String checkedIn, String total) {
    return 'دخل $checkedIn من $total';
  }

  @override
  String get orgSalesOverTime => 'المبيعات، آخر 14 يومًا';

  @override
  String orgTicketsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تذكرة',
      many: '$count تذكرة',
      few: '$count تذاكر',
      two: 'تذكرتان',
      one: 'تذكرة واحدة',
      zero: 'لا تذاكر',
    );
    return '$_temp0';
  }

  @override
  String get orgByTier => 'المبيعات حسب الفئة';

  @override
  String get orgDrafts => 'المسودات';

  @override
  String get orgDraftUntitled => 'فعالية بلا عنوان';

  @override
  String orgDraftSavedAt(String when) {
    return 'حُفظت $when';
  }

  @override
  String get orgDraftDeleted => 'حُذفت المسودة';

  @override
  String get orgDelete => 'حذف';

  @override
  String get orgUpcoming => 'الفعاليات القادمة';

  @override
  String get orgNoEvents => 'لا توجد فعاليات قادمة بعد. أنشئ أول فعالية.';

  @override
  String get orgStatusLive => 'جارية الآن';

  @override
  String get orgStatusOnSale => 'متاحة للبيع';

  @override
  String get orgStatusSoldOut => 'نفدت التذاكر';

  @override
  String get orgCheckIn => 'تسجيل الدخول';

  @override
  String get orgEdit => 'تعديل';

  @override
  String get orgScanTab => 'المسح';

  @override
  String get orgGuestsTab => 'قائمة الضيوف';

  @override
  String get orgScanHint => 'وجّه الكاميرا نحو رمز QR في تذكرة الحاضر.';

  @override
  String get orgCameraUnavailable => 'الكاميرا غير متاحة. أدخل الرمز يدويًا.';

  @override
  String get orgEnterCode => 'إدخال الرمز يدويًا';

  @override
  String get orgEnterCodeBody => 'الصق محتوى رمز QR أو اكتب رقم التذكرة.';

  @override
  String get orgCodeHint => 'ETK1… أو رقم التذكرة';

  @override
  String get orgVerify => 'تحقّق';

  @override
  String get orgSearchGuests => 'ابحث بالاسم أو الفئة أو التذكرة';

  @override
  String get orgNoGuests => 'لا ضيوف';

  @override
  String get orgNoGuestsBody => 'ستظهر هنا التذاكر المباعة لهذه الفعالية.';

  @override
  String get orgNoMatches => 'لا يوجد ضيف يطابق بحثك.';

  @override
  String get orgCheckInAction => 'سجّل الدخول';

  @override
  String orgPendingSync(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count للمزامنة',
      many: '$count للمزامنة',
      few: '$count للمزامنة',
      two: 'اثنان للمزامنة',
      one: 'واحد للمزامنة',
    );
    return '$_temp0';
  }

  @override
  String get orgSynced => 'تمت مزامنة جميع عمليات الدخول.';

  @override
  String orgSyncOffline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'غير متصل: ستتم مزامنة $count عملية دخول لاحقًا.',
      many: 'غير متصل: ستتم مزامنة $count عملية دخول لاحقًا.',
      few: 'غير متصل: ستتم مزامنة $count عمليات دخول لاحقًا.',
      two: 'غير متصل: ستتم مزامنة عمليتي دخول لاحقًا.',
      one: 'غير متصل: ستتم مزامنة عملية دخول واحدة لاحقًا.',
    );
    return '$_temp0';
  }

  @override
  String get resValid => 'تذكرة صالحة. أهلًا بك!';

  @override
  String get resAlready => 'سُجّل دخوله مسبقًا';

  @override
  String resAlreadyBody(String time) {
    return 'استُخدمت هذه التذكرة في $time.';
  }

  @override
  String get resWrongEvent => 'فعالية خاطئة';

  @override
  String get resWrongEventBody => 'هذه التذكرة لفعالية أخرى.';

  @override
  String get resExpired => 'انتهت صلاحية الرمز';

  @override
  String get resExpiredBody =>
      'تتجدد رموز التذاكر كل 30 ثانية. اطلب من الضيف فتح تذكرته مجددًا.';

  @override
  String get resForged => 'تذكرة غير صالحة';

  @override
  String get resForgedBody => 'هذا الرمز ليس تذكرة Eventra أصلية.';

  @override
  String get resCancelled => 'ملغاة';

  @override
  String get resCancelledBody => 'تم استرداد هذه التذكرة أو إلغاؤها.';

  @override
  String get resNextScan => 'امسح التالي';

  @override
  String get wizNewTitle => 'فعالية جديدة';

  @override
  String get wizEditTitle => 'تعديل الفعالية';

  @override
  String get wizSaveDraft => 'حفظ المسودة';

  @override
  String get wizDraftSaved => 'حُفظت المسودة';

  @override
  String wizStepOf(int step, int total) {
    return 'الخطوة $step من $total';
  }

  @override
  String get wizStepBasics => 'الأساسيات';

  @override
  String get wizStepSchedule => 'التاريخ والوقت';

  @override
  String get wizStepVenue => 'المكان';

  @override
  String get wizStepTiers => 'التذاكر والأسعار';

  @override
  String get wizStepCover => 'صورة الغلاف';

  @override
  String get wizStepReview => 'المراجعة والنشر';

  @override
  String get wizNext => 'متابعة';

  @override
  String get wizPublish => 'نشر الفعالية';

  @override
  String get wizSaveChanges => 'حفظ التغييرات';

  @override
  String get wizPublished => 'فعاليتك منشورة الآن.';

  @override
  String get wizUpdated => 'تم تحديث الفعالية.';

  @override
  String get wizPublishFailed => 'تعذّر نشر الفعالية. حاول مجددًا.';

  @override
  String get wizTitle => 'عنوان الفعالية';

  @override
  String get wizCategory => 'الفئة';

  @override
  String get wizDescription => 'الوصف';

  @override
  String get wizStarts => 'البداية';

  @override
  String get wizEnds => 'النهاية';

  @override
  String get wizPick => 'اختر';

  @override
  String wizDuration(int hours, int minutes) {
    return 'المدة: $hours س $minutes د';
  }

  @override
  String get wizVenueName => 'اسم المكان';

  @override
  String get wizAddress => 'العنوان';

  @override
  String get wizPinHint => 'انقر على الخريطة لتحديد المدخل.';

  @override
  String get wizPinHere => 'استخدم موقعي';

  @override
  String wizTierN(int n) {
    return 'الفئة $n';
  }

  @override
  String get wizTierName => 'اسم الفئة';

  @override
  String get wizTierNameHint => 'دخول عام';

  @override
  String get wizTierPrice => 'السعر';

  @override
  String get wizTierCapacity => 'الكمية';

  @override
  String get wizFreeTier => 'السعر 0 يجعل هذه الفئة مجانية (بالتسجيل).';

  @override
  String get wizAddTier => 'إضافة فئة';

  @override
  String wizCapacityTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقعد إجمالًا',
      many: '$count مقعدًا إجمالًا',
      few: '$count مقاعد إجمالًا',
      two: 'مقعدان إجمالًا',
      one: 'مقعد واحد إجمالًا',
      zero: 'لا مقاعد بعد',
    );
    return '$_temp0';
  }

  @override
  String wizCoverN(int n) {
    return 'صورة الغلاف $n';
  }

  @override
  String get wizCoverCredit => 'الصور: Unsplash (ترخيص Unsplash).';

  @override
  String get wizDefaultPolicy =>
      'استرداد كامل حتى 48 ساعة قبل الفعالية. لا استرداد خلال 48 ساعة من موعد البدء.';

  @override
  String wizErrTitle(int min, int max) {
    return 'استخدم من $min إلى $max حرفًا.';
  }

  @override
  String get wizErrCategory => 'اختر فئة.';

  @override
  String wizErrDescription(int n) {
    return 'صف الفعالية في $n حرفًا على الأقل.';
  }

  @override
  String get wizErrStart => 'اختر موعد بدء الفعالية.';

  @override
  String get wizErrStartPast => 'يجب أن يكون موعد البدء في المستقبل.';

  @override
  String get wizErrEnd => 'اختر موعد انتهاء الفعالية.';

  @override
  String get wizErrEndBefore => 'يجب أن تكون النهاية بعد البداية.';

  @override
  String get wizErrTooLong => 'لا يمكن أن تتجاوز مدة الفعالية 7 أيام.';

  @override
  String get wizErrVenue => 'أدخل اسم المكان.';

  @override
  String get wizErrAddress => 'أدخل العنوان.';

  @override
  String get wizErrPin => 'ضع العلامة على الخريطة.';

  @override
  String wizErrTiers(int n) {
    return 'أضف من فئة واحدة إلى $n فئات.';
  }

  @override
  String get wizErrTierName => 'سمِّ الفئة (من 2 إلى 30 حرفًا).';

  @override
  String get wizErrTierDuplicate => 'يجب أن يكون لكل فئة اسم مختلف.';

  @override
  String get wizErrTierPrice => 'أدخل سعرًا من 0 إلى 10,000.';

  @override
  String get wizErrTierCapacity => 'أدخل كمية من 1 إلى 100,000.';

  @override
  String get wizErrTierBelowSold => 'لا يمكن أن تقل الكمية عن التذاكر المباعة.';

  @override
  String wizErrTierBelowSoldN(int n) {
    return '$n على الأقل (مباعة بالفعل).';
  }

  @override
  String get wizErrCover => 'اختر صورة غلاف.';

  @override
  String orgPctOfCapacity(String pct, String capacity) {
    return '$pct من $capacity مقعد';
  }

  @override
  String a11yRating(String rating, String count) {
    return 'التقييم $rating من 5 بناءً على $count مراجعة';
  }

  @override
  String a11yEventPhoto(String title) {
    return 'صورة $title';
  }

  @override
  String a11ySalesChart(String days, String total, String peak) {
    return 'التذاكر المبيعة خلال آخر $days يومًا: $total إجمالًا، وأفضل يوم $peak';
  }
}
