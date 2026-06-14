import React, { useEffect, useRef } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { ArrowUp, Loader2, MessageSquare } from 'lucide-react';
import { useAuth } from '../../lib/auth-context';
import { useMessages } from '../../hooks/queries/useMessages';
import { useSendMessage } from '../../hooks/mutations/useSendMessage';
import { useMarkMessagesRead } from '../../hooks/mutations/useMarkMessagesRead';
import type { ProfessionalClient } from '../../types/database.types';
import { Button } from '../ui/button';
import { messageSchema, type MessageFormData } from '../../lib/validation/schemas';
import { toast } from '../../lib/toast';
import { usePortalI18n } from '../../lib/portal-i18n';

interface ChatPanelProps {
  client: ProfessionalClient;
  onMessagesRead?: () => void;
}

export const ChatPanel: React.FC<ChatPanelProps> = ({ client, onMessagesRead }) => {
  const { professional } = useAuth();
  const { tr, locale } = usePortalI18n();
  const { data: messages = [], isLoading, error } = useMessages(client.id);
  const sendMutation = useSendMessage(client.id);
  const markReadMutation = useMarkMessagesRead();

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<MessageFormData>({
    resolver: zodResolver(messageSchema),
    defaultValues: { body: '' },
  });

  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const prevMessageCountRef = useRef(0);

  const scrollToBottom = () => {
    if (scrollContainerRef.current) {
      scrollContainerRef.current.scrollTop = scrollContainerRef.current.scrollHeight;
    }
  };

  useEffect(() => {
    if (messages.length > prevMessageCountRef.current) {
      scrollToBottom();
    }
    prevMessageCountRef.current = messages.length;
  }, [messages]);

  useEffect(() => {
    const unreadIds = messages
      .filter((message) => message.author_role === 'client' && !message.professional_read_at)
      .map((message) => message.id);

    if (unreadIds.length > 0) {
      markReadMutation.mutate({ messageIds: unreadIds, onSuccess: onMessagesRead });
    }
  }, [client.id, markReadMutation, messages, onMessagesRead]);

  const handleSendMessage = (data: MessageFormData) => {
    if (!professional) {
      return;
    }

    sendMutation.mutate(
      {
        professional_client_id: client.id,
        professional_id: professional.id,
        client_id: client.client_id,
        body: data.body,
      },
      {
        onSuccess: () => reset(),
        onError: (err: any) => {
          toast.error(tr('No se pudo enviar el mensaje', 'Failed to send message'), {
            description: err?.message || tr('Error desconocido', 'Unknown error'),
          });
        },
      },
    );
  };

  const getInitials = (id: string) => id.slice(0, 2).toUpperCase();

  const formatTime = (dateStr: string) =>
    new Date(dateStr).toLocaleTimeString(locale === 'es' ? 'es-ES' : 'en-US', {
      hour: '2-digit',
      minute: '2-digit',
    });

  return (
    <div className="portal-panel flex h-[540px] flex-col overflow-hidden rounded-[1.6rem]">
      <div className="border-b border-border px-5 py-4">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/12 text-primary">
            <MessageSquare className="h-5 w-5" />
          </div>
          <div>
            <h3 className="text-base font-bold text-foreground">{tr('Mensajes', 'Messages')}</h3>
            <p className="text-sm text-muted-foreground">
              {tr(
                `Hilo real con ${client.display_name || client.client_id.slice(0, 8)}`,
                `Real thread with ${client.display_name || client.client_id.slice(0, 8)}`,
              )}
            </p>
          </div>
        </div>
      </div>

      <div
        ref={scrollContainerRef}
        className="flex-1 overflow-y-auto px-5 py-4"
      >
        {error ? (
          <EmptyChatState
            title={tr('Mensajes no disponibles', 'Messages unavailable')}
            body={tr(
              'La relación tiene mensajería habilitada, pero el portal no ha podido cargar el hilo actual.',
              'Messaging is enabled for this relationship, but the portal could not load the current thread.',
            )}
          />
        ) : isLoading ? (
          <div className="flex h-full items-center justify-center gap-2 text-sm text-muted-foreground">
            <Loader2 className="h-4 w-4 animate-spin text-primary" />
            <span>{tr('Cargando mensajes...', 'Loading messages...')}</span>
          </div>
        ) : messages.length === 0 ? (
          <EmptyChatState
            title={tr('Todavía no hay mensajes', 'No messages yet')}
            body={tr(
              'La conversación permanece vacía hasta que exista el primer mensaje real entre profesional y cliente.',
              'The conversation remains empty until the first real message exists between professional and client.',
            )}
          />
        ) : (
          <div className="space-y-4">
            {messages.map((message) => {
              const isSelf = message.author_role === 'professional';

              return (
                <div
                  key={message.id}
                  className={`flex gap-3 ${isSelf ? 'flex-row-reverse' : 'flex-row'}`}
                >
                  <div
                    className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-xl text-[10px] font-extrabold ${
                      isSelf
                        ? 'bg-primary text-primary-foreground'
                        : 'bg-background text-foreground border border-border'
                    }`}
                  >
                    {isSelf
                      ? professional?.display_name?.slice(0, 2).toUpperCase() || 'MT'
                      : getInitials(client.client_id)}
                  </div>

                  <div className={`max-w-[78%] ${isSelf ? 'text-right' : ''}`}>
                    <div
                      className={`inline-block rounded-2xl px-4 py-3 text-sm leading-relaxed ${
                        isSelf
                          ? 'rounded-tr-sm bg-primary text-primary-foreground'
                          : 'rounded-tl-sm border border-border bg-card text-foreground'
                      }`}
                    >
                      <p className="whitespace-pre-wrap">{message.body}</p>
                    </div>
                    <p className="mt-1 px-1 text-[10px] font-semibold text-muted-foreground">
                      {formatTime(message.created_at)}
                    </p>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      <div className="border-t border-border bg-background/70 px-4 py-3">
        <form onSubmit={handleSubmit(handleSendMessage)} className="relative flex items-center gap-2">
          <input
            type="text"
            placeholder={tr('Escribe un mensaje...', 'Write a message...')}
            className="portal-input h-11 flex-1 rounded-xl px-4 text-sm font-medium outline-none focus:border-primary"
            disabled={sendMutation.isPending}
            {...register('body')}
          />
          {errors.body && (
            <p className="absolute -top-5 left-1 text-[10px] font-semibold text-red-500">
              {errors.body.message}
            </p>
          )}
          <Button
            type="submit"
            disabled={sendMutation.isPending}
            size="icon"
            className="h-11 w-11 rounded-xl bg-primary text-primary-foreground"
          >
            {sendMutation.isPending ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <ArrowUp className="h-4 w-4" />
            )}
          </Button>
        </form>
      </div>
    </div>
  );
};

const EmptyChatState: React.FC<{ title: string; body: string }> = ({ title, body }) => (
  <div className="flex h-full flex-col items-center justify-center p-6 text-center">
    <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-background text-muted-foreground">
      <MessageSquare className="h-6 w-6" />
    </div>
    <p className="mt-4 text-base font-bold text-foreground">{title}</p>
    <p className="mt-2 max-w-sm text-sm leading-relaxed text-muted-foreground">{body}</p>
  </div>
);
