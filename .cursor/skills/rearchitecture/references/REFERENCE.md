# Re-Architecture — Component Architecture Documentation

> **Reusable template for documenting component architecture, separation of concerns, and bounded contexts**

---

## Purpose

This template helps you document and establish:
- **Component boundaries** and separation of concerns
- **Bounded contexts** (domain boundaries)
- **Data flow patterns** and component responsibilities
- **Design principles** for maintainable code
- **Extension points** for future development

**When to use:**
- After splitting large components into smaller ones
- When establishing architecture patterns for a new project
- During refactoring to document intended structure
- When onboarding new developers to the codebase

**Difference from Debug.md:**
- **Debug.md**: Finds bugs, performance issues, accessibility problems (diagnostic)
- **Re-Architecture.md**: Documents structure, boundaries, patterns (architectural)
- Use Debug.md to find problems → Use Re-Architecture.md to establish structure

---

## Prompt Template

```
Document the component architecture of this project following the Re-Architecture template.

## Scope

1. **Analyze Current Structure**
   - Map all components and their locations
   - Identify component sizes (lines of code)
   - Find large components (>500 lines) that may need splitting
   - Identify shared utilities and hooks

2. **Establish Boundaries**
   - Categorize components: Feature (domain) vs UI (presentation) vs Infrastructure
   - Define bounded contexts (domains)
   - Document component responsibilities
   - Map data flow patterns

3. **Document Architecture**
   - Create separation of concerns diagram
   - Document component responsibilities table
   - Define bounded contexts with clear boundaries
   - List design principles being followed
   - Document state management strategy (local vs global)
   - Document error handling boundaries (component → page → app)
   - Document dependency management patterns
   - Document API layer architecture (client, endpoints, caching)
   - Document performance patterns (code splitting, memoization)

4. **Identify Improvements**
   - Components that violate single responsibility
   - Missing separation of concerns
   - Opportunities for better boundaries
   - Reusability improvements
   - State management anti-patterns (prop drilling, unnecessary global state)
   - Missing error boundaries
   - Circular dependencies or tight coupling
   - Performance bottlenecks (missing memoization, large bundles)

## Output Format

Create/update ARCHITECTURE.md with:
- Updated directory structure showing component organization
- Frontend Component Architecture section with:
  - Separation of concerns diagram
  - Component boundaries (Feature/UI/Infrastructure)
  - Data flow diagram
  - Component responsibilities table
  - Bounded contexts (with clear boundaries)
  - Design principles
  - State management architecture (colocation, patterns, normalization)
  - Error handling & resilience patterns (error boundaries, fallback UI)
  - Dependency management (coupling, import organization, circular dependencies)
  - API & data layer architecture (client, endpoints, caching, data fetching)
  - Performance architecture (code splitting, memoization, lazy loading)
- Extension points for future development
```

---

## Architecture Documentation Template

### 1. Directory Structure

```markdown
## Directory Structure

```
project/
├── src/
│   ├── app/                    # Next.js App Router (or pages/)
│   │   ├── page.tsx            # Main page (orchestrator)
│   │   ├── layout.tsx          # Root layout
│   │   └── api/                # API routes (server-side)
│   │       └── [routes].ts
│   ├── components/             # React components (UI layer)
│   │   ├── [Feature]/          # Feature-specific components (optional grouping)
│   │   └── [Component].tsx     # Individual components
│   ├── lib/                    # Shared utilities & types
│   │   ├── types.ts            # TypeScript types
│   │   ├── utils.ts            # Utility functions
│   │   └── [module].ts         # Other shared modules
│   └── hooks/                 # Custom React hooks
│       └── [hook].ts
└── [other directories]
```
```

### 2. Component Architecture Diagram

```markdown
## Frontend Component Architecture

### Separation of Concerns

```
┌─────────────────────────────────────────────────────────────────┐
│                    FRONTEND ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              PRESENTATION LAYER (Components)             │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │                                                          │  │
│  │  Feature Components (Domain-Specific)                    │  │
│  │  ├── [FeatureComponent].tsx    ([Domain])              │  │
│  │                                                          │  │
│  │  UI Components (Reusable)                               │  │
│  │  ├── [UIComponent].tsx         ([Purpose])             │  │
│  │                                                          │  │
│  │  Infrastructure Components                               │  │
│  │  └── [InfraComponent].tsx      ([Cross-cutting])       │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                    │
│                            ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              ORCHESTRATION LAYER (Pages)                │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │                                                          │  │
│  │  page.tsx (Main Page)                                   │  │
│  │  ├── State management                                    │  │
│  │  ├── API calls                                           │  │
│  │  └── Component composition                               │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                    │
│                            ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              UTILITY LAYER (lib/)                        │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │                                                          │  │
│  │  utils.ts         ([Purpose])                          │  │
│  │  types.ts         ([Purpose])                          │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                    │
│                            ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              HOOKS LAYER (hooks/)                       │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │                                                          │  │
│  │  [hook].ts        ([Purpose])                          │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```
```

