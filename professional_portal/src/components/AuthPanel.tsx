import React, { useState } from 'react';
import { z } from 'zod';
import {
  ArrowRight,
  Lock,
  Mail,
  Send,
  ShieldCheck,
  UserCheck,
} from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { toast } from '../lib/toast';
import { usePortalI18n } from '../lib/portal-i18n';

type AuthMode = 'magic-link' | 'password' | 'signup';

export const AuthPanel: React.FC = () => {
  const { login, loginWithPassword, signUpWithPassword } = useAuth();
  const { t } = usePortalI18n();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [authMode, setAuthMode] = useState<AuthMode>('magic-link');
  const [loading, setLoading] = useState(false);
  const [successState, setSuccessState] = useState<
    null | 'magic_link_sent' | 'signup_confirmation_sent'
  >(null);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  const resetTransientState = (mode: AuthMode) => {
    setAuthMode(mode);
    setFieldErrors({});
    setSuccessState(null);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFieldErrors({});

    const emailResult = z.string().email().safeParse(email.trim());
    if (!emailResult.success) {
      setFieldErrors({
        email: t('components.authpanel.please_enter_a_valid_email_address'),
      });
      return;
    }
    const cleanEmail = emailResult.data;

    if (authMode !== 'magic-link') {
      if (!password) {
        setFieldErrors({
          password: t('components.authpanel.password_is_required'),
        });
        return;
      }
      if (password.length < 8) {
        setFieldErrors({
          password: t('components.authpanel.password_must_be_at_least_8_characters'),
        });
        return;
      }
    }

    if (authMode === 'signup') {
      if (!confirmPassword) {
        setFieldErrors({
          confirmPassword: t('components.authpanel.confirm_the_password_to_create_the_account'),
        });
        return;
      }
      if (confirmPassword !== password) {
        setFieldErrors({
          confirmPassword: t('components.authpanel.passwords_do_not_match'),
        });
        return;
      }
    }

    setLoading(true);

    if (authMode === 'magic-link') {
      const { error } = await login(cleanEmail);
      if (error) {
        toast.error(error.message);
      } else {
        setSuccessState('magic_link_sent');
      }
      setLoading(false);
      return;
    }

    if (authMode === 'signup') {
      const { error, requiresEmailConfirmation } = await signUpWithPassword(cleanEmail, password);
      if (error) {
        toast.error(error.message);
      } else if (requiresEmailConfirmation) {
        setSuccessState('signup_confirmation_sent');
      } else {
        toast.success(
          t('components.authpanel.account_created_you_can_now_complete_your_professional_profile'),
        );
      }
      setLoading(false);
      return;
    }

    const { error } = await loginWithPassword(cleanEmail, password);
    if (error) {
      toast.error(error.message);
    }
    setLoading(false);
  };

  const title =
    authMode === 'signup'
      ? t('components.authpanel.create_your_professional_access')
      : t('components.authpanel.sign_in_to_your_professional_portal');

  const body =
    authMode === 'signup'
      ? t('components.authpanel.first_create_the_account_in_supabase_auth_after_that_you_can_save_the_pr')
      : t('components.authpanel.access_your_real_roster_plans_follow_up_and_practice_operations');

  return (
    <div className="glass-card rounded-[2rem] p-8 md:p-10">
      <div className="mb-8">
        <p className="portal-kicker">{t('components.authpanel.professional_access')}</p>
        <h2 className="portal-title mt-3 text-foreground">{title}</h2>
        <p className="portal-body mt-3 max-w-md">{body}</p>
      </div>

      <div className="mb-8 grid grid-cols-3 gap-2">
        <button
          type="button"
          disabled={loading}
          onClick={() => resetTransientState('magic-link')}
          className={`portal-meta flex items-center justify-center gap-2 rounded-xl px-4 py-3 transition-colors ${
            authMode === 'magic-link'
              ? 'bg-primary text-primary-foreground'
              : 'portal-soft-panel text-foreground'
          }`}
        >
          <Send className="h-4 w-4" />
          {t('components.authpanel.magic_link')}
        </button>
        <button
          type="button"
          disabled={loading}
          onClick={() => resetTransientState('password')}
          className={`portal-meta flex items-center justify-center gap-2 rounded-xl px-4 py-3 transition-colors ${
            authMode === 'password'
              ? 'bg-primary text-primary-foreground'
              : 'portal-soft-panel text-foreground'
          }`}
        >
          <Lock className="h-4 w-4" />
          {t('components.authpanel.password')}
        </button>
        <button
          type="button"
          disabled={loading}
          onClick={() => resetTransientState('signup')}
          className={`portal-meta flex items-center justify-center gap-2 rounded-xl px-4 py-3 transition-colors ${
            authMode === 'signup'
              ? 'bg-primary text-primary-foreground'
              : 'portal-soft-panel text-foreground'
          }`}
        >
          <UserCheck className="h-4 w-4" />
          {t('components.authpanel.create_account')}
        </button>
      </div>

      {successState ? (
        <div className="portal-soft-panel rounded-2xl p-6 text-center">
          <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-primary/12 text-primary">
            <Send className="h-5 w-5" />
          </div>
          <h4 className="portal-card-heading mt-4">
            {successState === 'magic_link_sent'
              ? t('components.authpanel.magic_link_sent')
              : t('components.authpanel.account_created')}
          </h4>
          <p className="portal-body mt-2">
            {successState === 'magic_link_sent'
              ? t('components.authpanel.check_to_complete_sign_in', { email: email })
              : t('components.authpanel.check_and_confirm_the_email_before_saving_the_profile_if_your_project_re', { email: email })}
          </p>
          <button
            type="button"
            onClick={() => {
              setSuccessState(null);
              setFieldErrors({});
            }}
            className="portal-meta mt-5 w-full rounded-xl border border-border bg-background px-4 py-3 text-foreground transition-colors hover:bg-accent"
          >
            {t('components.authpanel.back')}
          </button>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <label className="portal-label">
              {t('components.authpanel.professional_email')}
            </label>
            <div className="relative">
              <Mail className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <input
                type="email"
                placeholder={t('components.authpanel.professional_email_placeholder')}
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                disabled={loading}
                className="portal-input h-14 w-full rounded-xl py-3 pl-12 pr-4 outline-none transition-colors focus:border-primary"
              />
            </div>
            {fieldErrors.email && (
              <p className="portal-meta text-red-500">{fieldErrors.email}</p>
            )}
          </div>

          {authMode !== 'magic-link' && (
            <div className="space-y-2">
              <label className="portal-label">
                {t('components.authpanel.password')}
              </label>
              <div className="relative">
                <Lock className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <input
                  type="password"
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  disabled={loading}
                  className="portal-input h-14 w-full rounded-xl py-3 pl-12 pr-4 outline-none transition-colors focus:border-primary"
                />
              </div>
              {fieldErrors.password && (
                <p className="portal-meta text-red-500">{fieldErrors.password}</p>
              )}
            </div>
          )}

          {authMode === 'signup' && (
            <div className="space-y-2">
              <label className="portal-label">
                {t('components.authpanel.confirm_password')}
              </label>
              <div className="relative">
                <Lock className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <input
                  type="password"
                  placeholder="••••••••"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  disabled={loading}
                  className="portal-input h-14 w-full rounded-xl py-3 pl-12 pr-4 outline-none transition-colors focus:border-primary"
                />
              </div>
              {fieldErrors.confirmPassword && (
                <p className="portal-meta text-red-500">{fieldErrors.confirmPassword}</p>
              )}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="portal-action mt-4 flex h-14 w-full items-center justify-center gap-2 rounded-xl bg-primary px-4 text-primary-foreground transition-opacity hover:opacity-95 disabled:opacity-50"
          >
            {loading
              ? t('components.authpanel.sending')
              : authMode === 'magic-link'
                ? t('components.authpanel.send_magic_link')
                : authMode === 'password'
                  ? t('components.authpanel.sign_in')
                  : t('components.authpanel.create_account')}
            {!loading && <ArrowRight className="h-4 w-4" />}
          </button>
        </form>
      )}

      <div className="mt-8 grid gap-3 border-t border-border pt-6 sm:grid-cols-2">
        <div className="portal-soft-panel flex items-center gap-3 rounded-2xl p-4">
          <ShieldCheck className="h-5 w-5 text-primary" />
          <div>
            <p className="portal-meta text-foreground">
              {t('components.authpanel.encrypted_connection')}
            </p>
            <p className="portal-meta">
              {t('components.authpanel.authenticated_with_supabase')}
            </p>
          </div>
        </div>
        <div className="portal-soft-panel flex items-center gap-3 rounded-2xl p-4">
          <UserCheck className="h-5 w-5 text-primary" />
          <div>
            <p className="portal-meta text-foreground">
              {t('components.authpanel.protected_data')}
            </p>
            <p className="portal-meta">
              {t('components.authpanel.visibility_depends_on_the_active_relationship_and_consent')}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
