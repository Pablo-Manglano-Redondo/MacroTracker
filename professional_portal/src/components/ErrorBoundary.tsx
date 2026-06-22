import { Component, type ErrorInfo, type ReactNode } from 'react';
import { Button } from './ui/button';
import { AlertTriangle, RefreshCw } from 'lucide-react';
import { usePortalI18n } from '../lib/portal-i18n';

interface ErrorBoundaryProps {
  children: ReactNode;
  fallback?: ReactNode;
}

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('[ErrorBoundary] Caught error:', error, errorInfo);
  }

  handleRetry = () => {
    this.setState({ hasError: false, error: null });
  };

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <PortalErrorFallback onRetry={this.handleRetry} />
      );
    }

    return this.props.children;
  }
}

function PortalErrorFallback({ onRetry }: { onRetry: () => void }) {
  const { t } = usePortalI18n();

  return (
    <div className="min-h-[400px] flex flex-col items-center justify-center p-8 text-center">
      <div className="w-16 h-16 rounded-full bg-destructive/10 flex items-center justify-center mb-4">
        <AlertTriangle className="w-8 h-8 text-destructive" />
      </div>
      <h2 className="text-xl font-bold text-foreground mb-2">
        {t('components.errorboundary.something_went_wrong')}
      </h2>
      <p className="text-sm text-muted-foreground max-w-md mb-6 leading-relaxed">
        {t('components.errorboundary.an_unexpected_error_occurred_please_try_again_or_contact_support_if_the_')}
      </p>
      <div className="flex gap-3">
        <Button onClick={onRetry} variant="default">
          <RefreshCw className="w-4 h-4 mr-2" />
          {t('components.errorboundary.try_again')}
        </Button>
        <Button onClick={() => window.location.reload()} variant="outline">
          {t('components.errorboundary.reload_page')}
        </Button>
      </div>
    </div>
  );
}
