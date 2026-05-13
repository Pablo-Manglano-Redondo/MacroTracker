import 'package:flutter/material.dart';
import 'package:macrotracker/core/utils/locator.dart';
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

  DriveBackupStatus? _status;
  bool _loadingStatus = true;
  bool _runningAction = false;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEs(context) ? 'Backup en Google Drive' : 'Google Drive backup',
      ),
      content: SizedBox(
        width: 420,
        child: _loadingStatus
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEs(context)
                        ? 'Genera un ZIP cifrado de tus datos y lo sube a tu propio Google Drive.'
                        : 'Creates an encrypted ZIP of your data and uploads it to your own Google Drive.',
                  ),
                  const SizedBox(height: 16),
                  _StatusCard(status: _status, isEs: _isEs(context)),
                  if (_runningAction) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: _runningAction ? null : () => Navigator.of(context).pop(),
          child: Text(S.of(context).dialogCancelLabel),
        ),
        if ((_status?.isSignedIn ?? false))
          TextButton(
            onPressed: _runningAction ? null : _disconnect,
            child: Text(_isEs(context) ? 'Desvincular' : 'Disconnect'),
          )
        else
          TextButton(
            onPressed: _runningAction ? null : _signIn,
            child: Text(_isEs(context) ? 'Iniciar sesion' : 'Sign in'),
          ),
        FilledButton.icon(
          onPressed:
              _runningAction || !(_status?.isSignedIn ?? false) ? null : _backup,
          icon: const Icon(Icons.cloud_upload_outlined),
          label: Text(_isEs(context) ? 'Hacer copia ahora' : 'Back up now'),
        ),
      ],
    );
  }

  Future<void> _refreshStatus() async {
    setState(() {
      _loadingStatus = true;
    });
    final status = await _driveBackupService.getStatus();
    if (!mounted) {
      return;
    }
    setState(() {
      _status = status;
      _loadingStatus = false;
    });
  }

  Future<void> _signIn() async {
    await _runAction(() async {
      await _driveBackupService.authenticate();
      await _refreshStatus();
      _showSnackBar(
        _isEs(context)
            ? 'Google Drive conectado.'
            : 'Google Drive connected.',
      );
    });
  }

  Future<void> _disconnect() async {
    await _runAction(() async {
      await _driveBackupService.disconnect();
      await _refreshStatus();
      _showSnackBar(
        _isEs(context)
            ? 'Google Drive desvinculado.'
            : 'Google Drive disconnected.',
      );
    });
  }

  Future<void> _backup() async {
    await _runAction(() async {
      await _backupToDriveUsecase.performBackup();
      await _refreshStatus();
      _showSnackBar(
        _isEs(context)
            ? 'Backup subido a Google Drive.'
            : 'Backup uploaded to Google Drive.',
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

  bool _isEs(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'es';
}

class _StatusCard extends StatelessWidget {
  final DriveBackupStatus? status;
  final bool isEs;

  const _StatusCard({
    required this.status,
    required this.isEs,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                signedIn ? Icons.check_circle_outline : Icons.cloud_off_outlined,
                color: signedIn
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  signedIn
                      ? (isEs ? 'Cuenta conectada' : 'Connected account')
                      : (isEs ? 'Sin conectar' : 'Not connected'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (accountName != null || accountEmail != null) ...[
            const SizedBox(height: 8),
            Text(accountName ?? accountEmail ?? ''),
            if (accountName != null && accountEmail != null)
              Text(
                accountEmail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
          if (status?.requiresManualConfiguration == true) ...[
            const SizedBox(height: 12),
            Text(
              isEs
                  ? 'Falta configurar OAuth de Google Drive para esta plataforma. Revisa docs/google-drive-backup-setup.md.'
                  : 'Google Drive OAuth is still missing for this platform. See docs/google-drive-backup-setup.md.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          if (errorMessage != null && errorMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
