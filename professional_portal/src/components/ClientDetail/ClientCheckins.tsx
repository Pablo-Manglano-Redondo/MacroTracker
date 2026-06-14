import React from 'react';
import { Activity, ClipboardCheck, Moon, Send, Smile } from 'lucide-react';
import type { ProfessionalClient } from '../../types/database.types';
import { useClientCheckins } from '../../hooks/queries/useCheckins';
import { useRequestCheckin } from '../../hooks/mutations/useRequestCheckin';
import { useAuth } from '../../lib/auth-context';
import { usePortalI18n } from '../../lib/portal-i18n';

export const ClientCheckins: React.FC<{ client: ProfessionalClient }> = ({ client }) => {
  const { data: checkins, isLoading, error } = useClientCheckins(client.id);
  const { professional } = useAuth();
  const { tr, locale } = usePortalI18n();
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
    <div className="space-y-5 animate-fade-in-up">
      <section className="portal-panel rounded-[1.6rem] p-5">
        <div className="flex flex-col gap-4 border-b border-border pb-4 sm:flex-row sm:items-center sm:justify-between">
          <div className="space-y-1">
            <div className="flex items-center gap-2 text-primary">
              <ClipboardCheck className="h-4.5 w-4.5" />
              <p className="portal-kicker">{tr('Seguimiento', 'Check-ins')}</p>
            </div>
            <h4 className="text-lg font-bold text-foreground">
              {tr('Respuestas del cliente', 'Client submissions')}
            </h4>
            <p className="text-sm leading-relaxed text-muted-foreground">
              {tr(
                'Solicita un check-in y revisa aquí energía, sueño, estado de ánimo y respuestas abiertas.',
                'Request a check-in and review energy, sleep, mood, and open-ended responses here.',
              )}
            </p>
          </div>
          <button
            onClick={handleRequest}
            disabled={requestCheckin.isPending}
            className="inline-flex items-center justify-center gap-2 rounded-xl bg-primary px-4 py-2.5 text-sm font-bold text-primary-foreground transition-opacity hover:opacity-95 disabled:cursor-not-allowed disabled:opacity-60"
          >
            <Send className="h-4 w-4" />
            {requestCheckin.isPending
              ? tr('Solicitando...', 'Requesting...')
              : tr('Solicitar check-in', 'Request check-in')}
          </button>
        </div>
      </section>

      {error ? (
        <div className="portal-panel rounded-[1.6rem] p-8 text-center text-sm text-muted-foreground">
          {tr(
            'Los check-ins no están disponibles ahora mismo. Mantén esta superficie explícita hasta que el backend devuelva envíos reales para la relación.',
            'Check-ins are not available right now. Keep this surface explicit until the backend returns real submissions for the relationship.',
          )}
        </div>
      ) : isLoading ? (
        <div className="space-y-3">
          {[1, 2].map((i) => (
            <div
              key={i}
              className="h-28 animate-pulse rounded-[1.4rem] border border-border bg-card/70"
            />
          ))}
        </div>
      ) : !checkins?.length ? (
        <div className="portal-panel rounded-[1.6rem] p-8 text-center text-sm text-muted-foreground">
          {tr(
            'Todavía no hay respuestas enviadas por este cliente.',
            'This client has not submitted any check-ins yet.',
          )}
        </div>
      ) : (
        <div className="space-y-4">
          {checkins.map((checkin) => (
            <article key={checkin.id} className="portal-panel rounded-[1.6rem] p-5">
              <div className="flex flex-col gap-3 border-b border-border pb-4 sm:flex-row sm:items-center sm:justify-between">
                <div>
                  <p className="text-xs font-bold uppercase tracking-[0.16em] text-muted-foreground">
                    {tr('Enviado', 'Submitted')}
                  </p>
                  <p className="mt-1 text-sm font-semibold text-foreground">
                    {new Date(checkin.submitted_at).toLocaleDateString(
                      locale === 'es' ? 'es-ES' : 'en-US',
                      { weekday: 'short', month: 'short', day: 'numeric' },
                    )}
                    {' · '}
                    {new Date(checkin.submitted_at).toLocaleTimeString(
                      locale === 'es' ? 'es-ES' : 'en-US',
                      { hour: '2-digit', minute: '2-digit' },
                    )}
                  </p>
                </div>
                <div className="flex flex-wrap items-center gap-2">
                  {checkin.energy_level != null && (
                    <MetricChip
                      icon={<Activity className="h-3.5 w-3.5 text-primary" />}
                      label={tr('Energía', 'Energy')}
                      value={`${checkin.energy_level}/10`}
                    />
                  )}
                  {checkin.sleep_avg != null && (
                    <MetricChip
                      icon={<Moon className="h-3.5 w-3.5 text-indigo-500" />}
                      label={tr('Sueño', 'Sleep')}
                      value={`${checkin.sleep_avg}h`}
                    />
                  )}
                  {checkin.mood && (
                    <MetricChip
                      icon={<Smile className="h-3.5 w-3.5 text-amber-500" />}
                      label={tr('Ánimo', 'Mood')}
                      value={checkin.mood}
                    />
                  )}
                </div>
              </div>

              {Object.keys(checkin.answers || {}).length > 0 && (
                <div className="mt-4 grid gap-3 md:grid-cols-2">
                  {Object.entries(checkin.answers).map(([key, val]) => (
                    <div key={key} className="rounded-xl border border-border bg-background/70 p-3">
                      <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                        {key}
                      </p>
                      <p className="mt-1 text-sm leading-relaxed text-foreground">{String(val)}</p>
                    </div>
                  ))}
                </div>
              )}

              {checkin.notes && (
                <div className="mt-4 rounded-xl border border-border bg-background/70 p-4">
                  <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                    {tr('Notas del cliente', 'Client notes')}
                  </p>
                  <p className="mt-2 text-sm leading-relaxed text-foreground">{checkin.notes}</p>
                </div>
              )}
            </article>
          ))}
        </div>
      )}
    </div>
  );
};

const MetricChip: React.FC<{ icon: React.ReactNode; label: string; value: string }> = ({
  icon,
  label,
  value,
}) => (
  <span className="inline-flex items-center gap-2 rounded-full border border-border bg-background px-3 py-1.5 text-xs font-semibold text-foreground">
    {icon}
    <span className="text-muted-foreground">{label}</span>
    <span>{value}</span>
  </span>
);
