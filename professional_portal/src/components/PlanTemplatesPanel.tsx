import React, { useMemo, useState } from 'react';
import { createPortal } from 'react-dom';
import { ClipboardCopy, Layers, Plus, Target, Trash2, UserCheck, X } from 'lucide-react';
import { useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import { useAuth } from '../lib/auth-context';
import { usePlanTemplates } from '../hooks/queries/usePlanTemplates';
import { useClients } from '../hooks/queries/useClients';
import { planTemplateRepository } from '../repositories/plan-template.repository';
import { supabase } from '../lib/supabase';
import { ConfirmDialog } from './ui/confirm-dialog';
import { usePortalI18n } from '../lib/portal-i18n';

export const PlanTemplatesPanel: React.FC = () => {
  const { professional } = useAuth();
  const { t } = usePortalI18n();
  const queryClient = useQueryClient();
  const { data: templates, isLoading } = usePlanTemplates(professional?.id);
  const { data: clients } = useClients(professional?.id);
  const [showForm, setShowForm] = useState(false);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [durationDays, setDurationDays] = useState(7);
  const [objective, setObjective] = useState('general_fitness');
  const [templateKcal, setTemplateKcal] = useState(2200);
  const [templateProtein, setTemplateProtein] = useState(160);
  const [templateCarbs, setTemplateCarbs] = useState(250);
  const [templateFat, setTemplateFat] = useState(70);
  const [deleteConfirm, setDeleteConfirm] = useState<string | null>(null);
  const [applyTarget, setApplyTarget] = useState<{ templateId: string; templateName: string } | null>(null);
  const [applyClientId, setApplyClientId] = useState('');
  const macroCards = [
    { label: t('common.kcal'), shortLabel: t('common.kcal'), value: templateKcal, set: setTemplateKcal, suffix: undefined, tone: 'rose' as const },
    { label: t('common.protein'), shortLabel: t('common.protein_short'), value: templateProtein, set: setTemplateProtein, suffix: t('common.grams_unit'), tone: 'emerald' as const },
    { label: t('common.carbs'), shortLabel: t('common.carbs_short'), value: templateCarbs, set: setTemplateCarbs, suffix: t('common.grams_unit'), tone: 'blue' as const },
    { label: t('common.fat'), shortLabel: t('common.fat_short'), value: templateFat, set: setTemplateFat, suffix: t('common.grams_unit'), tone: 'amber' as const },
  ];

  const totalTemplates = templates?.length ?? 0;
  const connectedClients = useMemo(
    () => (clients || []).filter((client) => client.status === 'connected'),
    [clients],
  );

  const handleCreate = async () => {
    if (!name.trim() || !professional) {
      return;
    }
    try {
      const meals = [
        {
          kcal: templateKcal,
          protein: templateProtein,
          carbs: templateCarbs,
          fat: templateFat,
        },
      ];
      await planTemplateRepository.create(supabase, {
        professional_id: professional.id,
        name: name.trim(),
        description: description.trim() || null,
        duration_days: durationDays,
        objective,
        meals,
      });
      queryClient.invalidateQueries({ queryKey: ['plan-templates', professional.id] });
      toast.success(t('components.plantemplatespanel.template_created'));
      setShowForm(false);
      setName('');
      setDescription('');
    } catch {
      toast.error(t('components.plantemplatespanel.failed_to_create_template'));
    }
  };

  const handleDelete = async (id: string) => {
    if (!professional) {
      return;
    }
    try {
      await planTemplateRepository.remove(supabase, id);
      queryClient.invalidateQueries({ queryKey: ['plan-templates', professional.id] });
      toast.success(t('components.plantemplatespanel.template_deleted'));
      setDeleteConfirm(null);
    } catch {
      toast.error(t('components.plantemplatespanel.failed_to_delete_template'));
    }
  };

  const handleApplyTemplate = async () => {
    if (!applyTarget || !applyClientId || !professional) {
      return;
    }
    const client = clients?.find((c) => c.client_id === applyClientId);
    if (!client) {
      toast.error(t('components.plantemplatespanel.select_a_client'));
      return;
    }

    const template = templates?.find((t) => t.id === applyTarget.templateId);
    if (!template) {
      toast.error(t('components.plantemplatespanel.template_not_found'));
      return;
    }

    sessionStorage.setItem(
      'apply-template',
      JSON.stringify({
        name: template.name,
        meals: template.meals || [],
      }),
    );

    window.location.hash = 'clients-panel';
    window.dispatchEvent(new CustomEvent('select-client', { detail: client.id }));

    try {
      await planTemplateRepository.incrementUse(supabase, applyTarget.templateId);
    } catch {}

    toast.success(
      t('components.plantemplatespanel.template_queued_for_review_in_plan_builder', { template_name: template.name }),
    );
    setApplyTarget(null);
    setApplyClientId('');
  };

  const objectiveLabel = (value: string) =>
    ({
      general_fitness: t('components.plantemplatespanel.general_fitness'),
      weight_loss: t('components.plantemplatespanel.weight_loss'),
      muscle_gain: t('components.plantemplatespanel.muscle_gain'),
      maintenance: t('components.plantemplatespanel.maintenance'),
      performance: t('components.plantemplatespanel.performance'),
    })[value] ?? value;

  return (
    <div className="space-y-6 animate-fade-in-up">
      <section className="portal-hero rounded-[1.8rem] p-6">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
          <div className="space-y-2">
            <p className="portal-kicker">{t('components.plantemplatespanel.plan_templates')}</p>
            <h2 className="portal-title text-3xl text-foreground">
              {t('components.plantemplatespanel.reusable_structures_to_operate_faster')}
            </h2>
            <p className="max-w-3xl text-sm leading-relaxed text-muted-foreground">
              {t('components.plantemplatespanel.save_durations_objectives_and_baseline_macros_that_you_can_later_apply_t')}
            </p>
          </div>
          <button
            onClick={() => setShowForm(true)}
            className="inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground"
          >
            <Plus className="h-4 w-4" />
            {t('components.plantemplatespanel.new_template')}
          </button>
        </div>
      </section>

      <section className="grid gap-4 md:grid-cols-3">
        <StatCard
          label={t('components.plantemplatespanel.templates')}
          value={totalTemplates}
          note={t('components.plantemplatespanel.current_reusable_library')}
        />
        <StatCard
          label={t('components.plantemplatespanel.connected_clients')}
          value={connectedClients.length}
          note={t('components.plantemplatespanel.valid_targets_for_applying_templates')}
        />
        <StatCard
          label={t('components.plantemplatespanel.objectives_ready')}
          value={5}
          note={t('components.plantemplatespanel.baseline_builder_catalog')}
        />
      </section>

      {isLoading ? (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {[1, 2, 3].map((i) => (
            <div key={i} className="portal-panel h-56 rounded-[1.6rem] animate-pulse" />
          ))}
        </div>
      ) : !templates?.length ? (
        <div className="portal-panel flex min-h-[340px] flex-col items-center justify-center rounded-[1.6rem] p-10 text-center">
          <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-primary/10 text-primary">
            <ClipboardCopy className="h-8 w-8" />
          </div>
          <h3 className="portal-title mt-5 text-2xl text-foreground">
            {t('components.plantemplatespanel.no_templates_yet')}
          </h3>
          <p className="mt-2 max-w-sm text-sm leading-relaxed text-muted-foreground">
            {t('components.plantemplatespanel.create_a_first_reusable_structure_to_speed_up_plan_publishing_for_connec')}
          </p>
          <button
            onClick={() => setShowForm(true)}
            className="mt-5 inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground"
          >
            <Plus className="h-4 w-4" />
            {t('components.plantemplatespanel.create_first_template')}
          </button>
        </div>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {templates.map((template) => {
            const macroTarget =
              Array.isArray(template.meals) && template.meals.length > 0
                ? (template.meals[0] as any)
                : null;

            return (
              <article key={template.id} className="portal-panel rounded-[1.6rem] p-5">
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <div className="flex items-center gap-2">
                      <Layers className="h-4 w-4 text-primary" />
                      <h3 className="truncate text-base font-bold text-foreground">{template.name}</h3>
                    </div>
                    {template.description && (
                      <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
                        {template.description}
                      </p>
                    )}
                  </div>
                  <button
                    onClick={() => setDeleteConfirm(template.id)}
                    className="rounded-xl p-2 text-muted-foreground transition-colors hover:bg-rose-500/10 hover:text-rose-500"
                    title={t('components.plantemplatespanel.delete_template')}
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>

                <div className="mt-4 flex flex-wrap gap-2">
                  <span className="portal-chip rounded-full px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em]">
                    {template.duration_days} {t('components.plantemplatespanel.days')}
                  </span>
                  <span className="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
                    {objectiveLabel(template.objective || 'general_fitness')}
                  </span>
                  <span className="rounded-full bg-background px-3 py-1 text-[10px] font-semibold text-muted-foreground">
                    {t('components.plantemplatespanel.used_times', { template_use_count: template.use_count })}
                  </span>
                </div>

                {macroTarget && (
                  <div className="mt-4 grid grid-cols-4 gap-2">
                    <MacroCard label={t('common.kcal')} value={macroTarget.kcal} tone="rose" />
                    <MacroCard label={t('common.protein_short')} value={macroTarget.protein} tone="emerald" suffix={t('common.grams_unit')} />
                    <MacroCard label={t('common.carbs_short')} value={macroTarget.carbs} tone="blue" suffix={t('common.grams_unit')} />
                    <MacroCard label={t('common.fat_short')} value={macroTarget.fat} tone="amber" suffix={t('common.grams_unit')} />
                  </div>
                )}

                <button
                  onClick={() =>
                    setApplyTarget({ templateId: template.id, templateName: template.name })
                  }
                  className="mt-5 inline-flex w-full items-center justify-center gap-2 rounded-xl border border-primary/20 bg-primary/10 px-4 py-2.5 text-xs font-bold uppercase tracking-[0.16em] text-primary transition-colors hover:bg-primary hover:text-primary-foreground"
                >
                  <Target className="h-4 w-4" />
                  {t('components.plantemplatespanel.apply_to_client')}
                </button>
              </article>
            );
          })}
        </div>
      )}

      {showForm &&
        createPortal(
          <div
            className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto bg-black/50 p-4 py-8 backdrop-blur-sm"
            onClick={() => setShowForm(false)}
          >
            <div
              className="glass-card my-auto w-full max-w-lg rounded-[1.8rem] p-6"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="mb-5 flex items-center justify-between border-b border-border pb-4">
                <div>
                  <h3 className="text-lg font-bold text-foreground">
                    {t('components.plantemplatespanel.create_plan_template')}
                  </h3>
                  <p className="text-sm text-muted-foreground">
                    {t('components.plantemplatespanel.define_objectives_and_baseline_macros_for_later_reuse')}
                  </p>
                </div>
                <button
                  onClick={() => setShowForm(false)}
                  className="rounded-xl p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>

              <div className="space-y-4">
                <Field label={t('components.plantemplatespanel.template_name')} required>
                  <input
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder={t('components.plantemplatespanel.e_g_8_week_cut')}
                    className="portal-input h-11 w-full rounded-xl px-4 text-sm font-medium outline-none focus:border-primary"
                  />
                </Field>

                <Field label={t('components.plantemplatespanel.description')}>
                  <textarea
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    rows={2}
                    placeholder={t('components.plantemplatespanel.usage_notes_or_context')}
                    className="portal-input w-full rounded-xl px-4 py-3 text-sm font-medium outline-none focus:border-primary"
                  />
                </Field>

                <div className="grid gap-4 sm:grid-cols-2">
                  <Field label={t('components.plantemplatespanel.duration_days')}>
                    <input
                      type="number"
                      min={1}
                      value={durationDays}
                      onChange={(e) => setDurationDays(+e.target.value)}
                      className="portal-input h-11 w-full rounded-xl px-4 text-sm font-semibold outline-none focus:border-primary"
                    />
                  </Field>
                  <Field label={t('components.plantemplatespanel.objective')}>
                    <select
                      value={objective}
                      onChange={(e) => setObjective(e.target.value)}
                      className="portal-input h-11 w-full rounded-xl px-4 text-sm font-semibold outline-none"
                    >
                      <option value="general_fitness">{t('components.plantemplatespanel.general_fitness')}</option>
                      <option value="weight_loss">{t('components.plantemplatespanel.weight_loss')}</option>
                      <option value="muscle_gain">{t('components.plantemplatespanel.muscle_gain')}</option>
                      <option value="maintenance">{t('components.plantemplatespanel.maintenance')}</option>
                      <option value="performance">{t('components.plantemplatespanel.performance')}</option>
                    </select>
                  </Field>
                </div>

                <div className="rounded-2xl border border-border bg-background/60 p-4">
                  <p className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">
                    {t('components.plantemplatespanel.default_macros')}
                  </p>
                  <div className="mt-3 grid grid-cols-2 gap-3 sm:grid-cols-4">
                    {macroCards.map((macro) => (
                      <div key={macro.label} className="space-y-1.5">
                        <label className="text-xs font-semibold text-muted-foreground">{macro.label}</label>
                        <input
                          type="number"
                          value={macro.value}
                          onChange={(e) => macro.set(+e.target.value)}
                          className="portal-input h-10 w-full rounded-xl px-3 text-sm font-semibold outline-none focus:border-primary"
                        />
                      </div>
                    ))}
                  </div>
                </div>

                <div className="flex justify-end gap-3 border-t border-border pt-4">
                  <button
                    onClick={() => setShowForm(false)}
                    className="rounded-xl border border-border px-4 py-2 text-sm font-semibold text-foreground transition-colors hover:bg-accent"
                  >
                    {t('components.plantemplatespanel.cancel')}
                  </button>
                  <button
                    onClick={handleCreate}
                    disabled={!name.trim()}
                    className="rounded-xl bg-primary px-5 py-2 text-sm font-bold text-primary-foreground disabled:opacity-50"
                  >
                    {t('components.plantemplatespanel.create_template')}
                  </button>
                </div>
              </div>
            </div>
          </div>,
          document.body,
        )}

      {applyTarget &&
        createPortal(
          <div
            className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto bg-black/50 p-4 py-8 backdrop-blur-sm"
            onClick={() => {
              setApplyTarget(null);
              setApplyClientId('');
            }}
          >
            <div
              className="glass-card my-auto w-full max-w-sm rounded-[1.8rem] p-6"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="mb-4 flex items-center justify-between border-b border-border pb-4">
                <div className="flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/12 text-primary">
                    <UserCheck className="h-5 w-5" />
                  </div>
                  <div>
                    <h3 className="text-base font-bold text-foreground">
                      {t('components.plantemplatespanel.apply_template')}
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      {t('components.plantemplatespanel.assign_to_a_connected_client')}
                    </p>
                  </div>
                </div>
                <button
                  onClick={() => {
                    setApplyTarget(null);
                    setApplyClientId('');
                  }}
                  className="rounded-xl p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>

              <p className="text-sm leading-relaxed text-muted-foreground">
                {t('components.plantemplatespanel.select_a_client_to_apply_you_will_be_able_to_review_meals_and_adjust_the', { applytarget_templatename: applyTarget.templateName })}
              </p>

              <div className="mt-4 space-y-4">
                <Field label={t('components.plantemplatespanel.client')}>
                  <select
                    value={applyClientId}
                    onChange={(e) => setApplyClientId(e.target.value)}
                    className="portal-input h-11 w-full rounded-xl px-4 text-sm font-semibold outline-none"
                  >
                    <option value="">{t('components.plantemplatespanel.select_a_client_2')}</option>
                    {connectedClients.map((client) => (
                      <option key={client.id} value={client.client_id}>
                        {client.display_name || client.client_id.slice(0, 8)}
                      </option>
                    ))}
                  </select>
                </Field>

                <div className="flex justify-end gap-3 border-t border-border pt-4">
                  <button
                    onClick={() => {
                      setApplyTarget(null);
                      setApplyClientId('');
                    }}
                    className="rounded-xl border border-border px-4 py-2 text-sm font-semibold text-foreground transition-colors hover:bg-accent"
                  >
                    {t('components.plantemplatespanel.cancel')}
                  </button>
                  <button
                    onClick={handleApplyTemplate}
                    disabled={!applyClientId}
                    className="rounded-xl bg-primary px-4 py-2 text-sm font-bold text-primary-foreground disabled:opacity-50"
                  >
                    {t('components.plantemplatespanel.apply_and_open')}
                  </button>
                </div>
              </div>
            </div>
          </div>,
          document.body,
        )}

      <ConfirmDialog
        open={deleteConfirm !== null}
        title={t('components.plantemplatespanel.delete_template')}
        message={t('components.plantemplatespanel.this_action_cannot_be_undone_the_template_will_be_permanently_removed_fr')}
        onConfirm={() => {
          if (deleteConfirm) {
            handleDelete(deleteConfirm);
          }
        }}
        onCancel={() => setDeleteConfirm(null)}
      />
    </div>
  );
};

const StatCard: React.FC<{ label: string; value: number; note: string }> = ({
  label,
  value,
  note,
}) => (
  <div className="portal-panel rounded-[1.4rem] p-4">
    <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">{label}</p>
    <p className="portal-metric mt-2 text-3xl font-extrabold text-foreground">{value}</p>
    <p className="mt-1 text-xs leading-relaxed text-muted-foreground">{note}</p>
  </div>
);

const MacroCard: React.FC<{
  label: string;
  value: number | null | undefined;
  tone: 'rose' | 'emerald' | 'blue' | 'amber';
  suffix?: string;
}> = ({ label, value, tone, suffix = '' }) => {
  const toneClass = {
    rose: 'text-rose-500 bg-rose-500/8',
    emerald: 'text-emerald-600 dark:text-emerald-400 bg-emerald-500/8',
    blue: 'text-sky-600 dark:text-sky-400 bg-sky-500/8',
    amber: 'text-amber-600 dark:text-amber-400 bg-amber-500/8',
  }[tone];

  return (
    <div className={`rounded-xl px-3 py-3 text-center ${toneClass}`}>
      <p className="text-[10px] font-bold uppercase tracking-[0.16em]">{label}</p>
      <p className="mt-1 text-sm font-extrabold">
        {value ?? '--'}
        {suffix}
      </p>
    </div>
  );
};

const Field: React.FC<{
  label: string;
  required?: boolean;
  children: React.ReactNode;
}> = ({ label, required = false, children }) => (
  <div className="space-y-2">
    <label className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">
      {label}
      {required ? ' *' : ''}
    </label>
    {children}
  </div>
);
