# Server Script Generator

> Auto-generate `start-servers.sh`, `stop-servers.sh`, and `check-servers.sh` for ANY multi-service project. One command startup, graceful shutdown, health checks—no more port conflicts or "which service starts first?" confusion.

![Type](https://img.shields.io/badge/Type-AI%20Agent-purple)
![Status](https://img.shields.io/badge/Status-Active-green)
![Stack](https://img.shields.io/badge/Stack-Cursor%20%7C%20Bash-blue)

## 🚀 Quick Start

**This is a Cursor agent—use it with `@` syntax:**

```bash
# In Cursor chat, reference the agent file directly:
@Generate-server-scripts.md @your-project-folder
```

**That's it.** Cursor loads the agent, analyzes your project, and generates three ready-to-use scripts.

### Example

```bash
@Generate-server-scripts.md @valetudo-ai
```

**What you get:**
- `start-servers.sh` — Auto-detects and starts all services (frontend, backend, database) in correct order
- `stop-servers.sh` — Gracefully stops everything, force-kills if needed
- `check-servers.sh` — Health check with port status, PIDs, and color-coded output

**Then use them:**
```bash
chmod +x start-servers.sh stop-servers.sh check-servers.sh
./start-servers.sh    # Start everything
./check-servers.sh    # Check status
./stop-servers.sh     # Stop everything
```

---

<details>
<summary>💡 Why This Actually Helps</summary>

### The Real Problem

You're switching between 4 projects. Each has frontend + backend + database. You can't remember:
- Which ports each one uses
- What the startup sequence is (database first? backend? does order matter?)
- Whether you already have something running (port conflicts mystery)
- How to check if everything's actually healthy
- Whether this project needs a virtualenv activated first

You waste **10-20 minutes every time you switch projects** just getting things running. Or you leave everything running all the time and your laptop sounds like a jet engine.

### When This Agent Is Genuinely Useful

**Use it when:**
- ✅ **Multi-service projects** — You need to start 3+ services in the right order
- ✅ **Context switching** — You're working on 2+ projects and switching between them daily
- ✅ **Cloned projects** — You forked/cloned something without clear startup docs
- ✅ **Team onboarding** — New teammate needs to get running quickly
- ✅ **After weeks away** — You return to a project and forgot the entire setup

**Real example:** You cloned an AI chat app. It has: React+Vite frontend (5173), Flask backend (5000), Postgres (5432), and Redis for caching (6379). The README says "run the frontend and backend" but doesn't mention you need Postgres running first or the backend crashes with cryptic connection errors. This agent detects all of that and generates scripts that start them in the right order with health checks.

### When This Is Overkill (Use Something Simpler)

**Skip this if:**
- ❌ **Single-service Next.js** — `npm run dev` is enough. Don't add complexity you don't need.
- ❌ **You have docker-compose** — Use that instead. It's more mature and handles networking better.
- ❌ **Mature startup scripts exist** — Don't replace working systems. If the project has good scripts, use them.
- ❌ **Solo simple projects** — Building a todo app with just frontend? You don't need this.

### The Honest Trade-off

**What you gain:**
- One-command startup across all your projects (`./start-servers.sh` becomes muscle memory)
- Consistent interface: every project has start/check/stop, same behavior
- Less mental overhead remembering project-specific quirks
- Forces your projects to have standard structure (ports in config, not hardcoded)

**What you give up:**
- Another abstraction layer to understand (the scripts themselves)
- Bash knowledge required to customize (though most people just generate and forget)
- If AI detects wrong ports/services, you need to fix the scripts manually

**My take:** If you're working on 1-2 simple projects, don't bother. If you're managing 4+ projects with multiple services each, this saves you hours per week and keeps you sane.

</details>

<details>
<summary>⚙️ How It Works</summary>

### The Agent Process

1. **You run:** `@Generate-server-scripts.md @your-project-folder`
2. **Agent analyzes:** Project structure, config files, dependencies
3. **Agent detects:**
   - Frontend (React/Vue/Next.js/etc) from `package.json`, `vite.config`, `next.config`
   - Backend (Flask/Django/Express/etc) from `app.py`, `server.js`, `requirements.txt`
   - Database (Postgres/Mongo/Redis/etc) from dependencies
   - Ports from config files or standard defaults
   - Virtual environments (`venv/`, `.venv/`)
   - Environment files (`.env`, `.env.local`)
4. **Agent generates:** Three executable Bash scripts with error handling, health checks, and clear status messages
5. **You save:** Copy the scripts to your project root, `chmod +x`, and use them

### What the Agent Looks At

```text
Your Project/
├── package.json              ← Dependencies, scripts, name
├── vite.config.js            ← Vite setup, port
├── next.config.js            ← Next.js setup
├── requirements.txt          ← Python deps
├── app.py / manage.py        ← Flask / Django entry
├── server.js                 ← Express entry
├── .env / .env.local         ← Environment variables
├── venv/ or .venv/           ← Virtual environment
└── node_modules/             ← Dependencies installed
```

### Detection Logic

- **Frontend:** Reads `package.json` + config files to infer React/Vite/Next/Vue/etc. Uses dev script (`npm run dev`, `npm start`) and detected/default port (5173, 3000, 8080).
- **Backend:** Looks for `app.py`, `manage.py`, `server.js`, `requirements.txt` or backend `package.json`. Infers Flask/Django/Express/FastAPI and appropriate start command and port (5000, 8000, 3000/3001). Detects virtualenvs and activates them.
- **Database:** Infers presence from deps (e.g., `psycopg2`, `mongoose`, `redis`). Uses standard ports (PostgreSQL 5432, MongoDB 27017, Redis 6379).
- **Environment:** Locates `.env`, `.env.local`, validates required env vars exist before starting.

</details>

<details>
<summary>🔄 Daily Workflow</summary>

### Morning Startup

```bash
cd ~/Projects/my-chat-app
./start-servers.sh
# ✅ PostgreSQL already running on 5432
# ✅ Backend started on 5000 (PID 12345)
# ✅ Frontend started on 5173 (PID 12346)
# → Frontend: http://localhost:5173
# → Backend: http://localhost:5000
```

### Switching Projects Mid-Day

```bash
cd ~/Projects/my-chat-app
./stop-servers.sh     # Stop current project

cd ~/Projects/another-app
./start-servers.sh    # Start different project
```

### Quick Health Check

```bash
./check-servers.sh
# ✅ Frontend (5173): Running (PID 12346)
# ✅ Backend (5000): Running (PID 12345)
# ✅ PostgreSQL (5432): Running
```

### With Logs (Debugging)

```bash
./start-servers.sh && tail -f *.log           # Watch all logs
./check-servers.sh && tail -n 50 backend.log  # Check backend logs
```

### End of Day

```bash
./stop-servers.sh     # Clean shutdown
# ✅ Frontend stopped
# ✅ Backend stopped
# ℹ️ PostgreSQL still running (shared across projects)
```

</details>

<details>
<summary>📋 Example Stacks</summary>

These examples show how the same agent adapts across different tech stacks.

### React + Flask (Valetudo AI)
- Frontend: React + Vite on port **5173**, command `npm run dev`, path `./`
- Backend: Flask on port **5000**, `python app.py`, path `./backend`, venv at `backend/venv/`
- Environment: `.env` at `backend/.env` with `PERPLEXITY_API_KEY`
- Scripts ensure venv is activated and `.env` exists before starting

### Next.js Full Stack
- Single Next.js app on port **3000**, `npm run dev`, path `./`
- Environment: `.env.local` with `DATABASE_URL`, `NEXTAUTH_SECRET`
- Scripts run in "single server mode" (combined frontend + backend)

### Django + React + PostgreSQL
- Backend: Django (`manage.py`) on **8000**, venv at `venv/`
- Frontend: React (Webpack) in `./frontend`, `npm start` on **3000**
- Database: PostgreSQL via `psycopg2`, port **5432**, typically started via `brew services`
- Scripts start PostgreSQL first, then Django (with venv), then React

### Express + Vue + MongoDB
- Frontend: Vue in `./client`, `npm run serve` on **8080**
- Backend: Express in `./server`, `node server.js` on **3001**
- Database: MongoDB with `mongoose`, `mongod --dbpath ./data/db` on **27017**
- Scripts coordinate MongoDB, then Express, then Vue, all with health checks

</details>

<details>
<summary>🛠️ Troubleshooting</summary>

### Common Issues

**Port already in use:**
```bash
lsof -i :5173                   # See what's using the port
lsof -ti :5173 | xargs kill -9  # Free it
```

**Can't connect to server:**
```bash
./check-servers.sh      # Is it running?
tail -f *.log           # Look for errors

# If needed, try manual start to debug:
cd backend && source venv/bin/activate && python app.py
npm run dev
```

**Virtualenv problems:**
```bash
rm -rf venv
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**Missing `.env`:**
```bash
ls -la .env backend/.env
cp .env.example .env
cp backend/.env.example backend/.env
```

**Dependencies not installed:**
```bash
npm install                       # Frontend
source venv/bin/activate
pip install -r requirements.txt   # Python backend
cd backend && npm install         # Node backend
```

### Emergency Commands

**Kill by process name:**
```bash
pkill -f vite                 # Kill Vite frontend
pkill -f "python app.py"      # Kill Flask backend
pkill -f "node server"        # Kill Node backend
pkill -f next                 # Kill Next.js
```

**Kill by port:**
```bash
lsof -ti :5173 | xargs kill -9    # Kill port 5173
lsof -ti :5000 | xargs kill -9    # Kill port 5000
lsof -ti :3000 | xargs kill -9    # Kill port 3000
```

**Nuclear option (common ports):**
```bash
for port in 3000 5000 5173 8000; do
    lsof -ti :$port | xargs kill -9 2>/dev/null
done
```

</details>

<details>
<summary>📚 Reference: Ports & Commands</summary>

### Common Ports by Technology

| Technology  | Default Port | Process Name     |
|-------------|-------------:|------------------|
| **Frontend** |              |                  |
| Vite (React)|         5173 | vite             |
| CRA (React) |         3000 | webpack          |
| Next.js     |         3000 | next             |
| Vue CLI     |         8080 | vue              |
| Angular     |         4200 | ng               |
| **Backend** |              |                  |
| Flask       |         5000 | app.py           |
| Django      |         8000 | manage.py        |
| Express     |     3000/3001| node server.js   |
| FastAPI     |         8000 | uvicorn          |
| Rails       |         3000 | rails            |
| **Database** |              |                  |
| PostgreSQL  |         5432 | postgres         |
| MongoDB     |        27017 | mongod           |
| Redis       |         6379 | redis-server     |
| MySQL       |         3306 | mysqld           |

### Bash Concepts You'll See

- **Process management:** `ps aux`, `ps aux | grep <name>`, `kill <PID>`, `kill -9 <PID>`, `pkill -f <pattern>`
- **Ports:** `lsof -i :<port>`, `lsof -ti :<port>`, `netstat -an | grep <port>`
- **Background jobs:** `command &`, `nohup command &`, `jobs`, `fg %1`, `bg %1`
- **Logs:** `tail -f file.log`, `tail -n 50 file.log`, `grep ERROR *.log`

</details>

<details>
<summary>🔧 Advanced Customization</summary>

### One-Time Setup for a New Project

```bash
git clone https://github.com/user/project
cd project

npm install                                  # Frontend deps
cd backend && pip install -r requirements.txt  # Backend deps

cp .env.example .env
cp backend/.env.example backend/.env

# In Cursor:
@Generate-server-scripts.md @project

chmod +x *.sh
./check-servers.sh
./start-servers.sh
```

### Advanced Things You Can Ask AI to Add

- **Extra services:** Redis (6379), Elasticsearch (9200), Docker containers, background workers (Celery, Sidekiq, etc.)
- **Pre-flight checks:** Node ≥ 18, Python ≥ 3.9, required env vars present, DB connection valid
- **Post-start actions:** run migrations, seed dev data, open browser to `http://localhost:XXXX`, tail logs for you

### Manual Template (For Non-Standard Setups)

If auto-detection isn't quite right, fill this in and send it to AI:

```text
Create 3 server management scripts (start, stop, check) for my project:

PROJECT: [Your Project Name]
LOCATION: [/absolute/path/to/project]

FRONTEND:
- Tech: [React+Vite / Next.js / Vue / Angular / etc]
- Path: [./ or ./frontend]
- Command: [npm run dev / npm start]
- Port: [5173 / 3000 / 8080]

BACKEND:
- Tech: [Flask / Express / Django / FastAPI / etc]
- Path: [./backend or ./api]
- Command: [python app.py / node server.js]
- Port: [5000 / 3001 / 8000]
- Virtualenv: [venv / .venv / None]

DATABASE (optional):
- Type: [PostgreSQL / MongoDB / Redis / None]
- Start command: [brew services start postgresql / mongod]
- Port: [5432 / 27017 / 6379]

ENVIRONMENT:
- .env location: [./backend/.env or ./.env]
- Required vars: [PERPLEXITY_API_KEY, DATABASE_URL, etc]

Requirements:
✅ Start in background, check if already running
✅ Stop gracefully (SIGTERM), force if needed (SIGKILL)
✅ Check health + show PIDs + verify .env exists
✅ Handle errors (missing .env, ports in use)
✅ Color-coded output with emojis
✅ Use absolute paths
```

</details>

---

**Last Updated:** 2025-01-30  
**Version:** v3.1  
**Agent File:** `Generate-server-scripts.md`
