# Implementation Plan: Professional Portal UI/UX Modernization

## Overview

This implementation plan details the migration of the MacroTracker Professional Portal from vanilla HTML/CSS/JavaScript to a modern React 19 + TypeScript + Vite stack with shadcn/ui components and Tailwind CSS v4. The implementation follows a phased approach starting with foundational setup, followed by core features, and finishing with advanced functionality and testing.

## Tasks

- [-] 1. Project setup and infrastructure
  - [-] 1.1 Initialize Vite + React 19 + TypeScript project
    - Create new Vite project with React template and TypeScript
    - Configure tsconfig.json with strict type checking
    - Set up folder structure matching design document
    - Configure path aliases for cleaner imports (@/components, @/lib, etc.)
    - _Requirements: 11.5, 20.7_

  - [-] 1.2 Configure Tailwind CSS v4 and design system
    - Install and configure Tailwind CSS v4
    - Create theme/colors.ts with Material Design 3 color palette
    - Configure Tailwind config with custom colors, fonts (Poppins), and design tokens
    - Set up PostCSS configuration
    - _Requirements: 3.1, 3.2, 3.5_

  - [-] 1.3 Install and configure shadcn/ui components
    - Initialize shadcn/ui in the project
    - Install base components: button, card, input, badge, dialog, sheet, toast, tooltip, skeleton, select, label, separator, avatar
    - Customize component styles to match MacroTracker design system
    - _Requirements: 3.1, 3.2_

  - [-] 1.4 Set up Supabase client and types
    - Install @supabase/supabase-js
    - Create lib/supabase.ts with Supabase client configuration
    - Generate TypeScript types from Supabase database schema
    - Create types/database.types.ts and types/index.ts
    - _Requirements: 1.1, 15.1_

  - [-] 1.5 Configure testing framework
    - Install and configure Vitest for unit testing
    - Install @testing-library/react and @testing-library/jest-dom
    - Install Playwright for E2E testing
    - Install fast-check for property-based testing
    - Create test setup files and configuration
    - _Requirements: 20.1, 20.2, 20.6_

- [~] 2. Checkpoint - Verify project foundation
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 3. Authentication system
  - [~] 3.1 Create authentication hook and utilities
    - Implement useAuth hook with session management
    - Create signInWithMagicLink function
    - Create signOut function
    - Implement session persistence and restoration
    - _Requirements: 1.1, 1.2, 1.4, 1.5_

  - [~] 3.2 Build login page and components
    - Create LoginPage component
    - Create LoginForm component with email input and validation
    - Create MagicLinkSent confirmation component
    - Implement email format validation
    - _Requirements: 1.1, 1.6_

  - [ ]* 3.3 Write property test for email validation
    - **Property 1: Email Format Validation**
    - **Validates: Requirements 1.6**

  - [~] 3.4 Create auth guard and protected routes
    - Implement ProtectedRoute component
    - Set up React Router with public/protected routes
    - Implement redirect to login for unauthenticated users
    - Implement redirect preservation for post-login navigation
    - _Requirements: 1.2, 1.3, 14.2_

  - [ ]* 3.5 Write integration tests for authentication flow
    - Test magic link email sending
    - Test session restoration
    - Test logout flow
    - _Requirements: 20.3_

- [ ] 4. Layout and navigation
  - [~] 4.1 Create core layout components
    - Create Sidebar component with navigation items
    - Create Header component with user info
    - Create AppShell component wrapping authenticated pages
    - Implement responsive behavior (fixed sidebar desktop, drawer mobile)
    - _Requirements: 4.1, 4.2, 4.7_

  - [~] 4.2 Implement navigation state and routing
    - Set up React Router v6 with lazy loading for code splitting
    - Implement active route highlighting
    - Create navigation items with icons (lucide-react)
    - Add MacroTracker brand lockup and status indicator
    - _Requirements: 4.3, 4.5, 4.6, 11.5_

  - [~] 4.3 Implement unread message badge system
    - Create badge display logic for navigation items
    - Integrate unread count query from Supabase
    - Update badge when new messages arrive
    - _Requirements: 4.4, 5.3_

  - [ ]* 4.4 Write unit tests for navigation components
    - Test active route highlighting
    - Test badge count display
    - Test responsive drawer behavior
    - _Requirements: 20.1_

