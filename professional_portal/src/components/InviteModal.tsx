import React, { useMemo, useState } from 'react';
import { createPortal } from 'react-dom';
import { Check, Copy, History, Link, QrCode, ShieldAlert, UserPlus, X } from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { usePortalI18n } from '../lib/portal-i18n';
import { useCreateInvite } from '../hooks/mutations/useCreateInvite';
import { useClients } from '../hooks/queries/useClients';
import { useInvites } from '../hooks/queries/useInvites';
import { formatPortalDate } from '../lib/date';
import { toast } from '../lib/toast';
import { getBillingSummary } from '../view-models/professional';

interface InviteModalProps {
  onClose: () => void;
}

export const InviteModal: React.FC<InviteModalProps> = ({ onClose }) => {
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();
  const [newCode, setNewCode] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);
  const [showQr, setShowQr] = useState(false);
  const { data: invites, isLoading } = useInvites(professional?.id);
  const { data: clients = [] } = useClients(professional?.id);

  const createInviteMutation = useCreateInvite();
  const connectedClients = clients.filter((client) => client.status === 'connected').length;
  const billingSummary = useMemo(
    () => getBillingSummary(professional, connectedClients),
    [connectedClients, professional],
  );
  const pendingInvites = useMemo(
    () =>
      (invites ?? []).filter(
        (invite) => invite.status === 'pending' && new Date(invite.expires_at) >= new Date(),
      ).length,
    [invites],
  );
  const billingStatusLabel =
    billingSummary.proStatus === 'trialing'
      ? t('components.billingpanel.trial_active')
      : billingSummary.proStatus === 'active'
        ? t('components.billingpanel.active')
        : billingSummary.proStatus === 'past_due'
          ? t('components.billingpanel.past_due')
          : billingSummary.proStatus === 'canceled'
            ? t('components.billingpanel.canceled')
            : t('components.billingpanel.inactive');

  const blockReason = !billingSummary.canOperatePractice
    ? t('components.invitemodal.billing_not_active')
    : billingSummary.atCapacity
      ? t('components.invitemodal.client_capacity_full')
      : null;

  const handleCreateInvite = () => {
    if (!professional) {
      toast.error(t('components.invitemodal.save_your_profile_first'));
      return;
    }
    if (!billingSummary.canOperatePractice) {
      toast.error(
        t('components.invitemodal.professional_subscription_must_be_active_to_create_invites'),
      );
      return;
    }
    if (billingSummary.atCapacity) {
      toast.error(t('components.invitemodal.client_capacity_reached_for_the_current_tier'));
      return;
    }

    createInviteMutation.mutate(professional.id, {
      onSuccess: (data) => {
        setNewCode(data.invite_code);
        setShowQr(false);
        toast.success(t('components.invitemodal.invite_code_generated'));
      },
      onError: (err: any) => {
        toast.error(t('components.invitemodal.failed_to_create_invite'), {
          description: err?.message || t('components.invitemodal.unknown_error'),
        });
      },
    });
  };

  const copyToClipboard = (code: string) => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    toast.success(t('components.invitemodal.code_copied'));
    setTimeout(() => setCopied(false), 2000);
  };

  return createPortal(
    <div
      className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto bg-background/70 p-4 py-8 backdrop-blur-md animate-fade-in-up"
      onClick={onClose}
    >
      <div
        className="portal-panel my-auto relative flex w-full max-w-3xl flex-col rounded-[1.8rem] p-6 shadow-2xl select-none"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="pointer-events-none absolute right-0 top-0 h-32 w-32 rounded-full bg-primary/5 blur-3xl" />

        <div className="mb-6 flex items-center justify-between border-b border-border pb-4">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <UserPlus className="h-4.5 w-4.5 stroke-[3]" />
            </div>
            <div>
              <h3 className="text-base font-bold tracking-tight text-foreground">
                {t('components.invitemodal.invite_client')}
              </h3>
              <p className="mt-0.5 text-[10px] font-semibold text-muted-foreground">
                {t('components.invitemodal.link_accounts_using_connection_codes')}
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="flex h-8 w-8 items-center justify-center rounded-xl border border-border text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
            title={t('components.invitemodal.close_modal')}
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="grid gap-5 xl:grid-cols-[1.1fr_0.9fr]">
          <div className="space-y-5">
            {blockReason && (
              <div className="flex items-start gap-3 rounded-2xl border border-amber-500/25 bg-amber-500/10 p-4 text-xs font-semibold leading-relaxed text-amber-800 dark:text-amber-100">
                <ShieldAlert className="mt-0.5 h-4 w-4 shrink-0 text-amber-500" />
                <div className="space-y-1">
                  <p className="text-sm font-bold text-foreground">
                    {t('components.invitemodal.you_cannot_invite_right_now')}
                  </p>
                  <p>
                    {t('components.invitemodal.new_invites_blocked_until_billing_and_slot', {
                      reason: blockReason,
                    })}
                  </p>
                </div>
              </div>
            )}

            <div className="grid gap-3 sm:grid-cols-2">
              <CapacityCard
                label={t('components.invitemodal.current_capacity')}
                value={`${connectedClients}/${billingSummary.clientLimit}`}
                note={t('components.invitemodal.slots_remaining', {
                  count: billingSummary.remainingClientSlots,
                })}
              />
              <CapacityCard
                label={t('components.invitemodal.pending_invites_summary')}
                value={String(pendingInvites)}
                note={t('components.invitemodal.pending_does_not_guarantee_acceptance')}
              />
              <CapacityCard
                label={t('components.invitemodal.access_status_summary')}
                value={billingStatusLabel}
                note={
                  billingSummary.canOperatePractice
                    ? t('components.invitemodal.invite_creation_enabled')
                    : t('components.invitemodal.billing_reactivation_required_first')
                }
              />
              <CapacityCard
                label={t('components.invitemodal.operational_mode')}
                value={
                  billingSummary.canOperatePractice
                    ? t('components.invitemodal.can_invite')
                    : t('components.invitemodal.blocked')
                }
                note={
                  billingSummary.atCapacity
                    ? t('components.invitemodal.capacity_is_current_bottleneck')
                    : t('components.invitemodal.invites_are_controlled_by_roster')
                }
              />
            </div>

            <div className="portal-soft-panel rounded-2xl p-5 text-center">
              {!newCode ? (
                <>
                  <div className="mx-auto mb-3 flex h-11 w-11 items-center justify-center rounded-xl border border-border bg-background text-muted-foreground">
                    <Link className="h-4.5 w-4.5" />
                  </div>
                  <p className="mx-auto mb-2 max-w-md text-sm font-semibold text-foreground">
                    {t('components.invitemodal.create_one_invite_when_ready')}
                  </p>
                  <p className="mx-auto mb-4 max-w-md text-sm font-medium leading-relaxed text-muted-foreground">
                    {t('components.invitemodal.client_enters_code_in_app')}
                  </p>
                  <p className="mb-4 text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                    {t('components.invitemodal.active_clients_and_open_slots', {
                      connected: connectedClients,
                      remaining: billingSummary.remainingClientSlots,
                    })}
                  </p>
                  <button
                    onClick={handleCreateInvite}
                    disabled={createInviteMutation.isPending || !billingSummary.canInviteClients}
                    className="inline-flex items-center gap-2 rounded-xl bg-primary px-5 py-2.5 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground transition-opacity hover:opacity-95 disabled:cursor-not-allowed disabled:opacity-50"
                  >
                    <UserPlus className="h-4 w-4 stroke-[3]" />
                    <span>
                      {createInviteMutation.isPending
                        ? t('components.invitemodal.generating')
                        : t('components.invitemodal.generate_invite_code')}
                    </span>
                  </button>
                </>
              ) : (
                <div className="flex w-full flex-col items-center">
                  <p className="mb-3 text-[9px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                    {t('components.invitemodal.invite_issued_and_pending_acceptance')}
                  </p>
                  <div className="inline-flex w-full items-center justify-between gap-3 rounded-xl border border-border bg-background px-4 py-3">
                    <span className="select-all pl-2 font-mono text-xl font-black tracking-[0.2em] text-foreground">
                      {newCode}
                    </span>
                    <div className="flex gap-1">
                      <button
                        onClick={() => copyToClipboard(newCode)}
                        className="rounded-lg p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                        title={t('components.invitemodal.copy_code')}
                      >
                        {copied ? <Check className="h-4 w-4 text-primary" /> : <Copy className="h-4 w-4" />}
                      </button>
                      <button
                        onClick={() => setShowQr((prev) => !prev)}
                        className={`rounded-lg p-2 transition-colors ${
                          showQr
                            ? 'bg-primary/10 text-primary'
                            : 'text-muted-foreground hover:bg-accent hover:text-foreground'
                        }`}
                        title={t('components.invitemodal.toggle_qr_code')}
                      >
                        <QrCode className="h-4 w-4" />
                      </button>
                    </div>
                  </div>

                  {showQr && (
                    <div className="mt-4 flex flex-col items-center rounded-2xl border border-border bg-white p-4 shadow-inner animate-fade-in-up">
                      <QRCode value={newCode} size={150} />
                      <p className="mt-2.5 select-none text-[9px] font-bold uppercase tracking-[0.16em] text-[#08080a]">
                        {t('components.invitemodal.scan_in_mobile_app')}
                      </p>
                    </div>
                  )}

                  <p className="mt-4 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
                    {t('components.invitemodal.expires_in_14_days')}
                  </p>
                  <p className="mt-2 max-w-md text-xs leading-relaxed text-muted-foreground">
                    {t('components.invitemodal.copy_code_or_show_qr')}
                  </p>

                  <div className="mt-4 w-full border-t border-border pt-4">
                    <button
                      onClick={handleCreateInvite}
                      disabled={createInviteMutation.isPending || !billingSummary.canInviteClients}
                      className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground transition-colors hover:text-foreground disabled:cursor-not-allowed disabled:opacity-50"
                    >
                      {t('components.invitemodal.generate_another_invite')}
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>

          <div className="portal-soft-panel space-y-4 rounded-2xl p-5">
            <h4 className="flex items-center gap-2 text-xs font-bold text-foreground">
              <History className="h-4 w-4 text-primary" />
              <span>{t('components.invitemodal.invite_history')}</span>
            </h4>

            <div className="rounded-xl border border-border bg-background p-4 text-xs leading-relaxed text-muted-foreground">
              {t('components.invitemodal.private_beta_loop_explained')}
            </div>

            {isLoading ? (
              <div className="space-y-2">
                {[1, 2, 3].map((i) => (
                  <div key={i} className="h-16 animate-pulse rounded-xl border border-border bg-background" />
                ))}
              </div>
            ) : !invites?.length ? (
              <p className="py-6 text-center text-sm font-medium text-muted-foreground">
                {t('components.invitemodal.no_connection_codes_generated_yet')}
              </p>
            ) : (
              <div className="max-h-[420px] space-y-2 overflow-y-auto pr-1">
                {invites.map((inv) => {
                  const expired = new Date(inv.expires_at) < new Date();
                  const visualStatus = expired && inv.status === 'pending' ? 'expired' : inv.status;

                  return (
                    <div
                      key={inv.id}
                      className="rounded-xl border border-border bg-background p-3 transition-colors hover:bg-accent"
                    >
                      <div className="flex items-center justify-between gap-3">
                        <div className="flex min-w-0 items-center gap-2">
                          <span className="select-all font-mono text-xs font-bold tracking-wider text-foreground">
                            {inv.invite_code}
                          </span>
                          <StatusBadge status={visualStatus} />
                        </div>
                        <button
                          onClick={() => copyToClipboard(inv.invite_code)}
                          className="rounded-lg p-1 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                          title={t('components.invitemodal.copy_code')}
                        >
                          <Copy className="h-3.5 w-3.5" />
                        </button>
                      </div>
                      <div className="mt-2 flex flex-wrap items-center gap-x-3 gap-y-1 text-[10px] font-semibold text-muted-foreground">
                        <span>
                          {t('components.invitemodal.created_label')}{' '}
                          {formatPortalDate(inv.created_at, locale, {
                            month: 'short',
                            day: 'numeric',
                          })}
                        </span>
                        <span>
                          {t('components.invitemodal.expires_label')}{' '}
                          {formatPortalDate(inv.expires_at, locale, {
                            month: 'short',
                            day: 'numeric',
                          })}
                        </span>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>,
    document.body,
  );
};

const CapacityCard: React.FC<{ label: string; value: string; note: string }> = ({
  label,
  value,
  note,
}) => (
  <div className="portal-soft-panel rounded-2xl p-4">
    <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
      {label}
    </p>
    <p className="mt-2 text-lg font-extrabold text-foreground">{value}</p>
    <p className="mt-1 text-xs leading-relaxed text-muted-foreground">{note}</p>
  </div>
);

const StatusBadge: React.FC<{ status: string }> = ({ status }) => {
  const { t } = usePortalI18n();
  const className =
    status === 'accepted'
      ? 'border border-emerald-500/20 bg-emerald-500/10 text-emerald-600 dark:text-emerald-300'
      : status === 'revoked'
        ? 'border border-slate-500/20 bg-slate-500/10 text-slate-600 dark:text-slate-300'
        : status === 'expired'
          ? 'border border-rose-500/20 bg-rose-500/10 text-rose-500'
          : 'border border-primary/20 bg-primary/10 text-primary';
  const label =
    status === 'accepted'
      ? t('components.invitemodal.accepted')
      : status === 'revoked'
        ? t('components.invitemodal.revoked')
        : status === 'expired'
          ? t('components.invitemodal.expired')
          : t('components.invitemodal.active');

  return (
    <span className={`rounded-md px-1.5 py-0.5 text-[8px] font-bold uppercase tracking-[0.16em] ${className}`}>
      {label}
    </span>
  );
};

function QRCode({ value, size }: { value: string; size: number }) {
  const canvasRef = React.useRef<HTMLCanvasElement>(null);

  React.useEffect(() => {
    import('qrcode').then((mod) => {
      if (canvasRef.current) {
        mod.toCanvas(canvasRef.current, value, {
          width: size,
          margin: 1,
          color: { dark: '#08080a', light: '#ffffff' },
        });
      }
    });
  }, [value, size]);

  return <canvas ref={canvasRef} style={{ width: size, height: size }} className="mx-auto rounded-lg" />;
}
