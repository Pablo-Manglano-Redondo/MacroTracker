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

  const profilePromisesRef = useRef<Record<string, Promise<any>>>({});

  const loadProfile = (userId: string) => {
    if (profilePromisesRef.current[userId]) {
      return profilePromisesRef.current[userId];
    }

    const promise = (async () => {
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
      } finally {
        delete profilePromisesRef.current[userId];
      }
    })();

    profilePromisesRef.current[userId] = promise;
    return promise;
  };

  const refreshProfile = async () => {
    if (user) {
      await loadProfile(user.id);
    }
  };

  useEffect(() => {
    let active = true;
    let isRetrying = false;

    const initialize = async () => {
      if (isRetrying) return;
      isRetrying = true;
      try {
        const timeoutPromise = new Promise<never>((_, reject) =>
          setTimeout(() => reject(new Error('Auth request timeout')), 2500)
        );

        const sessionPromise = supabase.auth.getSession();
        const { data: { session } } = await Promise.race([sessionPromise, timeoutPromise]);
        if (!active) return;

        setSession(session);
        setUser(session?.user ?? null);
        currentUserIdRef.current = session?.user?.id ?? null;

        if (session?.user) {
          const profilePromise = loadProfile(session.user.id);
          await Promise.race([profilePromise, timeoutPromise]);
        }

        if (active) {
          initializedRef.current = true;
          setLoading(false);
        }
      } catch (err) {
        console.warn('Auth initialization attempt failed, will retry:', err);
      } finally {
        isRetrying = false;
      }
    };

    initialize();

    const retryInterval = setInterval(() => {
      if (active && !initializedRef.current) {
        initialize();
      } else {
        clearInterval(retryInterval);
      }
    }, 3000);

    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (_event, currentSession) => {
      if (!active) return;

      const nextUserId = currentSession?.user?.id ?? null;
      const sameUser = currentUserIdRef.current === nextUserId;

      setSession(currentSession);
      setUser(currentSession?.user ?? null);

      if (nextUserId) {
        const shouldBlockUi = !initializedRef.current || !sameUser;
        if (shouldBlockUi) {
          setLoading(true);
        }

        try {
          const timeoutPromise = new Promise<never>((_, reject) =>
            setTimeout(() => reject(new Error('Profile request timeout')), 2500)
          );
          const profilePromise = loadProfile(nextUserId);
          await Promise.race([profilePromise, timeoutPromise]);
        } catch (err) {
          console.warn('Profile load failed or timed out:', err);
        }

        if (!active) return;

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
      active = false;
      clearInterval(retryInterval);
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
