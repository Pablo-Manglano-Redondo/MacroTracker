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
import { ConfirmDialog } from '../ui/confirm-dialog';
import { usePortalI18n } from '../../lib/portal-i18n';

const CATEGORIES = ['general', 'assessment', 'medical', 'progress', 'billing', 'other'] as const;

export const ClientNotes: React.FC<{ client: ProfessionalClient }> = ({ client }) => {
  const { tr, locale } = usePortalI18n();
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
      toast.error(tr('El cuerpo de la nota es obligatorio', 'Note body required'));
      return;
    }
    try {
      await createNote.mutateAsync({
        professional_client_id: client.id,
        professional_id: client.professional_id,
        title: title.trim() || tr('Nota', 'Note'),
        body: body.trim(),
        category: category as any,
        pinned: false,
      });
      setShowForm(false);
      setTitle('');
      setBody('');
      setCategory('general');
      toast.success(tr('Nota creada', 'Note created'));
    } catch {
      toast.error(tr('No se pudo crear la nota', 'Failed to create note'));
    }
  };

  const categoryLabel = (value: string) =>
    ({
      general: tr('General', 'General'),
      assessment: tr('Evaluación', 'Assessment'),
      medical: tr('Médico', 'Medical'),
      progress: tr('Progreso', 'Progress'),
      billing: tr('Facturación', 'Billing'),
      other: tr('Otro', 'Other'),
    })[value] ?? value;

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between border-b border-border pb-3">
        <div className="flex items-center gap-2">
          <FileText className="h-4.5 w-4.5 text-primary" />
          <h3 className="text-base font-bold text-foreground">{tr('Notas del cliente', 'Client notes')}</h3>
        </div>
        <button
          onClick={() => setShowForm(true)}
          className="inline-flex items-center gap-1 rounded-xl bg-primary px-3 py-1.5 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground"
        >
          <Plus className="h-3.5 w-3.5" />
          {tr('Nueva nota', 'New note')}
        </button>
      </div>

      {showForm && (
        <div className="portal-panel rounded-[1.4rem] p-4">
          <div className="space-y-3">
            <input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder={tr('Título de la nota', 'Note title')}
              className="portal-input h-10 w-full rounded-xl px-3 text-sm font-medium outline-none focus:border-primary"
            />
            <textarea
              value={body}
              onChange={(e) => setBody(e.target.value)}
              placeholder={tr('Escribe la nota...', 'Write the note...')}
              rows={4}
              className="portal-input w-full rounded-xl px-3 py-3 text-sm font-medium outline-none focus:border-primary"
            />
            <div className="flex items-center justify-between gap-2">
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="portal-input rounded-xl px-3 py-2 text-sm font-semibold outline-none"
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
                  className="rounded-xl border border-border px-3 py-2 text-sm font-semibold text-foreground hover:bg-accent"
                >
                  {tr('Cancelar', 'Cancel')}
                </button>
                <button
                  onClick={handleCreate}
                  disabled={createNote.isPending}
                  className="rounded-xl bg-primary px-3 py-2 text-sm font-bold text-primary-foreground disabled:opacity-50"
                >
                  {tr('Guardar', 'Save')}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {error ? (
        <div className="portal-panel rounded-[1.4rem] p-8 text-center text-sm text-muted-foreground">
          {tr(
            'Las notas no se han podido cargar todavía. Este tab debe seguir siendo explícito hasta que exista dato real.',
            'Notes could not be loaded yet. This tab should remain explicit until real data exists.',
          )}
        </div>
      ) : isLoading ? (
        <div className="space-y-3">
          {[1, 2].map((index) => (
            <div key={index} className="portal-panel h-24 rounded-[1.4rem] animate-pulse" />
          ))}
        </div>
      ) : !sortedNotes.length ? (
        <div className="portal-panel rounded-[1.4rem] p-8 text-center text-sm text-muted-foreground">
          {tr('Todavía no hay notas para este cliente.', 'No notes exist for this client yet.')}
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
                      className="portal-input h-10 w-full rounded-xl px-3 text-sm font-medium outline-none focus:border-primary"
                    />
                    <textarea
                      value={editBody}
                      onChange={(e) => setEditBody(e.target.value)}
                      rows={3}
                      className="portal-input w-full rounded-xl px-3 py-3 text-sm font-medium outline-none focus:border-primary"
                    />
                    <div className="flex items-center justify-between gap-2">
                      <select
                        value={editCategory}
                        onChange={(e) => setEditCategory(e.target.value)}
                        className="portal-input rounded-xl px-3 py-2 text-sm font-semibold outline-none"
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
                              toast.success(tr('Nota actualizada', 'Note updated'));
                              setEditingId(null);
                            } catch {
                              toast.error(tr('No se pudo actualizar', 'Failed to update'));
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
                          <span className="truncate text-sm font-bold text-foreground">{note.title}</span>
                          <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.16em] ${categoryTone}`}>
                            {categoryLabel(note.category || 'general')}
                          </span>
                        </div>
                        <p className="mt-3 whitespace-pre-wrap text-sm leading-relaxed text-muted-foreground">
                          {note.body}
                        </p>
                        <p className="mt-3 text-[11px] font-semibold text-muted-foreground">
                          {tr('Creada', 'Created')}{' '}
                          {new Date(note.created_at).toLocaleDateString(locale === 'es' ? 'es-ES' : 'en-US', {
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
        title={tr('Eliminar nota', 'Delete note')}
        message={tr(
          'Esta acción no se puede deshacer. La nota se eliminará permanentemente.',
          'This action cannot be undone. The note will be permanently removed.',
        )}
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
