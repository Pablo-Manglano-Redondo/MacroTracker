import { type SupabaseClient } from '@supabase/supabase-js';

export interface RosterAnalytics {
  totalClients: number;
  activeClients: number;
  revokedClients: number;
  clientLimit: number;
  activePlans: number;
  totalPlans: number;
}

export interface AdherenceTrend {
  date: string;
  kcalAdherence: number;
  proteinAdherence: number;
  carbsAdherence: number;
  fatAdherence: number;
}

export interface ClientAdherence {
  clientId: string;
  name: string;
  snapshotCount: number;
  avgKcalAdherence: number;
  latestDate: string | null;
}

export const analyticsRepository = {
  getRosterStats: async (supabase: SupabaseClient, professionalId: string): Promise<RosterAnalytics> => {
    const { data: prof } = await supabase
      .from('professionals')
      .select('client_limit')
      .eq('id', professionalId)
      .single();

    const { data: statusCounts } = await supabase
      .from('professional_clients')
      .select('status')
      .eq('professional_id', professionalId);

    const { count: activePlans } = await supabase
      .from('nutrition_plans')
      .select('id', { count: 'exact', head: true })
      .eq('professional_id', professionalId)
      .eq('status', 'active');

    const { count: totalPlans } = await supabase
      .from('nutrition_plans')
      .select('id', { count: 'exact', head: true })
      .eq('professional_id', professionalId);

    const allClients = statusCounts ?? [];
    return {
      totalClients: allClients.length,
      activeClients: allClients.filter(c => c.status === 'connected').length,
      revokedClients: allClients.filter(c => c.status === 'revoked').length,
      clientLimit: (prof as { client_limit: number } | null)?.client_limit ?? 10,
      activePlans: activePlans ?? 0,
      totalPlans: totalPlans ?? 0,
    };
  },

  getAdherenceTrends: async (supabase: SupabaseClient, professionalId: string): Promise<AdherenceTrend[]> => {
    const { data, error } = await supabase
      .from('client_shared_snapshots')
      .select('snapshot_date, kcal_actual, kcal_target, protein_actual, protein_target, carbs_actual, carbs_target, fat_actual, fat_target')
      .eq('professional_id', professionalId)
      .order('snapshot_date', { ascending: true })
      .limit(90);

    if (error) throw error;

    const dateMap = new Map<string, {
      kcalRatio: number; proteinRatio: number; carbsRatio: number; fatRatio: number; count: number;
    }>();

    for (const snap of data ?? []) {
      const existing = dateMap.get(snap.snapshot_date) ?? {
        kcalRatio: 0, proteinRatio: 0, carbsRatio: 0, fatRatio: 0, count: 0,
      };
      existing.kcalRatio += snap.kcal_target > 0 ? snap.kcal_actual / snap.kcal_target : 0;
      existing.proteinRatio += snap.protein_target > 0 ? snap.protein_actual / snap.protein_target : 0;
      existing.carbsRatio += snap.carbs_target > 0 ? snap.carbs_actual / snap.carbs_target : 0;
      existing.fatRatio += snap.fat_target > 0 ? snap.fat_actual / snap.fat_target : 0;
      existing.count += 1;
      dateMap.set(snap.snapshot_date, existing);
    }

    return Array.from(dateMap.entries()).map(([date, stats]) => ({
      date,
      kcalAdherence: stats.count > 0 ? Math.round((stats.kcalRatio / stats.count) * 100) : 0,
      proteinAdherence: stats.count > 0 ? Math.round((stats.proteinRatio / stats.count) * 100) : 0,
      carbsAdherence: stats.count > 0 ? Math.round((stats.carbsRatio / stats.count) * 100) : 0,
      fatAdherence: stats.count > 0 ? Math.round((stats.fatRatio / stats.count) * 100) : 0,
    }));
  },

  getPerClientAdherence: async (supabase: SupabaseClient, professionalId: string): Promise<ClientAdherence[]> => {
    const { data: clients } = await supabase
      .from('professional_clients')
      .select('client_id, display_name')
      .eq('professional_id', professionalId)
      .eq('status', 'connected');

    if (!clients || clients.length === 0) return [];

    const clientIds = clients.map(c => c.client_id);
    const nameMap = new Map<string, string>(
      clients.map((client) => [
        client.client_id,
        client.display_name || client.client_id.slice(0, 8),
      ]),
    );

    const { data: snapshots } = await supabase
      .from('client_shared_snapshots')
      .select('client_id, snapshot_date, kcal_actual, kcal_target')
      .in('client_id', clientIds)
      .order('snapshot_date', { ascending: false });

    const clientMap = new Map<string, { sumRatio: number; count: number; latestDate: string | null }>();

    for (const snap of snapshots ?? []) {
      const existing = clientMap.get(snap.client_id) ?? { sumRatio: 0, count: 0, latestDate: null as string | null };
      if (snap.kcal_target > 0) {
        existing.sumRatio += snap.kcal_actual / snap.kcal_target;
        existing.count += 1;
      }
      if (!existing.latestDate || snap.snapshot_date > existing.latestDate) {
        existing.latestDate = snap.snapshot_date;
      }
      clientMap.set(snap.client_id, existing);
    }

    return Array.from(clientMap.entries()).map(([clientId, stats]) => ({
      clientId,
      name: nameMap.get(clientId) ?? clientId.slice(0, 8),
      snapshotCount: stats.count,
      avgKcalAdherence: stats.count > 0 ? Math.round((stats.sumRatio / stats.count) * 100) : 0,
      latestDate: stats.latestDate,
    })).sort((a, b) => b.snapshotCount - a.snapshotCount);
  },

  getRevenueEstimate: (professional: { pro_status?: string } | null): { tier: string; amount: string } => {
    if (!professional?.pro_status || professional.pro_status === 'inactive' || professional.pro_status === 'canceled') {
      return { tier: 'Inactive', amount: '$0/mo' };
    }
    return { tier: professional.pro_status, amount: 'Active' };
  },
};
