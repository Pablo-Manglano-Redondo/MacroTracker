import 'package:flutter/material.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/accept_professional_invite_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/disconnect_professional_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_plan_usecase.dart';

class ProfessionalPlanScreen extends StatefulWidget {
  const ProfessionalPlanScreen({super.key});

  @override
  State<ProfessionalPlanScreen> createState() => _ProfessionalPlanScreenState();
}

class ProfessionalPlanScreenArguments {
  final String inviteCode;

  const ProfessionalPlanScreenArguments({required this.inviteCode});
}

class _ProfessionalPlanScreenState extends State<ProfessionalPlanScreen> {
  final _codeController = TextEditingController();
  late final GetProfessionalPlanUsecase _getProfessionalPlanUsecase;
  late final AcceptProfessionalInviteUsecase _acceptProfessionalInviteUsecase;
  late final DisconnectProfessionalUsecase _disconnectProfessionalUsecase;

  ProfessionalConnectionEntity? _connection;
  ProfessionalInvitePreviewEntity? _invitePreview;
  bool _loading = true;
  bool _handledRouteArguments = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getProfessionalPlanUsecase = locator<GetProfessionalPlanUsecase>();
    _acceptProfessionalInviteUsecase =
        locator<AcceptProfessionalInviteUsecase>();
    _disconnectProfessionalUsecase = locator<DisconnectProfessionalUsecase>();
    _loadConnection();
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
        if (mounted) {
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
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    return Scaffold(
      appBar: AppBar(
        title: Text(isEs ? 'Plan de mi nutricionista' : 'My coach plan'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (_connection != null)
                  _ConnectedPlanView(
                    connection: _connection!,
                    onRefresh: _loadConnection,
                    onDisconnect: _disconnect,
                  )
                else
                  _InviteEntryView(
                    codeController: _codeController,
                    invitePreview: _invitePreview,
                    error: _error,
                    onPreviewInvite: _previewInvite,
                    onAcceptInvite: _acceptInvite,
                  ),
              ],
            ),
    );
  }

  Future<void> _loadConnection() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final connection = await _getProfessionalPlanUsecase.getActiveConnection(
        refreshRemotePlan: true,
      );
      if (!mounted) return;
      setState(() {
        _connection = connection;
        _loading = false;
      });
    } catch (error) {
      final cachedConnection =
          await _getProfessionalPlanUsecase.getActiveConnection();
      if (!mounted) return;
      setState(() {
        _connection = cachedConnection;
        _error =
            cachedConnection == null ? _friendlyError(context, error) : null;
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
      if (!mounted) return;
      setState(() {
        _invitePreview = invite;
        _error = invite == null
            ? _copy(
                context,
                es: 'No se ha encontrado una invitacion pendiente con ese codigo.',
                en: 'No pending invite was found for that code.',
              )
            : invite.isExpired
                ? _copy(
                    context,
                    es: 'La invitacion ha expirado.',
                    en: 'This invite has expired.',
                  )
                : null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyError(context, error);
        _loading = false;
      });
    }
  }

  Future<void> _acceptInvite() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final connection = await _acceptProfessionalInviteUsecase
          .acceptInvite(_codeController.text);
      if (!mounted) return;
      setState(() {
        _connection = connection;
        _invitePreview = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyError(context, error);
        _loading = false;
      });
    }
  }

  Future<void> _disconnect() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_copy(
          context,
          es: 'Desconectar profesional',
          en: 'Disconnect professional',
        )),
        content: Text(_copy(
          context,
          es: 'Se revocara el acceso y se detendra la sincronizacion de resumenes agregados.',
          en: 'Access will be revoked and aggregate snapshot sync will stop.',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_copy(context, es: 'Cancelar', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_copy(context, es: 'Desconectar', en: 'Disconnect')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _loading = true);
    await _disconnectProfessionalUsecase.disconnect();
    if (!mounted) return;
    setState(() {
      _connection = null;
      _loading = false;
    });
  }
}

class _InviteEntryView extends StatelessWidget {
  final TextEditingController codeController;
  final ProfessionalInvitePreviewEntity? invitePreview;
  final String? error;
  final VoidCallback onPreviewInvite;
  final VoidCallback onAcceptInvite;

  const _InviteEntryView({
    required this.codeController,
    required this.invitePreview,
    required this.error,
    required this.onPreviewInvite,
    required this.onAcceptInvite,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoCard(
          icon: Icons.verified_user_outlined,
          title: _copy(
            context,
            es: 'Conecta solo con invitacion',
            en: 'Connect by invite only',
          ),
          body: _copy(
            context,
            es: 'Introduce el codigo que te ha dado tu nutricionista. Antes de conectar veras exactamente que datos se comparten.',
            en: 'Enter the code from your coach. Before connecting, you will see exactly what data is shared.',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: codeController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText:
                _copy(context, es: 'Codigo de invitacion', en: 'Invite code'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.key_outlined),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onPreviewInvite,
          icon: const Icon(Icons.search_outlined),
          label: Text(
              _copy(context, es: 'Revisar invitacion', en: 'Review invite')),
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(error!, style: TextStyle(color: colorScheme.error)),
        ],
        if (invitePreview != null && !invitePreview!.isExpired) ...[
          const SizedBox(height: 18),
          _ConsentCard(
            invitePreview: invitePreview!,
            onAcceptInvite: onAcceptInvite,
          ),
        ],
      ],
    );
  }
}

class _ConsentCard extends StatelessWidget {
  final ProfessionalInvitePreviewEntity invitePreview;
  final VoidCallback onAcceptInvite;

