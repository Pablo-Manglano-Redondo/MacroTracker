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
  const { tr } = usePortalI18n();

  return (
    <div className="min-h-[400px] flex flex-col items-center justify-center p-8 text-center">
      <div className="w-16 h-16 rounded-full bg-destructive/10 flex items-center justify-center mb-4">
        <AlertTriangle className="w-8 h-8 text-destructive" />
      </div>
      <h2 className="text-xl font-bold text-foreground mb-2">
        {tr('Algo no ha ido bien', 'Something went wrong')}
      </h2>
      <p className="text-sm text-muted-foreground max-w-md mb-6 leading-relaxed">
        {tr(
          'Se ha producido un error inesperado. Inténtalo de nuevo o contacta con soporte si el problema continúa.',
          'An unexpected error occurred. Please try again or contact support if the problem persists.',
        )}
      </p>
      <div className="flex gap-3">
        <Button onClick={onRetry} variant="default">
          <RefreshCw className="w-4 h-4 mr-2" />
          {tr('Intentar de nuevo', 'Try again')}
        </Button>
        <Button onClick={() => window.location.reload()} variant="outline">
          {tr('Recargar página', 'Reload page')}
        </Button>
      </div>
    </div>
  );
}
