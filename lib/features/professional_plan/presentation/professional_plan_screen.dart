import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:macrotracker/core/services/cloud_account_service.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/professional_plan/data/data_source/professional_plan_data_source.dart';
import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/accept_professional_invite_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/disconnect_professional_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_messages_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_section_summary_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_sharing_scope_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/mark_professional_section_seen_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/mark_professional_message_read_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/send_professional_message_usecase.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/get_body_progress_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/upload_professional_snapshot_usecase.dart';
import 'package:macrotracker/generated/l10n.dart';

// Modular Widget Imports
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_ui_helpers.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/invite_entry_view.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/connected_professional_hub.dart';

class ProfessionalPlanScreen extends StatefulWidget {
  const ProfessionalPlanScreen({super.key});

  @override
  State<ProfessionalPlanScreen> createState() => _ProfessionalPlanScreenState();
}

class ProfessionalPlanScreenArguments {
  final String inviteCode;
  final bool preferEmbeddedTabAfterAccept;

  const ProfessionalPlanScreenArguments({
    required this.inviteCode,
    this.preferEmbeddedTabAfterAccept = false,
  });
}

class _ProfessionalPlanScreenState extends State<ProfessionalPlanScreen> {
  final _codeController = TextEditingController();

  late final AcceptProfessionalInviteUsecase _acceptProfessionalInviteUsecase;
  late final DisconnectProfessionalUsecase _disconnectProfessionalUsecase;
  late final GetProfessionalSectionSummaryUsecase
      _getProfessionalSectionSummaryUsecase;
  late final GetProfessionalMessagesUsecase _getProfessionalMessagesUsecase;
  late final MarkProfessionalMessageReadUsecase
      _markProfessionalMessageReadUsecase;
  late final SendProfessionalMessageUsecase _sendProfessionalMessageUsecase;
  late final GetProfessionalSharingScopeUsecase
      _getProfessionalSharingScopeUsecase;
  late final MarkProfessionalSectionSeenUsecase
      _markProfessionalSectionSeenUsecase;

  ProfessionalConnectionEntity? _connection;
  ProfessionalSectionSummaryEntity? _summary;
  ProfessionalSharingScopeEntity? _sharingScope;
  ProfessionalMessageThreadEntity? _messages;
  ProfessionalInvitePreviewEntity? _invitePreview;
  bool _loading = true;
  bool _protectingAccount = false;
  bool _sendingMessage = false;
  bool _handledRouteArguments = false;
  String? _error;
  ProfessionalHubTab _selectedTab = ProfessionalHubTab.summary;

