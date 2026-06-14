const OPEN_INVITE_MODAL_EVENT = 'macrotracker:open-invite-modal';

export function openInviteModal() {
  window.dispatchEvent(new CustomEvent(OPEN_INVITE_MODAL_EVENT));
}

export function onOpenInviteModal(handler: () => void) {
  window.addEventListener(OPEN_INVITE_MODAL_EVENT, handler);
  return () => window.removeEventListener(OPEN_INVITE_MODAL_EVENT, handler);
}
