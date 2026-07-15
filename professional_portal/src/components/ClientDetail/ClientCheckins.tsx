import React from 'react';
import { Activity, ClipboardCheck, Clock, Moon, Send, Smile, ChevronDown, ChevronUp } from 'lucide-react';
import type { ProfessionalClient } from '../../types/database.types';
import { useClientCheckinRequests, useClientCheckins } from '../../hooks/queries/useCheckins';
import { useRequestCheckin } from '../../hooks/mutations/useRequestCheckin';
import { useMarkCheckinsReviewed, useMarkSingleCheckinReviewed } from '../../hooks/mutations/useMarkCheckinsReviewed';
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
  const markSingleReviewed = useMarkSingleCheckinReviewed(client.id, professional?.id);

  const dailyNotes = React.useMemo(() => {
    return (client.client_shared_snapshots || [])
      .filter((s) => s.notes && s.notes.trim() !== '')
      .sort((a, b) => b.snapshot_date.localeCompare(a.snapshot_date));
  }, [client.client_shared_snapshots]);

  const [expandedCheckins, setExpandedCheckins] = React.useState<Record<string, boolean>>({});

  const toggleExpand = (checkinId: string) => {
    setExpandedCheckins((prev) => ({
      ...prev,
      [checkinId]: !prev[checkinId],
    }));
  };

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

  // Calculate Averages for Dashboard
  const { avgEnergy, avgSleep, dominantMood } = React.useMemo(() => {
    if (!checkins || checkins.length === 0) {
      return { avgEnergy: null, avgSleep: null, dominantMood: null };
    }

    const checkinsWithEnergy = checkins.filter((c) => c.energy_level != null);
    const energyAvg = checkinsWithEnergy.length > 0
      ? (checkinsWithEnergy.reduce((sum, c) => sum + c.energy_level!, 0) / checkinsWithEnergy.length).toFixed(1)
      : null;

    const checkinsWithSleep = checkins.filter((c) => c.sleep_avg != null);
    const sleepAvg = checkinsWithSleep.length > 0
      ? (checkinsWithSleep.reduce((sum, c) => sum + c.sleep_avg!, 0) / checkinsWithSleep.length).toFixed(1)
      : null;

    const checkinsWithMood = checkins.filter((c) => c.mood);
    const moodCounts = checkinsWithMood.reduce<Record<string, number>>((acc, c) => {
      acc[c.mood!] = (acc[c.mood!] ?? 0) + 1;
      return acc;
    }, {});

    let moodDom = null;
    let maxCount = 0;
    Object.entries(moodCounts).forEach(([mood, count]) => {
      if (count > maxCount) {
        maxCount = count;
        moodDom = mood;
      }
    });

    return { avgEnergy: energyAvg, avgSleep: sleepAvg, dominantMood: moodDom };
  }, [checkins]);

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

      {/* Metrics Dashboard */}
      {checkins && checkins.length > 0 && (avgEnergy || avgSleep || dominantMood) && (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
          {avgEnergy && (
            <div className="portal-panel rounded-2xl p-4.5 flex items-center gap-3.5 bg-card/30 border border-border/60">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-600 dark:text-[#72de98]">
                <Activity className="h-5 w-5" />
              </div>
              <div>
                <p className="portal-label text-[10px] text-muted-foreground/80">Energía Promedio</p>
                <p className="portal-kpi-value text-xl font-extrabold mt-0.5 text-foreground">{avgEnergy} <span className="text-xs text-muted-foreground">/10</span></p>
              </div>
            </div>
          )}
          {avgSleep && (
            <div className="portal-panel rounded-2xl p-4.5 flex items-center gap-3.5 bg-card/30 border border-border/60">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-indigo-500/10 text-indigo-600 dark:text-[#818cf8]">
                <Moon className="h-5 w-5" />
              </div>
              <div>
                <p className="portal-label text-[10px] text-muted-foreground/80">Sueño Promedio</p>
                <p className="portal-kpi-value text-xl font-extrabold mt-0.5 text-foreground">{avgSleep} <span className="text-xs text-muted-foreground">h</span></p>
              </div>
            </div>
          )}
          {dominantMood && (
            <div className="portal-panel rounded-2xl p-4.5 flex items-center gap-3.5 bg-card/30 border border-border/60">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-amber-500/10 text-amber-600 dark:text-[#fcd34d]">
                <Smile className="h-5 w-5" />
              </div>
              <div>
                <p className="portal-label text-[10px] text-muted-foreground/80">Ánimo Predominante</p>
                <p className="portal-kpi-value text-xl font-extrabold mt-0.5 capitalize text-foreground">{dominantMood}</p>
              </div>
            </div>
          )}
        </div>
      )}

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
          {checkins.map((checkin) => {
            const isPending = !checkin.reviewed_at;
            const hasDetails = Object.keys(checkin.answers || {}).length > 0 || !!checkin.notes;
            const isExpanded = expandedCheckins[checkin.id] || false;

            return (
              <article
                key={checkin.id}
                className={`portal-panel rounded-[1.6rem] p-5 transition-all duration-200 border border-border ${
                  isPending
                    ? 'border-l-4 border-l-amber-500 bg-amber-500/[0.01] shadow-[0_0_15px_-3px_rgba(245,158,11,0.02)]'
                    : 'opacity-95'
                }`}
              >
                <div className="flex flex-col gap-3 border-b border-border pb-4 sm:flex-row sm:items-center sm:justify-between">
                  <div className="flex items-center gap-3">
                    {isPending && (
                      <span className="flex h-2.5 w-2.5 shrink-0 rounded-full bg-amber-500 animate-pulse" title="Nuevo" />
                    )}
                    <div>
                      <p className="portal-label">
                        {t('components.clientdetail.clientcheckins.submitted')}
                      </p>
                      <p className="portal-meta mt-1 text-foreground font-extrabold">
                        {formatPortalDate(checkin.submitted_at, locale, {
                          weekday: 'short', month: 'short', day: 'numeric',
                        })}
                        {' · '}
                        {formatPortalTime(checkin.submitted_at, locale, {
                          hour: '2-digit', minute: '2-digit',
                        })}
                      </p>
                    </div>
                  </div>
                  <div className="flex flex-wrap items-center gap-2 sm:justify-end">
                    {isPending ? (
                      <button
                        onClick={() => markSingleReviewed.mutate(checkin.id)}
                        disabled={markSingleReviewed.isPending}
                        className="portal-pill inline-flex items-center gap-1.5 rounded-full border border-amber-500/30 bg-amber-500/10 px-3 py-1.5 text-amber-700 dark:text-amber-300 font-extrabold hover:bg-amber-500/20 transition-all text-[10px]"
                      >
                        {markSingleReviewed.isPending ? '...' : (locale?.toLowerCase().startsWith('es') ? 'Marcar revisado' : 'Mark reviewed')}
                      </button>
                    ) : (
                      <span className="portal-pill inline-flex items-center gap-2 rounded-full border border-emerald-500/25 bg-emerald-500/10 px-3 py-1 text-emerald-700 dark:text-emerald-300">
                        {locale?.toLowerCase().startsWith('es') ? 'Revisado' : 'Reviewed'}
                      </span>
                    )}
                    {checkin.energy_level != null && (
                      <MetricChip
                        icon={<Activity className="h-3.5 w-3.5 text-emerald-500" />}
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

                {hasDetails && (
                  <div className="mt-4">
                    {isExpanded ? (
                      <div className="space-y-4 animate-fade-in-up">
                        {Object.keys(checkin.answers || {}).length > 0 && (
                          <div className="grid gap-3 md:grid-cols-2">
                            {Object.entries(checkin.answers).map(([key, val]) => (
                              <div key={key} className="rounded-xl border border-border bg-background/50 p-3.5">
                                <p className="text-xs font-bold text-muted-foreground/80">
                                  {key}
                                </p>
                                <div className="mt-2 bg-secondary/40 rounded-xl px-3 py-2 text-foreground inline-block max-w-full text-sm leading-relaxed">
                                  {String(val)}
                                </div>
                              </div>
                            ))}
                          </div>
                        )}

                        {checkin.notes && (
                          <div className="rounded-xl border border-border bg-background/50 p-4">
                            <p className="portal-label">
                              {t('components.clientdetail.clientcheckins.client_notes')}
                            </p>
                            <p className="portal-body mt-2 text-foreground leading-relaxed italic border-l-2 border-primary/30 pl-3">
                              "{checkin.notes}"
                            </p>
                          </div>
                        )}

                        <button
                          onClick={() => toggleExpand(checkin.id)}
                          className="w-full mt-2 text-center text-xs font-bold text-muted-foreground hover:text-foreground flex items-center justify-center gap-1 py-1.5 bg-secondary/20 hover:bg-secondary/40 rounded-xl transition-all"
                        >
                          {locale?.toLowerCase().startsWith('es') ? 'Ocultar respuestas' : 'Hide responses'} <ChevronUp className="h-3.5 w-3.5" />
                        </button>
                      </div>
                    ) : (
                      <button
                        onClick={() => toggleExpand(checkin.id)}
                        className="w-full text-center text-xs font-extrabold text-primary hover:text-primary/80 flex items-center justify-center gap-1 py-2.5 bg-secondary/15 hover:bg-secondary/35 rounded-xl transition-all"
                      >
                        {locale?.toLowerCase().startsWith('es') ? 'Ver respuestas y notas' : 'View responses & notes'} <ChevronDown className="h-3.5 w-3.5" />
                      </button>
                    )}
                  </div>
                )}
              </article>
            );
          })}
        </div>
      )}

      {dailyNotes.length > 0 && (
        <section className="portal-panel rounded-[1.6rem] p-5 space-y-4">
          <div className="flex items-center gap-2 text-primary border-b border-border pb-3">
            <ClipboardCheck className="h-4.5 w-4.5" />
            <h4 className="portal-card-heading">
              {locale?.toLowerCase().startsWith('es') ? 'Notas de contexto diario' : 'Daily context notes'}
            </h4>
          </div>
          <div className="space-y-3">
            {dailyNotes.map((note) => (
              <div key={note.id} className="rounded-2xl border border-border bg-card/45 p-4 flex flex-col gap-2">
                <div className="flex items-center justify-between">
                  <span className="portal-label text-muted-foreground">
                    {formatPortalDate(note.snapshot_date, locale)}
                  </span>
                  <span className="portal-pill rounded-full bg-primary/10 px-2 py-0.5 text-[9px] font-extrabold uppercase tracking-wider text-primary">
                    {locale?.toLowerCase().startsWith('es') ? 'Diario' : 'Daily'}
                  </span>
                </div>
                <p className="portal-body leading-relaxed text-foreground italic border-l-2 border-primary/45 pl-3">
                  "{note.notes}"
                </p>
              </div>
            ))}
          </div>
        </section>
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
