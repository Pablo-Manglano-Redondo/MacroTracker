import React, { useEffect, useState, useRef, useMemo } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import {
  Briefcase,
  Check,
  User,
  Camera,
  Trash2,
  Loader2,
} from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { profileSchema, type ProfileFormData } from '../lib/validation/schemas';
import { useUpdateProfile } from '../hooks/mutations/useUpdateProfile';
import { formatPortalDate } from '../lib/date';
import { toast } from '../lib/toast';
import { usePortalI18n } from '../lib/portal-i18n';
import { supabase } from '../lib/supabase';
import { useClients } from '../hooks/queries/useClients';
import { getBillingSummary } from '../view-models/professional';
import { ImageCropperModal } from './ImageCropperModal';

export const ProfilePanel: React.FC = () => {
  const { user, professional, refreshProfile } = useAuth();
  const { t, locale } = usePortalI18n();
  const updateProfile = useUpdateProfile();

  const { data: clients = [] } = useClients(professional?.id);
  const connectedClients = useMemo(
    () => clients.filter((c) => c.status === 'connected').length,
    [clients]
  );

  const billingSummary = useMemo(
    () => getBillingSummary(professional, connectedClients),
    [professional, connectedClients]
  );

  const currentPriceLabel = useMemo(() => {
    if (!professional) return '';
    const tier = billingSummary.tier;
    const interval = billingSummary.billingInterval;
    const priceKey = `components.billingpanel.price_${tier}_${interval}`;
    const suffixKey = interval === 'annual'
      ? 'components.billingpanel.price_yr_suffix'
      : 'components.billingpanel.price_mo_suffix';
    return ` (${t(priceKey as any)}${t(suffixKey as any)})`;
  }, [professional, billingSummary.tier, billingSummary.billingInterval, t]);

  const [isUploading, setIsUploading] = useState(false);
  const [cropperSrc, setCropperSrc] = useState<string | null>(null);
  const [isCropperOpen, setIsCropperOpen] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<ProfileFormData>({
    resolver: zodResolver(profileSchema),
    defaultValues: { displayName: '', businessName: '' },
  });

  useEffect(() => {
    if (professional) {
      reset({
        displayName: professional.display_name || '',
        businessName: professional.business_name || '',
      });
    }
  }, [professional, reset]);

  const triggerFileInput = () => {
    if (fileInputRef.current) {
      fileInputRef.current.click();
    }
  };

  const handlePhotoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !user || !professional) return;

    if (file.size > 2 * 1024 * 1024) {
      toast.error(t('components.profilepanel.photo_formats_limit'));
      return;
    }

    const validTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (!validTypes.includes(file.type)) {
      toast.error(t('components.profilepanel.photo_formats_limit'));
      return;
    }

    const reader = new FileReader();
    reader.onload = () => {
      setCropperSrc(reader.result as string);
      setIsCropperOpen(true);
    };
    reader.readAsDataURL(file);
  };

  const handleCroppedApply = async (croppedBlob: Blob) => {
    if (!user || !professional) return;

    setIsCropperOpen(false);
    setIsUploading(true);
    try {
      const filePath = `${user.id}/avatar_${Date.now()}.jpg`;

      const { error: uploadError } = await supabase.storage
        .from('professional-avatars')
        .upload(filePath, croppedBlob, {
          contentType: 'image/jpeg',
          cacheControl: '3600',
          upsert: true,
        });

      if (uploadError) throw uploadError;

      const { data: { publicUrl } } = supabase.storage
        .from('professional-avatars')
        .getPublicUrl(filePath);

      await updateProfile.mutateAsync({
        user_id: user.id,
        display_name: professional.display_name || '',
        business_name: professional.business_name || undefined,
        avatar_url: publicUrl,
      });

      await refreshProfile();
      toast.success(t('components.profilepanel.profile_saved'));
    } catch (err: any) {
      toast.error(t('components.profilepanel.unknown_error'), {
        description: err.message || '',
      });
    } finally {
      setIsUploading(false);
      setCropperSrc(null);
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  const handlePhotoDelete = async () => {
    if (!user || !professional || !professional.avatar_url) return;

    setIsUploading(true);
    try {
      const urlParts = professional.avatar_url.split('professional-avatars/');
      const filePath = urlParts[1];

      if (filePath) {
        await supabase.storage
          .from('professional-avatars')
          .remove([filePath]);
      }

      await updateProfile.mutateAsync({
        user_id: user.id,
        display_name: professional.display_name || '',
        business_name: professional.business_name || undefined,
        avatar_url: null,
      });

      await refreshProfile();
      toast.success(t('components.profilepanel.profile_saved'));
    } catch (err: any) {
      toast.error(t('components.profilepanel.unknown_error'), {
        description: err.message || '',
      });
    } finally {
      setIsUploading(false);
    }
  };

  const onSubmit = async (data: ProfileFormData) => {
    if (!user) {
      return;
    }

    try {
      await updateProfile.mutateAsync({
        user_id: user.id,
        display_name: data.displayName,
        business_name: data.businessName || undefined,
        avatar_url: professional?.avatar_url || null,
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
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <h2 className="text-2xl font-black text-foreground uppercase tracking-[0.12em]">
          {t('components.appshell.professional_profile')}
        </h2>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <section className="portal-panel rounded-[1.6rem] overflow-hidden">
          <div className="border-b border-border px-8 py-6">
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/12 text-primary">
                <User className="h-5 w-5" />
              </div>
              <div>
                <h3 className="text-xl font-black text-foreground">
                  {t('components.profilepanel.professional_details')}
                </h3>
                <p className="text-sm font-semibold text-muted-foreground">
                  {t('components.profilepanel.information_visible_inside_the_portal_and_related_flows')}
                </p>
              </div>
            </div>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="grid gap-8 px-8 py-8 md:grid-cols-[180px_minmax(0,1fr)]">
            {/* Left Col: Photo Uploader */}
            <div className="flex flex-col items-center justify-start gap-4">
              <label className="text-sm font-black uppercase tracking-[0.2em] text-muted-foreground text-center">
                {t('components.profilepanel.profile_picture')}
              </label>

              <div
                onClick={triggerFileInput}
                className="group relative flex h-32 w-32 cursor-pointer items-center justify-center rounded-[2rem] border-2 border-dashed border-border bg-background/40 overflow-hidden shadow-inner transition-all hover:border-primary hover:bg-background/80"
              >
                {isUploading ? (
                  <div className="flex flex-col items-center gap-2">
                    <Loader2 className="h-6 w-6 animate-spin text-primary" />
                    <span className="text-[10px] font-black uppercase tracking-wider text-muted-foreground">
                      {t('components.profilepanel.uploading')}
                    </span>
                  </div>
                ) : professional?.avatar_url ? (
                  <>
                    <img
                      src={professional.avatar_url}
                      alt={professional.display_name || ''}
                      className="h-full w-full object-cover rounded-[1.9rem]"
                    />
                    <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/60 opacity-0 transition-opacity group-hover:opacity-100 rounded-[1.9rem]">
                      <Camera className="h-6 w-6 text-white" />
                      <span className="mt-1 text-[10px] font-black uppercase tracking-wider text-white">
                        {t('components.profilepanel.upload_photo')}
                      </span>
                    </div>
                  </>
                ) : (
                  <div className="flex flex-col items-center justify-center p-3 text-center">
                    <Camera className="h-7 w-7 text-muted-foreground transition-transform group-hover:scale-105 group-hover:text-primary" />
                    <span className="mt-1.5 text-[9px] font-black uppercase leading-tight tracking-wider text-muted-foreground max-w-[90px]">
                      {t('components.profilepanel.drag_drop_click')}
                    </span>
                  </div>
                )}
              </div>

              {professional?.avatar_url && !isUploading && (
                <button
                  type="button"
                  onClick={handlePhotoDelete}
                  className="flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-xs font-black uppercase tracking-wider text-red-500 transition-colors hover:bg-red-500/10"
                >
                  <Trash2 className="h-3.5 w-3.5" />
                  {t('components.profilepanel.delete_photo')}
                </button>
              )}

              <input
                type="file"
                ref={fileInputRef}
                onChange={handlePhotoUpload}
                accept="image/jpeg,image/png,image/webp"
                className="hidden"
              />

              <p className="text-[10px] leading-relaxed text-muted-foreground text-center max-w-[150px] font-medium">
                {t('components.profilepanel.photo_formats_limit')}
              </p>
            </div>

            {/* Right Col: Fields */}
            <div className="space-y-5">
              <div className="space-y-2">
                <label className="text-sm font-black uppercase tracking-[0.2em] text-muted-foreground">
                  {t('components.profilepanel.display_name')} *
                </label>
                <div className="relative">
                  <User className="pointer-events-none absolute left-4 top-1/2 h-4.5 w-4.5 -translate-y-1/2 text-muted-foreground" />
                  <input
                    {...register('displayName')}
                    placeholder={t('components.profilepanel.e_g_marta_lopez')}
                    disabled={updateProfile.isPending || isUploading}
                    className="portal-input h-12 w-full rounded-xl pl-12 pr-4 text-base font-semibold outline-none transition-colors focus:border-primary"
                  />
                </div>
                {errors.displayName && (
                  <p className="text-sm font-bold text-red-500">{errors.displayName.message}</p>
                )}
              </div>

              <div className="space-y-2">
                <label className="text-sm font-black uppercase tracking-[0.2em] text-muted-foreground">
                  {t('components.profilepanel.business_name')}
                </label>
                <div className="relative">
                  <Briefcase className="pointer-events-none absolute left-4 top-1/2 h-4.5 w-4.5 -translate-y-1/2 text-muted-foreground" />
                  <input
                    {...register('businessName')}
                    placeholder={t('components.profilepanel.e_g_north_nutrition_practice')}
                    disabled={updateProfile.isPending || isUploading}
                    className="portal-input h-12 w-full rounded-xl pl-12 pr-4 text-base font-semibold outline-none transition-colors focus:border-primary"
                  />
                </div>
              </div>

              <div className="grid gap-3 rounded-2xl border border-border bg-background/60 p-6 md:grid-cols-2">
                <div>
                  <p className="text-xs font-black uppercase tracking-[0.2em] text-muted-foreground">
                    {t('components.profilepanel.user')}
                  </p>
                  <p className="mt-1 text-base font-extrabold text-foreground truncate">
                    {user?.email || t('components.profilepanel.unavailable')}
                  </p>
                </div>
                <div>
                  <p className="text-xs font-black uppercase tracking-[0.2em] text-muted-foreground">
                    {t('components.profilepanel.last_review')}
                  </p>
                  <p className="mt-1 text-base font-extrabold text-foreground">
                    {formatPortalDate(new Date(), locale)}
                  </p>
                </div>
              </div>

              <button
                type="submit"
                disabled={updateProfile.isPending || isUploading}
                className="inline-flex h-12 items-center justify-center gap-2.5 rounded-xl bg-primary px-6 text-base font-extrabold uppercase tracking-[0.16em] text-primary-foreground transition-opacity hover:opacity-95 disabled:opacity-50"
              >
                <Check className="h-5 w-5" />
                {updateProfile.isPending
                  ? t('components.profilepanel.saving')
                  : t('components.profilepanel.save_changes')}
              </button>
            </div>
          </form>
        </section>

        {/* Right column: Subscription & Trust */}
        <section className="flex flex-col h-full">
          {/* Subscription Details Card */}
          <div className="portal-panel rounded-[1.6rem] p-8 flex-1 flex flex-col">
            <div className="flex items-start justify-between gap-4 border-b border-border pb-5 mb-5">
              <div className="space-y-1">
                <p className="text-xs font-black uppercase tracking-[0.2em] text-primary">
                  {t('components.profilepanel.subscription_details')}
                </p>
                <h3 className="text-2xl font-black text-foreground">
                  {billingSummary.tierLabel}
                </h3>
              </div>
              <span className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-[10px] font-black uppercase tracking-[0.15em] ${
                billingSummary.hasProfessionalAccess
                  ? 'bg-primary/10 text-primary'
                  : 'bg-red-500/10 text-red-500'
              }`}>
                <span className={`h-1.5 w-1.5 rounded-full ${
                  billingSummary.hasProfessionalAccess ? 'bg-primary' : 'bg-red-500'
                }`} />
                {billingSummary.proStatusLabel}
              </span>
            </div>

            <div className="flex-1 flex flex-col justify-between">
              <div className="space-y-5">
                <div className="space-y-2">
                  <div className="flex items-center justify-between text-sm font-semibold">
                    <span className="text-muted-foreground">{t('components.profilepanel.connected_clients')}</span>
                    <span className="text-foreground font-extrabold">{connectedClients} / {billingSummary.clientLimit}</span>
                  </div>
                  <div className="h-2.5 w-full rounded-full bg-border/40 overflow-hidden">
                    <div
                      className={`h-full rounded-full transition-all duration-500 ${
                        billingSummary.atCapacity
                          ? 'bg-red-500'
                          : (connectedClients / (billingSummary.clientLimit || 1)) > 0.8
                            ? 'bg-amber-500'
                            : 'bg-primary'
                      }`}
                      style={{ width: `${Math.min(100, (connectedClients / (billingSummary.clientLimit || 1)) * 100)}%` }}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3 pt-1">
                  <div className="portal-soft-panel rounded-xl p-4 border border-border/30">
                    <p className="text-[10px] font-black uppercase tracking-wider text-muted-foreground">
                      {t('components.profilepanel.remaining_slots')}
                    </p>
                    <p className="mt-1 text-2xl font-black text-foreground">
                      {billingSummary.remainingClientSlots}
                    </p>
                  </div>
                  <div className="portal-soft-panel rounded-xl p-4 border border-border/30">
                    <p className="text-[10px] font-black uppercase tracking-wider text-muted-foreground">
                      {t('components.billingpanel.billing_interval')}
                    </p>
                    <p className="mt-2 text-sm font-black uppercase tracking-wider text-foreground">
                      {billingSummary.billingIntervalLabel}{currentPriceLabel}
                    </p>
                  </div>
                </div>
              </div>

              <button
                type="button"
                onClick={() => {
                  window.location.hash = 'billing-panel';
                }}
                className="mt-6 flex w-full items-center justify-center gap-2 rounded-xl bg-primary/10 border border-primary/20 px-4 py-3.5 text-xs font-extrabold uppercase tracking-[0.16em] text-primary transition-colors hover:bg-primary/20 cursor-pointer"
              >
                {t('components.profilepanel.manage_subscription')}
              </button>
            </div>
          </div>
        </section>
      </div>

      <ImageCropperModal
        src={cropperSrc || ''}
        isOpen={isCropperOpen}
        onClose={() => {
          setIsCropperOpen(false);
          setCropperSrc(null);
          if (fileInputRef.current) fileInputRef.current.value = '';
        }}
        onApply={handleCroppedApply}
      />
    </div>
  );
};
