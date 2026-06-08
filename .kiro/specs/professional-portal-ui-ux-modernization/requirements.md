# Requirements Document

## Introduction

The MacroTracker Professional Portal is a B2B web application that enables nutrition professionals to manage their clients, create meal plans, monitor client progress, and communicate with clients. The current implementation uses vanilla HTML/CSS/JavaScript, which limits maintainability, scalability, and user experience quality. This document defines the requirements for modernizing the portal to professional standards using modern web technologies while maintaining consistency with the MacroTracker Flutter mobile application.

## Glossary

- **Professional**: A nutrition professional using the MacroTracker Pro Portal to manage clients
- **Client**: An end-user of the MacroTracker mobile app who has connected with a professional
- **Portal**: The MacroTracker Professional Portal web application
- **Magic_Link**: A passwordless authentication link sent via email
- **Pro_Status**: The subscription status of a professional (inactive, trialing, active, past_due, canceled)
- **Client_Relationship**: The connection between a professional and their client
- **Snapshot**: A daily summary of a client's macro nutrition tracking data
- **Nutrition_Plan**: A structured meal plan created by a professional for a client
- **Real_Time_Messaging**: Bidirectional communication system between professional and client
- **Supabase**: The backend-as-a-service platform providing authentication, database, and real-time features
- **Design_System**: The visual language and component library aligning with MacroTracker Flutter app
- **Bundle_Size**: The total size of JavaScript and CSS files delivered to the browser
- **Row_Level_Security**: Database-level security policies controlling data access

## Requirements

### Requirement 1: User Authentication

**User Story:** As a nutrition professional, I want to authenticate securely without managing passwords, so that I can quickly access my portal without security concerns.

#### Acceptance Criteria

1. WHEN a professional enters their email address, THE Portal SHALL send a magic link to that email address
2. WHEN a professional clicks a valid magic link, THE Portal SHALL authenticate the professional and redirect to the dashboard
3. WHEN a professional clicks an expired or invalid magic link, THE Portal SHALL display an error message and allow requesting a new link
4. WHEN an authenticated professional closes their browser, THE Portal SHALL maintain the session for up to 7 days
5. WHEN a professional logs out, THE Portal SHALL immediately invalidate the session and redirect to the login page
6. THE Portal SHALL validate email format before attempting to send magic links

### Requirement 2: Professional Profile Management

**User Story:** As a nutrition professional, I want to create and update my professional profile, so that clients can identify me correctly and I can present my business professionally.

#### Acceptance Criteria

1. WHEN a professional first authenticates, THE Portal SHALL prompt for profile creation with required fields
2. THE Portal SHALL require a display name between 2 and 100 characters
3. THE Portal SHALL allow an optional business name up to 150 characters
4. WHEN a professional updates their profile, THE Portal SHALL persist changes to the database immediately
5. THE Portal SHALL display the professional's current pro status (inactive, trialing, active, past_due, canceled)
6. WHEN profile update fails, THE Portal SHALL display a clear error message without modifying displayed data
7. THE Portal SHALL validate all input fields before submission

### Requirement 3: Visual Design System Consistency

**User Story:** As a nutrition professional familiar with the MacroTracker mobile app, I want the portal to use the same visual language, so that the experience feels cohesive across platforms.

#### Acceptance Criteria

1. THE Portal SHALL use the Material Design 3 color palette defined in the MacroTracker Flutter app
2. THE Portal SHALL use Poppins font family throughout the interface
3. THE Portal SHALL provide both light and dark theme modes
4. WHEN a user's system prefers dark mode, THE Portal SHALL default to dark theme
5. THE Portal SHALL use consistent spacing, border radius, and elevation following Material Design 3 guidelines
6. THE Portal SHALL display color contrast ratios meeting WCAG 2.1 Level AA standards (minimum 4.5:1)

### Requirement 4: Responsive Layout and Navigation

**User Story:** As a nutrition professional, I want to navigate the portal efficiently on both desktop and mobile devices, so that I can manage my practice from anywhere.

#### Acceptance Criteria

