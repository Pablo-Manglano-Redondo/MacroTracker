import React, { useState } from 'react';
import { useAuth } from '../../lib/auth-context';
import { usePlans } from '../../hooks/queries/usePlans';
import { useArchivePlan, useDeletePlan, useDuplicatePlan, useBatchArchivePlans } from '../../hooks/mutations/useDeletePlan';
import type { ProfessionalClient } from '../../types/database.types';
import { Button } from '../ui/button';
import { toast } from '../../lib/toast';
import { FileText, Plus, Copy, Archive, Trash2, Loader2, LayoutList, CheckSquare, Square } from 'lucide-react';

interface PlanListProps {
  client: ProfessionalClient;
  onNewPlan: () => void;
  onEditPlan: (planId: string) => void;
}

export const PlanList: React.FC<PlanListProps> = ({ client, onNewPlan, onEditPlan }) => {
  const { professional } = useAuth();
  const { data: plans, isLoading, error } = usePlans(client.client_id);
  const archivePlan = useArchivePlan(client.client_id);
  const deletePlan = useDeletePlan(client.client_id);
  const duplicatePlan = useDuplicatePlan(client.client_id);
  const batchArchivePlans = useBatchArchivePlans(client.client_id);
  const [confirmDelete, setConfirmDelete] = useState<string | null>(null);
  const [selectMode, setSelectMode] = useState(false);
  const [selectedPlans, setSelectedPlans] = useState<Set<string>>(new Set());

  const toggleSelect = (planId: string) => {
    setSelectedPlans(prev => {
      const next = new Set(prev);
      if (next.has(planId)) next.delete(planId);
      else next.add(planId);
      return next;
    });
  };

  const toggleSelectAll = () => {
    const active = plans?.filter(p => p.status !== 'archived') ?? [];
    setSelectedPlans(prev => prev.size === active.length ? new Set() : new Set(active.map(p => p.id)));
  };

  const handleBatchArchive = async () => {
    if (selectedPlans.size === 0) return;
    try {
      await batchArchivePlans.mutateAsync(Array.from(selectedPlans));
      toast.success(`Archived ${selectedPlans.size} plan${selectedPlans.size > 1 ? 's' : ''}`);
      setSelectedPlans(new Set());
      setSelectMode(false);
    } catch {
      toast.error('Failed to archive plans');
    }
  };

  const handleDuplicate = async (planId: string) => {
    if (!professional) return;
    try {
      await duplicatePlan.mutateAsync({
        professionalId: professional.id,
        clientId: client.client_id,
        planId,
      });
      toast.success('Plan duplicated');
    } catch {
      toast.error('Failed to duplicate plan');
    }
  };

  const handleArchive = async (planId: string) => {
    try {
      await archivePlan.mutateAsync(planId);
      toast.success('Plan archived');
    } catch {
      toast.error('Failed to archive plan');
    }
  };

  const handleDelete = async (planId: string) => {
    try {
      await deletePlan.mutateAsync(planId);
      toast.success('Plan deleted');
      setConfirmDelete(null);
    } catch {
      toast.error('Failed to delete plan');
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'active':
        return <span className="inline-flex items-center px-1.5 py-0.5 rounded-full bg-emerald-50 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400 text-[10px] font-medium">Active</span>;
      case 'draft':
        return <span className="inline-flex items-center px-1.5 py-0.5 rounded-full bg-zinc-100 text-zinc-600 dark:bg-zinc-800 dark:text-zinc-400 text-[10px] font-medium">Draft</span>;
      case 'archived':
        return <span className="inline-flex items-center px-1.5 py-0.5 rounded-full bg-zinc-100 text-zinc-500 dark:bg-zinc-800 dark:text-zinc-500 text-[10px] font-medium">Archived</span>;
      default:
        return <span className="inline-flex items-center px-1.5 py-0.5 rounded-full bg-zinc-100 text-zinc-500 text-[10px] font-medium">{status}</span>;
    }
  };

  const activePlans = plans?.filter(p => p.status !== 'archived') ?? [];
  const archivedPlans = plans?.filter(p => p.status === 'archived') ?? [];

  if (isLoading) {
    return (
      <div className="rounded-xl border bg-card card-elevated p-6 flex items-center justify-center min-h-[200px]">
        <Loader2 className="w-5 h-5 animate-spin text-muted-foreground" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="rounded-xl border bg-card p-5 text-center text-sm text-destructive">
        Failed to load plans.
      </div>
    );
  }

  return (
    <div className="rounded-xl border bg-card card-elevated">
      {/* Header */}
      <div className="px-5 py-4 border-b flex items-center justify-between">
        <div className="flex items-center gap-2.5">
          <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
            <LayoutList className="w-4 h-4 text-primary" />
          </div>
          <div>
            <p className="text-sm font-semibold leading-none">Plans</p>
            <p className="text-[11px] text-muted-foreground mt-0.5">
              {activePlans.length} active
            </p>
          </div>
        </div>
        <div className="flex items-center gap-1.5">
          {selectMode ? (
            <>
              <Button
                size="sm"
                variant="ghost"
                className="h-8 rounded-lg text-xs"
                onClick={() => { setSelectMode(false); setSelectedPlans(new Set()); }}
              >
                Cancel
              </Button>
              <Button
                size="sm"
                variant="secondary"
                className="h-8 rounded-lg text-xs"
                disabled={selectedPlans.size === 0 || batchArchivePlans.isPending}
                onClick={handleBatchArchive}
              >
                {batchArchivePlans.isPending ? (
                  <Loader2 className="w-3.5 h-3.5 mr-1.5 animate-spin" />
                ) : (
                  <Archive className="w-3.5 h-3.5 mr-1.5" />
                )}
                Archive ({selectedPlans.size})
              </Button>
            </>
          ) : (
            <>
              <button
                className="p-1.5 rounded-md text-muted-foreground hover:text-foreground hover:bg-secondary transition-colors"
                onClick={() => setSelectMode(true)}
                title="Select plans"
              >
                <CheckSquare className="w-4 h-4" />
              </button>
              <Button onClick={onNewPlan} size="sm" className="h-8 rounded-lg text-xs">
                <Plus className="w-3.5 h-3.5 mr-1.5" />
                New
              </Button>
            </>
          )}
        </div>
      </div>

      {/* Content */}
      {plans && plans.length === 0 ? (
        <div className="px-5 py-10 text-center">
          <div className="w-12 h-12 rounded-full bg-muted/50 flex items-center justify-center mx-auto mb-3">
            <FileText className="w-5 h-5 text-muted-foreground/60" />
          </div>
          <p className="text-sm text-muted-foreground">No plans yet</p>
          <p className="text-xs text-muted-foreground/70 mt-1">Create a plan to set macro targets</p>
        </div>
      ) : (
        <div className="p-2">
          {selectMode && activePlans.length > 0 && (
            <div className="flex items-center gap-2 px-3 py-1.5 mb-1">
              <button
                className="p-1 rounded-md text-muted-foreground hover:text-foreground transition-colors"
                onClick={toggleSelectAll}
              >
                {selectedPlans.size === activePlans.length ? (
                  <CheckSquare className="w-4 h-4" />
                ) : (
                  <Square className="w-4 h-4" />
                )}
              </button>
              <span className="text-xs text-muted-foreground">
                {selectedPlans.size === 0
                  ? 'Select plans to batch archive'
                  : `${selectedPlans.size} of ${activePlans.length} selected`
                }
              </span>
            </div>
          )}
          {activePlans.map((plan) => (
            <div
              key={plan.id}
              className={`group flex items-center gap-3 px-3 py-3 rounded-lg transition-colors ${selectMode ? '' : 'hover:bg-secondary/60 cursor-pointer'}`}
              onClick={selectMode ? () => toggleSelect(plan.id) : () => onEditPlan(plan.id)}
            >
              {selectMode ? (
                <button
                  className="p-1 rounded-md text-muted-foreground hover:text-foreground transition-colors"
                  onClick={(e) => { e.stopPropagation(); toggleSelect(plan.id); }}
                >
                  {selectedPlans.has(plan.id) ? (
                    <CheckSquare className="w-4 h-4 text-primary" />
                  ) : (
                    <Square className="w-4 h-4" />
                  )}
                </button>
              ) : (
                <div className="w-8 h-8 rounded-lg bg-secondary flex items-center justify-center shrink-0">
                  <FileText className="w-4 h-4 text-muted-foreground" />
                </div>
              )}
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium truncate">{plan.name}</span>
                  {getStatusBadge(plan.status)}
                </div>
                <p className="text-[11px] text-muted-foreground mt-0.5">
                  {new Date(plan.created_at).toLocaleDateString()}
                </p>
              </div>
              {!selectMode && (
                <div className="flex items-center gap-0.5 shrink-0 opacity-0 group-hover:opacity-100 transition-opacity" onClick={(e) => e.stopPropagation()}>
                  <button
                    className="p-1.5 rounded-md text-muted-foreground hover:text-foreground hover:bg-secondary transition-colors"
                    onClick={() => handleDuplicate(plan.id)}
                    title="Duplicate"
                  >
                    <Copy className="w-3.5 h-3.5" />
                  </button>
                  <button
                    className="p-1.5 rounded-md text-muted-foreground hover:text-amber-600 hover:bg-secondary transition-colors"
                    onClick={() => handleArchive(plan.id)}
                    title="Archive"
                  >
                    <Archive className="w-3.5 h-3.5" />
                  </button>
                  {confirmDelete === plan.id ? (
                    <div className="flex items-center gap-1 ml-1">
                      <button
                        className="p-1.5 rounded-md text-destructive hover:bg-destructive/10 transition-colors"
                        onClick={() => handleDelete(plan.id)}
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                      <button
                        className="p-1.5 rounded-md text-muted-foreground hover:bg-secondary transition-colors"
                        onClick={() => setConfirmDelete(null)}
                      >
                        Cancel
                      </button>
                    </div>
                  ) : (
                    <button
                      className="p-1.5 rounded-md text-muted-foreground hover:text-destructive hover:bg-secondary transition-colors"
                      onClick={() => setConfirmDelete(plan.id)}
                      title="Delete"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  )}
                </div>
              )}
            </div>
          ))}

          {/* Archived */}
          {archivedPlans.length > 0 && (
            <details className="group">
              <summary className="px-3 py-2 text-xs text-muted-foreground cursor-pointer hover:text-foreground transition-colors select-none">
                Archived ({archivedPlans.length})
              </summary>
              <div className="mt-1">
                {archivedPlans.map((plan) => (
                  <div
                    key={plan.id}
                    className="flex items-center gap-3 px-3 py-2.5 rounded-lg opacity-60 hover:opacity-100 transition-opacity"
                  >
                    <FileText className="w-4 h-4 text-muted-foreground shrink-0" />
                    <span className="text-sm text-muted-foreground truncate flex-1">{plan.name}</span>
                    {getStatusBadge(plan.status)}
                    <button
                      className="p-1 rounded-md text-muted-foreground hover:text-destructive transition-colors"
                      onClick={() => handleDelete(plan.id)}
                    >
                      <Trash2 className="w-3 h-3" />
                    </button>
                  </div>
                ))}
              </div>
            </details>
          )}
        </div>
      )}
    </div>
  );
};
