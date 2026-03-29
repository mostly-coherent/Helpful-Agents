---
name: app-password-auth
description: Adds password-gated authentication with idle timeout to Next.js apps. Creates login page, API routes, middleware with rolling sessions, and SessionGuard with idle warning. Use when user wants to add password protection, auth gating, session management, idle logout, or sign-out to a Next.js app.
---

# App Password Auth

Adds a complete password-gate auth system to any Next.js app (App Router). Includes login page, middleware with rolling session, sign-out button, and idle timeout with warning countdown.

## When to Use

- Adding password protection to a new or existing Next.js app
- User mentions "auth", "login", "password gate", "idle timeout", "session guard"
- Standardizing auth across multiple apps

## Auth System Spec

All values below are the **gold standard** — use these exact values unless the user requests otherwise.

| Parameter | Value |
|-----------|-------|
| Cookie maxAge | **2 days** (`60 * 60 * 24 * 2`) |
| Rolling refresh | **Yes** — middleware extends cookie on every authenticated request |
| Idle timeout | **30 minutes** (`30 * 60 * 1000` ms) |
| Warning countdown | **60 seconds** before auto-logout |
| Activity throttle | **5 seconds** minimum between timer resets |
| Activity events | `mousemove`, `mousedown`, `keydown`, `touchstart`, `scroll`, `click` |
| Auth cookie value | `"authenticated"` |
| Password env var | `APP_PASSWORD` |

## Files to Create/Update

Detect the app's directory structure first: **`src/app/`** vs **`app/`** at project root.

### 1. `middleware.ts` (project root — always at root, not in src/)

```typescript
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

// Session duration: 2 days (rolling — refreshed on every authenticated request)
const SESSION_MAX_AGE = 60 * 60 * 24 * 2;

export function middleware(request: NextRequest) {
  const password = process.env.APP_PASSWORD;
  if (!password) return NextResponse.next();

  const isAuthenticated =
    request.cookies.get("COOKIE_NAME")?.value === "authenticated";

  const { pathname } = request.nextUrl;
  const isPublic = pathname === "/login" ||
    pathname === "/api/login" ||
    pathname === "/api/logout";

  if (isPublic) return NextResponse.next();

  if (!isAuthenticated) {
    const loginUrl = new URL("/login", request.url);
    loginUrl.searchParams.set("redirect", pathname);
    return NextResponse.redirect(loginUrl);
  }

  // Rolling session: refresh cookie on every authenticated request
  const response = NextResponse.next();
  response.cookies.set("COOKIE_NAME", "authenticated", {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    maxAge: SESSION_MAX_AGE,
    path: "/",
  });
  return response;
}

export const config = {
  matcher: [
    "/((?!api/login|api/logout|_next/static|_next/image|favicon.ico).*)",
  ],
};
```

**Customization points:**
- Replace `COOKIE_NAME` with a unique name per app (e.g., `my_app_auth`)
- Add extra public routes to matcher if needed (e.g., `/api/cron`)

### 2. `app/api/login/route.ts` (or `src/app/api/login/route.ts`)

```typescript
import { NextRequest, NextResponse } from "next/server";
import { cookies } from "next/headers";

export async function POST(request: NextRequest) {
  try {
    const { password } = await request.json();
    const expectedPassword = process.env.APP_PASSWORD;

    if (!expectedPassword) {
      return NextResponse.json({ success: true }, { status: 200 });
    }

    if (!password || password !== expectedPassword) {
      return NextResponse.json(
        { success: false, error: "Invalid password" },
        { status: 401 }
      );
    }

    const cookieStore = await cookies();
    cookieStore.set("COOKIE_NAME", "authenticated", {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      maxAge: 60 * 60 * 24 * 2, // 2 days
      path: "/",
    });

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("[Login] Error:", error);
    return NextResponse.json(
      { success: false, error: "Failed to authenticate" },
      { status: 500 }
    );
  }
}
```

