import { describe, it, expect, vi, beforeEach } from 'vitest';
import { messageRepository } from './message.repository';
import { type SupabaseClient } from '@supabase/supabase-js';

describe('messageRepository', () => {
  let mockSupabase: any;

  beforeEach(() => {
    mockSupabase = {
      from: vi.fn(),
      channel: vi.fn(),
    };
  });

  describe('listByRelationship', () => {
    it('queries messages for a relationship ordered by created_at', async () => {
      const mockMessages = [{ id: '1', body: 'hello' }, { id: '2', body: 'world' }];
      const mockOrder = vi.fn().mockResolvedValue({ data: mockMessages, error: null });
      const mockEq = vi.fn().mockReturnValue({ order: mockOrder });
      const mockSelect = vi.fn().mockReturnValue({ eq: mockEq });
      mockSupabase.from.mockReturnValue({ select: mockSelect });

      const result = await messageRepository.listByRelationship(
        mockSupabase as SupabaseClient,
        'rel-123'
      );

      expect(mockSupabase.from).toHaveBeenCalledWith('professional_client_messages');
      expect(mockSelect).toHaveBeenCalledWith('*');
      expect(mockEq).toHaveBeenCalledWith('professional_client_id', 'rel-123');
      expect(mockOrder).toHaveBeenCalledWith('created_at', { ascending: true });
      expect(result).toEqual(mockMessages);
    });

    it('throws error when database query fails', async () => {
      const dbError = new Error('Database connection failed');
      const mockOrder = vi.fn().mockResolvedValue({ data: null, error: dbError });
      const mockEq = vi.fn().mockReturnValue({ order: mockOrder });
      const mockSelect = vi.fn().mockReturnValue({ eq: mockEq });
      mockSupabase.from.mockReturnValue({ select: mockSelect });

      await expect(
        messageRepository.listByRelationship(mockSupabase as SupabaseClient, 'rel-123')
      ).rejects.toThrow('Database connection failed');
    });
  });

  describe('send', () => {
    it('inserts a message with role professional', async () => {
      const mockInsert = vi.fn().mockResolvedValue({ error: null });
      mockSupabase.from.mockReturnValue({ insert: mockInsert });

      const payload = {
        professional_client_id: 'rel-123',
        professional_id: 'prof-456',
        client_id: 'client-789',
        body: 'Testing messaging',
      };

      await messageRepository.send(mockSupabase as SupabaseClient, payload);

      expect(mockSupabase.from).toHaveBeenCalledWith('professional_client_messages');
      expect(mockInsert).toHaveBeenCalledWith({
        professional_client_id: 'rel-123',
        professional_id: 'prof-456',
        client_id: 'client-789',
        author_role: 'professional',
        body: 'Testing messaging',
      });
    });

    it('throws error when insert fails', async () => {
      const dbError = new Error('Insert restricted');
      const mockInsert = vi.fn().mockResolvedValue({ error: dbError });
      mockSupabase.from.mockReturnValue({ insert: mockInsert });

      const payload = {
        professional_client_id: 'rel-123',
        professional_id: 'prof-456',
        client_id: 'client-789',
        body: 'Testing messaging',
      };

      await expect(
        messageRepository.send(mockSupabase as SupabaseClient, payload)
      ).rejects.toThrow('Insert restricted');
    });
  });

  describe('markAsRead', () => {
    it('updates professional_read_at field by default', async () => {
      const mockIn = vi.fn().mockResolvedValue({ error: null });
      const mockUpdate = vi.fn().mockReturnValue({ in: mockIn });
      mockSupabase.from.mockReturnValue({ update: mockUpdate });

      await messageRepository.markAsRead(mockSupabase as SupabaseClient, ['msg-1', 'msg-2']);

      expect(mockSupabase.from).toHaveBeenCalledWith('professional_client_messages');
      expect(mockUpdate).toHaveBeenCalledWith(
        expect.objectContaining({
          professional_read_at: expect.any(String),
        })
      );
      expect(mockIn).toHaveBeenCalledWith('id', ['msg-1', 'msg-2']);
    });

    it('updates client_read_at field when role is client', async () => {
      const mockIn = vi.fn().mockResolvedValue({ error: null });
      const mockUpdate = vi.fn().mockReturnValue({ in: mockIn });
      mockSupabase.from.mockReturnValue({ update: mockUpdate });

      await messageRepository.markAsRead(
        mockSupabase as SupabaseClient,
        ['msg-1'],
        'client'
      );

      expect(mockUpdate).toHaveBeenCalledWith(
        expect.objectContaining({
          client_read_at: expect.any(String),
        })
      );
    });

    it('returns early without querying when messageIds array is empty', async () => {
      await messageRepository.markAsRead(mockSupabase as SupabaseClient, []);
      expect(mockSupabase.from).not.toHaveBeenCalled();
    });
  });

  describe('subscribeToNewMessages', () => {
    it('subscribes to insert events on the messages table for specific relationship', () => {
      const mockSubscribe = vi.fn().mockReturnValue('mock-channel');
      const mockOn = vi.fn().mockReturnValue({ subscribe: mockSubscribe });
      mockSupabase.channel.mockReturnValue({ on: mockOn });

      const callback = vi.fn();
      const channel = messageRepository.subscribeToNewMessages(
        mockSupabase as SupabaseClient,
        'rel-123',
        callback
      );

      expect(mockSupabase.channel).toHaveBeenCalledWith('messages-relationship:rel-123');
      expect(mockOn).toHaveBeenCalledWith(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'professional_client_messages',
          filter: 'professional_client_id=eq.rel-123',
        },
        expect.any(Function)
      );
      expect(channel).toBe('mock-channel');

      // Trigger the postgres event callback to test if custom callback is executed
      const eventCallback = (mockOn.mock.calls[0] as any)[2];
      eventCallback({ new: { id: 'new-msg', body: 'hello real-time' } });
      expect(callback).toHaveBeenCalledWith({ id: 'new-msg', body: 'hello real-time' });
    });
  });
});
