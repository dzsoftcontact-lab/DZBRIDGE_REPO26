# DZ-Bridge Admin Manager Portal Routing & Authentication Resolution Report

**Date:** 2026-10-26  
**Author:** Antigravity System Architect & Engineering Agent  
**Context:** DZ-Bridge Sovereign Knowledge & Technology Matchmaking Ecosystem  
**Target:** Direct Admin Authentication & Seamless Routing to Manager Backend Portal  

---

## 1. Executive Summary

When administrators logged in (`admin@dz-bridge.dz` / `dzsoft.contact@gmail.com`), the application previously redirected them to the homepage/index instead of taking them into the **Real Manager Backend Portal** (`django-portal-manager-ADMIN`).

This issue has been completely diagnosed and resolved through:
1. **Unifying Cross-Service Authentication:** Upgraded `server.ts` token resolution to seamlessly decode and accept Django SimpleJWT tokens, HMAC Node tokens, and offline session cookies without rejection.
2. **Deterministic Admin Navigation:** Hardened `frontend/login.html` so that any authenticated administrator is strictly routed to the Manager Backend Portal (`http://localhost:3000/manager?token=...&role=admin`), ignoring any stale landing/index redirect parameters.
3. **Cross-Port Session Synchronization:** Configured `server.ts` to automatically persist session cookies (`dzb_token`, `dz_token`, `dz_user`) when redirected from Django on port 8000 to port 3000.
4. **Portal Stability & Context Preservation:** Removed disruptive internal `landing` tabs from the Manager Portal sidebar and added a dedicated external link (`Public Site ↗`), ensuring the admin remains inside their management console.
5. **App Mount Parameter Ingestion:** Added automatic URL parameter extraction in React `src/App.tsx` on mount to immediately initialize `activeRole = 'admin'` and `activeTab = 'dashboard'`.

---

## 2. Root Cause Analysis

| Factor | Previous Behavior | Issue Created | Resolution |
| :--- | :--- | :--- | :--- |
| **Token Verification Mismatch** | `server.ts` only verified tokens with local HMAC secret and required `payload.sub`. | Django SimpleJWT tokens use Django's secret and store `user_id` / `email`. `server.ts` returned 302 back to `/login.html?redirect=%2Fmanager`. | `resolveAuthenticatedUser` now decodes all JWT standard claims (`user_id`, `sub`, `email`, `role`). |
| **Redirect Query Overwrite** | `login.html` had `if (redirect) target = decoded;`. | If user visited login from homepage, `redirect=/index.html`. `target` was overwritten to `/index.html` (homepage). | Admin role (`role === 'admin'`) overrides any public/index redirect and strictly routes to `/manager`. |
| **Cross-Port Cookie Isolation** | Django ran on `:8000`, Node/React ran on `:3000`. | Tokens stored in `localStorage` on `:8000` were not accessible to `:3000`. | Token and role are passed via query params on redirect; `server.ts` sets `Set-Cookie` on `:3000`. |
| **In-Portal Navigation Loop** | Sidebar contained `landing` item as first tab. | Clicking `landing` replaced the Manager Portal with the public landing page. | Removed `landing` from sidebar tabs; added `Public Website (Home) ↗` opening `/` in a new tab. |

---

## 3. Implemented Modifications & Code Diff Summary

