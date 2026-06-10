import React from 'react';
import type { ProfessionalClient } from '../../types/database.types';
import { useClientCheckins } from '../../hooks/queries/useCheckins';
import { useRequestCheckin } from '../../hooks/mutations/useRequestCheckin';
import { useAuth } from '../../lib/auth-context';
import { ClipboardCheck, Activity, Moon, Smile, Send } from 'lucide-react';

export const ClientCheckins: React.FC<{ client: ProfessionalClient }> = ({ client }) => {
  const { data: checkins, isLoading } = useClientCheckins(client.id);
  const { professional } = useAuth();
  const requestCheckin = useRequestCheckin();

  const handleRequest = () => {
    if (!professional) return;
    requestCheckin.mutate({
      professionalId: professional.id,
      clientId: client.client_id,
      professionalClientId: client.id,
    });
  };

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <h4 className="text-sm font-bold flex items-center gap-1.5">
          <ClipboardCheck className="w-4 h-4 text-primary" />
          Check-ins
        </h4>
        <button
          onClick={handleRequest}
          disabled={requestCheckin.isPending}
          className="flex items-center gap-1.5 px-3 py-1.5 text-[11px] rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors disabled:opacity-50"
        >
          <Send className="w-3 h-3" />
          {requestCheckin.isPending ? 'Requesting...' : 'Request check-in'}
        </button>
      </div>

      {isLoading ? (
        <div className="space-y-2">{[1,2].map(i => <div key={i} className="h-24 rounded-xl bg-muted/30 animate-pulse" />)}</div>
      ) : !checkins?.length ? (
        <p className="text-xs text-muted-foreground text-center py-6">No check-ins submitted yet</p>
      ) : (
        <div className="space-y-3">
          {checkins.map(c => (
            <div key={c.id} className="rounded-xl border bg-card p-4 space-y-3 card-elevated">
              <div className="flex items-center justify-between">
                <span className="text-xs font-medium text-muted-foreground">
                  {new Date(c.submitted_at).toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' })}
                  {' · '}
                  {new Date(c.submitted_at).toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' })}
                </span>
                <div className="flex items-center gap-3 text-[11px] text-muted-foreground">
                  {c.energy_level != null && (
                    <span className="flex items-center gap-1">
                      <Activity className="w-3 h-3" /> {c.energy_level}/10
                    </span>
                  )}
                  {c.sleep_avg != null && (
                    <span className="flex items-center gap-1">
                      <Moon className="w-3 h-3" /> {c.sleep_avg}h
                    </span>
                  )}
                  {c.mood && (
                    <span className="flex items-center gap-1">
                      <Smile className="w-3 h-3" /> {c.mood}
                    </span>
                  )}
                </div>
              </div>

              {Object.keys(c.answers || {}).length > 0 && (
                <div className="space-y-2">
                  {Object.entries(c.answers).map(([key, val]) => (
                    <div key={key}>
                      <p className="text-[11px] font-medium text-muted-foreground">{key}</p>
                      <p className="text-xs mt-0.5">{String(val)}</p>
                    </div>
                  ))}
                </div>
              )}

              {c.notes && (
                <p className="text-xs text-muted-foreground italic border-t pt-2">{c.notes}</p>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
