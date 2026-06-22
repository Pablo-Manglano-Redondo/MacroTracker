import React, { useEffect, useState } from 'react';
import {
  ArrowRight,
  ChefHat,
  ClipboardCheck,
  CreditCard,
  Languages,
  LayoutDashboard,
  Layers,
  LogOut,
  Moon,
  SlidersHorizontal,
  Sun,
  User,
  Users,
} from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { supabase } from '../lib/supabase';
import { getBillingSummary } from '../view-models/professional';
import { PortalLocale, usePortalI18n } from '../lib/portal-i18n';

interface SidebarProps {
  activePanel: string;
  setActivePanel: (panel: string) => void;
  onInviteClient?: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({
  activePanel,
  setActivePanel,
  onInviteClient,
}) => {
  const { professional, signOut } = useAuth();
  const { locale, setLocale, t } = usePortalI18n();
  const billingSummary = getBillingSummary(professional);
  const billingIntervalLabel =
    billingSummary.billingInterval === 'annual'
      ? t('components.sidebar.annual')
      : t('components.sidebar.monthly');
  const statusLabelMap: Record<string, string> = {
    inactive: t('components.sidebar.inactive'),
    trialing: t('components.sidebar.trial_active'),
    active: t('components.sidebar.active'),
    past_due: t('components.sidebar.past_due'),
    canceled: t('components.sidebar.canceled'),
  };
  const proStatusLabel = statusLabelMap[billingSummary.proStatus] ?? billingSummary.proStatus;

  const [theme, setTheme] = useState<'light' | 'dark'>(() => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('theme');
      if (saved === 'light' || saved === 'dark') {
        return saved;
      }
      return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    }
    return 'light';
  });

  const [completedSteps, setCompletedSteps] = useState({
    profile: false,
    preferences: false,
    templates: false,
    clients: false,
  });

  useEffect(() => {
    if (!professional) {
      setCompletedSteps({
        profile: false,
        preferences: false,
        templates: false,
        clients: false,
      });
      return;
    }

    const checkSetup = async () => {
      const profileDone = !!professional.display_name;
      const prefDone = !!professional.business_name;

      const { count: templateCount } = await supabase
        .from('plan_templates')
        .select('*', { count: 'exact', head: true })
        .eq('professional_id', professional.id);

      const { count: clientCount } = await supabase
        .from('professional_clients')
        .select('*', { count: 'exact', head: true })
        .eq('professional_id', professional.id);

      setCompletedSteps({
        profile: profileDone,
        preferences: prefDone,
        templates: (templateCount ?? 0) > 0,
        clients: (clientCount ?? 0) > 0,
      });
    };

    checkSetup();
  }, [professional, activePanel]);

  const stepsCount = Object.values(completedSteps).filter(Boolean).length;
  const isSetupComplete = stepsCount === 4;

  useEffect(() => {
    const root = window.document.documentElement;
    if (theme === 'dark') {
      root.classList.add('dark');
    } else {
      root.classList.remove('dark');
    }
    localStorage.setItem('theme', theme);
  }, [theme]);

  const handleContinueSetup = () => {
    if (!completedSteps.profile || !completedSteps.preferences) {
      setActivePanel('profile-panel');
      window.location.hash = 'profile-panel';
      return;
    }

    if (!completedSteps.templates) {
      setActivePanel('templates-panel');
      window.location.hash = 'templates-panel';
      return;
    }

    if (!completedSteps.clients) {
      onInviteClient?.();
      return;
    }

    setActivePanel('dashboard-panel');
    window.location.hash = 'dashboard-panel';
  };

  const navigationGroups = [
    {
      title: t('components.sidebar.operations'),
      items: [
        { id: 'dashboard-panel', label: t('components.sidebar.overview'), icon: LayoutDashboard },
        { id: 'clients-panel', label: t('components.sidebar.clients'), icon: Users },
        { id: 'checkins-panel', label: t('components.sidebar.check_ins'), icon: ClipboardCheck },
      ],
    },
    {
      title: t('components.sidebar.library'),
      items: [
        { id: 'templates-panel', label: t('components.sidebar.templates'), icon: Layers },
        { id: 'recipes-panel', label: t('components.sidebar.recipes'), icon: ChefHat },
      ],
    },
    {
      title: t('components.sidebar.management'),
      items: [
        { id: 'profile-panel', label: t('components.sidebar.profile'), icon: User },
        { id: 'billing-panel', label: t('components.sidebar.billing'), icon: CreditCard },
      ],
    },
  ];

  const localeOptions: PortalLocale[] = ['es', 'en'];

  return (
    <aside className="flex h-screen w-[292px] shrink-0 flex-col justify-between border-r border-sidebar-border bg-sidebar-bg text-sidebar-foreground shadow-2xl">
      <div className="space-y-6 p-5">
        <button
          onClick={() => {
            setActivePanel('profile-panel');
            window.location.hash = 'profile-panel';
          }}
          className="portal-sidebar-card flex w-full items-center gap-3 rounded-2xl p-3 text-left transition-colors hover:bg-sidebar-accent-hover"
        >
          <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-primary text-primary-foreground shadow-sm">
            <span className="portal-metric text-sm font-extrabold">
              {professional?.business_name?.slice(0, 2).toUpperCase() || 'MT'}
            </span>
          </div>
          <div className="min-w-0 flex-1">
            <p className="text-[10px] font-extrabold uppercase tracking-[0.18em] text-sidebar-muted">
              MacroTracker {t('components.sidebar.portal')}
            </p>
            <p className="mt-1 truncate text-sm font-bold text-sidebar-foreground">
              {professional?.business_name || t('components.sidebar.independent_practice')}
            </p>
          </div>
          <SlidersHorizontal className="h-4 w-4 text-sidebar-muted" />
        </button>

        <div className="space-y-5">
          {navigationGroups.map((group) => (
            <div key={group.title} className="space-y-2">
              <h3 className="px-3 text-[10px] font-extrabold uppercase tracking-[0.18em] text-sidebar-muted">
                {group.title}
              </h3>
              <nav className="flex flex-col gap-1" aria-label={group.title}>
                {group.items.map((item) => {
                  const Icon = item.icon;
                  const isActive = activePanel === item.id;

                  return (
                    <button
                      key={item.id}
                      onClick={() => {
                        setActivePanel(item.id);
                        window.location.hash = item.id;
                      }}
                      aria-current={isActive ? 'page' : undefined}
                      className={`relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left text-sm font-medium transition-colors ${
                        isActive
                          ? 'bg-sidebar-accent text-sidebar-foreground'
                          : 'text-sidebar-muted hover:bg-sidebar-accent hover:text-sidebar-foreground'
                      }`}
                    >
                      <Icon className="h-4 w-4 shrink-0" />
                      <span>{item.label}</span>
                      {isActive && (
                        <span className="absolute left-0 top-1/2 h-4 w-1 -translate-y-1/2 rounded-r bg-primary" />
                      )}
                    </button>
                  );
                })}
              </nav>
            </div>
          ))}
        </div>
      </div>

      <div className="space-y-4 border-t border-sidebar-border px-5 py-5">
        <div className="portal-sidebar-card rounded-2xl p-4">
          <div className="flex items-start justify-between gap-3">
            <div>
              <p className="text-[10px] font-extrabold uppercase tracking-[0.18em] text-sidebar-muted">
                {t('components.sidebar.current_plan')}
              </p>
              <h4 className="mt-2 text-sm font-bold text-sidebar-foreground">
                {billingSummary.tierLabel} · {billingIntervalLabel}
              </h4>
              <p className="mt-1 text-[11px] font-semibold text-sidebar-muted">
                {proStatusLabel}
              </p>
            </div>
            <span
              className={`mt-1 h-2.5 w-2.5 rounded-full ${
                isSetupComplete ? 'bg-emerald-400' : 'bg-amber-400'
              }`}
            />
          </div>

          <div className="mt-4 space-y-2">
            <div className="flex items-center justify-between text-[10px] font-extrabold uppercase tracking-[0.16em] text-sidebar-muted">
              <span>{t('components.sidebar.setup_progress')}</span>
              <span>
                {stepsCount}/4
              </span>
            </div>
            <div className="h-2 rounded-full bg-black/20">
              <div
                className="h-full rounded-full bg-primary transition-all duration-500"
                style={{ width: `${(stepsCount / 4) * 100}%` }}
              />
            </div>
          </div>

          <button
            onClick={handleContinueSetup}
            className="mt-4 flex w-full items-center justify-between rounded-xl border border-sidebar-border bg-sidebar-accent px-3.5 py-2.5 text-sm font-semibold text-sidebar-foreground transition-colors hover:bg-sidebar-accent-hover"
          >
            <span>
              {isSetupComplete
                ? t('components.sidebar.workspace_ready')
                : t('components.sidebar.continue_setup')}
            </span>
            <ArrowRight className="h-4 w-4" />
          </button>

          {onInviteClient && (
            <button
              onClick={onInviteClient}
              disabled={!billingSummary.hasProfessionalAccess}
              className="mt-2 w-full rounded-xl border border-sidebar-border px-3.5 py-2.5 text-sm font-semibold text-sidebar-foreground transition-colors hover:bg-sidebar-accent disabled:cursor-not-allowed disabled:opacity-50"
            >
              {t('components.sidebar.invite_client')}
            </button>
          )}
        </div>

        <div className="portal-sidebar-card rounded-2xl p-3">
          <div className="flex items-center justify-between gap-2">
            <div className="flex items-center gap-2 text-sm font-semibold text-sidebar-foreground">
              <Languages className="h-4 w-4 text-sidebar-muted" />
              <span>{t('components.sidebar.language')}</span>
            </div>
            <div className="flex rounded-xl border border-sidebar-border bg-black/10 p-1">
              {localeOptions.map((option) => (
                <button
                  key={option}
                  onClick={() => setLocale(option)}
                  className={`rounded-lg px-2.5 py-1 text-xs font-bold uppercase transition-colors ${
                    locale === option
                      ? 'bg-primary text-primary-foreground'
                      : 'text-sidebar-muted hover:text-sidebar-foreground'
                  }`}
                >
                  {option}
                </button>
              ))}
            </div>
          </div>

          <div className="mt-3 flex items-center justify-between rounded-xl border border-sidebar-border bg-black/10 px-3 py-2">
            <span className="text-sm font-semibold text-sidebar-foreground">
              {theme === 'dark' ? t('components.sidebar.dark_mode') : t('components.sidebar.light_mode')}
            </span>
            <button
              onClick={() => setTheme((prev) => (prev === 'light' ? 'dark' : 'light'))}
              aria-label={t('components.sidebar.toggle_theme')}
              className="rounded-lg p-1.5 text-sidebar-muted transition-colors hover:bg-sidebar-accent hover:text-sidebar-foreground"
            >
              {theme === 'light' ? <Moon className="h-4 w-4" /> : <Sun className="h-4 w-4" />}
            </button>
          </div>
        </div>

        <button
          onClick={signOut}
          className="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold text-sidebar-muted transition-colors hover:bg-rose-500/10 hover:text-rose-300"
        >
          <LogOut className="h-4 w-4 shrink-0" />
          <span>{t('components.sidebar.sign_out')}</span>
        </button>
      </div>
    </aside>
  );
};