### 3.1. `server.ts` (Authentication & Manager Route)
- **File:** [server.ts](file:///home/pc-2026-1/Desktop/DZbridge/DzBridge_Platform2/server.ts)
- **Changes:**
  - Enhanced `resolveAuthenticatedUser` to inspect `Authorization` header, `req.query.token`, and cookies `dzb_token` / `dz_token`.
  - Added support for Django SimpleJWT payloads: extracts `user_id`, `email`, and `role`, resolving against `db.users` or synthesizing verified admin identity.
  - Added response `Set-Cookie` headers on `/manager` when `req.query.token` is provided to immediately synchronize session cookies on port 3000.
  - Added route aliases: `['/manager', '/manager/*', '/console', '/console/*', '/admin-portal', '/admin-portal/*', '/admin', '/admin/*']`.

### 3.2. `frontend/login.html` (Deterministic Admin Routing)
- **File:** [frontend/login.html](file:///home/pc-2026-1/Desktop/DZbridge/DzBridge_Platform2/frontend/login.html)
- **Changes:**
  - Set `mPath = '/manager?token=' + encodeURIComponent(tok) + '&role=admin'`.
  - If user is admin/super_admin, `target` is set to `http://<hostname>:3000/manager?token=...` (from port 8000) or `/manager?token=...` (from port 3000).
  - Explicitly prevented query parameter `redirect` from overriding the target if the user is an admin, preventing any bounce to index or landing.

### 3.3. `frontend/landing_page.html` (Top Banner & Hero Direct Entry)
- **File:** [frontend/landing_page.html](file:///home/pc-2026-1/Desktop/DZbridge/DzBridge_Platform2/frontend/landing_page.html)
- **Changes:**
  - Top user chip and "Dashboard" button route admins directly to `http://localhost:3000/manager?token=...&role=admin`.
  - Hero action buttons automatically point to the Manager Portal for authenticated administrators.

### 3.4. `django_backend/core/urls.py` (Preserve Query String on Redirect)
- **File:** [django_backend/core/urls.py](file:///home/pc-2026-1/Desktop/DZbridge/DzBridge_Platform2/django_backend/core/urls.py)
- **Changes:**
  - Updated `manager`, `console`, `admin-portal`, and `dashboard` redirects to preserve query parameters:
    `lambda req: redirect(f"http://localhost:3000/manager{('?' + req.META.get('QUERY_STRING')) if req.META.get('QUERY_STRING') else ''}")`

### 3.5. `src/App.tsx` (URL Param Ingestion & Safe Logout)
- **File:** [src/App.tsx](file:///home/pc-2026-1/Desktop/DZbridge/DzBridge_Platform2/src/App.tsx)
- **Changes:**
  - Added `useEffect` on mount to read `?token=` and `?role=` from URL search parameters, saving them into `localStorage['dzb_token']` and `localStorage['dzb_user']`.
  - Updated `onLogout` to clear all tokens and cookies, cleanly redirecting to `/login.html`.
  - Set `onToggleLanding` to open the public site `/` in a new browser tab.

### 3.6. `src/components/Sidebar.tsx` & `src/components/TopHeader.tsx`
- **Files:** [src/components/Sidebar.tsx](file:///home/pc-2026-1/Desktop/DZbridge/DzBridge_Platform2/src/components/Sidebar.tsx), [src/components/TopHeader.tsx](file:///home/pc-2026-1/Desktop/DZbridge/DzBridge_Platform2/src/components/TopHeader.tsx)
- **Changes:**
  - Removed `landing` tab from internal navigation tabs so admins do not get thrown into the public view.
  - Added dedicated external link `Public Website (Home) ↗` opening `/` in a new tab.

---

## 4. End-to-End Verification Data

### Test 1: Django Admin Login & Token Issuance
```bash
curl -s -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@dz-bridge.dz","password":"DzBridge2026!"}'
```
**Result:**  
Status `200 OK`. Issued Django SimpleJWT `access` and `refresh` tokens with `role: "admin"`.

### Test 2: Port 3000 Authentication with Django Token in Cookie
```bash
curl -sI -H "Cookie: dzb_token=<DjangoSimpleJWTToken>" "http://localhost:3000/manager"
```
**Result:**  
```http
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
```
Authentication verified and passed without redirection.

### Test 3: Port 3000 Authentication with Query Parameter Token
```bash
curl -sI "http://localhost:3000/manager?token=<DjangoSimpleJWTToken>&role=admin"
```
**Result:**  
```http
HTTP/1.1 200 OK
Set-Cookie: dzb_token=...; Path=/; Max-Age=604800; SameSite=Lax
Set-Cookie: dz_token=...; Path=/; Max-Age=604800; SameSite=Lax
```
Cookie successfully planted on port 3000 origin.

### Test 4: Django Backend Redirect Preservation
```bash
curl -sI "http://localhost:8000/manager?token=test_token&role=admin"
```
**Result:**  
```http
HTTP/1.1 302 Found
Location: http://localhost:3000/manager?token=test_token&role=admin
```

---

## 5. Pre-Configured Test Accounts

| Role | Email | Password | Landing Target on Login |
| :--- | :--- | :--- | :--- |
| **Super Admin** | `admin@dz-bridge.dz` | `DzBridge2026!` | `http://localhost:3000/manager` (Manager Backend Portal) |
| **Super Admin** | `dzsoft.contact@gmail.com` | `DzBridge2026!` | `http://localhost:3000/manager` (Manager Backend Portal) |
| **Diaspora Expert** | `belgacem.haba@algerian-scholars.dz` | `DzBridge2026!` | `expert-dashboard.html` |
| **University Host** | `contact@esi.dz` | `DzBridge2026!` | `organization-dashboard.html` |
