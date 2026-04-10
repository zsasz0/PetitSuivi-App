import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

/// Exhaustive medical and social history form for a single child.
///
/// This detailed multi-page view gathers required medical history and checks.
/// The resulting structured medical record JSON is eventually injected into 
/// the main registration API payload.

/// A multi-page form for entering a child's exhaustive medical and social history.
///
/// This widget uses a `PageView` to navigate through 5 sections of medical data.
/// It supports pre-filling fields via [initialData] (typically injected with
/// parent-derived data) and enforces strict validation rules before saving:
/// - **Required Fields**: All single-choice (radio-button-style) fields
///   must be answered before the user can save.
/// - **Mutual Exclusivity**: Certain multi-choice fields (like previous enrollment
///   or social behavior) enforce exclusivity for "none" or "normal" options.
/// - **Conditional Details**: Toggling certain Yes/No questions (like allergies or
///   medications) dynamically reveals text fields for further details.
class ChildMedicalRecordPage extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const ChildMedicalRecordPage({super.key, required this.initialData});

  @override
  State<ChildMedicalRecordPage> createState() => _ChildMedicalRecordPageState();
}

class _ChildMedicalRecordPageState extends State<ChildMedicalRecordPage> {
  final PageController _pageController = PageController();
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, bool> _checks = {};
  final Map<String, String> _singleChoice = {};
  final Map<String, Set<String>> _multiChoice = {};
  int _currentPage = 0;
  static const int _totalPages = 5;

