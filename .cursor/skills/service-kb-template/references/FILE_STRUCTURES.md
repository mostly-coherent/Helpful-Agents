# Service KB Template — Frontend Application Adaptations

Detailed section outlines for documenting Frontend Applications using the KB structure.

---

## 00_App_Overview.md (Frontend)

```markdown
## 1. Executive Summary
## 2. User Value & Personas
## 3. Application Architecture
   - High-level component diagram
   - Page/route structure
   - State management approach
## 4. Technology Stack
   - Framework, state management, styling, GraphQL client
## 5. Page Structure Overview
   - Table of pages/routes with purpose
## 6. Key User Flows (Summary)
## 7. Backend Dependencies
   - GraphQL APIs consumed, auth providers
## 8. Documentation Map
## Provenance & Freshness
```

---

## 02_Component_Reference.md (Frontend)

```markdown
## 1. Executive Summary
## 2. Component Importance Levels
   - CRITICAL / IMPORTANT / SUPPORTING
## 3. Core Components (Must Know)
   - Layout components (Header, Footer, Layouts)
   - Form components (inputs, validation)
   - Navigation components
## 4. Feature Components (By Domain)
   - Checkout, Payment, Cart, User/account
## 5. Shared Utilities
   - Custom hooks (signatures and purpose)
   - Higher-Order Components
   - Context providers
## 6. Styling Patterns
   - CSS module conventions, design system, responsive patterns
## Provenance & Freshness
```

---

## 05_State_Dictionary.md (Frontend)

```markdown
## 1. Executive Summary
## 2. Redux Store Structure
   - Store slices with purpose
   - Key state shapes
## 3. GraphQL Types (Client-Side)
   - Query response types
   - Mutation input types
   - Fragment definitions
## 4. Component Interfaces
   - Key prop type definitions
   - Shared interfaces
## 5. Form Data Structures
   - Form state shapes, validation schemas
## 6. Client-Side Storage
   - LocalStorage keys and purpose
   - SessionStorage usage
   - Cookie definitions
## Provenance & Freshness
```

---

## 06_User_Flows.md (Frontend, Optional)

**Create when:** App has complex multi-step user journeys.

```markdown
## 1. Executive Summary
## 2. Primary User Flows
   - New Purchase Flow
   - Trial Conversion Flow
   - Payment Update Flow
   - Cancel/Pause Flow
## 3. Secondary Flows
   - Plan Change, Team Upgrade, Error Recovery
## 4. Flow Diagrams
## 5. Edge Cases & Error Handling
## Provenance & Freshness
```

---

## 06_Tool_Manifest.md (MCP Servers)

```markdown
## 1. Executive Summary
   - Tooling capabilities, categories, counts
## 2. Tool Response Schema (Common)
   - Standard response structure, error handling
## 3. Tool Categories
   - Per category, per tool:
     - Name, purpose
     - Request schema (fields, types, required/optional)
     - Response schema
     - Downstream integrations
     - Use cases
     - Error handling
## 4. Tool Discovery & Registration
## 5. Authentication & Authorization
## 6. Tool Usage Patterns
   - Common workflows, best practices, example sequences
## Provenance & Freshness
```

**Key principles:**
- Document every exposed tool (completeness critical for MCP clients)
- Include field-level request/response schemas
- Link tools to `03_Integration_Patterns.md` for downstream integrations
- Focus on "what it does" and "when to use it"
- Mark deprecated tools: ⚠️ **DEPRECATED**
