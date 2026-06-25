import React, { useMemo, useState } from 'react';
import { createPortal } from 'react-dom';
import { Check, Copy, History, QrCode, ShieldAlert, UserPlus, X } from 'lucide-react';
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
        className="portal-panel my-auto relative flex w-full max-w-3xl flex-col rounded-[1.8rem] p-8 shadow-2xl select-none"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="pointer-events-none absolute right-0 top-0 h-32 w-32 rounded-full bg-primary/5 blur-3xl" />

        {/* Header */}
        <div className="mb-8 flex items-center justify-between border-b border-border pb-6">
          <div className="flex items-center gap-4">
            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <UserPlus className="h-6 w-6 stroke-[2]" />
            </div>
            <div>
              <h3 className="text-2xl font-black uppercase tracking-[0.12em] text-foreground">
                {t('components.invitemodal.invite_client')}
              </h3>
              <p className="mt-1 text-sm font-semibold text-muted-foreground">
                {t('components.invitemodal.link_accounts_using_connection_codes')}
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="flex h-10 w-10 items-center justify-center rounded-xl border border-border text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
            title={t('components.invitemodal.close_modal')}
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="grid gap-8 md:grid-cols-[1fr_1px_1fr]">
          {/* Left — Generate code */}
          <div className="flex flex-col gap-5">
            {/* Capacity pill */}
            <div className="flex items-center gap-2.5 text-sm font-semibold text-muted-foreground">
              <span className="inline-flex h-7 items-center rounded-full border border-border bg-accent px-3 font-mono text-sm font-bold text-foreground">
                {connectedClients}/{billingSummary.clientLimit}
              </span>
              <span>
                {t('components.invitemodal.slots_remaining', {
                  count: billingSummary.remainingClientSlots,
                })}
              </span>
            </div>

            {/* Block warning */}
            {blockReason && (
              <div className="flex items-start gap-3 rounded-2xl border border-amber-500/25 bg-amber-500/10 p-4 text-sm font-semibold leading-relaxed text-amber-800 dark:text-amber-100">
                <ShieldAlert className="mt-0.5 h-5 w-5 shrink-0 text-amber-500" />
                <p>{blockReason}</p>
              </div>
            )}

            {/* Code area */}
            <div className="portal-soft-panel flex flex-1 flex-col items-center justify-center gap-5 rounded-2xl p-8 text-center">
              {!newCode ? (
                <>
                  <p className="text-lg font-extrabold text-foreground">
                    {t('components.invitemodal.create_one_invite_when_ready')}
                  </p>
                  <p className="text-base font-semibold leading-relaxed text-muted-foreground">
                    {t('components.invitemodal.client_enters_code_in_app')}
                  </p>
                  <button
                    onClick={handleCreateInvite}
                    disabled={createInviteMutation.isPending || !billingSummary.canInviteClients}
                    className="inline-flex items-center gap-2.5 rounded-xl bg-primary px-6 py-3 text-sm font-extrabold uppercase tracking-[0.12em] text-primary-foreground transition-opacity hover:opacity-95 disabled:cursor-not-allowed disabled:opacity-50"
                  >
                    <UserPlus className="h-5 w-5 stroke-[2]" />
                    <span>
                      {createInviteMutation.isPending
                        ? t('components.invitemodal.generating')
                        : t('components.invitemodal.generate_invite_code')}
                    </span>
                  </button>
                </>
              ) : (
                <div className="flex w-full flex-col items-center gap-4">
                  <p className="text-xs font-black uppercase tracking-[0.16em] text-muted-foreground">
                    {t('components.invitemodal.invite_issued_and_pending_acceptance')}
                  </p>

                  {/* Code row */}
                  <div className="inline-flex w-full items-center justify-between gap-3 rounded-xl border border-border bg-background px-5 py-4">
                    <span className="select-all font-mono text-3xl font-black tracking-[0.25em] text-foreground">
                      {newCode}
                    </span>
                    <div className="flex gap-1">
                      <button
                        onClick={() => copyToClipboard(newCode)}
                        className="rounded-lg p-2.5 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                        title={t('components.invitemodal.copy_code')}
                      >
                        {copied ? <Check className="h-5 w-5 text-primary" /> : <Copy className="h-5 w-5" />}
                      </button>
                      <button
                        onClick={() => setShowQr((prev) => !prev)}
                        className={`rounded-lg p-2.5 transition-colors ${
                          showQr
                            ? 'bg-primary/10 text-primary'
                            : 'text-muted-foreground hover:bg-accent hover:text-foreground'
                        }`}
                        title={t('components.invitemodal.toggle_qr_code')}
                      >
                        <QrCode className="h-5 w-5" />
                      </button>
                    </div>
                  </div>

                  {showQr && (
                    <div className="flex flex-col items-center rounded-2xl border border-border bg-white p-5 shadow-inner animate-fade-in-up">
                      <QRCode value={newCode} size={180} />
                      <p className="mt-3 select-none text-xs font-black uppercase tracking-[0.16em] text-[#08080a]">
                        {t('components.invitemodal.scan_in_mobile_app')}
                      </p>
                    </div>
                  )}

                  <p className="text-xs font-black uppercase tracking-[0.16em] text-primary">
                    {t('components.invitemodal.expires_in_14_days')}
                  </p>

                  <button
                    onClick={handleCreateInvite}
                    disabled={createInviteMutation.isPending || !billingSummary.canInviteClients}
                    className="text-base font-semibold text-muted-foreground transition-colors hover:text-foreground disabled:cursor-not-allowed disabled:opacity-50"
                  >
                    {t('components.invitemodal.generate_another_invite')}
                  </button>
                </div>
              )}
            </div>
          </div>

          {/* Divider */}
          <div className="hidden md:block w-px bg-border" />

          {/* Right — History */}
          <div className="flex flex-col gap-4">
            <h4 className="flex items-center gap-2.5 text-base font-extrabold text-foreground">
              <History className="h-5 w-5 text-primary" />
              <span>{t('components.invitemodal.invite_history')}</span>
            </h4>

            {isLoading ? (
              <div className="space-y-3">
                {[1, 2, 3].map((i) => (
                  <div key={i} className="h-20 animate-pulse rounded-xl border border-border bg-background" />
                ))}
              </div>
            ) : !invites?.length ? (
              <p className="py-10 text-center text-base font-semibold text-muted-foreground">
                {t('components.invitemodal.no_connection_codes_generated_yet')}
              </p>
            ) : (
              <div className="max-h-[360px] space-y-2 overflow-y-auto pr-1">
                {invites.map((inv) => {
                  const expired = new Date(inv.expires_at) < new Date();
                  const visualStatus = expired && inv.status === 'pending' ? 'expired' : inv.status;

                  return (
                    <div
                      key={inv.id}
                      className="rounded-xl border border-border bg-background p-4 transition-colors hover:bg-accent"
                    >
                      <div className="flex items-center justify-between gap-3">
                        <div className="flex min-w-0 items-center gap-3">
                          <span className="select-all font-mono text-base font-bold tracking-wider text-foreground">
                            {inv.invite_code}
                          </span>
                          <StatusBadge status={visualStatus} />
                        </div>
                        <button
                          onClick={() => copyToClipboard(inv.invite_code)}
                          className="rounded-lg p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                          title={t('components.invitemodal.copy_code')}
                        >
                          <Copy className="h-4.5 w-4.5" />
                        </button>
                      </div>
                      <div className="mt-2.5 flex flex-wrap items-center gap-x-3 gap-y-1 text-sm font-semibold text-muted-foreground">
                        <span>
                          {t('components.invitemodal.created_label')}{' '}
                          {formatPortalDate(inv.created_at, locale, {
                            month: 'short',
                            day: 'numeric',
                          })}
                        </span>
                        {inv.status !== 'accepted' && (
                          <span>
                            {t('components.invitemodal.expires_label')}{' '}
                            {formatPortalDate(inv.expires_at, locale, {
                              month: 'short',
                              day: 'numeric',
                            })}
                          </span>
                        )}
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
    <span className={`rounded-md px-2 py-0.5 text-xs font-bold uppercase tracking-[0.12em] ${className}`}>
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