1. WHEN viewing on desktop (>768px width), THE Portal SHALL display a fixed sidebar with navigation
2. WHEN viewing on mobile (≤768px width), THE Portal SHALL display a hamburger menu button that opens a navigation drawer
3. THE Portal SHALL highlight the current page in the navigation menu
4. WHEN a professional has unread messages, THE Portal SHALL display a badge count on the "Clientes" navigation item
5. THE Portal SHALL display the MacroTracker brand lockup and "Pro Portal" title in the navigation area
6. THE Portal SHALL provide a status indicator showing the professional's online status
7. WHEN a navigation item is clicked, THE Portal SHALL navigate to the appropriate page without full page reload

### Requirement 5: Client Relationship Management

**User Story:** As a nutrition professional, I want to view and manage all my client connections, so that I can track who I'm working with and their current status.

#### Acceptance Criteria

1. THE Portal SHALL display a list of all client relationships for the authenticated professional
2. WHEN displaying clients, THE Portal SHALL show client ID, connection status, and connection date
3. WHEN a client has sent unread messages, THE Portal SHALL display an unread message count badge
4. WHEN a client has recent snapshot data, THE Portal SHALL display the latest daily summary
5. WHEN a professional clicks on a client card, THE Portal SHALL navigate to the detailed client view
6. THE Portal SHALL sort clients by most recent activity first
7. WHEN the professional has no clients, THE Portal SHALL display an informative empty state with invitation creation action

### Requirement 6: Client Invitation System

**User Story:** As a nutrition professional, I want to generate invitation codes for potential clients, so that clients can connect with me through the mobile app.

#### Acceptance Criteria

1. WHEN a professional creates an invitation, THE Portal SHALL generate a unique invitation code
2. THE Portal SHALL display the invitation code in a format easy to copy and share
3. WHEN an invitation is created, THE Portal SHALL store it in the database with creation timestamp
4. THE Portal SHALL display all active invitations with their status
5. WHEN an invitation is used by a client, THE Portal SHALL update its status to "accepted"
6. WHEN a professional is at their client limit, THE Portal SHALL prevent creating new invitations and display upgrade prompt

### Requirement 7: Real-Time Client Messaging

**User Story:** As a nutrition professional, I want to exchange messages with my clients in real-time, so that I can provide timely support and guidance.

#### Acceptance Criteria

1. WHEN viewing a client detail page, THE Portal SHALL display all messages in chronological order
2. WHEN a professional sends a message, THE Portal SHALL immediately display it in the message list without page reload
3. WHEN a client sends a message from the mobile app, THE Portal SHALL update the message list within 2 seconds
4. WHEN messages are displayed, THE Portal SHALL show message body, timestamp, and author role
5. WHEN a professional views unread client messages, THE Portal SHALL mark them as read automatically
6. THE Portal SHALL auto-scroll to the most recent message when the chat loads or new messages arrive
7. WHEN message input is empty or contains only whitespace, THE Portal SHALL disable the send button
8. WHEN the Enter key is pressed in the message input, THE Portal SHALL send the message

### Requirement 8: Client Progress Monitoring

**User Story:** As a nutrition professional, I want to view my clients' daily macro tracking snapshots, so that I can monitor their adherence and provide informed guidance.

#### Acceptance Criteria

1. WHEN viewing a client detail page, THE Portal SHALL display all available daily snapshots
2. WHEN displaying snapshots, THE Portal SHALL show date, actual values, and target values for calories, protein, carbs, and fat
3. THE Portal SHALL calculate and display adherence percentage for each macro nutrient
4. THE Portal SHALL sort snapshots by date in descending order (most recent first)
5. THE Portal SHALL visually distinguish snapshots where goals were met versus not met
6. WHEN no snapshots exist for a client, THE Portal SHALL display an informative empty state
7. THE Portal SHALL format macro values as whole numbers (rounded)

### Requirement 9: Nutrition Plan Creation

**User Story:** As a nutrition professional, I want to create structured nutrition plans for my clients, so that I can provide clear macro targets for each day of the week.

#### Acceptance Criteria

1. THE Portal SHALL allow creating a nutrition plan with a descriptive name (3-100 characters)
2. THE Portal SHALL require selecting one objective: general_fitness, muscle_gain, weight_loss, or maintenance
3. THE Portal SHALL require defining macro goals for all 7 days of the week
4. WHEN defining daily goals, THE Portal SHALL require positive integer values for calories, protein, carbs, and fat
5. THE Portal SHALL validate that all macro goals are greater than zero before saving
6. WHEN a plan is created, THE Portal SHALL associate it with both the professional and target client
7. THE Portal SHALL allow marking plans as active, inactive, or completed
8. WHEN a professional creates a plan, THE Portal SHALL persist it immediately and display success confirmation

