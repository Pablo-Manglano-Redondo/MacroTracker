import React, { useState, useEffect, useCallback } from 'react';
import { useAuth } from '../lib/auth-context';
import { supabase } from '../lib/supabase';
import { useCreateInvite } from '../hooks/mutations/useCreateInvite';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { toast } from '../lib/toast';
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
  const [step, setStep] = useState<WizardStep>('invite');
  const [inviteCode, setInviteCode] = useState<string | null>(null);
  const [newClientId, setNewClientId] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);

  const createInviteMutation = useCreateInvite();

  // Step 1: Create invite code
  const handleCreateInvite = () => {
    if (!professional) {
      toast.error('Save your profile first.');
      return;
    }

    createInviteMutation.mutate(professional.id, {
      onSuccess: (data) => {
        setInviteCode(data.invite_code);
        setStep('waiting');
        toast.success('Invite code created!');
      },
      onError: (err: any) => {
        toast.error('Failed to create invite', { description: err?.message || 'Unknown error' });
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
          toast.success('Client accepted the invite!');
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
        toast.success('Client found!');
      } else {
        toast.info('No client has accepted yet. Share the invite code.');
      }
    } catch {
      toast.error('Failed to check for client connection');
    }
  }, [professional]);

  const copyToClipboard = () => {
    if (!inviteCode) return;
    navigator.clipboard.writeText(inviteCode);
    setCopied(true);
    toast.success('Copied!');
    setTimeout(() => setCopied(false), 2000);
  };

  const handleComplete = () => {
    if (newClientId) {
      onDone(newClientId);
    }
  };

  return (
    <Card className="p-6 border max-w-2xl mx-auto">
      {/* Step indicator */}
      <div className="flex items-center gap-2 mb-6">
        {(['invite', 'waiting', 'complete'] as const).map((s, i) => (
          <React.Fragment key={s}>
            <div className={`flex items-center gap-2 ${i > 0 ? 'ml-0' : ''}`}>
              <div className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold ${
                step === s 
                  ? 'bg-primary text-primary-foreground ring-2 ring-primary/30' 
                  : ['waiting', 'complete'].includes(step) && s !== 'complete' && step !== s
                    ? 'bg-accent text-accent-foreground'
                    : step === 'complete' && s === 'complete'
                      ? 'bg-primary text-primary-foreground'
                      : 'bg-muted/30 text-muted-foreground'
              }`}>
                {s === 'complete' && step === 'complete' ? (
                  <CheckCircle2 className="w-4 h-4" />
                ) : (
                  i + 1
                )}
              </div>
              <span className={`text-xs font-bold ${
                step === s ? 'text-foreground' : 'text-muted-foreground'
              }`}>
                {s === 'invite' ? 'Create Invite' : s === 'waiting' ? 'Share Code' : 'Connected'}
              </span>
            </div>
            {i < 2 && (
              <ArrowRight className="w-4 h-4 text-muted-foreground/40" />
            )}
          </React.Fragment>
        ))}
      </div>

      {/* Step content */}
      {step === 'invite' && (
        <div className="text-center py-6 space-y-4">
          <div className="w-16 h-16 rounded-full bg-accent flex items-center justify-center mx-auto">
            <UserPlus className="w-8 h-8 text-primary" />
          </div>
          <div>
            <h3 className="text-lg font-bold">Add a New Client</h3>
            <p className="text-sm text-muted-foreground mt-1 max-w-md mx-auto leading-relaxed">
              Create an invite code that your client can use in their mobile app to connect with you.
            </p>
          </div>
          <Button onClick={handleCreateInvite} disabled={createInviteMutation.isPending} size="lg">
            {createInviteMutation.isPending ? (
              <Loader2 className="w-4 h-4 animate-spin mr-2" />
            ) : (
              <Sparkles className="w-4 h-4 mr-2" />
            )}
            Generate invite code
          </Button>
          <div>
            <Button onClick={onCancel} variant="ghost" size="sm" className="text-muted-foreground">
              Cancel
            </Button>
          </div>
        </div>
      )}

      {step === 'waiting' && (
        <div className="text-center py-6 space-y-4">
          <div className="w-16 h-16 rounded-full bg-accent flex items-center justify-center mx-auto animate-pulse">
            <Loader2 className="w-8 h-8 text-primary animate-spin" />
          </div>
          <div>
            <h3 className="text-lg font-bold">Share This Code</h3>
            <p className="text-sm text-muted-foreground mt-1 max-w-md mx-auto leading-relaxed">
              Ask your client to enter this code in their MacroTracker mobile app under "Connect to Professional".
            </p>
          </div>
          
          {inviteCode && (
            <div className="bg-accent/20 border border-primary/20 p-6 rounded-xl max-w-xs mx-auto">
              <p className="text-xs font-bold text-primary uppercase tracking-wide mb-2">Invite Code</p>
              <div className="text-3xl font-black tracking-[0.3em] text-foreground mb-3 select-all">
                {inviteCode}
              </div>
              <p className="text-xs text-muted-foreground">Expires in 14 days</p>
            </div>
          )}

          <div className="flex items-center justify-center gap-3">
            <Button onClick={copyToClipboard} variant="outline">
              {copied ? (
                <Check className="w-4 h-4 mr-2 text-primary" />
              ) : (
                <Copy className="w-4 h-4 mr-2" />
              )}
              Copy code
            </Button>
            <Button onClick={handleCheckForClient} variant="secondary">
              <RefreshCw className="w-4 h-4 mr-2" />
              Check for client
            </Button>
          </div>

          <p className="text-xs text-muted-foreground">
            Waiting for client to accept... The page will update automatically.
          </p>

          <div>
            <Button onClick={onCancel} variant="ghost" size="sm" className="text-muted-foreground">
              Cancel
            </Button>
          </div>
        </div>
      )}

      {step === 'complete' && (
        <div className="text-center py-6 space-y-4">
          <div className="w-16 h-16 rounded-full bg-accent flex items-center justify-center mx-auto">
            <CheckCircle2 className="w-8 h-8 text-primary" />
          </div>
          <div>
            <h3 className="text-lg font-bold">Client Connected!</h3>
            <p className="text-sm text-muted-foreground mt-1 max-w-md mx-auto leading-relaxed">
              Your client has accepted the invite and connected to your practice.
            </p>
          </div>
          <div className="flex items-center justify-center gap-3">
            <Button onClick={handleComplete} size="lg">
              <ArrowRight className="w-4 h-4 mr-2" />
              Go to Client
            </Button>
            <Button onClick={onCancel} variant="outline">
              Back to Clients
            </Button>
          </div>
        </div>
      )}
    </Card>
  );
};
