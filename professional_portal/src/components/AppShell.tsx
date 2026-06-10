import React, { useState, useEffect, lazy, Suspense } from 'react';
import { useAuth } from '../lib/auth-context';
import { Sidebar } from './Sidebar';
import { ProfessionalClient } from '../types/database.types';
import { supabase } from '../lib/supabase';
import { Loader2, Sparkles, Briefcase, ChevronRight, Menu, X } from 'lucide-react';
import { NotificationBell } from './NotificationBell';

const AuthPanel = lazy(() => import('./AuthPanel').then(m => ({ default: m.AuthPanel })));
const ProfilePanel = lazy(() => import('./ProfilePanel').then(m => ({ default: m.ProfilePanel })));
const BillingPanel = lazy(() => import('./BillingPanel').then(m => ({ default: m.BillingPanel })));
const InvitePanel = lazy(() => import('./InvitePanel').then(m => ({ default: m.InvitePanel })));
const ClientsPanel = lazy(() => import('./ClientsPanel').then(m => ({ default: m.ClientsPanel })));
const ClientDetail = lazy(() => import('./ClientDetail').then(m => ({ default: m.ClientDetail })));
const OnboardingWizard = lazy(() => import('./OnboardingWizard').then(m => ({ default: m.OnboardingWizard })));
const DashboardPanel = lazy(() => import('./DashboardPanel').then(m => ({ default: m.DashboardPanel })));
const RecipeLibraryPanel = lazy(() => import('./RecipeLibraryPanel').then(m => ({ default: m.RecipeLibraryPanel })));
const PlanTemplatesPanel = lazy(() => import('./PlanTemplatesPanel').then(m => ({ default: m.PlanTemplatesPanel })));
const CheckinTemplatesPanel = lazy(() => import('./CheckinTemplatesPanel').then(m => ({ default: m.CheckinTemplatesPanel })));

const PanelFallback = () => (
  <div className="flex items-center justify-center py-16">
    <Loader2 className="w-6 h-6 animate-spin text-primary" />
  </div>
);

