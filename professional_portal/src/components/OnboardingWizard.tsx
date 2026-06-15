import React, { useState, useEffect, useCallback } from 'react';
import { useAuth } from '../lib/auth-context';
import { supabase } from '../lib/supabase';
import { useCreateInvite } from '../hooks/mutations/useCreateInvite';
import { Button } from './ui/button';
import { toast } from '../lib/toast';
import { usePortalI18n } from '../lib/portal-i18n';
import {
  UserPlus, Copy, Check, Loader2, RefreshCw,
  ArrowRight, Sparkles, CheckCircle2
} from 'lucide-react';

type WizardStep = 'invite' | 'waiting' | 'complete';

interface OnboardingWizardProps {
  onDone: (clientId: string) => void;
  onCancel: () => void;
}

export const OnboardingWizard: React.FC<OnboardingWizardProps> = ({ onDone, onCancel }) => {
  const { professional } = useAuth();
  const { tr } = usePortalI18n();
  const [step, setStep] = useState<WizardStep>('invite');
  const [inviteCode, setInviteCode] = useState<string | null>(null);
  const [newClientId, setNewClientId] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);

  const createInviteMutation = useCreateInvite();

  // Step 1: Create invite code
  const handleCreateInvite = () => {
    if (!professional) {
      toast.error(tr('Guarda primero tu perfil.', 'Save your profile first.'));
      return;
    }

    createInviteMutation.mutate(professional.id, {
      onSuccess: (data) => {
        setInviteCode(data.invite_code);
        setStep('waiting');
        toast.success(tr('Código de invitación creado', 'Invite code created'));
      },
      onError: (err: any) => {
        toast.error(tr('No se pudo crear la invitación', 'Failed to create invite'), {
          description: err?.message || tr('Error desconocido', 'Unknown error'),
        });
      },
    });
  };

  // Step 2: Poll for client acceptance via realtime
  useEffect(() => {
    if (step !== 'waiting' || !professional) return;

    // Subscribe to new professional_clients for this professional
    const channel = supabase
      .channel(`onboarding-${professional.id}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'professional_clients',
          filter: `professional_id=eq.${professional.id}`,
        },
        (payload) => {
          const newRel = payload.new as { client_id: string };
          setNewClientId(newRel.client_id);
          setStep('complete');
          toast.success(tr('El cliente aceptó la invitación', 'Client accepted the invite'));
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [step, professional]);

  // Manual refresh to check for new client
  const handleCheckForClient = useCallback(async () => {
    if (!professional) return;

    try {
      const { data, error } = await supabase
        .from('professional_clients')
        .select('client_id')
        .eq('professional_id', professional.id)
        .order('connected_at', { ascending: false })
        .limit(1);

      if (error) throw error;

      if (data && data.length > 0) {
        setNewClientId(data[0]!.client_id);
        setStep('complete');
        toast.success(tr('Cliente encontrado', 'Client found'));
      } else {
        toast.info(
          tr(
            'Todavía no hay ningún cliente conectado. Comparte el código de invitación.',
            'No client has accepted yet. Share the invite code.',
          ),
        );
      }
    } catch {
      toast.error(tr('No se pudo comprobar la conexión del cliente', 'Failed to check for client connection'));
    }
  }, [professional]);

  const copyToClipboard = () => {
    if (!inviteCode) return;
    navigator.clipboard.writeText(inviteCode);
    setCopied(true);
    toast.success(tr('Copiado', 'Copied'));
    setTimeout(() => setCopied(false), 2000);
  };

  const handleComplete = () => {
    if (newClientId) {
      onDone(newClientId);
    }
  };

  return (
    <div className="glass-card rounded-2xl border-none p-6 max-w-2xl mx-auto relative overflow-hidden animate-fade-in-up">
      <div className="absolute top-0 right-0 w-32 h-32 bg-primary/5 rounded-full blur-3xl pointer-events-none" />

      {/* Step indicator */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-8 border-b border-border/20 pb-5">
        {(['invite', 'waiting', 'complete'] as const).map((s, i) => {
          const isActive = step === s;
          const isDone = (s === 'invite' && step !== 'invite') || (s === 'waiting' && step === 'complete');

          return (
            <React.Fragment key={s}>
              <div className="flex items-center gap-2.5">
                <div className={`w-7 h-7 rounded-xl flex items-center justify-center text-xs font-black transition-all ${
                  isActive
                    ? 'bg-gradient-to-r from-primary to-teal-500 text-white ring-2 ring-primary/30 shadow-[0_0_10px_rgba(16,185,129,0.3)]'
                    : isDone
                    ? 'bg-primary/20 text-primary border border-primary/20'
                    : 'bg-black/10 dark:bg-white/5 border border-border/20 text-muted-foreground'
                }`}>
                  {isDone ? (
                    <Check className="w-3.5 h-3.5" />
                  ) : s === 'complete' && step === 'complete' ? (
                    <CheckCircle2 className="w-3.5 h-3.5" />
                  ) : (
                    i + 1
                  )}
                </div>
                <div>
                  <span className={`text-[10px] font-extrabold uppercase tracking-wider ${
                    isActive ? 'text-primary' : 'text-muted-foreground'
                  }`}>
                    {s === 'invite'
                      ? tr('Paso 1', 'Step 1')
                      : s === 'waiting'
                        ? tr('Paso 2', 'Step 2')
                        : tr('Paso 3', 'Step 3')}
                  </span>
                  <p className={`text-xs font-extrabold -mt-0.5 ${isActive ? 'text-foreground' : 'text-muted-foreground'}`}>
                    {s === 'invite'
                      ? tr('Crear invitacion', 'Create invite')
                      : s === 'waiting'
                        ? tr('Compartir codigo', 'Share code')
                        : tr('Conexion lista', 'Connected')}
                  </p>
                </div>
              </div>
              {i < 2 && (
                <ArrowRight className="hidden sm:block w-4 h-4 text-muted-foreground/30" />
              )}
            </React.Fragment>
          );
        })}
      </div>

      {/* Step content */}
      {step === 'invite' && (
        <div className="text-center py-6 space-y-5">
          <div className="w-14 h-14 rounded-2xl bg-primary/10 border border-primary/20 flex items-center justify-center mx-auto text-primary shadow-lg shadow-primary/5">
            <UserPlus className="w-6 h-6" />
          </div>
          <div>
            <h3 className="text-sm font-extrabold text-gradient">{tr('Añadir cliente', 'Add a new client')}</h3>
            <p className="text-xs text-muted-foreground mt-2 max-w-sm mx-auto leading-relaxed font-semibold">
              {tr(
                'Genera un código único de 8 caracteres para conectar el seguimiento móvil del cliente con tu portal profesional.',
                "Generate a unique 8-character code that connects your client's mobile tracking to your professional portal.",
              )}
            </p>
          </div>
          <Button
            onClick={handleCreateInvite}
            disabled={createInviteMutation.isPending}
            className="px-6 py-2.5 rounded-xl bg-gradient-to-r from-primary to-teal-500 text-white font-extrabold uppercase tracking-wider text-xs hover:brightness-110 hover:shadow-[0_0_15px_rgba(16,185,129,0.3)] transition-all cursor-pointer"
          >
            {createInviteMutation.isPending ? (
              <Loader2 className="w-4 h-4 animate-spin mr-2" />
            ) : (
              <Sparkles className="w-4 h-4 mr-2" />
            )}
            {tr('Generar invitación', 'Generate invite code')}
          </Button>
          <div>
            <button onClick={onCancel} className="text-[10px] font-extrabold uppercase tracking-wider text-muted-foreground hover:text-foreground transition-colors cursor-pointer">
              {tr('Volver al portal', 'Back to portal')}
            </button>
          </div>
        </div>
      )}

      {step === 'waiting' && (
        <div className="text-center py-6 space-y-5">
          <div className="w-14 h-14 rounded-2xl bg-primary/10 border border-primary/20 flex items-center justify-center mx-auto text-primary animate-pulse shadow-lg shadow-primary/5">
            <Loader2 className="w-6 h-6 animate-spin" />
          </div>
          <div>
            <h3 className="text-sm font-extrabold text-gradient">{tr('Compartir invitación', 'Share invite code')}</h3>
            <p className="text-xs text-muted-foreground mt-2 max-w-sm mx-auto leading-relaxed font-semibold">
              {tr(
                'Pide al cliente que introduzca este código dentro de la app MacroTracker, en la sección ',
                'Ask your client to enter this code inside the MacroTracker mobile app under the ',
              )}
              <strong className="text-primary font-bold">{tr('Nutricionista', 'Nutritionist')}</strong>
              {tr('.', ' section.')}
            </p>
          </div>

          {inviteCode && (
            <div className="border border-border/40 bg-black/10 dark:bg-white/5 p-5 rounded-2xl max-w-xs mx-auto shadow-inner relative overflow-hidden">
              <div className="absolute top-0 right-0 w-16 h-16 bg-primary/5 rounded-full blur-xl pointer-events-none" />
              <p className="text-[8px] font-black text-primary uppercase tracking-widest mb-1">
                {tr('Código activo', 'Active invite code')}
              </p>
              <div className="text-3xl font-mono font-black tracking-[0.2em] text-foreground select-all pl-2">
                {inviteCode}
              </div>
              <p className="text-[9px] font-bold text-muted-foreground/60 mt-1">
                {tr('Caduca en 14 días', 'Expires in 14 days')}
              </p>
            </div>
          )}

          <div className="flex items-center justify-center gap-3.5">
            <Button
              onClick={copyToClipboard}
              className="px-4 py-2 rounded-xl bg-white/5 border border-border/40 text-foreground text-xs font-bold hover:bg-white/10 transition-colors cursor-pointer"
            >
              {copied ? (
                <Check className="w-4 h-4 mr-2 text-primary" />
              ) : (
                <Copy className="w-4 h-4 mr-2" />
              )}
              {tr('Copiar código', 'Copy code')}
            </Button>
            <Button
              onClick={handleCheckForClient}
              className="px-4 py-2 rounded-xl bg-white/5 border border-border/40 text-foreground text-xs font-bold hover:bg-white/10 transition-colors cursor-pointer"
            >
              <RefreshCw className="w-4 h-4 mr-2" />
              {tr('Actualizar', 'Refresh')}
            </Button>
          </div>

          <p className="text-[10px] font-extrabold uppercase tracking-wider text-muted-foreground/70 animate-pulse">
            {tr(
              'Esperando activación desde el dispositivo... Actualización en tiempo real.',
              'Waiting for device activation... Real-time updates.',
            )}
          </p>

          <div>
            <button onClick={onCancel} className="text-[10px] font-extrabold uppercase tracking-wider text-muted-foreground hover:text-foreground transition-colors cursor-pointer">
              {tr('Cancelar conexión', 'Cancel connection')}
            </button>
          </div>
        </div>
      )}

      {step === 'complete' && (
        <div className="text-center py-6 space-y-5">
          <div className="w-14 h-14 rounded-2xl bg-primary/10 border border-primary/20 flex items-center justify-center mx-auto text-primary shadow-lg shadow-primary/5">
            <CheckCircle2 className="w-6 h-6" />
          </div>
          <div>
            <h3 className="text-sm font-extrabold text-gradient">{tr('Conexión completada', 'Connection successful')}</h3>
            <p className="text-xs text-muted-foreground mt-2 max-w-sm mx-auto leading-relaxed font-semibold">
              {tr(
                'El perfil del cliente ya esta vinculado y listo para recibir planes y seguimiento desde el portal.',
                'The client profile is now linked and ready to receive plans and follow-up from the portal.',
              )}
            </p>
          </div>
          <div className="flex items-center justify-center gap-3.5">
            <Button
              onClick={handleComplete}
              className="px-6 py-2.5 rounded-xl bg-gradient-to-r from-primary to-teal-500 text-white font-extrabold uppercase tracking-wider text-xs hover:brightness-110 hover:shadow-[0_0_15px_rgba(16,185,129,0.3)] transition-all cursor-pointer"
            >
              <ArrowRight className="w-4 h-4 mr-2" />
              {tr('Abrir cliente conectado', 'Open connected client')}
            </Button>
            <Button
              onClick={onCancel}
              className="px-4 py-2.5 rounded-xl bg-white/5 border border-border/40 text-foreground text-xs font-bold hover:bg-white/10 transition-colors cursor-pointer"
            >
              {tr('Volver al roster', 'Back to roster')}
            </Button>
          </div>
        </div>
      )}
    </div>
  );
};
