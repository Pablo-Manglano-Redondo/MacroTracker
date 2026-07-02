import { vi, describe, test, expect, beforeEach, afterEach } from 'vitest';

// Mock the config and supabase modules so they don't throw errors in test environments
vi.mock('../config', () => ({
  supabaseConfig: {
    url: 'https://mock-project.supabase.co',
    anonKey: 'mock-anon-key',
  },
  practiceAlertsEnabled: true,
}));

vi.mock('./supabase', () => ({
  supabase: {
    from: vi.fn(() => ({
      select: vi.fn(() => ({
        single: vi.fn().mockResolvedValue({ data: null, error: null }),
      })),
    })),
  },
}));

import { act } from 'react';
import ReactDOM from 'react-dom/client';
import { NavigationProvider, usePortalNavigation } from './navigation-context';

describe('NavigationProvider', () => {
  let container: HTMLDivElement;

  beforeEach(() => {
    container = document.createElement('div');
    document.body.appendChild(container);
    window.location.hash = '';
  });

  afterEach(() => {
    document.body.removeChild(container);
  });

  test('provides initial state and allows panel navigation', async () => {
    let navigation: any = null;

    const TestComponent = () => {
      navigation = usePortalNavigation();
      return <div>Active: {navigation.activePanel}</div>;
    };

    const root = ReactDOM.createRoot(container);
    await act(async () => {
      root.render(
        <NavigationProvider>
          <TestComponent />
        </NavigationProvider>
      );
    });

    expect(navigation).not.toBeNull();
    expect(navigation.activePanel).toBe('dashboard-panel');
    expect(navigation.selectedClient).toBeNull();
    expect(navigation.detailTab).toBe('summary');

    // Navigate to recipes panel
    await act(async () => {
      navigation.navigateToPanel('recipes-panel');
    });

    expect(navigation.activePanel).toBe('recipes-panel');
    expect(window.location.hash).toBe('#recipes-panel');
  });

  test('allows client and tab selection', async () => {
    let navigation: any = null;

    const TestComponent = () => {
      navigation = usePortalNavigation();
      return null;
    };

    const root = ReactDOM.createRoot(container);
    await act(async () => {
      root.render(
        <NavigationProvider>
          <TestComponent />
        </NavigationProvider>
      );
    });

    // Mock client object
    const mockClient = {
      id: 'relationship-123',
      client_id: 'client-456',
      display_name: 'John Doe',
      status: 'connected',
    } as any;

    await act(async () => {
      navigation.selectClient(mockClient, 'plans');
    });

    expect(navigation.selectedClient).toBe(mockClient);
    expect(navigation.detailTab).toBe('plans');

    await act(async () => {
      navigation.selectClientTab('chat');
    });

    expect(navigation.detailTab).toBe('chat');
  });
});
