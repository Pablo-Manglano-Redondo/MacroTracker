import { useQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { diaryRepository } from '../../repositories/diary.repository';

export const diaryQueryKeys = {
  entries: (professionalClientId: string) => ['diary-entries', professionalClientId] as const,
};

export const useDiaryEntries = (professionalClientId: string) => {
  return useQuery({
    queryKey: diaryQueryKeys.entries(professionalClientId),
    queryFn: () => diaryRepository.listByClient(supabase, professionalClientId),
    enabled: !!professionalClientId,
    staleTime: 30_000,
  });
};
