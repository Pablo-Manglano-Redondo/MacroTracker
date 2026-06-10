import React, { useState } from 'react';
import { useAuth } from '../lib/auth-context';
import { usePlanTemplates } from '../hooks/queries/usePlanTemplates';
import { useClients } from '../hooks/queries/useClients';
import { ClipboardCopy, Layers, Plus, Trash2, X, Target, UserCheck } from 'lucide-react';
import { toast } from 'sonner';
import { planTemplateRepository } from '../repositories/plan-template.repository';
import { supabase } from '../lib/supabase';
import { useQueryClient } from '@tanstack/react-query';
import { ConfirmDialog } from './ui/confirm-dialog';

export const PlanTemplatesPanel: React.FC = () => {
  const { professional } = useAuth();
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

  const handleCreate = async () => {
    if (!name.trim() || !professional) return;
    try {
      const meals = [{ kcal: templateKcal, protein: templateProtein, carbs: templateCarbs, fat: templateFat }];
      await planTemplateRepository.create(supabase, {
        professional_id: professional.id,
        name: name.trim(),
        description: description.trim() || null,
        duration_days: durationDays,
        objective,
        meals,
      });
      queryClient.invalidateQueries({ queryKey: ['plan-templates', professional.id] });
      toast.success('Template created');
      setShowForm(false);
      setName(''); setDescription('');
    } catch { toast.error('Failed to create template'); }
  };

  const handleDelete = async (id: string) => {
    if (!professional) return;
    try {
      await planTemplateRepository.remove(supabase, id);
      queryClient.invalidateQueries({ queryKey: ['plan-templates', professional.id] });
      toast.success('Template deleted');
      setDeleteConfirm(null);
    } catch { toast.error('Failed to delete'); }
  };

  const handleApplyTemplate = async () => {
    if (!applyTarget || !applyClientId || !professional) return;
    const client = clients?.find(c => c.client_id === applyClientId);
    if (!client) { toast.error('Select a client'); return; }

    const template = templates?.find(t => t.id === applyTarget.templateId);
    if (!template) { toast.error('Template not found'); return; }

    // Store template data for PlanBuilder to pick up
    sessionStorage.setItem('apply-template', JSON.stringify({
      name: template.name,
      meals: template.meals || [],
    }));

    // Navigate to client detail — switch to clients-panel and select the client
    window.location.hash = 'clients-panel';
    // Dispatch custom event so AppShell can select the client
    window.dispatchEvent(new CustomEvent('select-client', { detail: client.id }));

    // Increment use count
    try { await planTemplateRepository.incrementUse(supabase, applyTarget.templateId); } catch {}

    toast.success(`Template "${template.name}" applied — open Plan Builder to review`);
    setApplyTarget(null);
    setApplyClientId('');
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-bold text-foreground flex items-center gap-2">
            <Layers className="w-5 h-5 text-primary" />
            Plan Templates
          </h2>
          <p className="text-xs text-muted-foreground mt-0.5">{templates?.length || 0} templates</p>
        </div>
        <button onClick={() => setShowForm(true)}
          className="btn-primary text-xs px-3 py-1.5 rounded-lg gap-1.5 flex items-center">
          <Plus className="w-3.5 h-3.5" /> New Template
        </button>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1,2,3].map(i => <div key={i} className="h-28 rounded-xl bg-muted/30 animate-pulse" />)}
        </div>
      ) : !templates?.length ? (
        <div className="text-center py-12 text-muted-foreground">
          <ClipboardCopy className="w-10 h-10 mx-auto mb-3 text-primary/30" />
          <p className="text-sm font-medium">No templates yet</p>
          <p className="text-xs mt-1">Save reusable plan structures for quick application.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {templates.map(t => {
            const macroTarget = Array.isArray(t.meals) && t.meals.length > 0 ? t.meals[0] as any : null;
            return (
              <div key={t.id} className="rounded-xl bg-card border p-4 space-y-3 card-elevated hover:shadow-md transition-shadow">
                <div className="flex items-start justify-between gap-2">
                  <div className="min-w-0">
                    <h4 className="text-sm font-bold truncate">{t.name}</h4>
                    {t.description && <p className="text-[11px] text-muted-foreground mt-0.5 truncate">{t.description}</p>}
                  </div>
                  <button onClick={() => setDeleteConfirm(t.id)}
                    className="p-1 rounded-md text-muted-foreground hover:text-red-500 hover:bg-red-500/10 transition-colors shrink-0">
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
                <div className="flex items-center gap-3 text-[11px] text-muted-foreground">
                  <span>{t.duration_days} days</span>
                  <span className="capitalize">{t.objective?.replace(/_/g, ' ')}</span>
                  <span>Used {t.use_count}x</span>
                </div>
                {macroTarget && (
                  <div className="flex gap-2 text-[10px] font-medium text-muted-foreground">
                    {macroTarget.kcal != null && <span>{macroTarget.kcal} kcal</span>}
                    {macroTarget.protein != null && <span>P: {macroTarget.protein}g</span>}
                    {macroTarget.carbs != null && <span>C: {macroTarget.carbs}g</span>}
                    {macroTarget.fat != null && <span>F: {macroTarget.fat}g</span>}
                  </div>
                )}
                <button
                  onClick={() => setApplyTarget({ templateId: t.id, templateName: t.name })}
                  className="w-full flex items-center justify-center gap-1.5 px-3 py-1.5 text-[11px] rounded-lg bg-primary/10 text-primary hover:bg-primary/20 transition-colors font-medium"
                >
                  <Target className="w-3 h-3" />
                  Apply to client
                </button>
              </div>
            );
          })}
        </div>
      )}

      {showForm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50" onClick={() => setShowForm(false)}>
          <div className="bg-card rounded-2xl p-6 w-full max-w-md m-4 shadow-2xl" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-bold">New Template</h3>
              <button onClick={() => setShowForm(false)} className="p-1 rounded-md hover:bg-secondary"><X className="w-4 h-4" /></button>
            </div>
            <div className="space-y-3">
              <div>
                <label className="text-[11px] font-medium text-muted-foreground">Name *</label>
                <input value={name} onChange={e => setName(e.target.value)}
                  className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
              </div>
              <div>
                <label className="text-[11px] font-medium text-muted-foreground">Description</label>
                <textarea value={description} onChange={e => setDescription(e.target.value)} rows={2}
                  className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-[11px] font-medium text-muted-foreground">Duration (days)</label>
                  <input type="number" min={1} value={durationDays} onChange={e => setDurationDays(+e.target.value)}
                    className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                </div>
                <div>
                  <label className="text-[11px] font-medium text-muted-foreground">Objective</label>
                  <select value={objective} onChange={e => setObjective(e.target.value)}
                    className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary">
                    <option value="general_fitness">General Fitness</option>
                    <option value="weight_loss">Weight Loss</option>
                    <option value="muscle_gain">Muscle Gain</option>
                    <option value="maintenance">Maintenance</option>
                    <option value="performance">Performance</option>
                  </select>
                </div>
              </div>
              <div className="border-t pt-3">
                <label className="text-[11px] font-medium text-muted-foreground block mb-2">Default macro targets</label>
                <div className="grid grid-cols-4 gap-2">
                  {[
                    { label: 'Kcal', value: templateKcal, set: setTemplateKcal },
                    { label: 'Protein', value: templateProtein, set: setTemplateProtein },
                    { label: 'Carbs', value: templateCarbs, set: setTemplateCarbs },
                    { label: 'Fat', value: templateFat, set: setTemplateFat },
                  ].map(m => (
                    <div key={m.label}>
                      <label className="text-[9px] text-muted-foreground">{m.label}</label>
                      <input type="number" value={m.value} onChange={e => m.set(+e.target.value)}
                        className="w-full mt-0.5 px-2 py-1 text-xs rounded border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                    </div>
                  ))}
                </div>
              </div>
              <div className="flex justify-end gap-2 pt-2">
                <button onClick={() => setShowForm(false)}
                  className="px-4 py-1.5 text-xs rounded-lg border hover:bg-secondary transition-colors">Cancel</button>
                <button onClick={handleCreate} disabled={!name.trim()}
                  className="px-4 py-1.5 text-xs rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors disabled:opacity-50">
                  Create
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Apply to client modal */}
      {applyTarget && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50" onClick={() => { setApplyTarget(null); setApplyClientId(''); }}>
          <div className="bg-card rounded-2xl p-6 w-full max-w-sm m-4 shadow-2xl" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-bold flex items-center gap-2">
                <UserCheck className="w-4 h-4 text-primary" />
                Apply "{applyTarget.templateName}"
              </h3>
              <button onClick={() => { setApplyTarget(null); setApplyClientId(''); }} className="p-1 rounded-md hover:bg-secondary"><X className="w-4 h-4" /></button>
            </div>
            <p className="text-xs text-muted-foreground mb-3">Select a client to apply this template to. You'll be able to review and adjust before publishing.</p>
            <div className="space-y-3">
              <div>
                <label className="text-[11px] font-medium text-muted-foreground">Client</label>
                <select value={applyClientId} onChange={e => setApplyClientId(e.target.value)}
                  className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary">
                  <option value="">Select a client...</option>
                  {(clients || []).map(c => (
                    <option key={c.id} value={c.client_id}>{c.display_name || c.client_id.slice(0, 8)}</option>
                  ))}
                </select>
              </div>
              <div className="flex justify-end gap-2 pt-2">
                <button onClick={() => { setApplyTarget(null); setApplyClientId(''); }}
                  className="px-4 py-1.5 text-xs rounded-lg border hover:bg-secondary transition-colors">Cancel</button>
                <button onClick={handleApplyTemplate} disabled={!applyClientId}
                  className="px-4 py-1.5 text-xs rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors disabled:opacity-50">
                  Apply & Open Plan
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={deleteConfirm !== null}
        title="Delete template"
        message="This action cannot be undone. The template will be permanently removed."
        onConfirm={() => { if (deleteConfirm) handleDelete(deleteConfirm); }}
        onCancel={() => setDeleteConfirm(null)}
      />
    </div>
  );
};
