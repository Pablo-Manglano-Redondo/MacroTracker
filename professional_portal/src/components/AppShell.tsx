import React, { useEffect, lazy, Suspense, useMemo, useState, useRef } from 'react';
import {
  ChevronRight,
  Home,
  Loader2,
  Menu,
  UserPlus,
  X,
  LogOut,
  Sun,
  Moon,
  Globe,
  User,
  Sparkles,
  Users,
  ShieldCheck,
} from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { Sidebar } from './Sidebar';
import { ProfessionalClient } from '../types/database.types';
import { NotificationBell } from './NotificationBell';
import { InviteModal } from './InviteModal';
import { TourButton } from './TourButton';
import { getBillingSummary, resolveWorkspaceState } from '../view-models/professional';
import { onOpenInviteModal } from '../lib/portal-events';
import { usePortalI18n } from '../lib/portal-i18n';
import { startTour, shouldAutoLaunchTour } from '../lib/tour';
import { buildDemoClient, isDemoClient } from '../lib/demo-client';
import { usePortalNavigation } from '../lib/navigation-context';

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



export const AppShell: React.FC = () => {
  const { session, loading, professional, user, signOut } = useAuth();
  const { t, locale, setLocale, locales } = usePortalI18n();

  const {
    activePanel,
    selectedClient,
    navigateToPanel: setActivePanel,
    selectClient: setSelectedClient,
    selectClientTab,
  } = usePortalNavigation();

  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [showInviteModal, setShowInviteModal] = useState(false);
  const [profileMenuOpen, setProfileMenuOpen] = useState(false);
  const [languageMenuOpen, setLanguageMenuOpen] = useState(false);
  const tourLaunchedRef = useRef(false);
  const [showSlowLoadWarning, setShowSlowLoadWarning] = useState(false);

  useEffect(() => {
    let timer: number | undefined;
    if (loading) {
      timer = window.setTimeout(() => {
        setShowSlowLoadWarning(true);
      }, 5000);
    } else {
      setShowSlowLoadWarning(false);
    }
    return () => {
      if (timer) window.clearTimeout(timer);
    };
  }, [loading]);

  const [theme, setTheme] = useState<'light' | 'dark'>(() => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('theme');
      if (saved === 'light' || saved === 'dark') return saved;
      return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    }
    return 'light';
  });

  useEffect(() => {
    const root = window.document.documentElement;
    if (theme === 'dark') root.classList.add('dark');
    else root.classList.remove('dark');
    localStorage.setItem('theme', theme);
  }, [theme]);

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
  const practiceBlocked = !billingSummary.canOperatePractice;
  const practiceBlockedLabel =
    workspaceState === 'past_due'
      ? t('components.appshell.billing')
      : workspaceState === 'canceled'
        ? t('components.appshell.billing')
        : t('components.appshell.initial_setup');

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
    const detachInviteListener = onOpenInviteModal(() => setShowInviteModal(true));
    return () => {
      detachInviteListener();
    };
  }, []);

  // Auto-launch tour on first login
  useEffect(() => {
    if (loading || !professional || tourLaunchedRef.current) return;
    if (shouldAutoLaunchTour()) {
      tourLaunchedRef.current = true;
      // Small delay to let the portal fully render first
      const timer = setTimeout(() => handleLaunchTour(), 800);
      return () => clearTimeout(timer);
    }
    return undefined;
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [loading, professional]);

  useEffect(() => {
    if (!practiceBlocked) return;

    const blockedPanels = new Set(['templates-panel', 'checkins-panel', 'recipes-panel']);
    if (blockedPanels.has(activePanel)) {
      setActivePanel('billing-panel');
    }
  }, [activePanel, practiceBlocked]);

  const handleSetActivePanel = (panel: any) => {
    setActivePanel(panel);
    setSidebarOpen(false);
  };

  const handleLaunchTour = () => {
    if (!professional) return;
    // If no real clients, inject demo client
    const hasNoClients = !selectedClient;
    const demoClient = buildDemoClient(professional.id, t('components.tour.demo_client_name'));

    startTour(
      {
        nextBtn: t('components.tour.next_btn'),
        prevBtn: t('components.tour.prev_btn'),
        doneBtn: t('components.tour.done_btn'),
        skipBtn: t('components.tour.skip_btn'),
        steps: [
          { title: t('components.tour.step1_title'), desc: t('components.tour.step1_desc') },
          { title: t('components.tour.step2_title'), desc: t('components.tour.step2_desc') },
          { title: t('components.tour.step3_title'), desc: t('components.tour.step3_desc') },
          { title: t('components.tour.step4_title'), desc: t('components.tour.step4_desc') },
          { title: t('components.tour.step5_title'), desc: t('components.tour.step5_desc') },
          { title: t('components.tour.step6_title'), desc: t('components.tour.step6_desc') },
          { title: t('components.tour.step7_title'), desc: t('components.tour.step7_desc') },
          { title: t('components.tour.step8_title'), desc: t('components.tour.step8_desc') },
          { title: t('components.tour.step9_title'), desc: t('components.tour.step9_desc') },
          { title: t('components.tour.step10_title'), desc: t('components.tour.step10_desc') },
          { title: t('components.tour.step11_title'), desc: t('components.tour.step11_desc') },
          { title: t('components.tour.step12_title'), desc: t('components.tour.step12_desc') },
          { title: t('components.tour.step13_title'), desc: t('components.tour.step13_desc') },
          { title: t('components.tour.step14_title'), desc: t('components.tour.step14_desc') },
        ],
      },
      {
        navigateTo: (panel) => handleSetActivePanel(panel as any),
        selectDemoClient: () => {
          if (hasNoClients) {
            setSelectedClient(demoClient);
          } else if (selectedClient && !isDemoClient(selectedClient)) {
            // keep first real client selected
          }
          handleSetActivePanel('clients-panel');
        },
        selectClientTab: (tab) => {
          selectClientTab(tab as any);
        },
        deselectClient: () => {
          if (isDemoClient(selectedClient)) {
            setSelectedClient(null);
          }
        },
      },
    );
  };

  if (loading) {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center gap-4 bg-background animate-fade-in">
        <Loader2 className="h-10 w-10 animate-spin text-primary" />
        <span className="text-lg font-semibold text-foreground animate-pulse">
          {t('components.appshell.loading_professional_portal')}
        </span>
        {showSlowLoadWarning && (
          <div className="mt-4 flex flex-col items-center gap-3 max-w-md text-center px-6 animate-fade-in-up">
            <p className="text-sm text-muted-foreground leading-relaxed">
              {t('components.appshell.slow_load_warning')}
            </p>
            <button
              onClick={() => window.location.reload()}
              className="text-sm font-bold text-primary hover:underline cursor-pointer"
            >
              {t('components.appshell.slow_load_reload_button')}
            </button>
          </div>
        )}
      </div>
    );
  }

  if (!session) {
    return (
      <div className="portal-page min-h-screen px-6 py-8 relative overflow-hidden flex items-center justify-center">
        {/* Glow effects for premium dark mode */}
        <div className="absolute top-1/4 left-10 -z-10 h-[350px] w-[350px] rounded-full bg-emerald-500/[0.04] blur-[120px] pointer-events-none" />
        <div className="absolute bottom-1/4 right-10 -z-10 h-[350px] w-[350px] rounded-full bg-teal-500/[0.04] blur-[120px] pointer-events-none" />

        <div className="relative z-10 mx-auto grid w-full max-w-6xl gap-10 lg:grid-cols-[minmax(0,1.05fr)_minmax(420px,0.85fr)] lg:items-center">
          <section className="portal-hero hidden rounded-[2.5rem] p-12 lg:block border border-white/[0.06] bg-gradient-to-b from-white/[0.03] to-white/[0.01] backdrop-blur-md shadow-2xl">
            {/* Branded Header */}
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-400 to-teal-500 text-black shadow-md shadow-emerald-500/20">
                <Sparkles className="h-5 w-5" />
              </div>
              <span className="font-sans text-2xl font-black tracking-tight text-white bg-gradient-to-r from-emerald-400 to-teal-400 bg-clip-text text-transparent">
                MacroTracker Pro
              </span>
            </div>

            <h1 className="portal-title mt-8 text-4xl font-extrabold leading-tight tracking-tight text-white xl:text-5xl">
              {t('components.appshell.a_restrained_operational_surface_for_nutritionists')}
            </h1>
            <p className="mt-5 text-base font-medium leading-relaxed text-zinc-300">
              {t('components.appshell.manage_real_relationships_plans_check_ins_and_shared_snapshots_without_m')}
            </p>

            <div className="mt-12 grid gap-5 md:grid-cols-3">
              {[
                {
                  title: t('components.appshell.real_relationships'),
                  body: t('components.appshell.only_clients_connected_from_the_mobile_app'),
                  icon: Users,
                },
                {
                  title: t('components.appshell.explicit_privacy'),
                  body: t('components.appshell.aggregate_by_default_detailed_only_by_consent'),
                  icon: ShieldCheck,
                },
                {
                  title: t('components.appshell.daily_work'),
                  body: t('components.appshell.plans_notes_messages_and_operational_follow_up'),
                  icon: Sparkles,
                },
              ].map(({ title, body, icon: Icon }) => (
                <div key={title} className="group relative rounded-2xl border border-white/[0.06] bg-white/[0.02] p-5 backdrop-blur-sm transition-all duration-300 hover:border-emerald-500/30 hover:bg-white/[0.04] hover:shadow-lg hover:shadow-emerald-950/20">
                  <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-400 transition-colors group-hover:bg-emerald-500/20 group-hover:text-emerald-300">
                    <Icon className="h-5 w-5" />
                  </div>
                  <h3 className="font-sans text-sm font-bold text-white tracking-wide">
                    {title}
                  </h3>
                  <p className="mt-2 text-xs font-semibold leading-relaxed text-zinc-400 group-hover:text-zinc-300 transition-colors">
                    {body}
                  </p>
                </div>
              ))}
            </div>
          </section>

          <main className="mx-auto w-full max-w-[480px]">
            {/* Mobile Branded Header */}
            <div className="mb-8 flex flex-col items-center text-center lg:hidden">
              <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-teal-500 text-black shadow-lg shadow-emerald-500/20">
                <Sparkles className="h-6 w-6" />
              </div>
              <h1 className="mt-4 font-sans text-2xl font-black tracking-tight text-white bg-gradient-to-r from-emerald-400 to-teal-400 bg-clip-text text-transparent">
                MacroTracker Pro
              </h1>
              <p className="mt-2 max-w-sm text-sm font-semibold text-zinc-300 text-center">
                {t('components.appshell.a_restrained_operational_surface_for_nutritionists')}
              </p>
            </div>
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
            <h1 className="portal-title mt-3 text-foreground">
              {t('components.appshell.complete_the_professional_profile_first')}
            </h1>
            <p className="portal-body mt-3 max-w-2xl text-muted-foreground">
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
            onClientUpdated={(client: ProfessionalClient) => {
              setSelectedClient(client);
            }}
            onAddClient={() => setShowInviteModal(true)}
          />
        );
    }
  };

  return (
    <div className="h-screen overflow-hidden bg-background">
      {sidebarOpen && (
        <div
          className="fixed inset-0 z-20 bg-black/30 xl:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      <div className="flex h-full">
        <div
          className={`fixed inset-y-0 left-0 z-30 transform transition-transform duration-200 xl:sticky xl:top-0 xl:h-screen xl:translate-x-0 ${
            sidebarOpen ? 'translate-x-0' : '-translate-x-full'
          }`}
        >
          <Sidebar
            onInviteClient={() => setShowInviteModal(true)}
          />
        </div>

        <main className="flex min-w-0 flex-1 flex-col">
          <header className="sticky top-0 z-20 flex h-20 items-center border-b border-border/80 bg-background/92 px-4 backdrop-blur md:px-8 shrink-0">
            <div className="mx-auto flex w-full max-w-[1800px] items-center justify-between gap-3">
              <div className="flex min-w-0 items-center gap-3">
                <button
                  className="flex h-10 w-10 items-center justify-center rounded-xl border border-border bg-card text-foreground shadow-sm xl:hidden"
                  onClick={() => setSidebarOpen(true)}
                  aria-label={t('components.appshell.open_navigation')}
                >
                  {sidebarOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
                </button>

                {/* MacroTracker Logo */}
                <div className="flex items-center gap-2 mr-2 xl:hidden">
                  <div className="portal-card-heading flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-[#72de98] text-[#0b0f11] shadow-inner">
                    M
                  </div>
                  <span className="hidden portal-card-heading text-white sm:block">
                    Macro<span className="text-[#72de98]">Tracker</span>
                  </span>
                </div>

                {/* Google-style breadcrumb */}
                <nav
                  aria-label="breadcrumb"
                  className="hidden items-center gap-0.5 rounded-full border border-border/60 bg-card/60 px-3 py-1.5 backdrop-blur-sm xl:flex"
                >
                  {/* Home */}
                  <button
                    onClick={() => handleSetActivePanel('dashboard-panel')}
                    className="flex items-center justify-center rounded-full p-1 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                    title={panelLabels['dashboard-panel']}
                    aria-label={panelLabels['dashboard-panel']}
                  >
                    <Home className="h-3.5 w-3.5" />
                  </button>

                  {/* Separator */}
                  <ChevronRight className="h-3.5 w-3.5 shrink-0 text-muted-foreground/40" />

                  {/* Business name — middle crumb if exists */}
                  {professional?.business_name && (
                    <>
                      <button
                        onClick={() => handleSetActivePanel('profile-panel')}
                        className="portal-meta rounded-full px-2 py-0.5 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground max-w-[140px] truncate"
                        title={t('components.appshell.open_professional_profile')}
                      >
                        {professional.business_name}
                      </button>
                      <ChevronRight className="h-3.5 w-3.5 shrink-0 text-muted-foreground/40" />
                    </>
                  )}

                  {/* Active panel — last crumb, highlighted */}
                  <span className="portal-meta rounded-full px-2 py-0.5 text-primary">
                    {panelLabels[activePanel as keyof typeof panelLabels] ?? panelLabels['dashboard-panel']}
                  </span>
                </nav>

                {/* Mobile fallback: just the panel name */}
                <span className="truncate portal-card-heading border-l border-border/60 pl-4 xl:hidden">
                  {panelLabels[activePanel as keyof typeof panelLabels] ?? panelLabels['dashboard-panel']}
                </span>
              </div>

              <div className="flex items-center gap-2.5">
                <button
                  id="tour-topbar-invite"
                  onClick={() => setShowInviteModal(true)}
                  disabled={!billingSummary.canOperatePractice}
                  className="inline-flex h-12 items-center gap-2.5 rounded-xl border border-border bg-card px-5 portal-action text-foreground shadow-sm transition-colors hover:bg-accent disabled:cursor-not-allowed disabled:opacity-50"
                >
                  <UserPlus className="h-4.5 w-4.5" />
                  <span className="hidden sm:inline">{t('components.appshell.invite_client')}</span>
                </button>

                {/* Language Dropdown Select */}
                <div className="relative">
                  <button
                    onClick={() => setLanguageMenuOpen((prev) => !prev)}
                    className="flex h-12 items-center gap-2 rounded-xl border border-border bg-card px-4 portal-action text-foreground hover:bg-accent transition-colors shadow-sm"
                    title={t('components.sidebar.language')}
                  >
                    <Globe className="h-4.5 w-4.5 text-muted-foreground" />
                    <span>{locale}</span>
                  </button>

                  {languageMenuOpen && (
                    <>
                      <div
                        className="fixed inset-0 z-35"
                        onClick={() => setLanguageMenuOpen(false)}
                      />
                      <div className="absolute right-0 mt-2.5 z-40 w-64 rounded-2xl border border-border bg-card p-2 shadow-2xl backdrop-blur">
                        <div className="space-y-1">
                          {locales.map((loc) => (
                            <button
                              key={loc.code}
                              onClick={() => {
                                setLocale(loc.code as any);
                                setLanguageMenuOpen(false);
                              }}
                              className={`flex w-full items-center justify-between rounded-xl px-3.5 py-2.5 text-left portal-action transition-colors ${
                                locale === loc.code
                                  ? 'bg-primary/10 text-primary'
                                  : 'text-muted-foreground hover:bg-accent hover:text-foreground'
                              }`}
                            >
                              <span>{loc.nativeName}</span>
                              <span className="portal-label opacity-60">{loc.code}</span>
                            </button>
                          ))}
                        </div>
                      </div>
                    </>
                  )}
                </div>

                {/* Theme Toggle Button */}
                <button
                  onClick={() => setTheme((prev) => (prev === 'light' ? 'dark' : 'light'))}
                  className="flex h-12 w-12 items-center justify-center rounded-xl border border-border bg-card text-foreground hover:bg-accent transition-colors shadow-sm"
                  title={t('components.sidebar.theme')}
                >
                  {theme === 'dark' ? (
                    <Moon className="h-4.5 w-4.5 text-muted-foreground hover:text-foreground" />
                  ) : (
                    <Sun className="h-4.5 w-4.5 text-muted-foreground hover:text-foreground" />
                  )}
                </button>

                <NotificationBell />

                <TourButton onClick={handleLaunchTour} />

                {/* Profile dropdown */}
                <div className="relative">
                  <button
                    onClick={() => setProfileMenuOpen((prev) => !prev)}
                    className="portal-card-heading flex h-12 w-12 items-center justify-center rounded-xl bg-[#72de98] text-[#0b0f11] shadow-md shadow-[#72de98]/10 transition-transform hover:scale-[1.02] overflow-hidden"
                    title={t('components.sidebar.profile_settings')}
                  >
                    {professional?.avatar_url ? (
                      <img
                        src={professional.avatar_url}
                        alt={professional.display_name || ''}
                        className="h-full w-full object-cover"
                      />
                    ) : (
                      <span className="portal-metric">{initials}</span>
                    )}
                  </button>

                  {profileMenuOpen && (
                    <>
                      <div
                        className="fixed inset-0 z-30"
                        onClick={() => setProfileMenuOpen(false)}
                      />
                      <div className="absolute right-0 mt-2.5 z-40 w-64 rounded-2xl border border-[#1e2326] bg-[#131719]/98 p-4 shadow-2xl backdrop-blur">
                        <div className="flex items-center gap-3 border-b border-[#181d20] pb-3 mb-3">
                          <div className="portal-card-heading flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-[#72de98] text-[#0b0f11] overflow-hidden">
                            {professional?.avatar_url ? (
                              <img
                                src={professional.avatar_url}
                                alt={professional.display_name || ''}
                                className="h-full w-full object-cover"
                              />
                            ) : (
                              initials
                            )}
                          </div>
                          <div className="min-w-0">
                            <p className="truncate portal-card-heading text-white">
                              {professional?.display_name || 'Professional'}
                            </p>
                            <p className="portal-meta truncate text-[#8a9499]">
                              {user?.email || ''}
                            </p>
                          </div>
                        </div>

                        <div className="space-y-1">
                          <button
                            onClick={() => {
                              handleSetActivePanel('profile-panel');
                              setProfileMenuOpen(false);
                            }}
                            className="portal-action flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left text-[#8a9499] hover:bg-[#1c2225] hover:text-white transition-colors"
                          >
                            <User className="h-4 w-4" />
                            <span>Ver Perfil</span>
                          </button>
                          <button
                            onClick={() => {
                              signOut();
                              setProfileMenuOpen(false);
                            }}
                            className="portal-action flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left text-rose-400 hover:bg-rose-950/20 hover:text-rose-200 transition-colors"
                          >
                            <LogOut className="h-4 w-4" />
                            <span>{t('components.sidebar.sign_out')}</span>
                          </button>
                        </div>
                      </div>
                    </>
                  )}
                </div>
              </div>
            </div>
          </header>

          <div className="flex-1 min-w-0 overflow-y-auto px-4 py-5 md:px-8 md:py-8">
            <div className="mx-auto max-w-[1800px] space-y-6 animate-fade-in-up">
              {practiceBlocked && (
                <div className="portal-body rounded-2xl border border-amber-500/25 bg-amber-500/10 p-4 text-amber-900 dark:text-amber-100">
                  {t('components.appshell.professional_access_is_currently_the_portal_remains_available_for_profil', { billingsummary_prostatus: billingSummary.proStatus })}{' '}
                  {t('components.appshell.billing')}:
                  {' '}
                  <button
                    onClick={() => handleSetActivePanel('billing-panel')}
                    className="portal-action underline underline-offset-2"
                  >
                    {practiceBlockedLabel}
                  </button>
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
