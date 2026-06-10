import React, { useEffect, useRef } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useAuth } from '../../lib/auth-context';
import { useMessages } from '../../hooks/queries/useMessages';
import { useSendMessage } from '../../hooks/mutations/useSendMessage';
import { useMarkMessagesRead } from '../../hooks/mutations/useMarkMessagesRead';
import type { ProfessionalClient } from '../../types/database.types';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { messageSchema, type MessageFormData } from '../../lib/validation/schemas';
import { toast } from '../../lib/toast';
import { MessageSquare, Loader2, ArrowUp } from 'lucide-react';

interface ChatPanelProps {
  client: ProfessionalClient;
  onMessagesRead?: () => void;
}

export const ChatPanel: React.FC<ChatPanelProps> = ({ client, onMessagesRead }) => {
  const { professional } = useAuth();
  const { data: messages = [], isLoading } = useMessages(client.id);
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
      .filter(m => m.author_role === 'client' && !m.professional_read_at)
      .map(m => m.id);

    if (unreadIds.length > 0) {
      markReadMutation.mutate({ messageIds: unreadIds, onSuccess: onMessagesRead });
    }
  }, [client.id]);

  const handleSendMessage = (data: MessageFormData) => {
    if (!professional) return;

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
          toast.error('Failed to send message', { description: err?.message || 'Unknown error' });
        },
      }
    );
  };

  const getInitials = (id: string) => id.slice(0, 2).toUpperCase();

  const formatTime = (dateStr: string) => {
    const d = new Date(dateStr);
    return d.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' });
  };

  return (
    <div className="rounded-xl border bg-card flex flex-col h-[500px] card-elevated">
      {/* Header */}
      <div className="px-5 py-3.5 border-b flex items-center gap-2.5">
        <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
          <MessageSquare className="w-4 h-4 text-primary" />
        </div>
        <div>
          <p className="text-sm font-semibold leading-none">Messages</p>
          <p className="text-[11px] text-muted-foreground mt-0.5">
            Real-time chat with {client.client_id}
          </p>
        </div>
      </div>

      {/* Messages */}
      <div
        ref={scrollContainerRef}
        className="flex-1 overflow-y-auto px-5 py-4 space-y-3 [scrollbar-width:thin] [scrollbar-color:rgb(200_200_200/0.3)_transparent] dark:[scrollbar-color:rgb(60_60_60/0.3)_transparent]"
      >
        {isLoading ? (
          <div className="flex items-center justify-center h-full gap-2 text-sm text-muted-foreground">
            <Loader2 className="w-4 h-4 animate-spin text-primary" />
            <span>Loading...</span>
          </div>
        ) : messages.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full text-muted-foreground p-6 text-center">
            <div className="w-12 h-12 rounded-full bg-muted/50 flex items-center justify-center mb-3">
              <MessageSquare className="w-5 h-5 text-muted-foreground/60" />
            </div>
            <p className="text-sm font-medium">No messages yet</p>
            <p className="text-xs text-muted-foreground/70 mt-1 max-w-[200px]">
              Start a conversation with your client
            </p>
          </div>
        ) : (
          messages.map((m) => {
            const isSelf = m.author_role === 'professional';
            return (
              <div
                key={m.id}
                className={`flex gap-2.5 animate-in fade-in-30 slide-in-from-bottom-1 duration-150 ${
                  isSelf ? 'flex-row-reverse' : 'flex-row'
                }`}
              >
                {/* Avatar */}
                <div className={`w-7 h-7 rounded-full flex items-center justify-center text-[10px] font-bold shrink-0 mt-0.5 ${
                  isSelf
                    ? 'bg-primary text-primary-foreground'
                    : 'bg-muted text-muted-foreground'
                }`}>
                  {isSelf ? (professional?.display_name?.slice(0, 2).toUpperCase() || 'MT') : getInitials(client.client_id)}
                </div>

                {/* Bubble */}
                <div className={`max-w-[75%] ${isSelf ? 'text-right' : ''}`}>
                  <div className={`inline-block px-3.5 py-2.5 text-sm leading-relaxed rounded-2xl ${
                    isSelf
                      ? 'bg-primary text-primary-foreground rounded-br-md'
                      : 'bg-secondary text-foreground rounded-bl-md'
                  }`}>
                    <p className="whitespace-pre-wrap">{m.body}</p>
                  </div>
                  <p className={`text-[10px] text-muted-foreground/70 mt-1 px-1 ${
                    isSelf ? 'text-right' : 'text-left'
                  }`}>
                    {formatTime(m.created_at)}
                  </p>
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* Input */}
      <div className="p-3 border-t">
        <form onSubmit={handleSubmit(handleSendMessage)} className="flex gap-2 items-center">
          <Input
            type="text"
            placeholder="Type a message..."
            className="border-0 bg-secondary focus-visible:ring-0 focus-visible:ring-offset-0 h-10 px-4 rounded-xl"
            disabled={sendMutation.isPending}
            {...register('body')}
          />
          {errors.body && (
            <p className="text-xs font-medium text-destructive absolute -mt-6 left-4">{errors.body.message}</p>
          )}
          <Button
            type="submit"
            disabled={sendMutation.isPending}
            size="icon"
            className="h-10 w-10 rounded-xl shrink-0"
          >
            {sendMutation.isPending ? (
              <Loader2 className="w-4 h-4 animate-spin" />
            ) : (
              <ArrowUp className="w-4 h-4" />
            )}
          </Button>
        </form>
      </div>
    </div>
  );
};
