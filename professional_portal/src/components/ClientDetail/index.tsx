import React, { useState } from 'react';
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
import { X, ShieldAlert, Plus, LayoutList, FileText, Scale, ClipboardCheck, User, UtensilsCrossed } from 'lucide-react';

interface ClientDetailProps {
  client: ProfessionalClient;
  onClose: () => void;
  onMessagesRead?: () => void;
}

type PlanView = 'list' | 'new' | 'edit';

export const ClientDetail: React.FC<ClientDetailProps> = ({ client, onClose, onMessagesRead }) => {
  const [planView, setPlanView] = useState<PlanView>('list');
  const [editingPlanId, setEditingPlanId] = useState<string | null>(null);
  const [detailTab, setDetailTab] = useState<'plans' | 'notes' | 'progress' | 'checkins' | 'profile' | 'diary'>('plans');

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

  return (
    <section className="space-y-5 animate-in fade-in slide-in-from-bottom-2 duration-200" id="client-detail-section">
      {/* Header */}
      <div className="flex items-start justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="w-11 h-11 rounded-full bg-primary flex items-center justify-center text-sm font-bold text-primary-foreground shrink-0">
            {(client.display_name || client.client_id).slice(0, 2).toUpperCase()}
          </div>
          <div>
            <h2 className="text-lg font-bold text-foreground leading-none">
              {client.display_name || client.client_id.slice(0, 8) + '...'}
            </h2>
            <div className="flex items-center gap-3 mt-1.5 text-xs text-muted-foreground">
              <span className="flex items-center gap-1">
                <span className={`w-1.5 h-1.5 rounded-full ${
                  client.status === 'connected' ? 'bg-emerald-500' : 'bg-zinc-400'
                }`} />
                {client.status}
              </span>
              <span>{client.sharing_mode}</span>
              <span className={client.messages_enabled ? 'text-emerald-600 dark:text-emerald-400' : 'text-zinc-400'}>
                {client.messages_enabled ? 'Messages on' : 'Messages off'}
              </span>
            </div>
          </div>
        </div>
        <button
          onClick={onClose}
          className="p-2 rounded-lg text-muted-foreground hover:text-foreground hover:bg-secondary transition-colors"
        >
          <X className="w-4 h-4" />
        </button>
      </div>

      {/* Detail Tabs */}
      <div className="flex items-center gap-1 p-1 bg-secondary/60 rounded-lg w-fit flex-wrap">
        <button onClick={() => { setDetailTab('plans'); handleBackToList(); }}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition-all ${
            detailTab === 'plans' ? 'bg-card text-foreground shadow-sm' : 'text-muted-foreground hover:text-foreground'
          }`}>
          <LayoutList className="w-3.5 h-3.5" /> Plans
        </button>
        <button onClick={() => setDetailTab('notes')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition-all ${
            detailTab === 'notes' ? 'bg-card text-foreground shadow-sm' : 'text-muted-foreground hover:text-foreground'
          }`}>
          <FileText className="w-3.5 h-3.5" /> Notes
        </button>
        <button onClick={() => setDetailTab('progress')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition-all ${
            detailTab === 'progress' ? 'bg-card text-foreground shadow-sm' : 'text-muted-foreground hover:text-foreground'
          }`}>
          <Scale className="w-3.5 h-3.5" /> Progress
        </button>
        <button onClick={() => setDetailTab('checkins')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition-all ${
            detailTab === 'checkins' ? 'bg-card text-foreground shadow-sm' : 'text-muted-foreground hover:text-foreground'
          }`}>
          <ClipboardCheck className="w-3.5 h-3.5" /> Check-ins
        </button>
        <button onClick={() => setDetailTab('diary')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition-all ${
            detailTab === 'diary' ? 'bg-card text-foreground shadow-sm' : 'text-muted-foreground hover:text-foreground'
          }`}>
          <UtensilsCrossed className="w-3.5 h-3.5" /> Diary
        </button>
        <button onClick={() => setDetailTab('profile')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition-all ${
            detailTab === 'profile' ? 'bg-card text-foreground shadow-sm' : 'text-muted-foreground hover:text-foreground'
          }`}>
          <User className="w-3.5 h-3.5" /> Profile
        </button>
      </div>

      {/* Plans sub-tabs */}
      {detailTab === 'plans' && (
        <div className="flex items-center gap-1 p-1 bg-secondary/40 rounded-lg w-fit">
          <button onClick={handleBackToList}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition-all ${
              planView === 'list' ? 'bg-card text-foreground shadow-sm' : 'text-muted-foreground hover:text-foreground'
            }`}>
            <LayoutList className="w-3.5 h-3.5" /> Plans
          </button>
          <button onClick={handleNewPlan}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition-all ${
              planView === 'new' ? 'bg-card text-foreground shadow-sm' : 'text-muted-foreground hover:text-foreground'
            }`}>
            <Plus className="w-3.5 h-3.5" /> New Plan
          </button>
        </div>
      )}

      {/* Content */}
      {detailTab === 'plans' && (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-5">
          <div className="lg:col-span-7">
            {planView === 'list' && (
              <PlanList client={client} onNewPlan={handleNewPlan} onEditPlan={handleEditPlan} />
            )}
            {planView === 'new' && (
              <PlanBuilder client={client} />
            )}
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

      {/* Chat */}
      {client.messages_enabled ? (
        <ChatPanel client={client} onMessagesRead={onMessagesRead} />
      ) : (
        <div className="rounded-xl border bg-card p-5 flex items-start gap-3 card-elevated">
          <ShieldAlert className="w-5 h-5 text-amber-500 shrink-0 mt-0.5" />
          <div>
            <p className="text-sm font-medium">Chat Disabled</p>
            <p className="text-xs text-muted-foreground mt-0.5 leading-relaxed">
              This client has disabled messages in their mobile privacy settings.
            </p>
          </div>
        </div>
      )}
    </section>
  );
};
