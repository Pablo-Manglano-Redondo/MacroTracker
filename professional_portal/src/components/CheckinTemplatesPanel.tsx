import React, { useState } from 'react';
import { useAuth } from '../lib/auth-context';
import { useCheckinTemplates } from '../hooks/queries/useCheckins';
import { useCreateCheckinTemplate, useDeleteCheckinTemplate } from '../hooks/mutations/useCheckinTemplates';
import { ClipboardCheck, Plus, Trash2, X } from 'lucide-react';
import { toast } from 'sonner';
import { ConfirmDialog } from './ui/confirm-dialog';

interface Question {
  id: string;
  label: string;
  type: 'text' | 'rating' | 'boolean';
}

const defaultQuestions: Question[] = [
  { id: 'q1', label: 'How was your energy this week?', type: 'rating' },
  { id: 'q2', label: 'Did you hit your daily protein target?', type: 'boolean' },
  { id: 'q3', label: 'Any comments about your training?', type: 'text' },
];

let qCounter = 4;

export const CheckinTemplatesPanel: React.FC = () => {
  const { professional } = useAuth();
  const { data: templates, isLoading } = useCheckinTemplates(professional?.id);
  const createTemplate = useCreateCheckinTemplate(professional?.id);
  const deleteTemplate = useDeleteCheckinTemplate(professional?.id);

  const [showForm, setShowForm] = useState(false);
  const [title, setTitle] = useState('');
  const [questions, setQuestions] = useState<Question[]>(defaultQuestions);
  const [deleteConfirm, setDeleteConfirm] = useState<string | null>(null);

  const handleCreate = async () => {
    if (!title.trim()) { toast.error('Template title required'); return; }
    try {
      await createTemplate.mutateAsync({
        professional_id: professional!.id,
        title: title.trim(),
        questions: questions.filter(q => q.label.trim()),
        is_default: false,
      });
      toast.success('Check-in template created');
      setShowForm(false);
      setTitle('');
      setQuestions(defaultQuestions);
    } catch { toast.error('Failed to create template'); }
  };

  const addQuestion = () => {
    setQuestions(prev => [...prev, { id: `q${qCounter++}`, label: '', type: 'text' }]);
  };

  const removeQuestion = (id: string) => {
    setQuestions(prev => prev.filter(q => q.id !== id));
  };

  const updateQuestion = (id: string, field: keyof Question, value: string) => {
    setQuestions(prev => prev.map(q => q.id === id ? { ...q, [field]: field === 'type' ? value as Question['type'] : value } : q));
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h2 className="text-lg font-bold text-foreground flex items-center gap-2">
            <ClipboardCheck className="w-5 h-5 text-primary" />
            Check-in Templates
          </h2>
          <p className="text-xs text-muted-foreground mt-0.5">{templates?.length || 0} templates</p>
        </div>
        <button onClick={() => setShowForm(true)}
          className="flex items-center gap-1.5 px-3 py-1.5 text-xs rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors">
          <Plus className="w-3.5 h-3.5" /> New Template
        </button>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1,2,3].map(i => <div key={i} className="h-32 rounded-xl bg-muted/30 animate-pulse" />)}
        </div>
      ) : !templates?.length ? (
        <div className="text-center py-12 text-muted-foreground">
          <ClipboardCheck className="w-10 h-10 mx-auto mb-3 text-primary/30" />
          <p className="text-sm font-medium">No check-in templates yet</p>
          <p className="text-xs mt-1">Create structured weekly check-ins for your clients.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {templates.map(t => (
            <div key={t.id} className="rounded-xl bg-card border p-4 space-y-3 card-elevated hover:shadow-md transition-shadow">
              <div className="flex items-start justify-between gap-2">
                <div className="min-w-0">
                  <h4 className="text-sm font-bold truncate">{t.title}</h4>
                  <p className="text-[11px] text-muted-foreground mt-0.5">
                    {(t.questions as any[] || []).length} questions
                    {t.is_default ? ' · Default' : ''}
                  </p>
                </div>
                <button onClick={() => setDeleteConfirm(t.id)}
                  className="p-1.5 rounded-md text-muted-foreground hover:text-red-500 hover:bg-red-500/10 transition-colors shrink-0">
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
              </div>
              {(t.questions as any[] || []).length > 0 && (
                <div className="space-y-1">
                  {(t.questions as Question[]).slice(0, 4).map(q => (
                    <div key={q.id} className="text-[11px] text-muted-foreground flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-primary/30 shrink-0" />
                      <span className="truncate">{q.label}</span>
                      <span className="text-[10px] text-muted-foreground/60 shrink-0">
                        {q.type === 'rating' ? '★1-10' : q.type === 'boolean' ? '✓/✗' : 'Aa'}
                      </span>
                    </div>
                  ))}
                  {(t.questions as any[]).length > 4 && (
                    <p className="text-[10px] text-muted-foreground/60 pt-1">+{(t.questions as any[]).length - 4} more</p>
                  )}
                </div>
              )}
              <p className="text-[10px] text-muted-foreground/60">
                Created {new Date(t.created_at).toLocaleDateString()}
              </p>
            </div>
          ))}
        </div>
      )}

      {showForm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50" onClick={() => setShowForm(false)}>
          <div className="bg-card rounded-2xl p-6 w-full max-w-lg max-h-[85vh] overflow-y-auto m-4 shadow-2xl" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-bold">New Check-in Template</h3>
              <button onClick={() => setShowForm(false)} className="p-1 rounded-md hover:bg-secondary"><X className="w-4 h-4" /></button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-[11px] font-medium text-muted-foreground">Template Title *</label>
                <input value={title} onChange={e => setTitle(e.target.value)} placeholder="e.g. Weekly Wellness Check"
                  className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
              </div>

              <div>
                <div className="flex items-center justify-between mb-2">
                  <label className="text-[11px] font-medium text-muted-foreground">Questions</label>
                  <button onClick={addQuestion}
                    className="flex items-center gap-1 px-2 py-1 text-[10px] rounded-md bg-secondary hover:bg-secondary/80 transition-colors">
                    <Plus className="w-3 h-3" /> Add Question
                  </button>
                </div>
                <div className="space-y-2">
                  {questions.map((q, idx) => (
                    <div key={q.id} className="flex items-start gap-2 p-3 rounded-lg border bg-background">
                      <div className="flex-1 space-y-1.5 min-w-0">
                        <input value={q.label} onChange={e => updateQuestion(q.id, 'label', e.target.value)}
                          placeholder={`Question ${idx + 1}`}
                          className="w-full px-2 py-1 text-xs rounded border bg-card focus:outline-none focus:ring-1 focus:ring-primary" />
                        <select value={q.type} onChange={e => updateQuestion(q.id, 'type', e.target.value)}
                          className="px-2 py-1 text-[10px] rounded border bg-card focus:outline-none focus:ring-1 focus:ring-primary">
                          <option value="text">Text (free response)</option>
                          <option value="rating">Rating (1-10)</option>
                          <option value="boolean">Yes / No</option>
                        </select>
                      </div>
                      <button onClick={() => removeQuestion(q.id)}
                        className="p-1 rounded-md text-muted-foreground hover:text-red-500 hover:bg-red-500/10 transition-colors shrink-0 mt-0.5">
                        <X className="w-3 h-3" />
                      </button>
                    </div>
                  ))}
                </div>
              </div>

              <div className="flex justify-end gap-2 pt-2 border-t">
                <button onClick={() => setShowForm(false)}
                  className="px-4 py-1.5 text-xs rounded-lg border hover:bg-secondary transition-colors">Cancel</button>
                <button onClick={handleCreate} disabled={createTemplate.isPending || !title.trim()}
                  className="px-4 py-1.5 text-xs rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors disabled:opacity-50">
                  {createTemplate.isPending ? 'Creating...' : 'Create Template'}
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
        onConfirm={() => { if (deleteConfirm) deleteTemplate.mutate(deleteConfirm); setDeleteConfirm(null); }}
        onCancel={() => setDeleteConfirm(null)}
        loading={deleteTemplate.isPending}
      />
    </div>
  );
};
