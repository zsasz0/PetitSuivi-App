import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/shared/support/components/support/support_header.dart';
import 'package:newv/views/shared/support/components/support/support_quick_actions.dart';
import 'package:newv/views/shared/support/components/support/support_social_contacts.dart';
import 'package:newv/views/shared/support/controllers/support_controller.dart';
import 'package:newv/views/shared/support/themes/support_theme.dart';
import 'package:provider/provider.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  late final SupportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SupportController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<AuthSession>();
      _controller.fetchParameters(session.token);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SupportController>.value(
      value: _controller,
      child: Consumer<SupportController>(
        builder: (context, controller, child) {
          // Listen to theme changes
          context.watch<ThemeManager>();

          return Scaffold(
            backgroundColor: SupportTheme.baseBackground,
            appBar: AppBar(
              title: Text(
                'Aide & Contact',
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: SupportTheme.primaryText,
                ),
              ),
              backgroundColor: SupportTheme.surfaceBackground,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: SupportTheme.primaryText),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: SupportTheme.mutedText.withValues(alpha: 0.1),
                  height: 1.0,
                ),
              ),
            ),
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.errorMsg.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'ERROR: ${controller.errorMsg}',
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SupportHeader(
                              companyName: controller.companyName,
                              address: controller.address,
                            ),
                            const SupportQuickActions(),
                            const SizedBox(height: 24),
                            const SupportSocialContacts(),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
          );
        },
      ),
    );
  }
}