  @override
  void initState() {
    super.initState();
    _acceptProfessionalInviteUsecase =
        locator<AcceptProfessionalInviteUsecase>();
    _disconnectProfessionalUsecase = locator<DisconnectProfessionalUsecase>();
    _getProfessionalSectionSummaryUsecase =
        locator<GetProfessionalSectionSummaryUsecase>();
    _getProfessionalMessagesUsecase = locator<GetProfessionalMessagesUsecase>();
    _markProfessionalMessageReadUsecase =
        locator<MarkProfessionalMessageReadUsecase>();
    _sendProfessionalMessageUsecase = locator<SendProfessionalMessageUsecase>();
    _getProfessionalSharingScopeUsecase =
        locator<GetProfessionalSharingScopeUsecase>();
    _markProfessionalSectionSeenUsecase =
        locator<MarkProfessionalSectionSeenUsecase>();
    _loadSection(refreshRemotePlan: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledRouteArguments) {
      return;
    }
    _handledRouteArguments = true;
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is ProfessionalPlanScreenArguments &&
        arguments.inviteCode.trim().isNotEmpty) {
      _codeController.text = arguments.inviteCode.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _connection == null) {
          _previewInvite();
        }
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).professionalScreenTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadSection(refreshRemotePlan: true),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  if (_connection == null) ...[
                    _SectionHero(
                      title: S.of(context).professionalHeroConnectTitle,
                      subtitle:
                          S.of(context).professionalSectionConnectSubtitle,
                      statusLabel: S.of(context).professionalStatusInviteOnly,
                      icon: Icons.medical_services_outlined,
                    ),
                    const SizedBox(height: 16),
                    InviteEntryView(
                      codeController: _codeController,
                      invitePreview: _invitePreview,
                      error: _error,
                      isBusy: _protectingAccount,
                      onPreviewInvite: _previewInvite,
                      onAcceptInvite: _acceptInvite,
                    ),
                  ] else if (_summary != null &&
                      _sharingScope != null &&
                      _messages != null)
                    ConnectedProfessionalHub(
                      summary: _summary!,
                      sharingScope: _sharingScope!,
                      messages: _messages!,
                      selectedTab: _selectedTab,
                      error: _error,
                      onSelectTab: (tab) {
                        setState(() => _selectedTab = tab);
                      },
                      onDisconnect: _disconnect,
                      onMarkMessageRead: _markMessageRead,
                      onSendMessage: _sendMessage,
                      sendingMessage: _sendingMessage,
                      onUpdateSharingMode: _updateSharingMode,
                      onUpdateDailyNote: _updateDailyNote,
                    )
                  else
                    _InfoCard(
                      icon: Icons.info_outline,
                      title: S.of(context).professionalSectionLoadErrorTitle,
                      body:
                          _error ?? S.of(context).professionalSectionRetryHint,
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> _loadSection({
    bool refreshRemotePlan = false,
    bool preserveSelectedTab = false,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await _getProfessionalSectionSummaryUsecase.execute(
        refreshRemotePlan: refreshRemotePlan,
      );
      if (!mounted) return;
      if (summary == null) {
        setState(() {
          _connection = null;
          _summary = null;
          _sharingScope = null;
          _messages = null;
          _loading = false;
        });
        return;
      }
      final sharingScope = await _getProfessionalSharingScopeUsecase.execute(
        connection: summary.connection,
      );
      final messages = await _getProfessionalMessagesUsecase.execute(
        connection: summary.connection,
      );
      await _markProfessionalSectionSeenUsecase.execute(
        connection: summary.connection,
      );
      if (!mounted) return;
        setState(() {
          _connection = summary.connection;
          _summary = summary;
          _sharingScope = sharingScope;
          _messages = messages;
          if (!preserveSelectedTab) {
            _selectedTab = ProfessionalHubTab.summary;
          }
          _loading = false;
        });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(context, error);
        _loading = false;
      });
    }
  }

  Future<void> _previewInvite() async {
    setState(() {
      _loading = true;
      _error = null;
      _invitePreview = null;
    });
    try {
      final invite = await _acceptProfessionalInviteUsecase
          .fetchInvitePreview(_codeController.text);
      await locator<ConversionAnalyticsService>().logEvent(
        'professional_invite_previewed',
        parameters: {
          'found': invite != null,
          if (invite != null) 'professional_id': invite.professionalId,
          if (invite != null) 'is_expired': invite.isExpired,
        },
      );
      if (!mounted) return;
      setState(() {
        _invitePreview = invite;
        _error = invite == null
            ? S.of(context).professionalInviteNotFound
            : invite.isExpired
                ? S.of(context).professionalInviteExpired
                : null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(context, error);
        _loading = false;
      });
    }
  }

  Future<void> _acceptInvite() async {
    final accountReady = _isDebugInviteCode()
        ? true
        : await _ensureProtectedAccountForConnection();
    if (!accountReady) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final connection = await _acceptProfessionalInviteUsecase
          .acceptInvite(_codeController.text);
      await locator<ConversionAnalyticsService>().logEvent(
        'professional_invite_accepted',
        parameters: {
          'professional_id': connection.professionalId,
          'relationship_id': connection.relationshipId,
        },
      );
      if (_shouldReturnToEmbeddedTab) {
        if (!mounted) return;
        Navigator.of(context).pop(true);
        return;
      }
      await _loadSection(refreshRemotePlan: true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(context, error);
        _loading = false;
      });
    }
  }

  Future<bool> _ensureProtectedAccountForConnection() async {
    try {
      final accountService = locator<CloudAccountService>();
      final status = await accountService.getStatus();
      if (status.isProtected) {
        return true;
      }

      if (!mounted) return false;

      final shouldProtect = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.of(context).professionalProtectAccountTitle),
          content: Text(S.of(context).professionalProtectAccountBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(S.of(context).dialogCancelLabel),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.g_mobiledata_outlined),
              label: Text(S.of(context).professionalProtectAccountAction),
            ),
          ],
        ),
      );

      if (shouldProtect != true) {
        return false;
      }
      if (!mounted) {
        return false;
      }

      setState(() {
        _protectingAccount = true;
        _error = null;
      });
      final opened = await accountService.protectWithGoogle();
      if (!mounted) {
        return false;
      }
      setState(() => _protectingAccount = false);
      _showSnackBar(
        opened
            ? S.of(context).professionalProtectAccountReturnHint
            : S.of(context).professionalProtectAccountOpenError,
      );
      return false;
    } catch (error) {
      if (!mounted) {
        return false;
      }
      setState(() {
        _protectingAccount = false;
        _error = friendlyError(context, error);
      });
      return false;
    }
  }

  Future<void> _markMessageRead(ProfessionalMessageEntity message) async {
    final connection = _connection;
    final messages = _messages;
    if (connection == null || messages == null || message.isRead) {
      return;
    }
    await _markProfessionalMessageReadUsecase.execute(
      connection: connection,
      messageId: message.id,
    );
    await _markProfessionalSectionSeenUsecase.execute(connection: connection);
    if (!mounted) return;
    setState(() {
      _messages = ProfessionalMessageThreadEntity(
        threadId: messages.threadId,
        isSupported: messages.isSupported,
        messagesEnabled: messages.messagesEnabled,
        messages: messages.messages
            .map((item) =>
                item.id == message.id ? item.copyWith(isRead: true) : item)
            .toList(),
      );
    });
  }

  Future<void> _sendMessage(String body) async {
    final connection = _connection;
    final messages = _messages;
    if (connection == null || messages == null || body.trim().isEmpty) {
      return;
    }
    setState(() {
      _sendingMessage = true;
      _error = null;
    });
    try {
      final sent = await _sendProfessionalMessageUsecase.execute(
        connection: connection,
        body: body,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _messages = ProfessionalMessageThreadEntity(
          threadId: messages.threadId,
          isSupported: true,
          messagesEnabled: messages.messagesEnabled,
          messages: [sent, ...messages.messages],
        );
        _sendingMessage = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _sendingMessage = false;
        _error = friendlyError(context, error);
      });
    }
  }

  bool _isDebugInviteCode() {
    return kDebugMode &&
        _codeController.text.trim().toUpperCase() ==
            ProfessionalPlanDataSource.debugInviteCode;
  }

  bool get _shouldReturnToEmbeddedTab {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return arguments is ProfessionalPlanScreenArguments &&
        arguments.preferEmbeddedTabAfterAccept &&
        Navigator.of(context).canPop();
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor:
              isError ? colorScheme.errorContainer : null,
          content: Text(
            message,
            style: TextStyle(
              color: isError ? colorScheme.onErrorContainer : null,
            ),
          ),
        ),
      );
  }

  Future<void> _disconnect() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).professionalDisconnectTitle),
        content: Text(S.of(context).professionalDisconnectBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.of(context).dialogCancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(S.of(context).professionalActionRevokeAccess),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _loading = true);
    await _disconnectProfessionalUsecase.disconnect();
    await locator<ConversionAnalyticsService>().logEvent(
      'professional_connection_revoked',
      parameters: {
        'professional_id': _connection?.professionalId,
        'relationship_id': _connection?.relationshipId,
      },
    );
    if (_shouldReturnToEmbeddedTab &&
        mounted &&
        Navigator.of(context).canPop()) {
      Navigator.of(context).pop(false);
      return;
    }
    if (!mounted) return;
    setState(() {
      _connection = null;
      _summary = null;
      _sharingScope = null;
      _messages = null;
      _loading = false;
      _selectedTab = ProfessionalHubTab.summary;
    });
  }

  Future<void> _updateSharingMode(String sharingMode) async {
    final connection = _connection;
    if (connection == null) return;
    setState(() => _loading = true);
    try {
      await locator<ProfessionalPlanRepository>().updateSharingMode(
        relationshipId: connection.relationshipId,
        clientId: connection.clientId,
        sharingMode: sharingMode,
      );
      await _loadSection(
        refreshRemotePlan: true,
        preserveSelectedTab: true,
      );
      if (!mounted) return;
      _showSnackBar(
        sharingMode == 'detailed'
            ? uiText(
                context,
                es: 'Diario detallado activado correctamente.',
                en: 'Detailed diary enabled successfully.',
              )
            : uiText(
                context,
                es: 'Se ha vuelto al modo solo agregados.',
                en: 'Switched back to aggregate-only sharing.',
              ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = _sharingModeErrorMessage(e);
      setState(() {
        _error = message;
        _loading = false;
      });
      _showSnackBar(message, isError: true);
    }
  }

  String _sharingModeErrorMessage(Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('socketexception') ||
        raw.contains('clientexception') ||
        raw.contains('failed host lookup') ||
        raw.contains('network')) {
      return uiText(
        context,
        es: 'No se pudo cambiar el nivel de privacidad porque no hay conexión. Inténtalo otra vez cuando el móvil vuelva a tener red.',
        en: 'Could not change the privacy level because the device is offline. Try again when the phone has network access.',
      );
    }
    if (raw.contains('permission') ||
        raw.contains('row-level security') ||
        raw.contains('not return a relationship row') ||
        raw.contains('blocked by permissions')) {
      return uiText(
        context,
        es: 'No se pudo actualizar el permiso con el profesional. La relación puede haberse revocado o el backend sigue bloqueando este cambio.',
        en: 'Could not update the permission with this professional. The relationship may have been revoked or the backend is still blocking this change.',
      );
    }
    if (raw.contains('not persisted') ||
        raw.contains('expected \"detailed\"') ||
        raw.contains('expected \"aggregate\"')) {
      return uiText(
        context,
        es: 'El cambio no quedó guardado en el servidor. Cierra y vuelve a abrir la sección antes de intentarlo otra vez.',
        en: 'The change was not persisted on the server. Close and reopen this section before trying again.',
      );
    }
    if (raw.contains('authentication') ||
        raw.contains('jwt') ||
        raw.contains('session') ||
        raw.contains('unauthorized') ||
        raw.contains('forbidden')) {
      return uiText(
        context,
        es: 'Tu sesión de nube ya no es válida para cambiar este permiso. Vuelve a iniciar sesión e inténtalo de nuevo.',
        en: 'Your cloud session is no longer valid for changing this permission. Sign in again and try once more.',
      );
    }
    return uiText(
      context,
      es: 'No se pudo cambiar el nivel de privacidad de esta relación. Inténtalo de nuevo en unos segundos.',
      en: 'Could not change the privacy level for this relationship. Try again in a few seconds.',
    );
  }

  Future<void> _updateDailyNote(String note) async {
    final connection = _connection;
    if (connection == null) return;
    setState(() => _loading = true);
    try {
      final todayActual = _summary?.today;
      final kcalActual = todayActual?.kcalActual ?? 0.0;
      final carbsActual = todayActual?.carbsActual ?? 0.0;
      final fatActual = todayActual?.fatActual ?? 0.0;
      final proteinActual = todayActual?.proteinActual ?? 0.0;
      final mealsLogged = todayActual?.mealsLogged ?? 0;

      final kcalTarget = todayActual?.kcalTarget ?? 0.0;
      final carbsTarget = todayActual?.carbsTarget ?? 0.0;
      final fatTarget = todayActual?.fatTarget ?? 0.0;
      final proteinTarget = todayActual?.proteinTarget ?? 0.0;

      final bodyProgress = await locator<GetBodyProgressUsecase>().getSummary();
      final weightKg = bodyProgress.latestWeightKg;
      final waistCm = bodyProgress.latestWaistCm;
      await locator<UploadProfessionalSnapshotUsecase>().uploadDailySnapshot(
        connection: connection,
        day: DateTime.now(),
        kcalActual: kcalActual,
        kcalTarget: kcalTarget,
        carbsActual: carbsActual,
        carbsTarget: carbsTarget,
        fatActual: fatActual,
        fatTarget: fatTarget,
        proteinActual: proteinActual,
        proteinTarget: proteinTarget,
        mealsLogged: mealsLogged,
        notes: note,
        weightKg: weightKg,
        waistCm: waistCm,
      );
      await _loadSection(refreshRemotePlan: false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(context, e);
        _loading = false;
      });
    }
  }
}

class _SectionHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusLabel;
  final IconData icon;

  const _SectionHero({
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Panel(
      accent: Color.alphaBlend(
        colorScheme.primary.withValues(alpha: 0.12),
        colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: colorScheme.primary.withValues(alpha: 0.14),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              StatusPill(
                icon: Icons.check_circle_outline,
                label: statusLabel,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colorScheme.primary.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
