import 'dart:async';

import 'package:flutter/material.dart';
import 'package:macrotracker/core/services/cloud_account_service.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/utils/locator.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfessionalPlanScreen extends StatefulWidget {
  final bool isEmbedded;

  const ProfessionalPlanScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<ProfessionalPlanScreen> createState() => _ProfessionalPlanScreenState();
}

class ProfessionalPlanScreenArguments {
  final String inviteCode;
  final bool preferEmbeddedTabAfterAccept;
  final ProfessionalHubTab? initialTab;

  const ProfessionalPlanScreenArguments({
    this.inviteCode = '',
    this.preferEmbeddedTabAfterAccept = false,
    this.initialTab,
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
  bool _acceptingInvite = false;
  bool _sendingMessage = false;
  bool _handledRouteArguments = false;
  String? _pendingProtectedInviteCode;
  StreamSubscription<AuthState>? _authSubscription;
  String? _error;
  ProfessionalHubTab _selectedTab = ProfessionalHubTab.summary;
  Timer? _autoRefreshTimer;

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
    _authSubscription =
        locator<SupabaseClient>().auth.onAuthStateChange.listen(
      (_) {
        unawaited(_resumePendingInviteAfterAuth());
      },
      onError: (error) {
        debugPrint('Auth error in professional plan screen: $error');
        if (!mounted) return;
        final isConflict = error is AuthException &&
            (error.statusCode == 'email_exists' ||
                error.message.toLowerCase().contains('already') ||
                error.toString().contains('email_exists'));
        if (isConflict) {
          _showSignInDialog();
        }
      },
    );
    _loadSection(refreshRemotePlan: true);
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (mounted && _connection != null) {
        _loadSection(
          refreshRemotePlan: true,
          preserveSelectedTab: true,
          isBackground: true,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledRouteArguments) {
      return;
    }
    _handledRouteArguments = true;
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is ProfessionalPlanScreenArguments) {
      if (arguments.initialTab != null) {
        _selectedTab = arguments.initialTab!;
      }
    }
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
    _autoRefreshTimer?.cancel();
    _authSubscription?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasInviteConsentPreview =
        _invitePreview != null && !_invitePreview!.isExpired;
    return Scaffold(
      appBar: widget.isEmbedded
          ? null
          : AppBar(
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
                    if (!hasInviteConsentPreview) ...[
                      _SectionHero(
                        title: S.of(context).professionalHeroConnectTitle,
                        subtitle:
                            S.of(context).professionalSectionConnectSubtitle,
                        icon: Icons.medical_services_outlined,
                        pillLabels: [
                          (
                            icon: Icons.key_outlined,
                            label: S.of(context).professionalInvitePillInvite,
                          ),
                          (
                            icon: Icons.shield_outlined,
                            label: S.of(context).professionalInvitePillConsent,
                          ),
                          (
                            icon: Icons.lock_clock_outlined,
                            label:
                                S.of(context).professionalInvitePillClearPrivacy,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    InviteEntryView(
                      codeController: _codeController,
                      invitePreview: _invitePreview,
                      error: _error,
                      isBusy: _protectingAccount || _acceptingInvite,
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
                      onDismissPlanUpdate: _dismissPlanUpdate,
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
    bool isBackground = false,
  }) async {
    if (!isBackground) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
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
          _protectingAccount = false;
          _acceptingInvite = false;
        });
        return;
      }
      final sharingScope = await _getProfessionalSharingScopeUsecase.execute(
        connection: summary.connection,
      );
      final messages = await _getProfessionalMessagesUsecase.execute(
        connection: summary.connection,
      );
      if (!isBackground) {
        await _markProfessionalSectionSeenUsecase.execute(
          connection: summary.connection,
        );
      }
      if (!mounted) return;
      setState(() {
        _connection = summary.connection;
        _summary = summary;
        _sharingScope = sharingScope;
        _messages = messages;
        if (!preserveSelectedTab && !_hasInitialTabArgument) {
          _selectedTab = ProfessionalHubTab.summary;
        }
        _loading = false;
        _protectingAccount = false;
        _acceptingInvite = false;
      });
    } catch (error) {
      if (!mounted) return;
      if (!isBackground) {
        setState(() {
          _error = friendlyError(context, error);
          _loading = false;
          _protectingAccount = false;
          _acceptingInvite = false;
        });
      }
    }
  }

  Future<void> _dismissPlanUpdate() async {
    if (_connection == null) return;
    try {
      await _markProfessionalSectionSeenUsecase.execute(
        connection: _connection!,
      );
      await _loadSection(preserveSelectedTab: true, isBackground: true);
    } catch (error) {
      debugPrint('Error dismissing plan update: $error');
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
    final inviteCode = _codeController.text.trim();
    if (inviteCode.isEmpty) {
      return;
    }
    final accountReady = await _ensureProtectedAccountForConnection(inviteCode);
    if (!accountReady) {
      return;
    }
    await _acceptInviteNow(inviteCode);
  }

  Future<void> _acceptInviteNow(String inviteCode) async {
    setState(() {
      _acceptingInvite = true;
      _protectingAccount = false;
      _error = null;
    });
    try {
      final connection =
          await _acceptProfessionalInviteUsecase.acceptInvite(inviteCode);
      await locator<ConversionAnalyticsService>().logEvent(
        'professional_invite_accepted',
        parameters: {
          'professional_id': connection.professionalId,
          'relationship_id': connection.relationshipId,
        },
      );
      if (_shouldReturnToEmbeddedTab) {
        if (!mounted) return;
        _pendingProtectedInviteCode = null;
        Navigator.of(context).pop(true);
        return;
      }
      _pendingProtectedInviteCode = null;
      await _loadSection(refreshRemotePlan: false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(context, error);
        _acceptingInvite = false;
      });
    }
  }

  Future<bool> _ensureProtectedAccountForConnection(String inviteCode) async {
    try {
      final accountService = locator<CloudAccountService>();
      final status = await accountService.getStatus();
      if (status.isProtected) {
        return true;
      }

      if (!mounted) return false;
      setState(() {
        _protectingAccount = true;
        _pendingProtectedInviteCode = inviteCode;
        _error = null;
      });

      final opened = await accountService.protectWithGoogle();
      if (!mounted) {
        return false;
      }
      if (!opened) {
        setState(() {
          _protectingAccount = false;
          _pendingProtectedInviteCode = null;
          _error = S.of(context).professionalProtectAccountOpenError;
        });
      } else {
        setState(() => _protectingAccount = false);
        _showSnackBar(S.of(context).professionalProtectAccountReturnHint);
      }
      return false;
    } catch (error) {
      if (!mounted) return false;
      setState(() {
        _protectingAccount = false;
        _pendingProtectedInviteCode = null;
        _error = friendlyError(context, error);
      });
      return false;
    }
  }

  Future<void> _resumePendingInviteAfterAuth() async {
    final inviteCode = _pendingProtectedInviteCode;
    if (inviteCode == null || _acceptingInvite) {
      return;
    }
    try {
      final status = await locator<CloudAccountService>().getStatus();
      if (!status.isProtected) {
        return;
      }
      await _acceptInviteNow(inviteCode);
    } catch (_) {
      if (!mounted) return;
      setState(() => _protectingAccount = false);
    }
  }

  Future<void> _showSignInDialog() async {
    final copy = S.of(context);
    final title = copy.settingsAccountAlreadyRegisteredTitle;
    final content = copy.settingsAccountAlreadyRegisteredBody;
    final cancelLabel = copy.dialogCancelLabel;
    final confirmLabel = copy.settingsAccountAlreadyRegisteredConfirm;

    final bool? shouldSignIn = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    if (shouldSignIn == true && mounted) {
      try {
        final opened = await locator<CloudAccountService>().signInWithGoogle();
        if (!mounted) return;
        if (!opened) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).paywallGoogleOpenFailed),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).paywallGoogleLinkStartFailed),
          ),
        );
      }
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

  bool get _shouldReturnToEmbeddedTab {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return arguments is ProfessionalPlanScreenArguments &&
        arguments.preferEmbeddedTabAfterAccept &&
        Navigator.of(context).canPop();
  }

  bool get _hasInitialTabArgument {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return arguments is ProfessionalPlanScreenArguments &&
        arguments.initialTab != null;
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
            ? S.of(context).professionalSharingDetailedEnabled
            : S.of(context).professionalSharingAggregateEnabled,
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
      return S.of(context).professionalSharingModeOfflineError;
    }
    if (raw.contains('permission') ||
        raw.contains('row-level security') ||
        raw.contains('not return a relationship row') ||
        raw.contains('blocked by permissions')) {
      return S.of(context).professionalSharingModePermissionError;
    }
    if (raw.contains('not persisted') ||
        raw.contains('expected "detailed"') ||
        raw.contains('expected "aggregate"')) {
      return S.of(context).professionalSharingModeNotPersistedError;
    }
    if (raw.contains('authentication') ||
        raw.contains('jwt') ||
        raw.contains('session') ||
        raw.contains('unauthorized') ||
        raw.contains('forbidden')) {
      return S.of(context).professionalSharingModeSessionError;
    }
    return S.of(context).professionalSharingModeGenericError;
  }

  Future<void> _updateDailyNote(String note) async {
    final connection = _connection;
    if (connection == null) return;
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
      await _loadSection(refreshRemotePlan: false, isBackground: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(context, e);
      });
      rethrow;
    }
  }
}

class _SectionHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<({IconData icon, String label})> pillLabels;

  const _SectionHero({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.pillLabels = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Panel(
      accent: Color.alphaBlend(
        colorScheme.primary.withValues(alpha: 0.10),
        colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── icon ─────────────────────────────────────────────────────
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: colorScheme.primary.withValues(alpha: 0.14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(height: 12),
          // ── title ────────────────────────────────────────────────────
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  height: 1.15,
                ),
          ),
          const SizedBox(height: 6),
          // ── subtitle ─────────────────────────────────────────────────
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
          // ── feature pills ────────────────────────────────────────────
          if (pillLabels.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final pill in pillLabels)
                  StatusPill(icon: pill.icon, label: pill.label),
              ],
            ),
          ],
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