### Requirement 10: Billing and Subscription Management

**User Story:** As a nutrition professional, I want to view my subscription status and manage billing, so that I can maintain active service and upgrade my plan as needed.

#### Acceptance Criteria

1. THE Portal SHALL display the professional's current pro status prominently
2. WHEN pro status is "inactive", THE Portal SHALL display available subscription tiers
3. THE Portal SHALL show client limits for each subscription tier
4. WHEN a professional selects a tier, THE Portal SHALL initiate Stripe checkout in a new window
5. WHEN Stripe checkout completes successfully, THE Portal SHALL update pro status to "trialing" or "active"
6. WHEN pro status is "past_due", THE Portal SHALL display a payment required warning
7. WHEN pro status is "canceled", THE Portal SHALL restrict access to client management features
8. THE Portal SHALL display subscription renewal date when applicable

### Requirement 11: Performance Optimization

**User Story:** As a nutrition professional on a mobile connection, I want the portal to load quickly and respond instantly, so that I can efficiently manage my practice without waiting.

#### Acceptance Criteria

1. THE Portal SHALL achieve First Contentful Paint in less than 1.5 seconds
2. THE Portal SHALL achieve Largest Contentful Paint in less than 2.5 seconds
3. THE Portal SHALL achieve Time to Interactive in less than 3.5 seconds
4. THE Portal SHALL deliver a gzipped bundle size less than 150 KB
5. WHEN navigating between pages, THE Portal SHALL use code splitting to load only necessary JavaScript
6. THE Portal SHALL cache API responses for 5 minutes to reduce redundant requests
7. THE Portal SHALL use optimistic updates for user actions to provide immediate feedback

### Requirement 12: Keyboard Accessibility

**User Story:** As a nutrition professional who relies on keyboard navigation, I want to access all portal features without a mouse, so that I can work efficiently using my preferred input method.

#### Acceptance Criteria

1. WHEN Tab key is pressed, THE Portal SHALL move focus to the next interactive element in logical order
2. WHEN Shift+Tab is pressed, THE Portal SHALL move focus to the previous interactive element
3. WHEN Enter or Space is pressed on a focused button, THE Portal SHALL activate that button
4. WHEN Escape is pressed in a modal dialog, THE Portal SHALL close the dialog
5. THE Portal SHALL display visible focus indicators on all interactive elements
6. WHEN a modal opens, THE Portal SHALL trap focus within the modal until it is closed
7. WHEN a modal closes, THE Portal SHALL return focus to the element that triggered it

### Requirement 13: Screen Reader Support

**User Story:** As a nutrition professional using a screen reader, I want to understand page structure and interactive elements, so that I can navigate and use the portal independently.

#### Acceptance Criteria

1. THE Portal SHALL use semantic HTML elements (nav, main, article, aside, button) for all content
2. THE Portal SHALL provide ARIA labels for all icon-only buttons
3. THE Portal SHALL announce dynamic content changes using aria-live regions
4. WHEN forms have validation errors, THE Portal SHALL associate error messages with form fields using aria-describedby
5. THE Portal SHALL mark required form fields with aria-required="true"
6. THE Portal SHALL use aria-current="page" to indicate the current navigation item
7. WHEN loading content, THE Portal SHALL provide loading state announcements

### Requirement 14: Error Handling and Recovery

**User Story:** As a nutrition professional, I want clear error messages and recovery options when things go wrong, so that I can understand problems and continue working.

#### Acceptance Criteria

1. WHEN an API request fails, THE Portal SHALL display a user-friendly error message describing what went wrong
2. WHEN authentication expires, THE Portal SHALL redirect to login and preserve the intended destination
3. WHEN a network error occurs, THE Portal SHALL automatically retry requests up to 3 times with exponential backoff
4. WHEN a validation error occurs, THE Portal SHALL highlight invalid fields and display specific error messages
5. WHEN Stripe checkout fails, THE Portal SHALL display error details and provide a retry option
6. WHEN an unexpected error occurs, THE Portal SHALL display a fallback error UI with page reload option
7. THE Portal SHALL log all errors to the console for debugging purposes

### Requirement 15: Data Security and Privacy

