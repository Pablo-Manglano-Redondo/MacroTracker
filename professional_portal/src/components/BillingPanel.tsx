import React, { useEffect, useMemo, useState } from 'react';
import {
  BadgeCheck,
  CreditCard,
  Loader2,
  ShieldAlert,
  Users,
} from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { toast } from '../lib/toast';
import { useStripeCheckout } from '../hooks/mutations/useStripeCheckout';
import { getBillingSummary } from '../view-models/professional';
import { usePortalI18n } from '../lib/portal-i18n';

type BillingInterval = 'monthly' | 'annual';

type TierCard = {
  id: 'starter' | 'growth' | 'studio';
  name: string;
  monthlyPrice: string;
  annualPrice: string;
  clientLimit: number;
  summaryEs: string;
  summaryEn: string;
  featuresEs: string[];
  featuresEn: string[];
};

const TIERS: TierCard[] = [
  {
    id: 'starter',
    name: 'Starter',
    monthlyPrice: '$29',
    annualPrice: '$276',
    clientLimit: 10,
    summaryEs: 'Para nutricionistas individuales que validan el flujo con un roster pequeño.',
    summaryEn: 'For solo nutritionists validating the workflow with a small roster.',
    featuresEs: [
      'Hasta 10 relaciones activas',
      'Planes, notas, check-ins y snapshots aggregate',
      'Diario detailed solo con consentimiento explícito del cliente',
    ],
    featuresEn: [
      'Up to 10 active client relationships',
      'Plans, notes, check-ins, and aggregate snapshots',
      'Detailed diary only when the client grants explicit consent',
    ],
  },
  {
    id: 'growth',
    name: 'Growth',
    monthlyPrice: '$79',
    annualPrice: '$756',
    clientLimit: 50,
    summaryEs: 'Para consultas que ya gestionan una base estable de clientes recurrentes.',
    summaryEn: 'For practices already managing a stable book of recurring clients.',
    featuresEs: [
      'Hasta 50 relaciones activas',
      'Las mismas superficies operativas que Starter',
      'Más capacidad para publicar planes e invitar clientes',
    ],
    featuresEn: [
      'Up to 50 active client relationships',
      'The same operational surfaces as Starter',
      'More capacity for plan publishing and invite operations',
    ],
  },
  {
    id: 'studio',
    name: 'Studio',
    monthlyPrice: '$199',
    annualPrice: '$1908',
    clientLimit: 500,
    summaryEs: 'Para equipos más grandes que usan el portal como operación interna controlada.',
    summaryEn: 'For larger teams using the portal as a controlled internal operation.',
    featuresEs: [
      'Hasta 500 relaciones activas',
      'Mismo contrato de datos y privacidad',
      'Pensado para operaciones invite-only de mayor volumen',
    ],
    featuresEn: [
      'Up to 500 active client relationships',
      'The same data contract and privacy model',
      'Built for higher-volume invite-only operations',
    ],
  },
];

