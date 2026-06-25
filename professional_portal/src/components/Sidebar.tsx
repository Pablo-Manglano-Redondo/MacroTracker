import React, { useMemo } from 'react';
import {
  Calendar,
  ChefHat,
  ChevronRight,
  ClipboardCheck,
  CreditCard,
  LayoutGrid,
  MessageSquare,
  ShieldAlert,
  User,
  Users,
} from 'lucide-react';
import { usePortalI18n } from '../lib/portal-i18n';
import { useAuth } from '../lib/auth-context';
import { useUnreadCounts } from '../hooks/queries/useClients';
import { useNotifications } from '../hooks/queries/useNotifications';
import { usePerClientAdherence } from '../hooks/queries/useAnalytics';

interface SidebarProps {
  activePanel: string;
  setActivePanel: (panel: string) => void;
  onInviteClient?: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ activePanel, setActivePanel }) => {
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();

  const formattedDate = useMemo(() => {
    const d = new Date();
    const weekday = d.toLocaleDateString(locale, { weekday: 'long' });
    const day = d.getDate();
    const month = d.toLocaleDateString(locale, { month: 'long' });

    const capWeekday = weekday.charAt(0).toUpperCase() + weekday.slice(1);
    const capMonth = month.charAt(0).toUpperCase() + month.slice(1);

    if (locale.startsWith('es')) {
      return `${capWeekday} ${day} de ${capMonth}`;
    } else {
      return `${capWeekday}, ${capMonth} ${day}`;
    }
  }, [locale]);

  const { data: unreadCounts = {} } = useUnreadCounts(professional?.id);
  const { data: notifications = [] } = useNotifications(professional?.id);
  const { data: clientAdherence = [] } = usePerClientAdherence(professional?.id);

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

  const getNavItemClass = (panel: string) => {
    const isActive = activePanel === panel;
    return `relative flex w-full items-center gap-3.5 rounded-xl px-3.5 py-2.5 text-left text-sm font-semibold transition-all duration-200 border ${
      isActive
        ? 'bg-emerald-500/10 border-emerald-500/20 dark:bg-[#121c19] dark:border-[#1f372d] text-emerald-600 dark:text-[#72de98] shadow-[0_4px_12px_rgba(16,185,129,0.04)] dark:shadow-[0_4px_12px_rgba(114,222,152,0.04)]'
        : 'border-transparent text-gray-500 dark:text-[#8a9499] hover:bg-gray-100 dark:hover:bg-[#131719]/60 hover:text-gray-900 hover:border-gray-200 dark:hover:text-white dark:hover:border-[#1e2326] group'
    }`;
  };

  return (
    <aside className="flex h-screen w-[292px] shrink-0 flex-col overflow-hidden border-r border-gray-200 dark:border-[#191e21] bg-gradient-to-b from-[#f8f9fa] to-[#f1f3f5] dark:from-[#0b0f11] dark:to-[#080b0c] text-foreground shadow-2xl transition-colors duration-200">
      <div className="flex h-20 shrink-0 items-center border-b border-gray-200 dark:border-[#181d20] bg-white/60 dark:bg-[#0b0f11]/60 backdrop-blur-md px-5 transition-colors duration-200">
        <div className="flex items-center gap-2.5">
          <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-[#72de98] to-[#51b87a] text-[#0b0f11] font-black shadow-[0_4px_12px_rgba(114,222,152,0.25)] transition-transform duration-300 hover:scale-105 cursor-pointer">
            M
          </div>
          <span className="text-lg font-black tracking-tight text-gray-900 dark:text-white select-none transition-colors duration-200">
            Macro<span className="text-[#72de98]">Tracker</span>
          </span>
        </div>
      </div>

      <div className="flex-1 space-y-5 overflow-y-auto p-5 custom-scrollbar">
        {/* Workspace / Operaciones */}
        <div className="space-y-2">
          <h3 className="px-3.5 text-[10px] font-extrabold uppercase tracking-[0.18em] text-gray-400 dark:text-[#8a9499] select-none transition-colors duration-200">
            {t('components.sidebar.operations')}
          </h3>
          <nav className="flex flex-col gap-1">
            <button
              onClick={() => {
                setActivePanel('dashboard-panel');
                window.location.hash = 'dashboard-panel';
              }}
              className={getNavItemClass('dashboard-panel')}
            >
              <LayoutGrid className="h-[18px] w-[18px] shrink-0 transition-transform duration-200 group-hover:scale-110" />
              <span>{t('components.sidebar.overview')}</span>
              {activePanel === 'dashboard-panel' && (
                <span className="absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-r bg-emerald-500 dark:bg-[#72de98] shadow-[0_0_8px_rgba(16,185,129,0.5)] dark:shadow-[0_0_8px_#72de98]" />
              )}
            </button>

            <button
              onClick={() => {
                setActivePanel('clients-panel');
                window.location.hash = 'clients-panel';
              }}
              className={getNavItemClass('clients-panel')}
            >
              <Users className="h-[18px] w-[18px] shrink-0 transition-transform duration-200 group-hover:scale-110" />
              <span>{t('components.sidebar.clients')}</span>
              {activePanel === 'clients-panel' && (
                <span className="absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-r bg-emerald-500 dark:bg-[#72de98] shadow-[0_0_8px_rgba(16,185,129,0.5)] dark:shadow-[0_0_8px_#72de98]" />
              )}
            </button>

            <button
              onClick={() => {
                setActivePanel('checkins-panel');
                window.location.hash = 'checkins-panel';
              }}
              className={getNavItemClass('checkins-panel')}
            >
              <ClipboardCheck className="h-[18px] w-[18px] shrink-0 transition-transform duration-200 group-hover:scale-110" />
              <span>{t('components.sidebar.check_ins')}</span>
              {activePanel === 'checkins-panel' && (
                <span className="absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-r bg-emerald-500 dark:bg-[#72de98] shadow-[0_0_8px_rgba(16,185,129,0.5)] dark:shadow-[0_0_8px_#72de98]" />
              )}
            </button>
          </nav>
        </div>

        <div className="h-px bg-gray-200 dark:bg-[#181d20]/70 transition-colors duration-200" />

        {/* Biblioteca / Recursos */}
        <div className="space-y-2">
          <h3 className="px-3.5 text-[10px] font-extrabold uppercase tracking-[0.18em] text-gray-400 dark:text-[#8a9499] select-none transition-colors duration-200">
            {t('components.sidebar.library')}
          </h3>
          <nav className="flex flex-col gap-1">
            <button
              onClick={() => {
                setActivePanel('recipes-panel');
                window.location.hash = 'recipes-panel';
              }}
              className={getNavItemClass('recipes-panel')}
            >
              <ChefHat className="h-[18px] w-[18px] shrink-0 transition-transform duration-200 group-hover:scale-110" />
              <span>{t('components.sidebar.recipes')}</span>
              {activePanel === 'recipes-panel' && (
                <span className="absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-r bg-emerald-500 dark:bg-[#72de98] shadow-[0_0_8px_rgba(16,185,129,0.5)] dark:shadow-[0_0_8px_#72de98]" />
              )}
            </button>

            <button
              onClick={() => {
                setActivePanel('templates-panel');
                window.location.hash = 'templates-panel';
              }}
              className={getNavItemClass('templates-panel')}
            >
              <ClipboardCheck className="h-[18px] w-[18px] shrink-0 transition-transform duration-200 group-hover:scale-110" />
              <span>{t('components.sidebar.templates')}</span>
              {activePanel === 'templates-panel' && (
                <span className="absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-r bg-emerald-500 dark:bg-[#72de98] shadow-[0_0_8px_rgba(16,185,129,0.5)] dark:shadow-[0_0_8px_#72de98]" />
              )}
            </button>
          </nav>
        </div>

        <div className="h-px bg-gray-200 dark:bg-[#181d20]/70 transition-colors duration-200" />

        {/* Gestión / Cuenta */}
        <div className="space-y-2">
          <h3 className="px-3.5 text-[10px] font-extrabold uppercase tracking-[0.18em] text-gray-400 dark:text-[#8a9499] select-none transition-colors duration-200">
            {t('components.sidebar.management')}
          </h3>
          <nav className="flex flex-col gap-1">
            <button
              onClick={() => {
                setActivePanel('profile-panel');
                window.location.hash = 'profile-panel';
              }}
              className={getNavItemClass('profile-panel')}
            >
              <User className="h-[18px] w-[18px] shrink-0 transition-transform duration-200 group-hover:scale-110" />
              <span>{t('components.sidebar.profile')}</span>
              {activePanel === 'profile-panel' && (
                <span className="absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-r bg-emerald-500 dark:bg-[#72de98] shadow-[0_0_8px_rgba(16,185,129,0.5)] dark:shadow-[0_0_8px_#72de98]" />
              )}
            </button>

            <button
              onClick={() => {
                setActivePanel('billing-panel');
                window.location.hash = 'billing-panel';
              }}
              className={getNavItemClass('billing-panel')}
            >
              <CreditCard className="h-[18px] w-[18px] shrink-0 transition-transform duration-200 group-hover:scale-110" />
              <span>{t('components.sidebar.billing')}</span>
              {activePanel === 'billing-panel' && (
                <span className="absolute bottom-2.5 left-0 top-2.5 w-[3px] rounded-r bg-emerald-500 dark:bg-[#72de98] shadow-[0_0_8px_rgba(16,185,129,0.5)] dark:shadow-[0_0_8px_#72de98]" />
              )}
            </button>
          </nav>
        </div>
      </div>

      <div className="space-y-4 px-5 pb-5 shrink-0">
        <div className="mb-2 h-px bg-gray-200 dark:bg-[#181d20]/70 transition-colors duration-200" />

        {/* Today's Triage Control Center */}
        <div className="rounded-2xl border border-gray-200 dark:border-[#1e2326] bg-white/40 dark:bg-[#131719]/40 p-4 shadow-sm backdrop-blur-md transition-colors duration-200">
          <div className="flex items-center gap-2 text-[10px] font-extrabold uppercase tracking-[0.18em] text-gray-500 dark:text-[#8a9499] select-none transition-colors duration-200">
            <Calendar className="h-4 w-4" />
            <span>{formattedDate}</span>
          </div>

          <div className="mt-4 space-y-2">
            <button
              onClick={() => {
                setActivePanel('checkins-panel');
                window.location.hash = 'checkins-panel';
              }}
              className="flex w-full items-center justify-between text-left rounded-xl p-2 -mx-2 transition-all duration-200 hover:bg-gray-100 dark:hover:bg-[#1e2326]/30 group cursor-pointer"
            >
              <div className="flex items-center gap-3">
                <div className="flex h-8 w-8 items-center justify-center rounded-xl border border-emerald-200 dark:border-[#1b3027] bg-emerald-50 dark:bg-[#121c18] text-emerald-600 dark:text-[#72de98] transition-transform duration-200 group-hover:scale-105 transition-colors">
                  <ClipboardCheck className="h-4.5 w-4.5" />
                </div>
                <span className="text-xs font-semibold leading-none text-gray-700 dark:text-[#e1e3e5] group-hover:text-gray-900 dark:group-hover:text-white transition-colors">
                  {pendingCheckinsCount === 1
                    ? t('components.sidebar.pending_checkins_count_one', {
                        count: pendingCheckinsCount,
                      })
                    : t('components.sidebar.pending_checkins_count', {
                        count: pendingCheckinsCount,
                      })}
                </span>
              </div>
              <ChevronRight className="h-4 w-4 text-gray-400 dark:text-[#5c686d] transition-transform duration-200 group-hover:translate-x-0.5 group-hover:text-emerald-500 dark:group-hover:text-[#72de98]" />
            </button>

            <button
              onClick={() => {
                setActivePanel('clients-panel');
                window.location.hash = 'clients-panel';
              }}
              className="flex w-full items-center justify-between text-left rounded-xl p-2 -mx-2 transition-all duration-200 hover:bg-gray-100 dark:hover:bg-[#1e2326]/30 group cursor-pointer"
            >
              <div className="flex items-center gap-3">
                <div className="flex h-8 w-8 items-center justify-center rounded-xl border border-sky-200 dark:border-[#1a2d33] bg-sky-50 dark:bg-[#131b1e] text-sky-600 dark:text-[#38bdf8] transition-transform duration-200 group-hover:scale-105 transition-colors">
                  <MessageSquare className="h-4.5 w-4.5" />
                </div>
                <span className="text-xs font-semibold leading-none text-gray-700 dark:text-[#e1e3e5] group-hover:text-gray-900 dark:group-hover:text-white transition-colors">
                  {totalUnreadMessages === 1
                    ? t('components.sidebar.unread_messages_count_one', {
                        count: totalUnreadMessages,
                      })
                    : t('components.sidebar.unread_messages_count', {
                        count: totalUnreadMessages,
                      })}
                </span>
              </div>
              <ChevronRight className="h-4 w-4 text-gray-400 dark:text-[#5c686d] transition-transform duration-200 group-hover:translate-x-0.5 group-hover:text-sky-500 dark:group-hover:text-[#38bdf8]" />
            </button>

            <button
              onClick={() => {
                setActivePanel('clients-panel');
                window.location.hash = 'clients-panel';
              }}
              className="flex w-full items-center justify-between text-left rounded-xl p-2 -mx-2 transition-all duration-200 hover:bg-gray-100 dark:hover:bg-[#1e2326]/30 group cursor-pointer"
            >
              <div className="flex items-center gap-3">
                <div className="flex h-8 w-8 items-center justify-center rounded-xl border border-amber-200 dark:border-[#33251a] bg-amber-50 dark:bg-[#1d1713] text-amber-600 dark:text-[#f59e0b] transition-transform duration-200 group-hover:scale-105 transition-colors">
                  <ShieldAlert className="h-4.5 w-4.5" />
                </div>
                <span className="text-xs font-semibold leading-none text-gray-700 dark:text-[#e1e3e5] group-hover:text-gray-900 dark:group-hover:text-white transition-colors">
                  {clientsInRiskCount === 1
                    ? t('components.sidebar.low_adherence_clients_count_one', {
                        count: clientsInRiskCount,
                      })
                    : t('components.sidebar.low_adherence_clients_count', {
                        count: clientsInRiskCount,
                      })}
                </span>
              </div>
              <ChevronRight className="h-4 w-4 text-gray-400 dark:text-[#5c686d] transition-transform duration-200 group-hover:translate-x-0.5 group-hover:text-amber-500 dark:group-hover:text-[#f59e0b]" />
            </button>
          </div>
        </div>
      </div>
    </aside>
  );
};
