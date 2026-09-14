import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../utils/navigator_key.dart';

bool _isMaintenanceDialogShowing = false;

/// Closes / terminates the application cleanly.
void _closeApplication() {
  try {
    SystemNavigator.pop();
  } catch (_) {}
  Future.delayed(const Duration(milliseconds: 150), () {
    try {
      exit(0);
    } catch (_) {}
  });
}

/// Displays a global blocking dialog informing the user that the application is under maintenance.
/// Disables all background interactions, prevents back-navigation, and exits the app when confirmed.
void showMaintenanceDialog({
  BuildContext? context,
  String? message,
  VoidCallback? onDismiss,
}) {
  if (_isMaintenanceDialogShowing) return;

  final targetContext = context ?? rootNavigatorKey.currentContext;
  if (targetContext == null) {
    debugPrint('[MaintenanceDialog] Cannot show dialog: context is null');
    return;
  }

  _isMaintenanceDialogShowing = true;

  showDialog<void>(
    context: targetContext,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (BuildContext dialogContext) {
      return MaintenanceDialog(
        message: message,
        onDismiss: () {
          _isMaintenanceDialogShowing = false;
          if (onDismiss != null) {
            Navigator.of(dialogContext, rootNavigator: true).pop();
            onDismiss();
          } else {
            _closeApplication();
          }
        },
      );
    },
  ).then((_) {
    _isMaintenanceDialogShowing = false;
  });
}

/// A modal dialog that indicates the application is under maintenance (HTTP 503).
/// Fully modal and non-dismissible: completely blocks user interactions across the app.
class MaintenanceDialog extends StatelessWidget {
  final String? message;
  final VoidCallback? onDismiss;

  const MaintenanceDialog({
    super.key,
    this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    final isDark = colors.isDark;

    final displayMessage = (message != null && message!.trim().isNotEmpty)
        ? message!.trim()
        : 'The app is currently under maintenance. Please try again after some time.';

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? colors.border.withOpacity(0.5) : colors.border.withOpacity(0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─── Header Icon ───────────────────────────────────────────
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: colors.warning.withOpacity(isDark ? 0.18 : 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.warning.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.engineering_rounded,
                      size: 40,
                      color: colors.warning,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Title ────────────────────────────────────────────────
                Text(
                  'Application Under Maintenance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),

                // ─── Message ──────────────────────────────────────────────
                Text(
                  displayMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.5,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 26),

                // ─── Action Button ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onDismiss ?? _closeApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: isDark ? colors.background : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    child: const Text('Okay, Got It'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
