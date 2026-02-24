#!/bin/bash

# Create a new project with canonical docs and optional Next.js AI scaffolding.
# Usage: ./create-project.sh my-project-name [--skip-github] [--basic] [--scaffold]
#
# Set GITHUB_USER for repo creation. Use --skip-github for non-interactive (e.g. agent) runs.

set -e

# Workspace root (where project will be created as subfolder)
WORKSPACE_ROOT="$(pwd)"

# Parse arguments
SKIP_GITHUB=false
BASIC_MODE=false
SCAFFOLD=false
PROJECT_NAME=""

for arg in "$@"; do
  case $arg in
    --skip-github)
      SKIP_GITHUB=true
      shift
      ;;
    --basic)
      BASIC_MODE=true
      shift
      ;;
    --scaffold)
      SCAFFOLD=true
      shift
      ;;
    *)
      PROJECT_NAME="$arg"
      shift
      ;;
  esac
done

if [ -z "$PROJECT_NAME" ]; then
  echo "Usage: ./create-project.sh <project-name> [--skip-github] [--basic] [--scaffold]"
  echo "Example: ./create-project.sh ai-chat-app"
  echo "Example: ./create-project.sh ai-chat-app --scaffold"
  echo ""
  echo "Options:"
  echo "  --skip-github    Skip GitHub repo creation (non-interactive)"
  echo "  --basic          Create basic web app (no AI/LLM scaffolding)"
  echo "  --scaffold       Create full Next.js AI app structure with:"
  echo "                   - Vercel AI SDK chat endpoint"
  echo "                   - Langfuse tracing"
  echo "                   - Prisma schema"
  echo "                   - Standard tool definitions"
  echo ""
  echo "Default: Creates AI-ready project with Vercel AI SDK patterns"
  exit 1
fi

# Validate project name
if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "❌ Invalid project name: '$PROJECT_NAME'"
  echo "   Project names must contain only letters, numbers, hyphens, and underscores"
  echo "   Good: ai-chat-app, my_project, Project123"
  echo "   Bad: my project, ai@chat, app!"
  exit 1
fi

PROJECT_DIR="$PROJECT_NAME"

# Check if project already exists
if [ -d "$PROJECT_DIR" ]; then
  echo "❌ Project '$PROJECT_NAME' already exists in this workspace"
  exit 1
fi

echo "🚀 Creating new project: $PROJECT_NAME"

# Create project directory
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Initialize Git
git init
git branch -M main
echo "✓ Git initialized (main branch)"

# Create basic README
if [ "$BASIC_MODE" = true ]; then
  cat > README.md << EOF
# $PROJECT_NAME

