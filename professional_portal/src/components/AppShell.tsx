import React, { useEffect, lazy, Suspense, useMemo, useState } from 'react';
import {
  Briefcase,
  ChevronRight,
  FileText,
  Loader2,
  Menu,
  UserPlus,
  X,
} from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { Sidebar } from './Sidebar';
import { supabase } from '../lib/supabase';
import { ProfessionalClient } from '../types/database.types';
import { NotificationBell } from './NotificationBell';
import { InviteModal } from './InviteModal';
import { getBillingSummary, resolveWorkspaceState } from '../view-models/professional';
import { onOpenInviteModal } from '../lib/portal-events';
import { usePortalI18n } from '../lib/portal-i18n';

const AuthPanel = lazy(() => import('./AuthPanel').then((m) => ({ default: m.AuthPanel })));
const ProfilePanel = lazy(() => import('./ProfilePanel').then((m) => ({ default: m.ProfilePanel })));
const BillingPanel = lazy(() => import('./BillingPanel').then((m) => ({ default: m.BillingPanel })));
const ClientsPanel = lazy(() => import('./ClientsPanel').then((m) => ({ default: m.ClientsPanel })));
const DashboardPanel = lazy(() => import('./DashboardPanel').then((m) => ({ default: m.DashboardPanel })));
const RecipeLibraryPanel = lazy(() => import('./RecipeLibraryPanel').then((m) => ({ default: m.RecipeLibraryPanel })));
const PlanTemplatesPanel = lazy(() => import('./PlanTemplatesPanel').then((m) => ({ default: m.PlanTemplatesPanel })));
const CheckinTemplatesPanel = lazy(() => import('./CheckinTemplatesPanel').then((m) => ({ default: m.CheckinTemplatesPanel })));

const PanelFallback = () => (
  <div className="flex items-center justify-center py-16">
    <Loader2 className="h-6 w-6 animate-spin text-primary" />
  </div>
);

const PANEL_IDS = [
  'profile-panel',
  'billing-panel',
  'clients-panel',
  'dashboard-panel',
  'recipes-panel',
  'templates-panel',
  'checkins-panel',
] as const;

