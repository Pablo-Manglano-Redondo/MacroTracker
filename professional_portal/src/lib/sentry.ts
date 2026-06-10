import * as Sentry from '@sentry/react';

const dsn = 'https://b51586cd2e102f9d247e515196af6162@o4511508222181376.ingest.de.sentry.io/4511508224671824';

Sentry.init({
  dsn,
  environment: 'web-portal',
  tracesSampleRate: 0.1,
  integrations: [Sentry.browserTracingIntegration()],
});

export default Sentry;
