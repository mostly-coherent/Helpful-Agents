---
description: Generates start/stop/check scripts for multi-service projects. Use when user says "generate server scripts", "start stop scripts", or needs server management scripts for a project.
---

# Generate Server Scripts

Creates start-servers.sh, stop-servers.sh, and check-servers.sh for a project.

## When to Use

- Multi-service project (frontend + backend + DB)
- Need unified start/stop/check scripts

## Instructions

1. **Analyze project** — Detect frontend (package.json, React/Vite/Next), backend (Python/Node), database, .env
2. **Determine config** — Ports, commands, process names
3. **Generate scripts** — start-servers.sh, stop-servers.sh, check-servers.sh
4. **Output** — Scripts in project root; report configuration found

See [REFERENCE.md](references/REFERENCE.md) for detection logic and script templates.
