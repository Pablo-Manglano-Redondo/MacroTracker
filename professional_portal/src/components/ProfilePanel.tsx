import React, { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useAuth } from '../lib/auth-context';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { profileSchema, type ProfileFormData } from '../lib/validation/schemas';
import { useUpdateProfile } from '../hooks/mutations/useUpdateProfile';
import { toast } from '../lib/toast';
import { User, HeartHandshake, Check } from 'lucide-react';

export const ProfilePanel: React.FC = () => {
  const { user, professional, refreshProfile } = useAuth();
  const updateProfile = useUpdateProfile();

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

  const onSubmit = async (data: ProfileFormData) => {
    if (!user) return;

    try {
      await updateProfile.mutateAsync({
        user_id: user.id,
        display_name: data.displayName,
        business_name: data.businessName || undefined,
      });
      await refreshProfile();
      toast.success('Profile saved');
    } catch (err: any) {
      toast.error('Failed to save profile', { description: err?.message || 'Unknown error' });
    }
  };

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
      {/* Form Card */}
      <div className="rounded-xl border bg-card card-elevated">
        <div className="px-5 py-4 border-b flex items-center gap-2.5">
          <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
            <User className="w-4 h-4 text-primary" />
          </div>
          <div>
            <p className="text-sm font-semibold leading-none">Profile</p>
            <p className="text-[11px] text-muted-foreground mt-0.5">Your public information</p>
          </div>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="p-5 space-y-4">
          <div className="space-y-1.5">
            <label className="text-xs font-medium text-foreground">Display Name</label>
            <Input
              {...register('displayName')}
              placeholder="e.g. John Doe"
              disabled={updateProfile.isPending}
              className="h-9"
            />
            {errors.displayName && (
              <p className="text-xs text-destructive">{errors.displayName.message}</p>
            )}
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-medium text-foreground">Business Name</label>
            <Input
              {...register('businessName')}
              placeholder="e.g. Elite Nutrition Inc."
              disabled={updateProfile.isPending}
              className="h-9"
            />
          </div>

          <Button type="submit" disabled={updateProfile.isPending} className="w-full h-9" size="sm">
            {updateProfile.isPending ? 'Saving...' : 'Save'}
          </Button>
        </form>
      </div>

      {/* Info Card */}
      <div className="rounded-xl border bg-card card-elevated p-5">
        <div className="flex items-center gap-2.5 mb-4">
          <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
            <HeartHandshake className="w-4 h-4 text-primary" />
          </div>
          <div>
            <p className="text-sm font-semibold leading-none">Privacy</p>
            <p className="text-[11px] text-muted-foreground mt-0.5">Client data boundaries</p>
          </div>
        </div>

        <p className="text-sm text-muted-foreground leading-relaxed mb-4">
          Clients approve sharing before any data is visible. No private information is accessible without explicit consent.
        </p>

        <div className="space-y-2.5">
          {[
            'Aggregate kcal and macro snapshots only',
            'No raw diary, food names, or photos',
            'Clients can revoke access anytime',
          ].map((item, i) => (
            <div key={i} className="flex items-start gap-2">
              <div className="w-4 h-4 rounded-full bg-primary/10 flex items-center justify-center mt-0.5 shrink-0">
                <Check className="w-2.5 h-2.5 text-primary" />
              </div>
              <span className="text-xs text-muted-foreground">{item}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