### 3. `app/api/logout/route.ts` (or `src/app/api/logout/route.ts`)

```typescript
import { NextResponse } from "next/server";
import { cookies } from "next/headers";

export async function POST() {
  const cookieStore = await cookies();
  cookieStore.delete("COOKIE_NAME");
  return NextResponse.json({ success: true });
}
```

### 4. `app/login/page.tsx` (or `src/app/login/page.tsx`)

Create a login page with:
- Centered card layout with app branding (name, emoji/icon, colors)
- Password input with error handling
- Submit button with loading state
- `Suspense` wrapper for `useSearchParams`
- Redirect support via `?redirect=` query param
- `autoFocus`, `required`, `autoComplete="current-password"` on input
- Accessible: `aria-describedby` for errors, `role="alert"` on error messages

**Style the login page to match the app's existing design language** (colors, fonts, theme).

### 5. `components/SessionGuard.tsx` (or `src/components/SessionGuard.tsx`)

The SessionGuard component handles:
- **Idle timeout:** 30-min timer, resets on user activity (throttled to 5s)
- **Warning modal:** 60-second countdown with "I'm here" and "Sign out" buttons
- **Sign-out button:** Fixed top-right, icon + text on larger screens
- **Login page exclusion:** Returns null on `/login`

Key implementation details:
- Uses `useRef` for timers (not state) to avoid re-render loops
- `lastResetRef` for throttling activity resets
- `useCallback` for all handlers to maintain stable references
- Cleanup: removes all event listeners and clears timers on unmount
- `{ passive: true }` on event listeners for performance

**If the app already has a sign-out button** (e.g., in a NavBar), the SessionGuard can skip rendering its own sign-out button and only provide the idle timeout + warning modal.

**Style the warning modal to match the app's existing design language.**

### 6. `app/layout.tsx` — Add SessionGuard

```typescript
import { SessionGuard } from "@/components/SessionGuard";
// ... existing imports

// In the body:
<SessionGuard />
{children}
```

### 7. `.env.example` — Add APP_PASSWORD

```
# Password Protection (set to enable login gate)
APP_PASSWORD=your-app-password
```

### 8. `.env.local` — Set actual password

Remind the user to set `APP_PASSWORD` in their `.env.local` file. **Never commit the actual password.**

## Implementation Checklist

1. [ ] Detect app structure (`src/app/` vs `app/`)
2. [ ] Choose unique cookie name (e.g., `{app_name}_auth`)
3. [ ] Create `middleware.ts` at project root
4. [ ] Create `api/login/route.ts`
5. [ ] Create `api/logout/route.ts`
6. [ ] Create `login/page.tsx` (styled to match app)
7. [ ] Create `SessionGuard.tsx` (or update existing)
8. [ ] Add `<SessionGuard />` to `layout.tsx`
9. [ ] Update `.env.example` with `APP_PASSWORD`
10. [ ] Remind user to set `APP_PASSWORD` in `.env.local`

## Existing App Adaptation

If the app **already has auth** and you're standardizing:

1. **Check cookie maxAge** — should be `60 * 60 * 24 * 2` (2 days)
2. **Check middleware** — should have rolling refresh (re-set cookie on each authenticated request)
3. **Check SessionGuard** — should have 5s activity throttle (`THROTTLE_MS = 5_000`)
4. **Check activity events** — should have all 6: `mousemove`, `mousedown`, `keydown`, `touchstart`, `scroll`, `click`
5. **Check warning dialog** — should have 60s countdown timer (not just "Stay Logged In" button)
6. **Delete orphaned files** — remove `proxy.ts` if middleware handles everything

## Notes

- Cookie name must be unique per app (avoids conflicts if apps share a domain)
- `APP_PASSWORD` not set = auth disabled (backward compatible for local dev)
- Middleware runs on edge — no Node.js-specific imports (no `crypto`, no `fs`)
- The login API route runs on Node.js — can use `cookies()` from `next/headers`