![Type](https://img.shields.io/badge/Type-Web%20App-blue)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow)
![Stack](https://img.shields.io/badge/Stack-Next.js%20%7C%20TypeScript%20%7C%20Tailwind-blue)

Short one- or two-sentence overview of what this project does, who it is for, and the main outcome it delivers.

## Features

- **Core value:** [What problem this solves]
- **Key workflow:** [Primary user flow or capability]
- **Integration:** [Important external APIs or services]

## Quick Start

\`\`\`bash
npm install
cp .env.example .env.local
npm run dev
\`\`\`

Open http://localhost:3000 in your browser.

## Environment Variables

- **\`NEXT_PUBLIC_SUPABASE_URL\`** – Supabase project URL
- **\`NEXT_PUBLIC_SUPABASE_ANON_KEY\`** – Supabase anonymous key

## Deployment

\`\`\`bash
vercel --prod
\`\`\`

## Development

See \`CLAUDE.md\` for detailed commands, project structure, and environment setup.

---

**Status:** In Development  
**Purpose:** Personal learning and portfolio project
EOF
else
  cat > README.md << EOF
# $PROJECT_NAME

![Type](https://img.shields.io/badge/Type-AI%20App-purple)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow)
![Stack](https://img.shields.io/badge/Stack-Next.js%20%7C%20Claude%20%7C%20Vercel%20AI%20SDK-blue)

Short one- or two-sentence overview of what this project does, who it is for, and the main outcome it delivers.

## Features

- **AI-powered:** [What the AI does for users]
- **Conversational:** [Chat/interaction pattern]
- **Personalized:** [How it adapts to users]

## Quick Start

\`\`\`bash
npm install
cp .env.example .env.local
npm run dev
\`\`\`

Open http://localhost:3000 in your browser.

## Environment Variables

- **\`ANTHROPIC_API_KEY\`** – Claude API key for chat
- **\`OPENAI_API_KEY\`** – OpenAI key for embeddings
- **\`NEXT_PUBLIC_SUPABASE_URL\`** – Supabase project URL
- **\`LANGFUSE_PUBLIC_KEY\`** – Langfuse tracing (optional)

## Tech Stack

- **LLM:** Anthropic Claude via Vercel AI SDK
- **Database:** Supabase (PostgreSQL + pgvector)
- **Observability:** Langfuse
- **Deploy:** Vercel

## Deployment

\`\`\`bash
vercel --prod
\`\`\`

## Development

See \`CLAUDE.md\` for detailed commands, project structure, and AI patterns.

---

**Status:** In Development  
**Purpose:** Personal learning and portfolio project
EOF
fi

# Create .env.example
if [ "$BASIC_MODE" = true ]; then
  cat > .env.example << EOF
# Database (Supabase)
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
EOF
else
  cat > .env.example << EOF
# LLM APIs (see root CLAUDE.md for preferred defaults)
ANTHROPIC_API_KEY=your-anthropic-key
OPENAI_API_KEY=your-openai-key

# Database + Vector Store (Supabase with pgvector)
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Observability (Langfuse)
LANGFUSE_PUBLIC_KEY=your-langfuse-public-key
LANGFUSE_SECRET_KEY=your-langfuse-secret-key
LANGFUSE_HOST=https://cloud.langfuse.com

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
EOF
fi

# Create .gitignore
cat > .gitignore << EOF
# Dependencies
node_modules/
venv/
__pycache__/
.venv/

# Environment variables
.env
.env.local
*.key
*.pem

# Build outputs
dist/
build/
.next/
out/
*.log

# Testing
test-results/
e2e-results/
playwright-report/
playwright/.cache/

# OS
.DS_Store
.vscode/
.idea/

# Claude
CLAUDE.local.md
.claude/

# AI Documentation (Mode A - not published to GitHub)
PLAN.md
BUILD_LOG.md
PIVOT_LOG.md
ARCHITECTURE.md
CLAUDE.md
EOF

# Create CLAUDE.md (AI assistant context)
if [ "$BASIC_MODE" = true ]; then
  cat > CLAUDE.md << EOF
# $PROJECT_NAME - AI Assistant Context

> **Purpose:** Technical context for AI coding assistants
> - Development commands and paths
> - Project structure and dependencies
> - Environment setup and troubleshooting
> - NOT for human readers (see README.md)

## Project Type
Next.js 14+ (App Router) with TypeScript (strict mode) and TailwindCSS

*Follows root CLAUDE.md Core Web defaults. No AI/LLM features.*

## Key Commands

### Development
\`\`\`bash
cd $PROJECT_NAME
npm run dev          # Start dev server on http://localhost:3000
npm run build        # Production build
npm run lint         # ESLint check
\`\`\`

### Deployment
\`\`\`bash
vercel --prod        # Deploy to Vercel personal account
\`\`\`

## Project Structure
\`\`\`
$PROJECT_NAME/
├── app/
│   ├── api/                    # API routes
│   ├── layout.tsx              # Root layout
│   ├── page.tsx                # Home page
│   └── globals.css             # Tailwind imports
├── components/
│   └── ui/                     # Reusable UI components
├── lib/
│   └── supabase.ts             # Supabase client
├── public/                     # Static assets
├── .env.local                  # Local environment (gitignored)
└── .env.example                # Template for env vars
\`\`\`

## Environment Variables
Required in \`.env.local\`:
\`\`\`bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
\`\`\`

## Testing

### E2E Testing (Playwright)
\`\`\`bash
npm test              # Run all E2E tests headless
npm run test:ui       # Interactive Playwright UI
npm run test:headed   # Watch tests in browser
\`\`\`

Test files: \`e2e/*.spec.ts\`  
Config: \`playwright.config.ts\`  
Screenshots: \`e2e-results/\`

## Development Notes
- Server runs on http://localhost:3000
- TypeScript strict mode enabled
- [Add project-specific technical notes here]

---

**Last Updated:** $(date +%Y-%m-%d)
EOF
else
  cat > CLAUDE.md << EOF
# $PROJECT_NAME - AI Assistant Context

> **Purpose:** Technical context for AI coding assistants
> - Development commands and paths
> - Project structure and dependencies
> - Environment setup and troubleshooting
> - NOT for human readers (see README.md)

## Project Type
Next.js 14+ (App Router) with AI/conversational features

*Follows root CLAUDE.md defaults (Core Web + AI/Conversational + Observability).*

## Tech Stack
- **Framework**: Next.js 14+ (App Router, Server Components)
- **Language**: TypeScript (strict mode)
- **Styling**: TailwindCSS
- **Database**: Supabase (PostgreSQL + pgvector)
- **LLM**: Anthropic Claude via Vercel AI SDK
- **Streaming**: \`ai\` package with \`ai/react\` hooks
- **Observability**: Langfuse for tracing
- **Testing**: Playwright E2E tests
- **Deploy**: Vercel

## Key Commands

### Development
\`\`\`bash
cd $PROJECT_NAME
npm run dev          # Start dev server on http://localhost:3000
npm run build        # Production build
npm run lint         # ESLint check
\`\`\`

### Deployment
\`\`\`bash
vercel --prod        # Deploy to Vercel personal account
\`\`\`

## Project Structure
\`\`\`
$PROJECT_NAME/
├── app/
│   ├── api/
│   │   ├── chat/route.ts       # Streaming chat endpoint (Vercel AI SDK)
│   │   └── embeddings/route.ts # Vector embedding endpoint
│   ├── layout.tsx              # Root layout with providers
│   ├── page.tsx                # Main UI (chat interface)
│   └── globals.css             # Tailwind imports
├── components/
│   ├── chat/                   # Chat UI components
│   │   ├── ChatMessages.tsx    # Message list display
│   │   ├── ChatInput.tsx       # User input with submit
│   │   └── MessageBubble.tsx   # Individual message styling
│   └── ui/                     # Reusable UI components
├── lib/
│   ├── ai/
│   │   ├── anthropic.ts        # Anthropic client setup
│   │   ├── prompts.ts          # System prompts and templates
│   │   └── tools.ts            # Tool definitions (if using function calling)
│   ├── db/
│   │   ├── supabase.ts         # Supabase client
│   │   └── vectors.ts          # pgvector operations
│   └── utils.ts                # Helper functions
├── types/
│   └── index.ts                # TypeScript type definitions
├── public/                     # Static assets
├── .env.local                  # Local environment (gitignored)
└── .env.example                # Template for env vars
\`\`\`

## Environment Variables
Required in \`.env.local\`:
\`\`\`bash
# LLM APIs
ANTHROPIC_API_KEY=your-anthropic-key
OPENAI_API_KEY=your-openai-key  # For embeddings

# Database + Vector Store
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Observability
LANGFUSE_PUBLIC_KEY=your-langfuse-public-key
LANGFUSE_SECRET_KEY=your-langfuse-secret-key
LANGFUSE_HOST=https://cloud.langfuse.com
\`\`\`

## Key Patterns

### Streaming Chat (Vercel AI SDK)
\`\`\`typescript
// app/api/chat/route.ts
import Anthropic from '@anthropic-ai/sdk';
import { AnthropicStream, StreamingTextResponse } from 'ai';

export async function POST(req: Request) {
  const { messages } = await req.json();
  
  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 1024,
    stream: true,
    messages,
  });
  
  const stream = AnthropicStream(response);
  return new StreamingTextResponse(stream);
}
\`\`\`

### Chat UI Hook
\`\`\`typescript
// In your page component
import { useChat } from 'ai/react';

const { messages, input, handleInputChange, handleSubmit, isLoading } = useChat({
  api: '/api/chat',
});
\`\`\`

### Langfuse Tracing
\`\`\`typescript
import { Langfuse } from 'langfuse';

const langfuse = new Langfuse({
  publicKey: process.env.LANGFUSE_PUBLIC_KEY,
  secretKey: process.env.LANGFUSE_SECRET_KEY,
});

// Wrap LLM calls with traces
const trace = langfuse.trace({ name: 'chat-response' });
\`\`\`

## Testing

### E2E Testing (Playwright)
\`\`\`bash
npm test              # Run all E2E tests headless
npm run test:ui       # Interactive Playwright UI
npm run test:headed   # Watch tests in browser
\`\`\`

Test files: \`e2e/*.spec.ts\`  
Config: \`playwright.config.ts\`  
Screenshots: \`e2e-results/\`

## Development Notes
- Server runs on http://localhost:3000
- TypeScript strict mode enabled
- Use \`claude-sonnet-4-20250514\` for balanced speed/quality
- Embeddings: OpenAI \`text-embedding-3-small\` (1536 dimensions)
- [Add project-specific technical notes here]

---

**Last Updated:** $(date +%Y-%m-%d)
EOF
fi

# Create PLAN.md (Blueprint - WHAT we're building)
cat > PLAN.md << EOF
# $PROJECT_NAME - Plan

> **Purpose:** Blueprint document (WHAT we're building)
> - Product vision and requirements
> - Target users and jobs to be done
> - Phases, milestones, and success criteria
> - Technical approach overview
> - NO detailed implementation (see CLAUDE.md for that)

## Product Vision & Requirements

**Problem:** [What problem does this solve? Who is it for?]

**Target Users:** [Primary and secondary users]

**Jobs to Be Done:** [Key user stories and use cases]
- As a [user type], I want to [action] so that [benefit]
- As a [user type], I want to [action] so that [benefit]

**Success Criteria:** [How we measure success]

## Phases

1. **Phase 1:** [Scope] — [Milestones] — [Status: Not Started]
2. **Phase 2:** [Scope] — [Milestones] — [Status: Not Started]

## Technical Approach

- **Framework:** Next.js 14+ (App Router, Server Components)
- **Language:** TypeScript (strict mode)
- **Styling:** TailwindCSS
- **Database:** Supabase (PostgreSQL + pgvector)
- **Deploy:** Vercel
- **Key Dependencies:** [List main packages]
- **Architecture:** [High-level description or diagram]

## Feature Requirements

### MVP (Must Have)
- [ ] [Core feature 1]
- [ ] [Core feature 2]

### Future (Nice to Have)
- [ ] [Enhancement 1]
- [ ] [Enhancement 2]

## Open Questions
- [ ] [Question 1]
- [ ] [Question 2]

---

**Last Updated:** $(date +%Y-%m-%d)
EOF

# Create BUILD_LOG.md (Journal - WHEN things happened)
cat > BUILD_LOG.md << EOF
# $PROJECT_NAME - Build Log

> **Purpose:** Chronological progress diary
> - Track what was done, when, and evidence of completion
> - Append entries (never replace); date each entry

---

## Progress - $(date +%Y-%m-%d)

**Done:**
- ✅ Project scaffolded with Next.js 14+ (App Router), TypeScript, TailwindCSS

**In Progress:**
- [ ] [Current task] (0%)

**Next:**
- [ ] [Priority 1]
- [ ] [Priority 2]

**Blockers:**
- None

---

**Last Updated:** $(date +%Y-%m-%d)
EOF

# Create PIVOT_LOG.md (Decisions & Course Corrections - WHY)
cat > PIVOT_LOG.md << EOF
# $PROJECT_NAME - Pivots & Decisions

> **Purpose:** Record key decisions and course corrections
> - Why we chose specific approaches
> - When we changed direction from original plan
> - Append chronologically; never replace

---

## Decision: Initial Tech Stack - $(date +%Y-%m-%d)

**Decision:** Next.js 14+ (App Router), TypeScript (strict mode), TailwindCSS, Supabase, Vercel

**Rationale:**
- Follows workspace defaults from root CLAUDE.md
- Next.js App Router provides modern React patterns
- TypeScript strict mode catches errors early
- Supabase provides unified database + vector store
- Vercel enables fast deployment

**Alternatives:**
- [Other frameworks/approaches considered]

**Status:** Implemented  
**DRI:** [Owner]

---

**Last Updated:** $(date +%Y-%m-%d)
EOF

# Create ARCHITECTURE.md (System Architecture - HOW)
cat > ARCHITECTURE.md << EOF
# $PROJECT_NAME - Architecture

> **Purpose:** Document system architecture and design decisions
> - Component structure and data flow
> - Integration points and key patterns
> - Technical constraints and conventions
> - Update when architecture changes significantly

---

## Overview

[High-level description of the system architecture]

## Components

- **[Component Name]**: [Responsibility and purpose]
- **[Component Name]**: [Responsibility and purpose]

## Data Flow

[Description of how data moves through the system, including:
- User interactions → API → Database
- Background processes
- External integrations]

## Integration Points

- **[External Service/API]**: [Purpose and integration pattern]
- **[External Service/API]**: [Purpose and integration pattern]

## Key Patterns & Conventions

- **[Pattern Name]**: [When/why to use this pattern]
- **[Pattern Name]**: [When/why to use this pattern]

## Technical Constraints

- **[Constraint]**: [Impact on system design]
- **[Constraint]**: [Impact on system design]

## Directory Structure

\`\`\`
$PROJECT_NAME/
├── app/                    # Next.js App Router pages and routes
├── components/             # React components
├── lib/                     # Utility functions and shared logic
├── types/                   # TypeScript type definitions
└── public/                  # Static assets
\`\`\`

---

**Last Updated:** $(date +%Y-%m-%d)
EOF

if [ "$BASIC_MODE" = true ]; then
  echo "✓ Created README.md, .env.example, .gitignore, CLAUDE.md, PLAN.md, BUILD_LOG.md, PIVOT_LOG.md, ARCHITECTURE.md (basic mode)"
else
  echo "✓ Created README.md, .env.example, .gitignore, CLAUDE.md, PLAN.md, BUILD_LOG.md, PIVOT_LOG.md, ARCHITECTURE.md (AI-ready)"
fi

# Create GitHub repo
GITHUB_USER="${GITHUB_USER:-your-username}"
echo ""
if [ "$SKIP_GITHUB" = true ] || [ ! -t 0 ]; then
  echo "⚠️  Skipped GitHub repo creation (--skip-github or non-interactive)"
  echo "   To create later: gh repo create $GITHUB_USER/$PROJECT_NAME --public --source=. --remote=origin"
  echo "   Or: git remote add origin git@github.com:$GITHUB_USER/$PROJECT_NAME.git"
else
  echo "Create GitHub repo at github.com/$GITHUB_USER? (y/n)"
  read -p "> " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v gh &> /dev/null; then
      gh repo create "$GITHUB_USER/$PROJECT_NAME" --public --source=. --remote=origin 2>/dev/null || {
        echo "⚠️  Run: gh auth login (if not authenticated)"
        echo "   Then: git remote add origin git@github.com:$GITHUB_USER/$PROJECT_NAME.git"
      }
    else
      echo "⚠️  Install gh CLI: https://cli.github.com/"
      echo "   Or add remote manually: git remote add origin git@github.com:$GITHUB_USER/$PROJECT_NAME.git"
    fi
  else
    echo "⚠️  Skipped. Create later: git remote add origin git@github.com:$GITHUB_USER/$PROJECT_NAME.git"
  fi
fi

# Scaffold full Next.js AI structure if requested
if [ "$SCAFFOLD" = true ]; then
  echo ""
  echo "📦 Scaffolding Next.js AI app structure..."
  
  # Create package.json
  cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "db:push": "prisma db push",
    "db:studio": "prisma studio",
    "db:generate": "prisma generate",
    "test": "playwright test",
    "test:ui": "playwright test --ui",
    "test:headed": "playwright test --headed"
  },
  "dependencies": {
    "@anthropic-ai/sdk": "^0.32.1",
    "@prisma/client": "^6.0.0",
    "@supabase/supabase-js": "^2.39.0",
    "ai": "^4.0.0",
    "langfuse": "^3.0.0",
    "next": "^15.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "@playwright/test": "^1.40.0",
    "@types/node": "^22.0.0",
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "eslint": "^9.0.0",
    "eslint-config-next": "^15.0.0",
    "postcss": "^8.0.0",
    "prisma": "^6.0.0",
    "tailwindcss": "^4.0.0",
    "typescript": "^5.0.0"
  }
}
EOF
  
  # Create directory structure
  mkdir -p app/api/chat
  mkdir -p app/api/feedback
  mkdir -p components/chat
  mkdir -p lib/ai
  mkdir -p lib/db
  mkdir -p types
  mkdir -p prisma
  mkdir -p e2e
  
  # Create tsconfig.json
  cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF
  
  # Create next.config.js
  cat > next.config.js << EOF
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    serverComponentsExternalPackages: ['langfuse'],
  },
};

module.exports = nextConfig;
EOF
  
  # Create tailwind.config.js
  cat > tailwind.config.js << EOF
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
EOF
  
  # Create postcss.config.js
  cat > postcss.config.js << EOF
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOF
  
  # Create Prisma schema
  cat > prisma/schema.prisma << EOF
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// Add your models here
model AdminConfig {
  id        String   @id @default(cuid())
  key       String   @unique
  value     String
  variant   String?  @default("A")
  isActive  Boolean  @default(true)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Feedback {
  id        String   @id @default(cuid())
  runId     String?
  score     Int?
  comment   String?
  createdAt DateTime @default(now())
}
EOF
  
  # Create Prisma client
  cat > lib/db/prisma.ts << EOF
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

export const prisma = globalForPrisma.prisma || new PrismaClient();

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

export default prisma;
EOF
  
  # Create Supabase client
  cat > lib/db/supabase.ts << EOF
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
EOF
  
  # Create AI agent config
  cat > lib/ai/agent.ts << EOF
import Anthropic from '@anthropic-ai/sdk';

export const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY!,
});

export const agentConfig = {
  model: 'claude-sonnet-4-20250514',
  maxTokens: 1024,
};

export const SYSTEM_PROMPT = \`You are a helpful assistant for $PROJECT_NAME.

Your capabilities:
- Answer questions about [your domain]
- Use tools to [describe tool capabilities]
- Provide accurate, helpful responses

Guidelines:
- Be concise but thorough
- Ask clarifying questions when needed
- Cite sources when applicable
\`;
EOF
  
  # Create tools definition
  cat > lib/ai/tools.ts << EOF
import { tool } from 'ai';
import { z } from 'zod';

// Example tool - replace with your domain-specific tools
export const exampleTool = tool({
  description: 'An example tool that echoes input',
  parameters: z.object({
    input: z.string().describe('The input to echo'),
  }),
  execute: async ({ input }) => {
    return { result: \`You said: \${input}\` };
  },
});

// Export all tools for the agent
export const agentTools = {
  exampleTool,
};
EOF
  
  # Create chat API route
  cat > app/api/chat/route.ts << EOF
import Anthropic from '@anthropic-ai/sdk';
import { AnthropicStream, StreamingTextResponse } from 'ai';
import { anthropic, SYSTEM_PROMPT } from '@/lib/ai/agent';
import { agentTools } from '@/lib/ai/tools';

export const maxDuration = 30;

export async function POST(req: Request) {
  const { messages } = await req.json();

  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 1024,
    system: SYSTEM_PROMPT,
    messages,
    stream: true,
  });

  const stream = AnthropicStream(response);
  return new StreamingTextResponse(stream);
}
EOF
  
  # Create feedback API route
  cat > app/api/feedback/route.ts << EOF
import { NextResponse } from 'next/server';
import prisma from '@/lib/db/prisma';

export async function POST(req: Request) {
  const { runId, score, comment } = await req.json();

  const feedback = await prisma.feedback.create({
    data: { runId, score, comment },
  });

  return NextResponse.json({ success: true, id: feedback.id });
}
EOF
  
  # Create Chat Interface component
  cat > components/chat/ChatInterface.tsx << EOF
'use client';

import { useChat } from 'ai/react';
import { useState } from 'react';

export function ChatInterface() {
  const { messages, input, handleInputChange, handleSubmit, isLoading } = useChat({
    api: '/api/chat',
  });

  return (
    <div className="flex flex-col h-screen max-w-4xl mx-auto p-4">
      {/* Messages */}
      <div className="flex-1 overflow-y-auto space-y-4 mb-4">
        {messages.map((m) => (
          <div
            key={m.id}
            className={\`p-4 rounded-lg \${m.role === 'user' ? 'bg-blue-100 ml-8' : 'bg-gray-100 mr-8'}\`}
          >
            <strong className="font-semibold">{m.role === 'user' ? 'You' : 'Assistant'}:</strong>
            <p className="mt-1">{m.content}</p>
          </div>
        ))}
      </div>

      {/* Input */}
      <form onSubmit={handleSubmit} className="flex gap-2">
        <input
          className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          value={input}
          onChange={handleInputChange}
          placeholder="Type your message..."
          disabled={isLoading}
        />
        <button
          type="submit"
          className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
          disabled={isLoading}
        >
          {isLoading ? 'Sending...' : 'Send'}
        </button>
      </form>
    </div>
  );
}
EOF
  
  # Create layout
  cat > app/layout.tsx << EOF
import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: '$PROJECT_NAME',
  description: 'AI-powered application',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
EOF
  
  # Create main page
  cat > app/page.tsx << EOF
import { ChatInterface } from '@/components/chat/ChatInterface';

export default function Home() {
  return <ChatInterface />;
}
EOF
  
  # Create globals.css
  cat > app/globals.css << EOF
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  padding: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}
EOF
  
  # Create playwright.config.ts
  cat > playwright.config.ts << EOF
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
EOF
  
  # Create sample E2E test
  cat > e2e/app.spec.ts << EOF
import { test, expect } from '@playwright/test';

test('homepage loads', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/$PROJECT_NAME/i);
});
EOF
  
  echo "✓ Scaffolded Next.js AI app structure"
  echo ""
  echo "📋 Scaffold includes:"
  echo "   - package.json with AI SDK, Supabase, Prisma, Langfuse"
  echo "   - /api/chat with streaming"
  echo "   - /api/feedback for user feedback capture"
  echo "   - ChatInterface.tsx with TailwindCSS styling"
  echo "   - Prisma schema with AdminConfig + Feedback"
  echo "   - lib/ai/agent.ts + tools.ts (customize these)"
  echo "   - Playwright E2E test setup"
  echo ""
  echo "⚡ After running 'npm install', update:"
  echo "   1. lib/ai/agent.ts - System prompt for your domain"
  echo "   2. lib/ai/tools.ts - Domain-specific tools"
  echo "   3. prisma/schema.prisma - Your data models"
fi

echo ""
if [ "$BASIC_MODE" = true ]; then
  echo "✅ Project '$PROJECT_NAME' created successfully! (Basic web app)"
elif [ "$SCAFFOLD" = true ]; then
  echo "✅ Project '$PROJECT_NAME' created successfully! (Full scaffold)"
else
  echo "✅ Project '$PROJECT_NAME' created successfully! (AI-ready)"
  echo ""
  echo "📦 Included AI patterns:"
  echo "   - Vercel AI SDK streaming chat structure"
  echo "   - Anthropic Claude + OpenAI embeddings"
  echo "   - Supabase pgvector for RAG"
  echo "   - Langfuse observability setup"
fi
echo ""
echo "Next steps:"
echo "  cd $PROJECT_DIR"
if [ "$SCAFFOLD" = true ]; then
  echo "  npm install"
  echo "  cp .env.example .env.local  # Add your API keys"
  echo "  npm run db:push             # Push Prisma schema"
  echo "  npm run dev                 # Start dev server"
else
  echo "  # 1. Edit PLAN.md - Define product vision, phases, and requirements"
  echo "  # 2. Edit ARCHITECTURE.md - Document system architecture and design"
  echo "  # 3. Edit README.md - Write user-facing overview"
  echo "  # 4. Review CLAUDE.md - Customize tech stack notes"
  if [ "$BASIC_MODE" != true ]; then
    echo "  # 5. npx create-next-app@latest . --typescript --tailwind --app"
    echo "  # 6. npm install ai @anthropic-ai/sdk @supabase/supabase-js langfuse"
    echo "  # 7. npm install -D @playwright/test"
    echo "  # 8. npx playwright install"
    echo "  # 9. Create playwright.config.ts and e2e/*.spec.ts"
  else
    echo "  # 5. npx create-next-app@latest . --typescript --tailwind --app"
    echo "  # 6. npm install -D @playwright/test"
    echo "  # 7. npx playwright install"
    echo "  # 8. Create playwright.config.ts and e2e/*.spec.ts"
  fi
fi
echo "  git add ."
echo "  git commit -m 'feat: initial commit'"
echo "  git push -u origin main"
echo ""

exit 0

