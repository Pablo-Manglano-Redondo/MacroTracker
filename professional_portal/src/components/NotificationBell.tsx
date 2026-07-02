import React, { useState, useRef, useEffect } from 'react';
import { useAuth } from '../lib/auth-context';
import { formatPortalDate } from '../lib/date';
import { usePortalI18n } from '../lib/portal-i18n';
import { useNotifications, useUnreadNotificationCount, useMarkNotificationRead } from '../hooks/queries/useNotifications';
import { Bell, BellRing, CheckCheck, MessageSquare, UserPlus, ClipboardCheck, Activity } from 'lucide-react';

interface NotificationStyle {
  bg: string;
  iconColor: string;
  icon: React.ComponentType<{ className?: string }>;
}

const getTypeStyles = (type: string): NotificationStyle => {
  switch (type) {
    case 'client_connected':
      return {
        bg: 'bg-emerald-500/10 border-emerald-500/20',
        iconColor: 'text-emerald-600 dark:text-emerald-400',
        icon: UserPlus,
      };
    case 'snapshot_received':
      return {
        bg: 'bg-primary/10 border-primary/20',
        iconColor: 'text-primary',
        icon: Activity,
      };
    case 'checkin_submitted':
      return {
        bg: 'bg-amber-500/10 border-amber-500/20',
        iconColor: 'text-amber-600 dark:text-amber-400',
        icon: ClipboardCheck,
      };
    case 'message_received':
      return {
        bg: 'bg-indigo-500/10 border-indigo-500/20',
        iconColor: 'text-indigo-600 dark:text-indigo-400',
        icon: MessageSquare,
      };
    default:
      return {
        bg: 'bg-muted/10 border-border/50',
        iconColor: 'text-muted-foreground',
        icon: Bell,
      };
  }
};