- [ ] 5. Professional profile management
  - [~] 5.1 Create professional data hook and API layer
    - Implement useProfessional hook with TanStack Query
    - Create fetch professional profile query
    - Create update professional mutation with optimistic updates
    - Implement cache invalidation strategy
    - _Requirements: 2.1, 2.4, 11.7_

  - [~] 5.2 Build profile UI components
    - Create ProfilePage component
    - Create ProfileCard component displaying current profile data
    - Create ProfileForm component with display name and business name inputs
    - Create ProStatusBadge component
    - _Requirements: 2.1, 2.5_

  - [~] 5.3 Implement profile validation and error handling
    - Add display name length validation (2-100 characters)
    - Add business name length validation (max 150 characters)
    - Implement error display without data modification on failure
    - Add input sanitization
    - _Requirements: 2.2, 2.3, 2.6, 2.7, 15.3_

  - [ ]* 5.4 Write property tests for profile validation
    - **Property 2: Display Name Length Validation**
    - **Property 3: Business Name Length Validation**
    - **Property 4: Profile Update Persistence**
    - **Validates: Requirements 2.2, 2.3, 2.4**

  - [ ]* 5.5 Write unit tests for profile components
    - Test profile form submission
    - Test validation error display
    - Test pro status badge rendering
    - _Requirements: 20.1_


- [ ] 6. Theme system (light/dark mode)
  - [~] 6.1 Create theme store and toggle functionality
    - Implement themeStore with Zustand
    - Create useTheme hook
    - Implement theme toggle function
    - Implement system preference detection
    - Persist theme preference to localStorage
    - _Requirements: 3.3, 3.4_

  - [~] 6.2 Apply theme classes and color tokens
    - Configure Tailwind dark mode class strategy
    - Apply theme-aware color classes to all components
    - Verify color contrast ratios meet WCAG 2.1 AA standards
    - _Requirements: 3.3, 3.6_

- [ ] 7. Client relationship management
  - [~] 7.1 Create client data hooks
    - Implement useClients hook with TanStack Query
    - Create query for fetching client relationships
    - Include latest snapshot and unread count in query
    - Implement client list sorting by recent activity
    - _Requirements: 5.1, 5.2, 5.4, 5.6_

  - [~] 7.2 Build client list UI components
    - Create ClientsPage component
    - Create ClientList component with mapping
    - Create ClientCard component with status, date, and snapshot display
    - Implement client card click navigation to detail page
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [ ]* 7.3 Write property tests for client list rendering
    - **Property 7: Client List Rendering Completeness**
    - **Property 8: Latest Snapshot Display**
    - **Property 9: Client List Sorting by Activity**
    - **Validates: Requirements 5.1, 5.2, 5.4, 5.6**

  - [~] 7.4 Implement empty state and loading states
    - Create EmptyState component with invitation action
    - Add loading skeleton placeholders
    - Implement error state display
    - _Requirements: 5.7, 18.7_

  - [ ]* 7.5 Write unit tests for client components
    - Test client card rendering with all fields
    - Test empty state display
    - Test loading state skeletons
    - _Requirements: 20.1_


- [ ] 8. Client invitation system
  - [~] 8.1 Create invitation hooks and API layer
    - Implement useInvites hook for fetching invitations
    - Implement useCreateInvitation mutation
    - Generate unique invitation codes
    - Store invitations with creation timestamp
    - _Requirements: 6.1, 6.3_

  - [~] 8.2 Build invitation UI components
    - Create InvitesPage component
    - Create InviteGenerator component with create button
    - Create InviteList component displaying all invitations
    - Display invitation codes in copy-friendly format
    - Show invitation status (pending, accepted)
    - _Requirements: 6.2, 6.4_

  - [~] 8.3 Implement client limit enforcement
    - Check professional client limit before creating invitation
    - Display upgrade prompt when at client limit
    - Disable invitation creation when limit reached
    - _Requirements: 6.6_

  - [ ]* 8.4 Write property tests for invitation system
    - **Property 10: Invitation Code Uniqueness**
    - **Property 11: Invitation Persistence with Timestamp**
    - **Property 12: Invitation List Display**
    - **Validates: Requirements 6.1, 6.3, 6.4**

  - [ ]* 8.5 Write unit tests for invitation components
    - Test invitation code generation uniqueness
    - Test client limit check
    - Test upgrade prompt display
    - _Requirements: 20.1_

