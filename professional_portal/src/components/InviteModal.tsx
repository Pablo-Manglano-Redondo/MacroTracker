import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import {
  Check,
  Copy,
  History,
  Link,
  QrCode,
  ShieldAlert,
  UserPlus,
  X,
} from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { useCreateInvite } from '../hooks/mutations/useCreateInvite';
import { useClients } from '../hooks/queries/useClients';
import { useInvites } from '../hooks/queries/useInvites';
import { toast } from '../lib/toast';
import { getBillingSummary } from '../view-models/professional';
import { usePortalI18n } from '../lib/portal-i18n';

interface InviteModalProps {
  onClose: () => void;
}

export const InviteModal: React.FC<InviteModalProps> = ({ onClose }) => {
  const { professional } = useAuth();
  const { tr, locale } = usePortalI18n();
  const billingSummary = getBillingSummary(professional);
  const [newCode, setNewCode] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);
  const [showQr, setShowQr] = useState(false);
  const { data: invites, isLoading } = useInvites(professional?.id);
  const { data: clients = [] } = useClients(professional?.id);

  const createInviteMutation = useCreateInvite();
  const connectedClients = clients.filter((client) => client.status === 'connected').length;
  const atCapacity = connectedClients >= billingSummary.clientLimit;
  const activePro = billingSummary.hasProfessionalAccess;

  const handleCreateInvite = () => {
    if (!professional) {
      toast.error(tr('Guarda primero tu perfil.', 'Save your profile first.'));
      return;
    }
    if (!activePro) {
      toast.error(
        tr(
          'La suscripción profesional debe estar activa para crear invitaciones.',
          'Professional subscription must be active to create invites.',
        ),
      );
      return;
    }
    if (atCapacity) {
      toast.error(
        tr(
          'Has alcanzado la capacidad del tier actual.',
          'Client capacity reached for the current tier.',
        ),
      );
      return;
    }

    createInviteMutation.mutate(professional.id, {
      onSuccess: (data) => {
        setNewCode(data.invite_code);
        setShowQr(false);
        toast.success(tr('Código generado', 'Invite code generated'));
      },
      onError: (err: any) => {
        toast.error(tr('No se pudo crear la invitación', 'Failed to create invite'), {
          description: err?.message || tr('Error desconocido', 'Unknown error'),
        });
      },
    });
  };

  const copyToClipboard = (code: string) => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    toast.success(tr('Código copiado', 'Code copied'));
    setTimeout(() => setCopied(false), 2000);
  };

  return createPortal(
    <div
      className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto bg-background/70 p-4 py-8 backdrop-blur-md animate-fade-in-up"
      onClick={onClose}
    >
      <div
        className="portal-panel my-auto relative flex w-full max-w-xl flex-col rounded-[1.8rem] p-6 shadow-2xl select-none"
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
                {tr('Invitar cliente', 'Invite client')}
              </h3>
              <p className="mt-0.5 text-[10px] font-semibold text-muted-foreground">
                {tr('Vincula cuentas con códigos de conexión', 'Link accounts using connection codes')}
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="flex h-8 w-8 items-center justify-center rounded-xl border border-border text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
            title={tr('Cerrar modal', 'Close modal')}
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="space-y-5">
          {!activePro && (
            <div className="flex items-start gap-3 rounded-2xl border border-amber-500/25 bg-amber-500/10 p-4 text-xs font-semibold leading-relaxed text-amber-800 dark:text-amber-100">
              <ShieldAlert className="mt-0.5 h-4 w-4 shrink-0 text-amber-500" />
              <span>
                {tr(
                  'Necesitas una suscripción profesional activa para invitar clientes. Revisa la facturación antes de abrir nuevas relaciones.',
                  'You need an active professional subscription to invite clients. Review billing before opening new relationships.',
                )}
              </span>
            </div>
          )}
          {activePro && atCapacity && (
            <div className="flex items-start gap-3 rounded-2xl border border-amber-500/25 bg-amber-500/10 p-4 text-xs font-semibold leading-relaxed text-amber-800 dark:text-amber-100">
              <ShieldAlert className="mt-0.5 h-4 w-4 shrink-0 text-amber-500" />
              <span>
                {tr(
                  `Capacidad alcanzada: ${connectedClients}/${billingSummary.clientLimit} clientes activos en el tier ${billingSummary.tierLabel}.`,
                  `Capacity reached: ${connectedClients}/${billingSummary.clientLimit} active clients on the ${billingSummary.tierLabel} tier.`,
                )}
              </span>
            </div>
          )}

          <div className="portal-soft-panel rounded-2xl p-5 text-center">
            {!newCode ? (
              <>
                <div className="mx-auto mb-3 flex h-11 w-11 items-center justify-center rounded-xl border border-border bg-background text-muted-foreground">
                  <Link className="h-4.5 w-4.5" />
                </div>
                <p className="mx-auto mb-4 max-w-sm text-sm font-medium leading-relaxed text-muted-foreground">
                  {tr(
                    'Genera un código único de 8 caracteres. El cliente lo introducirá en la app MacroTracker, dentro de la sección Nutricionista, para vincular la relación.',
                    'Generate a unique 8-character code. The client will enter it in the MacroTracker app, inside the Nutritionist section, to link the relationship.',
                  )}
                </p>
                <p className="mb-4 text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                  {tr(
                    `${connectedClients}/${billingSummary.clientLimit} clientes activos en uso`,
                    `${connectedClients}/${billingSummary.clientLimit} active clients in use`,
                  )}
                </p>
                <button
                  onClick={handleCreateInvite}
                  disabled={createInviteMutation.isPending || !activePro || atCapacity}
                  className="inline-flex items-center gap-2 rounded-xl bg-primary px-5 py-2.5 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground transition-opacity hover:opacity-95 disabled:cursor-not-allowed disabled:opacity-50"
                >
                  <UserPlus className="h-4 w-4 stroke-[3]" />
                  <span>
                    {createInviteMutation.isPending
                      ? tr('Generando...', 'Generating...')
                      : tr('Generar código', 'Generate code')}
                  </span>
                </button>
              </>
            ) : (
              <div className="flex w-full flex-col items-center">
                <p className="mb-3 text-[9px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                  {tr('Código activo listo', 'Active invite code ready')}
                </p>
                <div className="inline-flex w-full items-center justify-between gap-3 rounded-xl border border-border bg-background px-4 py-3">
                  <span className="select-all pl-2 font-mono text-xl font-black tracking-[0.2em] text-foreground">
                    {newCode}
                  </span>
                  <div className="flex gap-1">
                    <button
                      onClick={() => copyToClipboard(newCode)}
                      className="rounded-lg p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                      title={tr('Copiar código', 'Copy code')}
                    >
                      {copied ? <Check className="h-4 w-4 text-primary" /> : <Copy className="h-4 w-4" />}
                    </button>
                    <button
                      onClick={() => setShowQr((prev) => !prev)}
                      className={`rounded-lg p-2 transition-colors ${
                        showQr ? 'bg-primary/10 text-primary' : 'text-muted-foreground hover:bg-accent hover:text-foreground'
                      }`}
                      title={tr('Mostrar QR', 'Toggle QR code')}
                    >
                      <QrCode className="h-4 w-4" />
                    </button>
                  </div>
                </div>

                {showQr && (
                  <div className="mt-4 flex flex-col items-center rounded-2xl border border-border bg-white p-4 shadow-inner animate-fade-in-up">
                    <QRCode value={newCode} size={150} />
                    <p className="mt-2.5 select-none text-[9px] font-bold uppercase tracking-[0.16em] text-[#08080a]">
                      {tr('Escanear en la app móvil', 'Scan in mobile app')}
                    </p>
                  </div>
                )}

                <p className="mt-4 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
                  {tr('Caduca en 14 días', 'Expires in 14 days')}
                </p>

                <div className="mt-4 w-full border-t border-border pt-4">
                  <button
                    onClick={handleCreateInvite}
                    disabled={createInviteMutation.isPending}
                    className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground transition-colors hover:text-foreground"
                  >
                    {tr('Generar nuevo código', 'Generate new code')}
                  </button>
                </div>
              </div>
            )}
          </div>

          <div className="portal-soft-panel space-y-4 rounded-2xl p-5">
            <h4 className="flex items-center gap-2 text-xs font-bold text-foreground">
              <History className="h-4 w-4 text-primary" />
              <span>{tr('Historial de invitaciones', 'Invite history')}</span>
            </h4>

            {isLoading ? (
              <div className="space-y-2">
                {[1, 2, 3].map((i) => (
                  <div key={i} className="h-11 animate-pulse rounded-xl border border-border bg-background" />
                ))}
              </div>
            ) : !invites?.length ? (
              <p className="py-6 text-center text-sm font-medium text-muted-foreground">
                {tr('Todavía no se han generado códigos.', 'No connection codes generated yet.')}
              </p>
            ) : (
              <div className="max-h-[180px] space-y-2 overflow-y-auto pr-1">
                {invites.map((inv) => {
                  const expired = new Date(inv.expires_at) < new Date();
                  return (
                    <div
                      key={inv.id}
                      className="flex items-center justify-between rounded-xl border border-border bg-background p-3 transition-colors hover:bg-accent"
                    >
                      <div className="flex items-center gap-2">
                        <span className="select-all font-mono text-xs font-bold tracking-wider text-foreground">
                          {inv.invite_code}
                        </span>
                        <span
                          className={`rounded-md px-1.5 py-0.5 text-[8px] font-bold uppercase tracking-[0.16em] ${
                            expired
                              ? 'border border-rose-500/20 bg-rose-500/10 text-rose-500'
                              : 'border border-primary/20 bg-primary/10 text-primary'
                          }`}
                        >
                          {expired ? tr('Caducado', 'Expired') : tr('Activo', 'Active')}
                        </span>
                      </div>
                      <div className="flex items-center gap-2 text-[10px] font-semibold text-muted-foreground">
                        <span>
                          {new Date(inv.created_at).toLocaleDateString(locale === 'es' ? 'es-ES' : 'en-US', {
                            month: 'short',
                            day: 'numeric',
                          })}
                        </span>
                        <button
                          onClick={() => copyToClipboard(inv.invite_code)}
                          className="rounded-lg p-1 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                          title={tr('Copiar código', 'Copy code')}
                        >
                          <Copy className="h-3.5 w-3.5" />
                        </button>
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
