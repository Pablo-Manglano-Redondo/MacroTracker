import React, { useMemo, useState } from 'react';
import {
  ClipboardCheck,
  FileText,
  LayoutList,
  MessageSquare,
  PanelLeftClose,
  PanelLeftOpen,
  Plus,
  Scale,
  ShieldAlert,
  User,
  UtensilsCrossed,
  X,
} from 'lucide-react';
import type { ProfessionalClient } from '../../types/database.types';
import { PlanBuilder } from './PlanBuilder';
import { PlanList } from './PlanList';
import { PlanEditor } from './PlanEditor';
import { SnapshotsPanel } from './SnapshotsPanel';
import { ChatPanel } from './ChatPanel';
import { ClientNotes } from './ClientNotes';
import { ClientProgressPanel } from './ClientProgressPanel';
import { ClientCheckins } from './ClientCheckins';
import { ClientProfile } from './ClientProfile';
import { DiaryPanel } from './DiaryPanel';
import { usePortalI18n } from '../../lib/portal-i18n';

interface ClientDetailProps {
  client: ProfessionalClient;
  onClose: () => void;
  onMessagesRead?: () => void;
  isRosterCollapsed?: boolean;
  onToggleRoster?: () => void;
  unreadCount?: number;
}

type PlanView = 'list' | 'new' | 'edit';
type DetailTab = 'plans' | 'notes' | 'progress' | 'checkins' | 'profile' | 'diary' | 'chat';