- [~] 9. Checkpoint - Verify core features
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 10. Real-time messaging system
  - [~] 10.1 Create message hooks with real-time subscriptions
    - Implement useMessages hook with TanStack Query
    - Subscribe to Supabase Realtime for new messages
    - Implement automatic cache updates on new messages
    - Create useSendMessage mutation
    - Create useMarkMessagesAsRead mutation
    - _Requirements: 7.1, 7.2, 7.3_

  - [~] 10.2 Build chat UI components
    - Create ChatPanel component with message list
    - Create message input field with send button
    - Display messages with body, timestamp, and author role styling
    - Implement auto-scroll to latest message
    - Implement Enter key to send message
    - _Requirements: 7.1, 7.4, 7.6, 7.8_

  - [~] 10.3 Implement message read tracking
    - Auto-mark client messages as read when viewed
    - Update unread count in real-time
    - Only mark unread messages (filter by professional_read_at)
    - _Requirements: 7.5_

  - [~] 10.4 Add message input validation
    - Disable send button when input is empty or whitespace only
    - Clear input after successful send
    - _Requirements: 7.7_

  - [ ]* 10.5 Write property tests for messaging
    - **Property 13: Message Chronological Ordering**
    - **Property 14: Sent Message Immediate Display**
    - **Property 15: Message Rendering Completeness**
    - **Property 16: Whitespace Message Validation**
    - **Validates: Requirements 7.1, 7.2, 7.4, 7.7**

  - [ ]* 10.6 Write integration tests for messaging
    - Test real-time message delivery
    - Test read status updates
    - Test optimistic message sending
    - _Requirements: 20.4_

- [ ] 11. Client detail page and progress monitoring
  - [~] 11.1 Create client detail hooks
    - Implement useClientDetail hook
    - Implement useClientSnapshots hook
    - Fetch client relationship data
    - Fetch all daily snapshots with sorting
    - _Requirements: 8.1_

  - [~] 11.2 Build client detail page
    - Create ClientDetailPage component
    - Display client header with ID, status, connection date
    - Integrate ChatPanel component
    - Create snapshot list section
    - _Requirements: 5.2, 8.1_

  - [~] 11.3 Build snapshot display components
    - Create SnapshotCard component
    - Display date, actual values, and target values for all macros
    - Calculate and display adherence percentage for each macro
    - Format macro values as rounded integers
    - Apply visual distinction for met vs. unmet goals
    - Sort snapshots by date descending
    - _Requirements: 8.2, 8.3, 8.4, 8.5, 8.7_

  - [~] 11.4 Implement snapshot empty state
    - Display informative empty state when no snapshots exist
    - _Requirements: 8.6_

  - [ ]* 11.5 Write property tests for snapshot display
    - **Property 17: Snapshot Rendering Completeness**
    - **Property 18: Adherence Percentage Calculation**
    - **Property 19: Snapshot Chronological Sorting**
    - **Property 20: Goal Achievement Visual Distinction**
    - **Property 21: Macro Value Integer Formatting**
    - **Validates: Requirements 8.2, 8.3, 8.4, 8.5, 8.7**

  - [ ]* 11.6 Write unit tests for snapshot components
    - Test adherence calculation accuracy
    - Test empty state display
    - Test visual distinction logic
    - _Requirements: 20.1_

