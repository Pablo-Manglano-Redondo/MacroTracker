import React, { useMemo, useState } from 'react';
import { Check, FileText, Pencil, Pin, Plus, Trash2, X } from 'lucide-react';
import { toast } from 'sonner';
import type { ClientNote, ProfessionalClient } from '../../types/database.types';
import { useClientNotes } from '../../hooks/queries/useClientNotes';
import {
  useCreateNote,
  useDeleteNote,
  useUpdateNote,
} from '../../hooks/mutations/useClientNotes';
import { formatPortalDate } from '../../lib/date';
import { ConfirmDialog } from '../ui/confirm-dialog';
import { usePortalI18n } from '../../lib/portal-i18n';

const CATEGORIES = ['general', 'assessment', 'medical', 'progress', 'billing', 'other'] as const;

export const ClientNotes: React.FC<{ client: ProfessionalClient }> = ({ client }) => {
  const { t, locale } = usePortalI18n();
  const { data: notes, isLoading, error } = useClientNotes(client.id);
  const createNote = useCreateNote(client.id);
  const deleteNote = useDeleteNote(client.id);
  const updateNote = useUpdateNote(client.id);

  const [showForm, setShowForm] = useState(false);
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [category, setCategory] = useState<string>('general');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editTitle, setEditTitle] = useState('');
  const [editBody, setEditBody] = useState('');
  const [editCategory, setEditCategory] = useState<string>('general');
  const [deleteConfirm, setDeleteConfirm] = useState<string | null>(null);

  const sortedNotes = useMemo(
    () => [...(notes || [])].sort((a, b) => Number(b.pinned) - Number(a.pinned)),
    [notes],
  );

  const startEdit = (note: ClientNote) => {
    setEditingId(note.id);
    setEditTitle(note.title);
    setEditBody(note.body);
    setEditCategory(note.category || 'general');
  };

  const handleCreate = async () => {
    if (!body.trim()) {
      toast.error(t('components.clientdetail.clientnotes.note_body_required'));
      return;
    }
    try {
      await createNote.mutateAsync({
        professional_client_id: client.id,
        professional_id: client.professional_id,
        title: title.trim() || t('components.clientdetail.clientnotes.note'),
        body: body.trim(),
        category: category as any,
        pinned: false,
      });
      setShowForm(false);
      setTitle('');
      setBody('');
      setCategory('general');
      toast.success(t('components.clientdetail.clientnotes.note_created'));
    } catch {
      toast.error(t('components.clientdetail.clientnotes.failed_to_create_note'));
    }
  };

  const categoryLabel = (value: string) =>
    ({
      general: t('components.clientdetail.clientnotes.general'),
      assessment: t('components.clientdetail.clientnotes.assessment'),
      medical: t('components.clientdetail.clientnotes.medical'),
      progress: t('components.clientdetail.clientnotes.progress'),
      billing: t('components.clientdetail.clientnotes.billing'),
      other: t('components.clientdetail.clientnotes.other'),
    })[value] ?? value;

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between border-b border-border pb-3">
        <div className="flex items-center gap-2">
          <FileText className="h-4.5 w-4.5 text-primary" />
          <h3 className="portal-card-heading">{t('components.clientdetail.clientnotes.client_notes')}</h3>
        </div>
        <button
          onClick={() => setShowForm(true)}
          className="portal-action inline-flex items-center gap-1 rounded-xl bg-primary px-3 py-1.5 text-primary-foreground"
        >
          <Plus className="h-3.5 w-3.5" />
          {t('components.clientdetail.clientnotes.new_note')}
        </button>
      </div>

      {showForm && (
        <div className="portal-panel rounded-[1.4rem] p-4">
          <div className="space-y-3">
            <input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder={t('components.clientdetail.clientnotes.note_title')}
              className="portal-input h-10 w-full rounded-xl px-3 outline-none focus:border-primary"
            />
            <textarea
              value={body}
              onChange={(e) => setBody(e.target.value)}
              placeholder={t('components.clientdetail.clientnotes.write_the_note')}
              rows={4}
              className="portal-input w-full rounded-xl px-3 py-3 outline-none focus:border-primary"
            />
            <div className="flex items-center justify-between gap-2">
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="portal-input rounded-xl px-3 py-2 outline-none"
              >
                {CATEGORIES.map((item) => (
                  <option key={item} value={item}>
                    {categoryLabel(item)}
                  </option>
                ))}
              </select>
              <div className="flex gap-2">
                <button
                  onClick={() => setShowForm(false)}
                  className="portal-meta rounded-xl border border-border px-3 py-2 text-foreground hover:bg-accent"
                >
                  {t('components.clientdetail.clientnotes.cancel')}
                </button>
                <button
                  onClick={handleCreate}
                  disabled={createNote.isPending}
                  className="portal-action rounded-xl bg-primary px-3 py-2 text-primary-foreground disabled:opacity-50"
                >
                  {t('components.clientdetail.clientnotes.save')}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {error ? (
        <div className="portal-panel portal-body rounded-[1.4rem] p-8 text-center text-muted-foreground">
          {t('components.clientdetail.clientnotes.notes_could_not_be_loaded_yet_this_tab_should_remain_explicit_until_real')}
        </div>
      ) : isLoading ? (
        <div className="space-y-3">
          {[1, 2].map((index) => (
            <div key={index} className="portal-panel h-24 rounded-[1.4rem] animate-pulse" />
          ))}
        </div>
      ) : !sortedNotes.length ? (
        <div className="portal-panel portal-body rounded-[1.4rem] p-8 text-center text-muted-foreground">
          {t('components.clientdetail.clientnotes.no_notes_exist_for_this_client_yet')}
        </div>
      ) : (
        <div className="space-y-3">
          {sortedNotes.map((note) => {
            const categoryTone = {
              assessment: 'text-sky-600 dark:text-sky-300 bg-sky-500/10',
              medical: 'text-rose-600 dark:text-rose-300 bg-rose-500/10',
              progress: 'text-emerald-600 dark:text-emerald-300 bg-emerald-500/10',
              billing: 'text-amber-600 dark:text-amber-300 bg-amber-500/10',
              general: 'text-muted-foreground bg-background',
              other: 'text-violet-600 dark:text-violet-300 bg-violet-500/10',
            }[note.category || 'general'];

            return (
              <div
                key={note.id}
                className={`portal-panel rounded-[1.4rem] p-4 ${note.pinned ? 'border-l-4 border-l-primary' : ''}`}
              >
                {editingId === note.id ? (
                  <div className="space-y-3">
                    <input
                      value={editTitle}
                      onChange={(e) => setEditTitle(e.target.value)}
                      className="portal-input h-10 w-full rounded-xl px-3 outline-none focus:border-primary"
                    />
                    <textarea
                      value={editBody}
                      onChange={(e) => setEditBody(e.target.value)}
                      rows={3}
                      className="portal-input w-full rounded-xl px-3 py-3 outline-none focus:border-primary"
                    />
                    <div className="flex items-center justify-between gap-2">
                      <select
                        value={editCategory}
                        onChange={(e) => setEditCategory(e.target.value)}
                        className="portal-input rounded-xl px-3 py-2 outline-none"
                      >
                        {CATEGORIES.map((item) => (
                          <option key={item} value={item}>
                            {categoryLabel(item)}
                          </option>
                        ))}
                      </select>
                      <div className="flex gap-1">
                        <button
                          onClick={async () => {
                            try {
                              await updateNote.mutateAsync({
                                id: note.id,
                                updates: {
                                  title: editTitle,
                                  body: editBody,
                                  category: editCategory as ClientNote['category'],
                                },
                              });
                              toast.success(t('components.clientdetail.clientnotes.note_updated'));
                              setEditingId(null);
                            } catch {
                              toast.error(t('components.clientdetail.clientnotes.failed_to_update'));
                            }
                          }}
                          disabled={updateNote.isPending}
                          className="rounded-xl p-2 text-primary hover:bg-primary/10"
                        >
                          <Check className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => setEditingId(null)}
                          className="rounded-xl p-2 text-muted-foreground hover:bg-accent"
                        >
                          <X className="h-4 w-4" />
                        </button>
                      </div>
                    </div>
                  </div>
                ) : (
                  <>
                    <div className="flex items-start justify-between gap-2">
                      <div className="min-w-0">
                        <div className="flex items-center gap-2">
                          {note.pinned ? <Pin className="h-3.5 w-3.5 rotate-45 fill-primary/20 text-primary" /> : null}
                          <span className="portal-card-heading truncate">{note.title}</span>
                          <span className={`portal-pill rounded-full px-2 py-0.5 ${categoryTone}`}>
                            {categoryLabel(note.category || 'general')}
                          </span>
                        </div>
                        <p className="portal-body mt-3 whitespace-pre-wrap">
                          {note.body}
                        </p>
                        <p className="portal-meta mt-3">
                          {t('components.clientdetail.clientnotes.created')}{' '}
                          {formatPortalDate(note.created_at, locale, {
                            year: 'numeric',
                            month: 'short',
                            day: 'numeric',
                          })}
                        </p>
                      </div>
                      <div className="flex gap-1">
                        <button
                          onClick={() => startEdit(note)}
                          className="rounded-xl p-2 text-muted-foreground transition-colors hover:bg-primary/10 hover:text-primary"
                        >
                          <Pencil className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => setDeleteConfirm(note.id)}
                          className="rounded-xl p-2 text-muted-foreground transition-colors hover:bg-rose-500/10 hover:text-rose-500"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    </div>
                  </>
                )}
              </div>
            );
          })}
        </div>
      )}

      <ConfirmDialog
        open={deleteConfirm !== null}
        title={t('components.clientdetail.clientnotes.delete_note')}
        message={t('components.clientdetail.clientnotes.this_action_cannot_be_undone_the_note_will_be_permanently_removed')}
        onConfirm={() => {
          if (deleteConfirm) {
            deleteNote.mutate(deleteConfirm);
            setDeleteConfirm(null);
          }
        }}
        onCancel={() => setDeleteConfirm(null)}
        loading={deleteNote.isPending}
      />
    </div>
  );
};
