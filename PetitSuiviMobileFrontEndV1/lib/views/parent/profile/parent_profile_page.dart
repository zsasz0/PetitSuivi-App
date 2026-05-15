import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/auth/login/login_page.dart';
import 'package:newv/views/parent/profile/components/common/child_profile_view_page.dart';

// Modular Imports
import 'package:newv/views/parent/profile/themes/profile_theme.dart';
import 'package:newv/views/parent/profile/controllers/profile_controller.dart';
import 'package:newv/views/parent/profile/components/profile/profile_header.dart';
import 'package:newv/views/parent/profile/components/profile/info_card.dart';
import 'package:newv/views/parent/profile/components/profile/children_section.dart';
import 'package:newv/views/parent/profile/components/profile/action_buttons.dart';
import 'package:newv/views/parent/profile/components/profile/change_password_dialog.dart';
import 'package:newv/views/parent/profile/components/profile/enrollment_modal.dart';

class ParentProfilePage extends StatefulWidget {
  const ParentProfilePage({super.key});

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  late final ProfileController _controller;

  final List<Map<String, dynamic>> _children = [];
  List<String> _paymentMethods = ['oneShot', 'monthlyPartial'];
  bool _isLoadingChildren = true;
  int _lastSeenSyncVersion = -1;

  double _baseFee = 1200.0;
  bool _loadingPricing = true;
  bool _inscriptionsOpen = true;
  Map<String, double> _mealPlanFees = {
    'Mon enfant prend le déjeuner et le goûter': 350.0,
    'Mon enfant prend seulement le déjeuner': 250.0,
    'Mon enfant prend seulement le goûter': 120.0,
    'Mon enfant ne mange pas à l\'école (le parent le récupère puis le ramène)':
        0.0,
  };

  static const List<String> _mealPlanOptions = [
    'Mon enfant prend le déjeuner et le goûter',
    'Mon enfant prend seulement le déjeuner',
    'Mon enfant prend seulement le goûter',
    'Mon enfant ne mange pas à l\'école (le parent le récupère puis le ramène)',
  ];
  static const List<String> _inscriptionTypes = [
    'Préscolaire (التحضيري)',
    'Maternelle (التمهيدي)',
  ];

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(context);
    _initData();
  }

  Future<void> _initData() async {
    await Future.wait([
      _controller.loadPaymentMethods(
        defaultPaymentMethods: _paymentMethods,
        setPaymentMethods: (methods) =>
            setState(() => _paymentMethods = methods),
      ),
      _controller.loadPricingParameters(
        mealPlanOptions: _mealPlanOptions,
        setLoading: (val) => setState(() => _loadingPricing = val),
        setInscriptionsOpen: (val) => setState(() => _inscriptionsOpen = val),
        setBaseFee: (val) => setState(() => _baseFee = val),
        setMealPlanFees: (val) =>
            setState(() => _mealPlanFees = {..._mealPlanFees, ...val}),
      ),
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentVersion = context.watch<AuthSession>().syncVersion;
    if (currentVersion != _lastSeenSyncVersion) {
      _lastSeenSyncVersion = currentVersion;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadChildren());
    }
  }

  Future<void> _loadChildren() async {
    await _controller.loadChildren(
      setLoading: (val) => setState(() => _isLoadingChildren = val),
      setChildren: (val) => setState(() {
        _children.clear();
        _children.addAll(val);
      }),
    );
  }

  double _calculateTotalAmount(String mealPlan) {
    return _baseFee + (_mealPlanFees[mealPlan] ?? 0.0);
  }

  String _paymentMethodLabel(String method) {
    switch (method) {
      case 'oneShot':
        return 'Annuel (En une seule fois)';
      case 'monthlyPartial':
        return 'Mensuel (Chaque mois)';
      default:
        return method;
    }
  }

  String _shortMealPlanLabel(String plan, {double? price}) {
    String label;
    if (plan.contains('récupère puis le ramène')) {
      label = 'Pas de cantine (Maison)';
    } else if (plan.contains('déjeuner et le goûter')) {
      label = 'Déjeuner + Goûter';
    } else if (plan.contains('seulement le déjeuner')) {
      label = 'Uniquement Déjeuner';
    } else if (plan.contains('seulement le goûter')) {
      label = 'Uniquement Goûter';
    } else {
      label = plan;
    }
    if (price != null && price > 0) {
      label += ' (${price.toStringAsFixed(0)} TND)';
    } else if (price != null && price == 0) {
      label += ' (Gratuit)';
    }
    return label;
  }

  void _onChildTap(Map<String, dynamic> child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildProfileViewPage(
          childData: child,
          inscriptionsOpen: _inscriptionsOpen,
          onRefresh: () async {
            await _initData();
            await _loadChildren();
          },
        ),
      ),
    );
  }

  void _onInscribeChild() {
    showDialog(
      context: context,
      builder: (context) => EnrollmentModal(
        inscriptionTypes: _inscriptionTypes,
        paymentMethods: _paymentMethods,
        mealPlanOptions: _mealPlanOptions,
        mealPlanFees: _mealPlanFees,
        loadingPricing: _loadingPricing,
        calculateTotalAmount: _calculateTotalAmount,
        paymentMethodLabel: _paymentMethodLabel,
        shortMealPlanLabel: _shortMealPlanLabel,
        onCreateInscription: _controller.createChildInscription,
      ),
    );
  }

  void _onChangePassword() {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(
        onSubmit: (pwd, messenger) =>
            _controller.changePassword(newPassword: pwd, messenger: messenger),
      ),
    );
  }

  void _onLogout() {
    context.read<AuthSession>().clear();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final session = context.watch<AuthSession>();

    return Container(
      color: ProfileTheme.baseDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Mon Profil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: ProfileTheme.lightText,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _initData();
            await _loadChildren();
          },
          color: ProfileTheme.tealAccent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 12,
              bottom: 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeader(session: session),
                const SizedBox(height: 32),
                InfoCard(session: session),
                const SizedBox(height: 24),
                ChildrenSection(
                  isLoading: _isLoadingChildren,
                  children: _children,
                  onChildTap: _onChildTap,
                  onInscribeChild: _onInscribeChild,
                  inscriptionsOpen: _inscriptionsOpen,
                  shortMealPlanLabel: _shortMealPlanLabel,
                ),
                const SizedBox(height: 32),
                ActionButtons(
                  onChangePassword: _onChangePassword,
                  onLogout: _onLogout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
