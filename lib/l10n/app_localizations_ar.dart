// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'دفتر';

  @override
  String get home => 'الرئيسية';

  @override
  String get customers => 'العملاء';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get language => 'اللغة';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get totalDebts => 'إجمالي الديون';

  @override
  String get totalPayments => 'إجمالي المدفوعات';

  @override
  String get pendingReminders => 'المعلقة';

  @override
  String get recentTransactions => 'آخر المعاملات';

  @override
  String get noTransactionsYet => 'لا توجد معاملات بعد';

  @override
  String get searchCustomers => 'البحث عن عملاء...';

  @override
  String get addCustomer => 'إضافة عميل';

  @override
  String get editCustomer => 'تعديل العميل';

  @override
  String get customerName => 'اسم العميل';

  @override
  String get customerPhone => 'رقم الهاتف';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get phoneOptional => 'الهاتف (اختياري)';

  @override
  String get noCustomersYet => 'لا يوجد عملاء بعد';

  @override
  String get noCustomersMessage => 'أضف أول عميل للبدء';

  @override
  String get debt => 'دين';

  @override
  String get payment => 'دفعة';

  @override
  String get amount => 'المبلغ';

  @override
  String get note => 'ملاحظة';

  @override
  String get noteOptional => 'ملاحظة (اختياري)';

  @override
  String get balance => 'الرصيد';

  @override
  String get owes => 'عليه';

  @override
  String get overpaid => 'زائد';

  @override
  String get settled => 'مساوي';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get phone => 'الهاتف';

  @override
  String get name => 'الاسم';

  @override
  String get customerDetail => 'تفاصيل العميل';

  @override
  String get addDebt => 'إضافة دين';

  @override
  String get recordPayment => 'تسجيل دفعة';

  @override
  String get noTransactionsForCustomer => 'لا توجد معاملات بعد';

  @override
  String get noTransactionsMessage => 'سجّل ديناً أو دفعة للبدء';

  @override
  String get totalOwed => 'إجمالي المستحق';

  @override
  String get totalPaid => 'إجمالي المدفوع';

  @override
  String get deleteCustomer => 'حذف العميل';

  @override
  String get confirmDelete => 'هل أنت متأكد من حذف هذا العميل؟';

  @override
  String get selectDebt => 'اختر الدين للسداد';

  @override
  String get remaining => 'المتبقي';

  @override
  String get paid => 'المدفوع';

  @override
  String get paidTo => 'مدفوع لـ';

  @override
  String get fullyPaid => 'مدفوع بالكامل';

  @override
  String get noOutstandingDebts => 'لا توجد ديون مستحقة';

  @override
  String get noOutstandingDebtsMessage => 'جميع الديون مسددة';

  @override
  String get editPayment => 'تعديل الدفعة';

  @override
  String get deletePayment => 'حذف الدفعة';

  @override
  String get amountCannotExceedRemaining => 'المبلغ لا يمكن أن يتجاوز المتبقي';

  @override
  String get editRecords => 'تعديل ';

  @override
  String get editDebt => 'تعديل الدين';

  @override
  String get deleteDebt => 'حذف الدين';

  @override
  String get confirmDeleteDebt =>
      'هل أنت متأكد من حذف هذا الدين؟ سيتم أيضًا حذف جميع الدفعات المرتبطة به.';

  @override
  String get allTransactions => 'جميع المعاملات';

  @override
  String get all => 'الكل';

  @override
  String get debts => 'الديون';

  @override
  String get payments => 'المدفوعات';

  @override
  String get searchTransactions => 'البحث في المعاملات...';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get filter => 'تصفية';

  @override
  String get dateRange => 'نطاق التاريخ';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get netBalance => 'الرصيد الصافي';

  @override
  String get dateNewest => 'التاريخ (الأحدث أولاً)';

  @override
  String get dateOldest => 'التاريخ (الأقدم أولاً)';

  @override
  String get amountHighest => 'المبلغ (الأعلى أولاً)';

  @override
  String get amountLowest => 'المبلغ (الأدنى أولاً)';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get collectionRate => 'نسبة التحصيل';

  @override
  String get topDebtors => 'أكبر المدينين';

  @override
  String get monthlyTrend => 'الاتجاه';

  @override
  String get outstanding => 'المتبقي';

  @override
  String get noChartData => 'لا توجد بيانات بعد';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get noTopDebtors => 'لا توجد ديون مستحقة';

  @override
  String get ofTotalDebts => 'من إجمالي الديون';

  @override
  String get analytics => 'التحليلات';

  @override
  String get seedDemoData => 'تحميل بيانات تجريبية';

  @override
  String get clearDemoData => 'مسح البيانات التجريبية';

  @override
  String get demoDataSeeded => 'تم تحميل البيانات التجريبية!';

  @override
  String get demoDataCleared => 'تم مسح البيانات التجريبية!';

  @override
  String get day => 'يوم';

  @override
  String get week => 'أسبوع';

  @override
  String get month => 'شهر';

  @override
  String get year => 'سنة';

  @override
  String get periodDebts => 'الديون';

  @override
  String get periodPayments => 'المدفوعات';

  @override
  String get periodTotals => 'المجاميع حسب الفترة';

  @override
  String get currentPeriod => 'الحالي';

  @override
  String get overdue => 'متأخرة';

  @override
  String get dueToday => 'مستحقة اليوم';

  @override
  String get upcoming => 'قادمة';

  @override
  String get completedReminders => 'مكتملة';

  @override
  String get noReminders => 'لا توجد تذكيرات';

  @override
  String get noRemindersMessage => 'جميع الديون مسددة!';

  @override
  String get daysOverdue => 'أيام تأخر';

  @override
  String get daysUntilDue => 'أيام حتى الاستحقاق';

  @override
  String get reminderDetails => 'تفاصيل التذكير';

  @override
  String get outstandingAmount => 'المبلغ المستحق';

  @override
  String get status => 'الحالة';

  @override
  String get markCompleted => 'تم التحصيل';

  @override
  String get deleteReminder => 'حذف التذكير';

  @override
  String get confirmDeleteReminder => 'هل أنت متأكد من حذف هذا التذكير؟';

  @override
  String get reminderDate => 'تاريخ التذكير';

  @override
  String get confirmMarkCompleted => 'هل تريد تحديد هذا التذكير كمكتمل؟';

  @override
  String get confirmMarkPending => 'هل تريد إعادة فتح هذا التذكير؟';

  @override
  String get deleteAll => 'حذف الكل';

  @override
  String get confirmDeleteAll =>
      'هل أنت متأكد من حذف جميع تذكيرات هذه القائمة؟';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get reminderDateOptional => 'تذكير (اختياري)';

  @override
  String get pickDate => 'اختر تاريخ';

  @override
  String get today => 'اليوم';

  @override
  String get afterOneWeek => 'بعد أسبوع';

  @override
  String get afterOneMonth => 'بعد شهر';

  @override
  String get searchReminders => 'بحث في التذكيرات...';

  @override
  String get sortByDateNewest => 'التاريخ (الأحدث)';

  @override
  String get sortByDateOldest => 'التاريخ (الأقدم)';

  @override
  String get sortByAmountHighest => 'المبلغ (الأعلى)';

  @override
  String get sortByAmountLowest => 'المبلغ (الأدنى)';

  @override
  String get sortByNameAZ => 'الاسم (أ-ي)';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get theme => 'المظهر';

  @override
  String get dataManagement => 'إدارة البيانات';

  @override
  String get administrator => 'مشرف';

  @override
  String get autoSettledViaReminder => 'تسوية تلقائية عبر التذكير';

  @override
  String get autoSettledViaReminderDelete => 'تسوية تلقائية عبر حذف التذكير';

  @override
  String get phoneInvalid => 'يجب أن يكون الرقم 11 خانة';

  @override
  String joined(Object date) {
    return 'انضم $date';
  }

  @override
  String get billion => 'مليار';

  @override
  String get million => 'مليون';

  @override
  String get thousand => 'ألف';

  @override
  String get signInWithGoogle => 'تسجيل الدخول بحساب Google';

  @override
  String get signInWithPhone => 'تسجيل الدخول بالهاتف';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get phoneHint => 'أدخل رقم هاتفك';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get verifyCode => 'تحقق';

  @override
  String get codeSent => 'تم إرسال الرمز إلى هاتفك';

  @override
  String codeSentTo(Object phone) {
    return 'تم إرسال الرمز إلى $phone';
  }

  @override
  String verificationCodeTo(Object phone) {
    return 'سنرسل رمز التحقق إلى $phone';
  }

  @override
  String get otpHint => 'أدخل الرمز المكون من6 أرقام';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendIn(Object seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get invalidOtp => 'رمز غير صحيح. حاول مرة أخرى.';

  @override
  String get verificationFailed => 'فشل التحقق. حاول مرة أخرى.';

  @override
  String get autoVerifying => 'جاري التحقق التلقائي...';

  @override
  String get createPin => 'إنشاء رمز PIN';

  @override
  String get enterPin => 'أدخل رمز PIN';

  @override
  String get confirmPin => 'تأكيد رمز PIN';

  @override
  String get pinHint => 'أدخل رمز PIN مكون من 4-6 أرقام';

  @override
  String get pinMismatch => 'رمز PIN غير متطابق';

  @override
  String get pinTooShort => 'يجب أن يكون رمز PIN 4 أرقام على الأقل';

  @override
  String get pinTooLong => 'يجب أن يكون رمز PIN 6 أرقام كحد أقصى';

  @override
  String get pinSetupTitle => 'إعداد رمز PIN';

  @override
  String get pinSetupSubtitle => 'أنشئ رمز PIN لتأمين حسابك';

  @override
  String get pinEntryTitle => 'مرحباً بعودتك';

  @override
  String get pinEntrySubtitle => 'أدخل رمز PIN للمتابعة';

  @override
  String get incorrectPin => 'رمز PIN غير صحيح. حاول مرة أخرى.';

  @override
  String get pinCreated => 'تم إنشاء رمز PIN بنجاح';

  @override
  String get yourName => 'اسمك';

  @override
  String get nameHint => 'أدخل اسمك';

  @override
  String get setupProfile => 'إعداد الملف الشخصي';

  @override
  String get profileSetupSubtitle => 'أدخل بياناتك للبدء';

  @override
  String get cloudSync => 'المزامنة السحابية';

  @override
  String get syncStatusConnected => 'متصل';

  @override
  String get syncStatusSyncing => 'جاري المزامنة...';

  @override
  String get syncStatusOffline => 'غير متصل';

  @override
  String get syncStatusError => 'خطأ في المزامنة';

  @override
  String get lastSynced => 'آخر مزامنة';

  @override
  String get pendingSync => 'بانتظار المزامنة';

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get notSynced => 'غير متزامن';

  @override
  String get deleteLocalDatabase => 'حذف قاعدة البيانات المحلية';

  @override
  String get confirmDeleteLocalDatabase =>
      'سيؤدي هذا إلى حذف جميع البيانات المحلية بشكل دائم (العملاء، الديون، الدفعات، التذكيرات). بياناتك في السحابة آمنة. هل تريد المتابعة؟';

  @override
  String get welcomeTo => 'مرحباً بك في';

  @override
  String get tagline => 'أدر ديونك بسهولة';

  @override
  String get subtitle => 'تتبع الديون رقمياً لأعمالك';

  @override
  String get choosePlan => 'اختر خطتك';

  @override
  String get choosePlanSubtitle => 'اختر اشتراكاً للبدء';

  @override
  String get planTrial => 'تجربة';

  @override
  String get planTrialDesc => '14 أيام وصول كامل، بدون بطاقة ائتمان';

  @override
  String get planWeekly => 'أسبوعي';

  @override
  String get planWeeklyDesc => '7 أيام وصول، تتجدد أسبوعياً';

  @override
  String get planMonthly => 'شهري';

  @override
  String get planMonthlyDesc => '30 يوم وصول، تتجدد شهرياً';

  @override
  String get free => 'مجاني';

  @override
  String get contactAdmin => 'تواصل مع المدير';

  @override
  String get subActive => 'نشط';

  @override
  String get subExpiring => 'ينتهي قريباً';

  @override
  String get subGrace => 'فترة السماح';

  @override
  String get subBlocked => 'محظور';

  @override
  String get subNoData => 'لا يوجد اشتراك';

  @override
  String get subExpiredReadonly => 'انتهى الاشتراك — وضع القراءة فقط';

  @override
  String get admin => 'الإدارة';

  @override
  String get subscribersDashboard => 'المشتركون';

  @override
  String get totalSubscribers => 'الإجمالي';

  @override
  String get activeSubscribers => 'نشط';

  @override
  String get expiringSubscribers => 'ينتهي قريباً';

  @override
  String get expiredSubscribers => 'منتهي';

  @override
  String get noSubscribers => 'لا يوجد مشتركون بعد';

  @override
  String get noSubscribersMessage => 'سيظهر المشتركون هنا بعد تسجيل الدخول';

  @override
  String daysAgo(Object days) {
    return 'منذ $days يوم';
  }

  @override
  String daysLeft(Object days) {
    return 'متبقي $days يوم';
  }

  @override
  String get subToday => 'اليوم';

  @override
  String get updateExpiry => 'تحديث تاريخ الانتهاء';

  @override
  String get extend15min => '+15 دقيقة';

  @override
  String get extend30min => '+30 دقيقة';

  @override
  String get extend1hour => '+ساعة';

  @override
  String get extendWeek => '+أسبوع';

  @override
  String get extend2Weeks => '+أسبوعين';

  @override
  String get extendMonth => '+شهر';

  @override
  String get expiryUpdated => 'تم تحديث تاريخ الانتهاء بنجاح';

  @override
  String get expiresOn => 'ينتهي في';

  @override
  String get accessDenied => 'غير مصرح بالدخول';

  @override
  String get subLoadError => 'فشل تحميل المشتركين';

  @override
  String get expireNow => 'إنهاء الآن';

  @override
  String get confirmExpire => 'إنهاء الاشتراك؟';

  @override
  String confirmExpireMsg(Object name) {
    return 'سيتم إنهاء اشتراك $name فوراً.';
  }

  @override
  String get cancelled => 'تم الإلغاء';

  @override
  String get subscriptionExpired => 'تم إنهاء الاشتراك';

  @override
  String get subscriptionDetails => 'تفاصيل الاشتراك';

  @override
  String get planName => 'الخطة';

  @override
  String get expiresOnLabel => 'ينتهي في';

  @override
  String get timeRemainingLabel => 'الوقت المتبقي';

  @override
  String get expiredLabel => 'منتهي';

  @override
  String get wipeAllData => 'مسح جميع البيانات';

  @override
  String get confirmWipeAll =>
      'سيؤدي هذا إلى حذف جميع البيانات بشكل永久 من المحلي والسحابة (العملاء، الديون، الدفعات، التذكيرات، الاشتراك). لا يمكن التراجع عن هذا الإجراء. هل تريد المتابعة؟';

  @override
  String get wipeAllSuccess => 'تم مسح جميع البيانات بنجاح';

  @override
  String get checkForUpdates => 'التحقق من التحديثات';

  @override
  String get updateAvailable => 'تحديث متاح';

  @override
  String get newVersionAvailable => 'إصدار جديد من التطبيق متاح';

  @override
  String get currentVersion => 'الإصدار الحالي';

  @override
  String get latestVersion => 'أحدث إصدار';

  @override
  String get updateNow => 'تحديث الآن';

  @override
  String get updateLater => 'لاحقًا';

  @override
  String get downloading => 'جاري التحميل...';

  @override
  String get downloadComplete => 'اكتمل التحميل';

  @override
  String get tapToInstall => 'اضغط لتثبيت التحديث';

  @override
  String get updateFailed => 'فشل التحديث. يرجى المحاولة مرة أخرى.';

  @override
  String get upToDate => 'أنت تستخدم أحدث إصدار!';

  @override
  String get releaseNotes => 'ما الجديد';

  @override
  String get forceUpdateRequired => 'هذا التحديث مطلوب للمتابعة';

  @override
  String get updateRetry => 'إعادة المحاولة';

  @override
  String get updateDone => 'تم';

  @override
  String get updateInstalling => 'جاري التحضير للتثبيت...';

  @override
  String get updateChecking => 'جاري التحقق من التحديثات...';

  @override
  String get blockedTitle => 'تم حظر الوصول';

  @override
  String get blockedClockRollback =>
      'تاريخ/وقت جهازك غير صحيح. يرجى ضبط ساعة الجهاز على التاريخ والوقت الصحيح، ثم الاتصال الإنترنت والضغط على تحديث.';

  @override
  String get blockedDataSafe => 'بياناتك آمنة ومحفوظة بشكل آمن.';

  @override
  String get blockedRequiresInternet => 'يتطلب اتصال الإنترنت للتحقق';

  @override
  String get blockedRefresh => 'تحديث والتحقق';

  @override
  String timeDaysHours(Object days, Object hours) {
    return '$daysي $hoursس';
  }

  @override
  String timeHoursMinutes(Object hours, Object minutes) {
    return '$hoursس $minutesد';
  }

  @override
  String get voiceInput => 'إدخال صوتي';

  @override
  String get listening => 'جاري الاستماع...';

  @override
  String get parsingVoice => 'الذكاء الاصطناعي يحلل...';

  @override
  String get transcriptLabel => 'النص المسجل';

  @override
  String get voiceInputError => 'فشل الإدخال الصوتي. حاول مجدداً.';

  @override
  String get requiresInternet => 'الإدخال الصوتي يتطلب اتصال بالإنترنت';

  @override
  String get speakNow => 'تحدث الآن...';

  @override
  String get parsedItems => 'العناصر المستخرجة';

  @override
  String get total => 'المجموع';

  @override
  String get due => 'تاريخ الاستحقاق';

  @override
  String get acceptAndSave => 'قبول وحفظ';

  @override
  String get retryParsing => 'إعادة المحاولة';

  @override
  String get editTranscript => 'تعديل النص';

  @override
  String get parse => 'تحليل';

  @override
  String get noSpeechDetected => 'لم يتم اكتشاف كلام. يرجى المحاولة مرة أخرى.';

  @override
  String get parsedItemsReady => 'تمت معالجة الإدخال الصوتي بنجاح!';

  @override
  String itemsSummary(Object count, Object total) {
    return '$count عناصر • $total';
  }

  @override
  String get apiKeyNotConfigured =>
      'مفتاح API غير مكون. قم بالتشغيل باستخدام: --dart-define-from-file=dart_define_config.env';

  @override
  String get noInternet =>
      'لا يوجد اتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String listeningDuration(Object duration) {
    return 'جاري الاستماع $duration';
  }

  @override
  String get serverError => 'خطأ في الخادم. يرجى المحاولة لاحقاً.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get transcript => 'النص';

  @override
  String get reRecord => 'إعادة التسجيل';

  @override
  String get remove => 'إزالة';

  @override
  String get voiceCommand => 'أمر صوتي';

  @override
  String get customerMatch => 'مطابقة العميل';

  @override
  String get noMatchFound => 'لم يتم العثور على عميل مطابق';

  @override
  String get addNewCustomer => 'إضافة عميل جديد';

  @override
  String get confirmAndSave => 'تأكيد وحفظ';

  @override
  String get viewCustomer => 'عرض العميل';

  @override
  String get voiceCommandError => 'لم يتم فهم الأمر. حاول مرة أخرى.';

  @override
  String get recordPaymentAction => 'تسجيل دفعة';

  @override
  String get unknownAction => 'إجراء غير معروف';

  @override
  String get confirmPayment => 'تأكيد الدفعة';

  @override
  String get paymentSuccess => 'تم تسجيل الدفعة بنجاح';

  @override
  String get customerCreated => 'تم إنشاء العميل بنجاح';

  @override
  String get paymentAmount => 'مبلغ الدفعة';

  @override
  String get outstandingDebts => 'الديون المستحقة';

  @override
  String get amountExceedsRemaining => 'تم تعديل المبلغ حسب المتبقي';

  @override
  String maxPaymentIs(Object amount) {
    return 'الحد الأقصى للدفع: $amount';
  }

  @override
  String get debtDeleted => 'تم حذف الدين بنجاح';

  @override
  String get transactionHistory => 'سجل المعاملات';

  @override
  String get deleteDebtAction => 'حذف الدين';

  @override
  String get confirmDeleteVoice => 'تأكيد الحذف';

  @override
  String get noDebtsFound => 'لا توجد ديون';

  @override
  String get noTransactionHistory => 'لا توجد معاملات بعد';

  @override
  String get errorSaving => 'فشل الحفظ. حاول مرة أخرى.';

  @override
  String get debtDetails => 'تفاصيل الدين';

  @override
  String get originalAmount => 'المبلغ الأصلي';

  @override
  String get amountPaid => 'المبلغ المدفوع';

  @override
  String get remainingAmount => 'المتبقي';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get paymentHistory => 'سجل المدفوعات';

  @override
  String get noPaymentsYet => 'لا توجد مدفوعات مسجلة بعد';
}
