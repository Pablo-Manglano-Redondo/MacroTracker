import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import { ClipboardCheck, Plus, Trash2, X } from 'lucide-react';
import { toast } from 'sonner';
import { useAuth } from '../lib/auth-context';
import { useCheckinTemplates } from '../hooks/queries/useCheckins';
import {
  useCreateCheckinTemplate,
  useDeleteCheckinTemplate,
} from '../hooks/mutations/useCheckinTemplates';
import { formatPortalDate } from '../lib/date';
import { ConfirmDialog } from './ui/confirm-dialog';
import { usePortalI18n } from '../lib/portal-i18n';

interface Question {
  id: string;
  label: string;
  type: 'text' | 'rating' | 'boolean';
}

const defaultQuestions: Question[] = [
  { id: 'q1', label: '', type: 'rating' },
  { id: 'q2', label: '', type: 'boolean' },
  { id: 'q3', label: '', type: 'text' },
];

let qCounter = 4;

export const CheckinTemplatesPanel: React.FC = () => {
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();
  const defaultQuestionLabels = [
    t('components.checkintemplatespanel.default_question_energy'),
    t('components.checkintemplatespanel.default_question_protein'),
    t('components.checkintemplatespanel.default_question_training_comments'),
  ];
  const { data: templates, isLoading } = useCheckinTemplates(professional?.id);
  const createTemplate = useCreateCheckinTemplate(professional?.id);
  const deleteTemplate = useDeleteCheckinTemplate(professional?.id);

  const [showForm, setShowForm] = useState(false);
  const [title, setTitle] = useState('');
  const [questions, setQuestions] = useState<Question[]>(
    defaultQuestions.map((question, index) => ({
      ...question,
      label: defaultQuestionLabels[index] ?? '',
    })),
  );
  const [deleteConfirm, setDeleteConfirm] = useState<string | null>(null);

  const handleCreate = async () => {
    if (!title.trim()) {
      toast.error(t('components.checkintemplatespanel.template_title_required'));
      return;
    }
    try {
      await createTemplate.mutateAsync({
        professional_id: professional!.id,
        title: title.trim(),
        questions: questions.filter((question) => question.label.trim()),
        is_default: false,
      });
      toast.success(t('components.checkintemplatespanel.check_in_template_created'));
      setShowForm(false);
      setTitle('');
      setQuestions(
        defaultQuestions.map((question, index) => ({
          ...question,
          label: defaultQuestionLabels[index] ?? '',
        })),
      );
    } catch {
      toast.error(t('components.checkintemplatespanel.failed_to_create_template'));
    }
  };

  const addQuestion = () => {
    setQuestions((prev) => [...prev, { id: `q${qCounter++}`, label: '', type: 'text' }]);
  };

  const removeQuestion = (id: string) => {
    setQuestions((prev) => prev.filter((question) => question.id !== id));
  };

  const updateQuestion = (id: string, field: keyof Question, value: string) => {
    setQuestions((prev) =>
      prev.map((question) =>
        question.id === id
          ? { ...question, [field]: field === 'type' ? (value as Question['type']) : value }
          : question,
      ),
    );
  };

  const questionTypeLabel = (type: Question['type']) =>
    ({
      text: t('components.checkintemplatespanel.text'),
      rating: '1-10',
      boolean: t('components.checkintemplatespanel.yes_no'),
    })[type];

  return (
    <div className="space-y-6 animate-fade-in-up">
      <section className="portal-hero rounded-[1.8rem] p-6">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
          <div className="space-y-2">
            <p className="portal-kicker">{t('components.checkintemplatespanel.check_in_templates')}</p>
            <h2 className="portal-title text-3xl text-foreground">
              {t('components.checkintemplatespanel.structured_forms_for_recurring_follow_up')}
            </h2>
            <p className="max-w-3xl text-sm leading-relaxed text-muted-foreground">
              {t('components.checkintemplatespanel.define_reusable_questions_to_collect_weekly_feedback_adherence_signals_a')}
            </p>
          </div>
          <button
            onClick={() => setShowForm(true)}
            className="inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground"
          >
            <Plus className="h-4 w-4" />
            {t('components.checkintemplatespanel.new_template')}
          </button>
        </div>
      </section>

      {isLoading ? (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {[1, 2, 3].map((index) => (
            <div key={index} className="portal-panel h-56 rounded-[1.6rem] animate-pulse" />
          ))}
        </div>
      ) : !templates?.length ? (
        <div className="portal-panel flex min-h-[340px] flex-col items-center justify-center rounded-[1.6rem] p-10 text-center">
          <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-primary/10 text-primary">
            <ClipboardCheck className="h-8 w-8" />
          </div>
          <h3 className="portal-title mt-5 text-2xl text-foreground">
            {t('components.checkintemplatespanel.no_check_in_templates_yet')}
          </h3>
          <p className="mt-2 max-w-sm text-sm leading-relaxed text-muted-foreground">
            {t('components.checkintemplatespanel.create_a_first_structure_to_receive_metrics_notes_and_progress_signals_f')}
          </p>
          <button
            onClick={() => setShowForm(true)}
            className="mt-5 inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground"
          >
            <Plus className="h-4 w-4" />
            {t('components.checkintemplatespanel.create_first_template')}
          </button>
        </div>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {templates.map((template) => (
            <article key={template.id} className="portal-panel rounded-[1.6rem] p-5">
              <div className="flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <div className="flex items-center gap-2">
                    <ClipboardCheck className="h-4 w-4 text-primary" />
                    <h3 className="truncate text-base font-bold text-foreground">{template.title}</h3>
                  </div>
                  <p className="mt-2 text-xs font-semibold uppercase tracking-[0.16em] text-muted-foreground">
                    {(template.questions as any[] || []).length} {t('components.checkintemplatespanel.questions')}
                    {template.is_default ? ` · ${t('components.checkintemplatespanel.default')}` : ''}
                  </p>
                </div>
                <button
                  onClick={() => setDeleteConfirm(template.id)}
                  className="rounded-xl p-2 text-muted-foreground transition-colors hover:bg-rose-500/10 hover:text-rose-500"
                  title={t('components.checkintemplatespanel.delete_template')}
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              </div>

              {(template.questions as any[] || []).length > 0 ? (
                <div className="mt-4 space-y-2 border-t border-border pt-4">
                  {(template.questions as Question[]).slice(0, 3).map((question) => (
                    <div
                      key={question.id}
                      className="rounded-xl border border-border bg-background/60 px-3 py-3 text-sm"
                    >
                      <div className="flex items-center justify-between gap-3">
                        <span className="truncate font-medium text-foreground">{question.label}</span>
                        <span className="rounded-full bg-primary/10 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
                          {questionTypeLabel(question.type)}
                        </span>
                      </div>
                    </div>
                  ))}
                  {(template.questions as any[]).length > 3 ? (
                    <p className="pt-1 text-xs font-bold uppercase tracking-[0.16em] text-primary">
                      +{(template.questions as any[]).length - 3} {t('components.checkintemplatespanel.more_questions')}
                    </p>
                  ) : null}
                </div>
              ) : null}

              <div className="mt-5 border-t border-border pt-3 text-[11px] font-semibold text-muted-foreground">
                {t('components.checkintemplatespanel.created')}{' '}
                {formatPortalDate(template.created_at, locale, {
                  month: 'short',
                  day: 'numeric',
                  year: 'numeric',
                })}
              </div>
            </article>
          ))}
        </div>
      )}

      {showForm &&
        createPortal(
          <div
            className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto bg-black/50 p-4 py-8 backdrop-blur-sm"
            onClick={() => setShowForm(false)}
          >
            <div
              className="glass-card my-auto w-full max-w-2xl rounded-[1.8rem] p-6"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="mb-6 flex items-center justify-between border-b border-border pb-4">
                <div>
                  <h3 className="text-lg font-bold text-foreground">
                    {t('components.checkintemplatespanel.new_check_in_template')}
                  </h3>
                  <p className="text-sm text-muted-foreground">
                    {t('components.checkintemplatespanel.build_a_reusable_form_for_your_clients')}
                  </p>
                </div>
                <button
                  onClick={() => setShowForm(false)}
                  className="rounded-xl p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>

              <div className="space-y-5">
                <div className="space-y-2">
                  <label className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">
                    {t('components.checkintemplatespanel.title')} *
                  </label>
                  <input
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    placeholder={t('components.checkintemplatespanel.e_g_weekly_wellness_check')}
                    className="portal-input h-11 w-full rounded-xl px-4 text-sm font-medium outline-none focus:border-primary"
                  />
                </div>

                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-baseline gap-2">
                      <label className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">
                        {t('components.checkintemplatespanel.questions_2')}
                      </label>
                      <span className="rounded-full bg-primary/10 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
                        {questions.length}
                      </span>
                    </div>
                    <button
                      onClick={addQuestion}
                      className="inline-flex items-center gap-1 rounded-xl border border-primary/20 bg-primary/10 px-3 py-1.5 text-xs font-bold uppercase tracking-[0.16em] text-primary"
                    >
                      <Plus className="h-3.5 w-3.5" />
                      {t('components.checkintemplatespanel.add')}
                    </button>
                  </div>

                  <div className="max-h-[46vh] space-y-3 overflow-y-auto pr-1">
                    {questions.map((question, index) => (
                      <div key={question.id} className="rounded-2xl border border-border bg-background/60 p-4">
                        <div className="mb-3 flex items-center gap-3">
                          <span className="flex h-7 w-7 items-center justify-center rounded-xl bg-primary/10 text-[10px] font-bold text-primary">
                            {String(index + 1).padStart(2, '0')}
                          </span>
                          <button
                            type="button"
                            onClick={() => removeQuestion(question.id)}
                            className="ml-auto rounded-xl p-2 text-muted-foreground transition-colors hover:bg-rose-500/10 hover:text-rose-500"
                            title={t('components.checkintemplatespanel.delete_question')}
                          >
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </div>

                        <div className="space-y-3">
                          <input
                            value={question.label}
                            onChange={(e) => updateQuestion(question.id, 'label', e.target.value)}
                            placeholder={t('components.checkintemplatespanel.question', { index_1: index + 1 })}
                            className="portal-input h-11 w-full rounded-xl px-4 text-sm font-medium outline-none focus:border-primary"
                          />

                          <div className="grid grid-cols-3 gap-2 rounded-xl border border-border bg-background p-1">
                            {(['text', 'rating', 'boolean'] as const).map((type) => (
                              <button
                                key={type}
                                type="button"
                                onClick={() => updateQuestion(question.id, 'type', type)}
                                className={`rounded-lg px-2 py-2 text-[11px] font-bold uppercase tracking-[0.16em] transition-colors ${
                                  question.type === type
                                    ? 'bg-primary text-primary-foreground'
                                    : 'text-muted-foreground hover:text-foreground'
                                }`}
                              >
                                {questionTypeLabel(type)}
                              </button>
                            ))}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="flex justify-end gap-3 border-t border-border pt-4">
                  <button
                    onClick={() => setShowForm(false)}
                    className="rounded-xl border border-border px-4 py-2 text-sm font-semibold text-foreground hover:bg-accent"
                  >
                    {t('components.checkintemplatespanel.cancel')}
                  </button>
                  <button
                    onClick={handleCreate}
                    disabled={createTemplate.isPending || !title.trim()}
                    className="rounded-xl bg-primary px-5 py-2 text-sm font-bold text-primary-foreground disabled:opacity-50"
                  >
                    {createTemplate.isPending
                      ? t('components.checkintemplatespanel.creating')
                      : t('components.checkintemplatespanel.create_template')}
                  </button>
                </div>
              </div>
            </div>
          </div>,
          document.body,
        )}

      <ConfirmDialog
        open={deleteConfirm !== null}
        title={t('components.checkintemplatespanel.delete_template')}
        message={t('components.checkintemplatespanel.this_action_cannot_be_undone_the_template_will_be_permanently_removed')}
        onConfirm={() => {
          if (deleteConfirm) deleteTemplate.mutate(deleteConfirm);
          setDeleteConfirm(null);
        }}
        onCancel={() => setDeleteConfirm(null)}
        loading={deleteTemplate.isPending}
      />
    </div>
  );
};
