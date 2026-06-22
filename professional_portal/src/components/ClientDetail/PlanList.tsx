import React, { useState } from 'react';
import {
  Archive,
  CheckSquare,
  Copy,
  FileText,
  LayoutList,
  Loader2,
  Plus,
  Square,
  Trash2,
} from 'lucide-react';
import { useAuth } from '../../lib/auth-context';
import { usePlans } from '../../hooks/queries/usePlans';
import {
  useArchivePlan,
  useBatchArchivePlans,
  useDeletePlan,
  useDuplicatePlan,
} from '../../hooks/mutations/useDeletePlan';
import type { ProfessionalClient } from '../../types/database.types';
import { formatPortalDate } from '../../lib/date';
import { Button } from '../ui/button';
import { toast } from '../../lib/toast';
import { getBillingSummary } from '../../view-models/professional';
import { getRelationshipStatusLabel } from '../../view-models/clients';
import { usePortalI18n } from '../../lib/portal-i18n';

interface PlanListProps {
  client: ProfessionalClient;
  onNewPlan: () => void;
  onEditPlan: (planId: string) => void;
}

export const PlanList: React.FC<PlanListProps> = ({ client, onNewPlan, onEditPlan }) => {
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();
  const billingSummary = getBillingSummary(professional);
  const { data: plans, isLoading, error } = usePlans(client.client_id, client.professional_id);
  const archivePlan = useArchivePlan();
  const deletePlan = useDeletePlan();
  const duplicatePlan = useDuplicatePlan();
  const batchArchivePlans = useBatchArchivePlans();
  const [confirmDelete, setConfirmDelete] = useState<string | null>(null);
  const [selectMode, setSelectMode] = useState(false);
  const [selectedPlans, setSelectedPlans] = useState<Set<string>>(new Set());

  const canManagePlans = billingSummary.hasProfessionalAccess && client.status === 'connected';

  const toggleSelect = (planId: string) => {
    setSelectedPlans((prev) => {
      const next = new Set(prev);
      if (next.has(planId)) next.delete(planId);
      else next.add(planId);
      return next;
    });
  };

  const activePlans = plans?.filter((plan) => plan.status !== 'archived') ?? [];
  const archivedPlans = plans?.filter((plan) => plan.status === 'archived') ?? [];

  const toggleSelectAll = () => {
    setSelectedPlans((prev) =>
      prev.size === activePlans.length ? new Set() : new Set(activePlans.map((plan) => plan.id)),
    );
  };

  const handleBatchArchive = async () => {
    if (selectedPlans.size === 0) return;
    try {
      await batchArchivePlans.mutateAsync(Array.from(selectedPlans));
      toast.success(
        t('components.clientdetail.planlist.archived_plans', { selectedplans_size: selectedPlans.size }),
      );
      setSelectedPlans(new Set());
      setSelectMode(false);
    } catch {
      toast.error(t('components.clientdetail.planlist.failed_to_archive_plans'));
    }
  };

  const handleDuplicate = async (planId: string) => {
    if (!professional || !canManagePlans) return;
    try {
      await duplicatePlan.mutateAsync({
        professionalId: professional.id,
        clientId: client.client_id,
        planId,
      });
      toast.success(t('components.clientdetail.planlist.plan_duplicated'));
    } catch {
      toast.error(t('components.clientdetail.planlist.failed_to_duplicate_plan'));
    }
  };

  const handleArchive = async (planId: string) => {
    if (!canManagePlans) return;
    try {
      await archivePlan.mutateAsync(planId);
      toast.success(t('components.clientdetail.planlist.plan_archived'));
    } catch {
      toast.error(t('components.clientdetail.planlist.failed_to_archive_plan'));
    }
  };

  const handleDelete = async (planId: string) => {
    if (!canManagePlans) return;
    try {
      await deletePlan.mutateAsync(planId);
      toast.success(t('components.clientdetail.planlist.plan_deleted'));
      setConfirmDelete(null);
    } catch {
      toast.error(t('components.clientdetail.planlist.failed_to_delete_plan'));
    }
  };

  const statusLabel = (status: string) =>
    ({
      active: t('components.clientdetail.planlist.active'),
      draft: t('components.clientdetail.planlist.draft'),
      archived: t('components.clientdetail.planlist.archived'),
    })[status] ?? status;

  if (isLoading) {
    return (
      <div className="portal-panel flex min-h-[220px] items-center justify-center rounded-[1.6rem]">
        <Loader2 className="h-5 w-5 animate-spin text-primary" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="portal-panel rounded-[1.6rem] p-5 text-center text-sm text-muted-foreground">
        {t('components.clientdetail.planlist.failed_to_load_plans')}
      </div>
    );
  }

  return (
    <div className="portal-panel rounded-[1.6rem]">
      <div className="flex items-center justify-between border-b border-border px-5 py-4">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/12 text-primary">
            <LayoutList className="h-5 w-5" />
          </div>
          <div>
            <h3 className="text-base font-bold text-foreground">{t('components.clientdetail.planlist.plans')}</h3>
            <p className="text-sm text-muted-foreground">
              {t('components.clientdetail.planlist.non_archived', { activeplans_length: activePlans.length })}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {selectMode ? (
            <>
              <Button
                size="sm"
                variant="ghost"
                className="h-9 rounded-xl text-sm font-semibold"
                onClick={() => {
                  setSelectMode(false);
                  setSelectedPlans(new Set());
                }}
              >
                {t('components.clientdetail.planlist.cancel')}
              </Button>
              <Button
                size="sm"
                variant="secondary"
                className="h-9 rounded-xl text-sm font-semibold"
                disabled={selectedPlans.size === 0 || batchArchivePlans.isPending}
                onClick={handleBatchArchive}
              >
                {batchArchivePlans.isPending ? (
                  <Loader2 className="mr-1.5 h-3.5 w-3.5 animate-spin" />
                ) : (
                  <Archive className="mr-1.5 h-3.5 w-3.5" />
                )}
                {t('components.clientdetail.planlist.archive')} ({selectedPlans.size})
              </Button>
            </>
          ) : (
            <>
              <button
                className="rounded-xl p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                onClick={() => setSelectMode(true)}
                disabled={!canManagePlans}
                title={t('components.clientdetail.planlist.select_plans')}
              >
                <CheckSquare className="h-4 w-4" />
              </button>
              <Button
                onClick={onNewPlan}
                size="sm"
                disabled={!canManagePlans}
                className="h-9 rounded-xl bg-primary text-sm font-bold text-primary-foreground"
              >
                <Plus className="mr-1.5 h-3.5 w-3.5" />
                {t('components.clientdetail.planlist.new')}
              </Button>
            </>
          )}
        </div>
      </div>

      {!canManagePlans && (
        <div className="mx-5 mt-4 rounded-xl border border-amber-500/25 bg-amber-500/10 p-4 text-sm text-amber-900 dark:text-amber-100">
          {client.status !== 'connected'
            ? t('components.clientdetail.planlist.plan_actions_are_disabled_because_this_relationship_is', { status_tolowercase: getRelationshipStatusLabel(client.status, t).toLowerCase() })
            : t('components.clientdetail.planlist.plan_actions_are_disabled_until_professional_access_returns_to_active_or')}
        </div>
      )}

      {plans && plans.length === 0 ? (
        <div className="px-5 py-10 text-center">
          <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-xl bg-background text-muted-foreground">
            <FileText className="h-5 w-5" />
          </div>
          <p className="mt-3 text-sm font-bold text-foreground">{t('components.clientdetail.planlist.no_plans_yet')}</p>
          <p className="mt-1 text-sm text-muted-foreground">
            {t('components.clientdetail.planlist.create_a_plan_to_define_weekly_nutrition_targets')}
          </p>
        </div>
      ) : (
        <div className="p-2">
          {selectMode && activePlans.length > 0 && (
            <div className="mb-1 flex items-center gap-2 px-3 py-2">
              <button
                className="rounded-lg p-1 text-muted-foreground transition-colors hover:text-foreground"
                onClick={toggleSelectAll}
              >
                {selectedPlans.size === activePlans.length ? (
                  <CheckSquare className="h-4 w-4 text-primary" />
                ) : (
                  <Square className="h-4 w-4" />
                )}
              </button>
              <span className="text-xs font-semibold text-muted-foreground">
                {selectedPlans.size === 0
                  ? t('components.clientdetail.planlist.select_plans_to_batch_archive')
                  : t('components.clientdetail.planlist.of_selected', { selectedplans_size: selectedPlans.size, activeplans_length: activePlans.length })}
              </span>
            </div>
          )}

          <div className="space-y-1">
            {activePlans.map((plan) => (
              <div
                key={plan.id}
                className={`group flex items-center gap-3 rounded-2xl px-3 py-3 transition-colors ${
                  selectMode ? '' : 'cursor-pointer hover:bg-accent'
                }`}
                onClick={selectMode ? () => toggleSelect(plan.id) : () => onEditPlan(plan.id)}
              >
                {selectMode ? (
                  <button
                    className="rounded-lg p-1 text-muted-foreground transition-colors hover:text-foreground"
                    onClick={(e) => {
                      e.stopPropagation();
                      toggleSelect(plan.id);
                    }}
                  >
                    {selectedPlans.has(plan.id) ? (
                      <CheckSquare className="h-4 w-4 text-primary" />
                    ) : (
                      <Square className="h-4 w-4" />
                    )}
                  </button>
                ) : (
                  <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-background text-muted-foreground">
                    <FileText className="h-4 w-4" />
                  </div>
                )}

                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-2">
                    <span className="truncate text-sm font-bold text-foreground">{plan.name}</span>
                    <span className="rounded-full bg-primary/10 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
                      {statusLabel(plan.status)}
                    </span>
                  </div>
                  <p className="mt-1 text-[11px] font-semibold text-muted-foreground">
                    {formatPortalDate(plan.created_at, locale)}
                  </p>
                </div>

                {!selectMode ? (
                  <div
                    className="flex items-center gap-1 opacity-0 transition-opacity group-hover:opacity-100"
                    onClick={(e) => e.stopPropagation()}
                  >
                    <IconAction title={t('components.clientdetail.planlist.duplicate')} onClick={() => handleDuplicate(plan.id)}>
                      <Copy className="h-3.5 w-3.5" />
                    </IconAction>
                    <IconAction title={t('components.clientdetail.planlist.archive')} onClick={() => handleArchive(plan.id)}>
                      <Archive className="h-3.5 w-3.5" />
                    </IconAction>
                    {confirmDelete === plan.id ? (
                      <div className="ml-1 flex items-center gap-1">
                        <IconAction title={t('components.clientdetail.planlist.confirm')} onClick={() => handleDelete(plan.id)} danger>
                          <Trash2 className="h-3.5 w-3.5" />
                        </IconAction>
                        <button
                          className="rounded-lg px-2 py-1 text-[10px] font-bold text-muted-foreground hover:bg-accent"
                          onClick={() => setConfirmDelete(null)}
                        >
                          {t('components.clientdetail.planlist.cancel')}
                        </button>
                      </div>
                    ) : (
                      <IconAction title={t('components.clientdetail.planlist.delete')} onClick={() => setConfirmDelete(plan.id)} danger>
                        <Trash2 className="h-3.5 w-3.5" />
                      </IconAction>
                    )}
                  </div>
                ) : null}
              </div>
            ))}

            {archivedPlans.length > 0 && (
              <details className="group mt-2">
                <summary className="cursor-pointer px-3 py-2 text-xs font-bold text-muted-foreground transition-colors hover:text-foreground">
                  {t('components.clientdetail.planlist.archived_2', { archivedplans_length: archivedPlans.length })}
                </summary>
                <div className="mt-1 space-y-1">
                  {archivedPlans.map((plan) => (
                    <div
                      key={plan.id}
                      className="flex items-center gap-3 rounded-xl bg-background/70 px-3 py-2 opacity-75 transition-opacity hover:opacity-100"
                    >
                      <FileText className="h-4 w-4 shrink-0 text-muted-foreground" />
                      <span className="flex-1 truncate text-sm font-semibold text-muted-foreground">{plan.name}</span>
                      <span className="rounded-full bg-background px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                        {statusLabel(plan.status)}
                      </span>
                      <IconAction title={t('components.clientdetail.planlist.delete')} onClick={() => handleDelete(plan.id)} danger>
                        <Trash2 className="h-3.5 w-3.5" />
                      </IconAction>
                    </div>
                  ))}
                </div>
              </details>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

const IconAction: React.FC<{
  title: string;
  onClick: () => void;
  danger?: boolean;
  children: React.ReactNode;
}> = ({ title, onClick, danger = false, children }) => (
  <button
    className={`rounded-lg p-1.5 transition-colors ${
      danger
        ? 'text-muted-foreground hover:bg-rose-500/10 hover:text-rose-500'
        : 'text-muted-foreground hover:bg-accent hover:text-foreground'
    }`}
    onClick={onClick}
    title={title}
  >
    {children}
  </button>
);
