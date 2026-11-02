import re
import json
import os
import hashlib

def hash_password(password: str) -> str:
    # Match the server.ts hash format: salt:hash
    salt = "4e12d324de81a66dd425ee3bc33f4959"
    key = hashlib.pbkdf2_hmac('sha512', password.encode('utf-8'), bytes.fromhex(salt), 100000)
    return f"{salt}:{key.hex()}"

DEFAULT_HASH = hash_password("DZbridge2026!")

with open('dz_bridge_database_dump_2026-10-13.sql', 'r', encoding='utf-8') as f:
    sql = f.read()

# -----------------------------------------------------------------------------
# 1. PARSE CONSTRAINTS (75 Foreign Keys)
# -----------------------------------------------------------------------------
constraint_pattern = r'ALTER TABLE \"(\w+)\"\s+ADD CONSTRAINT \"([^\"]+)\"\s+FOREIGN KEY \(\"([^\"]+)\"\)\s+REFERENCES \"(\w+)\"\(\"([^\"]+)\"(?:\)\s+ON DELETE ([^;]+);|\);)'
constraint_matches = re.findall(constraint_pattern, sql, re.DOTALL)
print(f"Found {len(constraint_matches)} constraint matches")

schema_relations = []
fk_lookup = {} # (source_table, source_col) -> (target_table, target_col, on_delete)

for src_tbl, con_name, src_col, tgt_tbl, tgt_col, on_del in constraint_matches:
    del_rule = on_del.strip() if on_del else "CASCADE"
    schema_relations.append({
        "id": con_name,
        "sourceTable": src_tbl,
        "sourceColumn": src_col,
        "targetTable": tgt_tbl,
        "targetColumn": tgt_col,
        "onDelete": del_rule,
        "label": f"{src_tbl}.{src_col} -> {tgt_tbl}.{tgt_col}"
    })
    fk_lookup[(src_tbl, src_col)] = (tgt_tbl, tgt_col, del_rule)

print(f"Constructed {len(schema_relations)} schema relations")

# -----------------------------------------------------------------------------
# 2. PARSE TABLES (29 Tables)
# -----------------------------------------------------------------------------
table_pattern = r'-- Table:\s*(\w+)\s*(?:\(([^)]+)\))?\n(?:-- Description:\s*([^\n]+)\n)?CREATE TABLE IF NOT EXISTS \"(\w+)\" \((.*?)\n\);'
table_matches = re.findall(table_pattern, sql, re.DOTALL)
print(f"Found {len(table_matches)} table matches")

schema_tables = []
for t_name, category, description, _, col_lines in table_matches:
    category = category.strip() if category else "Custom"
    description = description.strip() if description else f"{t_name} relational table"
    
    columns = []
    # Parse each column line: e.g. "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    for line in col_lines.splitlines():
        line = line.strip()
        if not line or not line.startswith('"'):
            continue
        line = line.rstrip(',')
        col_m = re.match(r'^\"(\w+)\"\s+([A-Za-z0-9_\[\]\(\)\s]+?)(?:\s+PRIMARY KEY)?(?:\s+NOT NULL)?(?:\s+DEFAULT\s+(.+?))?$', line)
        if not col_m:
            # Fallback
            parts = line.split(maxsplit=2)
            c_name = parts[0].strip('"')
            c_type = parts[1] if len(parts) > 1 else 'VARCHAR(255)'
            columns.append({
                "id": f"col-{t_name}-{c_name}",
                "name": c_name,
                "type": c_type,
                "isPrimary": "PRIMARY KEY" in line.upper(),
                "isNullable": "NOT NULL" not in line.upper() and "PRIMARY KEY" not in line.upper(),
                "defaultValue": None
            })
            continue
        
        c_name = col_m.group(1)
        raw_type = col_m.group(2).strip()
        def_val = col_m.group(3).strip() if col_m.group(3) else None
        
        # Clean type
        is_pk = "PRIMARY KEY" in line.upper()
        is_not_null = "NOT NULL" in line.upper()
        # Remove keywords from type
        clean_type = re.sub(r'\b(PRIMARY\s+KEY|NOT\s+NULL|DEFAULT.*)\b', '', raw_type, flags=re.IGNORECASE).strip()
        if not clean_type:
            clean_type = "VARCHAR(255)"
            
        col_def = {
            "id": f"col-{t_name}-{c_name}",
            "name": c_name,
            "type": clean_type,
            "isPrimary": is_pk,
            "isNullable": not is_not_null and not is_pk,
            "defaultValue": def_val,
            "description": f"{c_name} field"
        }
        
        # Check FK
        if (t_name, c_name) in fk_lookup:
            tgt_t, tgt_c, del_r = fk_lookup[(t_name, c_name)]
            col_def["isForeign"] = True
            col_def["foreignTable"] = tgt_t
            col_def["foreignColumn"] = tgt_c
            col_def["description"] = f"FK -> {tgt_t}({tgt_c}) ON DELETE {del_r}"
            
        columns.append(col_def)

    schema_tables.append({
        "id": f"tbl-{t_name}",
        "name": t_name,
        "description": description,
        "category": category,
        "columns": columns
    })

