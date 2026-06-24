import React, { useMemo } from 'react';
import {
  ArrowRight,
  Calendar,
  ChefHat,
  ChevronRight,
  ClipboardCheck,
  CreditCard,
  Crown,
  LayoutGrid,
  MessageSquare,
  ShieldAlert,
  User,
  Users,
} from 'lucide-react';
import { usePortalI18n } from '../lib/portal-i18n';
import { useAuth } from '../lib/auth-context';
import { useClients, useUnreadCounts } from '../hooks/queries/useClients';
import { useNotifications } from '../hooks/queries/useNotifications';
import { usePerClientAdherence } from '../hooks/queries/useAnalytics';
import { getBillingSummary } from '../view-models/professional';

interface SidebarProps {
  activePanel: string;
  setActivePanel: (panel: string) => void;
  onInviteClient?: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ activePanel, setActivePanel }) => {
  const { professional } = useAuth();
  const { t } = usePortalI18n();

  const { data: clients = [] } = useClients(professional?.id);
  const { data: unreadCounts = {} } = useUnreadCounts(professional?.id);
  const { data: notifications = [] } = useNotifications(professional?.id);
  const { data: clientAdherence = [] } = usePerClientAdherence(professional?.id);

  const connectedClientsCount = useMemo(
    () => clients.filter((client) => client.status === 'connected').length,
    [clients],
  );
  const billingSummary = getBillingSummary(professional, connectedClientsCount);
  const billingIntervalLabel =
    billingSummary.billingInterval === 'annual'
      ? t('components.sidebar.annual')
      : t('components.sidebar.monthly');

  const totalUnreadMessages = useMemo(
    () => Object.values(unreadCounts).reduce((sum, val) => sum + val, 0),
    [unreadCounts],
  );
  const pendingCheckinsCount = useMemo(
    () => notifications.filter((n) => n.type === 'checkin_submitted' && !n.read).length,
    [notifications],
  );
  const clientsInRiskCount = useMemo(
    () => clientAdherence.filter((client) => client.avgKcalAdherence < 75).length,
    [clientAdherence],
  );

  const clientLimit = billingSummary.clientLimit || 10;
  const connectedClients = billingSummary.connectedClients;
  const planProgressPct = clientLimit ? (connectedClients / clientLimit) * 100 : 0;

  const getNavItemClass = (panel: string) => {
    const isActive = activePanel === panel;
    return `relative flex w-full items-center gap-3.5 rounded-xl px-3.5 py-2.5 text-left text-sm font-semibold transition-all ${
      isActive
        ? 'bg-[#121c19] text-[#72de98]'
        : 'text-[#8a9499] hover:bg-[#131719] hover:text-[#ffffff] group'
    }`;
  };

  return (
    <aside className="flex h-screen w-[292px] shrink-0 flex-col overflow-hidden border-r border-[#191e21] bg-[#0b0f11] text-sidebar-foreground shadow-2xl">
      <div className="flex h-20 shrink-0 items-center border-b border-[#181d20] bg-[#0b0f11] px-5">
        <div className="flex items-center gap-2.5">
          <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-[#72de98] text-[#0b0f11] font-black shadow-inner">
            M
          </div>
          <span className="text-lg font-black tracking-tight text-white">
            Macro<span className="text-[#72de98]">Tracker</span>
          </span>
        </div>
      </div>

      <div className="flex-1 space-y-5 overflow-y-auto p-5 scrollbar-thin">
        <div className="space-y-2">
          <h3 className="px-3.5 text-[10px] font-extrabold uppercase tracking-[0.18em] text-[#8a9499]">
            {t('components.sidebar.navigation')}
          </h3>
          <nav className="flex flex-col gap-1">
            <button
              onClick={() => {
                setActivePanel('dashboard-panel');
                window.location.hash = 'dashboard-panel';
              }}
              className={getNavItemClass('dashboard-panel')}
            >
              <LayoutGrid className="h-[18px] w-[18px] shrink-0" />
              <span>{t('components.sidebar.overview')}</span>
              {activePanel === 'dashboard-panel' && (
                <span className="absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-r bg-[#72de98]" />
              )}
            </button>

            <button
              onClick={() => {
                setActivePanel('clients-panel');
                window.location.hash = 'clients-panel';
              }}
              className={getNavItemClass('clients-panel')}
            >
              <Users className="h-[18px] w-[18px] shrink-0" />
              <span>{t('components.sidebar.clients')}</span>
              {activePanel === 'clients-panel' && (
                <span className="absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-r bg-[#72de98]" />
              )}
            </button>

            <button
              onClick={() => {
                setActivePanel('templates-panel');
                window.location.hash = 'templates-panel';
              }}
              className={getNavItemClass('templates-panel')}
            >
              <ClipboardCheck className="h-[18px] w-[18px] shrink-0" />
              <span>{t('components.sidebar.templates')}</span>
              {activePanel === 'templates-panel' && (
                <span className="absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-r bg-[#72de98]" />
              )}
            </button>

            <button
              onClick={() => {
                setActivePanel('checkins-panel');
                window.location.hash = 'checkins-panel';
              }}
              className={getNavItemClass('checkins-panel')}
            >
              <ClipboardCheck className="h-[18px] w-[18px] shrink-0" />
              <span>{t('components.sidebar.check_ins')}</span>
              {activePanel === 'checkins-panel' && (
                <span className="absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-r bg-[#72de98]" />
              )}
            </button>

            <button
              onClick={() => {
                setActivePanel('billing-panel');
                window.location.hash = 'billing-panel';
              }}
              className={getNavItemClass('billing-panel')}
            >
              <CreditCard className="h-[18px] w-[18px] shrink-0" />
              <span>{t('components.sidebar.billing')}</span>
              {activePanel === 'billing-panel' && (
                <span className="absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-r bg-[#72de98]" />
              )}
            </button>

            <button
              onClick={() => {
                setActivePanel('profile-panel');
                window.location.hash = 'profile-panel';
              }}
              className={getNavItemClass('profile-panel')}
            >
              <User className="h-[18px] w-[18px] shrink-0" />
              <span>{t('components.sidebar.profile')}</span>
              {activePanel === 'profile-panel' && (
                <span className="absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-r bg-[#72de98]" />
              )}
            </button>
          </nav>
        </div>

        <div className="h-px bg-[#181d20]" />

        <div className="space-y-2">
          <h3 className="px-3.5 text-[10px] font-extrabold uppercase tracking-[0.18em] text-[#8a9499]">
            {t('components.sidebar.library_section')}
          </h3>
          <nav className="flex flex-col gap-1">
            <button
              onClick={() => {
                setActivePanel('recipes-panel');
                window.location.hash = 'recipes-panel';
              }}
              className={getNavItemClass('recipes-panel')}
            >
              <ChefHat className="h-[18px] w-[18px] shrink-0" />
              <span>{t('components.sidebar.recipes')}</span>
              {activePanel === 'recipes-panel' && (
                <span className="absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-r bg-[#72de98]" />
              )}
            </button>
          </nav>
        </div>
      </div>

      <div className="space-y-4 px-5 pb-5">
        <div className="mb-2 h-px bg-[#181d20]" />

        <div className="rounded-2xl border border-[#1e2326] bg-[#131719] p-4 shadow-sm">
          <div className="flex items-center gap-2 text-[10px] font-extrabold uppercase tracking-[0.18em] text-[#8a9499]">
            <Calendar className="h-4 w-4" />
            <span>{t('components.sidebar.today')}</span>
          </div>

          <div className="mt-4 space-y-3.5">
            <button
              onClick={() => {
                setActivePanel('checkins-panel');
                window.location.hash = 'checkins-panel';
              }}
              className="flex w-full items-center justify-between text-left transition-opacity hover:opacity-80"
            >
              <div className="flex items-center gap-3">
                <div className="flex h-8 w-8 items-center justify-center rounded-xl border border-[#1b3027] bg-[#121c18] text-[#72de98]">
                  <ClipboardCheck className="h-4.5 w-4.5" />
                </div>
                <span className="text-xs font-semibold leading-none text-[#e1e3e5]">
                  {pendingCheckinsCount === 1
                    ? t('components.sidebar.pending_checkins_count_one', {
                        count: pendingCheckinsCount,
                      })
                    : t('components.sidebar.pending_checkins_count', {
                        count: pendingCheckinsCount,
                      })}
                </span>
              </div>
              <ChevronRight className="h-4 w-4 text-[#5c686d]" />
            </button>

            <button
              onClick={() => {
                setActivePanel('clients-panel');
                window.location.hash = 'clients-panel';
              }}
              className="flex w-full items-center justify-between text-left transition-opacity hover:opacity-80"
            >
              <div className="flex items-center gap-3">
                <div className="flex h-8 w-8 items-center justify-center rounded-xl border border-[#1a2d33] bg-[#131b1e] text-[#38bdf8]">
                  <MessageSquare className="h-4.5 w-4.5" />
                </div>
                <span className="text-xs font-semibold leading-none text-[#e1e3e5]">
                  {totalUnreadMessages === 1
                    ? t('components.sidebar.unread_messages_count_one', {
                        count: totalUnreadMessages,
                      })
                    : t('components.sidebar.unread_messages_count', {
                        count: totalUnreadMessages,
                      })}
                </span>
              </div>
              <ChevronRight className="h-4 w-4 text-[#5c686d]" />
            </button>

            <button
              onClick={() => {
                setActivePanel('clients-panel');
                window.location.hash = 'clients-panel';
              }}
              className="flex w-full items-center justify-between text-left transition-opacity hover:opacity-80"
            >
              <div className="flex items-center gap-3">
                <div className="flex h-8 w-8 items-center justify-center rounded-xl border border-[#33251a] bg-[#1d1713] text-[#f59e0b]">
                  <ShieldAlert className="h-4.5 w-4.5" />
                </div>
                <span className="text-xs font-semibold leading-none text-[#e1e3e5]">
                  {clientsInRiskCount === 1
                    ? t('components.sidebar.low_adherence_clients_count_one', {
                        count: clientsInRiskCount,
                      })
                    : t('components.sidebar.low_adherence_clients_count', {
                        count: clientsInRiskCount,
                      })}
                </span>
              </div>
              <ChevronRight className="h-4 w-4 text-[#5c686d]" />
            </button>
          </div>
        </div>

        <div className="rounded-2xl border border-[#1e2326] bg-[#131719] p-4 shadow-sm">
          <div className="flex items-center justify-between gap-3">
            <div className="flex items-center gap-2 text-[10px] font-extrabold uppercase tracking-[0.18em] text-[#8a9499]">
              <Crown className="h-4 w-4 text-[#72de98]" />
              <span>{t('components.sidebar.current_plan_label')}</span>
            </div>
            <span className="h-2 w-2 rounded-full bg-[#72de98] shadow-[0_0_8px_rgba(114,222,152,0.6)]" />
          </div>

          <h4 className="mt-2.5 text-sm font-bold text-[#ffffff]">
            {billingSummary.tierLabel} / {billingIntervalLabel}
          </h4>
          <p className="mt-1 text-xs font-semibold text-[#8a9499]">
            {t('components.sidebar.clients_in_use_summary', {
              connected: connectedClients,
              limit: clientLimit,
            })}
          </p>

          <div className="mt-3 h-1.5 w-full overflow-hidden rounded-full bg-[#181d20]">
            <div
              className="h-full rounded-full bg-[#72de98] transition-all duration-500"
              style={{ width: `${planProgressPct}%` }}
            />
          </div>

          <button
            onClick={() => {
              setActivePanel('billing-panel');
              window.location.hash = 'billing-panel';
            }}
            className="mt-4 flex w-full items-center justify-between rounded-xl border border-[#1f3731] bg-[#0c1a16] px-4 py-2.5 text-xs font-bold uppercase tracking-[0.16em] text-[#72de98] transition-all hover:bg-[#122822] hover:text-[#83e9a7]"
          >
            <span>{t('components.sidebar.manage_plan')}</span>
            <ArrowRight className="h-4 w-4" />
          </button>
        </div>
      </div>
    </aside>
  );
};
