# DZ-Bridge Real Manager Backend Portal & Django Integration Report
**Date:** 2026-10-26 16:58:10 CET  
**Environment:** Linux (Ubuntu/Debian) · DZ-Bridge Sovereign Academic & Diaspora Ecosystem  
**Author:** Antigravity Autonomous Pair Programmer  
**Status:** Merged, Synchronized & Verified  

---

## 1. Executive Summary

As requested, the full **Manager Backend Portal Platform** from `django-portal-manager-ADMIN` has been merged and unified into the active DZ-Bridge platform (`DzBridge_Platform2`). 

When an administrative user (`admin@dz-bridge.dz`, `dzsoft.contact@gmail.com`, or `degha`) logs in, they are no longer directed to a narrow sub-console. Instead, they are taken directly to the **Real Manager Backend Portal** (`/manager`), landing on the **National Dashboard Overview** (`activeTab: 'dashboard'`) with complete managerial oversight over all integrated frontend workspaces, live Django backend services, PostgreSQL database tables, and algorithmic matching runs.

---

## 2. Integrated Manager Portal Architecture

The Manager Backend Portal unites all 12 operational studios into a single unified control room:

1. **National Dashboard Overview (`dashboard`)**:
   - High-level KPIs: Total registered diaspora scholars, partner universities, active doctoral challenges, confirmed partnerships.
   - Algorithmic Matchmaking Engine controls (re-running compatibility calculations across skills, availability, and location).
   - Real-time activity feed and system health monitors.
2. **Scholar & Diaspora Workspace (`scholar-space`)**:
   - Management and inspection of visiting diaspora scholars (e.g. Prof. Belgacem Haba, Dr. Amina Benali).
3. **University & Institute Portal (`university-portal`)**:
   - Direct control of institutional submissions and challenge matching.
4. **REST API Gateway & Endpoint Studio (`api-management`)**:
   - Interactive testing, latency tracking, and execution of live API endpoints.
5. **Translation Hub (`translation-hub`)**:
   - Live trilingual catalog editor (English, French, Arabic) with RTL/LTR directional support.
6. **Django REST Framework Client (`django-client`)**:
   - Dedicated DRF test harness running live against Django backend services on port 8000.
7. **Database Studio (`schema`)**:
   - Interactive D3 SVG Entity-Relationship (ERD) graph of the 21 PostgreSQL/SQLite relational tables.
   - Live Table Data Browser supporting direct record insertion, inline editing, CSV/JSON import, and backup export.
8. **Automated Lifecycle Sequences (`sequence`)**:
   - 7-step automated test runner simulating the entire scholar award lifecycle:
     *Registration* $\rightarrow$ *Availability Posting* $\rightarrow$ *Challenge Submission* $\rightarrow$ *Compatibility Scoring* $\rightarrow$ *Invitation* $\rightarrow$ *Institutional Protocol* $\rightarrow$ *Audit Verification*.
9. **Super Admin Control Center (`admin-console`)**:
   - High-level governance, cryptographic ledger verification, and administrative audit trails.
10. **User Management & RBAC Studio (`user-management`)**:
    - User account creation, role assignment (`super_admin`, `admin`, `expert`, `organization`), status toggling (active/suspended), and credential resets.
11. **Custom Strategic KPI Studio (`kpi-studio`)**:
    - Live formula builder for custom institutional and platform indicators.
12. **Audit Logs & Governance (`analytics`)**:
    - Cryptographic activity ledger with IP tracking, timestamping, and compliance audit exports.

---

## 3. Real Backend Synchronization & Proxy Architecture

### 3.1 Reverse Proxy to Django REST Framework (`/api/v1/*`)
To ensure full synchronization with Django (`django_backend` on port 8000) without cross-origin (CORS) complications:
- All calls to `/api/v1/*` originating from port 3000 are natively reverse-proxied to `http://127.0.0.1:8000/api/v1/*`.
- Headers, JWT Bearer tokens, and request payloads pass transparently to Django models and viewsets.
- Fallback resilience: If Django is momentarily offline or in maintenance, the system seamlessly serves from the persistent database store.

### 3.2 State Synchronization (`/api/state/full`)
- On application boot, `src/App.tsx` calls `/api/state/full` to synchronize active projects, candidate matches, bilateral collaborations, and database tables.

---

## 4. Route & Access Summary

| Route | Role Access | Target Component / View |
| :--- | :--- | :--- |
| `http://localhost:3000/` | Public | Sovereign Homepage (`landing_page.html`) |
| `http://localhost:3000/landing` | Public | HTTP 301 Redirect to `/` |
| `http://localhost:3000/login` | Public | Authentication Portal (`login.html`) |
| `http://localhost:3000/manager` | **Admin / Super Admin** | **Real Manager Backend Portal (`activeTab: 'dashboard'`)** |
| `http://localhost:3000/console` | Admin / Super Admin | Real Manager Backend Portal (Alias to `/manager`) |
| `http://localhost:3000/expert-dashboard.html` | Expert | Dedicated Diaspora Scholar Dashboard |
| `http://localhost:3000/organization-dashboard.html` | Organization | Dedicated Institutional Dashboard |
| `http://localhost:3000/api/v1/*` | Authenticated | Live Django DRF Proxy $\rightarrow$ `http://localhost:8000/api/v1/*` |

---

## 5. Verification Evidence

### 5.1 Manager Route Verification
```bash
# Unauthenticated request to /manager gets guarded and redirected to login:
$ curl -I http://localhost:3000/manager
HTTP/1.1 302 Found
Location: /login.html?redirect=%2Fmanager

# Login redirect for admin role target:
$ curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@dz-bridge.dz","password":"DZbridge2026!"}'
=> {
     "role": "admin",
     "fullName": "Dr. Youcef Khelifi",
     "target": "/manager"
   }
```

### 5.2 Reverse Proxy Verification (Port 3000 to Django Port 8000)
```bash
$ DJANGO_TOKEN=$(curl -s -X POST http://localhost:8000/api/v1/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@dz-bridge.dz","password":"DzBridge2026!"}' | jq -r '.token // .access')

# Calling Django endpoint through port 3000:
$ curl -s http://localhost:3000/api/v1/projects/ \
  -H "Authorization: Bearer $DJANGO_TOKEN" | jq .results[0].title
=> "Cycle Doctoral Intensif : Modèles de Fondation et NLP Arabe"
```

### 5.3 Django Port 8000 Direct Redirect Resolution
```bash
# Direct access to Django on port 8000 (/manager) immediately redirects to port 3000:
$ curl -I http://localhost:8000/manager
HTTP/1.1 302 Found
Location: http://localhost:3000/manager

# Direct access to /console on port 8000:
$ curl -I http://localhost:8000/console
HTTP/1.1 302 Found
Location: http://localhost:3000/manager

# Direct access to /dashboard on port 8000:
$ curl -I http://localhost:8000/dashboard
HTTP/1.1 302 Found
Location: http://localhost:3000/manager
```

---
*Report archived under `md_files_log/django_portal_manager_integration_report_2026-10-26.md` in accordance with the `log-outputs-to-md` skill.*
