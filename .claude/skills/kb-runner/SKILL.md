# KB Runner

Operates a recurring, PM-focused knowledge base refresh loop for any system — backend services, frontend applications, or MCP servers. Uses designated repositories as the single source of truth to create and maintain a 7-file (or 8-file for MCP) KB in Markdown. Use when creating a new KB, refreshing an existing KB, onboarding a new system, or running a monthly KB update. Triggers on "KB runner", "knowledge base", "refresh KB", "create KB", "update KB", "system documentation".

## Inputs

1. `<SYSTEM_NAME>` — human-readable name
2. `<KB_FOLDER>` — path for the KB folder
3. `<SYSTEM_TYPE>` — Backend Service | Frontend App | MCP Server
4. `<SOURCE_REPOS>` — repositories as source of truth

## System Type Detection

| Type | Indicators | Document Focus |
|------|-----------|----------------|
| **Backend Service** | REST/GraphQL APIs, databases, microservice | APIs, entities, integrations, schemas |
| **Frontend App** | React/Next.js, components, state management | User flows, components, pages, client integrations |
| **MCP Server** | Model Context Protocol tools, Python/Node handlers | Tool catalog, schemas, downstream integrations |

## KB File Structure

All systems maintain 7 core Markdown files:

| File | Purpose |
|------|---------|
| `00_Service_Overview.md` / `00_App_Overview.md` | What the system does, why it matters |
| `01_Configuration_Reference.md` | Business & ops configuration levers |
| `02_Entity_Reference.md` / `02_Component_Reference.md` | Domain model / entities or React components |
| `03_Integration_Patterns.md` | How system integrates with others |
| `04_Operational_Runbooks.md` | Operational procedures, debugging |
| `05_Data_Dictionary.md` / `05_State_Dictionary.md` | DB schema, API payloads, or Redux state |
| `README.md` | Entry point, navigation, change history |

**Additional:** MCP Servers add `06_Tool_Manifest.md`; Frontend Apps optionally add `06_User_Flows.md`.

## High-Level Workflow

1. **Sync & Diff** — Pull latest code, identify changes since last run
2. **Document Update Loop** — Update each doc per system-type guidance
3. **README Refresh** — Update navigation and KB Change Snapshot
4. **Validation & Quality Gates** — Verify accuracy, completeness, consistency, usability
5. **Delivery** — Commit and communicate

## Sync & Diff

Pull latest repos, then build the delta:
- **Backend:** Config changes, schema migrations, API endpoints, integrations
- **Frontend:** Pages/routes, components, state management, GraphQL, styling, feature flags
- **MCP:** New/changed tools, schemas, downstream integrations

## Validation Gates

- [ ] Config keys match latest configs
- [ ] Integrations match code and infra
- [ ] **Backend:** API endpoints match controllers/OpenAPI; schema matches migrations
- [ ] **Frontend:** Pages match routes; components match implementation; state shape matches store
- [ ] All required files exist with README having KB Change Snapshot
- [ ] Terminology consistent across docs
- [ ] PMs can skim and understand; examples are realistic

## Document-Specific Guidance

For detailed per-file section outlines (what to put in each doc, by system type), see [DOCUMENT_GUIDANCE.md](references/DOCUMENT_GUIDANCE.md).

## Provenance Block

Every doc (00-05) ends with:
- Last Updated, Next Review, Codebase Version
- Source Repositories (with commit SHAs)
- Major Changes This Update (3-5 items)
- Known Gaps, Contributors, Maintainer, Feedback channel

## Related Skills

| Skill | Purpose |
|-------|---------|
| `service-kb-template` | Canonical KB information architecture |
| `kb-drift-report` | Audit existing KB against template |
