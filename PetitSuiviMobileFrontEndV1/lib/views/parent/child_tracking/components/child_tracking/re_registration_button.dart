import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/auth/register/entities/child.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/re_registration_page.dart';
import 'package:newv/views/parent/child_tracking/themes/child_tracking_theme.dart';

class ReRegistrationButton extends StatelessWidget {
  final Child child;
  final VoidCallback onRefresh;

  const ReRegistrationButton({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => ReRegistrationPage(
              childId: child.id ?? 0,
              firstName: child.firstName,
              lastName: child.lastName,
              birthDate: child.birthDate.toIso8601String().split('T').first,
            ),
          ),
        );
        if (result == true) {
          onRefresh();
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: ChildTrackingTheme.indigoAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 22),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Inscrire pour la nouvelle année',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
