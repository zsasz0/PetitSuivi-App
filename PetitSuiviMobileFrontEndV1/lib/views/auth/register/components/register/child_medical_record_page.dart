import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';
import '../../themes/register_theme.dart';

/// Exhaustive medical and social history form for a single child.
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

  static const List<String> _textKeys = [
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
    'pregnancyHealthDetails',
    'deliveryDetails',
    'healthAtBirthDetails',
    'malformationsDetails',
    'diseaseOtherDetails',
    'healthConditionOtherDetails',
    'hospitalizationDetails',
    'surgeriesDetails',
    'hospitalAddress',
    'allergyDetails',
    'medicationDetails',
    'treatmentDetails',
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

  void _save() {
    final missingText = <String>[];
    final requiredTextConfigs = [
      {'key': 'childFullName', 'label': 'الاسم واللقب / Nom & Prénom'},
      {'key': 'birthDatePlace', 'label': 'الولادة / Naissance (Date & Lieu)'},
      {'key': 'nationality', 'label': 'الجنسية / Nationalité'},
      {'key': 'address', 'label': 'العنوان / Adresse'},
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
            'يرجى ملء الحقول الإلزامية التالية / Veuillez remplir les champs obligatoires suivants : ${missingText.join('، ')}',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

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
            'يرجى الإجابة على جميع الأسئلة ذات الاختيار الواحد / Veuillez répondre à toutes les questions à choix unique',
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
        title: 'إرشادات عامة / Informations générales',
        subtitle: 'الصفحة / Page 1 من/sur $_totalPages',
        content: _buildSection1(),
      ),
      _buildPage(
        pageNumber: 2,
        title:
            'إرشادات عن الولادة والأمراض / Informations sur la naissance et les maladies',
        subtitle: 'الصفحة / Page 2 من/sur $_totalPages',
        content: _buildSection2(),
      ),
      _buildPage(
        pageNumber: 3,
        title:
            'الحالة الصحية الحالية للطفل / État de santé actuel de l\'enfant',
        subtitle: 'الصفحة / Page 3 من/sur $_totalPages',
        content: _buildSection3(),
      ),
      _buildPage(
        pageNumber: 4,
        title:
            'الوضع الاجتماعي والنفسي للطفل / Situation sociale et psychologique',
        subtitle: 'الصفحة / Page 4 من/sur $_totalPages',
        content: _buildSection4(),
      ),
      _buildPage(
        pageNumber: 5,
        title: 'معلومات إضافية / Informations supplémentaires',
        subtitle: 'الصفحة / Page 5 من/sur $_totalPages',
        content: _buildSection5(),
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RegisterTheme.baseDark,
        appBar: AppBar(
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'الملف الطبي / Dossier médical',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.bold,
                color: RegisterTheme.lightText,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: RegisterTheme.lightText),
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
                    ? RegisterTheme.tealAccent
                    : (past
                          ? RegisterTheme.tealAccent.withValues(alpha: 0.5)
                          : RegisterTheme.glassBorder),
                borderRadius: BorderRadius.circular(12),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: RegisterTheme.tealAccent.withValues(
                            alpha: 0.4,
                          ),
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
              color: RegisterTheme.tealAccent.withValues(alpha: 0.8),
              fontFamily: AppTheme.fontName,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: RegisterTheme.lightText,
              fontFamily: AppTheme.fontName,
            ),
          ),
          const SizedBox(height: 24),
          content,
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final isLast = _currentPage == _totalPages - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: RegisterTheme.baseDark,
        boxShadow: [
          BoxShadow(
            color: RegisterTheme.baseDark.withValues(alpha: 0.8),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              flex: 3,
              child: OutlinedButton(
                onPressed: _goPrevious,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: RegisterTheme.glassBorder),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'السابق / Précédent',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: RegisterTheme.lightText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            const Spacer(flex: 3),

          const SizedBox(width: 16),

          Expanded(
            flex: 4,
            child: ElevatedButton(
              onPressed: isLast ? _save : _goNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: RegisterTheme.tealAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: RegisterTheme.tealAccent.withValues(alpha: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      isLast ? 'حفظ / Enregistrer' : 'التالي / Suivant',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isLast
                            ? RegisterTheme.lightText
                            : RegisterTheme.baseDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLast
                        ? Icons.check_circle_outline
                        : Icons.arrow_forward_ios,
                    color: isLast
                        ? RegisterTheme.lightText
                        : RegisterTheme.baseDark,
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

  Widget _buildSection1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _text(
          'childFullName',
          'الاسم واللقب / Nom & Prénom',
          icon: Icons.person_outline,
        ),
        _text(
          'birthDatePlace',
          'الولادة / Naissance',
          icon: Icons.cake_outlined,
        ),
        _text(
          'nationality',
          'الجنسية / Nationalité',
          icon: Icons.flag_outlined,
        ),
        _text(
          'address',
          'العنوان / Adresse',
          maxLines: 2,
          icon: Icons.location_on_outlined,
        ),
        _multi(
          key: 'previousEnrollment',
          title: 'هل كان الطفل مرسما؟ / L\'enfant était-il inscrit avant ?',
          options: const [
            'بمحضنة / Crèche',
            'بروضة أخرى / Autre jardin d\'enfants',
            'بكتاب آخر / École coranique',
            'لا / Non',
          ],
          exclusiveOption: 'لا / Non',
        ),
        _text(
          'institutionStudyDuration',
          'المؤسسة والمدة / Établissement & Durée',
        ),
        _yesNo(
          'parentsKinship',
          'هل هناك قرابة بين الأب والأم؟ / Lien de parenté entre les parents ?',
        ),
        if (_checks['parentsKinship'] == true)
          _text('kinshipDetails', 'إن نعم، حددها / Si oui, précisez'),

        _sectionHeader('الأب / Père', Icons.man_outlined),
        _text('fatherName', 'اسم الأب / Nom du père'),
        _text(
          'fatherBirthYear',
          'سنة الولادة / Année de naissance',
          keyboardType: TextInputType.number,
        ),
        _text('fatherJob', 'المهنة / Profession'),
        _yesNo('fatherAlive', 'هل هو على قيد الحياة؟ / Est-il en vie ?'),
        _yesNo('fatherLivesWithFamily', 'يعيش مع أسرته / Vit avec sa famille'),
        _yesNo('fatherDivorced', 'مطلق / Divorcé'),
        _yesNo('fatherAbroad', 'مقيم بالخارج / Réside à l\'étranger'),
        _yesNo('fatherAlcohol', 'هل يتعاطى الكحول / Consomme de l\'alcool'),
        _yesNo('fatherSmoking', 'السجائر / Fumeur'),

        _sectionHeader('الأم / Mère', Icons.woman_outlined),
        _text('motherName', 'اسم الأم / Nom de la mère'),
        _text(
          'motherBirthYear',
          'سنة الولادة / Année de naissance',
          keyboardType: TextInputType.number,
        ),
        _text('motherJob', 'المهنة / Profession'),
        _yesNo('motherAlive', 'هل هي على قيد الحياة؟ / Est-elle en vie ?'),
        _yesNo('motherLivesWithFamily', 'تعيش مع أسرتها / Vit avec sa famille'),
        _yesNo('motherDivorced', 'مطلقة / Divorcée'),
        _yesNo('motherAbroad', 'مقيمة بالخارج / Réside à l\'étranger'),
        _yesNo('motherAlcohol', 'هل يتعاطى الكحول / Consomme de l\'alcool'),
        _yesNo('motherSmoking', 'السجائر / Fumeuse'),

        _sectionHeader(
          'الإخوة والسكن / Fratrie et domicile',
          Icons.home_outlined,
        ),
        _text(
          'siblingsAliveBoys',
          'إخوة ذكور / Frères en vie',
          keyboardType: TextInputType.number,
        ),
        _text(
          'siblingsAliveGirls',
          'أخوات إناث / Sœurs en vie',
          keyboardType: TextInputType.number,
        ),
        _text(
          'siblingsDeceasedBoys',
          'إخوة متوفون / Frères décédés',
          keyboardType: TextInputType.number,
        ),
        _text(
          'siblingsDeceasedGirls',
          'أخوات متوفيات / Sœurs décédées',
          keyboardType: TextInputType.number,
        ),
        _text(
          'childOrder',
          'ترتيب الطفل / Ordre de l\'enfant',
          keyboardType: TextInputType.number,
        ),
        _text(
          'absenceFromStudy',
          'أيام الغياب / Jours d\'absence',
          keyboardType: TextInputType.number,
        ),
        _text(
          'roomsCount',
          'عدد الغرف / Nbr. chambres',
          keyboardType: TextInputType.number,
        ),
        _multi(
          key: 'waterSource',
          title: 'مصدر الماء / Source d\'eau',
          options: const [
            'حنفية في البيت / Robinet à la maison',
            'حنفية عمومية / Robinet public',
            'بئر / Puits',
            'ماء معلب / Eau en bouteille',
            'مصدر آخر / Autre source',
          ],
        ),
        _text(
          'healthSupervisingStructure',
          'الهيكل الصحي / Structure de santé',
        ),
        _text(
          'familyDoctor',
          'طبيب العائلة / Médecin de famille',
          icon: Icons.medical_services_outlined,
        ),
      ],
    );
  }

  Widget _buildSection2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _single(
          key: 'motherPregnancyHealth',
          title:
              'الحالة الصحية للأم أثناء الحمل / Santé de la mère pendant la grossesse',
          options: const ['عادية / Normale', 'مشاكل صحية / Problèmes de santé'],
        ),
        if (_singleChoice['motherPregnancyHealth'] ==
            'مشاكل صحية / Problèmes de santé')
          _text(
            'pregnancyHealthDetails',
            'المشاكل الصحية / Préciser les problèmes',
            maxLines: 2,
          ),
        _single(
          key: 'birthPlace',
          title: 'مكان الولادة / Lieu de naissance',
          options: const [
            'بالمنزل / À domicile',
            'المستشفى / Hôpital',
            'مصحة خاصة / Clinique privée',
          ],
        ),
        _single(
          key: 'birthTiming',
          title: 'توقيت الولادة / Moment de l\'accouchement',
          options: const ['في أوانها / À terme', 'قبل أوانها / Prématuré'],
        ),
        _single(
          key: 'deliveryType',
          title: 'نوع الولادة / Type d\'accouchement',
          options: const ['عادية / Normal', 'غير عادية / Compliqué'],
        ),
        if (_singleChoice['deliveryType'] == 'غير عادية / Compliqué')
          _text(
            'deliveryDetails',
            'تفاصيل الولادة / Préciser les détails',
            maxLines: 2,
          ),
        _single(
          key: 'healthAtBirth',
          title:
              'الحالة الصحية للطفل عند الولادة / État de santé à la naissance',
          options: const ['عادية / Normal', 'غير عادية / Anormal'],
        ),
        if (_singleChoice['healthAtBirth'] == 'غير عادية / Anormal')
          _text(
            'healthAtBirthDetails',
            'تفاصيل الحالة / Préciser les détails',
            maxLines: 2,
          ),
        _yesNo(
          'congenitalMalformations',
          'هل توجد تشوهات خلقية؟ / Malformations congénitales ?',
        ),
        if (_checks['congenitalMalformations'] == true)
          _text(
            'malformationsDetails',
            'التشوهات / Préciser les malformations',
            maxLines: 2,
          ),

        _sectionHeader('الأمراض / Historique', Icons.history_outlined),
        _multi(
          key: 'diseases',
          title: 'اختر الأمراض المزمنة إن وجدت / Maladies chroniques',
          options: const [
            'الروماتيزم / Rhumatisme',
            'أمراض المفاصل / Maladies articulaires',
            'أمراض الدم / Maladies du sang',
            'أمراض القلب / Maladies cardiaques',
            'أمراض الكلى / Maladies rénales',
            'أمراض الرئة / Maladies pulmonaires',
            'الربو / Asthme',
            'الجذبة / Épilepsie/Convulsions',
            'الحساسية / Allergies',
            'خلل في الغدد / Troubles glandulaires',
            'أمراض أخرى / Autres maladies',
          ],
        ),
        if (_multiChoice['diseases']?.contains(
              'أمراض أخرى / Autres maladies',
            ) ==
            true)
          _text(
            'diseaseOtherDetails',
            'أمراض أخرى / Autres maladies',
            maxLines: 2,
          ),
        _multi(
          key: 'diseases2',
          title: 'أمراض الطفولة السابقة / Maladies infantiles passées',
          options: const [
            'الحصبة / Rougeole',
            'الحميرة / Rubéole',
            'النكاف / Oreillons',
            'الجدري / Varicelle',
            'التهاب السحايا / Méningite',
            'التشنج / Spasmes',
            'مرض السكري / Diabète',
            'الصفراء / Jaunisse',
            'حالة صحية أخرى / Autre condition',
          ],
        ),
        if (_multiChoice['diseases2']?.contains(
              'حالة صحية أخرى / Autre condition',
            ) ==
            true)
          _text(
            'healthConditionOtherDetails',
            'حالة أخرى / Autre condition',
            maxLines: 2,
          ),
        _yesNo(
          'hospitalized',
          'هل سبق له الإقامة بالمستشفى؟ / Déjà hospitalisé ?',
        ),
        if (_checks['hospitalized'] == true)
          _text(
            'hospitalizationDetails',
            'تفاصيل الإقامة / Détails d\'hospitalisation',
            maxLines: 2,
          ),
        _yesNo(
          'surgeries',
          'هل خضع لعمليات جراحية؟ / Interventions chirurgicales ?',
        ),
        if (_checks['surgeries'] == true)
          _text(
            'surgeriesDetails',
            'تفاصيل العمليات / Détails des chirurgies',
            maxLines: 2,
          ),
        _text(
          'hospitalAddress',
          'عنوان المستشفى / Adresse de l\'hôpital',
          maxLines: 2,
          icon: Icons.local_hospital_outlined,
        ),
      ],
    );
  }

  Widget _buildSection3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'الحالة الصحية / Santé actuelle',
          Icons.monitor_heart_outlined,
        ),
        _yesNo('current_allergy', 'هل يعاني الطفل من حساسية؟ / Allergies ?'),
        if (_checks['current_allergy'] == true)
          _text(
            'allergyDetails',
            'تفاصيل الحساسية / Détails des allergies',
            maxLines: 2,
          ),
        _yesNo(
          'current_fracture_history',
          'خلفيات للكسور؟ / Antécédents de fractures ?',
        ),
        _yesNo(
          'current_surgery_history',
          'خلفيات لعمليات جراحية؟ / Antécédents chirurgicaux ?',
        ),
        _yesNo(
          'current_motor_deficiency',
          'قصور عضلي أو حركي؟ / Déficience motrice ?',
        ),
        _yesNo(
          'current_visual_deficiency',
          'قصور بصري؟ / Déficience visuelle ?',
        ),
        _yesNo(
          'current_hearing_deficiency',
          'قصور سمعي؟ / Déficience auditive ?',
        ),
        _yesNo('current_speech_delay', 'تأخر في النطق؟ / Retard de parole ?'),
        _yesNo(
          'current_balance_trouble',
          'فقدان التوازن أو اضطراب المشي؟ / Troubles de l\'équilibre ?',
        ),
        _yesNo('current_headache', 'صداع مزمن؟ / Maux de tête chroniques ?'),
        _yesNo(
          'current_ear_pain',
          'آلام أو سيلان في الأذن؟ / Douleurs aux oreilles ?',
        ),
        _yesNo(
          'current_stomach_pain',
          'آلام في البطن والمعدة؟ / Maux d\'estomac/ventre ?',
        ),
        _yesNo('current_anemia', 'فقر الدم؟ / Anémie ?'),
        _yesNo(
          'current_breathing_difficulty',
          'صعوبات في التنفس؟ / Difficultés respiratoires ?',
        ),
        _yesNo(
          'current_sphincter_trouble',
          'اضطرابات في المثانة؟ / Troubles sphinctériens ?',
        ),
        _yesNo(
          'current_other_health_issue',
          'مشاكل صحية أخرى؟ / Autres problèmes de santé ?',
        ),
        _yesNo(
          'current_takes_medications',
          'هل يتناول حالياً أدوية؟ / Prend des médicaments ?',
        ),
        if (_checks['current_takes_medications'] == true)
          _text(
            'medicationDetails',
            'أسماء الأدوية / Noms des médicaments',
            maxLines: 2,
          ),
        _yesNo(
          'current_under_treatment',
          'هل يتلقى حالياً علاجاً أو إشرافاً طبياً؟ / Sous traitement ou suivi médical ?',
        ),
        if (_checks['current_under_treatment'] == true)
          _text(
            'treatmentDetails',
            'نوع العلاج / Quel traitement ?',
            maxLines: 2,
          ),

        _sectionHeader(
          'صحة العائلة / Santé familiale',
          Icons.family_restroom_outlined,
        ),
        _yesNo('family_diabetes', 'السكري / Diabète'),
        _yesNo('family_hypertension', 'ضغط الدم / Hypertension'),
        _yesNo('family_anemia', 'فقر الدم / Anémie'),
        _yesNo('family_allergy', 'حساسية / Allergies'),
        _yesNo('family_deafness', 'الصمم / Surdité'),
        _yesNo('family_genetic', 'مرض وراثي / Maladie génétique'),
        _yesNo('family_mental_delay', 'تأخر ذهني / Retard mental'),
        _yesNo('family_congenital', 'مرض خلقي / Maladie congénitale'),
        _yesNo('family_psychiatric', 'مرض نفسي / Maladie psychiatrique'),
        _yesNo('family_obesity', 'السمنة / Obésité'),
        _yesNo('family_mutism', 'البكم / Mutisme'),
      ],
    );
  }

  Widget _buildSection4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _single(
          key: 'social_position_siblings',
          title: 'وضعية الطفل بين الإخوة / Position parmi les frères et sœurs',
          options: const [
            'وحيد / Unique',
            'الأكبر / Aîné',
            'الأوسط / Cadet',
            'الأصغر / Benjamin',
          ],
        ),
        _single(
          key: 'social_lives_with',
          title: 'يقيم الطفل عادة مع / L\'enfant vit avec',
          options: const [
            'والده / Son père',
            'والدته / Sa mère',
            'كلا الوالدين / Ses deux parents',
            'شخص آخر / Autre personne',
          ],
        ),
        _single(
          key: 'social_family_relation',
          title: 'علاقة الطفل مع العائلة / Relation avec la famille',
          options: const [
            'عادية / Normale',
            'جيدة / Bonne',
            'صعبة / Difficile',
          ],
        ),
        _multi(
          key: 'social_behavior',
          title: 'السلوك العام للطفل / Comportement général',
          options: const [
            'عادي / Normal',
            'سريع الانفعال / Irritable',
            'عدواني / Agressif',
            'خجول / Timide',
            'كثير الحركة / Hyperactif',
          ],
          exclusiveOption: 'عادي / Normal',
        ),
        _single(
          key: 'social_eating',
          title: 'طبيعة تناول الأكل / Alimentation',
          options: const [
            'جيد / Bonne',
            'ضعيف / Faible',
            'يرفض الأكل / Refuse de manger',
          ],
        ),
        _single(
          key: 'social_sleep',
          title: 'طبيعة النوم / Sommeil',
          options: const ['جيد / Bon', 'قلق / Agité', 'كوابيس / Cauchemars'],
        ),
        _single(
          key: 'social_time_space',
          title: 'النظام الزمني والمكاني / Repères spatio-temporels',
          options: const ['طبيعي / Normaux', 'غير منظم / Désorganisés'],
        ),
      ],
    );
  }

  Widget _buildSection5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _text(
          'socialAdditionalInfo',
          'ملاحظات إضافية / Remarques supplémentaires',
          maxLines: 8,
          icon: Icons.notes_outlined,
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: RegisterTheme.accentColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: RegisterTheme.accentColor,
                fontFamily: AppTheme.fontName,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Divider(
              color: RegisterTheme.accentColor.withValues(alpha: 0.3),
            ),
          ),
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
          color: RegisterTheme.glassBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: RegisterTheme.glassBorder, width: 1),
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            color: RegisterTheme.lightText,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontFamily: AppTheme.fontName,
              color: RegisterTheme.mutedText.withValues(alpha: 0.8),
            ),
            suffixIcon: icon != null
                ? Icon(icon, color: RegisterTheme.mutedText)
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          cursorColor: RegisterTheme.tealAccent,
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
                ? RegisterTheme.tealAccent.withValues(alpha: 0.1)
                : RegisterTheme.glassBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value
                  ? RegisterTheme.tealAccent
                  : RegisterTheme.glassBackground,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: value
                        ? RegisterTheme.lightText
                        : RegisterTheme.mutedText,
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
                  color: value
                      ? RegisterTheme.tealAccent
                      : RegisterTheme.glassBorder,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      right: value ? 26 : 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: RegisterTheme.baseDark,
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
              color: RegisterTheme.lightText,
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
                        ? RegisterTheme.tealAccent.withValues(alpha: 0.15)
                        : RegisterTheme.glassBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? RegisterTheme.tealAccent
                          : RegisterTheme.glassBorder,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected
                          ? RegisterTheme.tealAccent
                          : RegisterTheme.mutedText,
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
              color: RegisterTheme.lightText,
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
                      if (exclusiveOption != null) {
                        if (option == exclusiveOption) {
                          selected.clear();
                          selected.add(option);
                        } else {
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
                              ? RegisterTheme.accentColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? RegisterTheme.accentColor
                                : RegisterTheme.glassBorder,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: RegisterTheme.lightText,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected
                                ? RegisterTheme.lightText
                                : RegisterTheme.mutedText,
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
