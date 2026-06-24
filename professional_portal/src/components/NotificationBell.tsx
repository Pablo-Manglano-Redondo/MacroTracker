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
        iconColor: 'text-emerald-400',
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
        iconColor: 'text-amber-400',
        icon: ClipboardCheck,
      };
    case 'message_received':
      return {
        bg: 'bg-indigo-500/10 border-indigo-500/20',
        iconColor: 'text-indigo-400',
        icon: MessageSquare,
      };
    default:
      return {
        bg: 'bg-white/5 border-white/10',
        iconColor: 'text-[#8a9499]',
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
          <span className="absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full bg-rose-500 text-white text-[10px] font-black flex items-center justify-center shadow-[0_0_8px_rgba(244,63,94,0.6)]">
            {unreadCount > 9 ? '9+' : unreadCount}
          </span>
        )}
      </button>

      {open && (
        <div className="absolute right-0 top-full mt-3 w-96 rounded-2xl border border-[#1e2326] bg-[#131719]/98 backdrop-blur-xl shadow-[0_20px_50px_rgba(0,0,0,0.6)] z-50 overflow-hidden animate-fade-in-up">
          <div className="flex items-center justify-between px-5 py-4 border-b border-[#1e2326]/60 bg-black/20">
            <p className="text-xs font-black uppercase tracking-[0.2em] text-[#8a9499]">
              {t('components.notificationbell.notifications')}
            </p>
            {unreadCount > 0 && (
              <button
                onClick={markAllRead}
                className="flex items-center gap-1.5 text-xs font-black uppercase tracking-[0.16em] text-muted-foreground hover:text-primary transition-colors cursor-pointer"
              >
                <CheckCheck className="w-4 h-4" />
                {t('components.notificationbell.mark_all_read')}
              </button>
            )}
          </div>
          <div className="max-h-[380px] overflow-y-auto custom-scrollbar divide-y divide-[#1e2326]/60">
            {notifications.length === 0 ? (
              <div className="px-6 py-12 text-center text-sm text-muted-foreground font-semibold">
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
                    }}
                    className={`w-full flex items-start gap-4 px-5 py-4.5 text-left transition-colors cursor-pointer border-l-2 ${
                      !n.read
                        ? 'bg-primary/[0.03] border-l-primary hover:bg-primary/[0.06]'
                        : 'border-l-transparent hover:bg-white/[0.02]'
                    }`}
                  >
                    <div className={`shrink-0 w-10 h-10 rounded-xl flex items-center justify-center border ${styles.bg}`}>
                      <Icon className={`w-5 h-5 ${styles.iconColor}`} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className={`text-sm ${!n.read ? 'font-black text-white' : 'font-semibold text-[#8a9499]'}`}>
                        {displayTitle}
                      </p>
                      {displayBody && (
                        <p className="text-xs text-[#8a9499]/85 mt-1 line-clamp-2 leading-relaxed font-semibold">
                          {displayBody}
                        </p>
                      )}
                      <p className="text-[10px] font-black text-[#5c666b] mt-2 uppercase tracking-wider">
                        {formatPortalDate(n.created_at, locale, {
                          month: 'short',
                          day: 'numeric',
                          hour: '2-digit',
                          minute: '2-digit',
                        })}
                      </p>
                    </div>
                    {!n.read && (
                      <div className="w-2 h-2 rounded-full bg-primary shrink-0 self-center shadow-[0_0_6px_rgba(16,185,129,0.6)]" />
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
