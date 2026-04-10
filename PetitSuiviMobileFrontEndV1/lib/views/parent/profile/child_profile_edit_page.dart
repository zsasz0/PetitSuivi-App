import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:newv/views/auth/register/components/widgets/child_medical_record_page.dart';

// File: child_profile_edit_page.dart
// Purpose: Form for editing a child's personal details and medical record.
// Usage: Navigated from ParentProfilePage child list.
// API Usage: No (currently simulation only, data passed back via Navigator.pop).
// Dependencies: AppTheme, AppLocalizations, ChildMedicalRecordPage.

/// A page that allows parents to update a child's name, birthdate, and medical record.
class ChildProfileEditPage extends StatefulWidget {
  final Map<String, dynamic> childData;

  const ChildProfileEditPage({super.key, required this.childData});

  @override
  State<ChildProfileEditPage> createState() => _ChildProfileEditPageState();
}

class _ChildProfileEditPageState extends State<ChildProfileEditPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _descriptionController;
  late String _birthDate;
  Map<String, dynamic> _medicalFormData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.childData['firstName'],
    );
    _lastNameController = TextEditingController(
      text: widget.childData['lastName'],
    );
    _descriptionController = TextEditingController(
      text: widget.childData['description'],
    );

    _birthDate = widget.childData['birthDate'] ?? '';
    _medicalFormData =
        (widget.childData['medicalRecordForm'] as Map<String, dynamic>?) ??
        <String, dynamic>{};
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _openMedicalRecordForm() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChildMedicalRecordPage(initialData: _medicalFormData),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _medicalFormData = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final l10n = AppLocalizations.of(context)!;
    final hasMedicalRecord = _medicalFormData.isNotEmpty;
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.edit,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppTheme.darkerText,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: AppTheme.darkerText),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Simulate saving
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil mis à jour')),
                );
              },
              child: Text(
                l10n.save.toUpperCase(),
                style: TextStyle(
                  color: AppTheme.nearlyDarkBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.nearlyWhite,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.grey.withValues(alpha: 0.2),
                            offset: const Offset(1, 1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(Icons.face, size: 50, color: AppTheme.spacer),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.nearlyDarkBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField(l10n.firstName, _firstNameController),
              const SizedBox(height: 16),
              _buildTextField(l10n.lastName, _lastNameController),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              _buildDatePicker(context),
              const SizedBox(height: 16),
              _buildTextField(
                l10n.description,
                _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.medicalRecord,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.darkerText,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          hasMedicalRecord
                              ? Icons.check_circle
                              : Icons.medical_services_outlined,
                          color: hasMedicalRecord
                              ? Colors.green
                              : AppTheme.nearlyDarkBlue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hasMedicalRecord
                                ? 'تمت تعبئة الاستمارة الطبية'
                                : 'لم يتم تعبئة الملف الطبي بعد',
                            style: TextStyle(
                              color: hasMedicalRecord
                                  ? Colors.green
                                  : AppTheme.grey,
                              fontWeight: hasMedicalRecord
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _openMedicalRecordForm,
                          icon: Icon(
                            hasMedicalRecord
                                ? Icons.edit_note
                                : Icons.add_circle_outline,
                            size: 18,
                          ),
                          label: Text(hasMedicalRecord ? 'تعديل' : 'تعبئة'),
                        ),
                      ],
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppTheme.darkerText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.dateOfBirth,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime now = DateTime.now();
            final DateTime firstDate = DateTime(
              now.year - 5,
              now.month - 4,
              now.day,
            );
            final DateTime lastDate = DateTime(
              now.year - 2,
              now.month,
              now.day,
            );

            DateTime parsedDate = _birthDate.isNotEmpty
                ? DateTime.parse(_birthDate)
                : DateTime(now.year - 3, now.month, now.day);

            if (parsedDate.isBefore(firstDate)) {
              parsedDate = firstDate;
            } else if (parsedDate.isAfter(lastDate)) {
              parsedDate = lastDate;
            }

            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: parsedDate,
              firstDate: firstDate,
              lastDate: lastDate,
            );
            if (picked != null) {
              setState(() {
                _birthDate =
                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _birthDate.isEmpty
                      ? AppLocalizations.of(context)!.save
                      : _birthDate,
                ),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
