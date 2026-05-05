import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/auth/register/entities/child.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/child_details_page.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/child_feed.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/child_tracking_empty.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/child_tracking_error.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/child_tracking_loading.dart';
import 'package:newv/views/parent/child_tracking/controllers/child_tracking_controller.dart';
import 'package:newv/views/parent/child_tracking/themes/child_tracking_theme.dart';
import 'package:provider/provider.dart';

class ChildTrackingPage extends StatefulWidget {
  const ChildTrackingPage({super.key});

  @override
  State<ChildTrackingPage> createState() => _ChildTrackingPageState();
}

class _ChildTrackingPageState extends State<ChildTrackingPage> {
  late ChildTrackingController _controller;
  bool _didAttemptRouteRestore = false;

  @override
  void initState() {
    super.initState();
    _controller = ChildTrackingController();
    _controller.checkInscriptionsOpen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = context.watch<AuthSession>();
    final childrenVersion = session.childrenVersion;
    final syncVersion = session.syncVersion;
    final shouldReload =
        childrenVersion != _controller.lastSeenChildrenVersion ||
        syncVersion != _controller.lastSeenSyncVersion;

    if (shouldReload) {
      _controller.lastSeenChildrenVersion = childrenVersion;
      _controller.lastSeenSyncVersion = syncVersion;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _controller.loadChildren(context);
        if (mounted) {
          _restoreSavedChildRoute(_controller.children);
        }
      });
    }
  }

  Future<void> _restoreSavedChildRoute(List<Child> children) async {
    if (_didAttemptRouteRestore || children.isEmpty) return;
    _didAttemptRouteRestore = true;

    final session = context.read<AuthSession>();
    final savedRoute = await session.getSavedParentChildRoute();
    if (!mounted || savedRoute == null) return;

    final childId = savedRoute['childId'];
    final savedTabIndex = savedRoute['tabIndex'];
    final resolvedChildId = childId is int
        ? childId
        : int.tryParse(childId?.toString() ?? '');
    final resolvedTabIndex = savedTabIndex is int
        ? savedTabIndex
        : int.tryParse(savedTabIndex?.toString() ?? '') ?? 0;

    if (resolvedChildId == null) {
      await session.clearParentChildRoute();
      return;
    }

    Child? targetChild;
    for (final child in children) {
      if (child.id == resolvedChildId) {
        targetChild = child;
        break;
      }
    }

    if (targetChild == null || !_controller.isChildApproved(targetChild)) {
      await session.clearParentChildRoute();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openChildDetails(targetChild!, initialTabIndex: resolvedTabIndex);
    });
  }

  Future<void> _openChildDetails(Child child, {int initialTabIndex = 0}) async {
    final childId = child.id;
    final session = context.read<AuthSession>();
    if (childId != null) {
      await session.saveParentChildRoute(
        childId: childId,
        tabIndex: initialTabIndex,
      );
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildDetailsPage(
          childData: child.toJson(),
          initialTabIndex: initialTabIndex,
        ),
      ),
    );
  }

  /// main widget
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;

        return Container(
          color: ChildTrackingTheme.baseDark,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            /// app bar
            appBar: AppBar(
              title: Text(
                l10n.selectChild,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: ChildTrackingTheme.lightText,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            /// body
            body: 
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,


                /// main children list
                children: [
                  Text(
                    l10n.whoToManage,
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: ChildTrackingTheme.mutedText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  /// loading indicator
                  if (_controller.isLoadingChildren)
                    const ChildTrackingLoading()
                  else if (_controller.errorMessage != null)
                    ChildTrackingError(
                      message: _controller.errorMessage!,
                      onRetry: () => _controller.loadChildren(context),
                    )
                  else if (_controller.children.isEmpty)
                    const ChildTrackingEmpty()
                  else
                    ChildFeed(
                      children: _controller.children,
                      controller: _controller,
                      onOpenDetails: (child) => _openChildDetails(child),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
