# Service KB Template

Defines the canonical information architecture for PM/business-centric knowledge bases. Provides the reusable 7-file (or 8-file for MCP) structure, standard front matter, provenance blocks, and section outlines for documenting any system — backend services, frontend applications, or MCP servers. Use as the reference architecture when creating or auditing a KB. Triggers on "KB template", "knowledge base structure", "KB architecture", "service documentation template".

## KB File Structure

Every system KB has 7 core Markdown files in a single `<KB_FOLDER>`:

| File | Purpose |
|------|---------|
| `00_Service_Overview.md` | What the system is and why it exists |
| `01_Configuration_Reference.md` | Business & ops levers (what can be configured) |
| `02_Entity_Reference.md` | Domain model / entities in business terms |
| `03_Integration_Patterns.md` | How the system interacts with others |
| `04_Operational_Runbooks.md` | Operational procedures and on-call runbooks |
| `05_Data_Dictionary.md` | Data contracts: DB schema, API payloads, events |
| `README.md` | Entry point, navigation, KB change history |

**MCP Servers:** Add `06_Tool_Manifest.md` (tool catalog with schemas).
**Frontend Apps:** Optionally add `06_User_Flows.md`; rename files per frontend conventions.

## Standard Front Matter

Every doc starts with:

```markdown
## <DOCUMENT_TITLE>

**Version:** vX.Y (YYYY-MM-DD)
**Purpose:** <1-2 sentence summary>
**Audience:** <Primary roles>
**Service:** <SYSTEM_NAME>
```

## Provenance & Freshness Block

Each doc (00-05) ends with:

```markdown
## Provenance & Freshness

**Last Updated:** YYYY-MM-DD
**Next Review:** YYYY-MM-DD
**Codebase Version:** [Git commit SHA or tag]
**Source Repositories:**
- [repo-1]: [commit SHA, date]

**Major Changes This Update:**
- [3-5 key changes]

**Known Gaps:**
- [Areas needing validation]

**Contributors:** [Names]
**Maintainer:** [Owning team]
**Feedback:** [Slack channel]
```

## File-by-File Outline

### 00_Service_Overview.md
1. Executive Summary — what it does, core capabilities, primary personas
2. Service Architecture Overview — diagram, major components
3. Business Purpose & Value — JTBD, key metrics
4. Core Capabilities — table: Capability | Description | PM Use Cases
5. Key Business Entities (Overview) — brief definitions, link to 02
6. Integration Summary — table of upstream/downstream, link to 03
7. Documentation Map — when to use each doc
8. Risks & Limitations (optional)
9. Provenance & Freshness

### 01_Configuration_Reference.md
1. Executive Summary — config types, who owns changes
2. Onboarding & Identity Configuration
3. Rate Limiting / Fair Use / Throttling
4. Quota / Plan / Pricing Levers
5. Feature Flags & Rollout Controls
6. Integration & Connector Configuration
7. Monitoring & Alert Thresholds
8. Quick Reference Tables — config key → meaning → values → owner
9. Provenance & Freshness

### 02_Entity_Reference.md
1. Executive Summary — entity types
2. Entity Importance Levels — CRITICAL / IMPORTANT / TECHNICAL
3. Core Business Entities (per entity: What, Business Definition, Why PM Needs to Know, Key Attributes table, Lifecycle, Related Entities)
4. Operational / Supporting Entities
5. Technical Entities (optional)
6. Cross-Entity Relationships — diagrams/tables
7. Provenance & Freshness

### 03_Integration_Patterns.md
1. Executive Summary — key partners, communication styles
2. Context Diagram — component/system diagram
3. Inter-Service Communication — per integration: Purpose, APIs, Triggers, Data Flow
4. Client Integration Patterns — auth, rate limits, errors
5. Event-Driven Patterns — topics, schemas, idempotency
6. Data Consistency & Resilience
7. Provenance & Freshness

### 04_Operational_Runbooks.md
1. Executive Summary
2. Common Operational Tasks — health checks, scaling, log inspection
3. Monitoring & Alerting — dashboards, SLIs/SLOs
4. Incident Response — per incident type: Symptoms → Triage → Diagnostics → Mitigations → Escalation
5. Troubleshooting Guides
6. Deployment & Change Management
7. Security & Compliance Operations
8. Disaster Recovery & Capacity Planning (optional)
9. Provenance & Freshness

### 05_Data_Dictionary.md
1. Executive Summary — data stores, critical tables
2. Schema Conventions — naming, PK strategy, audit fields
3. Core Tables — per table: Purpose, Schema table, Relationships, Sample Data
4. Supporting Tables
5. API Data Contracts — field-level descriptions, link to OpenAPI
6. Event Schemas — event types, field tables, topics
7. Data Retention & Governance
8. Provenance & Freshness

### README.md
1. System Overview — short description + link to 00
2. Metadata & Status — version, owner
3. Documentation Navigator — table: Document | When to Use | Audience | Reading Time
4. KB Change Snapshot — what changed this run
5. Usage Guides by Scenario (optional) — "When planning features...", "When handling escalation..."
6. KB History — reverse-chronological versions

## Frontend Adaptations

For detailed frontend-specific file adaptations, see [FILE_STRUCTURES.md](references/FILE_STRUCTURES.md).

| Standard Name | Frontend Adaptation |
|---------------|---------------------|
| `00_Service_Overview.md` | `00_App_Overview.md` |
| `02_Entity_Reference.md` | `02_Component_Reference.md` |
| `05_Data_Dictionary.md` | `05_State_Dictionary.md` |

## Role Layering

- **PM/Business:** Focus on README, 00, and "What/Why" sections of 01/02
- **Engineers:** Deep sections in 00, 03, 05; for MCP: 06_Tool_Manifest
- **SRE/Ops:** Primary: 04 (runbooks); cross-reference 01 (config), 05 (data)

## Related Skills

| Skill | Purpose |
|-------|---------|
| `kb-runner` | Create/refresh KB content using this template |
| `kb-drift-report` | Audit KB against this template |