- [ ] 12. Nutrition plan creation
  - [~] 12.1 Create nutrition plan hooks
    - Implement usePlans hook for fetching plans
    - Implement useCreatePlan mutation
    - Implement useUpdatePlan mutation
    - _Requirements: 9.8_

  - [~] 12.2 Build plan creation form
    - Create PlanBuilder component
    - Add plan name input with validation (3-100 characters)
    - Add objective selector (general_fitness, muscle_gain, weight_loss, maintenance)
    - Create 7-day macro goal inputs (one per weekday)
    - _Requirements: 9.1, 9.2, 9.3_

  - [~] 12.3 Implement plan validation
    - Validate all macro goals are positive integers greater than zero
    - Ensure all 7 days have values before saving
    - Associate plan with professional and target client
    - _Requirements: 9.4, 9.5, 9.6_

  - [~] 12.4 Add plan status management
    - Allow marking plans as active, inactive, or completed
    - Display success confirmation on plan creation
    - _Requirements: 9.7, 9.8_

  - [ ]* 12.5 Write property tests for plan validation
    - **Property 22: Nutrition Plan Name Validation**
    - **Property 23: Macro Goal Positive Integer Validation**
    - **Validates: Requirements 9.1, 9.4, 9.5**

  - [ ]* 12.6 Write unit tests for plan components
    - Test plan form validation
    - Test 7-day goal completeness check
    - Test plan status updates
    - _Requirements: 20.1_

- [ ] 13. Billing and subscription management
  - [~] 13.1 Build billing page and tier display
    - Create BillingPage component
    - Create TierCard component for each subscription tier
    - Display current pro status prominently
    - Show client limits for each tier
    - _Requirements: 10.1, 10.2, 10.3_

  - [~] 13.2 Implement Stripe checkout integration
    - Create Stripe checkout session API call
    - Open Stripe checkout in new window on tier selection
    - Handle successful checkout completion
    - Update pro status to trialing or active after checkout
    - _Requirements: 10.4, 10.5_

  - [~] 13.3 Add subscription status warnings
    - Display payment required warning for past_due status
    - Restrict client management features for canceled status
    - Display subscription renewal date when applicable
    - _Requirements: 10.6, 10.7, 10.8_

  - [ ]* 13.4 Write integration tests for billing flow
    - Test Stripe checkout initiation
    - Test status update after successful payment
    - Test feature restriction for canceled subscriptions
    - _Requirements: 20.5_

- [~] 14. Checkpoint - Verify advanced features
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 15. Client search and filtering
  - [~] 15.1 Implement search functionality
    - Add search input field to ClientsPage
    - Implement search filtering by client ID (case-insensitive)
    - Add 300ms debounce to search input
    - _Requirements: 16.1, 16.2, 16.3_

  - [~] 15.2 Add status filter options
    - Create filter UI for client status
    - Implement multi-filter logic (all filters must match)
    - Display empty state when no clients match filters
    - _Requirements: 16.4, 16.5, 16.6_

  - [~] 15.3 Implement filter state persistence
    - Preserve filter state in URL query params or localStorage
    - Restore filters when returning to clients page
    - _Requirements: 16.7_

  - [ ]* 15.4 Write property tests for filtering
    - **Property 32: Client Search Filtering**
    - **Property 33: Multi-Filter Client Display**
    - **Validates: Requirements 16.2, 16.5**

  - [ ]* 15.5 Write unit tests for search and filter
    - Test search debouncing
    - Test filter combination logic
    - Test filter persistence
    - _Requirements: 20.1_

- [ ] 16. Animations and microinteractions
  - [~] 16.1 Set up Framer Motion
    - Install framer-motion
    - Configure motion components
    - Check and respect prefers-reduced-motion setting
    - _Requirements: 18.6_

  - [~] 16.2 Implement button hover and press animations
    - Add scale to 102% on hover
    - Add scale to 98% on press/tap
    - Apply to all button components
    - _Requirements: 18.1, 18.2_

  - [~] 16.3 Add list item animations
    - Fade in list items with 200ms animation
    - Implement staggered animations for lists
    - Apply to client list, invitation list, snapshot list
    - _Requirements: 18.3_

  - [~] 16.4 Add modal and page transition animations
    - Animate modals from 95% to 100% scale with fade-in
    - Add smooth fade transitions between pages
    - _Requirements: 18.4, 18.5_

  - [~] 16.5 Enhance loading states with skeleton animations
    - Add pulsing animation to skeleton placeholders
    - Apply to all loading states (clients, messages, snapshots)
    - _Requirements: 18.7_

