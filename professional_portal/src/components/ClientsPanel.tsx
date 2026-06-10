import React, { useState, useMemo } from 'react';
import { useAuth } from '../lib/auth-context';
import { useClients, useUnreadCounts } from '../hooks/queries/useClients';
import type { ProfessionalClient } from '../types/database.types';
import { Button } from './ui/button';
import { Skeleton } from './ui/skeleton';
import { MessageSquare, ChevronRight, UserPlus, Users, Search } from 'lucide-react';

function clientDisplayName(c: ProfessionalClient): string {
  return c.display_name || c.client_id.slice(0, 8);
}

function clientInitial(c: ProfessionalClient): string {
  if (c.display_name) return c.display_name.slice(0, 2).toUpperCase();
  return c.client_id.slice(0, 2).toUpperCase();
}

interface ClientsPanelProps {
  onSelectClient: (client: ProfessionalClient) => void;
  selectedClient: ProfessionalClient | null;
  onAddClient?: () => void;
}

export const ClientsPanel: React.FC<ClientsPanelProps> = ({ onSelectClient, selectedClient, onAddClient }) => {
  const { professional } = useAuth();
  const { data: clients = [], isLoading, refetch, isRefetching } = useClients(professional?.id);
  const { data: unreadCounts = {} } = useUnreadCounts(professional?.id);
  const [search, setSearch] = useState('');

  const filtered = useMemo(() => {
    if (!search.trim()) return clients;
    const q = search.toLowerCase();
    return clients.filter(c => {
      const name = clientDisplayName(c).toLowerCase();
      return name.includes(q) || c.client_id.toLowerCase().includes(q);
    });
  }, [clients, search]);

  if (!professional) {
    return (
      <div className="rounded-xl border bg-card p-5 text-center text-sm text-muted-foreground card-elevated">
        Save your profile first to load clients.
      </div>
    );
  }

  return (
    <div className="rounded-xl border bg-card card-elevated flex flex-col">
      {/* Header */}
      <div className="px-5 py-4 border-b flex items-center justify-between gap-4">
        <div className="flex items-center gap-2.5 min-w-0">
          <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center shrink-0">
            <Users className="w-4 h-4 text-primary" />
          </div>
          <div className="min-w-0">
            <p className="text-sm font-semibold leading-none">Clients</p>
            <p className="text-[11px] text-muted-foreground mt-0.5">
              {filtered.length}/{clients.length} connected
            </p>
          </div>
        </div>
        {onAddClient && (
          <Button onClick={onAddClient} size="sm" className="h-8 rounded-lg text-xs shrink-0">
            <UserPlus className="w-3.5 h-3.5 mr-1.5" />
            Add
          </Button>
        )}
      </div>

      {/* Search */}
      <div className="px-4 pt-3 pb-1">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-muted-foreground pointer-events-none" />
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search clients..."
            className="w-full pl-9 pr-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary"
          />
        </div>
      </div>

      {/* Client list */}
      <div className="flex-1 overflow-y-auto max-h-[360px] [scrollbar-width:thin] [scrollbar-color:rgb(200_200_200/0.3)_transparent] dark:[scrollbar-color:rgb(60_60_60/0.3)_transparent]">
        {isLoading ? (
          <div className="p-3 space-y-1">
            {[1, 2, 3].map((i) => (
              <div key={i} className="flex items-center gap-3 px-3 py-3 rounded-lg">
                <Skeleton className="w-9 h-9 rounded-full shrink-0" />
                <div className="flex-1 space-y-1.5">
                  <Skeleton className="h-3.5 w-28" />
                  <Skeleton className="h-3 w-40" />
                </div>
              </div>
            ))}
          </div>
        ) : filtered.length === 0 ? (
          <div className="px-5 py-10 text-center">
            <div className="w-12 h-12 rounded-full bg-muted/50 flex items-center justify-center mx-auto mb-3">
              <Users className="w-5 h-5 text-muted-foreground/60" />
            </div>
            <p className="text-sm text-muted-foreground">
              {search ? 'No clients match your search' : 'No clients yet'}
            </p>
            {!search && (
              <p className="text-xs text-muted-foreground/70 mt-1">Invite your first client to get started</p>
            )}
          </div>
        ) : (
          <div className="p-2">
            {filtered.map((row) => {
              const unreadCount = unreadCounts[row.id] ?? 0;
              const isSelected = selectedClient?.id === row.id;
              const snapshots = row.client_shared_snapshots || [];
              const latestSnapshot = snapshots.length > 0
                ? [...snapshots].sort((a, b) => b.snapshot_date.localeCompare(a.snapshot_date))[0]
                : null;

              return (
                <button
                  key={row.id}
                  onClick={() => onSelectClient(row)}
                  className={`w-full flex items-center gap-3 px-3 py-3 rounded-lg text-left transition-all duration-100 ${
                    isSelected
                      ? 'bg-primary/10'
                      : 'hover:bg-secondary/60'
                  }`}
                >
                  <div className={`w-9 h-9 rounded-full flex items-center justify-center text-xs font-bold shrink-0 ${
                    isSelected
                      ? 'bg-primary text-primary-foreground'
                      : 'bg-secondary text-secondary-foreground'
                  }`}>
                    {clientInitial(row)}
                  </div>

                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="text-sm font-medium truncate">
                        {clientDisplayName(row)}
                      </span>
                      {unreadCount > 0 && (
                        <span className="inline-flex items-center gap-0.5 px-1.5 py-0.5 rounded-full bg-destructive text-destructive-foreground text-[10px] font-bold shrink-0">
                          <MessageSquare className="w-2.5 h-2.5" />
                          {unreadCount}
                        </span>
                      )}
                    </div>
                    <p className="text-[11px] text-muted-foreground truncate mt-0.5">
                      {latestSnapshot
                        ? `${latestSnapshot.kcal_actual}/${latestSnapshot.kcal_target} kcal`
                        : 'No snapshots yet'
                      }
                    </p>
                  </div>

                  <ChevronRight className={`w-4 h-4 shrink-0 transition-colors ${
                    isSelected ? 'text-primary' : 'text-muted-foreground/40'
                  }`} />
                </button>
              );
            })}
          </div>
        )}
      </div>

      {/* Refresh footer */}
      {!isLoading && clients.length > 0 && (
        <div className="px-5 py-3 border-t">
          <button
            onClick={() => refetch()}
            disabled={isRefetching}
            className="text-xs text-muted-foreground hover:text-foreground transition-colors disabled:opacity-50"
          >
            {isRefetching ? 'Refreshing...' : 'Refresh list'}
          </button>
        </div>
      )}
    </div>
  );
};
