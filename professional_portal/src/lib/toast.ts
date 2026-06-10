import { toast as sonnerToast } from 'sonner';

type ToastProps = {
  title?: string;
  description?: string;
  duration?: number;
};

export const toast = {
  success: (message: string, props?: ToastProps) => {
    sonnerToast.success(message, {
      description: props?.description,
      duration: props?.duration ?? 4000,
    });
  },
  error: (message: string, props?: ToastProps) => {
    sonnerToast.error(message, {
      description: props?.description,
      duration: props?.duration ?? 6000,
    });
  },
  warning: (message: string, props?: ToastProps) => {
    sonnerToast.warning(message, {
      description: props?.description,
      duration: props?.duration ?? 5000,
    });
  },
  info: (message: string, props?: ToastProps) => {
    sonnerToast.info(message, {
      description: props?.description,
      duration: props?.duration ?? 4000,
    });
  },
  promise: <T,>(
    promise: Promise<T>,
    messages: {
      loading: string;
      success: string;
      error: string;
    }
  ) => {
    return sonnerToast.promise(promise, {
      loading: messages.loading,
      success: messages.success,
      error: messages.error,
    });
  },
  dismiss: (id?: string | number) => {
    sonnerToast.dismiss(id);
  },
};