  const _ConsentCard({
    required this.invitePreview,
    required this.onAcceptInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invitePreview.professionalName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            _ConsentRow(
              text: _copy(
                context,
                es: 'Compartiras kcal, macros, dias registrados y adherencia agregada.',
                en: 'You will share calories, macros, logged days, and aggregate adherence.',
              ),
            ),
            _ConsentRow(
              text: _copy(
                context,
                es: 'No se comparte el diario bruto ni comidas completas en esta version.',
                en: 'Raw diary entries and full meals are not shared in this version.',
              ),
            ),
            _ConsentRow(
              text: _copy(
                context,
                es: 'Puedes revocar el acceso en cualquier momento.',
                en: 'You can revoke access at any time.',
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAcceptInvite,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(_copy(
                context,
                es: 'Aceptar y conectar',
                en: 'Accept and connect',
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectedPlanView extends StatelessWidget {
  final ProfessionalConnectionEntity connection;
  final VoidCallback onRefresh;
  final VoidCallback onDisconnect;

  const _ConnectedPlanView({
    required this.connection,
    required this.onRefresh,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final plan = connection.activePlan;
    final todayTarget = plan?.targetForDate(DateTime.now());
    final colorScheme = Theme.of(context).colorScheme;
    final suggestedMeals = plan?.meals.take(3).toList() ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.08),
            colorScheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: colorScheme.primary.withValues(alpha: 0.14),
                      ),
                      child: Icon(
                        Icons.handshake_outlined,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            connection.professionalName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _copy(
                              context,
                              es: 'Conexion activa. Tus resumenes agregados se sincronizan con consentimiento.',
                              en: 'Connection active. Your aggregate snapshots sync with consent.',
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusPill(
                      icon: Icons.shield_outlined,
                      label: _copy(
                        context,
                        es: 'Solo agregados',
                        en: 'Aggregate only',
                      ),
                    ),
                    _StatusPill(
                      icon: Icons.link_off_outlined,
                      label: _copy(
                        context,
                        es: 'Revocable',
                        en: 'Revocable',
                      ),
                    ),
                    _StatusPill(
                      icon: Icons.today_outlined,
                      label: _copy(
                        context,
                        es: 'Objetivos diarios',
                        en: 'Daily targets',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _copy(context, es: 'Plan actual', en: 'Current plan'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  plan?.name ??
                      _copy(context,
                          es: 'Sin plan activo', en: 'No active plan'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (plan?.objective.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    plan!.objective,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 16),
                if (todayTarget != null)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _TargetTile(
                        label: 'Kcal',
                        value: todayTarget.kcalGoal.round().toString(),
                        color: colorScheme.primary,
                      ),
                      _TargetTile(
                        label: _copy(context, es: 'Proteina', en: 'Protein'),
                        value: '${todayTarget.proteinGoal.round()}g',
                        color: colorScheme.tertiary,
                      ),
                      _TargetTile(
                        label: _copy(context, es: 'Carbos', en: 'Carbs'),
                        value: '${todayTarget.carbsGoal.round()}g',
                        color: colorScheme.secondary,
                      ),
                      _TargetTile(
                        label: _copy(context, es: 'Grasa', en: 'Fat'),
                        value: '${todayTarget.fatGoal.round()}g',
                        color: colorScheme.error,
                      ),
                    ],
                  )
                else
                  Text(_copy(
                    context,
                    es: 'Cuando tu nutricionista publique un plan activo aparecera aqui.',
                    en: 'When your coach publishes an active plan it will appear here.',
                  )),
              ],
            ),
          ),
        ),
        if (suggestedMeals.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _copy(
                      context,
                      es: 'Comidas sugeridas',
                      en: 'Suggested meals',
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  for (final meal in suggestedMeals)
                    _SuggestedMealRow(
                      slot: meal.slot,
                      title: meal.title,
                      kcal: meal.kcal?.round(),
                    ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_outlined),
              label: Text(
                  _copy(context, es: 'Actualizar plan', en: 'Refresh plan')),
            ),
            TextButton.icon(
              onPressed: onDisconnect,
              icon: const Icon(Icons.link_off_outlined),
              label: Text(
                  _copy(context, es: 'Revocar acceso', en: 'Revoke access')),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.surfaceContainerHigh,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _TargetTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TargetTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.09),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedMealRow extends StatelessWidget {
  final String slot;
  final String title;
  final int? kcal;

  const _SuggestedMealRow({
    required this.slot,
    required this.title,
    required this.kcal,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalizedSlot = slot.trim().isEmpty ? '-' : slot.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colorScheme.secondaryContainer,
            ),
            child: Icon(
              Icons.restaurant_menu_outlined,
              size: 18,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  kcal == null
                      ? normalizedSlot
                      : '$normalizedSlot - $kcal kcal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
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
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  final String text;

  const _ConsentRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

String _copy(BuildContext context, {required String es, required String en}) {
  return Localizations.localeOf(context).languageCode == 'es' ? es : en;
}

String _friendlyError(BuildContext context, Object error) {
  final raw = error.toString();
  final isEs = Localizations.localeOf(context).languageCode == 'es';
  if (raw.contains('SocketException') ||
      raw.contains('ClientException') ||
      raw.contains('Failed host lookup') ||
      raw.contains('Network')) {
    return isEs
        ? 'No se pudo conectar. Revisa la conexion e intentalo de nuevo.'
        : 'Could not connect. Check your connection and try again.';
  }
  if (raw.contains('anonymous auth') || raw.contains('Authentication')) {
    return isEs
        ? 'No se pudo crear la identidad cloud necesaria para conectar el plan.'
        : 'Could not create the cloud identity required to connect the plan.';
  }
  if (raw.contains('expired')) {
    return isEs ? 'La invitacion ha expirado.' : 'This invite has expired.';
  }
  return isEs
      ? 'No se pudo completar la accion. Intentalo de nuevo.'
      : 'The action could not be completed. Try again.';
}
