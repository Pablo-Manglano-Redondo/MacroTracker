import React, { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Briefcase, Check, HeartHandshake, ShieldCheck, User } from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { profileSchema, type ProfileFormData } from '../lib/validation/schemas';
import { useUpdateProfile } from '../hooks/mutations/useUpdateProfile';
import { formatPortalDate } from '../lib/date';
import { toast } from '../lib/toast';
import { usePortalI18n } from '../lib/portal-i18n';

export const ProfilePanel: React.FC = () => {
  const { user, professional, refreshProfile } = useAuth();
  const { t, locale } = usePortalI18n();
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
      toast.success(t('components.profilepanel.profile_saved'));
    } catch (err: any) {
      const rawMessage = String(err?.message || '');
      const description = rawMessage.includes('professionals_user_id_fkey')
        ? t('components.profilepanel.the_current_session_does_not_match_a_valid_supabase_auth_user_sign_out_c')
        : rawMessage.includes('Auth session is missing') || rawMessage.includes('out of sync')
          ? t('components.profilepanel.the_local_session_is_no_longer_valid_sign_in_again_before_saving_the_pro')
          : err?.message || t('components.profilepanel.unknown_error');

      toast.error(t('components.profilepanel.failed_to_save_profile'), {
        description,
      });
    }
  };

  return (
    <div className="space-y-6 select-none animate-fade-in-up">
      <section className="portal-hero rounded-[1.8rem] p-6">
        <div className="space-y-2">
          <p className="portal-kicker">{t('components.profilepanel.professional_profile')}</p>
          <h2 className="portal-title text-3xl text-foreground">
            {t('components.profilepanel.identity_practice_and_trust_framework')}
          </h2>
          <p className="max-w-3xl text-sm leading-relaxed text-muted-foreground">
            {t('components.profilepanel.manage_how_the_practice_appears_inside_the_portal_and_keep_the_operating')}
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
                  {t('components.profilepanel.professional_details')}
                </h3>
                <p className="text-xs text-muted-foreground">
                  {t('components.profilepanel.information_visible_inside_the_portal_and_related_flows')}
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
                  {t('components.profilepanel.preview')}
                </p>
                <p className="mt-1 text-sm text-muted-foreground">
                  {t('components.profilepanel.visible_initials')}
                </p>
              </div>
            </div>

            <div className="space-y-5">
              <div className="space-y-2">
                <label className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">
                  {t('components.profilepanel.display_name')} *
                </label>
                <div className="relative">
                  <User className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <input
                    {...register('displayName')}
                    placeholder={t('components.profilepanel.e_g_marta_lopez')}
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
                  {t('components.profilepanel.business_name')}
                </label>
                <div className="relative">
                  <Briefcase className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <input
                    {...register('businessName')}
                    placeholder={t('components.profilepanel.e_g_north_nutrition_practice')}
                    disabled={updateProfile.isPending}
                    className="portal-input h-11 w-full rounded-xl pl-10 pr-4 text-sm font-medium outline-none transition-colors focus:border-primary"
                  />
                </div>
              </div>

              <div className="grid gap-3 rounded-2xl border border-border bg-background/60 p-4 md:grid-cols-2">
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                    {t('components.profilepanel.user')}
                  </p>
                  <p className="mt-1 text-sm font-semibold text-foreground">
                    {user?.email || t('components.profilepanel.unavailable')}
                  </p>
                </div>
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                    {t('components.profilepanel.last_review')}
                  </p>
                  <p className="mt-1 text-sm font-semibold text-foreground">
                    {formatPortalDate(new Date(), locale)}
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
                  ? t('components.profilepanel.saving')
                  : t('components.profilepanel.save_changes')}
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
                  {t('components.profilepanel.privacy_and_trust')}
                </h3>
              </div>
              <p className="text-sm leading-relaxed text-muted-foreground">
                {t('components.profilepanel.the_portal_should_never_imply_more_visibility_than_what_really_exists')}
              </p>
            </div>
            <span className="inline-flex items-center gap-2 rounded-full bg-primary/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
              <span className="h-2 w-2 rounded-full bg-primary" />
              {t('components.profilepanel.active')}
            </span>
          </div>

          <div className="mt-5 space-y-3">
            {[
              t('components.profilepanel.aggregate_snapshots_are_the_default_baseline_for_every_active_relationsh'),
              t('components.profilepanel.detailed_diary_rows_only_appear_with_explicit_client_consent'),
              t('components.profilepanel.the_client_can_revoke_the_professional_relationship_at_any_moment'),
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
                {t('components.profilepanel.operational_context')}
              </p>
            </div>
            <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
              {t('components.profilepanel.this_surface_is_intended_for_internal_operations_roster_notes_plans_and_')}
            </p>
          </div>
        </section>
      </div>
    </div>
  );
};
