import 'package:flutter/material.dart';
import 'package:newv/views/auth/register/entities/child.dart';
import 'package:newv/views/parent/child_tracking/controllers/child_tracking_controller.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/child_card.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/pickup_notifier_button.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/pickup_pending_hint.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/re_registration_button.dart';
import 'package:newv/views/themes/app_theme.dart';

class ChildFeed extends StatelessWidget {
  final List<Child> children;
  final ChildTrackingController controller;
  final Function(Child) onOpenDetails;

  const ChildFeed({
    super.key,
    required this.children,
    required this.controller,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final child = children[index];
        return _buildChildTile(context, child);
      },
    );
  }

  Widget _buildChildTile(BuildContext context, Child child) {
    final canOpenProfile = controller.isChildApproved(child);
    final needsReReg = controller.needsReRegistration(child);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 200,
          child: ChildCard(
            child: child,
            controller: controller,
            onOpenDetails: () => onOpenDetails(child),
          ),
        ),
        const SizedBox(height: 16),
        if (needsReReg)
          if (controller.inscriptionsOpen)
            ReRegistrationButton(
              child: child,
              onRefresh: () => controller.loadChildren(context),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Les inscriptions sont actuellement fermées.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: Colors.orange,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
        else if (canOpenProfile)
          PickupNotifierButton(child: child, controller: controller)
        else
          const PickupPendingHint(),
      ],
    );
  }
}
