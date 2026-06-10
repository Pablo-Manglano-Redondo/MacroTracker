import React, { useMemo, useState } from 'react';
import { useAuth } from '../lib/auth-context';
import { useRosterStats, useAdherenceTrends, usePerClientAdherence } from '../hooks/queries/useAnalytics';
import type { AdherenceTrend } from '../repositories/analytics.repository';
import { Skeleton } from './ui/skeleton';
import { toast } from 'sonner';
import { Users, FileText, TrendingUp, AlertCircle, DollarSign, UserCheck, LayoutDashboard, Calendar, Download } from 'lucide-react';
import { downloadCsv } from '../lib/csv';

const RANGE_PRESETS = [
  { label: '7d', days: 7 },
  { label: '30d', days: 30 },
  { label: '90d', days: 90 },
  { label: 'All', days: 0 },
] as const;

export const DashboardPanel: React.FC = () => {
  const { professional } = useAuth();
  const { data: roster, isLoading: rosterLoading } = useRosterStats(professional?.id);
  const { data: trends, isLoading: trendsLoading } = useAdherenceTrends(professional?.id);
  const { data: clientAdherence = [], isLoading: clientsLoading } = usePerClientAdherence(professional?.id);
  const [rangeDays, setRangeDays] = useState(30);
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');

  const cutoffDate = useMemo(() => {
    if (startDate && endDate) return { start: startDate, end: endDate } as { start: string; end: string };
    if (rangeDays === 0) return null;
    const d = new Date();
    d.setDate(d.getDate() - rangeDays);
    return { start: d.toISOString().split('T')[0], end: new Date().toISOString().split('T')[0] };
  }, [rangeDays, startDate, endDate]) as { start: string; end: string } | null;

  if (!professional) {
    return (
      <div className="rounded-xl border bg-card p-8 text-center text-sm text-muted-foreground card-elevated">
        Save your profile first to view analytics.
      </div>
    );
  }

  const filteredTrends: AdherenceTrend[] = useMemo(() => {
    if (!trends) return [];
    if (!cutoffDate) return trends;
    return trends.filter(t => t.date >= cutoffDate.start && t.date <= cutoffDate.end);
  }, [trends, cutoffDate]);

  const avgAdherence = filteredTrends.length > 0
    ? Math.round(filteredTrends.reduce((sum: number, t: { kcalAdherence: number }) => sum + t.kcalAdherence, 0) / filteredTrends.length)
    : null;

  const revenueInfo = useMemo(() => {
    const status = professional.pro_status;
    if (!status || status === 'inactive' || status === 'canceled') {
      return { tier: 'Free', amount: '$0' };
    }
    if (status === 'trialing') return { tier: 'Trial', amount: '$0' };
    const tiers: Record<string, { name: string; price: string }> = {
      starter: { name: 'Starter', price: '$29' },
      growth: { name: 'Growth', price: '$79' },
      studio: { name: 'Studio', price: '$199' },
    };
    const t = tiers[status];
    return { tier: t?.name || status, amount: t?.price || 'Active' };
  }, [professional.pro_status]);

  const handleExportCsv = () => {
    const headers = ['Date', 'Kcal Adherence %', 'Protein Adherence %', 'Carbs Adherence %', 'Fat Adherence %'];
    const rows = filteredTrends.map(t => [t.date, t.kcalAdherence, t.proteinAdherence, t.carbsAdherence, t.fatAdherence]);
    downloadCsv(`dashboard-adherence-${new Date().toISOString().split('T')[0]}.csv`, headers, rows);
    toast.success('CSV exported');
  };

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
            <LayoutDashboard className="w-4 h-4 text-primary" />
          </div>
          <div>
            <h2 className="text-lg font-bold">Dashboard</h2>
            <p className="text-xs text-muted-foreground">Practice overview</p>
          </div>
        </div>
        {filteredTrends.length > 0 && (
          <button onClick={handleExportCsv}
            className="flex items-center gap-1.5 px-3 py-1.5 text-xs rounded-lg border hover:bg-secondary transition-colors">
            <Download className="w-3.5 h-3.5" /> Export CSV
          </button>
        )}
      </div>

      {/* Stat cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {/* Roster */}
        <div className="rounded-xl border bg-card p-4 card-elevated">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs text-muted-foreground font-medium">Roster</span>
            <Users className="w-4 h-4 text-muted-foreground/50" />
          </div>
          {rosterLoading ? (
            <div className="space-y-1.5"><Skeleton className="h-7 w-16" /><Skeleton className="h-3 w-20" /></div>
          ) : (
            <>
              <p className="text-2xl font-bold">{roster?.activeClients ?? 0}</p>
              <p className="text-[11px] text-muted-foreground mt-0.5">
                {roster?.clientLimit ?? 10} limit
              </p>
            </>
          )}
        </div>

        {/* Plans */}
        <div className="rounded-xl border bg-card p-4 card-elevated">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs text-muted-foreground font-medium">Plans</span>
            <FileText className="w-4 h-4 text-muted-foreground/50" />
          </div>
          {rosterLoading ? (
            <div className="space-y-1.5"><Skeleton className="h-7 w-12" /><Skeleton className="h-3 w-16" /></div>
          ) : (
            <>
              <p className="text-2xl font-bold">{roster?.activePlans ?? 0}</p>
              <p className="text-[11px] text-muted-foreground mt-0.5">
                {roster?.totalPlans ?? 0} total
              </p>
            </>
          )}
        </div>

        {/* Adherence */}
        <div className="rounded-xl border bg-card p-4 card-elevated">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs text-muted-foreground font-medium">Adherence</span>
            <TrendingUp className="w-4 h-4 text-muted-foreground/50" />
          </div>
          {trendsLoading ? (
            <div className="space-y-1.5"><Skeleton className="h-7 w-16" /><Skeleton className="h-3 w-20" /></div>
          ) : avgAdherence !== null ? (
            <>
              <p className="text-2xl font-bold">{avgAdherence}%</p>
              <p className={`text-[11px] font-medium ${
                avgAdherence >= 85 ? 'text-emerald-600' : avgAdherence >= 70 ? 'text-amber-600' : 'text-rose-600'
              }`}>
                {avgAdherence >= 85 ? 'Good' : avgAdherence >= 70 ? 'Fair' : 'Needs work'}
              </p>
            </>
          ) : (
            <>
              <p className="text-2xl font-bold text-muted-foreground/30">--</p>
              <p className="text-[11px] text-muted-foreground">No data</p>
            </>
          )}
        </div>

        {/* Revenue */}
        <div className="rounded-xl border bg-card p-4 card-elevated">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs text-muted-foreground font-medium">Revenue</span>
            <DollarSign className="w-4 h-4 text-muted-foreground/50" />
          </div>
          <p className="text-2xl font-bold">{revenueInfo.amount}</p>
          <p className="text-[11px] text-muted-foreground mt-0.5">{revenueInfo.tier}</p>
        </div>
      </div>

      {/* Date Range Filter */}
      <div className="flex items-center gap-3 flex-wrap">
        <div className="flex items-center gap-1">
          <Calendar className="w-3.5 h-3.5 text-muted-foreground" />
          <span className="text-xs text-muted-foreground font-medium">Range:</span>
        </div>
        <div className="flex gap-1">
          {RANGE_PRESETS.map(p => (
            <button key={p.label} onClick={() => { setRangeDays(p.days); setStartDate(''); setEndDate(''); }}
              className={`px-2.5 py-1 text-[11px] font-medium rounded-md transition-colors ${
                rangeDays === p.days && !startDate
                  ? 'bg-primary text-primary-foreground'
                  : 'bg-secondary text-muted-foreground hover:text-foreground'
              }`}>
              {p.label}
            </button>
          ))}
        </div>
        <div className="flex items-center gap-2 ml-auto">
          <input type="date" value={startDate} onChange={e => { setStartDate(e.target.value); setRangeDays(0); }}
            className="px-2 py-1 text-[11px] rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
          <span className="text-[10px] text-muted-foreground">—</span>
          <input type="date" value={endDate} onChange={e => { setEndDate(e.target.value); setRangeDays(0); }}
            className="px-2 py-1 text-[11px] rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
        </div>
        {cutoffDate && (
          <span className="text-[10px] text-muted-foreground">
            {filteredTrends.length} days of data
          </span>
        )}
      </div>

      {/* Chart */}
      {trendsLoading ? (
        <div className="rounded-xl border bg-card p-5 card-elevated">
          <Skeleton className="h-4 w-32 mb-4" />
          <div className="flex items-end gap-1.5 h-20">
            {[1, 2, 3, 4, 5, 6, 7].map((i) => (
              <Skeleton key={i} className="flex-1 h-full rounded-t" />
            ))}
          </div>
        </div>
      ) : filteredTrends.length > 0 && (
        <div className="rounded-xl border bg-card p-5 card-elevated">
          <div className="flex items-center justify-between mb-4">
            <p className="text-xs font-semibold text-muted-foreground">
              {cutoffDate ? `${rangeDays || 'Custom'} day trend` : 'All-time trend'}
            </p>
            <p className="text-[10px] text-muted-foreground">
              {filteredTrends.length} data points
            </p>
          </div>
          <div className="flex items-end gap-1.5 h-20">
            {filteredTrends.map((day: AdherenceTrend) => (
              <div key={day.date} className="flex-1 flex flex-col items-center gap-1">
                <div
                  className={`w-full rounded-t ${
                    day.kcalAdherence >= 85 ? 'bg-emerald-400' : day.kcalAdherence >= 70 ? 'bg-amber-400' : 'bg-rose-400'
                  }`}
                  style={{ height: `${Math.max(day.kcalAdherence, 5)}%` }}
                  title={`${day.date}: ${day.kcalAdherence}%`}
                />
                <span className="text-[9px] text-muted-foreground/70">
                  {new Date(day.date).toLocaleDateString(undefined, { weekday: 'short' }).slice(0, 2)}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Per-client adherence */}
      {clientsLoading ? (
        <div className="rounded-xl border bg-card p-5 card-elevated">
          <Skeleton className="h-4 w-40 mb-4" />
          <div className="space-y-3">
            {[1, 2, 3].map((i) => (
              <div key={i} className="flex items-center justify-between">
                <Skeleton className="h-3.5 w-32" />
                <Skeleton className="h-3.5 w-16" />
              </div>
            ))}
          </div>
        </div>
      ) : clientAdherence.length > 0 && (
        <div className="rounded-xl border bg-card card-elevated">
          <div className="px-5 py-4 border-b flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
              <UserCheck className="w-4 h-4 text-primary" />
            </div>
            <div>
              <p className="text-sm font-semibold leading-none">Client Adherence</p>
              <p className="text-[11px] text-muted-foreground mt-0.5">{clientAdherence.length} clients</p>
            </div>
          </div>
          <div className="p-2">
            {clientAdherence.map((c) => (
              <div key={c.clientId} className="flex items-center justify-between px-3 py-2.5 rounded-lg hover:bg-secondary/50 transition-colors">
                <div className="flex items-center gap-2.5 min-w-0">
                  <div className="w-7 h-7 rounded-full bg-secondary flex items-center justify-center text-[10px] font-bold text-secondary-foreground shrink-0">
                    {c.name.slice(0, 2).toUpperCase()}
                  </div>
                  <span className="text-sm font-medium truncate">{c.name}</span>
                </div>
                <div className="flex items-center gap-3 shrink-0">
                  <span className="text-[11px] text-muted-foreground">{c.snapshotCount} snaps</span>
                  <span className={`text-xs font-semibold px-2 py-0.5 rounded-full ${
                    c.avgKcalAdherence >= 85 ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400'
                    : c.avgKcalAdherence >= 70 ? 'bg-amber-50 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400'
                    : 'bg-rose-50 text-rose-700 dark:bg-rose-900/30 dark:text-rose-400'
                  }`}>
                    {c.avgKcalAdherence}%
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Empty state */}
      {!rosterLoading && roster && roster.totalClients === 0 && (
        <div className="rounded-xl border border-dashed bg-card/50 p-8 text-center">
          <AlertCircle className="w-8 h-8 text-muted-foreground/30 mx-auto mb-3" />
          <p className="text-sm font-medium text-foreground mb-1">Welcome</p>
          <p className="text-xs text-muted-foreground max-w-xs mx-auto">
            Add your first client to see analytics and adherence data here.
          </p>
        </div>
      )}
    </div>
  );
};
