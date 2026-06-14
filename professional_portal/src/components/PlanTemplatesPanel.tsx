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
  const { tr } = usePortalI18n();
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
      toast.success(tr('Plantilla creada', 'Template created'));
      setShowForm(false);
      setName('');
      setDescription('');
    } catch {
      toast.error(tr('No se pudo crear la plantilla', 'Failed to create template'));
    }
  };

  const handleDelete = async (id: string) => {
    if (!professional) {
      return;
    }
    try {
      await planTemplateRepository.remove(supabase, id);
      queryClient.invalidateQueries({ queryKey: ['plan-templates', professional.id] });
      toast.success(tr('Plantilla eliminada', 'Template deleted'));
      setDeleteConfirm(null);
    } catch {
      toast.error(tr('No se pudo eliminar la plantilla', 'Failed to delete template'));
    }
  };

  const handleApplyTemplate = async () => {
    if (!applyTarget || !applyClientId || !professional) {
      return;
    }
    const client = clients?.find((c) => c.client_id === applyClientId);
    if (!client) {
      toast.error(tr('Selecciona un cliente', 'Select a client'));
      return;
    }

    const template = templates?.find((t) => t.id === applyTarget.templateId);
    if (!template) {
      toast.error(tr('Plantilla no encontrada', 'Template not found'));
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
      tr(
        `Plantilla "${template.name}" preparada para revisar en Plan Builder`,
        `Template "${template.name}" queued for review in Plan Builder`,
      ),
    );
    setApplyTarget(null);
    setApplyClientId('');
  };

  const objectiveLabel = (value: string) =>
    ({
      general_fitness: tr('Fitness general', 'General fitness'),
      weight_loss: tr('Pérdida de peso', 'Weight loss'),
      muscle_gain: tr('Ganancia muscular', 'Muscle gain'),
      maintenance: tr('Mantenimiento', 'Maintenance'),
      performance: tr('Rendimiento', 'Performance'),
    })[value] ?? value;

  return (
    <div className="space-y-6 animate-fade-in-up">
      <section className="portal-hero rounded-[1.8rem] p-6">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
          <div className="space-y-2">
            <p className="portal-kicker">{tr('Plantillas de planes', 'Plan templates')}</p>
            <h2 className="portal-title text-3xl text-foreground">
              {tr(
                'Estructuras reutilizables para operar más rápido.',
                'Reusable structures to operate faster.',
              )}
            </h2>
            <p className="max-w-3xl text-sm leading-relaxed text-muted-foreground">
              {tr(
                'Guarda duraciones, objetivos y macros base que luego puedas aplicar a clientes conectados y revisar antes de publicar.',
                'Save durations, objectives, and baseline macros that you can later apply to connected clients and review before publishing.',
              )}
            </p>
          </div>
          <button
            onClick={() => setShowForm(true)}
            className="inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground"
          >
            <Plus className="h-4 w-4" />
            {tr('Nueva plantilla', 'New template')}
          </button>
        </div>
      </section>

      <section className="grid gap-4 md:grid-cols-3">
        <StatCard
          label={tr('Plantillas', 'Templates')}
          value={totalTemplates}
          note={tr('Biblioteca reusable actual', 'Current reusable library')}
        />
        <StatCard
          label={tr('Clientes conectados', 'Connected clients')}
          value={connectedClients.length}
          note={tr('Destino válido para aplicar plantillas', 'Valid targets for applying templates')}
        />
        <StatCard
          label={tr('Objetivos listos', 'Objectives ready')}
          value={5}
          note={tr('Catálogo base del builder', 'Baseline builder catalog')}
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
            {tr('Todavía no hay plantillas', 'No templates yet')}
          </h3>
          <p className="mt-2 max-w-sm text-sm leading-relaxed text-muted-foreground">
            {tr(
              'Crea una primera estructura reusable para acelerar la publicación de planes en clientes conectados.',
              'Create a first reusable structure to speed up plan publishing for connected clients.',
            )}
          </p>
          <button
            onClick={() => setShowForm(true)}
            className="mt-5 inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground"
          >
            <Plus className="h-4 w-4" />
            {tr('Crear primera plantilla', 'Create first template')}
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
                    title={tr('Eliminar plantilla', 'Delete template')}
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>

                <div className="mt-4 flex flex-wrap gap-2">
                  <span className="portal-chip rounded-full px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em]">
                    {template.duration_days} {tr('días', 'days')}
                  </span>
                  <span className="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
                    {objectiveLabel(template.objective || 'general_fitness')}
                  </span>
                  <span className="rounded-full bg-background px-3 py-1 text-[10px] font-semibold text-muted-foreground">
                    {tr(`Usada ${template.use_count} veces`, `Used ${template.use_count} times`)}
                  </span>
                </div>

                {macroTarget && (
                  <div className="mt-4 grid grid-cols-4 gap-2">
                    <MacroCard label="Kcal" value={macroTarget.kcal} tone="rose" />
                    <MacroCard label="P" value={macroTarget.protein} tone="emerald" suffix="g" />
                    <MacroCard label="C" value={macroTarget.carbs} tone="blue" suffix="g" />
                    <MacroCard label="F" value={macroTarget.fat} tone="amber" suffix="g" />
                  </div>
                )}

                <button
                  onClick={() =>
                    setApplyTarget({ templateId: template.id, templateName: template.name })
                  }
                  className="mt-5 inline-flex w-full items-center justify-center gap-2 rounded-xl border border-primary/20 bg-primary/10 px-4 py-2.5 text-xs font-bold uppercase tracking-[0.16em] text-primary transition-colors hover:bg-primary hover:text-primary-foreground"
                >
                  <Target className="h-4 w-4" />
                  {tr('Aplicar a cliente', 'Apply to client')}
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
                    {tr('Crear plantilla de plan', 'Create plan template')}
                  </h3>
                  <p className="text-sm text-muted-foreground">
                    {tr(
                      'Define objetivos y macros base para reutilizar después.',
                      'Define objectives and baseline macros for later reuse.',
                    )}
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
                <Field label={tr('Nombre de la plantilla', 'Template name')} required>
                  <input
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder={tr('Ej. Déficit 8 semanas', 'E.g. 8-week cut')}
                    className="portal-input h-11 w-full rounded-xl px-4 text-sm font-medium outline-none focus:border-primary"
                  />
                </Field>

                <Field label={tr('Descripción', 'Description')}>
                  <textarea
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    rows={2}
                    placeholder={tr('Notas de uso o contexto...', 'Usage notes or context...')}
                    className="portal-input w-full rounded-xl px-4 py-3 text-sm font-medium outline-none focus:border-primary"
                  />
                </Field>

                <div className="grid gap-4 sm:grid-cols-2">
                  <Field label={tr('Duración (días)', 'Duration (days)')}>
                    <input
                      type="number"
                      min={1}
                      value={durationDays}
                      onChange={(e) => setDurationDays(+e.target.value)}
                      className="portal-input h-11 w-full rounded-xl px-4 text-sm font-semibold outline-none focus:border-primary"
                    />
                  </Field>
                  <Field label={tr('Objetivo', 'Objective')}>
                    <select
                      value={objective}
                      onChange={(e) => setObjective(e.target.value)}
                      className="portal-input h-11 w-full rounded-xl px-4 text-sm font-semibold outline-none"
                    >
                      <option value="general_fitness">{tr('Fitness general', 'General fitness')}</option>
                      <option value="weight_loss">{tr('Pérdida de peso', 'Weight loss')}</option>
                      <option value="muscle_gain">{tr('Ganancia muscular', 'Muscle gain')}</option>
                      <option value="maintenance">{tr('Mantenimiento', 'Maintenance')}</option>
                      <option value="performance">{tr('Rendimiento', 'Performance')}</option>
                    </select>
                  </Field>
                </div>

                <div className="rounded-2xl border border-border bg-background/60 p-4">
                  <p className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">
                    {tr('Macros por defecto', 'Default macros')}
                  </p>
                  <div className="mt-3 grid grid-cols-2 gap-3 sm:grid-cols-4">
                    {[
                      {
                        label: 'Kcal',
                        value: templateKcal,
                        set: setTemplateKcal,
                      },
                      {
                        label: 'Protein',
                        value: templateProtein,
                        set: setTemplateProtein,
                      },
                      {
                        label: 'Carbs',
                        value: templateCarbs,
                        set: setTemplateCarbs,
                      },
                      {
                        label: 'Fat',
                        value: templateFat,
                        set: setTemplateFat,
                      },
                    ].map((macro) => (
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
                    {tr('Cancelar', 'Cancel')}
                  </button>
                  <button
                    onClick={handleCreate}
                    disabled={!name.trim()}
                    className="rounded-xl bg-primary px-5 py-2 text-sm font-bold text-primary-foreground disabled:opacity-50"
                  >
                    {tr('Crear plantilla', 'Create template')}
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
                      {tr('Aplicar plantilla', 'Apply template')}
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      {tr('Asignar a un cliente conectado', 'Assign to a connected client')}
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
                {tr(
                  `Selecciona un cliente para aplicar "${applyTarget.templateName}". Después podrás revisar comidas y ajustar el plan antes de publicar.`,
                  `Select a client to apply "${applyTarget.templateName}". You will be able to review meals and adjust the plan before publishing.`,
                )}
              </p>

              <div className="mt-4 space-y-4">
                <Field label={tr('Cliente', 'Client')}>
                  <select
                    value={applyClientId}
                    onChange={(e) => setApplyClientId(e.target.value)}
                    className="portal-input h-11 w-full rounded-xl px-4 text-sm font-semibold outline-none"
                  >
                    <option value="">{tr('Selecciona un cliente...', 'Select a client...')}</option>
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
                    {tr('Cancelar', 'Cancel')}
                  </button>
                  <button
                    onClick={handleApplyTemplate}
                    disabled={!applyClientId}
                    className="rounded-xl bg-primary px-4 py-2 text-sm font-bold text-primary-foreground disabled:opacity-50"
                  >
                    {tr('Aplicar y abrir', 'Apply and open')}
                  </button>
                </div>
              </div>
            </div>
          </div>,
          document.body,
        )}

      <ConfirmDialog
        open={deleteConfirm !== null}
        title={tr('Eliminar plantilla', 'Delete template')}
        message={tr(
          'Esta acción no se puede deshacer. La plantilla se eliminará definitivamente de la biblioteca profesional.',
          'This action cannot be undone. The template will be permanently removed from the professional library.',
        )}
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
