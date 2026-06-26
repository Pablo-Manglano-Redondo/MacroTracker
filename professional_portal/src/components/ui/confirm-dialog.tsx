import React from 'react';
import { createPortal } from 'react-dom';
import { AlertTriangle, X } from 'lucide-react';

interface ConfirmDialogProps {
  open: boolean;
  title: string;
  message: string;
  confirmLabel?: string;
  cancelLabel?: string;
  destructive?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
  loading?: boolean;
}

export const ConfirmDialog: React.FC<ConfirmDialogProps> = ({
  open,
  title,
  message,
  confirmLabel = 'Delete',
  cancelLabel = 'Cancel',
  destructive = true,
  onConfirm,
  onCancel,
  loading = false,
}) => {
  if (!open) return null;

  return createPortal(
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50" onClick={onCancel}>
      <div
        className="bg-card rounded-2xl p-6 w-full max-w-sm m-4 shadow-2xl"
        onClick={e => e.stopPropagation()}
      >
        <div className="flex items-start gap-4">
          <div className={`p-2 rounded-full shrink-0 ${destructive ? 'bg-red-500/10' : 'bg-primary/10'}`}>
            <AlertTriangle className={`w-5 h-5 ${destructive ? 'text-red-500' : 'text-primary'}`} />
          </div>
          <div className="flex-1 min-w-0">
            <h3 className="portal-card-heading">{title}</h3>
            <p className="portal-meta mt-1 text-muted-foreground leading-relaxed">{message}</p>
          </div>
          <button onClick={onCancel} className="p-1 rounded-md hover:bg-secondary shrink-0">
            <X className="w-4 h-4" />
          </button>
        </div>
        <div className="flex justify-end gap-2 mt-5">
          <button
            onClick={onCancel}
            disabled={loading}
            className="portal-action px-4 py-1.5 rounded-lg border hover:bg-secondary transition-colors disabled:opacity-50"
          >
            {cancelLabel}
          </button>
          <button
            onClick={onConfirm}
            disabled={loading}
            className={`portal-action px-4 py-1.5 rounded-lg transition-colors disabled:opacity-50 ${
              destructive
                ? 'bg-red-500 text-white hover:bg-red-600'
                : 'bg-primary text-primary-foreground hover:bg-primary/90'
            }`}
          >
            {loading ? 'Processing...' : confirmLabel}
          </button>
        </div>
      </div>
    </div>,
    document.body,
  );
};
