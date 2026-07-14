import React, { useMemo, useState } from 'react';
import {
  ClipboardCheck,
  FileText,
  LayoutGrid,
  LayoutList,
  MessageSquare,
  PanelLeftClose,
  PanelLeftOpen,
  Plus,
  Scale,
  ShieldAlert,
  User,
  UtensilsCrossed,
  X,
} from 'lucide-react';
import type { ProfessionalClient } from '../../types/database.types';
import { PlanBuilder } from './PlanBuilder';
import { PlanList } from './PlanList';
import { PlanEditor } from './PlanEditor';
import { SnapshotsPanel } from './SnapshotsPanel';
import { ChatPanel } from './ChatPanel';
import { ClientNotes } from './ClientNotes';
import { ClientProgressPanel } from './ClientProgressPanel';
import { ClientCheckins } from './ClientCheckins';
import { ClientProfile } from './ClientProfile';
import { DiaryPanel } from './DiaryPanel';
import { SummaryPanel } from './SummaryPanel';
import { useAuth } from '../../lib/auth-context';
import { usePortalI18n } from '../../lib/portal-i18n';
import { usePortalNavigation, DetailTab } from '../../lib/navigation-context';
import { formatPortalDate, formatPortalTime } from '../../lib/date';
import { getLatestSnapshot, getSnapshotAdherence } from '../../view-models/clients';
import { usePlans } from '../../hooks/queries/usePlans';
import { useClientCheckinRequests, useClientCheckins } from '../../hooks/queries/useCheckins';
import { useClientProgress } from '../../hooks/queries/useClientProgress';
import { useMessages } from '../../hooks/queries/useMessages';
import { isDemoClient } from '../../lib/demo-client';

interface ClientDetailProps {
  client: ProfessionalClient;
  onClose: () => void;
  onMessagesRead?: () => void;
  isRosterCollapsed?: boolean;
  onToggleRoster?: () => void;
  unreadCount?: number;
  onClientUpdated?: (client: ProfessionalClient) => void;
}

type PlanView = 'list' | 'new' | 'edit';


