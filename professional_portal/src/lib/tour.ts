import { driver } from 'driver.js';
import type { DriveStep } from 'driver.js';

type TourStrings = {
  nextBtn: string;
  prevBtn: string;
  doneBtn: string;
  skipBtn: string;
  steps: Array<{ title: string; desc: string }>;
};

type TourCallbacks = {
  /** Navigate to a named panel */
  navigateTo: (panel: string) => void;
  /** Select a client for the client-detail steps (pass demo client id) */
  selectDemoClient: () => void;
  /** Switch the tab inside client-detail */
  selectClientTab: (tab: string) => void;
  /** Deselect client when tour is done */
  deselectClient: () => void;
};

/**
 * Delay helper — needed after navigation so the DOM re-renders before
 * Driver.js tries to highlight the next element.
 */
function delay(ms = 150): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Build all 14 tour steps and start the Driver.js tour.
 *
 * The tour is navigation-aware: each step that requires a different panel
 * uses `onHighlightStarted` to trigger the navigation callback, wait for the
 * DOM to settle, and then let Driver.js highlight the correct element.
 */
export function startTour(strings: TourStrings, callbacks: TourCallbacks): void {
  const { navigateTo, selectDemoClient, selectClientTab, deselectClient } = callbacks;

  const steps: DriveStep[] = [
    // ── Step 1: Welcome ─────────────────────────────────────────────────────
    {
      element: '#tour-sidebar-logo',
      popover: {
        title: strings.steps[0]!.title,
        description: strings.steps[0]!.desc,
        side: 'right',
        align: 'center',
      },
    },

    // ── Step 2: Dashboard Metrics ────────────────────────────────────────────
    {
      element: '#tour-dashboard-metrics',
      popover: {
        title: strings.steps[1]!.title,
        description: strings.steps[1]!.desc,
        side: 'bottom',
        align: 'start',
      },
      onHighlightStarted: async () => {
        navigateTo('dashboard-panel');
        await delay(200);
      },
    },

    // ── Step 3: Activity Feed ────────────────────────────────────────────────
    {
      element: '#tour-dashboard-feed',
      popover: {
        title: strings.steps[2]!.title,
        description: strings.steps[2]!.desc,
        side: 'top',
        align: 'start',
      },
    },

    // ── Step 4: Invite Client button ─────────────────────────────────────────
    {
      element: '#tour-topbar-invite',
      popover: {
        title: strings.steps[3]!.title,
        description: strings.steps[3]!.desc,
        side: 'bottom',
        align: 'end',
      },
    },

    // ── Step 5: Client list ──────────────────────────────────────────────────
    {
      element: '#tour-clients-list',
      popover: {
        title: strings.steps[4]!.title,
        description: strings.steps[4]!.desc,
        side: 'right',
        align: 'start',
      },
      onHighlightStarted: async () => {
        navigateTo('clients-panel');
        selectDemoClient();
        await delay(300);
      },
    },

    // ── Step 6: Client summary tab ───────────────────────────────────────────
    {
      element: '#tour-client-summary-tab',
      popover: {
        title: strings.steps[5]!.title,
        description: strings.steps[5]!.desc,
        side: 'bottom',
        align: 'start',
      },
      onHighlightStarted: async () => {
        selectClientTab('summary');
        await delay(200);
      },
    },

    // ── Step 7: Plans tab ────────────────────────────────────────────────────
    {
      element: '#tour-client-plans-tab',
      popover: {
        title: strings.steps[6]!.title,
        description: strings.steps[6]!.desc,
        side: 'bottom',
        align: 'start',
      },
      onHighlightStarted: async () => {
        selectClientTab('plans');
        await delay(200);
      },
    },

    // ── Step 8: Check-ins tab ────────────────────────────────────────────────
    {
      element: '#tour-client-checkins-tab',
      popover: {
        title: strings.steps[7]!.title,
        description: strings.steps[7]!.desc,
        side: 'bottom',
        align: 'start',
      },
      onHighlightStarted: async () => {
        selectClientTab('checkins');
        await delay(200);
      },
    },

    // ── Step 9: Chat tab ─────────────────────────────────────────────────────
    {
      element: '#tour-client-chat-tab',
      popover: {
        title: strings.steps[8]!.title,
        description: strings.steps[8]!.desc,
        side: 'bottom',
        align: 'start',
      },
      onHighlightStarted: async () => {
        selectClientTab('chat');
        await delay(200);
      },
    },

    // ── Step 10: Check-in templates panel ────────────────────────────────────
    {
      element: '#tour-checkins-panel',
      popover: {
        title: strings.steps[9]!.title,
        description: strings.steps[9]!.desc,
        side: 'top',
        align: 'start',
      },
      onHighlightStarted: async () => {
        deselectClient();
        navigateTo('checkins-panel');
        await delay(300);
      },
    },

    // ── Step 11: Recipe library ───────────────────────────────────────────────
    {
      element: '#tour-recipes-panel',
      popover: {
        title: strings.steps[10]!.title,
        description: strings.steps[10]!.desc,
        side: 'top',
        align: 'start',
      },
      onHighlightStarted: async () => {
        navigateTo('recipes-panel');
        await delay(300);
      },
    },

    // ── Step 12: Plan templates ───────────────────────────────────────────────
    {
      element: '#tour-templates-panel',
      popover: {
        title: strings.steps[11]!.title,
        description: strings.steps[11]!.desc,
        side: 'top',
        align: 'start',
      },
      onHighlightStarted: async () => {
        navigateTo('templates-panel');
        await delay(300);
      },
    },

    // ── Step 13: Profile & Billing ────────────────────────────────────────────
    {
      element: '#tour-profile-panel',
      popover: {
        title: strings.steps[12]!.title,
        description: strings.steps[12]!.desc,
        side: 'top',
        align: 'start',
      },
      onHighlightStarted: async () => {
        navigateTo('profile-panel');
        await delay(300);
      },
    },

    // ── Step 14: Finish ───────────────────────────────────────────────────────
    {
      element: '#tour-topbar-invite',
      popover: {
        title: strings.steps[13]!.title,
        description: strings.steps[13]!.desc,
        side: 'bottom',
        align: 'end',
      },
      onHighlightStarted: async () => {
        navigateTo('dashboard-panel');
        await delay(200);
      },
    },
  ];

  const driverInstance = driver({
    showProgress: true,
    animate: true,
    overlayOpacity: 0.65,
    smoothScroll: true,
    allowClose: true,
    steps,
    nextBtnText: strings.nextBtn,
    prevBtnText: strings.prevBtn,
    doneBtnText: strings.doneBtn,
    progressText: '{{current}} / {{total}}',
    popoverClass: 'macro-tour-popover',
    onCloseClick: () => {
      deselectClient();
      driverInstance.destroy();
      localStorage.setItem('tour-completed', '1');
    },
    onDestroyStarted: () => {
      deselectClient();
      localStorage.setItem('tour-completed', '1');
    },
  });

  driverInstance.drive();
}

export function shouldAutoLaunchTour(): boolean {
  return !localStorage.getItem('tour-completed');
}

export function resetTour(): void {
  localStorage.removeItem('tour-completed');
}
