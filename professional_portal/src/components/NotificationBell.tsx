import React, { useState, useRef, useEffect } from 'react';
import { useAuth } from '../lib/auth-context';
import { useNotifications, useUnreadNotificationCount, useMarkNotificationRead } from '../hooks/queries/useNotifications';
import { Bell, BellRing, CheckCheck, MessageSquare, UserPlus, ClipboardCheck, Activity } from 'lucide-react';

const typeIcons: Record<string, React.ReactNode> = {
  client_connected: <UserPlus className="w-3.5 h-3.5 text-emerald-500" />,
  snapshot_received: <Activity className="w-3.5 h-3.5 text-primary" />,
  checkin_submitted: <ClipboardCheck className="w-3.5 h-3.5 text-amber-500" />,
  message_received: <MessageSquare className="w-3.5 h-3.5 text-blue-500" />,
};

export const NotificationBell: React.FC = () => {
  const { professional } = useAuth();
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
        className="relative w-9 h-9 flex items-center justify-center rounded-lg hover:bg-accent transition-colors"
        aria-label={`Notifications${unreadCount > 0 ? ` (${unreadCount} unread)` : ''}`}
      >
        {unreadCount > 0 ? <BellRing className="w-4 h-4 text-primary" /> : <Bell className="w-4 h-4 text-muted-foreground" />}
        {unreadCount > 0 && (
          <span className="absolute -top-0.5 -right-0.5 w-4 h-4 rounded-full bg-destructive text-destructive-foreground text-[9px] font-bold flex items-center justify-center">
            {unreadCount > 9 ? '9+' : unreadCount}
          </span>
        )}
      </button>

      {open && (
        <div className="absolute right-0 top-full mt-2 w-80 rounded-xl border bg-card shadow-2xl z-50 overflow-hidden">
          <div className="flex items-center justify-between px-4 py-3 border-b">
            <p className="text-xs font-bold">Notifications</p>
            {unreadCount > 0 && (
              <button onClick={markAllRead} className="flex items-center gap-1 text-[10px] text-muted-foreground hover:text-foreground transition-colors">
                <CheckCheck className="w-3 h-3" /> Mark all read
              </button>
            )}
          </div>
          <div className="max-h-[360px] overflow-y-auto [scrollbar-width:thin]">
            {notifications.length === 0 ? (
              <div className="px-4 py-8 text-center text-xs text-muted-foreground">No notifications yet</div>
            ) : (
              notifications.map(n => (
                <button
                  key={n.id}
                  onClick={() => { if (!n.read) markRead(n.id); }}
                  className={`w-full flex items-start gap-3 px-4 py-3 text-left hover:bg-secondary/50 transition-colors ${
                    !n.read ? 'bg-primary/5 border-l-2 border-l-primary' : 'border-l-2 border-l-transparent'
                  }`}
                >
                  <div className="shrink-0 mt-0.5">{typeIcons[n.type] || <Bell className="w-3.5 h-3.5 text-muted-foreground" />}</div>
                  <div className="flex-1 min-w-0">
                    <p className={`text-xs ${!n.read ? 'font-semibold' : 'font-medium text-muted-foreground'}`}>{n.title}</p>
                    {n.body && <p className="text-[10px] text-muted-foreground mt-0.5 line-clamp-2">{n.body}</p>}
                    <p className="text-[9px] text-muted-foreground/60 mt-1">
                      {new Date(n.created_at).toLocaleDateString(undefined, { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}
                    </p>
                  </div>
                  {!n.read && <div className="w-2 h-2 rounded-full bg-primary shrink-0 mt-1.5" />}
                </button>
              ))
            )}
          </div>
        </div>
      )}
    </div>
  );
};
