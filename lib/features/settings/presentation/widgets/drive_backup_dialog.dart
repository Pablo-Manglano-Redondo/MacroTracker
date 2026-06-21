import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/settings/data/services/android_drive_backup_scheduler.dart';
import 'package:macrotracker/features/settings/data/services/google_drive_backup_service.dart';
import 'package:macrotracker/features/settings/domain/usecase/backup_to_drive_usecase.dart';
import 'package:macrotracker/generated/l10n.dart';

class DriveBackupDialog extends StatefulWidget {
  const DriveBackupDialog({super.key});

  @override
  State<DriveBackupDialog> createState() => _DriveBackupDialogState();
}

class _DriveBackupDialogState extends State<DriveBackupDialog> {
  final GoogleDriveBackupService _driveBackupService =
      locator<GoogleDriveBackupService>();
  final BackupToDriveUsecase _backupToDriveUsecase =
      locator<BackupToDriveUsecase>();
  final GetConfigUsecase _getConfigUsecase = locator<GetConfigUsecase>();
  final AddConfigUsecase _addConfigUsecase = locator<AddConfigUsecase>();
  final AndroidDriveBackupScheduler _backupScheduler =
      locator<AndroidDriveBackupScheduler>();

  DriveBackupStatus? _status;
  ConfigEntity? _config;
  bool _loadingStatus = true;
  bool _runningAction = false;