export const NotificationBell: React.FC = () => {
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();
  const { data: notifications = [] } = useNotifications(professional?.id);
  const { data: unreadCount = 0 } = useUnreadNotificationCount(professional?.id);
  const { markRead, markAllRead } = useMarkNotificationRead(professional?.id);
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  const translateNotification = (title: string, body?: string | null) => {
    let translatedTitle = title;
    let translatedBody = body || undefined;

    if (title === 'New client connected') {
      translatedTitle = t('components.notificationbell.type_client_connected_title');
    } else if (title === 'Daily snapshot received') {
      translatedTitle = t('components.notificationbell.type_snapshot_received_title');
    } else if (title === 'Check-in requested') {
      translatedTitle = t('components.notificationbell.type_checkin_requested_title');
    } else if (title === 'Check-in submitted') {
      translatedTitle = t('components.notificationbell.type_checkin_submitted_title');
    } else if (title === 'New message received') {
      translatedTitle = t('components.notificationbell.type_message_received_title');
    } else if (title === 'Plan activated') {
      translatedTitle = t('components.notificationbell.type_plan_activated_title');
    }

    if (body === 'A client has accepted your invitation and connected to your practice.') {
      translatedBody = t('components.notificationbell.type_client_connected_body');
    } else if (body === 'A client has shared their daily nutrition snapshot.') {
      translatedBody = t('components.notificationbell.type_snapshot_received_body');
    } else if (body === 'A check-in request was sent to the client.') {
      translatedBody = t('components.notificationbell.type_checkin_requested_body');
    } else if (body === 'A client has submitted their weekly check-in.') {
      translatedBody = t('components.notificationbell.type_checkin_submitted_body');
    } else if (body === 'A client has sent you a message.') {
      translatedBody = t('components.notificationbell.type_message_received_body');
    } else if (body === 'The nutrition plan has been activated.') {
      translatedBody = t('components.notificationbell.type_plan_activated_body');
    }

    return { title: translatedTitle, body: translatedBody };
  };

  useEffect(() => {
    const handleClick = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener('mousedown', handleClick);
    return () => document.removeEventListener('mousedown', handleClick);
  }, []);

  return (
    <div ref={ref} className="relative">
      <button
        onClick={() => setOpen(!open)}
        className="relative w-12 h-12 flex items-center justify-center rounded-xl bg-card border border-border hover:bg-accent text-foreground shadow-sm transition-all cursor-pointer animate-fade-in"
        aria-label={
          unreadCount > 0
            ? t('components.notificationbell.notifications_unread', { unreadcount: unreadCount })
            : t('components.notificationbell.notifications')
        }
      >
        {unreadCount > 0 ? <BellRing className="w-5 h-5 text-primary animate-pulse" /> : <Bell className="w-5 h-5 text-muted-foreground" />}
        {unreadCount > 0 && (
          <span className="portal-label absolute -top-1.5 -right-1.5 flex h-5 w-5 items-center justify-center rounded-full bg-rose-500 text-white shadow-[0_0_8px_rgba(244,63,94,0.6)]">
            {unreadCount > 9 ? '9+' : unreadCount}
          </span>
        )}
      </button>

      {open && (
        <div className="absolute right-0 top-full mt-3 w-[400px] rounded-2xl border border-border bg-card/98 backdrop-blur-xl shadow-2xl dark:shadow-[0_20px_50px_rgba(0,0,0,0.6)] z-50 overflow-hidden animate-fade-in-up">
          <div className="flex items-center justify-between px-5 py-3.5 border-b border-border/60 bg-muted/20">
            <span className="text-[11px] font-bold tracking-wider uppercase text-muted-foreground/80">
              {t('components.notificationbell.notifications')}
            </span>
            {unreadCount > 0 && (
              <button
                onClick={markAllRead}
                className="flex items-center gap-1.5 text-[11px] font-bold tracking-wider uppercase text-muted-foreground hover:text-primary transition-colors cursor-pointer whitespace-nowrap"
              >
                <CheckCheck className="w-3.5 h-3.5" />
                {t('components.notificationbell.mark_all_read')}
              </button>
            )}
          </div>
          <div className="max-h-[380px] overflow-y-auto custom-scrollbar divide-y divide-border/60">
            {notifications.length === 0 ? (
              <div className="portal-body px-6 py-12 text-center text-muted-foreground text-sm">
                {t('components.notificationbell.no_notifications_yet')}
              </div>
            ) : (
              notifications.map((n) => {
                const styles = getTypeStyles(n.type);
                const Icon = styles.icon;
                const { title: displayTitle, body: displayBody } = translateNotification(n.title, n.body);
                return (
                  <button
                    key={n.id}
                    onClick={() => {
                      if (!n.read) markRead(n.id);

                      const clientId = n.metadata?.client_id || n.metadata?.professional_client_id;
                      if (clientId) {
                        let tab = 'summary';
                        if (n.type === 'snapshot_received' || n.title === 'Daily snapshot received') {
                          tab = 'diary';
                        } else if (n.type === 'checkin_submitted' || n.title === 'Check-in submitted' || n.title === 'Check-in requested') {
                          tab = 'checkins';
                        } else if (n.type === 'message_received' || n.title === 'New message received') {
                          tab = 'chat';
                        } else if (n.type === 'plan_activated' || n.title === 'Plan activated') {
                          tab = 'plans';
                        }

                        // Store pending tab for when ClientDetail mounts
                        (window as any).__pendingClientTab = { clientId, tab };

                        // Update hash and dispatch select client
                        window.location.hash = 'clients-panel';
                        window.dispatchEvent(new CustomEvent('select-client', { detail: clientId }));
                        window.dispatchEvent(new CustomEvent('select-client-tab', { detail: { clientId, tab } }));

                        // Close the notification bell dropdown
                        setOpen(false);
                      }
                    }}
                    className={`w-full flex items-start gap-3.5 px-5 py-3.5 text-left transition-colors cursor-pointer border-l-2 ${
                      !n.read
                        ? 'bg-primary/[0.03] border-l-primary hover:bg-primary/[0.06]'
                        : 'border-l-transparent hover:bg-accent/40'
                    }`}
                  >
                    <div className={`shrink-0 w-9 h-9 rounded-xl flex items-center justify-center border ${styles.bg}`}>
                      <Icon className={`w-4.5 h-4.5 ${styles.iconColor}`} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className={`portal-card-heading text-[14px] leading-tight ${!n.read ? 'text-foreground font-bold' : 'text-muted-foreground font-semibold'}`}>
                        {displayTitle}
                      </p>
                      {displayBody && (
                        <p className="text-[13px] leading-snug mt-1 line-clamp-2 text-muted-foreground/80">
                          {displayBody}
                        </p>
                      )}
                      <p className="text-[11px] font-medium mt-1.5 text-muted-foreground/50">
                        {formatPortalDate(n.created_at, locale, {
                          month: 'short',
                          day: 'numeric',
                          hour: '2-digit',
                          minute: '2-digit',
                        })}
                      </p>
                    </div>
                    {!n.read && (
                      <div className="w-1.5 h-1.5 rounded-full bg-primary shrink-0 self-center shadow-[0_0_6px_rgba(16,185,129,0.6)]" />
                    )}
                  </button>
                );
              })
            )}
          </div>
        </div>
      )}
    </div>
  );
};