export const AppShell: React.FC = () => {
  const { session, loading, professional } = useAuth();
  const { t } = usePortalI18n();
  const [activePanel, setActivePanel] = useState('dashboard-panel');
  const [selectedClient, setSelectedClient] = useState<ProfessionalClient | null>(null);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [showInviteModal, setShowInviteModal] = useState(false);

  const initials = professional?.display_name
    ? professional.display_name
        .split(' ')
        .map((n: string) => n[0])
        .join('')
        .slice(0, 2)
        .toUpperCase()
    : professional?.business_name
      ? professional.business_name.slice(0, 2).toUpperCase()
      : 'MT';

  const workspaceState = resolveWorkspaceState(professional);
  const billingSummary = getBillingSummary(professional);

  const panelLabels = useMemo(
    () => ({
      'dashboard-panel': t('components.appshell.overview'),
      'clients-panel': t('components.appshell.clients'),
      'templates-panel': t('components.appshell.templates'),
      'recipes-panel': t('components.appshell.recipes'),
      'checkins-panel': t('components.appshell.check_ins'),
      'profile-panel': t('components.appshell.professional_profile'),
      'billing-panel': t('components.appshell.billing'),
    }),
    [t],
  );

  useEffect(() => {
    const handleHashChange = () => {
      const hash = window.location.hash.replace('#', '');
      if (hash && PANEL_IDS.includes(hash as (typeof PANEL_IDS)[number])) {
        setActivePanel(hash);
      }
    };

    const handleSelectClient = (e: Event) => {
      const clientId = (e as CustomEvent).detail;
      if (professional) {
        supabase
          .from('professional_clients')
          .select('*')
          .eq('professional_id', professional.id)
          .eq('client_id', clientId)
          .single()
          .then(({ data }) => {
            if (data) {
              setSelectedClient(data as unknown as ProfessionalClient);
            }
          });
      }
    };

    window.addEventListener('hashchange', handleHashChange);
    window.addEventListener('select-client', handleSelectClient);
    const detachInviteListener = onOpenInviteModal(() => setShowInviteModal(true));
    handleHashChange();

    return () => {
      window.removeEventListener('hashchange', handleHashChange);
      window.removeEventListener('select-client', handleSelectClient);
      detachInviteListener();
    };
  }, [professional]);

  const handleSetActivePanel = (panel: string) => {
    setActivePanel(panel);
    window.location.hash = panel;
    setSidebarOpen(false);
  };

  if (loading) {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center gap-3 bg-background">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
        <span className="text-sm font-semibold text-muted-foreground">
          {t('components.appshell.loading_professional_portal')}
        </span>
      </div>
    );
  }

  if (!session) {
    return (
      <div className="portal-page min-h-screen px-6 py-8">
        <div className="mx-auto grid min-h-[calc(100vh-4rem)] max-w-6xl gap-8 lg:grid-cols-[minmax(0,0.92fr)_minmax(420px,0.78fr)] lg:items-center">
          <section className="portal-hero hidden rounded-[2rem] p-10 lg:block">
            <p className="portal-kicker">{t('components.appshell.professional_portal')}</p>
            <h1 className="portal-title mt-4 max-w-xl text-4xl text-foreground">
              {t('components.appshell.a_restrained_operational_surface_for_nutritionists')}
            </h1>
            <p className="mt-4 max-w-xl text-base font-medium leading-relaxed text-muted-foreground">
              {t('components.appshell.manage_real_relationships_plans_check_ins_and_shared_snapshots_without_m')}
            </p>

            <div className="mt-10 grid gap-4 md:grid-cols-3">
              {[
                [
                  t('components.appshell.real_relationships'),
                  t('components.appshell.only_clients_connected_from_the_mobile_app'),
                ],
                [
                  t('components.appshell.explicit_privacy'),
                  t('components.appshell.aggregate_by_default_detailed_only_by_consent'),
                ],
                [
                  t('components.appshell.daily_work'),
                  t('components.appshell.plans_notes_messages_and_operational_follow_up'),
                ],
              ].map(([title, body]) => (
                <div key={title} className="portal-soft-panel rounded-2xl p-4">
                  <p className="text-sm font-bold text-foreground">{title}</p>
                  <p className="mt-2 text-sm leading-relaxed text-muted-foreground">{body}</p>
                </div>
              ))}
            </div>
          </section>

          <main className="mx-auto w-full max-w-[480px]">
            <Suspense fallback={<PanelFallback />}>
              <AuthPanel />
            </Suspense>
          </main>
        </div>
      </div>
    );
  }

  if (workspaceState === 'needs_profile') {
    return (
      <div className="portal-page min-h-screen px-6 py-10">
        <div className="mx-auto max-w-6xl space-y-6">
          <section className="portal-hero rounded-[2rem] p-6 md:p-8">
            <p className="portal-kicker">{t('components.appshell.initial_setup')}</p>
            <h1 className="portal-title mt-3 text-2xl text-foreground">
              {t('components.appshell.complete_the_professional_profile_first')}
            </h1>
            <p className="mt-3 max-w-2xl text-sm font-medium leading-relaxed text-muted-foreground">
              {t('components.appshell.the_authenticated_user_exists_but_there_is_still_no_row_in_professionals')}
            </p>
          </section>
          <Suspense fallback={<PanelFallback />}>
            <ProfilePanel />
          </Suspense>
        </div>
      </div>
    );
  }

  const renderActivePanel = () => {
    switch (activePanel) {
      case 'dashboard-panel':
        return <DashboardPanel />;
      case 'profile-panel':
        return <ProfilePanel />;
      case 'billing-panel':
        return <BillingPanel />;
      case 'recipes-panel':
        return <RecipeLibraryPanel />;
      case 'templates-panel':
        return <PlanTemplatesPanel />;
      case 'checkins-panel':
        return <CheckinTemplatesPanel />;
      case 'clients-panel':
      default:
        return (
          <ClientsPanel
            selectedClient={selectedClient}
            onSelectClient={(client: ProfessionalClient | null) => {
              setSelectedClient(client);
              if (client && window.innerWidth < 1280) {
                setTimeout(() => {
                  document
                    .getElementById('client-detail-section')
                    ?.scrollIntoView({ behavior: 'smooth' });
                }, 100);
              }
            }}
            onAddClient={() => setShowInviteModal(true)}
          />
        );
    }
  };

  return (
    <div className="min-h-screen bg-background">
      {sidebarOpen && (
        <div
          className="fixed inset-0 z-20 bg-black/30 xl:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      <div className="flex min-h-screen">
        <div
          className={`fixed inset-y-0 left-0 z-30 transform transition-transform duration-200 xl:static xl:translate-x-0 ${
            sidebarOpen ? 'translate-x-0' : '-translate-x-full'
          }`}
        >
          <Sidebar
            activePanel={activePanel}
            setActivePanel={handleSetActivePanel}
            onInviteClient={() => setShowInviteModal(true)}
          />
        </div>

        <main className="flex min-w-0 flex-1 flex-col">
          <header className="sticky top-0 z-20 border-b border-border/80 bg-background/92 px-4 py-3 backdrop-blur md:px-8">
            <div className="mx-auto flex max-w-[1800px] items-center justify-between gap-3">
              <div className="flex min-w-0 items-center gap-3">
                <button
                  className="flex h-10 w-10 items-center justify-center rounded-xl border border-border bg-card text-foreground shadow-sm xl:hidden"
                  onClick={() => setSidebarOpen(true)}
                  aria-label={t('components.appshell.open_navigation')}
                >
                  {sidebarOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
                </button>

                <button
                  onClick={() => handleSetActivePanel('profile-panel')}
                  className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary text-primary-foreground shadow-sm xl:hidden"
                  title={t('components.appshell.open_professional_profile')}
                >
                  <span className="portal-metric text-xs font-extrabold">{initials}</span>
                </button>

                <div className="min-w-0">
                  <div className="flex items-center gap-2 overflow-hidden">
                    <span className="portal-kicker hidden sm:inline">{t('components.appshell.practice')}</span>
                    <ChevronRight className="hidden h-3.5 w-3.5 text-muted-foreground sm:inline" />
                    <span className="truncate text-sm font-bold text-foreground">
                      {panelLabels[activePanel as keyof typeof panelLabels] ?? panelLabels['dashboard-panel']}
                    </span>
                    {professional?.business_name && (
                      <>
                        <ChevronRight className="hidden h-3.5 w-3.5 text-muted-foreground md:inline" />
                        <button
                          onClick={() => handleSetActivePanel('profile-panel')}
                          className="hidden items-center gap-1 text-sm font-medium text-muted-foreground transition-colors hover:text-foreground md:flex"
                          title={t('components.appshell.open_professional_profile')}
                        >
                          <Briefcase className="h-3.5 w-3.5" />
                          <span className="truncate">{professional.business_name}</span>
                        </button>
                      </>
                    )}
                  </div>
                </div>
              </div>

              <div className="flex items-center gap-2">
                <button
                  onClick={() => setShowInviteModal(true)}
                  disabled={!billingSummary.hasProfessionalAccess}
                  className="inline-flex items-center gap-2 rounded-xl border border-border bg-card px-3 py-2 text-xs font-bold text-foreground shadow-sm transition-colors hover:bg-accent disabled:cursor-not-allowed disabled:opacity-50"
                >
                  <UserPlus className="h-3.5 w-3.5" />
                  <span className="hidden sm:inline">{t('components.appshell.invite_client')}</span>
                </button>
                <button
                  onClick={() => handleSetActivePanel('templates-panel')}
                  className="inline-flex items-center gap-2 rounded-xl bg-primary px-3 py-2 text-xs font-bold text-primary-foreground shadow-sm transition-colors hover:opacity-95"
                >
                  <FileText className="h-3.5 w-3.5" />
                  <span className="hidden sm:inline">{t('components.appshell.new_template')}</span>
                </button>
                <div className="flex h-10 w-10 items-center justify-center rounded-xl border border-border bg-card shadow-sm">
                  <NotificationBell />
                </div>
              </div>
            </div>
          </header>

          <div className="flex-1 overflow-y-auto px-4 py-5 md:px-8 md:py-8">
            <div className="mx-auto max-w-[1800px] space-y-6 animate-fade-in-up">
              {workspaceState === 'inactive_subscription' && (
                <div className="rounded-2xl border border-amber-500/25 bg-amber-500/10 p-4 text-sm font-medium leading-relaxed text-amber-900 dark:text-amber-100">
                  {t('components.appshell.professional_access_is_currently_the_portal_remains_available_for_profil', { billingsummary_prostatus: billingSummary.proStatus })}
                </div>
              )}
              <Suspense fallback={<PanelFallback />}>{renderActivePanel()}</Suspense>
            </div>
          </div>
        </main>
      </div>

      {showInviteModal && <InviteModal onClose={() => setShowInviteModal(false)} />}
    </div>
  );
};
