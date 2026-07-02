import React from 'react';
import { Activity, ClipboardCheck, Clock, Moon, Send, Smile } from 'lucide-react';
import type { ProfessionalClient } from '../../types/database.types';
import { useClientCheckinRequests, useClientCheckins } from '../../hooks/queries/useCheckins';
import { useRequestCheckin } from '../../hooks/mutations/useRequestCheckin';
import { useMarkCheckinsReviewed } from '../../hooks/mutations/useMarkCheckinsReviewed';
import { useAuth } from '../../lib/auth-context';
import { formatPortalDate, formatPortalTime } from '../../lib/date';
import { usePortalI18n } from '../../lib/portal-i18n';

export const ClientCheckins: React.FC<{ client: ProfessionalClient }> = ({ client }) => {
  const { data: checkins, isLoading, error } = useClientCheckins(client.id);
  const { data: requests, isLoading: requestsLoading } = useClientCheckinRequests(client.id);
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();
  const requestCheckin = useRequestCheckin();
  const markReviewed = useMarkCheckinsReviewed(client.id, professional?.id);

  const pendingReviewCount = checkins?.filter((checkin) => !checkin.reviewed_at).length ?? 0;
  const pendingRequests = requests?.filter((request) => request.status === 'pending') ?? [];

  const handleRequest = () => {
    if (!professional) return;
    requestCheckin.mutate({
      professionalId: professional.id,
      clientId: client.client_id,
      professionalClientId: client.id,
    });
  };

  const handleMarkReviewed = () => {
    markReviewed.mutate();
  };

  return (
    <div className="space-y-5 animate-fade-in-up">
      <section className="portal-panel rounded-[1.6rem] p-5">
        <div className="flex flex-col gap-4 border-b border-border pb-4 sm:flex-row sm:items-center sm:justify-between">
          <div className="space-y-1">
            <div className="flex items-center gap-2 text-primary">
              <ClipboardCheck className="h-4.5 w-4.5" />
              <p className="portal-kicker">{t('components.clientdetail.clientcheckins.check_ins')}</p>
            </div>
            <h4 className="portal-card-heading">
              {t('components.clientdetail.clientcheckins.client_submissions')}
            </h4>
            <p className="portal-body">
              {t('components.clientdetail.clientcheckins.request_a_check_in_and_review_energy_sleep_mood_and_open_ended_responses')}
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            {pendingReviewCount > 0 && (
              <button
                onClick={handleMarkReviewed}
                disabled={markReviewed.isPending}
                className="portal-action inline-flex items-center justify-center gap-2 rounded-xl border border-border bg-card px-4 py-2.5 text-foreground transition-colors hover:bg-accent disabled:cursor-not-allowed disabled:opacity-60"
              >
                <ClipboardCheck className="h-4 w-4" />
                {markReviewed.isPending
                  ? '...'
                  : locale?.toLowerCase().startsWith('es')
                    ? `Marcar ${pendingReviewCount} revisado${pendingReviewCount === 1 ? '' : 's'}`
                    : `Mark ${pendingReviewCount} reviewed`}
              </button>
            )}
            <button
              onClick={handleRequest}
              disabled={requestCheckin.isPending}
              className="portal-action inline-flex items-center justify-center gap-2 rounded-xl bg-primary px-4 py-2.5 text-primary-foreground transition-opacity hover:opacity-95 disabled:cursor-not-allowed disabled:opacity-60"
            >
              <Send className="h-4 w-4" />
              {requestCheckin.isPending
                ? t('components.clientdetail.clientcheckins.requesting')
                : t('components.clientdetail.clientcheckins.request_check_in')}
            </button>
          </div>
        </div>
      </section>

      {pendingRequests.length > 0 && (
        <div className="space-y-3">
          <div className="flex items-center gap-2 text-primary">
            <Clock className="h-4.5 w-4.5" />
            <p className="portal-kicker">
              {locale?.toLowerCase().startsWith('es') ? 'Solicitudes pendientes' : 'Pending requests'}
            </p>
          </div>
          {pendingRequests.map((request) => (
            <article
              key={request.id}
              className="portal-panel flex flex-col gap-3 rounded-[1.6rem] border-amber-500/25 bg-amber-500/5 p-5 sm:flex-row sm:items-center sm:justify-between"
            >
              <div>
                <p className="portal-card-heading">
                  {locale?.toLowerCase().startsWith('es')
                    ? 'Check-in solicitado al cliente'
                    : 'Check-in requested from client'}
                </p>
                <p className="portal-meta mt-1">
                  {formatPortalDate(request.requested_at, locale, {
                    weekday: 'short', month: 'short', day: 'numeric',
                  })}
                  {' · '}
                  {formatPortalTime(request.requested_at, locale, {
                    hour: '2-digit', minute: '2-digit',
                  })}
                </p>
              </div>
              <span className="portal-pill inline-flex items-center gap-2 rounded-full border border-amber-500/25 bg-amber-500/10 px-3 py-1 text-amber-700 dark:text-amber-300">
                <Clock className="h-3.5 w-3.5" />
                {locale?.toLowerCase().startsWith('es') ? 'Esperando respuesta' : 'Waiting for response'}
              </span>
            </article>
          ))}
        </div>
      )}

      {error ? (
        <div className="portal-panel portal-body rounded-[1.6rem] p-8 text-center text-muted-foreground">
          {t('components.clientdetail.clientcheckins.check_ins_are_not_available_right_now_keep_this_surface_explicit_until_t')}
        </div>
      ) : isLoading || requestsLoading ? (
        <div className="space-y-3">
          {[1, 2].map((i) => (
            <div
              key={i}
              className="h-28 animate-pulse rounded-[1.4rem] border border-border bg-card/70"
            />
          ))}
        </div>
      ) : !checkins?.length ? (
        <div className="portal-panel portal-body rounded-[1.6rem] p-8 text-center text-muted-foreground">
          {pendingRequests.length > 0
            ? locale?.toLowerCase().startsWith('es')
              ? 'Aún no hay respuestas enviadas para la solicitud pendiente.'
              : 'No submitted responses for the pending request yet.'
            : t('components.clientdetail.clientcheckins.this_client_has_not_submitted_any_check_ins_yet')}
        </div>
      ) : (
        <div className="space-y-4">
          {checkins.map((checkin) => (
            <article key={checkin.id} className="portal-panel rounded-[1.6rem] p-5">
              <div className="flex flex-col gap-3 border-b border-border pb-4 sm:flex-row sm:items-center sm:justify-between">
                <div>
                  <p className="portal-label">
                    {t('components.clientdetail.clientcheckins.submitted')}
                  </p>
                  <p className="portal-meta mt-1 text-foreground">
                    {formatPortalDate(checkin.submitted_at, locale, {
                      weekday: 'short', month: 'short', day: 'numeric',
                    })}
                    {' · '}
                    {formatPortalTime(checkin.submitted_at, locale, {
                      hour: '2-digit', minute: '2-digit',
                    })}
                  </p>
                </div>
                <div className="flex flex-wrap items-center gap-2">
                  {checkin.reviewed_at ? (
                    <span className="portal-pill inline-flex items-center gap-2 rounded-full border border-emerald-500/25 bg-emerald-500/10 px-3 py-1 text-emerald-700 dark:text-emerald-300">
                      {locale?.toLowerCase().startsWith('es') ? 'Revisado' : 'Reviewed'}
                    </span>
                  ) : (
                    <span className="portal-pill inline-flex items-center gap-2 rounded-full border border-amber-500/25 bg-amber-500/10 px-3 py-1 text-amber-700 dark:text-amber-300">
                      {locale?.toLowerCase().startsWith('es') ? 'Pendiente' : 'Pending'}
                    </span>
                  )}
                  {checkin.energy_level != null && (
                    <MetricChip
                      icon={<Activity className="h-3.5 w-3.5 text-primary" />}
                      label={t('components.clientdetail.clientcheckins.energy')}
                      value={`${checkin.energy_level}/10`}
                    />
                  )}
                  {checkin.sleep_avg != null && (
                    <MetricChip
                      icon={<Moon className="h-3.5 w-3.5 text-indigo-500" />}
                      label={t('components.clientdetail.clientcheckins.sleep')}
                      value={`${checkin.sleep_avg}h`}
                    />
                  )}
                  {checkin.mood && (
                    <MetricChip
                      icon={<Smile className="h-3.5 w-3.5 text-amber-500" />}
                      label={t('components.clientdetail.clientcheckins.mood')}
                      value={checkin.mood}
                    />
                  )}
                </div>
              </div>

              {Object.keys(checkin.answers || {}).length > 0 && (
                <div className="mt-4 grid gap-3 md:grid-cols-2">
                  {Object.entries(checkin.answers).map(([key, val]) => (
                    <div key={key} className="rounded-xl border border-border bg-background/70 p-3">
                      <p className="portal-label">
                        {key}
                      </p>
                      <p className="portal-body mt-1 text-foreground">{String(val)}</p>
                    </div>
                  ))}
                </div>
              )}

              {checkin.notes && (
                <div className="mt-4 rounded-xl border border-border bg-background/70 p-4">
                  <p className="portal-label">
                    {t('components.clientdetail.clientcheckins.client_notes')}
                  </p>
                  <p className="portal-body mt-2 text-foreground">{checkin.notes}</p>
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
  <span className="portal-pill inline-flex items-center gap-2 rounded-full border border-border bg-background px-3 py-1.5 text-foreground normal-case tracking-normal">
    {icon}
    <span className="portal-meta text-muted-foreground">{label}</span>
    <span className="portal-meta text-foreground">{value}</span>
  </span>
);
