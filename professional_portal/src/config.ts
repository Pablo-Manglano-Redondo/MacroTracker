interface SupabaseConfig {
  url: string;
  anonKey: string;
}

declare global {
  interface Window {
    MT_SUPABASE_CONFIG?: SupabaseConfig;
  }
}

const getEnvConfig = (): SupabaseConfig => {
  const windowConfig = (window.MT_SUPABASE_CONFIG || {}) as Partial<SupabaseConfig>;
  
  return {
    url: windowConfig.url || ((import.meta as any).env?.VITE_SUPABASE_URL as string) || '',
    anonKey: windowConfig.anonKey || ((import.meta as any).env?.VITE_SUPABASE_ANON_KEY as string) || '',
  };
};

export const supabaseConfig = getEnvConfig();
