# Auto-Generate Server Management Scripts

**INSTRUCTIONS:** In Cursor, type `@generate-server-scripts.md @[your-project-folder]`

---

## Your Task:

I need you to create 3 server management scripts for the attached project folder:

1. **start-servers.sh** - Start all servers
2. **stop-servers.sh** - Stop all servers  
3. **check-servers.sh** - Check server health

## Step 1: Analyze the Project

**Please automatically detect:**

### Frontend Detection:
- Check for `package.json` in root or `/frontend` or `/client`
- Look for these fields:
  - `"scripts": { "dev": ..., "start": ..., "build": ... }`
  - Dependencies: react, vue, angular, next, vite, webpack, etc.
- Identify the dev command (usually `npm run dev` or `npm start`)
- Find the port (check vite.config, next.config, .env, or use defaults)
- Determine the process name to monitor (vite, next, webpack, ng serve, etc.)

### Backend Detection:
- Check for backend files:
  - Python: `app.py`, `manage.py`, `main.py`, `requirements.txt`
  - Node.js: `server.js`, `index.js`, `app.js` in `/backend` or `/server`
  - Check for frameworks: Flask, Django, FastAPI, Express, NestJS, etc.
- Check for virtual environment: `venv/`, `.venv/`, `env/`
- Find the start command
- Find the port (check code, .env, or use defaults)
- Determine the process name to monitor

### Database Detection:
- Check for database configs:
  - PostgreSQL: Look for `pg`, `psycopg2`, connection strings
  - MongoDB: Look for `mongoose`, `pymongo`
  - Redis: Look for `redis` in dependencies
  - SQLite: Check for `.db` files or `sqlite3`
- Determine if it needs to be started/stopped

### Environment Files:
- Check for `.env`, `.env.example`, `.env.local`
- Note the location
- Check for required variables (API keys, DB URLs, etc.)

### Project Structure:
- Is it monorepo (frontend + backend in one folder)?
- Separate folders for frontend/backend?
- Root-level or nested?

## Step 2: Determine Configuration

Based on your analysis, tell me what you found:

```
PROJECT ANALYSIS:
=================
Project Name: [detected from folder name]
Project Path: [full path]

FRONTEND:
- Technology: [React + Vite / Next.js / None / etc.]
- Location: [./ or ./frontend or ./client]
- Start Command: [npm run dev / npm start]
- Port: [5173 / 3000 / detected port]
- Process to Monitor: [vite / next / webpack]

BACKEND:
- Technology: [Flask / Express / Django / None / etc.]
- Location: [./backend / ./server / ./api]
- Start Command: [python app.py / node server.js]
- Virtual Environment: [venv / .venv / None]
- Port: [5000 / 3001 / detected port]
- Process to Monitor: [app.py / server.js]

DATABASE:
- Type: [PostgreSQL / MongoDB / None / etc.]
- Needs Management: [Yes / No]

ENVIRONMENT:
- .env Location: [./backend/.env / ./.env]
- Key Variables: [list critical ones like API keys]
```

## Step 3: Generate the Scripts

Create **start-servers.sh** with:
- Check if .env exists and has real values (not placeholders)
- Check if dependencies are installed (node_modules, venv)
- Check if ports are already in use
- Start backend first (if exists), wait for it to be ready
- Start frontend (if exists), wait for it to be ready
- Start database (if needed)
- Run health checks
- Show access URLs
- Create log files (frontend.log, backend.log)
- Handle all errors gracefully

Create **stop-servers.sh** with:
- Find all related processes
- Try graceful shutdown (SIGTERM) first
- Wait 5 seconds
- Force kill (SIGKILL) if still running
- Verify all stopped
- Clean up log files
- Show what was stopped

Create **check-servers.sh** with:
- Test if each port responds
- Check if processes are running
- Show PIDs
- Color-coded status (✅/❌)
- Return proper exit codes

## Requirements:

✅ Bash scripts with `#!/bin/bash`
✅ Error handling for common issues
✅ Clear status messages with emojis
✅ Absolute paths (use the detected project path)
✅ Cross-platform (macOS/Linux)
✅ Executable permissions mentioned
✅ Comments explaining each section

## Output Format:

1. Show me the analysis (Step 2)
2. Provide complete script contents for all 3 files
3. Tell me where to save them (in the project root)
4. Provide the commands to make them executable
5. Explain any assumptions or special considerations

---

**NOTE:** If you can't determine something with confidence, make a reasonable assumption based on common conventions and note it in your analysis and explicitly ask for my feedback.