  // Modern Theme Colors (Matching main registration)
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);
  static Color get _indigoAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF3F51B5)
      : const Color(0xFF6870FA);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  static const List<String> _textKeys = [
    // Section 1 – General
    'childFullName',
    'birthDatePlace',
    'nationality',
    'address',
    'institutionStudyDuration',
    'kinshipDetails',
    'fatherName',
    'fatherBirthYear',
    'fatherJob',
    'motherName',
    'motherBirthYear',
    'motherJob',
    'siblingsAliveBoys',
    'siblingsAliveGirls',
    'siblingsDeceasedBoys',
    'siblingsDeceasedGirls',
    'childOrder',
    'absenceFromStudy',
    'roomsCount',
    'healthSupervisingStructure',
    'familyDoctor',
    // Section 2 – Birth & Diseases
    'pregnancyHealthDetails',
    'deliveryDetails',
    'healthAtBirthDetails',
    'malformationsDetails',
    'diseaseOtherDetails',
    'healthConditionOtherDetails',
    'hospitalizationDetails',
    'surgeriesDetails',
    'hospitalAddress',
    // Section 3 – Conditional detail fields
    'allergyDetails',
    'medicationDetails',
    'treatmentDetails',
    // Section 5 – Additional info
    'socialAdditionalInfo',
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    final textData =
        (data['text'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final checksData =
        (data['checks'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final singleChoiceData =
        (data['singleChoice'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final multiChoiceData =
        (data['multiChoice'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    for (final key in _textKeys) {
      _textControllers[key] = TextEditingController(
        text: (textData[key] ?? data[key] ?? '').toString(),
      );
    }
    for (final entry in checksData.entries) {
      _checks[entry.key] = entry.value == true;
    }
    for (final entry in singleChoiceData.entries) {
      _singleChoice[entry.key] = (entry.value ?? '').toString();
    }
    for (final entry in multiChoiceData.entries) {
      final raw = entry.value;
      if (raw is List) {
        _multiChoice[entry.key] = raw.map((e) => e.toString()).toSet();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Required single-choice keys that must have a selection before saving
  static const List<String> _requiredSingleKeys = [
    'motherPregnancyHealth',
    'birthPlace',
    'birthTiming',
    'deliveryType',
    'healthAtBirth',
    'social_position_siblings',
    'social_lives_with',
    'social_family_relation',
    'social_eating',
    'social_sleep',
    'social_time_space',
  ];

  /// Validates required fields and returns the collected data to the caller.
  ///
  /// This method iterates over `_requiredSingleKeys` to ensure the user has
  /// selected an option for all mandatory single-choice questions. If any are
  /// missing, it displays an error `SnackBar` and halts the save process.
  /// If valid, it packages the text, checks, singleChoice, and multiChoice
  /// data into a map and pops the route.
  void _save() {
    // Validate required text fields
    final missingText = <String>[];
    final requiredTextConfigs = [
      {'key': 'childFullName', 'label': 'الاسم واللقب'},
      {'key': 'birthDatePlace', 'label': 'تاريخ ومكان الولادة'},
      {'key': 'nationality', 'label': 'الجنسية'},
      {'key': 'address', 'label': 'العنوان العائلي'},
    ];
    for (final config in requiredTextConfigs) {
      final key = config['key']!;
      final value = _textControllers[key]?.text.trim() ?? '';
      if (value.isEmpty) {
        missingText.add(config['label']!);
      }
    }
    if (missingText.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى ملء الحقول الإلزامية التالية: ${missingText.join('، ')}',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Validate required single-choice fields
    final missingSingle = <String>[];
    for (final key in _requiredSingleKeys) {
      if ((_singleChoice[key] ?? '').isEmpty) {
        missingSingle.add(key);
      }
    }
    if (missingSingle.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى الإجابة على جميع الأسئلة ذات الاختيار الواحد',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final text = <String, String>{};
    for (final entry in _textControllers.entries) {
      text[entry.key] = entry.value.text.trim();
    }

    final multiChoiceAsList = <String, List<String>>{};
    for (final entry in _multiChoice.entries) {
      multiChoiceAsList[entry.key] = entry.value.toList();
    }

    Navigator.pop<Map<String, dynamic>>(context, {
      'text': text,
      'checks': _checks,
      'singleChoice': _singleChoice,
      'multiChoice': multiChoiceAsList,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final pages = <Widget>[
      _buildPage(
        pageNumber: 1,
        title: 'إرشادات عامة',
        subtitle: 'الصفحة 1 من $_totalPages',
        content: _buildSection1(),
      ),
      _buildPage(
        pageNumber: 2,
        title: 'إرشادات عن الولادة والأمراض',
        subtitle: 'الصفحة 2 من $_totalPages',
        content: _buildSection2(),
      ),
      _buildPage(
        pageNumber: 3,
        title: 'الحالة الصحية الحالية للطفل',
        subtitle: 'الصفحة 3 من $_totalPages',
        content: _buildSection3(),
      ),
      _buildPage(
        pageNumber: 4,
        title: 'الوضع الاجتماعي والنفسي للطفل',
        subtitle: 'الصفحة 4 من $_totalPages',
        content: _buildSection4(),
      ),
      _buildPage(
        pageNumber: 5,
        title: 'معلومات إضافية',
        subtitle: 'الصفحة 5 من $_totalPages',
        content: _buildSection5(),
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _baseDark,
        appBar: AppBar(
          title: Text(
            'الملف الطبي للطفل',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              color: _lightText,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: _lightText),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  children: pages,
                ),
              ),
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalPages, (index) {
          final selected = _currentPage == index;
          final past = _currentPage > index;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              decoration: BoxDecoration(
                color: selected
                    ? _tealAccent
                    : (past
                          ? _tealAccent.withValues(alpha: 0.5)
                          : ThemeColors.glassBorder),
                borderRadius: BorderRadius.circular(12),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _tealAccent.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPage({
    required int pageNumber,
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: ListView(
        key: ValueKey<int>(pageNumber),
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _tealAccent.withValues(alpha: 0.8),
              fontFamily: AppTheme.fontName,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _lightText,
              fontFamily: AppTheme.fontName,
            ),
          ),
          const SizedBox(height: 24),
          content,
          const SizedBox(height: 40), // Space for bottom padding
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final isLast = _currentPage == _totalPages - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: _baseDark,
        boxShadow: [
          BoxShadow(
            color: _baseDark.withValues(alpha: 0.8),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: _goPrevious,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ThemeColors.glassBorderStrong),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'السابق',
                  style: TextStyle(
                    color: _lightText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            const Spacer(flex: 1),

          const SizedBox(width: 16),

          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLast ? _save : _goNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: _tealAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: _tealAccent.withValues(alpha: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLast ? 'حفظ الملف الطبي' : 'التالي',
                    style: TextStyle(
                      color: isLast ? _lightText : _baseDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLast
                        ? Icons.check_circle_outline
                        : Icons.arrow_forward_ios,
                    color: isLast ? _lightText : _baseDark,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goNext() {
    if (_currentPage >= _totalPages - 1) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _goPrevious() {
    if (_currentPage <= 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  // ──────────────────────────────────────────────
  // Section 1: إرشادات عامة
  // ──────────────────────────────────────────────
  Widget _buildSection1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _text('childFullName', 'اسم الطفل ولقبه', icon: Icons.person_outline),
        _text(
          'birthDatePlace',
          'تاريخ ومكان الولادة',
          icon: Icons.cake_outlined,
        ),
        _text('nationality', 'الجنسية', icon: Icons.flag_outlined),
        _text(
          'address',
          'العنوان',
          maxLines: 2,
          icon: Icons.location_on_outlined,
        ),
        _multi(
          key: 'previousEnrollment',
          title: 'هل كان الطفل مرسما؟',
          options: const ['بمحضنة', 'بروضة أخرى', 'بكتاب آخر', 'لا'],
          exclusiveOption: 'لا',
        ),
        _text('institutionStudyDuration', 'اسم المؤسسة، مدة الدراسة'),
        _yesNo('parentsKinship', 'هل هناك قرابة بين الأب والأم؟'),
        if (_checks['parentsKinship'] == true)
          _text('kinshipDetails', 'إن نعم، حددها'),

        _sectionHeader('معلومات الأب', Icons.man_outlined),
        _text('fatherName', 'اسم الأب'),
        _text(
          'fatherBirthYear',
          'سنة الولادة',
          keyboardType: TextInputType.number,
        ),
        _text('fatherJob', 'المهنة'),
        _yesNo('fatherAlive', 'هل هو على قيد الحياة؟'),
        _yesNo('fatherLivesWithFamily', 'يعيش مع أسرته'),
        _yesNo('fatherDivorced', 'مطلق'),
        _yesNo('fatherAbroad', 'مقيم بالخارج'),
        _yesNo('fatherAlcohol', 'هل يتعاطى الكحول'),
        _yesNo('fatherSmoking', 'السجائر'),

        _sectionHeader('معلومات الأم', Icons.woman_outlined),
        _text('motherName', 'اسم الأم'),
        _text(
          'motherBirthYear',
          'سنة الولادة',
          keyboardType: TextInputType.number,
        ),
        _text('motherJob', 'المهنة'),
        _yesNo('motherAlive', 'هل هي على قيد الحياة؟'),
        _yesNo('motherLivesWithFamily', 'تعيش مع أسرتها'),
        _yesNo('motherDivorced', 'مطلقة'),
        _yesNo('motherAbroad', 'مقيمة بالخارج'),
        _yesNo('motherAlcohol', 'هل تتعاطى الكحول'),
        _yesNo('motherSmoking', 'السجائر'),

        _sectionHeader('الإخوة والمسكن', Icons.home_outlined),
        _text(
          'siblingsAliveBoys',
          'الإخوة على قيد الحياة - ذكور',
          keyboardType: TextInputType.number,
        ),
        _text(
          'siblingsAliveGirls',
          'الإخوة على قيد الحياة - إناث',
          keyboardType: TextInputType.number,
        ),
        _text(
          'siblingsDeceasedBoys',
          'المتوفون - ذكور',
          keyboardType: TextInputType.number,
        ),
        _text(
          'siblingsDeceasedGirls',
          'المتوفون - إناث',
          keyboardType: TextInputType.number,
        ),
        _text('childOrder', 'ترتيب الولد', keyboardType: TextInputType.number),
        _text(
          'absenceFromStudy',
          'أيام الغياب',
          keyboardType: TextInputType.number,
        ),
        _text(
          'roomsCount',
          'عدد الغرف بالمنزل',
          keyboardType: TextInputType.number,
        ),
        _multi(
          key: 'waterSource',
          title: 'مصدر الماء',
          options: const [
            'حنفية في البيت',
            'حنفية عمومية',
            'بئر',
            'ماء معلب',
            'مصدر آخر',
          ],
        ),
        _text('healthSupervisingStructure', 'الهيكل الصحي'),
        _text(
          'familyDoctor',
          'طبيب العائلة (إن وجد)',
          icon: Icons.medical_services_outlined,
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Section 2: إرشادات عن الولادة والأمراض
  // ──────────────────────────────────────────────
  Widget _buildSection2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _single(
          key: 'motherPregnancyHealth',
          title: 'الحالة الصحية للأم أثناء الحمل',
          options: const ['عادية', 'مشاكل صحية'],
        ),
        if (_singleChoice['motherPregnancyHealth'] == 'مشاكل صحية')
          _text(
            'pregnancyHealthDetails',
            'إذا كان هناك مشاكل، اذكرها',
            maxLines: 2,
          ),
        _single(
          key: 'birthPlace',
          title: 'مكان الولادة',
          options: const ['بالمنزل', 'المستشفى', 'مصحة خاصة'],
        ),
        _single(
          key: 'birthTiming',
          title: 'توقيت الولادة',
          options: const ['في أوانها', 'قبل أوانها'],
        ),
        _single(
          key: 'deliveryType',
          title: 'نوع الولادة',
          options: const ['عادية', 'غير عادية'],
        ),
        if (_singleChoice['deliveryType'] == 'غير عادية')
          _text(
            'deliveryDetails',
            'إذا كانت غير عادية، اذكر التفاصيل',
            maxLines: 2,
          ),
        _single(
          key: 'healthAtBirth',
          title: 'الحالة الصحية للطفل عند الولادة',
          options: const ['عادية', 'غير عادية'],
        ),
        if (_singleChoice['healthAtBirth'] == 'غير عادية')
          _text(
            'healthAtBirthDetails',
            'إذا كانت غير عادية، اذكر التفاصيل',
            maxLines: 2,
          ),
        _yesNo('congenitalMalformations', 'هل توجد تشوهات خلقية؟'),
        if (_checks['congenitalMalformations'] == true)
          _text('malformationsDetails', 'إن نعم، اذكرها', maxLines: 2),

        _sectionHeader('تاريخ الأمراض', Icons.history_outlined),
        _multi(
          key: 'diseases',
          title: 'اختر الأمراض المزمنة إن وجدت',
          options: const [
            'الروماتيزم',
            'أمراض المفاصل',
            'أمراض الدم',
            'أمراض القلب',
            'أمراض الكلى',
            'أمراض الرئة',
            'الربو',
            'الجذبة',
            'الحساسية',
            'خلل في الغدد',
            'أمراض أخرى',
          ],
        ),
        if (_multiChoice['diseases']?.contains('أمراض أخرى') == true)
          _text(
            'diseaseOtherDetails',
            'أمراض مزمنة أخرى - اذكر التفاصيل',
            maxLines: 2,
          ),
        _multi(
          key: 'diseases2',
          title: 'أمراض الطفولة السابقة',
          options: const [
            'الحصبة',
            'الحميرة',
            'النكاف',
            'الجدري',
            'التهاب السحايا',
            'التشنج',
            'مرض السكري',
            'الصفراء',
            'حالة صحية أخرى',
          ],
        ),
        if (_multiChoice['diseases2']?.contains('حالة صحية أخرى') == true)
          _text(
            'healthConditionOtherDetails',
            'حالة صحية أخرى - اذكرها',
            maxLines: 2,
          ),
        _yesNo('hospitalized', 'هل سبق له الإقامة بالمستشفى؟'),
        if (_checks['hospitalized'] == true)
          _text('hospitalizationDetails', 'إن نعم، اذكر التفاصيل', maxLines: 2),
        _yesNo('surgeries', 'هل خضع لعمليات جراحية؟'),
        if (_checks['surgeries'] == true)
          _text('surgeriesDetails', 'إن نعم، اذكر التفاصيل', maxLines: 2),
        _text(
          'hospitalAddress',
          'عنوان المستشفى أو المصحة المعالجة',
          maxLines: 2,
          icon: Icons.local_hospital_outlined,
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Section 3: الحالة الصحية الحالية للطفل
  // ──────────────────────────────────────────────
  Widget _buildSection3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'الحالة الصحية للطفل حالياً',
          Icons.monitor_heart_outlined,
        ),
        _yesNo('current_allergy', 'هل يعاني الطفل من حساسية؟'),
        if (_checks['current_allergy'] == true)
          _text('allergyDetails', 'ما هي الحساسية؟', maxLines: 2),
        _yesNo('current_fracture_history', 'خلفيات للكسور؟'),
        _yesNo('current_surgery_history', 'خلفيات لعمليات جراحية؟'),
        _yesNo('current_motor_deficiency', 'قصور عضلي أو حركي؟'),
        _yesNo('current_visual_deficiency', 'قصور بصري؟'),
        _yesNo('current_hearing_deficiency', 'قصور سمعي؟'),
        _yesNo('current_speech_delay', 'تأخر في النطق؟'),
        _yesNo('current_balance_trouble', 'فقدان التوازن أو اضطراب المشي؟'),
        _yesNo('current_headache', 'صداع مزمن؟'),
        _yesNo('current_ear_pain', 'آلام أو سيلان في الأذن؟'),
        _yesNo('current_stomach_pain', 'آلام في البطن والمعدة؟'),
        _yesNo('current_anemia', 'فقر الدم؟'),
        _yesNo('current_breathing_difficulty', 'صعوبات في التنفس؟'),
        _yesNo('current_sphincter_trouble', 'اضطرابات في المثانة؟'),
        _yesNo('current_other_health_issue', 'مشاكل صحية أخرى؟'),
        _yesNo('current_takes_medications', 'هل يتناول حالياً أدوية؟'),
        if (_checks['current_takes_medications'] == true)
          _text('medicationDetails', 'ما هي الأدوية؟', maxLines: 2),
        _yesNo(
          'current_under_treatment',
          'هل يتلقى حالياً علاجاً أو إشرافاً طبياً؟',
        ),
        if (_checks['current_under_treatment'] == true)
          _text('treatmentDetails', 'ما نوع العلاج؟', maxLines: 2),

        _sectionHeader(
          'الحالة الصحية للعائلة والأقارب',
          Icons.family_restroom_outlined,
        ),
        _yesNo('family_diabetes', 'السكري'),
        _yesNo('family_hypertension', 'ضغط الدم'),
        _yesNo('family_anemia', 'فقر الدم'),
        _yesNo('family_allergy', 'حساسية'),
        _yesNo('family_deafness', 'الصمم'),
        _yesNo('family_genetic', 'مرض وراثي'),
        _yesNo('family_mental_delay', 'تأخر ذهني'),
        _yesNo('family_congenital', 'مرض خلقي'),
        _yesNo('family_psychiatric', 'مرض نفسي'),
        _yesNo('family_obesity', 'السمنة'),
        _yesNo('family_mutism', 'البكم'),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Section 4: الوضع الاجتماعي والنفسي للطفل
  // ──────────────────────────────────────────────
  Widget _buildSection4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _single(
          key: 'social_position_siblings',
          title: 'وضعية الطفل بين الإخوة',
          options: const ['وحيد', 'الأكبر', 'الأوسط', 'الأصغر'],
        ),
        _single(
          key: 'social_lives_with',
          title: 'يقيم الطفل عادة مع',
          options: const ['والده', 'والدته', 'كلا الوالدين', 'شخص آخر'],
        ),
        _single(
          key: 'social_family_relation',
          title: 'علاقة الطفل مع العائلة',
          options: const ['عادية', 'جيدة', 'صعبة'],
        ),
        _multi(
          key: 'social_behavior',
          title: 'السلوك العام للطفل',
          options: const [
            'عادي',
            'سريع الانفعال',
            'عدواني',
            'خجول',
            'كثير الحركة',
          ],
          exclusiveOption: 'عادي',
        ),
        _single(
          key: 'social_eating',
          title: 'طبيعة تناول الأكل',
          options: const ['جيد', 'ضعيف', 'يرفض الأكل'],
        ),
        _single(
          key: 'social_sleep',
          title: 'طبيعة النوم',
          options: const ['جيد', 'قلق', 'كوابيس'],
        ),
        _single(
          key: 'social_time_space',
          title: 'النظام الزمني والمكاني',
          options: const ['طبيعي', 'غير منظم'],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Section 5: معلومات إضافية تفيد الطبيب المدرسي
  // ──────────────────────────────────────────────
  Widget _buildSection5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _text(
          'socialAdditionalInfo',
          'معلومات، ملاحظات، أو توصيات خاصة تعتقد أنها قد تفيد الطبيب المدرسي أو المشرفين...',
          maxLines: 8,
          icon: Icons.notes_outlined,
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Reusable widgets
  // ──────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: _indigoAccent),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _indigoAccent,
              fontFamily: AppTheme.fontName,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Divider(color: _indigoAccent.withValues(alpha: 0.3))),
        ],
      ),
    );
  }

  Widget _text(
    String key,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    final controller = _textControllers.putIfAbsent(
      key,
      () => TextEditingController(),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.glassBorderSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.glassBorder, width: 1),
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            color: _lightText,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontFamily: AppTheme.fontName,
              color: _mutedText.withValues(alpha: 0.8),
            ),
            suffixIcon: icon != null ? Icon(icon, color: _mutedText) : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          cursorColor: _tealAccent,
        ),
      ),
    );
  }

  Widget _yesNo(String key, String title) {
    final value = _checks[key] ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () => setState(() => _checks[key] = !value),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: value
                ? _tealAccent.withValues(alpha: 0.1)
                : ThemeColors.glassBackgroundSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value ? _tealAccent : ThemeColors.glassBorderSubtle,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: value ? _lightText : _mutedText,
                    fontSize: 15,
                    fontFamily: AppTheme.fontName,
                    fontWeight: value ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 48,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: value ? _tealAccent : ThemeColors.glassBorder,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      // For RTL, true typically moves the circle to the left.
                      // Wait, let's keep it visually logical:
                      right: value ? 26 : 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _baseDark,
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColors.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // this is a widget to show single choice options
  Widget _single({
    required String key,
    required String title,
    required List<String> options,
  }) {
    final selected = _singleChoice[key];
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _lightText,
              fontSize: 16,
              fontFamily: AppTheme.fontName,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: options.map((option) {
              final isSelected = selected == option;
              return GestureDetector(
                onTap: () => setState(() => _singleChoice[key] = option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _tealAccent.withValues(alpha: 0.15)
                        : ThemeColors.glassBorderSubtle,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? _tealAccent : ThemeColors.glassBorder,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? _tealAccent : _mutedText,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontFamily: AppTheme.fontName,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Builds a multi-choice checkbox group.
  ///
  /// [key] is the data map key. [title] is the question text. [options] is the
  /// list of available checkbox labels.
  ///
  /// If [exclusiveOption] is provided (e.g., 'لا' or 'عادي'), selecting that
  /// option will automatically deselect all other options in the group. Conversely,
  /// selecting any other option will automatically deselect the [exclusiveOption].
  Widget _multi({
    required String key,
    required String title,
    required List<String> options,
    String? exclusiveOption,
  }) {
    final selected = _multiChoice.putIfAbsent(key, () => <String>{});
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _lightText,
              fontSize: 16,
              fontFamily: AppTheme.fontName,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: options.map((option) {
              final isSelected = selected.contains(option);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selected.remove(option);
                    } else {
                      // Mutual exclusivity logic
                      if (exclusiveOption != null) {
                        if (option == exclusiveOption) {
                          // Selecting the exclusive option clears all others
                          selected.clear();
                          selected.add(option);
                        } else {
                          // Selecting a non-exclusive option removes the exclusive one
                          selected.remove(exclusiveOption);
                          selected.add(option);
                        }
                      } else {
                        selected.add(option);
                      }
                    }
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _indigoAccent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? _indigoAccent
                                : ThemeColors.glassBorderMedium,
                          ),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, size: 16, color: _lightText)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? _lightText : _mutedText,
                            fontSize: 15,
                            fontFamily: AppTheme.fontName,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
