import React, { useEffect, useRef } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { ArrowUp, Loader2, MessageSquare } from 'lucide-react';
import { useAuth } from '../../lib/auth-context';
import { useMessages } from '../../hooks/queries/useMessages';
import { useSendMessage } from '../../hooks/mutations/useSendMessage';
import { useMarkMessagesRead } from '../../hooks/mutations/useMarkMessagesRead';
import type { ProfessionalClient, ProfessionalClientMessage } from '../../types/database.types';
import { formatPortalTime } from '../../lib/date';
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
  const { t, locale } = usePortalI18n();
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
          toast.error(t('components.clientdetail.chatpanel.failed_to_send_message'), {
            description: err?.message || t('components.clientdetail.chatpanel.unknown_error'),
          });
        },
      },
    );
  };

  const getInitials = (id: string) => id.slice(0, 2).toUpperCase();

  const formatTime = (dateStr: string) =>
    formatPortalTime(dateStr, locale, {
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
            <h3 className="portal-card-heading">{t('components.clientdetail.chatpanel.messages')}</h3>
            <p className="portal-meta mt-1">
              {t('components.clientdetail.chatpanel.real_thread_with', { value_0_8: client.display_name || client.client_id.slice(0, 8) })}
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
            title={t('components.clientdetail.chatpanel.messages_unavailable')}
            body={t('components.clientdetail.chatpanel.messaging_is_enabled_for_this_relationship_but_the_portal_could_not_load')}
          />
        ) : isLoading ? (
          <div className="portal-body flex h-full items-center justify-center gap-2 text-muted-foreground">
            <Loader2 className="h-4 w-4 animate-spin text-primary" />
            <span>{t('components.clientdetail.chatpanel.loading_messages')}</span>
          </div>
        ) : messages.length === 0 ? (
          <EmptyChatState
            title={t('components.clientdetail.chatpanel.no_messages_yet')}
            body={t('components.clientdetail.chatpanel.the_conversation_remains_empty_until_the_first_real_message_exists_betwe')}
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
                    className={`flex h-8 w-8 shrink-0 items-center justify-center overflow-hidden rounded-xl text-[10px] font-extrabold tracking-wider uppercase ${
                      isSelf
                        ? 'bg-primary text-primary-foreground'
                        : 'bg-background text-muted-foreground border border-border'
                    }`}
                  >
                    {isSelf ? (
                      professional?.avatar_url ? (
                        <img
                          src={professional.avatar_url}
                          alt={professional.display_name || ''}
                          className="h-full w-full object-cover"
                        />
                      ) : (
                        professional?.display_name?.slice(0, 2).toUpperCase() || 'MT'
                      )
                    ) : (
                      getInitials(client.client_id)
                    )}
                  </div>

                  <div className={`max-w-[78%] ${isSelf ? 'text-right' : ''}`}>
                    <div
                      className={`inline-block rounded-2xl px-4 py-3 text-[15px] font-medium leading-relaxed ${
                        isSelf
                          ? 'rounded-tr-sm bg-primary text-primary-foreground'
                          : 'rounded-tl-sm border border-border bg-card text-foreground'
                      }`}
                    >
                      <p className="whitespace-pre-wrap">{message.body}</p>
                    </div>
                    <p className={`portal-meta mt-1 px-1 flex items-center gap-1 ${isSelf ? 'justify-end' : ''}`}>
                      <span>{formatTime(message.created_at)}</span>
                      {isSelf && <MessageTicks message={message} />}
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
            placeholder={t('components.clientdetail.chatpanel.write_a_message')}
            className="portal-input h-11 flex-1 rounded-xl px-4 outline-none focus:border-primary"
            disabled={sendMutation.isPending}
            {...register('body')}
          />
          {errors.body && (
            <p className="portal-meta absolute -top-5 left-1 text-red-500">
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
    <p className="portal-card-heading mt-4">{title}</p>
    <p className="portal-body mt-2 max-w-sm">{body}</p>
  </div>
);

const MessageTicks: React.FC<{ message: ProfessionalClientMessage }> = ({ message }) => {
  const [isDelivered, setIsDelivered] = React.useState(false);

  React.useEffect(() => {
    if (message.client_read_at) {
      setIsDelivered(true);
      return;
    }

    const createdTime = new Date(message.created_at).getTime();
    const now = Date.now();
    const diff = now - createdTime;

    if (diff >= 2000) {
      setIsDelivered(true);
      return;
    }

    const timer = setTimeout(() => {
      setIsDelivered(true);
    }, 2000 - diff);

    return () => {
      clearTimeout(timer);
    };
  }, [message.client_read_at, message.created_at]);

  if (message.client_read_at) {
    // Double blue check
    return (
      <span className="inline-flex items-center text-[#34b7f1] dark:text-[#53bdeb] shrink-0" title="Leído">
        <svg viewBox="0 0 16 16" fill="currentColor" className="h-3.5 w-3.5">
          <path d="M10.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L3.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z" />
          <path d="M15.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-1.5-1.5a.5.5 0 1 1 .708-.708l1.146 1.147 6.646-6.647a.5.5 0 0 1 .708 0z" />
        </svg>
      </span>
    );
  }

  if (isDelivered) {
    // Double gray check
    return (
      <span className="inline-flex items-center text-muted-foreground/60 shrink-0" title="Entregado">
        <svg viewBox="0 0 16 16" fill="currentColor" className="h-3.5 w-3.5">
          <path d="M10.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L3.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z" />
          <path d="M15.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-1.5-1.5a.5.5 0 1 1 .708-.708l1.146 1.147 6.646-6.647a.5.5 0 0 1 .708 0z" />
        </svg>
      </span>
    );
  }

  // Single gray check
  return (
    <span className="inline-flex items-center text-muted-foreground/60 shrink-0" title="Enviado">
      <svg viewBox="0 0 16 16" fill="currentColor" className="h-3.5 w-3.5">
        <path d="M10.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L3.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z" />
      </svg>
    </span>
  );
};
