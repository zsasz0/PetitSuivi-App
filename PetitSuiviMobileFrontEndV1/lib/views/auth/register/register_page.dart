import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:newv/app_theme.dart';
import 'package:newv/utils/api_constants.dart';
import 'package:newv/views/parent/waitingForApproval/pages/waiting_approval_page.dart';

import 'components/widgets/custom_stepper.dart';
import 'components/widgets/bottom_navigation.dart';
import 'components/widgets/parent_info_step.dart';
import 'components/widgets/children_info_step.dart';
import 'components/utils/register_validators.dart';
import 'components/utils/register_utils.dart';
import 'package:newv/theme_manager.dart';

/// Multi-step registration flow for parents and their children.
///
/// This widget provides a wizard for collecting the parent's data on step 0
/// and children's data on step 1. All data is structured into a payload
/// and submitted to the Mobile API.
///
/// **API Connectivity:**
/// - **Endpoint**: `POST /api/register`
/// - **Method**: POST
/// - **Payload Structure**:
///   ```json
///   {
///     "cin": 12345678,
///     "firstName": "String",
///     "lastName": "String",
///     "birthdate": "YYYY-MM-DD",
///     "email": "String",
///     "phone": "String",
///     "adresse": "String",
///     "password": "String",
///     "password_confirmation": "String",
///     "role": "parent",
///     "children": [
///       {
///         "firstName": "String",
///         "lastName": "String",
///         "birthdate": "YYYY-MM-DD",
///         "medicalRecordForm": { /* Exhuastive medical objects */ },
///         "inscriptions": [
///           {
///              "insc_date": "YYYY-MM-DD",
///              "status": "pending",
///              "type": "Préscolaire (التحضيري)",
///              "payment_method": "oneShot",
///              "meal_plan": "Mon enfant prend le déjeuner...",
///              "total_amount": 1200.0
///           }
///         ]
///       }
///     ]
///   }
///   ```
/// - **Expected Responses**: Returns a JSON representation containing success or failure metrics and navigates to the approval page upon success.