  bool get _isAndroid => Platform.isAndroid;
  bool get _signedIn => _status?.isSignedIn ?? false;
  bool get _autoBackupEnabled => _config?.googleDriveAutoBackupEnabled ?? false;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: _loadingStatus
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.cloud_sync_outlined,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).driveBackupTitle,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  S.of(context).driveBackupSubtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _runningAction
                                ? null
                                : () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            tooltip: MaterialLocalizations.of(context)
                                .closeButtonTooltip,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _ConnectionPanel(
                        status: _status,
                      ),
                      const SizedBox(height: 12),
                      _BackupSummaryPanel(
                        config: _config,
                      ),
                      if (_isAndroid) ...[
                        const SizedBox(height: 12),
                        _AutomationPanel(
                          enabled: _autoBackupEnabled,
                          signedIn: _signedIn,
                          runningAction: _runningAction,
                          onChanged: _setAutoBackupEnabled,
                        ),
                      ],
                      if (_runningAction) ...[
                        const SizedBox(height: 16),
                        const LinearProgressIndicator(),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          if (_signedIn)
                            OutlinedButton.icon(
                              onPressed: _runningAction ? null : _disconnect,
                              icon: const Icon(Icons.link_off_outlined),
                              label: Text(S.of(context).driveBackupDisconnect),
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: _runningAction ? null : _signIn,
                              icon: const Icon(Icons.login_outlined),
                              label: Text(S.of(context).driveBackupConnect),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed:
                                  _runningAction || !_signedIn ? null : _backup,
                              icon: const Icon(Icons.cloud_upload_outlined),
                              label: Text(S.of(context).driveBackupRunNow),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _refreshStatus() async {
    if (mounted) {
      setState(() {
        _loadingStatus = true;
      });
    }

    final status = await _driveBackupService.getStatus();
    final config = await _getConfigUsecase.getConfig();

    if (!mounted) {
      return;
    }

    setState(() {
      _status = status;
      _config = config;
      _loadingStatus = false;
    });
  }

  Future<void> _signIn() async {
    await _runAction(() async {
      await _driveBackupService.authenticate();
      // Auto-activate backup by default upon sign in (opt-out)
      await _addConfigUsecase.setGoogleDriveAutoBackupEnabled(true);
      await _backupScheduler.syncFromConfig(true);
      await _refreshStatus();
      if (!mounted) return;
      _showSnackBar(
        S.of(context).driveBackupConnectedSnack,
      );
    });
  }

  Future<void> _disconnect() async {
    await _runAction(() async {
      await _driveBackupService.disconnect();
      if (_autoBackupEnabled) {
        await _addConfigUsecase.setGoogleDriveAutoBackupEnabled(false);
        await _backupScheduler.cancelDailyBackup();
      }
      await _refreshStatus();
      if (!mounted) return;
      _showSnackBar(
        S.of(context).driveBackupDisconnectedSnack,
      );
    });
  }

  Future<void> _backup() async {
    await _runAction(() async {
      final result = await _backupToDriveUsecase.performBackup();
      await _refreshStatus();
      if (!mounted) return;
      _showSnackBar(
        S.of(context).driveBackupUploadedSnack(
              result.fileName ?? S.of(context).driveBackupDefaultFileName,
            ),
      );
    });
  }

  Future<void> _setAutoBackupEnabled(bool enabled) async {
    await _runAction(() async {
      if (enabled && !_signedIn) {
        await _driveBackupService.authenticate();
      }
      await _addConfigUsecase.setGoogleDriveAutoBackupEnabled(enabled);
      await _backupScheduler.syncFromConfig(enabled);
      await _refreshStatus();
      if (!mounted) return;
      _showSnackBar(
        enabled
            ? S.of(context).driveBackupDailyEnabledSnack
            : S.of(context).driveBackupDailyDisabledSnack,
      );
    });
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() {
      _runningAction = true;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) {
        _showSnackBar(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _runningAction = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ConnectionPanel extends StatelessWidget {
  final DriveBackupStatus? status;

  const _ConnectionPanel({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final signedIn = status?.isSignedIn ?? false;
    final accountName = status?.accountName;
    final accountEmail = status?.accountEmail;
    final errorMessage = status?.errorMessage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                signedIn ? Icons.check_circle : Icons.cloud_off_outlined,
                color: signedIn
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  signedIn
                      ? S.of(context).driveBackupAccountConnected
                      : S.of(context).driveBackupNotConnected,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (signedIn
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest)
                      .withValues(alpha: signedIn ? 0.12 : 0.8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  signedIn
                      ? S.of(context).driveBackupReady
                      : S.of(context).driveBackupPending,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: signedIn
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (accountName != null || accountEmail != null) ...[
            const SizedBox(height: 12),
            if (accountName != null && accountName.isNotEmpty)
              Text(
                accountName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (accountEmail != null && accountEmail.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: accountName != null ? 2 : 0),
                child: Text(
                  accountEmail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
          if (status?.requiresManualConfiguration == true) ...[
            const SizedBox(height: 12),
            _InlineNotice(
              icon: Icons.warning_amber_rounded,
              color: theme.colorScheme.error,
              text: S.of(context).driveBackupOAuthMissing,
            ),
          ],
          if (errorMessage != null && errorMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InlineNotice(
              icon: Icons.error_outline,
              color: theme.colorScheme.error,
              text: errorMessage,
            ),
          ],
        ],
      ),
    );
  }
}

class _BackupSummaryPanel extends StatelessWidget {
  final ConfigEntity? config;

  const _BackupSummaryPanel({
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastSuccess = config?.googleDriveLastBackupSuccessAt;
    final lastAttempt = config?.googleDriveLastBackupAttemptAt;
    final lastError = config?.googleDriveLastBackupError;

    final hasFailure = lastError != null &&
        lastError.isNotEmpty &&
        (lastAttempt == null || lastAttempt != lastSuccess);

    final statusLabel = hasFailure
        ? S.of(context).driveBackupLastAttemptFailed
        : lastSuccess != null
            ? S.of(context).driveBackupLastCompleted
            : S.of(context).driveBackupNoneYet;

    final statusColor = hasFailure
        ? theme.colorScheme.error
        : lastSuccess != null
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).driveBackupStatusTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                hasFailure
                    ? Icons.error_outline
                    : lastSuccess != null
                        ? Icons.check_circle_outline
                        : Icons.schedule_outlined,
                color: statusColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusLabel,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasFailure
                          ? _formatTimestamp(context, lastAttempt,
                              fallback: S.of(context).driveBackupNoTimestamp)
                          : _formatTimestamp(context, lastSuccess,
                              fallback: S.of(context).driveBackupNoUploadYet),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasFailure) ...[
            const SizedBox(height: 12),
            _InlineNotice(
              icon: Icons.info_outline,
              color: theme.colorScheme.error,
              text: lastError,
            ),
          ],
        ],
      ),
    );
  }
}

class _AutomationPanel extends StatelessWidget {
  final bool enabled;
  final bool signedIn;
  final bool runningAction;
  final ValueChanged<bool> onChanged;

  const _AutomationPanel({
    required this.enabled,
    required this.signedIn,
    required this.runningAction,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).driveBackupDailyTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      signedIn
                          ? S.of(context).driveBackupDailySignedInBody
                          : S.of(context).driveBackupDailyConnectFirstBody,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch.adaptive(
                value: enabled,
                onChanged:
                    !runningAction && (signedIn || enabled) ? onChanged : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            S.of(context).driveBackupDailyScheduleNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? text;

  const _InlineNotice({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
          ),
        ),
      ],
    );
  }
}

String _formatTimestamp(
  BuildContext context,
  String? isoString, {
  required String fallback,
}) {
  final parsed = isoString != null ? DateTime.tryParse(isoString) : null;
  if (parsed == null) {
    return fallback;
  }

  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).add_Hm().format(parsed.toLocal());
}
