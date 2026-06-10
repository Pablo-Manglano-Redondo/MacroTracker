import React, { useState, useEffect } from 'react';
import { useAuth } from '../lib/auth-context';
import { 
  User, 
  CreditCard, 
  UserPlus, 
  Users, 
  LogOut, 
  Sun, 
  Moon,
  LayoutDashboard,
  ChefHat,
  Layers,
  ClipboardCheck
} from 'lucide-react';

interface SidebarProps {
  activePanel: string;
  setActivePanel: (panel: string) => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ activePanel, setActivePanel }) => {
  const { professional, signOut } = useAuth();
  
  const [theme, setTheme] = useState<'light' | 'dark'>(() => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('theme');
      if (saved === 'light' || saved === 'dark') return saved;
      return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    }
    return 'light';
  });

  useEffect(() => {
    const root = window.document.documentElement;
    if (theme === 'dark') {
      root.classList.add('dark');
    } else {
      root.classList.remove('dark');
    }
    localStorage.setItem('theme', theme);
  }, [theme]);

  const toggleTheme = () => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
  };

  const navItems = [
    { id: 'dashboard-panel', label: 'Dashboard', icon: LayoutDashboard },
    { id: 'clients-panel', label: 'Clients', icon: Users },
    { id: 'recipes-panel', label: 'Recipes', icon: ChefHat },
    { id: 'templates-panel', label: 'Templates', icon: Layers },
    { id: 'checkins-panel', label: 'Check-ins', icon: ClipboardCheck },
    { id: 'profile-panel', label: 'Profile', icon: User },
    { id: 'billing-panel', label: 'Billing', icon: CreditCard },
    { id: 'invite-panel', label: 'Invite', icon: UserPlus },
  ];

  const getInitials = () => {
    if (professional?.display_name) {
      return professional.display_name.slice(0, 2).toUpperCase();
    }
    if (professional?.business_name) {
      return professional.business_name.slice(0, 2).toUpperCase();
    }
    return 'MT';
  };

  return (
    <aside className="sticky top-0 h-screen w-[260px] bg-sidebar-bg text-sidebar-foreground flex flex-col justify-between shrink-0 border-r border-sidebar-border select-none overflow-y-auto [scrollbar-width:none]">
      {/* Top section */}
      <div className="p-5 space-y-8">
        {/* Brand */}
        <div className="flex items-center gap-2.5">
          <div className="w-9 h-9 flex items-center justify-center rounded-lg bg-primary text-primary-foreground font-bold text-sm">
            MT
          </div>
          <div>
            <p className="text-[10px] font-semibold tracking-wider text-sidebar-muted uppercase">MacroTracker</p>
            <p className="text-sm font-bold text-white leading-none mt-0.5">Pro Portal</p>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex flex-col gap-0.5" aria-label="Portal sections">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activePanel === item.id;
            return (
              <button
                key={item.id}
                onClick={() => {
                  setActivePanel(item.id);
                  window.location.hash = item.id;
                }}
                aria-current={isActive ? 'page' : undefined}
                className={`flex items-center gap-2.5 w-full px-3 py-2 rounded-lg text-[13px] font-medium text-left transition-all duration-100 ${
                  isActive
                    ? 'bg-white/10 text-white'
                    : 'text-sidebar-foreground/60 hover:bg-white/5 hover:text-sidebar-foreground/90'
                }`}
              >
                <Icon className="w-4 h-4 shrink-0" />
                <span>{item.label}</span>
              </button>
            );
          })}
        </nav>
      </div>

      {/* Bottom section */}
      <div className="p-5 space-y-4">
        {/* Theme toggle */}
        <div className="flex items-center justify-between text-xs">
          <span className="text-sidebar-muted/60 font-medium">
            {theme === 'dark' ? 'Dark mode' : 'Light mode'}
          </span>
          <button
            onClick={toggleTheme}
            aria-label={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
            className="p-1.5 rounded-md text-sidebar-muted/60 hover:text-white hover:bg-white/5 transition-colors"
          >
            {theme === 'light' ? <Moon className="w-4 h-4" /> : <Sun className="w-4 h-4" />}
          </button>
        </div>

        {/* Profile */}
        {professional && (
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-full bg-white/10 text-white text-xs font-bold flex items-center justify-center shrink-0">
              {getInitials()}
            </div>
            <div className="min-w-0 flex-1">
              <p className="text-xs font-semibold text-white truncate">
                {professional.business_name || professional.display_name || 'Professional'}
              </p>
              <p className="text-[10px] text-sidebar-muted/60 truncate">
                {professional.pro_status === 'active' ? 'Pro Active' : professional.pro_status || 'Free'}
              </p>
            </div>
          </div>
        )}

        {/* Sign out */}
        <button
          onClick={signOut}
          className="flex items-center gap-2 w-full px-3 py-2 rounded-lg text-xs font-medium text-sidebar-muted/60 hover:text-white hover:bg-white/5 transition-colors"
        >
          <LogOut className="w-3.5 h-3.5" />
          Sign out
        </button>
      </div>
    </aside>
  );
};