export const ClientDetail: React.FC<ClientDetailProps> = ({
  client,
  onClose,
  onMessagesRead,
  isRosterCollapsed = false,
  onToggleRoster,
  unreadCount = 0,
  onClientUpdated,
}) => {
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();

  const [planView, setPlanView] = useState<PlanView>('list');
  const [editingPlanId, setEditingPlanId] = useState<string | null>(null);
  const { detailTab, selectClientTab: setDetailTab } = usePortalNavigation();

  React.useEffect(() => {
    if (detailTab === 'plans') {
      setEditingPlanId(null);
      setPlanView('list');
    }
  }, [detailTab]);

  const { data: plans = [] } = usePlans(client.client_id, professional?.id);
  const { data: checkins = [] } = useClientCheckins(client.id);
  const { data: checkinRequests = [] } = useClientCheckinRequests(client.id);
  const { data: progressRecords = [] } = useClientProgress(client.id);
  const { data: messages = [] } = useMessages(client.id);

  const clientName = client.display_name || client.client_id.slice(0, 8);
  const initials = clientName
    .split(/\s+/)
    .map((part) => part[0])
    .join('')
    .slice(0, 2)
    .toUpperCase();

  const latestSnapshot = getLatestSnapshot(client);

  const weeklyAdherence = useMemo(() => {
    const snapshots = client.client_shared_snapshots || [];
    if (snapshots.length === 0) return { val: null, pts: [] as number[] };
    const valid = snapshots
      .map((s) => getSnapshotAdherence(s))
      .filter((a): a is number => a !== null);
    if (valid.length === 0) return { val: null, pts: [] as number[] };
    const avg = Math.round(valid.reduce((sum, val) => sum + val, 0) / valid.length);
    return { val: avg, pts: valid.slice(-5) };
  }, [client.client_shared_snapshots]);

  const pendingCheckinCount =
    checkinRequests.filter((request) => request.status === 'pending').length +
    checkins.filter((checkin) => !checkin.reviewed_at).length;
  const latestCheckinDateStr =
    checkins.length > 0 && checkins[0]?.submitted_at
      ? formatPortalDate(checkins[0].submitted_at, locale, {
          month: 'numeric',
          day: 'numeric',
          year: 'numeric',
        })
      : null;

  const latestMessageTimeStr =
    messages.length > 0 && messages[messages.length - 1]?.created_at
      ? formatPortalTime(messages[messages.length - 1]!.created_at, locale, {
          hour: '2-digit',
          minute: '2-digit',
        })
      : null;

  const weightMetrics = useMemo(() => {
    const snapshots = client.client_shared_snapshots || [];
    const fromProgress = progressRecords
      .filter((r) => r.weight_kg != null && r.weight_kg > 0)
      .map((r) => ({ date: r.record_date, val: r.weight_kg! }));
    const fromSnapshots = snapshots
      .filter((s) => s.weight_kg != null && s.weight_kg > 0)
      .map((s) => ({ date: s.snapshot_date, val: s.weight_kg! }));

    const merged = [...fromProgress, ...fromSnapshots];
    merged.sort((a, b) => a.date.localeCompare(b.date));

    const result: { date: string; val: number }[] = [];
    merged.forEach((item) => {
      if (result.length === 0 || result[result.length - 1]?.date !== item.date) {
        result.push(item);
      }
    });

    const current = result.length > 0 ? (result[result.length - 1]?.val ?? null) : null;
    let change = 0;
    if (result.length >= 2 && current !== null) {
      const first = result[0]?.val ?? 0;
      change = current - first;
    }
    return { current, change };
  }, [progressRecords, client.client_shared_snapshots]);

  const activePlan = plans.find((p) => p.status === 'active') || null;
  const activePlanStartStr =
    activePlan && activePlan.starts_on
      ? formatPortalDate(activePlan.starts_on, locale, {
          month: 'numeric',
          day: 'numeric',
          year: 'numeric',
        })
      : null;

  const tabs: Array<{ id: DetailTab; label: string; icon: React.ReactNode; badge?: number }> = [
    { id: 'summary', label: t('components.clientdetail.index.summary'), icon: <LayoutGrid className="h-4 w-4" /> },
    { id: 'plans', label: t('components.clientdetail.index.plans'), icon: <LayoutList className="h-4 w-4" /> },
    { id: 'checkins', label: t('components.clientdetail.index.check_ins'), icon: <ClipboardCheck className="h-4 w-4" /> },
    { id: 'progress', label: t('components.clientdetail.index.progress'), icon: <Scale className="h-4 w-4" /> },
    {
      id: 'chat',
      label: t('components.clientdetail.index.chat'),
      icon: <MessageSquare className="h-4 w-4" />,
      badge: unreadCount > 0 ? unreadCount : undefined,
    },
    { id: 'diary', label: t('components.clientdetail.index.diary'), icon: <UtensilsCrossed className="h-4 w-4" /> },
    { id: 'notes', label: t('components.clientdetail.index.notes'), icon: <FileText className="h-4 w-4" /> },
    { id: 'profile', label: t('components.clientdetail.index.profile'), icon: <User className="h-4 w-4" /> },
  ];

  return (
    <section className="space-y-6 animate-fade-in-up w-full" id="client-detail-section">
      <div className="portal-hero rounded-[1.8rem] p-8">
        <div className="flex items-start justify-between gap-4">
          <div className="flex min-w-0 items-start gap-5">
            <div className="portal-metric flex h-20 w-20 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm">
              {initials}
            </div>
            <div className="min-w-0 space-y-2.5">
              <p className="portal-kicker">
                {t('components.clientdetail.index.selected_client')}
              </p>
              <div className="flex items-center gap-2.5 flex-wrap">
                <h2 className="portal-title truncate text-foreground">
                  {clientName}
                </h2>
                {isDemoClient(client) && (
                  <span className="inline-flex items-center rounded-lg border border-amber-500/30 bg-amber-500/10 px-2.5 py-1 portal-pill text-amber-600 dark:text-amber-300">
                    {t('components.tour.demo_client_badge')}
                  </span>
                )}
                {!isDemoClient(client) && (
                  <button
                    onClick={() => setDetailTab('profile')}
                    className="text-muted-foreground transition-colors hover:text-foreground"
                    title={t('components.clientdetail.index.edit_profile')}
                  >
                    <FileText className="h-5 w-5" />
                  </button>
                )}
              </div>

            </div>
          </div>

          <div className="flex items-center gap-2">
            {onToggleRoster && (
              <button
                onClick={onToggleRoster}
                className="rounded-xl border border-border bg-card p-2.5 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground xl:flex"
                title={
                  isRosterCollapsed
                    ? t('components.clientdetail.index.expand_roster')
                    : t('components.clientdetail.index.collapse_roster')
                }
              >
                {isRosterCollapsed ? (
                  <PanelLeftOpen className="h-4.5 w-4.5 text-primary" />
                ) : (
                  <PanelLeftClose className="h-4.5 w-4.5" />
                )}
              </button>
            )}
            <button
              onClick={onClose}
              className="rounded-xl border border-border bg-card p-2.5 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
              aria-label={t('components.clientdetail.index.close_details')}
            >
              <X className="h-4.5 w-4.5" />
            </button>
          </div>
        </div>

        <div className="mt-6 grid grid-cols-[repeat(auto-fit,minmax(160px,1fr))] gap-5">
          {/* Adherencia semanal */}
          <div className="portal-panel flex flex-col rounded-2xl p-6 shadow-sm">
            <p className="min-h-[2.5rem] portal-label">
              {t('components.clientdetail.index.weekly_adherence')}
            </p>
            <div className="mt-2.5 flex items-baseline gap-2">
              <p className="portal-kpi-value">
                {weeklyAdherence.val !== null ? `${weeklyAdherence.val}%` : '--'}
              </p>
              {weeklyAdherence.pts.length >= 2 && (
                <svg width="42" height="16" className="ml-1 shrink-0 overflow-visible">
                  <path
                    d={weeklyAdherence.pts
                      .map((val, idx) => {
                        const x = (idx / (weeklyAdherence.pts.length - 1)) * 38;
                        const y = 14 - (val / 100) * 12;
                        return `${idx === 0 ? 'M' : 'L'}${x},${y}`;
                      })
                      .join(' ')}
                    fill="none"
                    stroke="#4ade80"
                    strokeWidth="2.5"
                    strokeLinecap="round"
                  />
                </svg>
              )}
            </div>
            <p className="portal-meta mt-auto pt-2.5 leading-none">
              {t('components.clientdetail.index.goal_over_75')}
            </p>
          </div>

          {/* Check-ins pendientes */}
          <div className="portal-panel flex flex-col rounded-2xl p-6 shadow-sm">
            <p className="min-h-[2.5rem] portal-label">
              {t('components.clientdetail.index.pending_checkin')}
            </p>
            <p className="portal-kpi-value mt-2.5">{pendingCheckinCount}</p>
            <p className="portal-meta mt-auto truncate pt-2.5 leading-none">
              {latestCheckinDateStr
                ? t('components.clientdetail.index.latest_prefix', { value: latestCheckinDateStr })
                : t('components.clientdetail.index.none_pending')}
            </p>
          </div>

          {/* Mensajes sin leer */}
          <div className="portal-panel flex flex-col rounded-2xl p-6 shadow-sm">
            <p className="min-h-[2.5rem] portal-label">
              {t('components.clientdetail.index.unread_messages')}
            </p>
            <p className="portal-kpi-value mt-2.5">{unreadCount}</p>
            <p className="portal-meta mt-auto truncate pt-2.5 leading-none">
              {latestMessageTimeStr
                ? t('components.clientdetail.index.latest_prefix', {
                    value: `${t('components.clientdetail.index.today')}, ${latestMessageTimeStr}`,
                  })
                : t('components.clientdetail.index.no_new_messages')}
            </p>
          </div>

          {/* Peso actual */}
          <div className="portal-panel flex flex-col rounded-2xl p-6 shadow-sm">
            <p className="min-h-[2.5rem] portal-label">
              {t('components.clientdetail.index.current_weight')}
            </p>
            <p className="portal-kpi-value mt-2.5">
              {weightMetrics.current ? `${weightMetrics.current.toFixed(1)} kg` : '--'}
            </p>
            {weightMetrics.change !== 0 ? (
              <p
                className={`portal-meta mt-auto flex items-center gap-0.5 pt-2.5 leading-none ${
                  weightMetrics.change < 0 ? 'text-green-500' : 'text-rose-500'
                }`}
              >
                {t('components.clientdetail.index.change_7_days', {
                  value: `${weightMetrics.change > 0 ? '+' : ''}${weightMetrics.change.toFixed(1)} kg`,
                })}
              </p>
            ) : (
              <p className="portal-meta mt-auto pt-2.5 leading-none">
                {t('components.clientdetail.index.no_changes')}
              </p>
            )}
          </div>

          {/* Última actualización */}
          <div className="portal-panel flex flex-col rounded-2xl p-6 shadow-sm">
            <p className="min-h-[2.5rem] portal-label">
              {t('components.clientdetail.index.latest_update')}
            </p>
            <p className="portal-kpi-value mt-2.5">
              {latestSnapshot
                ? formatPortalDate(latestSnapshot.snapshot_date, locale, {
                    month: 'short',
                    day: 'numeric',
                  })
                : t('components.clientdetail.index.today')}
            </p>
            <p className="portal-meta mt-auto pt-2.5 leading-none">
              {latestSnapshot
                ? t('components.clientdetail.index.synced')
                : t('components.clientdetail.index.not_synced')}
            </p>
          </div>

          {/* Plan activo */}
          <div className="portal-panel flex flex-col rounded-2xl p-6 shadow-sm">
            <p className="min-h-[2.5rem] portal-label">
              {t('components.clientdetail.index.active_plan')}
            </p>
            <p className="portal-card-heading mt-2.5 leading-tight line-clamp-2" title={activePlan ? activePlan.name.replace(/semanals/gi, 'semanal') : undefined}>
              {activePlan ? activePlan.name.replace(/semanals/gi, 'semanal') : t('components.clientdetail.index.none')}
            </p>
            <p className="portal-meta mt-auto truncate pt-2.5 leading-none">
              {activePlanStartStr
                ? t('components.clientdetail.index.started_prefix', {
                    date: activePlanStartStr,
                  })
                : t('components.clientdetail.index.inactive')}
            </p>
          </div>
        </div>

      </div>

      <div className="flex flex-wrap gap-2.5">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            id={`tour-client-${tab.id}-tab`}
            onClick={() => {
              setDetailTab(tab.id);
              if (tab.id === 'plans') {
                setEditingPlanId(null);
                setPlanView('list');
              }
            }}
            className={`flex items-center justify-center gap-2 rounded-xl px-3.5 py-2.5 portal-action transition-all ${
              detailTab === tab.id
                ? 'bg-primary text-primary-foreground shadow-sm shadow-primary/20'
                : 'portal-chip hover:bg-accent hover:text-foreground'
            }`}
          >
            {tab.icon}
            <span className="font-medium">{tab.label}</span>
            {tab.badge ? (
              <span className="shrink-0 rounded-full bg-rose-500 px-2.5 py-1 portal-pill text-white">
                {tab.badge}
              </span>
            ) : null}
          </button>
        ))}
      </div>

      {detailTab === 'plans' && (
        <div className="flex flex-wrap gap-2">
          <button
            onClick={() => {
              setEditingPlanId(null);
              setPlanView('list');
            }}
            className={`inline-flex items-center gap-2 rounded-xl px-3 py-2 portal-action transition-colors ${
              planView === 'list'
                ? 'border border-border bg-card text-foreground shadow-sm'
                : 'portal-chip hover:bg-accent'
            }`}
          >
            <LayoutList className="h-3.5 w-3.5" />
            {t('components.clientdetail.index.plans')}
          </button>
          <button
            onClick={() => {
              setEditingPlanId(null);
              setPlanView('new');
            }}
            className={`inline-flex items-center gap-2 rounded-xl px-3 py-2 portal-action transition-colors ${
              planView === 'new'
                ? 'border border-border bg-card text-foreground shadow-sm'
                : 'portal-chip hover:bg-accent'
            }`}
          >
            <Plus className="h-3.5 w-3.5" />
            {t('components.clientdetail.index.new_plan')}
          </button>
        </div>
      )}

      <div className="space-y-6">
        {detailTab === 'summary' && (
          <SummaryPanel
            client={client}
            unreadCount={unreadCount}
            messages={messages}
            onSetActiveTab={(tab) => {
              setDetailTab(tab);
              if (tab === 'plans') {
                setEditingPlanId(null);
                setPlanView('list');
              }
            }}
            onEditPlan={(planId) => {
              setEditingPlanId(planId);
              setPlanView('edit');
              setDetailTab('plans');
            }}
          />
        )}

        {detailTab === 'plans' && (
          <div className="grid grid-cols-1 gap-6 lg:grid-cols-12">
            <div className={planView === 'list' ? 'lg:col-span-7' : 'lg:col-span-12'}>
              {planView === 'list' && (
                <PlanList
                  client={client}
                  onNewPlan={() => {
                    setEditingPlanId(null);
                    setPlanView('new');
                  }}
                  onEditPlan={(planId) => {
                    setEditingPlanId(planId);
                    setPlanView('edit');
                  }}
                />
              )}
              {planView === 'new' && <PlanBuilder client={client} />}
              {planView === 'edit' && editingPlanId && (
                <PlanEditor
                  client={client}
                  planId={editingPlanId}
                  onBack={() => {
                    setEditingPlanId(null);
                    setPlanView('list');
                  }}
                />
              )}
            </div>
            {planView === 'list' && (
              <div className="lg:col-span-5">
                <SnapshotsPanel client={client} />
              </div>
            )}
          </div>
        )}

        {detailTab === 'notes' && <ClientNotes client={client} />}
        {detailTab === 'progress' && <ClientProgressPanel client={client} />}
        {detailTab === 'checkins' && <ClientCheckins client={client} />}
        {detailTab === 'diary' && <DiaryPanel client={client} />}
        {detailTab === 'profile' && (
          <ClientProfile client={client} onClientUpdated={onClientUpdated} />
        )}

        {detailTab === 'chat' && (
          <div className="w-full animate-fade-in-up">
            {client.messages_enabled ? (
              <ChatPanel client={client} onMessagesRead={onMessagesRead} />
            ) : (
              <div className="portal-panel flex items-start gap-3 rounded-[1.6rem] border-amber-500/25 bg-amber-500/8 p-5">
                <ShieldAlert className="mt-0.5 h-5 w-5 shrink-0 text-amber-500 dark:text-amber-300" />
                <div className="space-y-1">
                  <p className="portal-card-heading text-foreground">
                    {t('components.clientdetail.index.chat_disabled')}
                  </p>
                  <p className="portal-body text-muted-foreground">
                    {t(
                      'components.clientdetail.index.this_client_has_disabled_messages_from_the_privacy_settings_in_the_mobil',
                    )}
                  </p>
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </section>
  );
};