- [ ] 17. Accessibility implementation
  - [~] 17.1 Implement keyboard navigation
    - Ensure Tab/Shift+Tab moves focus in logical order
    - Add Enter/Space key handlers to all interactive elements
    - Implement Escape key handler for modal dialogs
    - Add visible focus indicators to all interactive elements
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

  - [~] 17.2 Implement focus management for modals
    - Trap focus within open modals
    - Return focus to triggering element on modal close
    - _Requirements: 12.6, 12.7_

  - [ ]* 17.3 Write property tests for keyboard navigation
    - **Property 24: Keyboard Tab Order Correctness**
    - **Validates: Requirements 12.1, 12.2**

  - [~] 17.4 Add semantic HTML and ARIA attributes
    - Use semantic HTML elements (nav, main, article, aside, button)
    - Add ARIA labels to icon-only buttons
    - Add aria-live regions for dynamic content
    - Associate form errors with fields using aria-describedby
    - Mark required fields with aria-required
    - Add aria-current="page" to current navigation item
    - Add loading state announcements
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6, 13.7_

  - [ ]* 17.5 Write property tests for ARIA implementation
    - **Property 25: Icon Button ARIA Label Completeness**
    - **Property 26: Form Error ARIA Association**
    - **Property 27: Required Field ARIA Marking**
    - **Validates: Requirements 13.2, 13.4, 13.5**

  - [ ]* 17.6 Conduct accessibility audit with Lighthouse
    - Run Lighthouse accessibility audit
    - Verify WCAG 2.1 Level AA compliance
    - Fix any issues identified
    - _Requirements: 3.6_

- [ ] 18. Error handling and recovery
  - [~] 18.1 Create error boundary component
    - Implement ErrorBoundary class component
    - Add fallback UI with reload option
    - Log errors to console
    - Wrap app in ErrorBoundary
    - _Requirements: 14.6_

  - [~] 18.2 Implement API error handling
    - Display user-friendly error messages for API failures
    - Implement automatic retry with exponential backoff (up to 3 attempts)
    - Configure TanStack Query retry strategy
    - _Requirements: 14.1, 14.3_

  - [ ]* 18.3 Write property tests for error handling
    - **Property 28: API Error User-Friendly Messaging**
    - **Property 29: Validation Error Field Highlighting**
    - **Validates: Requirements 14.1, 14.4**

  - [~] 18.4 Add validation error handling
    - Highlight invalid form fields visually
    - Display specific validation error messages
    - Associate errors with fields for screen readers
    - _Requirements: 14.4_

  - [~] 18.5 Implement auth expiration handling
    - Redirect to login on expired session
    - Preserve intended destination URL
    - Display session expired message
    - _Requirements: 14.2_

  - [~] 18.6 Add Stripe checkout error recovery
    - Display error details when checkout fails
    - Provide retry option
    - _Requirements: 14.5_

- [ ] 19. Security implementation
  - [~] 19.1 Implement input validation and sanitization
    - Validate all user input with Zod schemas
    - Sanitize user-generated content before display
    - Prevent XSS with HTML sanitization using DOMPurify
    - _Requirements: 15.3, 15.5_

  - [ ]* 19.2 Write property tests for input sanitization
    - **Property 30: User Input Sanitization**
    - **Property 31: HTML Content Sanitization**
    - **Validates: Requirements 15.3, 15.5**

  - [~] 19.3 Configure Content Security Policy
    - Add CSP meta tag to index.html
    - Configure allowed sources for scripts, styles, images, fonts
    - Allow connections to Supabase and Stripe domains
    - _Requirements: 15.2_

  - [~] 19.4 Implement secure token storage
    - Verify Supabase stores tokens in httpOnly cookies
    - Never expose API keys or secrets in client code
    - _Requirements: 15.4, 15.7_

  - [~] 19.5 Add request origin verification
    - Verify request origin for sensitive operations (if needed in Edge Functions)
    - _Requirements: 15.6_

