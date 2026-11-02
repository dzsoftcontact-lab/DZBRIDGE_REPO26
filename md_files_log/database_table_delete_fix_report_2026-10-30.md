# Database Studio – Table Delete Fix Report

- **Date**: 2026-10-30
- **Environment**: Local dev (`tsx server.ts` on :3000, Django on :8000)
- **Target**: `http://localhost:3000/manager` → Database Studio
- **Role**: Platform engineer

## Executive Summary
Deleting a table in the Manager Portal looked like it worked, but it was never saved.
After a page reload the table came back. The delete never reached the backend's drop-table endpoint.

## Root Causes
1. `handleDeleteTableData` in `src/App.tsx` called `POST /api/data/:table/clear`. That endpoint only empties the rows. It never called `DELETE /api/schema/tables/:id`.
2. That call read the token from the wrong key (`dzb-token` instead of `dzb_token`).
3. `schemaTables` always starts from `INITIAL_SCHEMA_TABLES`, so every deleted table reappeared after a reload.
4. The backend `DELETE /api/schema/tables/:id` only matched server IDs, which are different from the console's table IDs. It returned 404 for most tables.

## Changes
| File | Change |
|------|--------|
| `server.ts` | `DELETE /api/schema/tables/:id` now matches by id **or** name and works for console-only tables |
| `server.ts` | New `db.dropped_tables` list (saved to `data/db.json`). A table name is removed from it when a table with that name is created again |
| `server.ts` | `/api/state/full` now returns `dropped_tables` |
| `src/App.tsx` | Delete now calls `DELETE /api/schema/tables/<name>` with the right token and cookies |
| `src/App.tsx` | On load, dropped tables and their relations are filtered out of the schema |

## Verification
- `npx tsc --noEmit`: no errors in `server.ts` or `src/App.tsx`.
- The running `tsx server.ts` process must be **restarted** for the backend changes to apply.
- Manual check: Manager → Database Studio → Delete Table → confirm → reload. The table stays deleted.

## Access
| URL | Role |
|-----|------|
| http://localhost:3000/manager | Admin (Manager Portal) |