### 3. Component Boundaries

```markdown
### Component Boundaries

**Feature Components** (Domain-Specific):
- **[ComponentName]**: [Purpose]. Owns [domain] state.
- **[ComponentName]**: [Purpose]. Owns [domain] state.

**UI Components** (Reusable):
- **[ComponentName]**: [Purpose]. Pure presentation, no domain logic.
- **[ComponentName]**: [Purpose]. Pure presentation, receives callbacks.

**Infrastructure Components**:
- **[ComponentName]**: [Purpose]. Cross-cutting concern, [scope].
```

### 4. Data Flow

```markdown
### Data Flow

```
User Interaction
    │
    ▼
page.tsx (Orchestrator)
    │
    ├─→ State updates (useState)
    │
    ├─→ API calls (fetch)
    │   │
    │   └─→ API Routes (server-side)
    │       └─→ [Backend Service]
    │
    └─→ Props to Components
        │
        ├─→ Feature Components (domain state)
        │   └─→ Own state + API calls
        │
        └─→ UI Components (presentation)
            └─→ Props only, no API calls
```
```

### 5. Component Responsibilities Table

```markdown
### Component Responsibilities

| Component | Responsibility | State | API Calls | Dependencies |
|-----------|---------------|-------|-----------|--------------|
| `page.tsx` | Orchestration, routing | [State types] | Yes ([APIs]) | All components |
| `[Component]` | [Purpose] | [State types] | [Yes/No] | [Dependencies] |
```

### 6. Bounded Contexts

```markdown
### Bounded Contexts

**1. [Context Name] Context** (`[components]`)
- **Purpose**: [What this context does]
- **Boundaries**: [Start] → [Middle] → [End]
- **State**: `[state variables]`
- **API**: `[API endpoints]`

**2. [Context Name] Context** (`[components]`)
- **Purpose**: [What this context does]
- **Boundaries**: [Start] → [Middle] → [End]
- **State**: `[state variables]`
- **API**: `[API endpoints]`
```

### 7. Design Principles

```markdown
### Design Principles

1. **Single Responsibility**: Each component has one clear purpose
2. **Composition over Inheritance**: Components compose via props, not inheritance
3. **Props Down, Events Up**: Data flows down, events flow up
4. **Container/Presenter Split**: Pages are containers (logic), components are presenters (UI)
5. **Domain Boundaries**: Feature components own domain state; UI components are stateless
6. **Reusability**: UI components are reusable across contexts
7. **Testability**: Small, focused components are easier to test
```

### 8. State Management Architecture

```markdown
### State Management Strategy

**State Colocation Decision Tree:**
```
State needed by:
├─→ Single component → useState (local state)
├─→ Parent + immediate children → Lift state to parent
├─→ Sibling components → Lift to common ancestor
├─→ Multiple pages/features → Context API or state management library
└─→ Global app state → Zustand/Redux/Jotai
```

**State Management Patterns:**

| Pattern | When to Use | Example |
|---------|-------------|---------|
| **useState** | Component-local state | Form inputs, UI toggles |
| **useReducer** | Complex state logic | Multi-step forms, state machines |
| **Context API** | Shared state across tree | Theme, auth, feature flags |
| **Zustand** | Global state, simple API | User preferences, cart |
| **Redux** | Complex global state, time-travel | Large apps, complex workflows |
| **Jotai** | Atomic state management | Fine-grained reactivity |

**State Normalization:**
- Normalize nested data structures
- Use IDs as keys, not objects
- Store relationships separately
- Denormalize only for display

**Derived State vs Stored State:**
- **Derived**: Computed from other state (useMemo, useCallback)
- **Stored**: Explicitly stored state (useState, useReducer)
- Prefer derived when possible to avoid sync issues

**State Management Thresholds (Optional Guidelines):**
- **Prop drilling**: Passing props through 3+ component levels → Consider Context API
- **Shared state**: State needed by 5+ components → Consider global state management (Zustand/Redux)
- **Cross-page state**: State needed across multiple pages/routes → Use global state management
- **State synchronization**: Multiple components updating same state → Use reducer pattern or state management library
```

### 9. Error Handling & Resilience Patterns

