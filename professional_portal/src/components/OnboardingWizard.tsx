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
  const { t } = usePortalI18n();
  const [step, setStep] = useState<WizardStep>('invite');
  const [inviteCode, setInviteCode] = useState<string | null>(null);
  const [newClientId, setNewClientId] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);

  const createInviteMutation = useCreateInvite();

  // Step 1: Create invite code
  const handleCreateInvite = () => {
    if (!professional) {
      toast.error(t('components.onboardingwizard.save_your_profile_first'));
      return;
    }

    createInviteMutation.mutate(professional.id, {
      onSuccess: (data) => {
        setInviteCode(data.invite_code);
        setStep('waiting');
        toast.success(t('components.onboardingwizard.invite_code_created'));
      },
      onError: (err: any) => {
        toast.error(t('components.onboardingwizard.failed_to_create_invite'), {
          description: err?.message || t('components.onboardingwizard.unknown_error'),
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
          toast.success(t('components.onboardingwizard.client_accepted_the_invite'));
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
        toast.success(t('components.onboardingwizard.client_found'));
      } else {
        toast.info(
          t('components.onboardingwizard.no_client_has_accepted_yet_share_the_invite_code'),
        );
      }
    } catch {
      toast.error(t('components.onboardingwizard.failed_to_check_for_client_connection'));
    }
  }, [professional]);

  const copyToClipboard = () => {
    if (!inviteCode) return;
    navigator.clipboard.writeText(inviteCode);
    setCopied(true);
    toast.success(t('components.onboardingwizard.copied'));
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
                <div className={`portal-label flex h-7 w-7 items-center justify-center rounded-xl transition-all ${
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
                  <span className={`portal-label ${
                    isActive ? 'text-primary' : 'text-muted-foreground'
                  }`}>
                    {s === 'invite'
                      ? t('components.onboardingwizard.step_1')
                      : s === 'waiting'
                        ? t('components.onboardingwizard.step_2')
                        : t('components.onboardingwizard.step_3')}
                  </span>
                  <p className={`portal-meta -mt-0.5 ${isActive ? 'text-foreground' : 'text-muted-foreground'}`}>
                    {s === 'invite'
                      ? t('components.onboardingwizard.create_invite')
                      : s === 'waiting'
                        ? t('components.onboardingwizard.share_code')
                        : t('components.onboardingwizard.connected')}
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
            <h3 className="portal-card-heading">{t('components.onboardingwizard.add_a_new_client')}</h3>
            <p className="portal-body mt-2 max-w-sm mx-auto">
              {t('components.onboardingwizard.generate_a_unique_8_character_code_that_connects_your_client_s_mobile_tr')}
            </p>
          </div>
          <Button
            onClick={handleCreateInvite}
            disabled={createInviteMutation.isPending}
            className="portal-action px-6 py-2.5 rounded-xl bg-gradient-to-r from-primary to-teal-500 text-white hover:brightness-110 hover:shadow-[0_0_15px_rgba(16,185,129,0.3)] transition-all cursor-pointer"
          >
            {createInviteMutation.isPending ? (
              <Loader2 className="w-4 h-4 animate-spin mr-2" />
            ) : (
              <Sparkles className="w-4 h-4 mr-2" />
            )}
            {t('components.onboardingwizard.generate_invite_code')}
          </Button>
          <div>
            <button onClick={onCancel} className="portal-action text-muted-foreground hover:text-foreground transition-colors cursor-pointer">
              {t('components.onboardingwizard.back_to_portal')}
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
            <h3 className="portal-card-heading">{t('components.onboardingwizard.share_invite_code')}</h3>
            <p className="portal-body mt-2 max-w-sm mx-auto">
              {t('components.onboardingwizard.ask_your_client_to_enter_this_code_inside_the_macrotracker_mobile_app_un')}
              <strong className="portal-action text-primary">{t('components.onboardingwizard.nutritionist')}</strong>
              {t('components.onboardingwizard.section')}
            </p>
          </div>

          {inviteCode && (
            <div className="border border-border/40 bg-black/10 dark:bg-white/5 p-5 rounded-2xl max-w-xs mx-auto shadow-inner relative overflow-hidden">
              <div className="absolute top-0 right-0 w-16 h-16 bg-primary/5 rounded-full blur-xl pointer-events-none" />
              <p className="portal-label mb-1 text-primary">
                {t('components.onboardingwizard.active_invite_code')}
              </p>
              <div className="portal-metric select-all pl-2 font-mono text-3xl tracking-[0.2em] text-foreground">
                {inviteCode}
              </div>
              <p className="portal-meta mt-1 text-muted-foreground/60">
                {t('components.onboardingwizard.expires_in_14_days')}
              </p>
            </div>
          )}

          <div className="flex items-center justify-center gap-3.5">
            <Button
              onClick={copyToClipboard}
              className="portal-action px-4 py-2 rounded-xl bg-white/5 border border-border/40 text-foreground hover:bg-white/10 transition-colors cursor-pointer"
            >
              {copied ? (
                <Check className="w-4 h-4 mr-2 text-primary" />
              ) : (
                <Copy className="w-4 h-4 mr-2" />
              )}
              {t('components.onboardingwizard.copy_code')}
            </Button>
            <Button
              onClick={handleCheckForClient}
              className="portal-action px-4 py-2 rounded-xl bg-white/5 border border-border/40 text-foreground hover:bg-white/10 transition-colors cursor-pointer"
            >
              <RefreshCw className="w-4 h-4 mr-2" />
              {t('components.onboardingwizard.refresh')}
            </Button>
          </div>

          <p className="portal-label animate-pulse text-muted-foreground/70">
            {t('components.onboardingwizard.waiting_for_device_activation_real_time_updates')}
          </p>

          <div>
            <button onClick={onCancel} className="portal-action text-muted-foreground hover:text-foreground transition-colors cursor-pointer">
              {t('components.onboardingwizard.cancel_connection')}
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
            <h3 className="portal-card-heading">{t('components.onboardingwizard.connection_successful')}</h3>
            <p className="portal-body mt-2 max-w-sm mx-auto">
              {t('components.onboardingwizard.the_client_profile_is_now_linked_and_ready_to_receive_plans_and_follow_u')}
            </p>
          </div>
          <div className="flex items-center justify-center gap-3.5">
            <Button
              onClick={handleComplete}
              className="portal-action px-6 py-2.5 rounded-xl bg-gradient-to-r from-primary to-teal-500 text-white hover:brightness-110 hover:shadow-[0_0_15px_rgba(16,185,129,0.3)] transition-all cursor-pointer"
            >
              <ArrowRight className="w-4 h-4 mr-2" />
              {t('components.onboardingwizard.open_connected_client')}
            </Button>
            <Button
              onClick={onCancel}
              className="portal-action px-4 py-2.5 rounded-xl bg-white/5 border border-border/40 text-foreground hover:bg-white/10 transition-colors cursor-pointer"
            >
              {t('components.onboardingwizard.back_to_roster')}
            </Button>
          </div>
        </div>
      )}
    </div>
  );
};
