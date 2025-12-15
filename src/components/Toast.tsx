import React, { useEffect, useState, useCallback, createContext, useContext } from 'react';
import { CheckCircle, AlertTriangle, Info, X, Loader2 } from 'lucide-react';

export type ToastType = 'success' | 'error' | 'info' | 'warning' | 'loading';

export interface Toast {
  id: string;
  message: string;
  type: ToastType;
  duration?: number; // ms, 0 = persistent
  action?: {
    label: string;
    onClick: () => void;
  };
}

interface ToastContextType {
  toasts: Toast[];
  addToast: (toast: Omit<Toast, 'id'>) => string;
  removeToast: (id: string) => void;
  updateToast: (id: string, updates: Partial<Omit<Toast, 'id'>>) => void;
}

const ToastContext = createContext<ToastContextType | null>(null);

export const useToast = () => {
  const context = useContext(ToastContext);
  if (!context) {
    throw new Error('useToast must be used within a ToastProvider');
  }
  return context;
};

// Helper hooks for common toast types
export const useToastHelpers = () => {
  const { addToast, removeToast, updateToast } = useToast();
  
  return {
    success: (message: string, duration = 4000) => 
      addToast({ message, type: 'success', duration }),
    error: (message: string, duration = 6000) => 
      addToast({ message, type: 'error', duration }),
    info: (message: string, duration = 4000) => 
      addToast({ message, type: 'info', duration }),
    warning: (message: string, duration = 5000) => 
      addToast({ message, type: 'warning', duration }),
    loading: (message: string) => 
      addToast({ message, type: 'loading', duration: 0 }),
    dismiss: removeToast,
    update: updateToast,
  };
};

export const ToastProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const addToast = useCallback((toast: Omit<Toast, 'id'>) => {
    const id = `toast-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    setToasts(prev => [...prev, { ...toast, id }]);
    return id;
  }, []);

  const removeToast = useCallback((id: string) => {
    setToasts(prev => prev.filter(t => t.id !== id));
  }, []);

  const updateToast = useCallback((id: string, updates: Partial<Omit<Toast, 'id'>>) => {
    setToasts(prev => prev.map(t => t.id === id ? { ...t, ...updates } : t));
  }, []);

  return (
    <ToastContext.Provider value={{ toasts, addToast, removeToast, updateToast }}>
      {children}
      <ToastContainer toasts={toasts} onRemove={removeToast} />
    </ToastContext.Provider>
  );
};

const ToastItem: React.FC<{ toast: Toast; onRemove: (id: string) => void }> = ({ toast, onRemove }) => {
  useEffect(() => {
    if (toast.duration && toast.duration > 0) {
      const timer = setTimeout(() => onRemove(toast.id), toast.duration);
      return () => clearTimeout(timer);
    }
  }, [toast.id, toast.duration, onRemove]);

  const icons = {
    success: <CheckCircle size={18} className="text-emerald-400" />,
    error: <AlertTriangle size={18} className="text-red-400" />,
    warning: <AlertTriangle size={18} className="text-amber-400" />,
    info: <Info size={18} className="text-[var(--hytale-accent-blue)]" />,
    loading: <Loader2 size={18} className="text-[var(--hytale-accent-blue)] animate-spin" />,
  };

  const bgColors = {
    success: 'bg-emerald-500/10 border-emerald-500/30',
    error: 'bg-red-500/10 border-red-500/30',
    warning: 'bg-amber-500/10 border-amber-500/30',
    info: 'bg-[var(--hytale-accent-blue)]/10 border-[var(--hytale-accent-blue)]/30',
    loading: 'bg-[var(--hytale-accent-blue)]/10 border-[var(--hytale-accent-blue)]/30',
  };

  return (
    <div 
      className={`flex items-center gap-3 px-4 py-3 rounded-lg border backdrop-blur-sm shadow-lg animate-slide-in ${bgColors[toast.type]}`}
      role="alert"
      aria-live="polite"
    >
      {icons[toast.type]}
      <span className="text-sm text-[var(--hytale-text-primary)] flex-1">{toast.message}</span>
      {toast.action && (
        <button
          onClick={toast.action.onClick}
          className="text-xs font-medium text-[var(--hytale-accent-blue)] hover:text-[var(--hytale-accent-blue-hover)] transition-colors"
        >
          {toast.action.label}
        </button>
      )}
      {toast.type !== 'loading' && (
        <button
          onClick={() => onRemove(toast.id)}
          className="p-1 hover:bg-white/10 rounded transition-colors text-[var(--hytale-text-muted)]"
          aria-label="Dismiss notification"
        >
          <X size={14} />
        </button>
      )}
    </div>
  );
};

const ToastContainer: React.FC<{ toasts: Toast[]; onRemove: (id: string) => void }> = ({ toasts, onRemove }) => {
  if (toasts.length === 0) return null;
  
  return (
    <div className="fixed bottom-4 right-4 z-[9999] flex flex-col gap-2 max-w-sm" aria-live="polite">
      {toasts.map(toast => (
        <ToastItem key={toast.id} toast={toast} onRemove={onRemove} />
      ))}
    </div>
  );
};

export default ToastProvider;