```markdown
### Error Handling Architecture

**Error Boundary Strategy:**
```
┌─────────────────────────────────────────┐
│         App-Level Error Boundary        │
│  (Catches all unhandled errors)         │
└─────────────────────────────────────────┘
              │
    ┌─────────┴─────────┐
    │                   │
┌───▼────┐         ┌───▼────┐
│ Page  │         │ Page   │
│Boundary│         │Boundary│
└───┬────┘         └───┬────┘
    │                   │
┌───▼────┐         ┌───▼────┐
│Feature │         │Feature │
│Boundary│         │Boundary│
└────────┘         └────────┘
```

**Error Handling Layers:**

| Layer | Responsibility | Pattern |
|-------|---------------|---------|
| **Component** | Try/catch for async operations | `try/catch` in event handlers |
| **Page** | Error boundary for feature sections | `<ErrorBoundary>` wrapper |
| **App** | Global error boundary | Root `<ErrorBoundary>` |
| **API** | API error handling | Error responses, retry logic |

**Fallback UI Patterns:**
- **Loading**: Skeleton screens or spinners
- **Error**: Error message with retry button
- **Empty**: Empty state with call-to-action
- **Offline**: Offline indicator with cached content

**Error Recovery Patterns:**
- **Retry**: Exponential backoff for transient errors
- **Fallback**: Show cached data when API fails
- **Graceful Degradation**: Disable features, show message
- **Circuit Breaker**: Stop requests after repeated failures

**Error Logging & Monitoring (Optional):**
- **Error boundaries**: Log errors to monitoring service (Sentry, LogRocket)
- **API errors**: Log failed API calls with context (endpoint, params, user)
- **Error tracking**: Track error frequency and patterns
- **User feedback**: Collect user-reported errors and feedback
- **Error boundaries placement**: Place at feature boundaries, not every component
```

### 10. Dependency Management & Coupling

```markdown
### Dependency Architecture

**Dependency Inversion Principle:**
- Components depend on abstractions (interfaces, types)
- Not on concrete implementations
- Example: `useAuth()` hook instead of direct `AuthService` import

**Import Organization:**
```
// 1. External dependencies
import React from 'react';
import { useState } from 'react';

// 2. Internal absolute imports
import { Button } from '@/components/Button';
import { useAuth } from '@/hooks/useAuth';

// 3. Relative imports
import { utils } from './utils';
import type { User } from './types';

// 4. Types (always last)
import type { ComponentProps } from 'react';
```

**Barrel Exports Pattern:**
```
components/
├── ui/
│   ├── Button.tsx
│   ├── Card.tsx
│   └── index.ts        # Barrel export
└── index.ts            # Main barrel export
```

**Circular Dependency Prevention:**
- Use barrel exports carefully
- Extract shared types to separate files
- Use dependency injection for services
- Avoid mutual imports between components

**Coupling Metrics:**
- **Afferent Coupling (Ca)**: How many modules depend on this module
- **Efferent Coupling (Ce)**: How many modules this module depends on
- **Instability (I)**: Ce / (Ca + Ce) — higher = more unstable
- Target: Low coupling, high cohesion

**Barrel Exports Guidelines (Optional):**
- **When to use**: Public API for component libraries, feature modules
- **When to avoid**: Deep barrel exports (barrel exporting barrels), circular dependencies
- **Pros**: Clean imports, easier refactoring, clear public API
- **Cons**: Can cause circular dependencies, harder tree-shaking, slower IDE autocomplete
- **Best practice**: Use for feature boundaries, avoid for utility modules
- **Dependency graph tools**: Use `madge` or `dependency-cruiser` to visualize dependencies
```

### 11. API & Data Layer Architecture

```markdown
### API Architecture

**API Client Organization:**
```
lib/
├── api/
│   ├── client.ts          # Base API client (fetch wrapper)
│   ├── endpoints/
│   │   ├── users.ts      # User endpoints
│   │   ├── products.ts   # Product endpoints
│   │   └── orders.ts     # Order endpoints
│   ├── types.ts          # API response types
│   └── interceptors.ts   # Request/response interceptors
```

**Data Fetching Patterns:**

| Pattern | Library | When to Use |
|---------|---------|-------------|
| **React Query** | @tanstack/react-query | Complex caching, background updates |
| **SWR** | swr | Simple caching, real-time updates |
| **Custom Hooks** | None | Simple cases, full control |
| **Server Components** | Next.js | Server-side data fetching |

**Cache Boundaries:**
- **Component-level**: Component-specific cache keys
- **Feature-level**: Feature-specific cache invalidation
- **Global**: Shared cache across features
- **Time-based**: TTL for stale data

**Data Transformation Layers:**
- **Normalization**: Convert API responses to normalized state
- **Denormalization**: Convert normalized state to display format
- **Validation**: Runtime validation (Zod, Yup)
- **Type Guards**: TypeScript type narrowing

**API Interceptors & Middleware (Optional):**
- **Request interceptors**: Add auth tokens, set headers, log requests
- **Response interceptors**: Handle errors globally, transform responses, refresh tokens
- **Error handling**: Centralized error handling for API failures
- **Retry logic**: Automatic retry for failed requests (with exponential backoff)
- **Request cancellation**: Cancel in-flight requests when component unmounts
- **Example structure**:
  ```
  lib/api/client.ts
  ├── requestInterceptor: Add auth token
  ├── responseInterceptor: Handle errors
  └── errorHandler: Centralized error processing
  ```
```