export const BillingPanel: React.FC = () => {
  const { professional } = useAuth();
  const { tr, locale } = usePortalI18n();
  const checkoutMutation = useStripeCheckout();
  const [selectedInterval, setSelectedInterval] = useState<BillingInterval>('monthly');
  const [loadingTier, setLoadingTier] = useState<string | null>(null);
  const [checkoutStatus, setCheckoutStatus] = useState<'success' | 'canceled' | null>(null);

  const billingSummary = useMemo(() => getBillingSummary(professional), [professional]);
  const billingIntervalLabel =
    billingSummary.billingInterval === 'annual'
      ? tr('Anual', 'Annual')
      : tr('Mensual', 'Monthly');
  const proStatusLabelMap: Record<string, string> = {
    inactive: tr('Inactivo', 'Inactive'),
    trialing: tr('Prueba activa', 'Trial active'),
    active: tr('Activo', 'Active'),
    past_due: tr('Pago pendiente', 'Past due'),
    canceled: tr('Cancelado', 'Canceled'),
  };
  const proStatusLabel = proStatusLabelMap[billingSummary.proStatus] ?? billingSummary.proStatus;

  useEffect(() => {
    if (professional?.billing_interval) {
      setSelectedInterval(professional.billing_interval);
    }
  }, [professional?.billing_interval]);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const checkout = params.get('checkout');
    if (checkout === 'success') {
      setCheckoutStatus('success');
    } else if (checkout === 'canceled' || checkout === 'cancelled') {
      setCheckoutStatus('canceled');
    } else {
      return;
    }

    window.history.replaceState({}, document.title, window.location.pathname + window.location.hash);
  }, []);

  const handleCheckout = (tierId: TierCard['id']) => {
    if (!professional) {
      toast.error(
        tr(
          'Crea primero el perfil profesional para abrir Stripe Checkout.',
          'Create the professional profile before opening Stripe checkout.',
        ),
      );
      return;
    }

    setLoadingTier(tierId);
    checkoutMutation.mutate(
      {
        tier: tierId,
        billingInterval: selectedInterval,
        origin: window.location.origin + window.location.pathname,
      },
      {
        onSuccess: (url) => {
          window.location.href = url;
        },
        onError: (error: unknown) => {
          const message =
            error instanceof Error
              ? error.message
              : tr('Stripe checkout ha fallado.', 'Stripe checkout failed.');
          toast.error(tr('Checkout no disponible', 'Checkout unavailable'), { description: message });
          setLoadingTier(null);
        },
      },
    );
  };

  return (
    <div className="space-y-6 animate-fade-in-up">
      <section className="portal-hero rounded-[1.8rem] p-6">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
          <div className="space-y-2">
            <div className="flex items-center gap-2 text-primary">
              <CreditCard className="h-5 w-5" />
              <p className="portal-kicker">{tr('Facturación', 'Billing')}</p>
            </div>
            <h2 className="portal-title text-3xl text-foreground">
              {tr('Acceso, tier y capacidad.', 'Access, tier, and capacity.')}
            </h2>
            <p className="max-w-2xl text-sm leading-relaxed text-muted-foreground">
              {tr(
                'El portal separa estado de acceso, tier comercial e intervalo de cobro. Un plan da capacidad operativa; no cambia el contrato de privacidad con clientes.',
                'The portal separates access status, commercial tier, and billing interval. A plan unlocks operational capacity; it does not change the privacy contract with clients.',
              )}
            </p>
          </div>

          <div className="inline-flex rounded-xl border border-border bg-card p-1">
            {(['monthly', 'annual'] as BillingInterval[]).map((interval) => (
              <button
                key={interval}
                onClick={() => setSelectedInterval(interval)}
                className={`rounded-lg px-3 py-1.5 text-xs font-bold uppercase tracking-[0.16em] transition-colors ${
                  selectedInterval === interval
                    ? 'bg-primary text-primary-foreground'
                    : 'text-muted-foreground hover:text-foreground'
                }`}
              >
                {interval === 'monthly' ? tr('Mensual', 'Monthly') : tr('Anual', 'Annual')}
              </button>
            ))}
          </div>
        </div>

        {checkoutStatus === 'success' && (
          <div className="mt-4 rounded-xl border border-primary/25 bg-primary/10 p-3 text-sm font-semibold text-primary">
            {tr(
              'Checkout completado. Si el webhook de Stripe aún no aterrizó, refresca el perfil en unos segundos.',
              'Checkout completed. If the Stripe webhook has not landed yet, refresh the profile in a few seconds.',
            )}
          </div>
        )}
        {checkoutStatus === 'canceled' && (
          <div className="mt-4 rounded-xl border border-amber-500/25 bg-amber-500/10 p-3 text-sm font-semibold text-amber-700 dark:text-amber-300">
            {tr(
              'Checkout cancelado. No se aplicó ningún cambio de facturación.',
              'Checkout canceled. No billing change was applied.',
            )}
          </div>
        )}

        <div className="mt-5 grid gap-4 md:grid-cols-3">
          <SummaryCard
            label={tr('Estado de acceso', 'Access status')}
            value={proStatusLabel}
            tone={billingSummary.hasProfessionalAccess ? 'good' : 'warn'}
            note={
              billingSummary.hasProfessionalAccess
                ? tr('Invitaciones y publicación de planes habilitadas.', 'Invites and plan publishing are enabled.')
                : tr('Invitaciones y nuevos planes bloqueados hasta reactivar facturación.', 'Invites and new plans stay blocked until billing is active.')
            }
          />
          <SummaryCard
            label={tr('Tier comercial', 'Commercial tier')}
            value={billingSummary.tierLabel}
            note={tr(
              `${billingSummary.clientLimit} clientes activos incluidos`,
              `${billingSummary.clientLimit} active clients included`,
            )}
          />
          <SummaryCard
            label={tr('Intervalo de cobro', 'Billing interval')}
            value={billingIntervalLabel}
            note={tr(
              'Guardado por separado del estado de suscripción',
              'Stored separately from subscription status',
            )}
          />
        </div>

        {selectedInterval === 'annual' && (
          <div className="portal-soft-panel mt-4 rounded-xl p-3 text-xs leading-relaxed text-muted-foreground">
            {tr(
              'El checkout anual depende de que los secrets `*_ANNUAL_PRICE_ID` estén configurados en Supabase. Si faltan, el error es explícito.',
              'Annual checkout depends on the matching `*_ANNUAL_PRICE_ID` secrets being configured in Supabase. If they are missing, the error is explicit.',
            )}
          </div>
        )}
      </section>

      {!billingSummary.hasProfessionalAccess && (
        <section className="rounded-2xl border border-amber-500/25 bg-amber-500/10 p-5">
          <div className="flex items-start gap-3">
            <ShieldAlert className="mt-0.5 h-5 w-5 text-amber-500 dark:text-amber-300" />
            <div className="space-y-1">
              <p className="text-sm font-bold text-foreground dark:text-white">
                {tr('La consulta aún no está operativa', 'Practice not operational yet')}
              </p>
              <p className="text-sm leading-relaxed text-amber-900 dark:text-amber-100">
                {tr(
                  `Los registros existentes pueden seguir en lectura, pero nuevas invitaciones y nuevos planes deben quedar bloqueados mientras el estado sea "${billingSummary.proStatus}".`,
                  `Existing records may remain readable, but new invites and new plans should stay blocked while access status is "${billingSummary.proStatus}".`,
                )}
              </p>
            </div>
          </div>
        </section>
      )}

      <section className="grid gap-4 xl:grid-cols-3">
        {TIERS.map((tier) => {
          const isCurrentPlan =
            billingSummary.tier === tier.id &&
            billingSummary.billingInterval === selectedInterval &&
            billingSummary.hasProfessionalAccess;
          const isLoading = loadingTier === tier.id;
          const price =
            selectedInterval === 'monthly'
              ? `${tier.monthlyPrice}/mo`
              : `${tier.annualPrice}/yr`;

          return (
            <article
              key={tier.id}
              className={`rounded-[1.6rem] border p-6 ${
                isCurrentPlan ? 'border-primary bg-primary/10' : 'portal-panel'
              }`}
            >
              <div className="flex items-start justify-between gap-4">
                <div>
                  <p className="text-sm font-bold uppercase tracking-[0.16em] text-primary">
                    {tier.name}
                  </p>
                  <h3 className="portal-metric mt-2 text-3xl font-extrabold text-foreground">
                    {price}
                  </h3>
                </div>
                <div className="portal-soft-panel rounded-xl px-3 py-2 text-right">
                  <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                    {tr('Capacidad', 'Capacity')}
                  </p>
                  <p className="mt-1 flex items-center gap-1 text-sm font-bold text-foreground">
                    <Users className="h-4 w-4 text-primary" />
                    {tier.clientLimit}
                  </p>
                </div>
              </div>

              <p className="mt-4 text-sm leading-relaxed text-muted-foreground">
                {locale === 'es' ? tier.summaryEs : tier.summaryEn}
              </p>

              <ul className="mt-5 space-y-3">
                {(locale === 'es' ? tier.featuresEs : tier.featuresEn).map((feature) => (
                  <li key={feature} className="flex items-start gap-2 text-sm text-muted-foreground">
                    <BadgeCheck className="mt-0.5 h-4 w-4 shrink-0 text-primary" />
                    <span>{feature}</span>
                  </li>
                ))}
              </ul>

              <button
                onClick={() => handleCheckout(tier.id)}
                disabled={!professional || isCurrentPlan || checkoutMutation.isPending}
                className={`mt-6 flex w-full items-center justify-center gap-2 rounded-xl px-4 py-3 text-xs font-bold uppercase tracking-[0.16em] transition-colors ${
                  isCurrentPlan
                    ? 'cursor-default border border-primary/30 bg-primary/15 text-primary'
                    : 'bg-primary text-primary-foreground hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50'
                }`}
              >
                {isLoading ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" />
                    {tr('Redirigiendo', 'Redirecting')}
                  </>
                ) : isCurrentPlan ? (
                  tr('Plan actual', 'Current plan')
                ) : (
                  tr('Abrir checkout', 'Open checkout')
                )}
              </button>
            </article>
          );
        })}
      </section>

      <section className="portal-panel rounded-[1.6rem] p-6">
        <h3 className="text-sm font-bold uppercase tracking-[0.16em] text-foreground">
          {tr('Recordatorios del contrato de datos', 'Data contract reminders')}
        </h3>
        <div className="mt-4 grid gap-3 md:grid-cols-2">
          <InfoCard
            title={tr('Aggregate siempre es la base', 'Aggregate sharing is the baseline')}
            body={tr(
              'Snapshots, adherencia de macros y progreso resumido pueden ser visibles con una relación activa.',
              'Snapshots, macro adherence, and summary progress can be visible with an active relationship.',
            )}
          />
          <InfoCard
            title={tr('Detailed requiere consentimiento', 'Detailed requires consent')}
            body={tr(
              'Las filas crudas del diario solo aparecen cuando el cliente mantiene la relación activa y el modo es detailed.',
              'Raw diary rows only appear when the client keeps the relationship active and the mode is detailed.',
            )}
          />
          <InfoCard
            title={tr('Billing no anula privacidad', 'Billing does not override privacy')}
            body={tr(
              'Un tier superior aumenta capacidad, no la cantidad de datos privados que el profesional puede ver.',
              'A higher tier increases capacity, not the amount of private data the professional may access.',
            )}
          />
          <InfoCard
            title={tr('El fallback read-only es honesto', 'Read-only fallback stays honest')}
            body={tr(
              'Cuando billing cae, el histórico puede seguir legible mientras nuevas invitaciones y nuevos planes quedan bloqueados.',
              'When billing lapses, historical records can remain readable while new invites and new plans are blocked.',
            )}
          />
        </div>
      </section>
    </div>
  );
};

const SummaryCard: React.FC<{
  label: string;
  value: string;
  note: string;
  tone?: 'good' | 'warn' | 'neutral';
}> = ({ label, value, note, tone = 'neutral' }) => (
  <div className="portal-soft-panel rounded-xl p-4">
    <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
      {label}
    </p>
    <p
      className={`mt-2 text-lg font-extrabold ${
        tone === 'good'
          ? 'text-primary'
          : tone === 'warn'
            ? 'text-amber-500 dark:text-amber-300'
            : 'text-foreground'
      }`}
    >
      {value}
    </p>
    <p className="mt-1 text-xs leading-relaxed text-muted-foreground">{note}</p>
  </div>
);

const InfoCard: React.FC<{ title: string; body: string }> = ({ title, body }) => (
  <div className="portal-soft-panel rounded-xl p-4">
    <p className="text-sm font-bold text-foreground">{title}</p>
    <p className="mt-2 text-sm leading-relaxed text-muted-foreground">{body}</p>
  </div>
);
