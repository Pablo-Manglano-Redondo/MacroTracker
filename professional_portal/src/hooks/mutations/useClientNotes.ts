import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { notesRepository } from '../../repositories/notes.repository';
import type { ClientNote } from '../../types/database.types';

export function useCreateNote(professionalClientId: string | undefined) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (note: Parameters<typeof notesRepository.create>[1]) =>
      notesRepository.create(supabase, note),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['client-notes', professionalClientId] });
    },
  });
}

export function useDeleteNote(professionalClientId: string | undefined) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => notesRepository.remove(supabase, id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['client-notes', professionalClientId] });
    },
  });
}

export function useUpdateNote(professionalClientId: string | undefined) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, updates }: { id: string; updates: Partial<ClientNote> }) =>
      notesRepository.update(supabase, id, updates),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['client-notes', professionalClientId] });
    },
  });
}