export const ClientDetail: React.FC<ClientDetailProps> = ({
  client,
  onClose,
  onMessagesRead,
  isRosterCollapsed = false,
  onToggleRoster,
  unreadCount = 0,
}) => {
  const { tr } = usePortalI18n();
  const [planView, setPlanView] = useState<PlanView>('list');
  const [editingPlanId, setEditingPlanId] = useState<string | null>(null);
  const [detailTab, setDetailTab] = useState<DetailTab>('plans');

  const clientName = client.display_name || client.client_id.slice(0, 8);
  const initials = clientName
    .split(/\s+/)
    .map((part) => part[0])
    .join('')
    .slice(0, 2)
    .toUpperCase();

  const relationshipLabel = useMemo(() => {
    if (client.status === 'connected') {
      return tr('Conectado', 'Connected');
    }
    if (client.status === 'revoked') {
      return tr('Revocado', 'Revoked');
    }
    if (client.status === 'archived') {
      return tr('Archivado', 'Archived');
    }
    return client.status;
  }, [client.status, tr]);

  const sharingLabel =
    client.sharing_mode === 'detailed'
      ? tr('Detallado', 'Detailed')
      : tr('Agregado', 'Aggregate');
  const messagesLabel = client.messages_enabled
    ? tr('Chat activo', 'Chat active')
    : tr('Chat inactivo', 'Chat inactive');

  const handleNewPlan = () => {
    setEditingPlanId(null);
    setPlanView('new');
  };

  const handleEditPlan = (planId: string) => {
    setEditingPlanId(planId);
    setPlanView('edit');
  };

  const handleBackToList = () => {
    setEditingPlanId(null);
    setPlanView('list');
  };

  const tabs: Array<{ id: DetailTab; label: string; icon: React.ReactNode; badge?: number }> = [
    { id: 'plans', label: tr('Planes', 'Plans'), icon: <LayoutList className="h-3.5 w-3.5" /> },
    { id: 'notes', label: tr('Notas', 'Notes'), icon: <FileText className="h-3.5 w-3.5" /> },
    { id: 'progress', label: tr('Progreso', 'Progress'), icon: <Scale className="h-3.5 w-3.5" /> },
    { id: 'checkins', label: tr('Check-ins', 'Check-ins'), icon: <ClipboardCheck className="h-3.5 w-3.5" /> },
    { id: 'diary', label: tr('Diario', 'Diary'), icon: <UtensilsCrossed className="h-3.5 w-3.5" /> },
    {
      id: 'chat',
      label: 'Chat',
      icon: <MessageSquare className="h-3.5 w-3.5" />,
      badge: unreadCount > 0 ? unreadCount : undefined,
    },
    { id: 'profile', label: tr('Perfil', 'Profile'), icon: <User className="h-3.5 w-3.5" /> },
  ];

  return (
    <section className="space-y-6 animate-fade-in-up" id="client-detail-section">
      <div className="portal-hero rounded-[1.8rem] p-5">
        <div className="flex items-start justify-between gap-4">
          <div className="flex min-w-0 items-start gap-4">
            <div className="flex h-14 w-14 items-center justify-center rounded-[1.1rem] bg-primary text-base font-extrabold text-primary-foreground shadow-sm">
              {initials}
            </div>
            <div className="min-w-0 space-y-2">
              <p className="portal-kicker">{tr('Cliente seleccionado', 'Selected client')}</p>
              <h2 className="portal-title truncate text-2xl text-foreground">{clientName}</h2>
              <div className="flex flex-wrap items-center gap-2">
                <Badge tone={client.status === 'connected' ? 'good' : 'neutral'}>
                  {relationshipLabel}
                </Badge>
                <Badge tone="primary">{sharingLabel}</Badge>
                <Badge tone={client.messages_enabled ? 'info' : 'neutral'}>{messagesLabel}</Badge>
              </div>
            </div>
          </div>

          <div className="flex items-center gap-2">
            {onToggleRoster && (
              <button
                onClick={onToggleRoster}
                className="rounded-xl border border-border bg-card p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground xl:flex"
                title={
                  isRosterCollapsed
                    ? tr('Expandir roster', 'Expand roster')
                    : tr('Colapsar roster', 'Collapse roster')
                }
              >
                {isRosterCollapsed ? (
                  <PanelLeftOpen className="h-4 w-4 text-primary" />
                ) : (
                  <PanelLeftClose className="h-4 w-4" />
                )}
              </button>
            )}
            <button
              onClick={onClose}
              className="rounded-xl border border-border bg-card p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
              aria-label={tr('Cerrar detalle', 'Close details')}
            >
              <X className="h-4 w-4" />
            </button>
          </div>
        </div>
      </div>

      <div className="flex flex-wrap gap-2">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => {
              setDetailTab(tab.id);
              if (tab.id === 'plans') {
                handleBackToList();
              }
            }}
            className={`inline-flex items-center gap-2 rounded-xl px-3.5 py-2 text-xs font-bold transition-colors ${
              detailTab === tab.id
                ? 'bg-primary text-primary-foreground'
                : 'portal-chip hover:bg-accent'
            }`}
          >
            {tab.icon}
            <span>{tab.label}</span>
            {tab.badge ? (
              <span className="rounded-full bg-rose-500 px-1.5 py-0.5 text-[10px] font-extrabold text-white">
                {tab.badge}
              </span>
            ) : null}
          </button>
        ))}
      </div>

      {detailTab === 'plans' && (
        <div className="flex flex-wrap gap-2">
          <button
            onClick={handleBackToList}
            className={`inline-flex items-center gap-2 rounded-xl px-3 py-2 text-xs font-bold transition-colors ${
              planView === 'list'
                ? 'bg-card text-foreground shadow-sm border border-border'
                : 'portal-chip hover:bg-accent'
            }`}
          >
            <LayoutList className="h-3.5 w-3.5" />
            {tr('Planes', 'Plans')}
          </button>
          <button
            onClick={handleNewPlan}
            className={`inline-flex items-center gap-2 rounded-xl px-3 py-2 text-xs font-bold transition-colors ${
              planView === 'new'
                ? 'bg-card text-foreground shadow-sm border border-border'
                : 'portal-chip hover:bg-accent'
            }`}
          >
            <Plus className="h-3.5 w-3.5" />
            {tr('Nuevo plan', 'New plan')}
          </button>
        </div>
      )}

      <div className="space-y-6">
        {detailTab === 'plans' && (
          <div className="grid grid-cols-1 gap-6 lg:grid-cols-12">
            <div className="lg:col-span-7">
              {planView === 'list' && (
                <PlanList client={client} onNewPlan={handleNewPlan} onEditPlan={handleEditPlan} />
              )}
              {planView === 'new' && <PlanBuilder client={client} />}
              {planView === 'edit' && editingPlanId && (
                <PlanEditor client={client} planId={editingPlanId} onBack={handleBackToList} />
              )}
            </div>
            <div className="lg:col-span-5">
              <SnapshotsPanel client={client} />
            </div>
          </div>
        )}

        {detailTab === 'notes' && <ClientNotes client={client} />}
        {detailTab === 'progress' && <ClientProgressPanel client={client} />}
        {detailTab === 'checkins' && <ClientCheckins client={client} />}
        {detailTab === 'diary' && <DiaryPanel client={client} />}
        {detailTab === 'profile' && <ClientProfile client={client} />}
        {detailTab === 'chat' && (
          <div className="mx-auto w-full max-w-4xl animate-fade-in-up">
            {client.messages_enabled ? (
              <ChatPanel client={client} onMessagesRead={onMessagesRead} />
            ) : (
              <div className="portal-panel flex items-start gap-3 rounded-[1.6rem] border-amber-500/25 bg-amber-500/8 p-5">
                <ShieldAlert className="mt-0.5 h-5 w-5 shrink-0 text-amber-500 dark:text-amber-300" />
                <div className="space-y-1">
                  <p className="text-sm font-bold text-foreground">
                    {tr('Chat desactivado', 'Chat disabled')}
                  </p>
                  <p className="text-sm leading-relaxed text-muted-foreground">
                    {tr(
                      'Este cliente ha desactivado los mensajes desde la configuración de privacidad de la app móvil.',
                      'This client has disabled messages from the privacy settings in the mobile app.',
                    )}
                  </p>
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </section>
  );
};

const Badge: React.FC<{
  tone: 'good' | 'primary' | 'info' | 'neutral';
  children: React.ReactNode;
}> = ({ tone, children }) => {
  const className = {
    good: 'bg-emerald-500/10 text-emerald-700 dark:text-emerald-300',
    primary: 'bg-primary/10 text-primary',
    info: 'bg-sky-500/10 text-sky-700 dark:text-sky-300',
    neutral: 'bg-background text-muted-foreground border border-border',
  }[tone];

  return (
    <span className={`inline-flex items-center gap-1 rounded-full px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] ${className}`}>
      {children}
    </span>
  );
};