export const AppShell: React.FC = () => {
  const { session, loading, professional } = useAuth();
  const [activePanel, setActivePanel] = useState('dashboard-panel');
  const [selectedClient, setSelectedClient] = useState<ProfessionalClient | null>(null);
  const [showOnboarding, setShowOnboarding] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(false);

  useEffect(() => {
    const handleHashChange = () => {
      const hash = window.location.hash.replace('#', '');
      if (hash && ['profile-panel', 'billing-panel', 'invite-panel', 'clients-panel', 'dashboard-panel', 'recipes-panel', 'templates-panel', 'checkins-panel'].includes(hash)) {
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
            if (data) setSelectedClient(data as unknown as ProfessionalClient);
          });
      }
    };

    window.addEventListener('hashchange', handleHashChange);
    window.addEventListener('select-client', handleSelectClient);
    handleHashChange();

    return () => {
      window.removeEventListener('hashchange', handleHashChange);
      window.removeEventListener('select-client', handleSelectClient);
    };
  }, [professional]);

  const handleOnboardingDone = async (clientId: string) => {
    if (professional) {
      const { data } = await supabase
        .from('professional_clients')
        .select('*')
        .eq('professional_id', professional.id)
        .eq('client_id', clientId)
        .single();

      if (data) {
        setSelectedClient(data as unknown as ProfessionalClient);
      }
    }
    setShowOnboarding(false);
    setActivePanel('clients-panel');
  };

  const handleSetActivePanel = (panel: string) => {
    setActivePanel(panel);
    window.location.hash = panel;
    setSidebarOpen(false);
  };

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen bg-background gap-3">
        <Loader2 className="w-8 h-8 animate-spin text-primary" />
        <span className="text-sm font-semibold text-muted-foreground animate-pulse">Initializing Pro Portal...</span>
      </div>
    );
  }

  if (!session) {
    return (
      <div className="min-h-screen bg-muted/20 flex flex-col items-center justify-center p-4">
        <header className="text-center space-y-2 mb-8 select-none">
          <div className="w-14 h-14 bg-primary text-primary-foreground font-black text-2xl flex items-center justify-center rounded-2xl mx-auto shadow-md">
            MT
          </div>
          <h1 className="text-2xl font-black text-foreground tracking-tight mt-3">MacroTracker Professional Portal</h1>
          <p className="text-sm text-muted-foreground max-w-[320px]">
            Private static invite-only portal for the B2B professional practitioner practice.
          </p>
        </header>
        <main className="w-full max-w-4xl">
          <Suspense fallback={<PanelFallback />}>
            <AuthPanel />
          </Suspense>
        </main>
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
      case 'invite-panel':
        return <InvitePanel />;
      case 'clients-panel':
      default:
        if (showOnboarding) {
          return (
            <OnboardingWizard
              onDone={handleOnboardingDone}
              onCancel={() => setShowOnboarding(false)}
            />
          );
        }
        return (
          <div className="grid grid-cols-1 xl:grid-cols-12 gap-6 items-start">
            <div className="xl:col-span-4">
              <ClientsPanel
                onSelectClient={(client: ProfessionalClient) => {
                  setSelectedClient(client);
                  if (window.innerWidth < 1280) {
                    setTimeout(() => {
                      document.getElementById('client-detail-section')?.scrollIntoView({ behavior: 'smooth' });
                    }, 100);
                  }
                }}
                selectedClient={selectedClient}
                onAddClient={() => setShowOnboarding(true)}
              />
            </div>
            <div className="xl:col-span-8" id="client-detail-section">
              {selectedClient ? (
                <ClientDetail
                  client={selectedClient}
                  onClose={() => setSelectedClient(null)}
                  onMessagesRead={() => {}}
                />
              ) : (
                <div className="border border-dashed rounded-xl p-12 text-center bg-muted/10 text-muted-foreground space-y-4 flex flex-col items-center justify-center min-h-[360px]">
                  <Sparkles className="w-12 h-12 text-primary/30 animate-pulse" />
                  <div>
                    <h4 className="font-bold text-foreground text-base">Select a client to get started</h4>
                    <p className="text-xs text-muted-foreground mt-1 max-w-[320px] mx-auto leading-relaxed">
                      Choose an active practitioner roster client on the left list to view aggregate progress snapshots, publish weekly coaching targets, or message them in real-time.
                    </p>
                  </div>
                </div>
              )}
            </div>
          </div>
        );
    }
  };

  return (
    <div className="min-h-screen flex bg-background">
      {sidebarOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-20 xl:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      <div className={`fixed inset-y-0 left-0 z-30 xl:static xl:z-auto transform transition-transform duration-200 ${
        sidebarOpen ? 'translate-x-0' : '-translate-x-full xl:translate-x-0'
      }`}>
        <Sidebar activePanel={activePanel} setActivePanel={handleSetActivePanel} />
      </div>

      <main className="flex-1 flex flex-col min-w-0">
        <header className="h-14 md:h-[76px] border-b bg-card px-4 md:px-8 flex items-center justify-between shrink-0 gap-3">
          <button
            className="xl:hidden w-9 h-9 flex items-center justify-center rounded-lg hover:bg-accent shrink-0"
            onClick={() => setSidebarOpen(true)}
            aria-label="Open navigation menu"
          >
            {sidebarOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
          </button>
          <div className="min-w-0">
            <p className="text-[10px] font-black tracking-widest text-primary uppercase hidden md:block">Professional operations</p>
            <h2 className="text-xs md:text-sm font-bold text-foreground flex items-center gap-1.5 truncate">
              <span className="truncate">Client plans, billing, and consent in one unified workspace</span>
              {professional && (
                <>
                  <ChevronRight className="w-3 h-3 text-muted-foreground shrink-0 hidden md:inline" />
                  <span className="text-muted-foreground font-semibold flex items-center gap-1 shrink-0 hidden md:flex">
                    <Briefcase className="w-3 h-3" />
                    {professional.business_name || 'Solo Practice'}
                  </span>
                </>
              )}
            </h2>
          </div>
          <div className="flex items-center gap-2">
            <NotificationBell />
          </div>
        </header>

        <div className="flex-1 overflow-y-auto p-4 md:p-8 select-none">
          <div className="max-w-7xl mx-auto space-y-6">
            <Suspense fallback={<PanelFallback />}>
              {renderActivePanel()}
            </Suspense>
          </div>
        </div>
      </main>
    </div>
  );
};
