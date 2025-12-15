import React, { Component, ErrorInfo, ReactNode } from 'react';
import { AlertTriangle, RefreshCw } from 'lucide-react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error, errorInfo: ErrorInfo) => void;
  section?: string; // Name of the section for error reporting
}

interface State {
  hasError: boolean;
  error: Error | null;
}

class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error(`Error in ${this.props.section || 'component'}:`, error, errorInfo);
    this.props.onError?.(error, errorInfo);
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
        <div className="flex flex-col items-center justify-center p-8 bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg">
          <div className="w-16 h-16 rounded-full bg-red-500/10 flex items-center justify-center mb-4">
            <AlertTriangle size={32} className="text-red-400" />
          </div>
          <h3 className="font-hytale font-bold text-lg text-[var(--hytale-text-primary)] mb-2">
            Something went wrong
          </h3>
          <p className="text-sm text-[var(--hytale-text-muted)] text-center mb-4 max-w-md">
            {this.props.section 
              ? `An error occurred in the ${this.props.section} section.`
              : 'An unexpected error occurred.'
            }
            {' '}Try refreshing the section or restart the application if the problem persists.
          </p>
          {this.state.error && (
            <details className="mb-4 w-full max-w-md">
              <summary className="text-xs text-[var(--hytale-text-dim)] cursor-pointer hover:text-[var(--hytale-text-muted)]">
                Technical Details
              </summary>
              <pre className="mt-2 p-3 bg-[var(--hytale-bg-input)] rounded text-xs text-[var(--hytale-text-muted)] overflow-auto max-h-32 font-mono">
                {this.state.error.message}
              </pre>
            </details>
          )}
          <button
            onClick={this.handleRetry}
            className="px-4 py-2 bg-[var(--hytale-accent-blue)] text-white rounded-md text-sm font-medium flex items-center gap-2 hover:bg-[var(--hytale-accent-blue-hover)] transition-colors"
          >
            <RefreshCw size={14} /> Try Again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;

