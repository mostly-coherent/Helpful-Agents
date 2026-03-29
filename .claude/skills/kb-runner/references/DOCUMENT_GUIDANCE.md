# KB Runner — Document-Specific Guidance

Detailed per-file section outlines for each system type (Backend Service, Frontend App, MCP Server).

---

## 00_Service_Overview.md / 00_App_Overview.md

**Goal:** Explain what the system does and why it matters.

### Backend Services
- Architecture diagram, core capabilities, key entities, integration summary

### Frontend Apps

```
## 1. Executive Summary
## 2. User Value & Personas
## 3. Application Architecture
## 4. Technology Stack
## 5. Page Structure Overview
## 6. Key User Flows (Summary)
## 7. Backend Dependencies
## 8. Documentation Map
## Provenance & Freshness
```

---

## 01_Configuration_Reference.md

**Goal:** Document configuration options.

### Backend Services
- Environment variables, feature flags, rate limits, thresholds

### Frontend Apps

```
## 1. Executive Summary
## 2. Build-Time Configuration
## 3. Runtime Configuration
## 4. Feature Flags
## 5. Analytics & Tracking
## 6. Localization (i18n)
## 7. Theming & Styling
## 8. Third-Party Integrations
## Provenance & Freshness
```

---

## 02_Entity_Reference.md / 02_Component_Reference.md

**Goal:** Document the main building blocks.

### Backend Services
- Database entities, domain objects, business logic containers

### Frontend Apps

```
## 1. Executive Summary
## 2. Component Categories
## 3. Core Components (Must Know)
   - Layout, Form, Navigation components
## 4. Feature Components (By Domain)
   - Checkout, Payment, User components
## 5. Shared Utilities
   - Hooks, HOCs, Context providers
## 6. Styling Patterns
## Provenance & Freshness
```

---

## 03_Integration_Patterns.md

**Goal:** Document system integrations.

### Backend Services
- REST/GraphQL APIs, event-driven, database connections

### Frontend Apps

```
## 1. Executive Summary
## 2. GraphQL Integration
   - Client config, key queries/mutations, caching, error handling
## 3. Authentication (IMS)
## 4. Analytics & Tracking
   - Tag management / analytics tooling, CDPs, custom events
## 5. Third-Party Integrations
   - Payment providers, Chat, Content (AEM)
## 6. State Management
   - Redux store structure, key actions/selectors
## 7. Parent/Child Communication (Iframes)
## Provenance & Freshness
```

---

## 04_Operational_Runbooks.md

**Goal:** Document operational procedures.

### Backend Services
- Health checks, incident response, deployment procedures

### Frontend Apps

```
## 1. Executive Summary
## 2. Development Setup
   - Prerequisites, environment, running locally
## 3. Build & Deployment
   - Commands, pipeline, environment promotion
## 4. Debugging & Troubleshooting
   - Common issues, browser tools, GraphQL debugging
## 5. Performance Monitoring
   - Key metrics, performance budgets
## 6. Error Tracking
## 7. A/B Testing & Feature Flags
## Provenance & Freshness
```

---

## 05_Data_Dictionary.md / 05_State_Dictionary.md

**Goal:** Document data structures.

### Backend Services
- Database schemas, API request/response shapes, event schemas

### Frontend Apps

```
## 1. Executive Summary
## 2. Redux State Structure
   - Store slices, key state shapes
## 3. GraphQL Types (Client-Side)
   - Query response types, mutation inputs, fragments
## 4. Component Interfaces
   - Key prop types, shared interfaces
## 5. Form Data Structures
## 6. Client-Side Storage
   - LocalStorage, SessionStorage, Cookies
## Provenance & Freshness
```

---

## 06_Tool_Manifest.md (MCP Servers Only)

**Goal:** Catalog all exposed MCP tools.

```
## 1. Executive Summary
## 2. Tool Response Schema (Common)
## 3. Tool Categories
   - Per category: tool name, purpose, request/response schema, downstream integrations, use cases
## 4. Tool Discovery & Registration
## 5. Authentication & Authorization
## 6. Tool Usage Patterns
## Provenance & Freshness
```

---

## 06_User_Flows.md (Frontend Apps, Optional)

**Goal:** Document key user journeys for complex apps.

```
## 1. Executive Summary
## 2. Primary User Flows
   - New Purchase, Trial Conversion, Payment Update, Cancel/Pause
## 3. Secondary Flows
   - Plan Change, Team Upgrade, Error Recovery
## 4. Flow Diagrams
## 5. Edge Cases & Error Handling
## Provenance & Freshness
```

---

## Frontend App Detection Checklist

| Indicator | Check |
|-----------|-------|
| `package.json` has `react` or `next` | Yes/No |
| `src/pages/` or `src/app/` directories | Yes/No |
| `.tsx` or `.jsx` component files | Yes/No |
| Redux/Zustand store configuration | Yes/No |
| Apollo Client or GraphQL client setup | Yes/No |
| CSS/PostCSS/Tailwind configuration | Yes/No |

## Terminology Mapping

| Backend Term | Frontend Equivalent |
|-------------|---------------------|
| Entity | Component / State Slice |
| API Endpoint | Page / Route |
| Service | Hook / Utility |
| Database Schema | Redux State Shape |
| Middleware | HOC / Context Provider |
| Controller | Page Component |
| Business Logic | Custom Hook |
