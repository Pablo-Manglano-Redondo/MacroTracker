import React, { createContext, useContext, useState, useEffect } from 'react';
import { ProfessionalClient } from '../types/database.types';
import { supabase } from './supabase';

export type DetailTab =
  | 'summary'
  | 'plans'
  | 'checkins'
  | 'chat'
  | 'progress'
  | 'diary'
  | 'notes'
  | 'profile';

export type ActivePanel =
  | 'profile-panel'
  | 'billing-panel'
  | 'clients-panel'
  | 'dashboard-panel'
  | 'recipes-panel'
  | 'templates-panel'
  | 'checkins-panel';

interface NavigationState {
  activePanel: ActivePanel;
  selectedClient: ProfessionalClient | null;
  detailTab: DetailTab;
  navigateToPanel: (panel: ActivePanel) => void;
  selectClient: (client: ProfessionalClient | null, tab?: DetailTab) => void;
  selectClientTab: (tab: DetailTab) => void;
}

const NavigationContext = createContext<NavigationState | undefined>(undefined);

export const NavigationProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [activePanel, setActivePanel] = useState<ActivePanel>(() => {
    if (typeof window !== 'undefined') {
      const hash = window.location.hash.replace('#', '');
      const validPanels: ActivePanel[] = [
        'profile-panel',
        'billing-panel',
        'clients-panel',
        'dashboard-panel',
        'recipes-panel',
        'templates-panel',
        'checkins-panel',
      ];
      if (validPanels.includes(hash as ActivePanel)) {
        return hash as ActivePanel;
      }
    }
    return 'dashboard-panel';
  });

  const [selectedClient, setSelectedClient] = useState<ProfessionalClient | null>(null);
  const [detailTab, setDetailTab] = useState<DetailTab>('summary');

  // Keep window.location.hash synchronized with activePanel
  useEffect(() => {
    const handleHashChange = () => {
      const hash = window.location.hash.replace('#', '');
      const validPanels: ActivePanel[] = [
        'profile-panel',
        'billing-panel',
        'clients-panel',
        'dashboard-panel',
        'recipes-panel',
        'templates-panel',
        'checkins-panel',
      ];
      if (validPanels.includes(hash as ActivePanel)) {
        setActivePanel(hash as ActivePanel);
      }
    };

    window.addEventListener('hashchange', handleHashChange);
    return () => window.removeEventListener('hashchange', handleHashChange);
  }, []);

  // Backward compatibility: Translate CustomEvents to Context state changes
  useEffect(() => {
    const handleSelectClientEvent = async (e: Event) => {
      const detail = (e as CustomEvent).detail;
      if (!detail) return;
      const relationshipId = typeof detail === 'string' ? null : detail?.relationshipId ?? null;
      const clientId = typeof detail === 'string' ? detail : detail?.clientId ?? null;

      if (!relationshipId && !clientId) return;

      // Fetch client details using supabase client
      let query = supabase
        .from('professional_clients')
        .select(`
          id,
          professional_id,
          client_id,
          display_name,
          status,
          connected_at,
          sharing_mode,
          messages_enabled,
          client_shared_snapshots(*)
        `);

      if (relationshipId) {
        query = query.eq('id', relationshipId);
      } else {
        query = query.eq('client_id', clientId);
      }

      const { data } = await query.single();
      if (data) {
        setSelectedClient(data as unknown as ProfessionalClient);
      }
    };

    const handleSelectTabEvent = (e: Event) => {
      const detail = (e as CustomEvent).detail;
      if (detail && typeof detail === 'object') {
        const { tab } = detail;
        if (tab) {
          setDetailTab(tab as DetailTab);
        }
      }
    };

    window.addEventListener('select-client', handleSelectClientEvent);
    window.addEventListener('select-client-tab', handleSelectTabEvent);

    return () => {
      window.removeEventListener('select-client', handleSelectClientEvent);
      window.removeEventListener('select-client-tab', handleSelectTabEvent);
    };
  }, []);

  const navigateToPanel = (panel: ActivePanel) => {
    setActivePanel(panel);
    if (typeof window !== 'undefined') {
      window.location.hash = panel;
    }
  };

  const selectClient = (client: ProfessionalClient | null, tab: DetailTab = 'summary') => {
    setSelectedClient(client);
    setDetailTab(tab);
  };

  const selectClientTab = (tab: DetailTab) => {
    setDetailTab(tab);
  };

  return (
    <NavigationContext.Provider
      value={{
        activePanel,
        selectedClient,
        detailTab,
        navigateToPanel,
        selectClient,
        selectClientTab,
      }}
    >
      {children}
    </NavigationContext.Provider>
  );
};

export const usePortalNavigation = () => {
  const context = useContext(NavigationContext);
  if (!context) {
    throw new Error('usePortalNavigation must be used within a NavigationProvider');
  }
  return context;
};