print(f"Constructed {len(schema_tables)} schema tables")

# -----------------------------------------------------------------------------
# 3. PARSE INSERTS (Data rows for all tables)
# -----------------------------------------------------------------------------
data_sec = sql[sql.find('-- 4. TABLE DATA'):sql.find('-- 5. RELATIONAL FOREIGN KEY')]
insert_pattern = r'INSERT INTO \"(\w+)\"\s*\((.*?)\)\s*VALUES\s*\((.*?)\)\s*ON CONFLICT DO NOTHING;'
insert_matches = re.findall(insert_pattern, data_sec, re.DOTALL)
print(f"Found {len(insert_matches)} insert statements")

def parse_sql_values(vals_str):
    # Tokenize comma separated SQL values handling strings with commas
    vals = []
    curr = []
    in_str = False
    depth = 0
    i = 0
    n = len(vals_str)
    while i < n:
        ch = vals_str[i]
        if ch == "'" and not in_str:
            in_str = True
            curr.append(ch)
        elif ch == "'" and in_str:
            if i + 1 < n and vals_str[i+1] == "'":
                curr.append("''")
                i += 1
            else:
                in_str = False
                curr.append(ch)
        elif ch in ('{', '[', '(') and not in_str:
            depth += 1
            curr.append(ch)
        elif ch in ('}', ']', ')') and not in_str:
            depth -= 1
            curr.append(ch)
        elif ch == ',' and not in_str and depth == 0:
            vals.append("".join(curr).strip())
            curr = []
        else:
            curr.append(ch)
        i += 1
    if curr:
        vals.append("".join(curr).strip())
    
    # Now cast each token
    cleaned = []
    for token in vals:
        token = token.strip()
        # Strip ::jsonb or other casts
        token = re.sub(r'::\w+$', '', token).strip()
        if token == 'NULL':
            cleaned.append(None)
        elif token == 'TRUE':
            cleaned.append(True)
        elif token == 'FALSE':
            cleaned.append(False)
        elif re.match(r'^-?\d+$', token):
            cleaned.append(int(token))
        elif re.match(r'^-?\d+\.\d+$', token):
            cleaned.append(float(token))
        elif token.startswith("'") and token.endswith("'"):
            inner = token[1:-1].replace("''", "'")
            # Try parsing inner as JSON if it looks like json or array
            if (inner.startswith('{') and inner.endswith('}')) or (inner.startswith('[') and inner.endswith(']')):
                try:
                    cleaned.append(json.loads(inner))
                except:
                    # Postgres array literal e.g. {"a", "b"}
                    if inner.startswith('{') and inner.endswith('}'):
                        items = [s.strip().strip('"') for s in inner[1:-1].split(',') if s.strip()]
                        cleaned.append(items)
                    else:
                        cleaned.append(inner)
            else:
                cleaned.append(inner)
        elif token.startswith('{') and token.endswith('}'):
            items = [s.strip().strip('"') for s in token[1:-1].split(',') if s.strip()]
            cleaned.append(items)
        else:
            cleaned.append(token)
    return cleaned

table_data_store = {t["name"]: [] for t in schema_tables}

for tbl_name, cols_str, vals_str in insert_matches:
    col_names = [c.strip().strip('"') for c in cols_str.split(',')]
    vals = parse_sql_values(vals_str)
    
    row = {}
    for c, v in zip(col_names, vals):
        row[c] = v
        
    if tbl_name in table_data_store:
        table_data_store[tbl_name].append(row)

for tbl, rows in table_data_store.items():
    if len(rows) > 0:
        print(f"  {tbl}: {len(rows)} rows")

# -----------------------------------------------------------------------------
# 4. LOAD & MERGE data/db.json
# -----------------------------------------------------------------------------
with open('data/db.json', 'r', encoding='utf-8') as f:
    existing_db = json.load(f)

# Existing users password hash map to preserve admin logins
existing_user_hashes = {u.get('email', '').lower(): u.get('password_hash') for u in existing_db.get('users', []) if u.get('password_hash')}
existing_user_hashes['admin@dz-bridge.dz'] = DEFAULT_HASH
existing_user_hashes['dzsoft.contact@gmail.com'] = DEFAULT_HASH

# Adapt users
adapted_users = []
for u_row in table_data_store.get('users', []):
    email = u_row.get('email', '')
    p_hash = existing_user_hashes.get(email.lower(), DEFAULT_HASH)
    
    # Find matching profile if available
    matching_prof = next((p for p in table_data_store.get('profiles', []) if p.get('user_id') == u_row.get('id')), {})
    full_name = matching_prof.get('full_name') or u_row.get('email', '').split('@')[0].capitalize()
    
    user_obj = {
        "id": u_row.get('id'),
        "email": email,
        "password_hash": p_hash,
        "fullName": full_name,
        "role": u_row.get('role', 'expert'),
        "status": u_row.get('status', 'active'),
        "country": matching_prof.get('country', 'Algeria'),
        "city": matching_prof.get('city', ''),
        "organizationName": matching_prof.get('organization_name', ''),
        "isDiaspora": matching_prof.get('is_diaspora', False),
        "specialty": ", ".join(matching_prof.get('expertise_tags', [])) if isinstance(matching_prof.get('expertise_tags'), list) else "",
        "bio": matching_prof.get('bio', ''),
        "phoneNumber": matching_prof.get('phone_number', ''),
        "createdAt": u_row.get('created_at') or '2026-08-01T08:00:00Z',
        "provider": "local"
    }
    adapted_users.append(user_obj)