- [ ] 20. Performance optimization
  - [~] 20.1 Implement code splitting and lazy loading
    - Use React.lazy for page components
    - Wrap lazy components in Suspense with loading fallback
    - Verify bundle splits correctly (one per route)
    - _Requirements: 11.5_

  - [~] 20.2 Configure TanStack Query cache strategy
    - Set staleTime to 5 minutes
    - Set gcTime to 30 minutes
    - Configure retry logic (3 attempts with exponential backoff)
    - _Requirements: 11.6_

  - [~] 20.3 Optimize component rendering
    - Memoize expensive components with React.memo
    - Use custom comparison functions where appropriate
    - Optimize list rendering with proper keys
    - _Requirements: 11.7_

  - [~] 20.4 Implement image optimization
    - Use WebP format with fallback
    - Add loading="lazy" to images
    - Implement responsive images with srcset if needed
    - _Requirements: 11.1, 11.2_

  - [~] 20.5 Optimize bundle size
    - Run Vite build analysis
    - Ensure gzipped bundle is under 150 KB
    - Remove unused dependencies
    - _Requirements: 11.4_

  - [ ]* 20.6 Run Lighthouse performance audit
    - Verify FCP < 1.5s
    - Verify LCP < 2.5s
    - Verify TTI < 3.5s
    - Verify CLS < 0.1
    - Fix any issues identified
    - _Requirements: 11.1, 11.2, 11.3_

- [ ] 21. Internationalization foundation
  - [~] 21.1 Set up Spanish language interface
    - Extract all UI text strings to translation keys
    - Implement Spanish translations for all interface text
    - Use consistent terminology matching MacroTracker mobile app
    - _Requirements: 19.1, 19.2_

  - [~] 21.2 Implement locale-aware formatting
    - Format dates using user's locale (date-fns)
    - Format numbers using user's locale
    - Apply Spanish formatting throughout
    - _Requirements: 19.3, 19.4_

  - [~] 21.3 Prepare for multi-language expansion
    - Structure translation strings for future expansion
    - Ensure error messages use translation keys
    - Document translation key structure
    - _Requirements: 19.5, 19.6, 19.7_

- [ ] 22. Offline capability (basic)
  - [~] 22.1 Implement offline detection
    - Add online/offline status indicator
    - Display offline status clearly
    - _Requirements: 17.2_

  - [~] 22.2 Display cached data when offline
    - Show previously loaded client data when offline
    - Display message requiring connection for write operations
    - _Requirements: 17.1, 17.3_

  - [~] 22.3 Implement automatic sync on reconnection
    - Detect when connectivity is restored
    - Preserve form data during offline period
    - Allow retry when online again
    - _Requirements: 17.4, 17.6_

  - [~] 22.4 Configure TanStack Query for offline support
    - Cache most recently viewed 50 clients
    - Use appropriate cache time for offline access
    - _Requirements: 17.5_


- [ ] 23. Dashboard page implementation
  - [~] 23.1 Create dashboard page with hero stats
    - Create DashboardPage component
    - Create StatCard component for key metrics
    - Display active clients count
    - Display unread messages count with urgency badge
    - Show trend information (e.g., "+12% vs mes anterior")
    - _Requirements: 5.1, 7.3_

  - [~] 23.2 Add quick actions section
    - Create QuickActionCard component
    - Add "Crear Invitación" quick action
    - Add "Nuevo Plan" quick action
    - Link to appropriate pages
    - _Requirements: 6.1, 9.1_

  - [~] 23.3 Implement recent activity feed
    - Create ActivityFeed component
    - Display recent client connections, messages, and snapshot updates
    - Limit to 5 most recent items
    - _Requirements: 5.6_

  - [ ]* 23.4 Write unit tests for dashboard components
    - Test stat card rendering
    - Test quick action navigation
    - Test activity feed sorting
    - _Requirements: 20.1_

- [ ] 24. End-to-end testing
  - [ ]* 24.1 Write E2E test for authentication flow
    - Test magic link login flow
    - Test session persistence
    - Test logout flow
    - _Requirements: 20.3_

  - [ ]* 24.2 Write E2E test for client management flow
    - Test viewing client list
    - Test client detail navigation
    - Test snapshot viewing
    - _Requirements: 20.4_

  - [ ]* 24.3 Write E2E test for invitation flow
    - Test invitation creation
    - Test invitation code display
    - Test invitation list rendering
    - _Requirements: 20.4_

  - [ ]* 24.4 Write E2E test for plan creation flow
    - Test plan form submission
    - Test validation errors
    - Test successful plan creation
    - _Requirements: 20.5_

  - [ ]* 24.5 Write E2E test for messaging flow
    - Test sending messages
    - Test real-time message reception
    - Test read status updates
    - _Requirements: 20.4_

