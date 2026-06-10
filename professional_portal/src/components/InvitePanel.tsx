import React, { useState } from 'react';
import { useAuth } from '../lib/auth-context';
import { useCreateInvite } from '../hooks/mutations/useCreateInvite';
import { useInvites } from '../hooks/queries/useInvites';
import { toast } from '../lib/toast';
import { UserPlus, Copy, Check, Link, History, QrCode, X } from 'lucide-react';

export const InvitePanel: React.FC = () => {
  const { professional } = useAuth();
  const [newCode, setNewCode] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);
  const [showQr, setShowQr] = useState<string | null>(null);
  const { data: invites, isLoading } = useInvites(professional?.id);

  const createInviteMutation = useCreateInvite();

  const hasActivePro = () => {
    if (!professional) return false;
    const status = professional.pro_status;
    return status === 'active' || status === 'trialing';
  };

  const handleCreateInvite = () => {
    if (!professional) {
      toast.error('Save your profile first.');
      return;
    }
    if (!hasActivePro()) {
      toast.error('Pro must be active to create invites.');
      return;
    }

    createInviteMutation.mutate(professional.id, {
      onSuccess: (data) => {
        setNewCode(data.invite_code);
        toast.success('Invite code generated');
      },
      onError: (err: any) => {
        toast.error('Failed to create invite', { description: err?.message || 'Unknown error' });
      },
    });
  };

  const copyToClipboard = (code: string) => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    toast.success('Copied');
    setTimeout(() => setCopied(false), 2000);
  };

  const activePro = hasActivePro();

  return (
    <div className="max-w-lg space-y-5">
      {/* Header */}
      <div className="flex items-center gap-3">
        <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
          <UserPlus className="w-4 h-4 text-primary" />
        </div>
        <div>
          <h2 className="text-lg font-bold">Invite Client</h2>
          <p className="text-xs text-muted-foreground">Generate a code for your client to connect</p>
        </div>
      </div>

      {/* Warning */}
      {!activePro && (
        <div className="rounded-lg bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 p-4 text-sm text-amber-700 dark:text-amber-300">
          Pro subscription required to create invite codes.
        </div>
      )}

      {/* Generate section */}
      <div className="rounded-xl border bg-card card-elevated p-6 text-center">
        {!newCode ? (
          <>
            <div className="w-14 h-14 rounded-full bg-muted/50 flex items-center justify-center mx-auto mb-4">
              <Link className="w-6 h-6 text-muted-foreground/60" />
            </div>
            <p className="text-sm text-muted-foreground mb-4">
              Generate a unique 8-character code for your client to use in their mobile app.
            </p>
            <button
              onClick={handleCreateInvite}
              disabled={createInviteMutation.isPending || !activePro}
              className="inline-flex items-center gap-2 px-4 py-2.5 rounded-lg bg-primary text-primary-foreground text-sm font-medium hover:bg-primary/90 transition-colors disabled:opacity-50"
            >
              {createInviteMutation.isPending ? (
                <>Generating...</>
              ) : (
                <>
                  <UserPlus className="w-4 h-4" />
                  Generate Code
                </>
              )}
            </button>
          </>
        ) : (
          <>
            <p className="text-xs text-muted-foreground mb-3">Share this code with your client</p>
            <div className="inline-flex items-center gap-3 px-6 py-4 rounded-xl bg-secondary">
              <span className="text-2xl font-mono font-bold tracking-[0.2em] text-foreground select-all">
                {newCode}
              </span>
              <button
                onClick={() => copyToClipboard(newCode)}
                className="p-2 rounded-lg hover:bg-background transition-colors text-muted-foreground hover:text-foreground"
              >
                {copied ? <Check className="w-5 h-5 text-emerald-500" /> : <Copy className="w-5 h-5" />}
              </button>
              <button
                onClick={() => setShowQr(newCode)}
                className="p-2 rounded-lg hover:bg-background transition-colors text-muted-foreground hover:text-foreground"
                title="Show QR code"
              >
                <QrCode className="w-5 h-5" />
              </button>
            </div>
            <p className="text-xs text-muted-foreground/70 mt-3">Expires in 14 days</p>
            <div className="mt-4">
              <button
                onClick={handleCreateInvite}
                disabled={createInviteMutation.isPending}
                className="text-xs text-muted-foreground hover:text-foreground transition-colors"
              >
                Generate new code
              </button>
            </div>
          </>
        )}
      </div>

      {/* History */}
      <div className="rounded-xl border bg-card card-elevated p-5 space-y-3">
        <h3 className="text-sm font-bold flex items-center gap-2">
          <History className="w-4 h-4 text-muted-foreground" />
          Invite History
        </h3>
        {isLoading ? (
          <div className="space-y-2">{[1,2,3].map(i => <div key={i} className="h-10 rounded-lg bg-muted/30 animate-pulse" />)}</div>
        ) : !invites?.length ? (
          <p className="text-xs text-muted-foreground text-center py-4">No invites generated yet</p>
        ) : (
          <div className="space-y-2">
            {invites.map(inv => {
              const expired = new Date(inv.expires_at) < new Date();
              return (
                <div key={inv.id} className="flex items-center justify-between p-3 rounded-lg bg-secondary/40">
                  <div className="flex items-center gap-3">
                    <span className="font-mono text-sm font-bold tracking-wider">{inv.invite_code}</span>
                    <span className={`text-[10px] px-1.5 py-0.5 rounded-full font-medium ${
                      expired ? 'bg-red-500/10 text-red-500' : 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400'
                    }`}>
                      {expired ? 'Expired' : 'Active'}
                    </span>
                  </div>
                  <div className="flex items-center gap-2 text-[10px] text-muted-foreground">
                    <span>{new Date(inv.created_at).toLocaleDateString()}</span>
                    <div className="flex gap-1">
                      <button onClick={() => copyToClipboard(inv.invite_code)}
                        className="p-1 rounded hover:bg-secondary transition-colors" title="Copy code">
                        <Copy className="w-3 h-3" />
                      </button>
                      <button onClick={() => setShowQr(inv.invite_code)}
                        className="p-1 rounded hover:bg-secondary transition-colors" title="QR code">
                        <QrCode className="w-3 h-3" />
                      </button>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* QR Code Modal */}
      {showQr && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50" onClick={() => setShowQr(null)}>
          <div className="bg-card rounded-2xl p-6 w-full max-w-xs m-4 shadow-2xl text-center" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-bold">QR Code</h3>
              <button onClick={() => setShowQr(null)} className="p-1 rounded-md hover:bg-secondary"><X className="w-4 h-4" /></button>
            </div>
            <QRCode value={showQr} size={220} />
            <p className="text-xs text-muted-foreground mt-3">Code: <span className="font-mono font-bold">{showQr}</span></p>
            <button onClick={() => { navigator.clipboard.writeText(showQr); toast.success('Copied'); }}
              className="mt-3 inline-flex items-center gap-1.5 px-3 py-1.5 text-xs rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors">
              <Copy className="w-3 h-3" /> Copy Code
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

function QRCode({ value, size }: { value: string; size: number }) {
  const canvasRef = React.useRef<HTMLCanvasElement>(null);

  React.useEffect(() => {
    import('qrcode').then(mod => {
      if (canvasRef.current) {
        mod.toCanvas(canvasRef.current, value, { width: size, margin: 2, color: { dark: '#0a0a0a', light: '#ffffff' } });
      }
    });
  }, [value, size]);

  return <canvas ref={canvasRef} style={{ width: size, height: size }} className="mx-auto" />;
}