# Ensure admin@dz-bridge.dz is present in users
if not any(u['email'] == 'admin@dz-bridge.dz' for u in adapted_users):
    adapted_users.insert(0, {
        "id": "usr-admin-001",
        "email": "admin@dz-bridge.dz",
        "password_hash": DEFAULT_HASH,
        "fullName": "Directeur Général DZ-Bridge (MESRS)",
        "role": "admin",
        "status": "active",
        "country": "Algeria",
        "city": "Algiers",
        "organizationName": "MESRS Higher Education Directorate",
        "isDiaspora": False,
        "specialty": "National Governance, Academic Strategy",
        "bio": "Lead national coordinator for diaspora academic missions.",
        "createdAt": "2026-01-05T00:00:00Z",
        "provider": "local"
    })

# Add users to table_data_store["users"] as well
for u in adapted_users:
    # Ensure in table_data_store.users
    existing = next((r for r in table_data_store['users'] if r.get('id') == u['id']), None)
    if existing:
        existing['password_hash'] = u['password_hash']
    else:
        table_data_store['users'].append({
            "id": u['id'],
            "email": u['email'],
            "password_hash": u['password_hash'],
            "role": u['role'],
            "status": u['status'],
            "created_at": u['createdAt']
        })

# Adapt projects
adapted_projects = []
for p in table_data_store.get('projects', []):
    adapted_projects.append({
        "id": p.get('id'),
        "organizationId": p.get('organization_id'),
        "organizationName": p.get('organization_name') or 'University Partner',
        "title": p.get('title'),
        "description": p.get('description'),
        "domain": p.get('field_domain') or 'Academic Research',
        "location": p.get('location') or 'Algiers, Algeria',
        "status": p.get('status') or 'submitted',
        "skillsRequired": p.get('required_skills') if isinstance(p.get('required_skills'), list) else ['Research'],
        "createdAt": p.get('created_at') or '2026-08-01T08:00:00Z'
    })

# Adapt matches
adapted_matches = []
for m in table_data_store.get('matches', []):
    adapted_matches.append({
        "id": m.get('id'),
        "projectId": m.get('project_id'),
        "expertId": m.get('expert_id'),
        "compatibilityScore": float(m.get('compatibility_score', 95.0)),
        "status": m.get('status', 'pending'),
        "createdAt": m.get('created_at') or '2026-08-01T08:00:00Z'
    })

# Adapt collaborations
adapted_collaborations = []
for c in table_data_store.get('collaborations', []):
    adapted_collaborations.append({
        "id": c.get('id'),
        "projectId": c.get('project_id'),
        "expertId": c.get('expert_id'),
        "organizationId": c.get('organization_id'),
        "status": c.get('status', 'active'),
        "confirmedAt": c.get('confirmed_at'),
        "completedAt": c.get('completed_at'),
        "notes": c.get('notes', '')
    })

# Adapt custom KPIs
adapted_kpis = table_data_store.get('custom_kpis', [])

# Adapt audit logs
adapted_audit = []
for a in table_data_store.get('activity_logs', []):
    adapted_audit.append({
        "id": a.get('id'),
        "userId": a.get('user_id'),
        "userName": a.get('user_id'),
        "actionType": a.get('action_type', 'ACTION'),
        "entityType": a.get('entity_type', 'record'),
        "entityId": a.get('entity_id', ''),
        "ipAddress": a.get('ip_address', '127.0.0.1'),
        "createdAt": a.get('created_at') or '2026-08-01T08:00:00Z',
        "metadata": a.get('metadata')
    })
if existing_db.get('audit_logs'):
    adapted_audit.extend(existing_db['audit_logs'])

# Construct full DB
updated_db = {
    "users": adapted_users,
    "projects": adapted_projects,
    "matches": adapted_matches,
    "collaborations": adapted_collaborations,
    "expert_availabilities": table_data_store.get('expert_availabilities', []),
    "ratings": table_data_store.get('ratings', []),
    "audit_logs": adapted_audit,
    "custom_kpis": adapted_kpis,
    "schema_tables": schema_tables,
    "schema_relations": schema_relations,
    "table_data_store": table_data_store,
    "dropped_tables": [],
    "translations": existing_db.get('translations', {})
}

with open('data/db.json', 'w', encoding='utf-8') as f:
    json.dump(updated_db, f, indent=2, ensure_ascii=False)

print(f"data/db.json successfully written with {len(schema_tables)} tables, {len(schema_relations)} relations, and full data store!")
