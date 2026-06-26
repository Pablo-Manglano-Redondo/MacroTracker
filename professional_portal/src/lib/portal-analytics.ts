import Sentry from './sentry';

export function trackPortalEvent(event: string, data?: Record<string, unknown>) {
  Sentry.addBreadcrumb({
    category: 'portal-event',
    level: 'info',
    message: event,
    data,
  });

  if ((import.meta as any).env?.DEV) {
    console.debug(`[portal-event] ${event}`, data ?? {});
  }
}
