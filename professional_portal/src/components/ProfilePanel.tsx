import React, { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Briefcase, Check, HeartHandshake, ShieldCheck, User } from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { profileSchema, type ProfileFormData } from '../lib/validation/schemas';
import { useUpdateProfile } from '../hooks/mutations/useUpdateProfile';
import { toast } from '../lib/toast';
import { usePortalI18n } from '../lib/portal-i18n';

export const ProfilePanel: React.FC = () => {
  const { user, professional, refreshProfile } = useAuth();
  const { tr, locale } = usePortalI18n();
  const updateProfile = useUpdateProfile();

  const {
    register,
    handleSubmit,
    reset,
    watch,
    formState: { errors },
  } = useForm<ProfileFormData>({
    resolver: zodResolver(profileSchema),
    defaultValues: { displayName: '', businessName: '' },
  });

  const displayNameVal = watch('displayName') || '';
  const initials = displayNameVal
    ? displayNameVal
        .trim()
        .split(/\s+/)
        .map((n) => n[0])
        .join('')
        .slice(0, 2)
        .toUpperCase()
    : 'PR';

  useEffect(() => {
    if (professional) {
      reset({
        displayName: professional.display_name || '',
        businessName: professional.business_name || '',
      });
    }
  }, [professional, reset]);

  const onSubmit = async (data: ProfileFormData) => {
    if (!user) {
      return;
    }

    try {
      await updateProfile.mutateAsync({
        user_id: user.id,
        display_name: data.displayName,
        business_name: data.businessName || undefined,
      });
      await refreshProfile();
      toast.success(tr('Perfil guardado', 'Profile saved'));
    } catch (err: any) {
      const rawMessage = String(err?.message || '');
      const description = rawMessage.includes('professionals_user_id_fkey')
        ? tr(
            'La sesión actual no corresponde a un usuario válido de Supabase Auth. Cierra sesión, crea la cuenta desde "Crear cuenta" o vuelve a iniciar sesión, y luego guarda el perfil.',
            'The current session does not match a valid Supabase Auth user. Sign out, create the account from "Create account" or sign in again, and then save the profile.',
          )
        : rawMessage.includes('Auth session is missing') || rawMessage.includes('out of sync')
          ? tr(
              'La sesión local ya no es válida. Vuelve a iniciar sesión antes de guardar el perfil.',
              'The local session is no longer valid. Sign in again before saving the profile.',
            )
          : err?.message || tr('Error desconocido', 'Unknown error');

      toast.error(tr('No se pudo guardar el perfil', 'Failed to save profile'), {
        description,
      });
    }
  };

  return (
    <div className="space-y-6 select-none animate-fade-in-up">
      <section className="portal-hero rounded-[1.8rem] p-6">
        <div className="space-y-2">
          <p className="portal-kicker">{tr('Perfil profesional', 'Professional profile')}</p>
          <h2 className="portal-title text-3xl text-foreground">
            {tr(
              'Identidad, práctica y marco de confianza.',
              'Identity, practice, and trust framework.',
            )}
          </h2>
          <p className="max-w-3xl text-sm leading-relaxed text-muted-foreground">
            {tr(
              'Gestiona cómo se presenta la consulta dentro del portal y mantén claro el marco operativo: relación activa, consentimiento y límites de acceso.',
              'Manage how the practice appears inside the portal and keep the operating framework clear: active relationship, consent, and access boundaries.',
            )}
          </p>
        </div>
      </section>

      <div className="grid gap-6 lg:grid-cols-[minmax(0,1.05fr)_minmax(320px,0.8fr)]">
        <section className="portal-panel rounded-[1.6rem] overflow-hidden">
          <div className="border-b border-border px-6 py-5">
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/12 text-primary">
                <User className="h-5 w-5" />
              </div>
              <div>
                <h3 className="text-base font-bold text-foreground">
                  {tr('Datos del profesional', 'Professional details')}
                </h3>
                <p className="text-xs text-muted-foreground">
                  {tr(
                    'Información visible dentro del portal y en flujos relacionados.',
                    'Information visible inside the portal and related flows.',
                  )}
                </p>
              </div>
            </div>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="grid gap-6 px-6 py-6 md:grid-cols-[180px_minmax(0,1fr)]">
            <div className="flex flex-col items-center justify-start gap-3">
              <div className="flex h-24 w-24 items-center justify-center rounded-[1.4rem] bg-primary text-2xl font-extrabold text-primary-foreground shadow-sm">
                {initials}
              </div>
              <div className="text-center">
                <p className="text-xs font-bold uppercase tracking-[0.16em] text-muted-foreground">
                  {tr('Vista previa', 'Preview')}
                </p>
                <p className="mt-1 text-sm text-muted-foreground">
                  {tr('Iniciales visibles', 'Visible initials')}
                </p>
              </div>
            </div>

            <div className="space-y-5">
              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">
                  {tr('Nombre visible', 'Display name')} *
                </label>
                <div className="relative">
                  <User className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <input
                    {...register('displayName')}
                    placeholder={tr('Ej. Marta López', 'E.g. Marta Lopez')}
                    disabled={updateProfile.isPending}
                    className="portal-input h-11 w-full rounded-xl pl-10 pr-4 text-sm font-medium outline-none transition-colors focus:border-primary"
                  />
                </div>
                {errors.displayName && (
                  <p className="text-xs font-semibold text-red-500">{errors.displayName.message}</p>
                )}
              </div>

              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">
                  {tr('Nombre de la consulta', 'Business name')}
                </label>
                <div className="relative">
                  <Briefcase className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <input
                    {...register('businessName')}
                    placeholder={tr('Ej. Consulta Nutricional Norte', 'E.g. North Nutrition Practice')}
                    disabled={updateProfile.isPending}
                    className="portal-input h-11 w-full rounded-xl pl-10 pr-4 text-sm font-medium outline-none transition-colors focus:border-primary"
                  />
                </div>
              </div>

              <div className="grid gap-3 rounded-2xl border border-border bg-background/60 p-4 md:grid-cols-2">
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                    {tr('Usuario', 'User')}
                  </p>
                  <p className="mt-1 text-sm font-semibold text-foreground">
                    {user?.email || tr('No disponible', 'Unavailable')}
                  </p>
                </div>
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                    {tr('Última revisión', 'Last review')}
                  </p>
                  <p className="mt-1 text-sm font-semibold text-foreground">
                    {new Date().toLocaleDateString(locale === 'es' ? 'es-ES' : 'en-US')}
                  </p>
                </div>
              </div>

              <button
                type="submit"
                disabled={updateProfile.isPending}
                className="inline-flex h-11 items-center justify-center gap-2 rounded-xl bg-primary px-5 text-sm font-bold text-primary-foreground transition-opacity hover:opacity-95 disabled:opacity-50"
              >
                <Check className="h-4 w-4" />
                {updateProfile.isPending
                  ? tr('Guardando...', 'Saving...')
                  : tr('Guardar cambios', 'Save changes')}
              </button>
            </div>
          </form>
        </section>

        <section className="portal-panel rounded-[1.6rem] p-6">
          <div className="flex items-start justify-between gap-4">
            <div className="space-y-1">
              <div className="flex items-center gap-2">
                <HeartHandshake className="h-5 w-5 text-primary" />
                <h3 className="text-base font-bold text-foreground">
                  {tr('Privacidad y confianza', 'Privacy and trust')}
                </h3>
              </div>
              <p className="text-sm leading-relaxed text-muted-foreground">
                {tr(
                  'El portal no debe sugerir más visibilidad de la que realmente existe.',
                  'The portal should never imply more visibility than what really exists.',
                )}
              </p>
            </div>
            <span className="inline-flex items-center gap-2 rounded-full bg-primary/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
              <span className="h-2 w-2 rounded-full bg-primary" />
              {tr('Activo', 'Active')}
            </span>
          </div>

          <div className="mt-5 space-y-3">
            {[
              tr(
                'Los snapshots aggregate son la base por defecto de cualquier relación activa.',
                'Aggregate snapshots are the default baseline for every active relationship.',
              ),
              tr(
                'El diario detailed solo aparece con consentimiento explícito del cliente.',
                'Detailed diary rows only appear with explicit client consent.',
              ),
              tr(
                'El cliente puede revocar la relación profesional en cualquier momento.',
                'The client can revoke the professional relationship at any moment.',
              ),
            ].map((item) => (
              <div key={item} className="portal-soft-panel flex items-start gap-3 rounded-2xl p-4">
                <div className="mt-0.5 flex h-6 w-6 items-center justify-center rounded-lg bg-primary/12 text-primary">
                  <Check className="h-3.5 w-3.5" />
                </div>
                <p className="text-sm leading-relaxed text-muted-foreground">{item}</p>
              </div>
            ))}
          </div>

          <div className="mt-5 rounded-2xl border border-border bg-background/60 p-4">
            <div className="flex items-center gap-2">
              <ShieldCheck className="h-4 w-4 text-primary" />
              <p className="text-sm font-semibold text-foreground">
                {tr('Contexto operativo', 'Operational context')}
              </p>
            </div>
            <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
              {tr(
                'Esta superficie está pensada para operación interna: roster, notas, planes y seguimiento. No es una página pública ni un escaparate comercial.',
                'This surface is intended for internal operations: roster, notes, plans, and follow-up. It is not a public page or a marketing surface.',
              )}
            </p>
          </div>
        </section>
      </div>
    </div>
  );
};
