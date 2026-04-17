import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';

import 'themes/register_theme.dart';
import 'components/register/register_stepper.dart';
import 'components/register/register_bottom_navigation.dart';
import 'components/register/parent_info_step.dart';
import 'components/register/children_info_step.dart';
import 'controllers/register_controller.dart';
import 'controllers/register_validators.dart';

/// Multi-step registration flow entry point.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late RegisterController _controller;

  int _currentStep = 0;
  bool _isLoading = false;
  String? _emailErrorText;
  List<String> _paymentMethods = ['oneShot', 'monthlyPartial'];

  // Parent Data Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cinController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _birthDate = '';

  // Children Data
  final List<Map<String, dynamic>> _children = [];

  @override
  void initState() {
    super.initState();
    _controller = RegisterController(context);
    _addChild(); // Initial child
    _loadMethods();
    _emailController.addListener(_clearEmailError);
  }

  void _clearEmailError() {
    if (_emailErrorText != null) {
      setState(() => _emailErrorText = null);
    }
  }

  Future<void> _loadMethods() async {
    final methods = await _controller.loadPaymentMethods();
    if (methods.isNotEmpty && mounted) {
      setState(() {
        _paymentMethods = {..._paymentMethods, ...methods}.toList();
      });
    }
  }

  void _addChild() {
    setState(() {
      _children.add({
        'firstName': '',
        'lastName': '',
        'birthDate': '',
        'oldSchool': '',
        'inscriptionType': 'Préscolaire (التحضيري)',
        'medicalRecord': '',
        'medicalRecordForm': <String, dynamic>{},
        'mealPlan': 'Mon enfant prend le déjeuner et le goûter',
        'totalPayment': 1550.0,
        'paymentMethod': _paymentMethods.first,
      });
    });
  }

  void _removeChild(int index) {
    if (_children.length > 1) {
      setState(() => _children.removeAt(index));
    }
  }

  Future<void> _selectDate() async {
    final date = await _controller.selectDate(
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      tealAccent: RegisterTheme.tealAccent,
      baseDark: RegisterTheme.baseDark,
      lightText: RegisterTheme.lightText,
      isLight: ThemeManager.instance.isLightMode,
    );
    if (date != null && mounted) {
      setState(() => _birthDate = date);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cinController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleNext() async {
    if (_currentStep == 0) {
      final error = RegisterValidators.validateParentStep(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _birthDate,
        cin: _cinController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (error != null) {
        _controller.showError(error);
        return;
      }

      final isAvailable = await _controller.checkEmailAvailability(
        _emailController.text.trim(),
        (err) => setState(() => _emailErrorText = err),
      );

      if (isAvailable && mounted) {
        setState(() => _currentStep = 1);
      }
    } else {
      _onRegister();
    }
  }

  void _onRegister() async {
    final childrenError = RegisterValidators.validateChildrenStep(_children);
    if (childrenError != null) {
      _controller.showError(childrenError);
      return;
    }

    final cinValue = int.tryParse(_cinController.text.trim());
    if (cinValue == null) {
      _controller.showError('CIN invalide.');
      return;
    }

    final today = DateTime.now().toIso8601String().split('T').first;
    final payload = {
      'cin': cinValue,
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'birthdate': _birthDate,
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'adresse': _addressController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _confirmPasswordController.text,
      'role': 'parent',
      'children': _children.map((child) {
        return {
          'firstName': child['firstName'],
          'lastName': child['lastName'],
          'birthdate': child['birthDate'],
          'medicalRecordForm': child['medicalRecordForm'],
          'inscriptions': [
            {
              'insc_date': today,
              'status': 'pending',
              'type': child['inscriptionType'],
              'payment_method': child['paymentMethod'],
              'meal_plan': child['mealPlan'],
              'total_amount': child['totalPayment'],
            }
          ],
        };
      }).toList(),
    };

    await _controller.handleRegister(
      payload: payload,
      onLoadingChanged: (loading) => setState(() => _isLoading = loading),
      onRegistrationError: (err, step) => setState(() {
        _emailErrorText = err;
        _currentStep = step;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentStep > 0) {
          setState(() => _currentStep = 0);
        }
      },
      child: Scaffold(
        backgroundColor: RegisterTheme.baseDark,
        appBar: AppBar(
          title: Text(
            'Inscription Parent',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w700,
              color: RegisterTheme.lightText,
            ),
          ),
          backgroundColor: RegisterTheme.baseDark,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: RegisterTheme.lightText),
            onPressed: () {
              if (_currentStep > 0) {
                setState(() => _currentStep = 0);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              RegisterStepper(currentStep: _currentStep),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
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
                  child: _currentStep == 0
                      ? ParentInfoStep(
                          firstNameController: _firstNameController,
                          lastNameController: _lastNameController,
                          cinController: _cinController,
                          phoneController: _phoneController,
                          emailController: _emailController,
                          addressController: _addressController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          birthDate: _birthDate,
                          onSelectDate: _selectDate,
                          emailErrorText: _emailErrorText,
                        )
                      : ChildrenInfoStep(
                          children: _children,
                          paymentMethods: _paymentMethods,
                          onRemoveChild: _removeChild,
                          onAddChild: _addChild,
                          parentAddress: _addressController.text,
                          totalChildren: _children.length,
                        ),
                ),
              ),
              RegisterBottomNavigation(
                currentStep: _currentStep,
                isLoading: _isLoading,
                onBack: () => setState(() => _currentStep = 0),
                onNext: _handleNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
