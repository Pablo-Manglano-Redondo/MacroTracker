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
  const { tr } = usePortalI18n();
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
        email: tr('Introduce un correo electrónico válido.', 'Please enter a valid email address.'),
      });
      return;
    }
    const cleanEmail = emailResult.data;

    if (authMode !== 'magic-link') {
      if (!password) {
        setFieldErrors({
          password: tr('La contraseña es obligatoria.', 'Password is required.'),
        });
        return;
      }
      if (password.length < 8) {
        setFieldErrors({
          password: tr(
            'La contraseña debe tener al menos 8 caracteres.',
            'Password must be at least 8 characters.',
          ),
        });
        return;
      }
    }

    if (authMode === 'signup') {
      if (!confirmPassword) {
        setFieldErrors({
          confirmPassword: tr(
            'Confirma la contraseña para crear la cuenta.',
            'Confirm the password to create the account.',
          ),
        });
        return;
      }
      if (confirmPassword !== password) {
        setFieldErrors({
          confirmPassword: tr(
            'Las contraseñas no coinciden.',
            'Passwords do not match.',
          ),
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
          tr(
            'Cuenta creada. Ya puedes completar tu perfil profesional.',
            'Account created. You can now complete your professional profile.',
          ),
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
      ? tr('Crea tu acceso profesional.', 'Create your professional access.')
      : tr('Entra en tu portal profesional.', 'Sign in to your professional portal.');

  const body =
    authMode === 'signup'
      ? tr(
          'Primero crea la cuenta en Supabase Auth. Después podrás guardar el perfil profesional sin chocar con la FK de `professionals.user_id`.',
          'First create the account in Supabase Auth. After that you can save the professional profile without hitting the `professionals.user_id` foreign key.',
        )
      : tr(
          'Accede al roster real, los planes, el seguimiento y la configuración operativa de tu consulta.',
          'Access your real roster, plans, follow-up, and practice operations.',
        );

  return (
    <div className="glass-card rounded-[2rem] p-8 md:p-10">
      <div className="mb-8">
        <p className="portal-kicker">{tr('Acceso profesional', 'Professional access')}</p>
        <h2 className="portal-title mt-3 text-3xl text-foreground">{title}</h2>
        <p className="mt-3 max-w-md text-sm leading-relaxed text-muted-foreground">{body}</p>
      </div>

      <div className="mb-8 grid grid-cols-3 gap-2">
        <button
          type="button"
          disabled={loading}
          onClick={() => resetTransientState('magic-link')}
          className={`flex items-center justify-center gap-2 rounded-xl px-4 py-3 text-sm font-semibold transition-colors ${
            authMode === 'magic-link'
              ? 'bg-primary text-primary-foreground'
              : 'portal-soft-panel text-foreground'
          }`}
        >
          <Send className="h-4 w-4" />
          {tr('Magic link', 'Magic link')}
        </button>
        <button
          type="button"
          disabled={loading}
          onClick={() => resetTransientState('password')}
          className={`flex items-center justify-center gap-2 rounded-xl px-4 py-3 text-sm font-semibold transition-colors ${
            authMode === 'password'
              ? 'bg-primary text-primary-foreground'
              : 'portal-soft-panel text-foreground'
          }`}
        >
          <Lock className="h-4 w-4" />
          {tr('Contraseña', 'Password')}
        </button>
        <button
          type="button"
          disabled={loading}
          onClick={() => resetTransientState('signup')}
          className={`flex items-center justify-center gap-2 rounded-xl px-4 py-3 text-sm font-semibold transition-colors ${
            authMode === 'signup'
              ? 'bg-primary text-primary-foreground'
              : 'portal-soft-panel text-foreground'
          }`}
        >
          <UserCheck className="h-4 w-4" />
          {tr('Crear cuenta', 'Create account')}
        </button>
      </div>

      {successState ? (
        <div className="portal-soft-panel rounded-2xl p-6 text-center">
          <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-primary/12 text-primary">
            <Send className="h-5 w-5" />
          </div>
          <h4 className="mt-4 text-lg font-bold text-foreground">
            {successState === 'magic_link_sent'
              ? tr('Enlace enviado', 'Magic link sent')
              : tr('Cuenta creada', 'Account created')}
          </h4>
          <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
            {successState === 'magic_link_sent'
              ? tr(
                  `Revisa la bandeja de entrada de ${email} para completar el acceso.`,
                  `Check ${email} to complete sign-in.`,
                )
              : tr(
                  `Revisa ${email} y confirma el correo antes de guardar el perfil, si tu proyecto exige verificación por email.`,
                  `Check ${email} and confirm the email before saving the profile if your project requires email verification.`,
                )}
          </p>
          <button
            type="button"
            onClick={() => {
              setSuccessState(null);
              setFieldErrors({});
            }}
            className="mt-5 w-full rounded-xl border border-border bg-background px-4 py-3 text-sm font-semibold text-foreground transition-colors hover:bg-accent"
          >
            {tr('Volver', 'Back')}
          </button>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <label className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">
              {tr('Correo profesional', 'Professional email')}
            </label>
            <div className="relative">
              <Mail className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <input
                type="email"
                placeholder="nombre@dominio.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                disabled={loading}
                className="portal-input h-14 w-full rounded-xl py-3 pl-12 pr-4 text-sm font-medium outline-none transition-colors focus:border-primary"
              />
            </div>
            {fieldErrors.email && (
              <p className="text-xs font-semibold text-red-500">{fieldErrors.email}</p>
            )}
          </div>

          {authMode !== 'magic-link' && (
            <div className="space-y-2">
              <label className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">
                {tr('Contraseña', 'Password')}
              </label>
              <div className="relative">
                <Lock className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <input
                  type="password"
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  disabled={loading}
                  className="portal-input h-14 w-full rounded-xl py-3 pl-12 pr-4 text-sm font-medium outline-none transition-colors focus:border-primary"
                />
              </div>
              {fieldErrors.password && (
                <p className="text-xs font-semibold text-red-500">{fieldErrors.password}</p>
              )}
            </div>
          )}

          {authMode === 'signup' && (
            <div className="space-y-2">
              <label className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">
                {tr('Confirmar contraseña', 'Confirm password')}
              </label>
              <div className="relative">
                <Lock className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <input
                  type="password"
                  placeholder="••••••••"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  disabled={loading}
                  className="portal-input h-14 w-full rounded-xl py-3 pl-12 pr-4 text-sm font-medium outline-none transition-colors focus:border-primary"
                />
              </div>
              {fieldErrors.confirmPassword && (
                <p className="text-xs font-semibold text-red-500">{fieldErrors.confirmPassword}</p>
              )}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="mt-4 flex h-14 w-full items-center justify-center gap-2 rounded-xl bg-primary px-4 text-sm font-bold text-primary-foreground transition-opacity hover:opacity-95 disabled:opacity-50"
          >
            {loading
              ? tr('Enviando...', 'Sending...')
              : authMode === 'magic-link'
                ? tr('Enviar magic link', 'Send magic link')
                : authMode === 'password'
                  ? tr('Entrar', 'Sign in')
                  : tr('Crear cuenta', 'Create account')}
            {!loading && <ArrowRight className="h-4 w-4" />}
          </button>
        </form>
      )}

      <div className="mt-8 grid gap-3 border-t border-border pt-6 sm:grid-cols-2">
        <div className="portal-soft-panel flex items-center gap-3 rounded-2xl p-4">
          <ShieldCheck className="h-5 w-5 text-primary" />
          <div>
            <p className="text-sm font-semibold text-foreground">
              {tr('Conexión cifrada', 'Encrypted connection')}
            </p>
            <p className="text-xs text-muted-foreground">
              {tr('Acceso autenticado con Supabase.', 'Authenticated with Supabase.')}
            </p>
          </div>
        </div>
        <div className="portal-soft-panel flex items-center gap-3 rounded-2xl p-4">
          <UserCheck className="h-5 w-5 text-primary" />
          <div>
            <p className="text-sm font-semibold text-foreground">
              {tr('Datos protegidos', 'Protected data')}
            </p>
            <p className="text-xs text-muted-foreground">
              {tr(
                'La visibilidad depende de la relación activa y del consentimiento.',
                'Visibility depends on the active relationship and consent.',
              )}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