/// A stateful multi-step registration screen.
///
/// It guides parents through entering their own information and then
/// adding/configuring one or more children for enrollment.
class RegisterPage extends StatefulWidget {
  /// Creates a [RegisterPage].
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  // Modern Theme Colors
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);

  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  static const String _defaultMealPlan =
      'Mon enfant prend le déjeuner et le goûter';
  static const String _defaultInscriptionType = 'Préscolaire (التحضيري)';
  static const List<String> _defaultPaymentMethods = [
    'oneShot',
    'monthlyPartial',
  ];

  // Parent Data
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

  bool _isLoading = false;
  List<String> _paymentMethods = _defaultPaymentMethods;

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

  @override
  void initState() {
    super.initState();
    _loadMethods();
    _addChild(); // Start with one child form
  }

  // used to load payment methods from the server
  Future<void> _loadMethods() async {
    final methods = await RegisterUtils.loadPaymentMethods();
    if (methods.isNotEmpty && mounted) {
      final mergedMethods = {..._defaultPaymentMethods, ...methods}.toList();
      setState(() {
        _paymentMethods = mergedMethods;
        for (final child in _children) {
          final current = child['paymentMethod']?.toString();
          if (current == null || !_paymentMethods.contains(current)) {
            child['paymentMethod'] = _paymentMethods.first;
          }
        }
      });
    }
  }

  // used to add child form
  void _addChild() {
    setState(() {
      _children.add({
        'firstName': '',
        'lastName': '',
        'birthDate': '',
        'oldSchool': '',
        'inscriptionType': _defaultInscriptionType,
        'medicalRecord': '',
        'medicalRecordForm': <String, dynamic>{},
        'mealPlan': _defaultMealPlan,
        'totalPayment': 1550.0,
        'paymentMethod': _paymentMethods.first,
      });
    });
  }

  // used to select parent date
  Future<void> _selectDate() async {
    final date = await RegisterUtils.selectParentDate(context);
    if (date != null && mounted) {
      setState(() {
        _birthDate = date;
      });
    }
  }

  // used to remove child form
  void _removeChild(int index) {
    if (_children.length > 1) {
      setState(() {
        _children.removeAt(index);
      });
    }
  }

  // used to build the parent register page
  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentStep > 0) {
          setState(() => _currentStep -= 1);
        }
      },
      child: Scaffold(
        backgroundColor: _baseDark,
        appBar: AppBar(
          title: Text(
            'Inscription Parent',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w700,
              color: _lightText,
            ),
          ),
          backgroundColor: _baseDark,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: _lightText),
            onPressed: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // include the stepper widget and the bottom navigation widget and the main content in a column
                CustomStepper(currentStep: _currentStep),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                    // if step is 0 show parent info step
                    // if step is 1 show children info step
                    child: _currentStep == 0
                        ? ParentInfoStep(
                            firstNameController: _firstNameController,
                            lastNameController: _lastNameController,
                            cinController: _cinController,
                            phoneController: _phoneController,
                            emailController: _emailController,
                            addressController: _addressController,
                            passwordController: _passwordController,
                            confirmPasswordController:
                                _confirmPasswordController,
                            birthDate: _birthDate,
                            onSelectDate: _selectDate,
                          )
                        : ChildrenInfoStep(
                            // show children info step
                            children: _children,
                            paymentMethods: _paymentMethods,
                            onRemoveChild: _removeChild,
                            onAddChild: _addChild,
                            parentAddress: _addressController.text,
                            totalChildren: _children.length,
                          ),
                  ),
                ),
                // it contains the bottom navigation buttons which allow user to navigate between steps and register
                BottomNavigation(
                  currentStep: _currentStep,
                  isLoading: _isLoading,
                  // onBack used in bottom navigation bar to go back to previous step
                  onBack: () {
                    setState(() => _currentStep -= 1);
                  },
                  // if step is 0 and user clicks next validate parent info and move to children info
                  // if step is 1 and user clicks next validate children info and move to register
                  onNext: () {
                    if (_currentStep == 0) {
                      // validate parent info
                      //validateParentStep function is in register_validators.dart return string error if validation fail or null if validation pass
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
                        RegisterUtils.showError(context, error);
                      } else {
                        setState(() => _currentStep += 1);
                      }
                    } else {
                      // if step is 1 and user clicks next validate children info and move to registers
                      _handleRegister();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Gathers all collected data from parent controllers and the `_children` list,
  /// constructs the final JSON payload, and sends a POST request to the backend.
  ///
  /// It performs the following:
  /// 1. Validates the final children forms.
  /// 2. Formats the parent's attributes.
  /// 3. Maps over the `_children` list to format the `inscriptions` and `medicalRecordForm` for each child.
  /// 4. Handles the API request, decoding errors or routing the user to the [WaitingApprovalPage] on success.
  // used to handle the registration
  Future<void> _handleRegister() async {
    final childrenError = RegisterValidators.validateChildrenStep(_children);
    if (childrenError != null) {
      RegisterUtils.showError(context, childrenError);
      return;
    }

    // set loading to true in order to show the loading indicator
    setState(() => _isLoading = true);
    // parse the cin to int
    final cin = int.tryParse(_cinController.text.trim());
    // if cin is null, show error and return
    if (cin == null) {
      setState(() => _isLoading = false);
      RegisterUtils.showError(context, 'CIN invalide.');
      return;
    }

    // create the uri for the registration
    final uri = Uri.parse('$_apiBaseUrl/api/register');
    // get the current date For the inscription date
    final today = DateTime.now().toIso8601String().split('T').first;
    // create the payload for the registration (used to send the data to the backend)
    // payload is a map that contains all the data of the registration
    final payload = {
      'cin': cin,
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'birthdate': _birthDate.isNotEmpty ? _birthDate : null,
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'adresse': _addressController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _confirmPasswordController.text,
      'role': 'parent',
      'children': _children.map((child) {
        // map over the children list to format the data
        return {
          // return the child data as a map ( all this key names are used in the backend )
          'firstName': child['firstName']?.toString() ?? '',
          'lastName': child['lastName']?.toString() ?? '',
          'birthdate': child['birthDate']?.toString().isNotEmpty == true
              ? child['birthDate']
              : null,
          'medicalRecordForm': child['medicalRecordForm'],
          'inscriptions': [
            {
              'insc_date': today,
              'status': 'pending',
              'type': child['inscriptionType']?.toString(),
              'payment_method':
                  child['paymentMethod']?.toString() ?? _paymentMethods.first,
              'meal_plan': child['mealPlan']?.toString(),
              'total_amount':
                  (child['totalPayment'] as num?)?.toDouble() ?? 1200.0,
            },
          ],
        };
      }).toList(),
    }; // end of payload

    // send the payload to the backend
    try {
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (!mounted)
        return; // check if the widget is still mounted before processing the response
      // decode the response body to geet the message or error
      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{}; // decode the response body
      // check if the response is successful
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // check if the response is successful
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WaitingApprovalPage()),
          (route) => false,
        );
      } else {
        RegisterUtils.showError(
          context,
          body['message']?.toString() ?? 'Échec de l\'inscription.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      RegisterUtils.showError(context, 'Erreur réseau lors de l\'inscription.');
    } finally {
      if (mounted) {
        setState(
          () => _isLoading = false,
        ); // set loading to false after the request is completed in order to hide the loading indicator
      }
    }
  }
}