- [ ] 25. Documentation and deployment preparation
  - [~] 25.1 Create environment configuration
    - Create .env.example with all required variables
    - Document Supabase configuration requirements
    - Document Stripe API key requirements
    - _Requirements: 15.7_

  - [~] 25.2 Write project README
    - Document project setup steps
    - Document available npm scripts
    - Document folder structure
    - Document component usage patterns
    - _Requirements: 20.7_

  - [~] 25.3 Configure production build
    - Optimize Vite config for production
    - Configure build output directory
    - Test production build locally
    - _Requirements: 11.4, 11.5_

  - [~] 25.4 Set up CI/CD pipeline configuration
    - Create CI workflow for running tests
    - Configure linting and type checking in CI
    - Prepare deployment configuration (Vercel/Netlify)
    - _Requirements: 20.7_

- [~] 26. Final checkpoint - Complete testing and verification
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- Integration and E2E tests validate complete user workflows
- The implementation uses React 19 + TypeScript as specified in the design document
- All components should follow the shadcn/ui patterns and MacroTracker design system
- TanStack Query handles server state with caching and optimistic updates
- Zustand manages client-side state (auth session, theme)
- Framer Motion provides smooth animations respecting user preferences
- Accessibility is built in from the start with ARIA attributes and keyboard navigation


## Task Dependency Graph

```json
{
  "waves": [
    {
      "id": 0,
      "tasks": ["1.1", "1.2", "1.3", "1.4", "1.5"]
    },
    {
      "id": 1,
      "tasks": ["3.1", "3.2", "4.1", "6.1"]
    },
    {
      "id": 2,
      "tasks": ["3.3", "3.4", "4.2", "6.2"]
    },
    {
      "id": 3,
      "tasks": ["3.5", "4.3", "5.1"]
    },
    {
      "id": 4,
      "tasks": ["4.4", "5.2", "5.3"]
    },
    {
      "id": 5,
      "tasks": ["5.4", "5.5", "7.1"]
    },
    {
      "id": 6,
      "tasks": ["7.2", "8.1"]
    },
    {
      "id": 7,
      "tasks": ["7.3", "7.4", "8.2", "8.3"]
    },
    {
      "id": 8,
      "tasks": ["7.5", "8.4", "8.5"]
    },
    {
      "id": 9,
      "tasks": ["10.1", "11.1", "12.1", "13.1"]
    },
    {
      "id": 10,
      "tasks": ["10.2", "10.3", "10.4", "11.2", "12.2"]
    },
    {
      "id": 11,
      "tasks": ["10.5", "10.6", "11.3", "11.4", "12.3", "12.4", "13.2", "13.3"]
    },
    {
      "id": 12,
      "tasks": ["11.5", "11.6", "12.5", "12.6", "13.4"]
    },
    {
      "id": 13,
      "tasks": ["15.1", "15.2", "15.3", "16.1"]
    },
    {
      "id": 14,
      "tasks": ["15.4", "15.5", "16.2", "16.3", "16.4", "16.5"]
    },
    {
      "id": 15,
      "tasks": ["17.1", "17.2", "18.1", "18.2", "19.1"]
    },
    {
      "id": 16,
      "tasks": ["17.3", "17.4", "18.3", "18.4", "18.5", "18.6", "19.2", "19.3", "19.4", "19.5"]
    },
    {
      "id": 17,
      "tasks": ["17.5", "17.6", "20.1", "20.2", "20.3", "20.4", "20.5", "21.1"]
    },
    {
      "id": 18,
      "tasks": ["20.6", "21.2", "21.3", "22.1", "22.2"]
    },
    {
      "id": 19,
      "tasks": ["22.3", "22.4", "23.1", "23.2", "23.3"]
    },
    {
      "id": 20,
      "tasks": ["23.4", "24.1", "24.2", "24.3"]
    },
    {
      "id": 21,
      "tasks": ["24.4", "24.5", "25.1", "25.2"]
    },
    {
      "id": 22,
      "tasks": ["25.3", "25.4"]
    }
  ]
}
```
