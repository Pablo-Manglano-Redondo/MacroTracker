import { useQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { notesRepository } from '../../repositories/notes.repository';

export function useClientNotes(professionalClientId: string | undefined) {
  return useQuery({
    queryKey: ['client-notes', professionalClientId],
    queryFn: () => notesRepository.listByClient(supabase, professionalClientId!),
    enabled: !!professionalClientId,
    staleTime: 10_000,
  });
}
