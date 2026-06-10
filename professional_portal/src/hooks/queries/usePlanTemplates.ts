import { useQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { planTemplateRepository } from '../../repositories/plan-template.repository';

export function usePlanTemplates(professionalId: string | undefined) {
  return useQuery({
    queryKey: ['plan-templates', professionalId],
    queryFn: () => planTemplateRepository.list(supabase, professionalId!),
    enabled: !!professionalId,
    staleTime: 60_000,
  });
}