**User Story:** As a nutrition professional handling client health data, I want the portal to protect sensitive information, so that I maintain client trust and comply with privacy standards.

#### Acceptance Criteria

1. THE Portal SHALL enforce Row Level Security policies preventing professionals from accessing other professionals' data
2. THE Portal SHALL use HTTPS for all communication between browser and server
3. THE Portal SHALL validate and sanitize all user input before processing
4. THE Portal SHALL store authentication tokens in httpOnly cookies
5. WHEN user-generated content is displayed, THE Portal SHALL sanitize HTML to prevent XSS attacks
6. THE Portal SHALL verify request origin for sensitive operations to prevent CSRF
7. THE Portal SHALL never expose API keys or secrets in client-side code

### Requirement 16: Client List Filtering and Search

**User Story:** As a nutrition professional with many clients, I want to filter and search my client list, so that I can quickly find specific clients.

#### Acceptance Criteria

1. THE Portal SHALL provide a search input field on the clients page
2. WHEN search text is entered, THE Portal SHALL filter clients by client ID matching the search term
3. THE Portal SHALL debounce search input by 300 milliseconds to reduce excessive filtering
4. THE Portal SHALL provide filter options for client status (pending, connected, disconnected)
5. WHEN filters are applied, THE Portal SHALL display only clients matching all active filters
6. WHEN no clients match filters, THE Portal SHALL display an informative empty state
7. THE Portal SHALL preserve filter state when navigating away and returning to the clients page

### Requirement 17: Offline Capability and Data Synchronization

**User Story:** As a nutrition professional with unreliable internet, I want the portal to work offline for viewing cached data, so that I can review client information anywhere.

#### Acceptance Criteria

1. WHEN the professional is offline, THE Portal SHALL display previously loaded client data
2. WHEN offline, THE Portal SHALL show a clear offline status indicator
3. WHEN attempting write operations offline, THE Portal SHALL display a message requiring internet connection
4. WHEN connectivity is restored, THE Portal SHALL automatically sync any pending operations
5. THE Portal SHALL cache the most recently viewed 50 clients for offline access
6. WHEN connectivity is lost during an operation, THE Portal SHALL preserve form data and allow retry when online

### Requirement 18: Animated Transitions and Microinteractions

**User Story:** As a nutrition professional, I want smooth visual transitions and responsive feedback, so that the portal feels polished and professional.

#### Acceptance Criteria

1. WHEN hovering over buttons, THE Portal SHALL scale them to 102% of original size
2. WHEN clicking buttons, THE Portal SHALL scale them to 98% of original size
3. WHEN list items appear, THE Portal SHALL fade them in with a 200ms animation
4. WHEN modals open, THE Portal SHALL animate from 95% scale to 100% with fade-in
5. WHEN page transitions occur, THE Portal SHALL use smooth fade transitions
6. THE Portal SHALL respect user's prefers-reduced-motion setting by disabling animations
7. WHEN loading data, THE Portal SHALL display skeleton placeholders that pulse gently

### Requirement 19: Multi-language Support Foundation

**User Story:** As a nutrition professional in a Spanish-speaking market, I want the portal interface in Spanish, so that I can work in my preferred language.

#### Acceptance Criteria

1. THE Portal SHALL display all interface text in Spanish by default
2. THE Portal SHALL use consistent terminology matching the MacroTracker mobile app
3. THE Portal SHALL format dates using the user's locale preferences
4. THE Portal SHALL format numbers using the user's locale preferences
5. THE Portal SHALL provide translation keys for all user-facing text strings
6. WHEN error messages are displayed, THE Portal SHALL show them in the user's language
7. THE Portal SHALL structure text strings to support future multi-language expansion

### Requirement 20: Testing and Quality Assurance

**User Story:** As a development team member, I want comprehensive automated tests, so that we can confidently make changes without breaking existing functionality.

#### Acceptance Criteria

1. THE Portal SHALL include unit tests for all custom hooks
2. THE Portal SHALL include unit tests for all utility functions
3. THE Portal SHALL include integration tests for authentication flow
4. THE Portal SHALL include integration tests for client management flow
5. THE Portal SHALL include end-to-end tests for critical user journeys
6. THE Portal SHALL achieve at least 80% code coverage for business logic
7. THE Portal SHALL run all tests in continuous integration before deployment
