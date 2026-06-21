import React, { useState, useRef, useEffect } from 'react';
import { useAuth } from '../lib/auth-context';
import { usePortalI18n } from '../lib/portal-i18n';
import { useNotifications, useUnreadNotificationCount, useMarkNotificationRead } from '../hooks/queries/useNotifications';
import { Bell, BellRing, CheckCheck, MessageSquare, UserPlus, ClipboardCheck, Activity } from 'lucide-react';

const typeIcons: Record<string, React.ReactNode> = {
  client_connected: <UserPlus className="w-3.5 h-3.5 text-emerald-400" />,
  snapshot_received: <Activity className="w-3.5 h-3.5 text-primary" />,
  checkin_submitted: <ClipboardCheck className="w-3.5 h-3.5 text-amber-400" />,
  message_received: <MessageSquare className="w-3.5 h-3.5 text-indigo-400" />,
};

export const NotificationBell: React.FC = () => {
  const { professional } = useAuth();
  const { tr } = usePortalI18n();
  const { data: notifications = [] } = useNotifications(professional?.id);
  const { data: unreadCount = 0 } = useUnreadNotificationCount(professional?.id);
  const { markRead, markAllRead } = useMarkNotificationRead(professional?.id);
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

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
        className="relative w-9 h-9 flex items-center justify-center rounded-xl bg-black/10 dark:bg-white/5 border border-border/20 hover:bg-black/15 dark:hover:bg-white/10 hover:border-border/40 transition-all cursor-pointer"
        aria-label={
          unreadCount > 0
            ? tr(`Notificaciones (${unreadCount} sin leer)`, `Notifications (${unreadCount} unread)`)
            : tr('Notificaciones', 'Notifications')
        }
      >
        {unreadCount > 0 ? <BellRing className="w-4 h-4 text-primary animate-pulse" /> : <Bell className="w-4 h-4 text-muted-foreground" />}
        {unreadCount > 0 && (
          <span className="absolute -top-1 -right-1 w-4 h-4 rounded-full bg-rose-500 text-white text-[8px] font-black flex items-center justify-center shadow-[0_0_8px_rgba(244,63,94,0.6)]">
            {unreadCount > 9 ? '9+' : unreadCount}
          </span>
        )}
      </button>

      {open && (
        <div className="absolute right-0 top-full mt-2 w-80 rounded-xl border border-border/40 bg-neutral-950/95 backdrop-blur-xl shadow-2xl z-50 overflow-hidden animate-fade-in-up">
          <div className="flex items-center justify-between px-4 py-3 border-b border-border/20 bg-white/1">
            <p className="text-xs font-extrabold text-gradient">{tr('Notificaciones', 'Notifications')}</p>
            {unreadCount > 0 && (
              <button onClick={markAllRead} className="flex items-center gap-1 text-[10px] font-bold text-muted-foreground hover:text-primary transition-colors cursor-pointer">
                <CheckCheck className="w-3.5 h-3.5" /> {tr('Marcar todo como leído', 'Mark all read')}
              </button>
            )}
          </div>
          <div className="max-h-[320px] overflow-y-auto custom-scrollbar">
            {notifications.length === 0 ? (
              <div className="px-4 py-10 text-center text-xs text-muted-foreground font-semibold">
                {tr('Todavía no hay notificaciones', 'No notifications yet')}
              </div>
            ) : (
              notifications.map(n => (
                <button
                  key={n.id}
                  onClick={() => { if (!n.read) markRead(n.id); }}
                  className={`w-full flex items-start gap-3 px-4 py-3 text-left border-b border-border/10 hover:bg-white/5 transition-colors cursor-pointer ${
                    !n.read ? 'bg-primary/5 border-l-2 border-l-primary' : 'border-l-2 border-l-transparent'
                  }`}
                >
                  <div className="shrink-0 mt-0.5 w-6 h-6 rounded-lg bg-black/20 dark:bg-white/5 flex items-center justify-center border border-border/10">
                    {typeIcons[n.type] || <Bell className="w-3.5 h-3.5 text-muted-foreground" />}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className={`text-xs ${!n.read ? 'font-bold text-foreground' : 'font-semibold text-muted-foreground'}`}>{n.title}</p>
                    {n.body && <p className="text-[10px] text-muted-foreground/80 mt-0.5 line-clamp-2 leading-relaxed">{n.body}</p>}
                    <p className="text-[8px] font-bold text-muted-foreground/50 mt-1">
                      {new Date(n.created_at).toLocaleDateString(undefined, { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}
                    </p>
                  </div>
                  {!n.read && <div className="w-1.5 h-1.5 rounded-full bg-primary shrink-0 mt-1.5 shadow-[0_0_6px_rgba(16,185,129,0.6)]" />}
                </button>
              ))
            )}
          </div>
        </div>
      )}
    </div>
  );
};
