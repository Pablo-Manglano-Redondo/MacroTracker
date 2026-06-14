import React from 'react';
import ReactDOM from 'react-dom/client';
import { QueryClientProvider } from '@tanstack/react-query';
import { AppShell } from './components/AppShell';
import { AuthProvider } from './lib/auth-context';
import { ErrorBoundary } from './components/ErrorBoundary';
import { queryClient } from './lib/query-client';
import { Toaster } from 'sonner';
import './lib/sentry';
import { PortalI18nProvider } from './lib/portal-i18n';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <ErrorBoundary>
      <QueryClientProvider client={queryClient}>
        <PortalI18nProvider>
          <AuthProvider>
            <AppShell />
            <Toaster
              position="bottom-right"
              richColors
              closeButton
              toastOptions={{
                className: 'font-sans text-sm',
              }}
            />
          </AuthProvider>
        </PortalI18nProvider>
      </QueryClientProvider>
    </ErrorBoundary>
  </React.StrictMode>
);