### 12. Performance Architecture Patterns

```markdown
### Performance Architecture

**Code Splitting Strategy:**
```
Route-based splitting:
├── app/
│   ├── page.tsx          # Main bundle
│   ├── about/
│   │   └── page.tsx      # Separate chunk
│   └── dashboard/
│       └── page.tsx      # Separate chunk

Component-based splitting:
├── components/
│   ├── HeavyChart.tsx    # Dynamic import
│   └── LightButton.tsx   # In main bundle
```

**Memoization Decision Tree:**
```
Expensive computation?
├─→ Yes → useMemo (expensive calculation)
└─→ No → Skip memoization

Function passed as prop?
├─→ Yes → useCallback (prevent re-renders)
└─→ No → Skip memoization

Component re-renders unnecessarily?
├─→ Yes → React.memo (prevent re-renders)
└─→ No → Skip memoization
```

**Performance Patterns:**

| Pattern | When to Use | Implementation |
|---------|-------------|----------------|
| **Lazy Loading** | Heavy components, routes | `React.lazy()`, `dynamic()` |
| **Virtualization** | Long lists (>100 items) | `react-window`, `react-virtualized` |
| **Debouncing** | Search inputs, resize handlers | `useDebounce` hook |
| **Throttling** | Scroll handlers, mouse move | `useThrottle` hook |
| **Code Splitting** | Large bundles, routes | Dynamic imports |

**Bundle Size Management:**
- Tree shaking: Use ES modules, avoid default exports for utilities
- Dynamic imports: Load heavy libraries on demand
- Bundle analysis: Use `@next/bundle-analyzer`
- Performance budgets: Set max bundle sizes

**React Suspense & Loading States (Optional):**
- **Suspense boundaries**: Wrap lazy-loaded components and data-fetching components
- **Placement**: Place at route boundaries, feature boundaries
- **Fallback UI**: Provide meaningful loading states (skeletons, spinners)
- **Error boundaries**: Combine with error boundaries for complete error handling
- **Example**:
  ```tsx
  <Suspense fallback={<Skeleton />}>
    <LazyComponent />
  </Suspense>
  ```

**Performance Monitoring (Optional):**
- **Web Vitals**: Track LCP, FID, CLS (Core Web Vitals)
- **Bundle analysis**: Regular bundle size audits
- **Performance budgets**: Set limits for bundle size, API response time
- **Monitoring tools**: Lighthouse CI, WebPageTest, custom performance metrics
- **Performance regression detection**: Track metrics over time, alert on degradation
```

---

## Quick Usage

### Full Architecture Documentation
```
Document the component architecture of this project following the Re-Architecture template
```

### After Component Splitting
```
Update ARCHITECTURE.md to reflect the component splitting we just did:
- Split [Component] into [New Components]
- Document the new component boundaries
- Update bounded contexts
```

### Establish New Architecture
```
Establish component architecture for this project:
- Analyze current structure
- Define component boundaries
- Document bounded contexts
- Create architecture documentation
```

---

## Component Size Guidelines

| Size | Action |
|------|--------|
| **< 200 lines** | ✅ Good size, maintainable |
| **200-500 lines** | ⚠️ Consider splitting if complex |
| **> 500 lines** | 🔴 Should be split into smaller components |

**Signs a component needs splitting:**
- Multiple responsibilities
- Complex state management
- Multiple API calls
- Deeply nested JSX
- Hard to test
- Hard to understand at a glance

---

## Component Categorization Guide

### Feature Components (Domain-Specific)
- Own domain state
- Make API calls related to their domain
- Contain business logic
- Examples: `UserProfile`, `ShoppingCart`, `BankOverview`

### UI Components (Reusable)
- Pure presentation
- Receive data via props
- Emit events via callbacks
- No domain logic
- Examples: `Button`, `Card`, `Modal`, `Input`

