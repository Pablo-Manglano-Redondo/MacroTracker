import React from 'react';
import { HelpCircle } from 'lucide-react';
import { usePortalI18n } from '../lib/portal-i18n';

interface TourButtonProps {
  onClick: () => void;
}

export const TourButton: React.FC<TourButtonProps> = ({ onClick }) => {
  const { t } = usePortalI18n();

  return (
    <button
      id="tour-help-button"
      onClick={onClick}
      className="flex h-12 w-12 items-center justify-center rounded-xl border border-border bg-card text-muted-foreground shadow-sm transition-colors hover:bg-accent hover:text-foreground"
      title={t('components.tour.button_title')}
      aria-label={t('components.tour.button_title')}
    >
      <HelpCircle className="h-5 w-5" />
    </button>
  );
};
