import React, { useState } from 'react';
import type { ProfessionalClient, ClientNote } from '../../types/database.types';
import { useClientNotes } from '../../hooks/queries/useClientNotes';
import { useCreateNote, useDeleteNote, useUpdateNote } from '../../hooks/mutations/useClientNotes';
import { Plus, Pin, Trash2, FileText, Pencil, X, Check } from 'lucide-react';
import { toast } from 'sonner';
import { ConfirmDialog } from '../ui/confirm-dialog';

const CATEGORIES = ['general', 'assessment', 'medical', 'progress', 'billing', 'other'] as const;

export const ClientNotes: React.FC<{ client: ProfessionalClient }> = ({ client }) => {
  const { data: notes, isLoading } = useClientNotes(client.id);
  const createNote = useCreateNote(client.id);
  const deleteNote = useDeleteNote(client.id);
  const [showForm, setShowForm] = useState(false);
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [category, setCategory] = useState<string>('general');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editTitle, setEditTitle] = useState('');
  const [editBody, setEditBody] = useState('');
  const [editCategory, setEditCategory] = useState<string>('general');
  const updateNote = useUpdateNote(client.id);
  const [deleteConfirm, setDeleteConfirm] = useState<string | null>(null);
  const startEdit = (note: ClientNote) => {
    setEditingId(note.id);
    setEditTitle(note.title);
    setEditBody(note.body);
    setEditCategory(note.category || 'general');
  };

  const handleCreate = async () => {
    if (!body.trim()) { toast.error('Note body required'); return; }
    try {
      await createNote.mutateAsync({
        professional_client_id: client.id,
        professional_id: client.professional_id,
        title: title.trim() || 'Note',
        body: body.trim(),
        category: category as any,
        pinned: false,
      });
      setShowForm(false); setTitle(''); setBody(''); setCategory('general');
      toast.success('Note created');
    } catch { toast.error('Failed to create note'); }
  };

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <h4 className="text-sm font-bold flex items-center gap-1.5">
          <FileText className="w-4 h-4 text-primary" />
          Notes
        </h4>
        <button onClick={() => setShowForm(true)}
          className="flex items-center gap-1 px-2.5 py-1 text-[11px] rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors">
          <Plus className="w-3 h-3" /> Add Note
        </button>
      </div>

      {showForm && (
        <div className="rounded-xl border bg-card p-4 space-y-3 card-elevated">
          <input value={title} onChange={e => setTitle(e.target.value)} placeholder="Note title..."
            className="w-full px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
          <textarea value={body} onChange={e => setBody(e.target.value)} placeholder="Write your note..." rows={4}
            className="w-full px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
          <div className="flex items-center justify-between gap-2">
            <select value={category} onChange={e => setCategory(e.target.value)}
              className="px-2.5 py-1 text-[11px] rounded-lg border bg-background focus:outline-none">
              {CATEGORIES.map(c => (
                <option key={c} value={c}>{c.charAt(0).toUpperCase() + c.slice(1)}</option>
              ))}
            </select>
            <div className="flex gap-2">
              <button onClick={() => setShowForm(false)}
                className="px-3 py-1 text-[11px] rounded-lg border hover:bg-secondary transition-colors">Cancel</button>
              <button onClick={handleCreate} disabled={createNote.isPending}
                className="px-3 py-1 text-[11px] rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors disabled:opacity-50">
                Save
              </button>
            </div>
          </div>
        </div>
      )}

      {isLoading ? (
        <div className="space-y-2">{[1,2].map(i => <div key={i} className="h-20 rounded-xl bg-muted/30 animate-pulse" />)}</div>
      ) : !notes?.length ? (
        <p className="text-xs text-muted-foreground text-center py-6">No notes yet</p>
      ) : (
        <div className="space-y-2">
          {notes.map(note => (
            <div key={note.id} className={`rounded-xl border bg-card p-3.5 space-y-2 card-elevated ${note.pinned ? 'ring-1 ring-primary/20' : ''}`}>
              {editingId === note.id ? (
                <div className="space-y-2">
                  <input value={editTitle} onChange={e => setEditTitle(e.target.value)}
                    className="w-full px-2 py-1 text-xs rounded border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                  <textarea value={editBody} onChange={e => setEditBody(e.target.value)} rows={3}
                    className="w-full px-2 py-1 text-xs rounded border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                  <div className="flex items-center justify-between gap-2">
                    <select value={editCategory} onChange={e => setEditCategory(e.target.value)}
                      className="px-2 py-1 text-[11px] rounded border bg-background focus:outline-none">
                      {CATEGORIES.map(c => (
                        <option key={c} value={c}>{c.charAt(0).toUpperCase() + c.slice(1)}</option>
                      ))}
                    </select>
                    <div className="flex gap-1">
                      <button onClick={async () => {
                        try {
                          await updateNote.mutateAsync({ id: note.id, updates: { title: editTitle, body: editBody, category: editCategory as ClientNote['category'] } });
                          toast.success('Note updated');
                          setEditingId(null);
                        } catch { toast.error('Failed to update'); }
                      }} disabled={updateNote.isPending}
                        className="p-1 rounded-md text-primary hover:bg-primary/10 transition-colors">
                        <Check className="w-3.5 h-3.5" />
                      </button>
                      <button onClick={() => setEditingId(null)}
                        className="p-1 rounded-md text-muted-foreground hover:bg-secondary transition-colors">
                        <X className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>
                </div>
              ) : (
                <>
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex items-center gap-2 min-w-0">
                      {note.pinned && <Pin className="w-3 h-3 text-primary shrink-0" />}
                      <span className="text-xs font-semibold truncate">{note.title}</span>
                      <span className="text-[10px] px-1.5 py-0.5 rounded-full bg-secondary text-muted-foreground shrink-0">
                        {note.category}
                      </span>
                    </div>
                    <div className="flex gap-1 shrink-0">
                      <button onClick={() => startEdit(note)}
                        className="p-1 rounded-md text-muted-foreground hover:text-primary hover:bg-primary/10 transition-colors">
                        <Pencil className="w-3 h-3" />
                      </button>
                      <button onClick={() => setDeleteConfirm(note.id)}
                        className="p-1 rounded-md text-muted-foreground hover:text-red-500 hover:bg-red-500/10 transition-colors">
                        <Trash2 className="w-3 h-3" />
                      </button>
                    </div>
                  </div>
                  <p className="text-xs text-muted-foreground whitespace-pre-wrap leading-relaxed">{note.body}</p>
                  <p className="text-[10px] text-muted-foreground/60">
                    {new Date(note.created_at).toLocaleDateString()}
                  </p>
                </>
              )}
            </div>
          ))}
        </div>
      )}

      <ConfirmDialog
        open={deleteConfirm !== null}
        title="Delete note"
        message="This action cannot be undone. The note will be permanently removed."
        onConfirm={() => { if (deleteConfirm) { deleteNote.mutate(deleteConfirm); setDeleteConfirm(null); } }}
        onCancel={() => setDeleteConfirm(null)}
        loading={deleteNote.isPending}
      />
    </div>
  );
};