### Infrastructure Components
- Cross-cutting concerns
- App-wide functionality
- Examples: `ErrorBoundary`, `AuthProvider`, `ThemeProvider`

---

## Bounded Context Identification

**How to identify bounded contexts:**

1. **Group by Domain**: What business domain does this serve?
   - User management
   - E-commerce
   - Content management
   - Analytics

2. **Group by Data**: What data does this component manage?
   - User data
   - Product data
   - Order data

3. **Group by Workflow**: What user workflow does this support?
   - Authentication flow
   - Checkout flow
   - Content creation flow

4. **Group by API**: What API endpoints does this use?
   - `/api/users/*`
   - `/api/products/*`
   - `/api/orders/*`

**Each bounded context should:**
- Have clear boundaries (start → end)
- Own its domain state
- Have minimal coupling to other contexts
- Be independently testable

---

## Extension Points

```markdown
## Extension Points

1. **New Components** — Add to `src/components/` following existing patterns
2. **New Hooks** — Add to `src/hooks/` for reusable logic
3. **New Utilities** — Add to `src/lib/utils.ts` or create new utility modules
4. **New Bounded Contexts** — Create new feature component group with clear boundaries
5. **New API Routes** — Add to `src/app/api/` (or `pages/api/`)
```

---

## Example: Before & After Component Splitting

### Before (Monolithic)
```
src/app/page.tsx (1,661 lines)
├── State management
├── API calls
├── All UI components inline
└── All business logic
```

### After (Separated)
```
src/app/page.tsx (433 lines)
├── State management
├── API calls
└── Component composition

src/components/
├── Feature Components (domain state)
├── UI Components (presentation)
└── Infrastructure Components
```

**Benefits:**
- ✅ 74% reduction in main file size
- ✅ Clear separation of concerns
- ✅ Reusable components
- ✅ Easier to test
- ✅ Easier to maintain

---

## Checklist

Before marking architecture documentation complete:

- [ ] Directory structure documented
- [ ] Component boundaries defined (Feature/UI/Infrastructure)
- [ ] Data flow diagram created
- [ ] Component responsibilities table filled
- [ ] Bounded contexts identified (3-7 contexts typical)
- [ ] Design principles listed
- [ ] **State management strategy** documented (local vs global)
- [ ] **Error handling boundaries** defined (component → page → app)
- [ ] **Dependency management** patterns documented
- [ ] **API layer architecture** documented (client, endpoints, caching)
- [ ] **Performance patterns** documented (code splitting, memoization)
- [ ] Extension points documented
- [ ] Large components (>500 lines) identified for future splitting
- [ ] Architecture diagram added to ARCHITECTURE.md

---

**Last Updated:** 2025-01-30

**Related Documents:**
- `Debug.md` — Find bugs and issues (diagnostic)
- `ARCHITECTURE.md` — Full architecture documentation (project-specific)

---

## Additional Architecture Patterns (Reference)

### Type Safety & Type Boundaries
- **Type boundaries**: Shared types (`lib/types.ts`), domain types (feature-specific), API types (`lib/api/types.ts`)
- **Type guards**: Runtime validation with TypeScript narrowing
- **Generic components**: Reusable components with type parameters
- **API contract types**: Zod schemas for runtime validation + TypeScript types

### Testing Architecture
- **Testing boundaries**: Unit (components), Integration (features), E2E (user flows)
- **Test organization**: Co-located tests (`Component.test.tsx`) vs separate `__tests__/` folder
- **Mock boundaries**: Mock external dependencies, test internal logic
- **Test utilities**: Shared test helpers, factories, fixtures

### Code Organization Patterns
- **File naming**: `PascalCase.tsx` for components, `camelCase.ts` for utilities
- **Directory organization**: Feature-based (`components/UserProfile/`) vs type-based (`components/ui/`)
- **Import aliases**: `@/components`, `@/lib`, `@/hooks` for clean imports
- **Barrel exports**: `index.ts` for public API, avoid deep barrel exports

### Form Architecture Patterns
- **Form state**: Controlled (React state) vs Uncontrolled (refs) vs Form libraries (React Hook Form)
- **Validation layers**: Client-side (immediate feedback) + Server-side (security)
- **Form submission**: Optimistic updates, error handling, loading states
- **Multi-step forms**: State management, navigation, validation per step

### Route & Navigation Architecture
- **Route organization**: File-based routing (Next.js App Router)
- **Route guards**: Protected routes, authentication checks
- **Navigation state**: URL state vs component state
- **Deep linking**: Preserve state in URL, handle browser back/forward

