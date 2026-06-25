import React, { useEffect, useMemo, useState } from 'react';
import {
  Activity,
  ArrowRight,
  CheckSquare,
  FileText,
  MessageSquare,
  Scale,
  Square,
} from 'lucide-react';
import type {
  ProfessionalClient,
  ProfessionalClientMessage,
} from '../../types/database.types';
import { useAuth } from '../../lib/auth-context';
import { usePlans } from '../../hooks/queries/usePlans';
import { useClientCheckins } from '../../hooks/queries/useCheckins';
import { useClientProgress } from '../../hooks/queries/useClientProgress';
import { usePortalI18n } from '../../lib/portal-i18n';
import { formatPortalDate, formatPortalTime } from '../../lib/date';
import { getLatestSnapshot, getSnapshotAdherence } from '../../view-models/clients';

interface SummaryPanelProps {
  client: ProfessionalClient;
  unreadCount: number;
  messages: ProfessionalClientMessage[];
  onSetActiveTab: (tab: 'plans' | 'checkins' | 'progress' | 'chat' | 'diary' | 'notes' | 'profile') => void;
  onEditPlan?: (planId: string) => void;
}

type MetricType = 'peso' | 'adherencia';

export const SummaryPanel: React.FC<SummaryPanelProps> = ({
  client,
  unreadCount,
  messages,
  onSetActiveTab,
  onEditPlan,
}) => {
  const { professional } = useAuth();
  const { locale, t } = usePortalI18n();

  const { data: plans = [] } = usePlans(client.client_id, professional?.id);
  const { data: checkins = [] } = useClientCheckins(client.id);
  const { data: progressRecords = [] } = useClientProgress(client.id);

  const [metricType, setMetricType] = useState<MetricType>('peso');

  const storageKey = `today-priorities-${client.id}`;
  const [checkedPriorities, setCheckedPriorities] = useState<Record<string, boolean>>({});

  useEffect(() => {
    try {
      const saved = localStorage.getItem(storageKey);
      setCheckedPriorities(saved ? JSON.parse(saved) : {});
    } catch (error) {
      console.error(error);
    }
  }, [client.id, storageKey]);

  const savePriorities = (newChecked: Record<string, boolean>) => {
    setCheckedPriorities(newChecked);
    try {
      localStorage.setItem(storageKey, JSON.stringify(newChecked));
    } catch (error) {
      console.error(error);
    }
  };

  const activePlan = useMemo(() => plans.find((p) => p.status === 'active') || null, [plans]);

  const planProgressPct = useMemo(() => {
    if (!activePlan || !activePlan.starts_on || !activePlan.ends_on) return 0;
    const start = new Date(activePlan.starts_on).getTime();
    const end = new Date(activePlan.ends_on).getTime();
    const now = Date.now();
    if (now <= start) return 0;
    if (now >= end) return 100;
    return Math.round(((now - start) / (end - start)) * 100);
  }, [activePlan]);

  const planWeekText = useMemo(() => {
    if (!activePlan || !activePlan.starts_on || !activePlan.ends_on) {
      return t('components.clientdetail.summarypanel.default_plan_week');
    }
    const start = new Date(activePlan.starts_on).getTime();
    const end = new Date(activePlan.ends_on).getTime();
    const totalDays = Math.max(1, (end - start) / (1000 * 60 * 60 * 24));
    const elapsedDays = Math.max(0, (Date.now() - start) / (1000 * 60 * 60 * 24));
    const totalWeeks = Math.max(1, Math.ceil(totalDays / 7));
    const currentWeek = Math.min(totalWeeks, Math.ceil(elapsedDays / 7) || 1);
    return t('components.clientdetail.summarypanel.plan_week_progress', {
      current: currentWeek,
      total: totalWeeks,
    });
  }, [activePlan, t]);

  const priorities = useMemo(() => {
    const list: Array<{ id: string; label: string; sub: string }> = [];
    const pendingCheckin = checkins.length > 0 ? (checkins[0] ?? null) : null;

    if (pendingCheckin?.submitted_at) {
      list.push({
        id: 'checkin',
        label: t('components.clientdetail.summarypanel.review_pending_checkin'),
        sub: formatPortalDate(pendingCheckin.submitted_at, locale, {
          month: 'short',
          day: 'numeric',
        }),
      });
    } else {
      list.push({
        id: 'checkin_fallback',
        label: t('components.clientdetail.summarypanel.review_pending_checkin'),
        sub: t('components.clientdetail.summarypanel.no_recent_checkins'),
      });
    }

    if (unreadCount > 0) {
      const latestClientMsg =
        [...messages].reverse().find((m) => m.author_role === 'client' && !m.professional_read_at) ??
        null;
      list.push({
        id: 'messages',
        label: t('components.clientdetail.summarypanel.reply_client_messages_count', {
          count: unreadCount,
        }),
        sub: latestClientMsg?.created_at
          ? t('components.clientdetail.index.latest_prefix', {
              value: formatPortalTime(latestClientMsg.created_at, locale, {
                hour: '2-digit',
                minute: '2-digit',
              }),
            })
          : t('components.clientdetail.index.latest_prefix', {
              value: `${t('components.clientdetail.summarypanel.today')}, 08:30`,
            }),
      });
    } else {
      list.push({
        id: 'messages_fallback',
        label: t('components.clientdetail.summarypanel.review_message_channel'),
        sub: t('components.clientdetail.summarypanel.no_unread_messages'),
      });
    }

    const latestSnapshot = getLatestSnapshot(client);
    if (latestSnapshot?.weight_kg) {
      list.push({
        id: 'adjust_calories',
        label: t('components.clientdetail.summarypanel.adjust_calories_by_progress'),
        sub: t('components.clientdetail.summarypanel.current_weight_label', {
          weight: latestSnapshot.weight_kg,
        }),
      });
    } else {
      list.push({
        id: 'adjust_calories_fallback',
        label: t('components.clientdetail.summarypanel.adjust_calories_by_progress'),
        sub: t('components.clientdetail.summarypanel.waiting_for_weight_data'),
      });
    }

    return list;
  }, [checkins, unreadCount, messages, client, locale, t]);

  const togglePriority = (id: string) => {
    const next = { ...checkedPriorities, [id]: !checkedPriorities[id] };
    savePriorities(next);
  };

  const markAllPrioritiesCompleted = () => {
    const next: Record<string, boolean> = {};
    priorities.forEach((priority) => {
      next[priority.id] = true;
    });
    savePriorities(next);
  };

  const weightRecords = useMemo(() => {
    const snapshots = client.client_shared_snapshots || [];
    const fromProgress = progressRecords
      .filter((r) => r.weight_kg != null && r.weight_kg > 0)
      .map((r) => ({ date: r.record_date, val: r.weight_kg! }));
    const fromSnapshots = snapshots
      .filter((s) => s.weight_kg != null && s.weight_kg > 0)
      .map((s) => ({ date: s.snapshot_date, val: s.weight_kg! }));

    const merged = [...fromProgress, ...fromSnapshots];
    merged.sort((a, b) => a.date.localeCompare(b.date));

    const result: typeof merged = [];
    merged.forEach((item) => {
      if (result.length === 0 || result[result.length - 1]?.date !== item.date) {
        result.push(item);
      }
    });

    return result.slice(-7);
  }, [progressRecords, client.client_shared_snapshots]);

  const adherenceRecords = useMemo(() => {
    const snapshots = client.client_shared_snapshots || [];
    const mapped = snapshots.map((snapshot) => ({
      date: snapshot.snapshot_date,
      val: getSnapshotAdherence(snapshot) ?? 0,
    }));
    mapped.sort((a, b) => a.date.localeCompare(b.date));
    return mapped.slice(-7);
  }, [client.client_shared_snapshots]);

  const chartRecords = useMemo(
    () => (metricType === 'peso' ? weightRecords : adherenceRecords),
    [metricType, weightRecords, adherenceRecords],
  );

  const progressMetrics = useMemo(() => {
    const weights = [...weightRecords].map((r) => r.val);
    const latestWeight = weights.length > 0 ? (weights[weights.length - 1] ?? null) : null;
    let change7d = 0;
    if (weights.length >= 2 && latestWeight !== null) {
      const first = weights[0] ?? 0;
      change7d = latestWeight - first;
    }
    const avgWeeklyChange =
      weights.length >= 2 && latestWeight !== null
        ? Number((change7d / weights.length).toFixed(2))
        : 0;
    const initialWeight = weights.length > 0 ? (weights[0] ?? 0) : 0;
    return { latestWeight, change7d, avgWeeklyChange, initialWeight };
  }, [weightRecords]);

  const svgChart = useMemo(() => {
    if (chartRecords.length < 2) {
      return (
        <div className="flex h-36 items-center justify-center rounded-xl bg-muted/5 text-xs text-muted-foreground">
          {t('components.clientdetail.summarypanel.not_enough_records_for_chart')}
        </div>
      );
    }

    const w = 400;
    const h = 140;
    const px = 40;
    const py = 20;

    const vals = chartRecords.map((record) => record.val);
    const minVal = Math.min(...vals);
    const maxVal = Math.max(...vals);
    const range = Math.max(maxVal - minVal, 1);

    const points = chartRecords.map((item, index) => {
      const x = px + (index / (chartRecords.length - 1)) * (w - px * 2);
      const y = h - py - ((item.val - minVal) / range) * (h - py * 2);
      return { x, y, ...item };
    });

    const pathD = points
      .map((point, idx) => `${idx === 0 ? 'M' : 'L'}${point.x.toFixed(1)},${point.y.toFixed(1)}`)
      .join(' ');

    const lastPoint = points[points.length - 1];
    const firstPoint = points[0];
    if (!lastPoint || !firstPoint) return null;

    return (
      <svg viewBox={`0 0 ${w} ${h}`} className="h-auto w-full" preserveAspectRatio="xMidYMid meet">
        <defs>
          <linearGradient id="chartLineGrad" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stopColor="#4ade80" />
            <stop offset="100%" stopColor="#10b981" />
          </linearGradient>
          <linearGradient id="chartAreaGrad" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stopColor="#10b981" stopOpacity="0.15" />
            <stop offset="100%" stopColor="#10b981" stopOpacity="0" />
          </linearGradient>
        </defs>

        <line x1={px} y1={py} x2={w - px} y2={py} stroke="rgba(255,255,255,0.05)" strokeDasharray="3 3" />
        <line
          x1={px}
          y1={(py + h - py) / 2}
          x2={w - px}
          y2={(py + h - py) / 2}
          stroke="rgba(255,255,255,0.05)"
          strokeDasharray="3 3"
        />
        <line x1={px} y1={h - py} x2={w - px} y2={h - py} stroke="rgba(255,255,255,0.05)" strokeDasharray="3 3" />

        <text x={px - 8} y={py + 3} className="fill-muted-foreground text-[8px] font-semibold" textAnchor="end">
          {maxVal.toFixed(1)}
        </text>
        <text x={px - 8} y={h - py + 3} className="fill-muted-foreground text-[8px] font-semibold" textAnchor="end">
          {minVal.toFixed(1)}
        </text>

        <path
          d={`${pathD} L ${lastPoint.x.toFixed(1)},${(h - py).toFixed(1)} L ${firstPoint.x.toFixed(1)},${(h - py).toFixed(1)} Z`}
          fill="url(#chartAreaGrad)"
        />

        <path d={pathD} fill="none" stroke="url(#chartLineGrad)" strokeWidth="2.5" strokeLinecap="round" />

        {points.map((point, idx) => (
          <g key={idx} className="group cursor-pointer">
            <circle cx={point.x} cy={point.y} r="4" className="fill-card stroke-primary" strokeWidth="2" />
            <circle cx={point.x} cy={point.y} r="8" className="fill-transparent transition-colors hover:fill-primary/20" />
          </g>
        ))}

        {points.map((point, idx) => {
          const parts = point.date.split('-');
          const label =
            parts.length === 3
              ? `${parseInt(parts[2] ?? '', 10)}/${parseInt(parts[1] ?? '', 10)}`
              : point.date;
          const shouldShow = idx % 2 === 0 || idx === points.length - 1;
          if (!shouldShow) return null;
          return (
            <text
              key={idx}
              x={point.x}
              y={h - 4}
              className="fill-muted-foreground text-[8px] font-medium"
              textAnchor="middle"
            >
              {idx === points.length - 1 ? t('components.clientdetail.summarypanel.today') : label}
            </text>
          );
        })}
      </svg>
    );
  }, [chartRecords, t]);

  const recentActivity = useMemo(() => {
    const items: Array<{ id: string; icon: React.ReactNode; text: string; date: string; tone: string }> = [];
    const pendingCheckin = checkins.length > 0 ? (checkins[0] ?? null) : null;

    if (pendingCheckin?.submitted_at) {
      items.push({
        id: 'checkin',
        icon: <Activity className="h-5 w-5" />,
        text: t('components.clientdetail.summarypanel.pending_checkin'),
        date: formatPortalDate(pendingCheckin.submitted_at, locale, {
          month: 'short',
          day: 'numeric',
        }),
        tone: 'orange',
      });
    }

    const latestSnapshot = getLatestSnapshot(client);
    if (latestSnapshot?.snapshot_date) {
      items.push({
        id: 'sync',
        icon: <Activity className="h-5 w-5" />,
        text: t('components.clientdetail.summarypanel.latest_sync'),
        date: formatPortalDate(latestSnapshot.snapshot_date, locale, {
          month: 'short',
          day: 'numeric',
        }),
        tone: 'green',
      });
    }

    const latestClientMsg = messages.find((message) => message.author_role === 'client') ?? null;
    if (latestClientMsg?.created_at) {
      items.push({
        id: 'msg',
        icon: <MessageSquare className="h-5 w-5" />,
        text: t('components.clientdetail.summarypanel.latest_client_message'),
        date: `"${latestClientMsg.body.slice(0, 32)}${latestClientMsg.body.length > 32 ? '...' : ''}"`,
        tone: 'blue',
      });
    }

    if (progressMetrics.change7d !== 0) {
      items.push({
        id: 'weight',
        icon: <Scale className="h-5 w-5" />,
        text: t('components.clientdetail.summarypanel.weight_change_7_days'),
        date: `${progressMetrics.change7d > 0 ? '+' : ''}${progressMetrics.change7d.toFixed(1)} kg`,
        tone: 'green',
      });
    }

    return items;
  }, [checkins, client, locale, messages, progressMetrics.change7d, t]);

  return (
    <div className="grid items-stretch gap-6 animate-fade-in-up xl:grid-cols-12">
      <div className="flex md:col-span-6 xl:col-span-4">
        <div className="portal-panel flex w-full flex-col justify-between rounded-[1.8rem] p-8">
          <div>
            <h3 className="text-xl font-black text-foreground">
              {t('components.clientdetail.summarypanel.client_summary')}
            </h3>

            <div className="mt-5 flex items-center gap-2.5 text-base font-black uppercase tracking-[0.2em] text-primary">
              <CheckSquare className="h-5 w-5 text-primary" />
              {t('components.clientdetail.summarypanel.today_priorities')}
            </div>

            <div className="mt-4 space-y-3.5">
              {priorities.map((priority) => {
                const isChecked = !!checkedPriorities[priority.id];
                return (
                  <div
                    key={priority.id}
                    onClick={() => togglePriority(priority.id)}
                    className="flex cursor-pointer items-start gap-3.5 rounded-xl border border-border bg-background/30 p-5 transition-colors hover:bg-accent/30"
                  >
                    <button className="mt-0.5 shrink-0 text-primary">
                      {isChecked ? (
                        <CheckSquare className="h-6 w-6 fill-primary/10" />
                      ) : (
                        <Square className="h-6 w-6" />
                      )}
                    </button>
                    <div className="min-w-0 flex-1">
                      <p
                        className={`text-lg font-extrabold leading-tight ${
                          isChecked ? 'text-muted-foreground line-through' : 'text-foreground'
                        }`}
                      >
                        {priority.label}
                      </p>
                      <p className="mt-1.5 text-sm font-semibold text-muted-foreground">
                        {priority.sub}
                      </p>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          <button
            onClick={markAllPrioritiesCompleted}
            className="mt-5 w-full rounded-xl bg-primary/10 py-4.5 text-base font-extrabold uppercase tracking-[0.2em] text-primary transition-colors hover:bg-primary/15"
          >
            {t('components.clientdetail.summarypanel.mark_all_completed')}
          </button>
        </div>
      </div>

      <div className="flex md:col-span-6 xl:col-span-4">
        <div className="portal-panel flex w-full flex-col justify-between rounded-[1.8rem] p-6">
          <div>
            <h3 className="text-xl font-black text-foreground">
              {t('components.clientdetail.summarypanel.active_plan')}
            </h3>

            {activePlan ? (
              <div className="mt-4 space-y-4">
                <div className="flex items-center gap-4 rounded-2xl border border-border bg-background/40 p-6">
                  <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
                    <FileText className="h-6.5 w-6.5" />
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2.5">
                      <h4 className="truncate text-lg font-black text-foreground">
                        {activePlan.name.replace(/semanals/gi, 'semanal')}
                      </h4>
                      <span className="rounded-full bg-primary/15 px-2.5 py-1 text-xs font-black uppercase tracking-wider text-primary">
                        {t('components.clientdetail.summarypanel.active')}
                      </span>
                    </div>
                    <p className="mt-1.5 text-base font-medium text-muted-foreground">
                      {t('components.clientdetail.summarypanel.started_on', {
                        date: activePlan.starts_on
                          ? formatPortalDate(activePlan.starts_on, locale)
                          : '16/6/2026',
                      })}
                    </p>
                  </div>
                </div>

                <div className="space-y-2">
                  <div className="flex items-center justify-between text-base font-extrabold">
                    <span className="text-foreground">{planWeekText}</span>
                    <span className="text-muted-foreground">{planProgressPct}%</span>
                  </div>
                  <div className="h-3 w-full overflow-hidden rounded-full bg-muted/20">
                    <div
                      className="h-full rounded-full bg-primary transition-all duration-300"
                      style={{ width: `${planProgressPct}%` }}
                    />
                  </div>
                </div>

                {activePlan.ends_on && (
                  <p className="text-base font-semibold text-muted-foreground">
                    {t('components.clientdetail.summarypanel.next_delivery', {
                      date: formatPortalDate(activePlan.ends_on, locale),
                    })}
                  </p>
                )}
              </div>
            ) : (
              <div className="mt-8 text-center">
                <p className="text-sm text-muted-foreground">
                  {t('components.clientdetail.summarypanel.no_active_plan_now')}
                </p>
              </div>
            )}
          </div>

          {activePlan ? (
            <div className="grid grid-cols-2 gap-4 pt-2">
              <button
                onClick={() => onSetActiveTab('plans')}
                className="rounded-xl border border-border py-4 text-base font-extrabold uppercase tracking-[0.2em] text-foreground hover:bg-accent"
              >
                {t('components.clientdetail.summarypanel.view_plan')}
              </button>
              <button
                onClick={() => onEditPlan && onEditPlan(activePlan.id)}
                className="rounded-xl bg-primary py-4 text-base font-extrabold uppercase tracking-[0.2em] text-primary-foreground hover:opacity-95"
              >
                {t('components.clientdetail.summarypanel.edit_plan')}
              </button>
            </div>
          ) : (
            <button
              onClick={() => onSetActiveTab('plans')}
              className="mt-4 w-full rounded-xl bg-primary py-3 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground hover:opacity-95"
            >
              {t('components.clientdetail.summarypanel.create_plan')}
            </button>
          )}
        </div>
      </div>

      <div className="flex md:col-span-12 xl:col-span-4">
        <div className="portal-panel flex w-full flex-col justify-between rounded-[1.8rem] p-8">
          <div>
            <h3 className="text-xl font-black text-foreground">
              {t('components.clientdetail.summarypanel.recent_activity')}
            </h3>
            <div className="mt-5 space-y-4">
              {recentActivity.length > 0 ? (
                recentActivity.map((activity) => (
                  <div key={activity.id} className="flex items-start gap-3.5">
                    <div
                      className={`mt-0.5 flex h-10 w-10 shrink-0 items-center justify-center rounded-xl ${
                        activity.tone === 'orange'
                          ? 'bg-amber-500/10 text-amber-500'
                          : activity.tone === 'blue'
                            ? 'bg-sky-500/10 text-sky-500'
                            : 'bg-green-500/10 text-green-500'
                      }`}
                    >
                      {activity.icon}
                    </div>
                    <div className="min-w-0">
                      <p className="text-base font-extrabold text-foreground">
                        {activity.text}
                      </p>
                      <p className="mt-0.5 truncate text-sm font-semibold text-muted-foreground">
                        {activity.date}
                      </p>
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-sm text-muted-foreground">
                  {t('components.clientdetail.summarypanel.no_recent_activity')}
                </p>
              )}
            </div>
          </div>
        </div>
      </div>

      <div className="flex md:col-span-12 xl:col-span-8">
        <div className="portal-panel flex w-full flex-col justify-between rounded-[1.8rem] p-8">
          <div>
            <div className="flex items-center justify-between">
              <h3 className="text-xl font-black text-foreground">
                {t('components.clientdetail.summarypanel.progress')}
              </h3>
              <div className="flex gap-1 rounded-xl bg-muted/10 p-1">
                <button
                  onClick={() => setMetricType('peso')}
                  className={`rounded-lg px-5 py-2.5 text-base font-extrabold transition-colors ${
                    metricType === 'peso'
                      ? 'bg-primary text-primary-foreground'
                      : 'text-muted-foreground hover:text-foreground'
                  }`}
                >
                  {t('components.clientdetail.summarypanel.weight')}
                </button>
                <button
                  onClick={() => setMetricType('adherencia')}
                  className={`rounded-lg px-5 py-2.5 text-base font-extrabold transition-colors ${
                    metricType === 'adherencia'
                      ? 'bg-primary text-primary-foreground'
                      : 'text-muted-foreground hover:text-foreground'
                  }`}
                >
                  {t('components.clientdetail.summarypanel.adherence')}
                </button>
              </div>
            </div>

            <div className="mt-6 grid items-center gap-6 md:grid-cols-12">
              <div className="md:col-span-8">{svgChart}</div>

              <div className="space-y-5 md:col-span-4">
                <div className="border-l-2 border-primary/20 pl-3.5">
                  <p className="text-sm font-black uppercase tracking-[0.2em] text-muted-foreground">
                    {t('components.clientdetail.summarypanel.change_7_days')}
                  </p>
                  <p
                    className={`portal-metric mt-1 text-4xl font-black ${
                      progressMetrics.change7d < 0
                        ? 'text-green-500'
                        : progressMetrics.change7d > 0
                          ? 'text-rose-500'
                          : 'text-foreground'
                    }`}
                  >
                    {progressMetrics.change7d > 0 ? '+' : ''}
                    {progressMetrics.change7d.toFixed(1)} kg
                  </p>
                </div>
                <div className="border-l-2 border-primary/20 pl-3.5">
                  <p className="text-sm font-black uppercase tracking-[0.2em] text-muted-foreground">
                    {t('components.clientdetail.summarypanel.weekly_average')}
                  </p>
                  <p className="portal-metric mt-1 text-xl font-black text-foreground">
                    {progressMetrics.avgWeeklyChange > 0 ? '+' : ''}
                    {progressMetrics.avgWeeklyChange.toFixed(2)} kg/día
                  </p>
                </div>
                <div className="border-l-2 border-primary/20 pl-3.5">
                  <p className="text-sm font-black uppercase tracking-[0.2em] text-muted-foreground">
                    {t('components.clientdetail.summarypanel.starting_weight')}
                  </p>
                  <p className="portal-metric mt-1 text-xl font-black text-foreground">
                    {progressMetrics.initialWeight.toFixed(1)} kg
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="flex md:col-span-12 xl:col-span-4">
        <div className="portal-panel flex w-full flex-col justify-between rounded-[1.8rem] p-8">
          <div>
            <div className="flex items-center justify-between">
              <h3 className="text-xl font-black text-foreground">
                {t('components.clientdetail.summarypanel.latest_messages')}
              </h3>
              {unreadCount > 0 && (
                <span className="flex h-6 items-center justify-center rounded-full bg-primary px-2.5 text-xs font-black text-primary-foreground">
                  {unreadCount}
                </span>
              )}
            </div>

            <div className="mt-5 space-y-5">
              {messages.length > 0 ? (
                [...messages].slice(-3).reverse().map((message) => {
                  const isUnread =
                    message.author_role === 'client' && !message.professional_read_at;
                  return (
                    <div key={message.id} className="relative pl-4">
                      {isUnread && (
                        <span className="absolute left-0 top-2 h-2.5 w-2.5 rounded-full bg-primary" />
                      )}
                      <p className="line-clamp-2 text-base font-bold leading-relaxed text-foreground">
                        {message.body}
                      </p>
                      <p className="mt-1 text-sm font-medium text-muted-foreground">
                        {message.author_role === 'professional'
                          ? t('components.clientdetail.summarypanel.you')
                          : t('components.clientdetail.summarypanel.client')}{' '}
                        ·{' '}
                        {message.created_at
                          ? formatPortalTime(message.created_at, locale, {
                              hour: '2-digit',
                              minute: '2-digit',
                            })
                          : ''}
                      </p>
                    </div>
                  );
                })
              ) : (
                <p className="text-sm text-muted-foreground">
                  {t('components.clientdetail.summarypanel.no_previous_messages')}
                </p>
              )}
            </div>
          </div>

          <button
            onClick={() => onSetActiveTab('chat')}
            className="mt-5 inline-flex items-center gap-2 text-base font-extrabold uppercase tracking-[0.2em] text-primary transition-colors hover:opacity-85"
          >
            {t('components.clientdetail.summarypanel.view_all_messages')}
            <ArrowRight className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  );
};
