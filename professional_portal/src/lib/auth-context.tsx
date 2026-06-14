import React, { createContext, useContext, useEffect, useRef, useState } from 'react';
import { Session, User } from '@supabase/supabase-js';
import { supabase } from './supabase';
import { Professional } from '../types/database.types';

interface AuthContextType {
  session: Session | null;
  user: User | null;
  professional: Professional | null;
  loading: boolean;
  login: (email: string) => Promise<{ error: Error | null }>;
  loginWithPassword: (email: string, password: string) => Promise<{ error: Error | null }>;
  signUpWithPassword: (
    email: string,
    password: string,
  ) => Promise<{ error: Error | null; requiresEmailConfirmation: boolean }>;
  signOut: () => Promise<void>;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [session, setSession] = useState<Session | null>(null);
  const [user, setUser] = useState<User | null>(null);
  const [professional, setProfessional] = useState<Professional | null>(null);
  const [loading, setLoading] = useState(true);
  const initializedRef = useRef(false);
  const currentUserIdRef = useRef<string | null>(null);

  const loadProfile = async (userId: string) => {
    try {
      const { data, error } = await supabase
        .from('professionals')
        .select('*')
        .eq('user_id', userId)
        .maybeSingle();

      if (error) {
        console.error('Error loading professional profile:', error);
      } else {
        setProfessional(data);
      }
    } catch (err) {
      console.error('Failed to load profile:', err);
    }
  };

  const refreshProfile = async () => {
    if (user) {
      await loadProfile(user.id);
    }
  };

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);
      currentUserIdRef.current = session?.user?.id ?? null;
      if (session?.user) {
        loadProfile(session.user.id).finally(() => {
          initializedRef.current = true;
          setLoading(false);
        });
      } else {
        initializedRef.current = true;
        setLoading(false);
      }
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (_event, currentSession) => {
      const nextUserId = currentSession?.user?.id ?? null;
      const sameUser = currentUserIdRef.current === nextUserId;

      setSession(currentSession);
      setUser(currentSession?.user ?? null);

      if (nextUserId) {
        const shouldBlockUi = !initializedRef.current || !sameUser;
        if (shouldBlockUi) {
          setLoading(true);
        }

        await loadProfile(nextUserId);
        currentUserIdRef.current = nextUserId;
        initializedRef.current = true;

        if (shouldBlockUi) {
          setLoading(false);
        }
      } else {
        currentUserIdRef.current = null;
        initializedRef.current = true;
        setProfessional(null);
        setLoading(false);
      }
    });

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  const login = async (email: string) => {
    try {
      const { error } = await supabase.auth.signInWithOtp({
        email,
        options: { emailRedirectTo: window.location.href },
      });
      return { error: error as Error | null };
    } catch (err) {
      return { error: err as Error };
    }
  };

  const loginWithPassword = async (email: string, password: string) => {
    try {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });
      return { error: error as Error | null };
    } catch (err) {
      return { error: err as Error };
    }
  };

  const signUpWithPassword = async (email: string, password: string) => {
    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: { emailRedirectTo: window.location.href },
      });

      const requiresEmailConfirmation =
        !data.session &&
        !!data.user &&
        Array.isArray(data.user.identities) &&
        data.user.identities.length > 0;

      return { error: error as Error | null, requiresEmailConfirmation };
    } catch (err) {
      return { error: err as Error, requiresEmailConfirmation: false };
    }
  };

  const signOut = async () => {
    await supabase.auth.signOut();
    setSession(null);
    setUser(null);
    setProfessional(null);
  };

  return (
    <AuthContext.Provider
      value={{
        session,
        user,
        professional,
        loading,
        login,
        loginWithPassword,
        signUpWithPassword,
        signOut,
        refreshProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
