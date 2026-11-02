-- ==============================================================================
-- DZ-BRIDGE: COMPREHENSIVE POSTGRESQL 16 DATABASE DUMP
-- Platform for Algerian Scholar Award & Diaspora Knowledge Transfer
-- Export Date: 2026-10-13T16:36:10.545Z
-- Total Tables: 29
-- Total Relations: 75
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. ENUM TYPES
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('expert', 'organization', 'admin');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_status') THEN
        CREATE TYPE user_status AS ENUM ('pending_verification', 'active', 'suspended', 'deactivated');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'project_status') THEN
        CREATE TYPE project_status AS ENUM ('draft', 'submitted', 'under_review', 'matched', 'contact_initiated', 'confirmed', 'in_progress', 'completed', 'cancelled', 'unsuccessful');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'match_status') THEN
        CREATE TYPE match_status AS ENUM ('pending', 'accepted', 'rejected', 'expired');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'collaboration_status') THEN
        CREATE TYPE collaboration_status AS ENUM ('pending', 'active', 'completed', 'cancelled');
    END IF;
END $$;

-- ==============================================================================
-- 3. TABLE SCHEMAS (DDL)
-- ==============================================================================

-- Table: users (Identity)
-- Description: System authentication credentials, roles, and status for experts, academic institutions, and MESRS admins
CREATE TABLE IF NOT EXISTS "users" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "email" VARCHAR(255) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "role" user_role ENUM NOT NULL,
    "status" user_status ENUM DEFAULT 'pending_verification',
    "email_verification_token" VARCHAR(255),
    "email_verified_at" TIMESTAMP WITH TIME ZONE,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: profiles (Identity)
-- Description: Polymorphic profile details, multi-select expertise tags, profile completeness %, and collaboration preferences
CREATE TABLE IF NOT EXISTS "profiles" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID,
    "full_name" VARCHAR(255) NOT NULL,
    "organization_name" VARCHAR(255),
    "organization_type" VARCHAR(100),
    "bio" TEXT,
    "phone_number" VARCHAR(50),
    "country" VARCHAR(100) DEFAULT 'Algeria',
    "city" VARCHAR(100),
    "is_diaspora" BOOLEAN DEFAULT FALSE,
    "expertise_tags" TEXT[] DEFAULT '{}',
    "collaboration_preferences" JSONB DEFAULT '{"remote_ok": true, "in_person_ok": true}'::jsonb,
    "profile_completeness_percentage" INT DEFAULT 85,
    "is_verified" BOOLEAN DEFAULT FALSE,
    "documents" JSONB DEFAULT '[]'::jsonb,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: experts (Identity)
-- Description: Dedicated registry of verified scientific experts and diaspora laureates with h-index, academic titles, research domains, citations, and credentials
CREATE TABLE IF NOT EXISTS "experts" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID,
    "full_name" VARCHAR(255) NOT NULL,
    "academic_title" VARCHAR(100) NOT NULL,
    "highest_degree" VARCHAR(100) NOT NULL,
    "current_affiliation" VARCHAR(255) NOT NULL,
    "country" VARCHAR(100) DEFAULT 'France',
    "city" VARCHAR(100),
    "is_diaspora" BOOLEAN DEFAULT TRUE,
    "primary_domain" VARCHAR(150) NOT NULL,
    "skills" TEXT[] DEFAULT '{}',
    "h_index" INT DEFAULT 18,
    "citations_count" INT DEFAULT 1200,
    "publications_count" INT DEFAULT 30,
    "bio" TEXT,
    "google_scholar_url" VARCHAR(255),
    "orcid_id" VARCHAR(50),
    "verification_status" VARCHAR(50) DEFAULT 'verified',
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: institutions (Academic)
-- Description: Unified general registry of partner institutions (Universities, National Higher Schools, Research Centers EPST, Enterprises, and Public Directorates)
CREATE TABLE IF NOT EXISTS "institutions" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID,
    "code" VARCHAR(50) NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "acronym" VARCHAR(50) NOT NULL,
    "institution_type" VARCHAR(80) DEFAULT 'university',
    "sector" VARCHAR(80) DEFAULT 'public',
    "wilaya" VARCHAR(100) NOT NULL,
    "country" VARCHAR(100) DEFAULT 'Algeria',
    "rector_or_director" VARCHAR(255),
    "contact_email" VARCHAR(255) NOT NULL,
    "website" VARCHAR(255),
    "total_doctoral_students" INT DEFAULT 0,
    "is_verified" BOOLEAN DEFAULT TRUE,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: research_laboratories (Academic)
-- Description: Accredited university research laboratories and doctoral school research units hosting diaspora missions
CREATE TABLE IF NOT EXISTS "research_laboratories" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "institution_id" UUID,
    "director_user_id" UUID,
    "code" VARCHAR(50) NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "acronym" VARCHAR(50) NOT NULL,
    "scientific_domain" VARCHAR(150) NOT NULL,
    "doctoral_school_name" VARCHAR(255),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: expert_availabilities (Matchmaking)
-- Description: Physical Algeria visit availability windows for diaspora and traveling scholars
CREATE TABLE IF NOT EXISTS "expert_availabilities" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "expert_id" UUID,
    "city" VARCHAR(100) NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE NOT NULL,
    "duration_days" INT,
    "notes" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: matching_algorithms (Matchmaking)
-- Description: Deterministic 4-factor matchmaking models, weighting matrices, and compatibility thresholds
CREATE TABLE IF NOT EXISTS "matching_algorithms" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "name" VARCHAR(150) NOT NULL,
    "version" VARCHAR(50) DEFAULT 'v2.6-prod',
    "description" TEXT,
    "skills_weight" DECIMAL(5,2) DEFAULT 45.00,
    "availability_weight" DECIMAL(5,2) DEFAULT 25.00,
    "location_weight" DECIMAL(5,2) DEFAULT 15.00,
    "diaspora_bonus_weight" DECIMAL(5,2) DEFAULT 15.00,
    "min_compatibility_threshold" DECIMAL(5,2) DEFAULT 65.00,
    "is_active" BOOLEAN DEFAULT TRUE,
    "created_by_user_id" UUID,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: matching_criteria_weights (Matchmaking)
-- Description: Granular mathematical parameters and sub-factor weights configuring the deterministic matching algorithm
CREATE TABLE IF NOT EXISTS "matching_criteria_weights" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "algorithm_id" UUID,
    "criterion_code" VARCHAR(50) NOT NULL,
    "criterion_name" VARCHAR(150) NOT NULL,
    "weight_percentage" DECIMAL(5,2) NOT NULL,
    "is_mandatory" BOOLEAN DEFAULT FALSE,
    "minimum_score_required" DECIMAL(5,2) DEFAULT 0.00,
    "notes" TEXT
);

-- Table: matching_runs (Matchmaking)
-- Description: Execution batches and automated algorithm runs scanning projects against expert profiles
CREATE TABLE IF NOT EXISTS "matching_runs" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "algorithm_id" UUID,
    "project_id" UUID,
    "initiated_by_user_id" UUID,
    "candidates_evaluated" INT DEFAULT 0,
    "matches_generated" INT DEFAULT 0,
    "avg_compatibility_score" DECIMAL(5,2) DEFAULT 0.00,
    "execution_time_ms" INT DEFAULT 120,
    "status" VARCHAR(50) DEFAULT 'completed',
    "ran_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: projects (Matchmaking)
-- Description: Collaboration initiatives and doctoral school projects submitted by Algerian universities (Strict 10-phase lifecycle)
CREATE TABLE IF NOT EXISTS "projects" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "organization_id" UUID,
    "institution_id" UUID,
    "laboratory_id" UUID,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT NOT NULL,
    "skills_required" TEXT[] DEFAULT '{}',
    "location" VARCHAR(100) NOT NULL,
    "start_date" DATE,
    "end_date" DATE,
    "logistics_offered" JSONB DEFAULT '{"travel": false, "lodging": false}'::jsonb,
    "budget_details" JSONB DEFAULT '{}'::jsonb,
    "status" project_status ENUM DEFAULT 'draft',
    "success_level" VARCHAR(80),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: matches (Matchmaking)
-- Description: Multi-factor compatibility pairings generated between university projects and diaspora fellows
CREATE TABLE IF NOT EXISTS "matches" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "project_id" UUID,
    "expert_id" UUID,
    "algorithm_id" UUID,
    "matching_run_id" UUID,
    "compatibility_score" DECIMAL(5,2) NOT NULL,
    "score_breakdown" JSONB DEFAULT '{}'::jsonb,
    "status" match_status ENUM DEFAULT 'pending',
    "notified_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "responded_at" TIMESTAMP WITH TIME ZONE,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: match_evaluations (Matchmaking)
-- Description: Scientific precision audits, academic committee evaluations, and ranking quality metrics (Precision@K, NDCG)
CREATE TABLE IF NOT EXISTS "match_evaluations" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "match_id" UUID NOT NULL,
    "algorithm_id" UUID NOT NULL,
    "matching_run_id" UUID,
    "evaluator_user_id" UUID,
    "skills_alignment_score" DECIMAL(5,2) NOT NULL,
    "availability_sync_score" DECIMAL(5,2) NOT NULL,
    "location_affinity_score" DECIMAL(5,2) NOT NULL,
    "diaspora_priority_score" DECIMAL(5,2) NOT NULL,
    "composite_score" DECIMAL(5,2) NOT NULL,
    "precision_metric" DECIMAL(5,2) DEFAULT 97.50,
    "recall_metric" DECIMAL(5,2) DEFAULT 94.20,
    "f1_score" DECIMAL(5,2) DEFAULT 95.80,
    "committee_verification_notes" TEXT,
    "is_verified_by_committee" BOOLEAN DEFAULT TRUE,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: conversations (Communications)
-- Description: Secure communication channel established between an expert and organization following mutual match acceptance
CREATE TABLE IF NOT EXISTS "conversations" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "project_id" UUID,
    "expert_id" UUID,
    "organization_id" UUID,
    "match_id" UUID,
    "status" VARCHAR(50) DEFAULT 'active',
    "preferred_contact_slot" VARCHAR(150),
    "last_message_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: messages (Communications)
-- Description: Encrypted communication messages exchanged between matched parties for mission scheduling and terms coordination
CREATE TABLE IF NOT EXISTS "messages" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "conversation_id" UUID,
    "sender_id" UUID,
    "recipient_id" UUID,
    "body" TEXT NOT NULL,
    "attachments" JSONB DEFAULT '[]'::jsonb,
    "is_read" BOOLEAN DEFAULT FALSE,
    "sent_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: collaborations (Collaborations)
-- Description: Official confirmed bilateral partnerships between Algerian universities and diaspora scholars
CREATE TABLE IF NOT EXISTS "collaborations" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "project_id" UUID,
    "expert_id" UUID,
    "organization_id" UUID,
    "institution_id" UUID,
    "status" collaboration_status ENUM DEFAULT 'pending',
    "completion_flag" BOOLEAN DEFAULT FALSE,
    "confirmed_at" TIMESTAMP WITH TIME ZONE,
    "completed_at" TIMESTAMP WITH TIME ZONE,
    "notes" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: collaboration_milestones (Collaborations)
-- Description: Structured deliverables, doctoral seminars, and on-site mission phases in Algeria
CREATE TABLE IF NOT EXISTS "collaboration_milestones" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "collaboration_id" UUID,
    "assigned_expert_id" UUID,
    "title" VARCHAR(255) NOT NULL,
    "phase_number" INT DEFAULT 1,
    "target_completion_date" DATE NOT NULL,
    "completed_at" TIMESTAMP WITH TIME ZONE,
    "status" VARCHAR(50) DEFAULT 'pending',
    "deliverable_description" TEXT,
    "verified_by_user_id" UUID,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: publications_patents (Collaborations)
-- Description: Intellectual property, co-authored peer-reviewed research papers, and patent filings co-produced with diaspora scholars
CREATE TABLE IF NOT EXISTS "publications_patents" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "expert_id" UUID,
    "collaboration_id" UUID,
    "institution_id" UUID,
    "title" VARCHAR(255) NOT NULL,
    "type" VARCHAR(80) DEFAULT 'patent',
    "patent_or_doi_number" VARCHAR(150) NOT NULL,
    "publisher_or_patent_office" VARCHAR(150) NOT NULL,
    "year" INT DEFAULT 2026,
    "citations_count" INT DEFAULT 0,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: event_promotions (Collaborations)
-- Description: University events, academic workshops, and keynote seminars promoted on DZ-Bridge and linked to collaborations
CREATE TABLE IF NOT EXISTS "event_promotions" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "organization_id" UUID,
    "collaboration_id" UUID,
    "project_id" UUID,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT NOT NULL,
    "event_type" VARCHAR(80) DEFAULT 'doctoral_seminar',
    "location_city" VARCHAR(100) NOT NULL,
    "venue_address" VARCHAR(255) NOT NULL,
    "event_date" DATE NOT NULL,
    "materials_urls" JSONB DEFAULT '[]'::jsonb,
    "status" VARCHAR(50) DEFAULT 'pending_approval',
    "approved_by_admin_id" UUID,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: surveys (Feedback)
-- Description: Configurable survey questionnaires triggered at key platform milestones (post-registration, match, completion)
CREATE TABLE IF NOT EXISTS "surveys" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "title" VARCHAR(255) NOT NULL,
    "survey_type" VARCHAR(80) DEFAULT 'collaboration_experience',
    "target_role" VARCHAR(50) DEFAULT 'all',
    "trigger_event" VARCHAR(80) DEFAULT 'after_collaboration_completion',
    "questions" JSONB NOT NULL,
    "is_active" BOOLEAN DEFAULT TRUE,
    "created_by_user_id" UUID,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: survey_responses (Feedback)
-- Description: Submitted feedback answers, satisfaction scores (1-5), and Net Promoter Scores (NPS) for platform governance
CREATE TABLE IF NOT EXISTS "survey_responses" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "survey_id" UUID,
    "user_id" UUID,
    "project_id" UUID,
    "collaboration_id" UUID,
    "responses" JSONB NOT NULL,
    "rating" INT NOT NULL,
    "nps_score" INT,
    "comments" TEXT,
    "submitted_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: ratings (Feedback)
-- Description: Confidential 1-5 scale mutual feedback across categories (communication, professionalism, value, punctuality)
CREATE TABLE IF NOT EXISTS "ratings" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "collaboration_id" UUID,
    "project_id" UUID,
    "from_user_id" UUID,
    "to_user_id" UUID,
    "overall_score" INT NOT NULL,
    "category_scores" JSONB NOT NULL,
    "comment" TEXT,
    "recommendation_for_future" BOOLEAN DEFAULT TRUE,
    "is_private_admin_only" BOOLEAN DEFAULT TRUE,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: issue_flags (Feedback)
-- Description: Dispute moderation, low-satisfaction alerts, and reported complaints requiring administrator intervention
CREATE TABLE IF NOT EXISTS "issue_flags" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "reporter_user_id" UUID,
    "reported_user_id" UUID,
    "project_id" UUID,
    "collaboration_id" UUID,
    "category" VARCHAR(100) NOT NULL,
    "description" TEXT NOT NULL,
    "severity" VARCHAR(50) DEFAULT 'medium',
    "status" VARCHAR(50) DEFAULT 'open',
    "admin_resolution_notes" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: custom_kpis (Audit)
-- Description: Dynamic platform KPIs configured by MESRS administrators with target thresholds, algorithm links, and front-end visualization modes
CREATE TABLE IF NOT EXISTS "custom_kpis" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "name" VARCHAR(150) NOT NULL,
    "description" TEXT,
    "category" VARCHAR(100) DEFAULT 'National Impact',
    "current_value" VARCHAR(50) NOT NULL,
    "target_value" VARCHAR(50) NOT NULL,
    "unit" VARCHAR(30) DEFAULT '',
    "progress_percentage" INT DEFAULT 80,
    "status" VARCHAR(50) DEFAULT 'on_track',
    "visualization_type" VARCHAR(50) DEFAULT 'progress',
    "display_on_landing" BOOLEAN DEFAULT TRUE,
    "created_by_user_id" UUID,
    "target_algorithm_id" UUID,
    "target_institution_id" UUID,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: kpi_evaluations (Audit)
-- Description: Periodic audit assessments and performance checkpoint evaluations measuring strategic KPI targets
CREATE TABLE IF NOT EXISTS "kpi_evaluations" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "kpi_id" UUID NOT NULL,
    "evaluated_by_user_id" UUID,
    "institution_id" UUID,
    "recorded_value" VARCHAR(50) NOT NULL,
    "target_value" VARCHAR(50) NOT NULL,
    "delta_percentage" DECIMAL(5,2) DEFAULT 0.00,
    "compliance_status" VARCHAR(50) DEFAULT 'compliant',
    "evaluation_notes" TEXT,
    "evaluated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: kpi_institution_targets (Audit)
-- Description: Institutional allocation of national KPI quotas per university and research centre
CREATE TABLE IF NOT EXISTS "kpi_institution_targets" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "kpi_id" UUID,
    "institution_id" UUID,
    "assigned_target_value" VARCHAR(50) NOT NULL,
    "achieved_value" VARCHAR(50) NOT NULL,
    "compliance_rate" DECIMAL(5,2) DEFAULT 90.00,
    "last_updated" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: analytics_snapshots (Audit)
-- Description: Automated platform health and conversion funnel snapshots aggregated for executive reporting (Explicit in Specs)
CREATE TABLE IF NOT EXISTS "analytics_snapshots" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "snapshot_date" DATE NOT NULL,
    "period_type" VARCHAR(50) DEFAULT 'monthly',
    "total_registered_experts" INT DEFAULT 0,
    "total_registered_organizations" INT DEFAULT 0,
    "total_projects_submitted" INT DEFAULT 0,
    "total_matches_generated" INT DEFAULT 0,
    "total_collaborations_confirmed" INT DEFAULT 0,
    "total_collaborations_completed" INT DEFAULT 0,
    "avg_time_to_match_days" DECIMAL(5,2) DEFAULT 1.80,
    "collaboration_success_rate" DECIMAL(5,2) DEFAULT 92.50,
    "user_satisfaction_avg_score" DECIMAL(3,2) DEFAULT 4.85,
    "metrics_payload" JSONB DEFAULT '{}'::jsonb,
    "generated_by_user_id" UUID,
    "institution_id" UUID,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: project_status_histories (Audit)
-- Description: Audit trail for project state machine transitions from draft to confirmed and completed
CREATE TABLE IF NOT EXISTS "project_status_histories" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "project_id" UUID,
    "previous_status" project_status ENUM,
    "new_status" project_status ENUM NOT NULL,
    "changed_by_user_id" UUID,
    "notes" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: activity_logs (Audit)
-- Description: Immutable system-wide audit trail with cross-table linkages to actors, projects, and collaborations
CREATE TABLE IF NOT EXISTS "activity_logs" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID,
    "project_id" UUID,
    "collaboration_id" UUID,
    "user_role" user_role ENUM,
    "action_type" VARCHAR(100) NOT NULL,
    "entity_type" VARCHAR(100),
    "entity_id" UUID,
    "status_before" VARCHAR(100),
    "status_after" VARCHAR(100),
    "ip_address" VARCHAR(45),
    "metadata" JSONB DEFAULT '{}'::jsonb,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: notifications (Audit)
-- Description: System alert routing and messaging linked directly to users, match proposals, and projects
CREATE TABLE IF NOT EXISTS "notifications" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID,
    "match_id" UUID,
    "project_id" UUID,
    "collaboration_id" UUID,
    "type" VARCHAR(80) NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "message" TEXT NOT NULL,
    "is_read" BOOLEAN DEFAULT FALSE,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 4. TABLE DATA (DML INSERT STATEMENTS)
-- ==============================================================================

-- Data for Table "users" (11 rows)
INSERT INTO "users" ("id", "email", "password_hash", "role", "status", "email_verification_token", "email_verified_at", "created_at", "updated_at")
VALUES ('admin-000', 'dzsoft.contact@gmail.com', NULL, 'admin', 'active', NULL, NULL, '2026-08-01T08:00:00Z', NULL)
ON CONFLICT DO NOTHING;
INSERT INTO "users" ("id", "email", "password_hash", "role", "status", "email_verification_token", "email_verified_at", "created_at", "updated_at")
VALUES ('usr-haba-1001', 'belgacem.haba@algerian-scholars.dz', NULL, 'expert', 'active', NULL, NULL, '2026-08-01T08:00:00Z', NULL)
ON CONFLICT DO NOTHING;
INSERT INTO "users" ("id", "email", "password_hash", "role", "status", "email_verification_token", "email_verified_at", "created_at", "updated_at")
VALUES ('usr-benali-1002', 'amina.benali@cnrs.fr', NULL, 'expert', 'active', NULL, NULL, '2026-08-01T08:00:00Z', NULL)
ON CONFLICT DO NOTHING;
INSERT INTO "users" ("id", "email", "password_hash", "role", "status", "email_verification_token", "email_verified_at", "created_at", "updated_at")
VALUES ('usr-mansouri-1003', 'karim.mansouri@tum.de', NULL, 'expert', 'active', NULL, NULL, '2026-08-01T08:00:00Z', NULL)
ON CONFLICT DO NOTHING;
INSERT INTO "users" ("id", "email", "password_hash", "role", "status", "email_verification_token", "email_verified_at", "created_at", "updated_at")
VALUES ('usr-belkacem-1004', 'tarek.belkacem@usthb.dz', NULL, 'expert', 'active', NULL, NULL, '2026-08-01T08:00:00Z', NULL)
ON CONFLICT DO NOTHING;
INSERT INTO "users" ("id", "email", "password_hash", "role", "status", "email_verification_token", "email_verified_at", "created_at", "updated_at")
VALUES ('usr-esi-2001', 'direction@esi.dz', NULL, 'organization', 'active', NULL, NULL, '2026-08-01T08:00:00Z', NULL)
ON CONFLICT DO NOTHING;
INSERT INTO "users" ("id", "email", "password_hash", "role", "status", "email_verification_token", "email_verified_at", "created_at", "updated_at")
VALUES ('usr-usthb-2002', 'rectorat@usthb.dz', NULL, 'organization', 'active', NULL, NULL, '2026-08-01T08:00:00Z', NULL)
ON CONFLICT DO NOTHING;
INSERT INTO "users" ("id", "email", "password_hash", "role", "status", "email_verification_token", "email_verified_at", "created_at", "updated_at")
VALUES ('usr-oran1-2003', 'contact@univ-oran1.dz', NULL, 'organization', 'active', NULL, NULL, '2026-08-01T08:00:00Z', NULL)
ON CONFLICT DO NOTHING;
INSERT INTO "users" ("id", "email", "password_hash", "role", "status", "email_verification_token", "email_verified_at", "created_at", "updated_at")
VALUES ('usr-const1-2004', 'rectorat@umc.edu.dz', NULL, 'organization', 'active', NULL, NULL, '2026-08-01T08:00:00Z', NULL)
ON CONFLICT DO NOTHING;
INSERT INTO "users" ("id", "email", "password_hash", "role", "status", "email_verification_token", "email_verified_at", "created_at", "updated_at")
VALUES ('usr-crti-2005', 'contact@crti.dz', NULL, 'organization', 'active', NULL, NULL, '2026-08-01T08:00:00Z', NULL)
ON CONFLICT DO NOTHING;
INSERT INTO "users" ("id", "email", "password_hash", "role", "status", "email_verification_token", "email_verified_at", "created_at", "updated_at")
VALUES ('usr-sonatrach-2006', 'rd@sonatrach.dz', NULL, 'organization', 'active', NULL, NULL, '2026-08-01T08:00:00Z', NULL)
ON CONFLICT DO NOTHING;

-- Data for Table "profiles" (5 rows)
INSERT INTO "profiles" ("id", "user_id", "full_name", "organization_name", "organization_type", "bio", "phone_number", "country", "city", "is_diaspora", "expertise_tags", "collaboration_preferences", "profile_completeness_percentage", "is_verified", "documents", "created_at")
VALUES ('prof-admin-000', 'admin-000', 'DEGHA HOUSSEM EDDINE', 'MESRS - Ministère de l''Enseignement Supérieur', 'Government / Ministry', 'Lead System Architect & National Platform Administrator (MESRS Governance)', '+213 550 12 34 56', 'Algeria', 'Algiers', FALSE, '{"Platform Architecture","PostgreSQL Schema","REST API","Governance"}', '{"National Academic Strategic Alignment"}', NULL, NULL, '{}', '2026-08-01T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "profiles" ("id", "user_id", "full_name", "organization_name", "organization_type", "bio", "phone_number", "country", "city", "is_diaspora", "expertise_tags", "collaboration_preferences", "profile_completeness_percentage", "is_verified", "documents", "created_at")
VALUES ('prof-haba-1', 'usr-haba-1001', 'Prof. Belgacem Haba', 'Adeia Inc.', 'enterprise', 'Prolific Algerian inventor with over 500 issued US patents in semiconductor packaging, miniaturization, and AI hardware acceleration. Active mentor to Algerian doctoral researchers.', '+1 (408) 555-0199', 'United States', 'San Jose, CA', TRUE, '{"Semiconductors","Microchip Packaging","Hardware Architecture","Deep Learning Acceleration","Nanotechnology"}', '{"remote_ok":true,"in_person_ok":true,"travel_stipend_required":false,"lodging_required":false,"honorarium_expected":false,"custom_terms":"Voluntary academic contribution for Algerian university doctoral schools and thesis jury panels."}'::jsonb, NULL, NULL, '{"[object Object]"}', '2026-08-01T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "profiles" ("id", "user_id", "full_name", "organization_name", "organization_type", "bio", "phone_number", "country", "city", "is_diaspora", "expertise_tags", "collaboration_preferences", "profile_completeness_percentage", "is_verified", "documents", "created_at")
VALUES ('prof-benali-2', 'usr-benali-1002', 'Dr. Amina Benali', 'CNRS Laboratoire d Informatique', 'research_institute', 'Leading researcher in natural language processing, multilingual foundation models, Arabic dialectal NLP, and medical diagnosis assistance.', '+33 6 12 34 56 78', 'France', 'Paris', TRUE, '{"Natural Language Processing","Arabic LLMs","Deep Learning","Biomedical AI","Curriculum Design"}', '{"remote_ok":true,"in_person_ok":true,"travel_stipend_required":true,"lodging_required":true,"honorarium_expected":false,"custom_terms":"Available for intensive autumn and winter school doctoral workshops in Algeria."}'::jsonb, NULL, NULL, '{"[object Object]"}', '2026-08-01T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "profiles" ("id", "user_id", "full_name", "organization_name", "organization_type", "bio", "phone_number", "country", "city", "is_diaspora", "expertise_tags", "collaboration_preferences", "profile_completeness_percentage", "is_verified", "documents", "created_at")
VALUES ('prof-mansouri-3', 'usr-mansouri-1003', 'Dr. Karim Mansouri', 'TUM Department of Energy', 'public_university', 'Specialist in Saharan solar photovoltaics, green hydrogen production through water electrolysis, and arid microgrid resilience.', '+49 176 98765432', 'Germany', 'Munich', TRUE, '{"Green Hydrogen","Solar Photovoltaics","Microgrids","Renewable Energy","Thermal Storage"}', '{"remote_ok":true,"in_person_ok":true,"travel_stipend_required":true,"lodging_required":true}'::jsonb, NULL, NULL, '{"[object Object]"}', '2026-08-01T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "profiles" ("id", "user_id", "full_name", "organization_name", "organization_type", "bio", "phone_number", "country", "city", "is_diaspora", "expertise_tags", "collaboration_preferences", "profile_completeness_percentage", "is_verified", "documents", "created_at")
VALUES ('prof-belkacem-4', 'usr-belkacem-1004', 'Prof. Tarek Belkacem', 'USTHB Laboratoire de Cyberscurit', 'public_university', 'Head of Network Security and Cryptographic Systems Laboratory at USTHB Bab Ezzouar. Experienced academic lead on national academic cloud infrastructure.', '+213 550 11 22 33', 'Algeria', 'Algiers', FALSE, '{"Cybersecurity","Cloud Computing","Network Security","Cryptography","Zero-Trust Architecture"}', '{"remote_ok":true,"in_person_ok":true,"travel_stipend_required":false}'::jsonb, NULL, NULL, NULL, '2026-08-01T08:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "experts" (3 rows)
INSERT INTO "experts" ("id", "user_id", "full_name", "academic_title", "highest_degree", "current_affiliation", "country", "city", "is_diaspora", "primary_domain", "skills", "h_index", "citations_count", "publications_count", "bio", "google_scholar_url", "orcid_id", "verification_status", "created_at")
VALUES ('exp-001', 'usr-haba-1001', 'Prof. Belgacem Haba', 'Pioneer Fellow & Microelectronics Laureate', 'PhD in Materials Science & Solar Energy (Stanford University)', 'Adeia / Silicon Valley (500+ US Patents)', 'United States', 'San Jose, CA', TRUE, 'Semiconductors & AI Hardware Acceleration', '{"Semiconductors","Microchip Packaging","Hardware Architecture","Deep Learning Acceleration","Nanotechnology"}', 58, 12450, 210, 'Prolific Algerian inventor with over 500 issued US patents in semiconductor packaging, miniaturization, and AI hardware acceleration. Active mentor to Algerian doctoral researchers.', 'https://scholar.google.com/citations?user=haba_belgacem', '0000-0002-1825-0097', 'verified', '2026-08-01T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "experts" ("id", "user_id", "full_name", "academic_title", "highest_degree", "current_affiliation", "country", "city", "is_diaspora", "primary_domain", "skills", "h_index", "citations_count", "publications_count", "bio", "google_scholar_url", "orcid_id", "verification_status", "created_at")
VALUES ('exp-002', 'usr-benali-1002', 'Dr. Amina Benali', 'Senior Research Scientist & NLP Lab Lead', 'PhD in Computer Science (Paris-Saclay / CNRS)', 'CNRS Paris-Saclay & Hugging Face Contributor', 'France', 'Paris', TRUE, 'Artificial Intelligence & Arabic Dialect NLP', '{"Natural Language Processing","Deep Learning","PyTorch","Transformer Architectures","Arabic Dialect Models","LLM Alignment"}', 28, 4120, 46, 'Leading researcher in multilingual large language models with specialized benchmarks for North African Arabic dialects (Darija/Algérien). Co-organizer of ArabicNLP workshops at ACL.', 'https://scholar.google.com/citations?user=benali_amina', '0000-0003-4921-8812', 'verified', '2026-08-02T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "experts" ("id", "user_id", "full_name", "academic_title", "highest_degree", "current_affiliation", "country", "city", "is_diaspora", "primary_domain", "skills", "h_index", "citations_count", "publications_count", "bio", "google_scholar_url", "orcid_id", "verification_status", "created_at")
VALUES ('exp-003', 'usr-mansouri-1003', 'Dr. Karim Mansouri', 'Associate Professor & Energy Systems Lead', 'Doctor of Engineering (Technical University of Munich)', 'TUM Department of Energy', 'Germany', 'Munich', TRUE, 'Green Hydrogen & Saharan Solar Photovoltaics', '{"Green Hydrogen","Solar Photovoltaics","Microgrids","Renewable Energy","Thermal Storage","Electrolysis"}', 22, 2980, 38, 'Specialist in Saharan solar photovoltaics, green hydrogen production through water electrolysis, and arid microgrid resilience.', 'https://scholar.google.com/citations?user=mansouri_karim', '0000-0001-9043-5571', 'verified', '2026-08-03T08:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "institutions" (6 rows)
INSERT INTO "institutions" ("id", "user_id", "code", "name", "acronym", "institution_type", "sector", "wilaya", "country", "rector_or_director", "contact_email", "website", "total_doctoral_students", "is_verified", "created_at")
VALUES ('inst-esi', 'usr-esi-2001', 'ESI-ALGIERS', 'École Nationale Supérieure d''Informatique (ESI)', 'ESI Algiers', 'national_school', 'public', 'Algiers (Oued Smar)', 'Algeria', 'Prof. Mouloud Koudil', 'direction@esi.dz', 'https://www.esi.dz', 340, TRUE, '2026-08-01T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "institutions" ("id", "user_id", "code", "name", "acronym", "institution_type", "sector", "wilaya", "country", "rector_or_director", "contact_email", "website", "total_doctoral_students", "is_verified", "created_at")
VALUES ('inst-usthb', 'usr-usthb-2002', 'USTHB-ALGIERS', 'Université des Sciences et de la Technologie Houari Boumediene', 'USTHB Bab Ezzouar', 'university', 'public', 'Algiers (Bab Ezzouar)', 'Algeria', 'Prof. Djamal-Eddine Akretche', 'rectorat@usthb.dz', 'https://www.usthb.dz', 1450, TRUE, '2026-08-02T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "institutions" ("id", "user_id", "code", "name", "acronym", "institution_type", "sector", "wilaya", "country", "rector_or_director", "contact_email", "website", "total_doctoral_students", "is_verified", "created_at")
VALUES ('inst-oran1', 'usr-oran1-2003', 'UNIV-ORAN1', 'Université d''Oran 1 Ahmed Ben Bella', 'Univ Oran 1', 'university', 'public', 'Oran (Es-Sénia)', 'Algeria', 'Prof. Abdelbaki Benziane', 'contact@univ-oran1.dz', 'https://www.univ-oran1.dz', 890, TRUE, '2026-08-05T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "institutions" ("id", "user_id", "code", "name", "acronym", "institution_type", "sector", "wilaya", "country", "rector_or_director", "contact_email", "website", "total_doctoral_students", "is_verified", "created_at")
VALUES ('inst-const1', 'usr-const1-2004', 'UNIV-CONST1', 'Université Constantine 1 Frères Mentouri', 'Univ Constantine 1', 'university', 'public', 'Constantine (Zouaghi)', 'Algeria', 'Prof. Bouras Ahmed', 'rectorat@umc.edu.dz', 'https://www.umc.edu.dz', 1120, TRUE, '2026-08-06T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "institutions" ("id", "user_id", "code", "name", "acronym", "institution_type", "sector", "wilaya", "country", "rector_or_director", "contact_email", "website", "total_doctoral_students", "is_verified", "created_at")
VALUES ('inst-crti', 'usr-crti-2005', 'EPST-CRTI', 'Centre de Recherche en Technologies Industrielles (CRTI)', 'CRTI Chéraga', 'research_center', 'public', 'Algiers (Chéraga)', 'Algeria', 'Dr. Mustapha Yahi', 'contact@crti.dz', 'https://www.crti.dz', 180, TRUE, '2026-08-10T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "institutions" ("id", "user_id", "code", "name", "acronym", "institution_type", "sector", "wilaya", "country", "rector_or_director", "contact_email", "website", "total_doctoral_students", "is_verified", "created_at")
VALUES ('inst-sonatrach-rd', 'usr-sonatrach-2006', 'SONATRACH-IAP', 'Institut Algérien du Pétrole & Division R&D Sonatrach', 'Sonatrach R&D / IAP', 'enterprise', 'public', 'Boumerdès', 'Algeria', 'Dr. Abdelkader Benmessaoud', 'rd@sonatrach.dz', 'https://iap.sonatrach.dz', 95, TRUE, '2026-08-12T08:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "research_laboratories" (3 rows)
INSERT INTO "research_laboratories" ("id", "institution_id", "director_user_id", "code", "name", "acronym", "scientific_domain", "doctoral_school_name", "created_at")
VALUES ('lab-lsi', 'inst-esi', 'usr-esi-2001', 'LAB-LSI-01', 'Laboratoire des Systèmes Informatiques (LSI)', 'LSI', 'Artificial Intelligence, Distributed Systems & Big Data', 'École Doctorale en Informatique & IA de Haut Niveau', '2026-08-15T09:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "research_laboratories" ("id", "institution_id", "director_user_id", "code", "name", "acronym", "scientific_domain", "doctoral_school_name", "created_at")
VALUES ('lab-lrea', 'inst-usthb', 'usr-usthb-2002', 'LAB-LREA-02', 'Laboratoire de Robotique, Parallélisme et Systèmes Embarqués', 'LREA', 'Embedded AI, Semiconductor Accelerators & Robotics', 'École Doctorale en Électronique & Microélectronique', '2026-08-16T09:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "research_laboratories" ("id", "institution_id", "director_user_id", "code", "name", "acronym", "scientific_domain", "doctoral_school_name", "created_at")
VALUES ('lab-semi', 'inst-crti', 'usr-crti-2005', 'LAB-CRTI-MAT', 'Unité de Recherche en Matériaux Avancés et Microélectronique', 'URMA-CRTI', 'Advanced Packaging, Thin Films & Nanotechnologies', 'Pôle Doctoral Inter-Centres MESRS', '2026-08-20T10:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "expert_availabilities" (4 rows)
INSERT INTO "expert_availabilities" ("id", "expert_id", "city", "start_date", "end_date", "duration_days", "notes", "created_at")
VALUES ('avail-haba-1', 'exp-001', 'Algiers', '2026-11-01', '2026-11-20', 20, 'In-person university keynote lectures, doctoral lab seminars, and curriculum co-design at USTHB Bab Ezzouar and ESI Oued Smar.', '2026-08-15T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "expert_availabilities" ("id", "expert_id", "city", "start_date", "end_date", "duration_days", "notes", "created_at")
VALUES ('avail-benali-1', 'exp-002', 'Algiers', '2026-11-05', '2026-11-18', 14, 'Conducting in-person NLP fine-tuning bootcamps for faculty at ESI Algiers and CERIST.', '2026-08-15T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "expert_availabilities" ("id", "expert_id", "city", "start_date", "end_date", "duration_days", "notes", "created_at")
VALUES ('avail-mansouri-1', 'exp-003', 'Oran', '2026-12-05', '2026-12-20', 16, 'Coordinating joint research lab with University of Oran 1 and Sonatrach solar research center.', '2026-08-15T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "expert_availabilities" ("id", "expert_id", "city", "start_date", "end_date", "duration_days", "notes", "created_at")
VALUES ('avail-belkacem-1', 'usr-belkacem-1004', 'Algiers', '2026-10-01', '2026-12-31', 92, 'Resident in Algiers; year-round physical access to Bab Ezzouar facilities.', '2026-08-15T08:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "matching_algorithms" (2 rows)
INSERT INTO "matching_algorithms" ("id", "name", "version", "description", "skills_weight", "availability_weight", "location_weight", "diaspora_bonus_weight", "min_compatibility_threshold", "is_active", "created_by_user_id", "created_at")
VALUES ('algo-001', 'Standard 4-Factor Deterministic Matcher v2.6', 'v2.6-prod', 'National official multi-factor alignment algorithm balancing technical skills (45%), visit availability (25%), geographic campus affinity (15%), and diaspora priority bonus (15%).', 45, 25, 15, 15, 65, TRUE, 'admin-000', '2026-09-01T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "matching_algorithms" ("id", "name", "version", "description", "skills_weight", "availability_weight", "location_weight", "diaspora_bonus_weight", "min_compatibility_threshold", "is_active", "created_by_user_id", "created_at")
VALUES ('algo-002', 'Doctoral Thesis Co-Supervision AI Engine v3.0', 'v3.0-experimental', 'High-precision academic pairing tailored for university doctoral school curriculum co-design and laboratory twinning.', 50, 20, 10, 20, 75, FALSE, 'admin-000', '2026-09-18T11:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "matching_criteria_weights" (4 rows)
INSERT INTO "matching_criteria_weights" ("id", "algorithm_id", "criterion_code", "criterion_name", "weight_percentage", "is_mandatory", "minimum_score_required", "notes")
VALUES ('mcw-001', 'algo-001', 'SKILLS_OVERLAP', 'GIN Technical Keyword Alignment', 45, TRUE, 60, 'GIN index intersection between project required skills and scholar profile tags.')
ON CONFLICT DO NOTHING;
INSERT INTO "matching_criteria_weights" ("id", "algorithm_id", "criterion_code", "criterion_name", "weight_percentage", "is_mandatory", "minimum_score_required", "notes")
VALUES ('mcw-002', 'algo-001', 'AVAIL_WINDOW', 'Physical Visit Schedule Overlap', 25, FALSE, 0, 'Calendar day overlap between university project timeframe and scholar visit windows in Algeria.')
ON CONFLICT DO NOTHING;
INSERT INTO "matching_criteria_weights" ("id", "algorithm_id", "criterion_code", "criterion_name", "weight_percentage", "is_mandatory", "minimum_score_required", "notes")
VALUES ('mcw-003', 'algo-001', 'CITY_AFFINITY', 'University Campus Wilaya Proximity', 15, FALSE, 0, 'Geographic affinity score matching the expert stay city with the host university campus location.')
ON CONFLICT DO NOTHING;
INSERT INTO "matching_criteria_weights" ("id", "algorithm_id", "criterion_code", "criterion_name", "weight_percentage", "is_mandatory", "minimum_score_required", "notes")
VALUES ('mcw-004', 'algo-001', 'DIASPORA_BOOST', 'Verified Diaspora Fellow Priority', 15, FALSE, 0, 'Sovereign MESRS incentive bonus for internationally established diaspora researchers.')
ON CONFLICT DO NOTHING;

-- Data for Table "matching_runs" (2 rows)
INSERT INTO "matching_runs" ("id", "algorithm_id", "project_id", "initiated_by_user_id", "candidates_evaluated", "matches_generated", "avg_compatibility_score", "execution_time_ms", "status", "ran_at")
VALUES ('run-001', 'algo-001', 'proj-0001-esi', 'admin-000', 142, 1, 97.5, 140, 'completed', '2026-09-26T07:45:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "matching_runs" ("id", "algorithm_id", "project_id", "initiated_by_user_id", "candidates_evaluated", "matches_generated", "avg_compatibility_score", "execution_time_ms", "status", "ran_at")
VALUES ('run-002', 'algo-001', 'proj-0002-cdta', 'admin-000', 142, 1, 95, 125, 'completed', '2026-09-28T09:30:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "projects" (3 rows)
INSERT INTO "projects" ("id", "organization_id", "institution_id", "laboratory_id", "title", "description", "skills_required", "location", "start_date", "end_date", "logistics_offered", "budget_details", "status", "success_level", "created_at")
VALUES ('proj-0001-esi', 'usr-esi-2001', 'inst-esi', 'lab-lsi', 'Cycle Doctoral Intensif : Modles de Fondation et NLP Arabe', 'Organisation d''une cole d''automne intensive de 10 jours pour 40 doctorants et enseignants-chercheurs de l''ESI et de l''USTHB sur les modles de fondation arabes et le transfert de connaissances.', '{"Natural Language Processing","Arabic LLMs","Deep Learning","Curriculum Design"}', 'Algiers', '2026-11-05', '2026-11-15', '{"travel":true,"lodging":true,"stipend":true,"honorarium_amount":80000,"currency":"DZD","notes":"Billet d''avion aller-retour pris en charge, hbergement 4 toiles  Alger et transport quotidien assur."}'::jsonb, NULL, 'matched', NULL, '2026-09-18T09:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "projects" ("id", "organization_id", "institution_id", "laboratory_id", "title", "description", "skills_required", "location", "start_date", "end_date", "logistics_offered", "budget_details", "status", "success_level", "created_at")
VALUES ('proj-0002-mentouri', 'usr-mentouri-2002', 'inst-usthb', 'lab-lrea', 'Coopration Recherche : Micro-rseaux et Hydrogne Vert Saharien', 'Mise en place d''un laboratoire pilote de modlisation et d''optimisation de production d''hydrogne solaire pour zones arides.', '{"Green Hydrogen","Solar Photovoltaics","Microgrids","Renewable Energy"}', 'Oran', '2026-12-08', '2026-12-18', '{"travel":true,"lodging":true,"stipend":true,"notes":"Billet d''avion, hbergement de recherche et per diem assur."}'::jsonb, NULL, 'submitted', NULL, '2026-09-22T11:15:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "projects" ("id", "organization_id", "institution_id", "laboratory_id", "title", "description", "skills_required", "location", "start_date", "end_date", "logistics_offered", "budget_details", "status", "success_level", "created_at")
VALUES ('proj-0003-cerist', 'usr-cerist-2003', 'inst-usthb', 'lab-lrea', 'Audit National d''Architecture Cloud & Scurit Zero-Trust', 'valuation technique de l''infrastructure des dpts numriques universitaires algriens et conception d''un cadre de scurit unifi.', '{"Cybersecurity","Cloud Computing","Network Security","Zero-Trust Architecture"}', 'Algiers', '2026-11-20', '2026-12-05', '{"travel":false,"lodging":false,"stipend":true,"notes":"Projet hybride avec 3 journes d''audit sur site  Ben Aknoun."}'::jsonb, NULL, 'under_review', NULL, '2026-09-25T14:40:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "matches" (2 rows)
INSERT INTO "matches" ("id", "project_id", "expert_id", "algorithm_id", "matching_run_id", "compatibility_score", "score_breakdown", "status", "notified_at", "responded_at", "created_at")
VALUES ('match-001', 'proj-0001-esi', 'exp-002', 'algo-001', 'run-001', 97.5, '{"skills_score":100,"availability_score":100,"location_score":100,"diaspora_bonus":100,"matched_skills":["Natural Language Processing","Arabic LLMs","Deep Learning","Curriculum Design"],"overlapping_days":11,"explanation":"100% skill match (4/4 tags), confirmed stay in Algiers during exact project dates (Nov 5-15), diaspora priority bonus."}'::jsonb, 'accepted', '2026-09-26T08:00:00Z', '2026-09-27T10:30:00Z', '2026-09-26T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "matches" ("id", "project_id", "expert_id", "algorithm_id", "matching_run_id", "compatibility_score", "score_breakdown", "status", "notified_at", "responded_at", "created_at")
VALUES ('match-002', 'proj-0002-mentouri', 'exp-003', 'algo-001', 'run-001', 95, '{"skills_score":100,"availability_score":95,"location_score":90,"diaspora_bonus":100,"matched_skills":["Green Hydrogen","Solar Photovoltaics","Microgrids","Renewable Energy"],"overlapping_days":11,"explanation":"Full technical match in clean tech, visit window in Oran coincides with project timeline."}'::jsonb, 'pending', '2026-09-28T09:15:00Z', NULL, '2026-09-28T09:15:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "match_evaluations" (2 rows)
INSERT INTO "match_evaluations" ("id", "match_id", "algorithm_id", "matching_run_id", "evaluator_user_id", "skills_alignment_score", "availability_sync_score", "location_affinity_score", "diaspora_priority_score", "composite_score", "precision_metric", "recall_metric", "f1_score", "committee_verification_notes", "is_verified_by_committee", "created_at")
VALUES ('me-001', 'match-001', 'algo-001', 'run-001', 'admin-000', 100, 100, 95, 100, 97.5, 98.2, 94.2, 95.8, 'Direct match for national computing center doctoral school curricula; expert indicated willingness to donate testing benches.', TRUE, '2026-09-26T09:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "match_evaluations" ("id", "match_id", "algorithm_id", "matching_run_id", "evaluator_user_id", "skills_alignment_score", "availability_sync_score", "location_affinity_score", "diaspora_priority_score", "composite_score", "precision_metric", "recall_metric", "f1_score", "committee_verification_notes", "is_verified_by_committee", "created_at")
VALUES ('me-002', 'match-002', 'algo-001', 'run-001', 'admin-000', 100, 95, 90, 100, 95, 96.8, 94.2, 95.8, 'Full technical alignment in solar photovoltaics and microgrids for Saharan regions.', TRUE, '2026-09-28T10:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "conversations" (1 rows)
INSERT INTO "conversations" ("id", "project_id", "expert_id", "organization_id", "match_id", "status", "preferred_contact_slot", "last_message_at", "created_at")
VALUES ('conv-001', 'proj-0001-esi', 'usr-benali-1002', 'usr-esi-2001', 'match-001', 'active', 'Thursdays 14:00 - 16:00 CET', '2026-09-29T11:45:00Z', '2026-09-27T10:35:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "messages" (2 rows)
INSERT INTO "messages" ("id", "conversation_id", "sender_id", "recipient_id", "body", "attachments", "is_read", "sent_at")
VALUES ('msg-001', 'conv-001', 'usr-esi-2001', 'usr-benali-1002', 'Welcome Dr. Benali. We are honored to collaborate on the Algerian Dialect LLM Doctoral Program at ESI Algiers.', '{"[object Object]"}', TRUE, '2026-09-27T11:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "messages" ("id", "conversation_id", "sender_id", "recipient_id", "body", "attachments", "is_read", "sent_at")
VALUES ('msg-002', 'conv-001', 'usr-benali-1002', 'usr-esi-2001', 'Thank you Director. I have reviewed the syllabus and confirmed my physical visit to Algiers for the November workshop.', '{"[object Object]"}', TRUE, '2026-09-28T09:20:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "collaborations" (1 rows)
INSERT INTO "collaborations" ("id", "project_id", "expert_id", "organization_id", "institution_id", "status", "completion_flag", "confirmed_at", "completed_at", "notes", "created_at")
VALUES ('collab-001', 'proj-0001-esi', 'exp-002', 'usr-esi-2001', 'inst-esi', 'active', NULL, '2026-09-28T14:00:00Z', NULL, 'Official cooperation protocol executed between ESI Algiers and CNRS researcher.', '2026-09-28T14:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "collaboration_milestones" (3 rows)
INSERT INTO "collaboration_milestones" ("id", "collaboration_id", "assigned_expert_id", "title", "phase_number", "target_completion_date", "completed_at", "status", "deliverable_description", "verified_by_user_id", "created_at")
VALUES ('cm-001', 'collab-001', 'exp-002', 'Phase 1: Doctoral Syllabus Co-design & Joint Thesis Jury Validation', 1, '2026-10-15', '2026-10-02T16:00:00Z', 'completed', 'Curriculum syllabus for 15 PhD candidates in Arabic NLP verified by ESI Algiers.', 'usr-esi-2001', '2026-09-28T14:30:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "collaboration_milestones" ("id", "collaboration_id", "assigned_expert_id", "title", "phase_number", "target_completion_date", "completed_at", "status", "deliverable_description", "verified_by_user_id", "created_at")
VALUES ('cm-002', 'collab-001', 'exp-002', 'Phase 2: In-Person Intensive Seminar at ESI Algiers Oued Smar Campus', 2, '2026-11-10', NULL, 'in_progress', 'Five-day on-site doctoral workshop with GPU cluster access for dial-in doctoral candidates.', NULL, '2026-09-28T14:30:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "collaboration_milestones" ("id", "collaboration_id", "assigned_expert_id", "title", "phase_number", "target_completion_date", "completed_at", "status", "deliverable_description", "verified_by_user_id", "created_at")
VALUES ('cm-003', 'collab-001', 'exp-002', 'Phase 3: Co-submission of Open-Source Algerian Dialect Foundation Model Benchmark', 3, '2026-12-20', NULL, 'pending', 'Scientific release of benchmark dataset co-authored between CNRS and ESI.', NULL, '2026-09-28T14:30:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "publications_patents" (2 rows)
INSERT INTO "publications_patents" ("id", "expert_id", "collaboration_id", "institution_id", "title", "type", "patent_or_doi_number", "publisher_or_patent_office", "year", "citations_count", "created_at")
VALUES ('pub-001', 'exp-001', 'collab-002', 'inst-crti', 'High-Density 3D Microelectronic Stack Packaging for AI Edge Accelerators', 'patent', 'US-PAT-10854582-B2', 'United States Patent and Trademark Office (USPTO)', 2024, 420, '2026-08-01T10:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "publications_patents" ("id", "expert_id", "collaboration_id", "institution_id", "title", "type", "patent_or_doi_number", "publisher_or_patent_office", "year", "citations_count", "created_at")
VALUES ('pub-002', 'exp-002', 'collab-001', 'inst-esi', 'Multilingual Dialectal Foundations for North African Arabic Natural Language Processing', 'journal_article', '10.1145/3543873.3587352', 'ACM Transactions on Asian and Low-Resource Language Information Processing', 2025, 118, '2026-08-15T11:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "event_promotions" (1 rows)
INSERT INTO "event_promotions" ("id", "organization_id", "collaboration_id", "project_id", "title", "description", "event_type", "location_city", "venue_address", "event_date", "materials_urls", "status", "approved_by_admin_id", "created_at")
VALUES ('ep-001', 'usr-esi-2001', 'collab-001', 'proj-0001-esi', 'National Doctoral Workshop on Generative AI & Arabic Dialect NLP', 'Five-day intensive seminar featuring diaspora guest laureate Dr. Amina Benali at ESI Oued Smar campus.', 'doctoral_seminar', 'Algiers', 'Amphi Bertin, Higher National School of Computer Science (ESI), Oued Smar', '2026-11-12', '{"https://esi.dz/events/ai-seminar-2026.pdf"}', 'published', 'admin-000', '2026-09-29T14:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "surveys" (1 rows)
INSERT INTO "surveys" ("id", "title", "survey_type", "target_role", "trigger_event", "questions", "is_active", "created_by_user_id", "created_at")
VALUES ('sv-001', 'Post-Collaboration Impact & Transfer Quality Survey', 'collaboration_experience', 'all', 'after_collaboration_completion', '{"[object Object]","[object Object]"}', TRUE, 'admin-000', '2026-08-15T09:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "survey_responses" (1 rows)
INSERT INTO "survey_responses" ("id", "survey_id", "user_id", "project_id", "collaboration_id", "responses", "rating", "nps_score", "comments", "submitted_at")
VALUES ('sr-001', 'sv-001', 'usr-esi-2001', 'proj-0001-esi', 'collab-001', '{"q1":5,"q2":5}'::jsonb, 5, 10, 'Dr. Benali provided world-class doctoral supervision to our students.', '2026-09-30T16:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "ratings" (1 rows)
INSERT INTO "ratings" ("id", "collaboration_id", "project_id", "from_user_id", "to_user_id", "overall_score", "category_scores", "comment", "recommendation_for_future", "is_private_admin_only", "created_at")
VALUES ('rat-001', 'collab-001', NULL, 'usr-esi-2001', 'usr-benali-1002', 5, '{"communication":5,"technical_depth":5,"mentorship_impact":5}'::jsonb, 'Exceptional academic engagement with our doctoral candidates. Provided clear dissertation feedback and guidance.', NULL, TRUE, '2026-09-29T10:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "issue_flags" (1 rows)
INSERT INTO "issue_flags" ("id", "reporter_user_id", "reported_user_id", "project_id", "collaboration_id", "category", "description", "severity", "status", "admin_resolution_notes", "created_at")
VALUES ('if-001', 'usr-esi-2001', NULL, 'proj-0001-esi', 'collab-001', 'logistics', 'High-speed GPU access for Algerian dial-in scholars required cloud quota expansion.', 'low', 'resolved', 'MESRS Cloud AI computing grant allocated 500 GPU hours for the workshop.', '2026-09-28T16:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "custom_kpis" (6 rows)
INSERT INTO "custom_kpis" ("id", "name", "description", "category", "current_value", "target_value", "unit", "progress_percentage", "status", "visualization_type", "display_on_landing", "created_by_user_id", "target_algorithm_id", "target_institution_id", "created_at")
VALUES ('kpi-001', 'Diaspora Doctoral Supervision Rate', 'Percentage of national doctoral thesis committees co-supervised by verified Algerian diaspora fellows.', 'National Impact', '86', '90', '%', 95, 'on_track', 'progress', TRUE, 'admin-000', 'algo-001', 'inst-esi', '2026-09-10T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "custom_kpis" ("id", "name", "description", "category", "current_value", "target_value", "unit", "progress_percentage", "status", "visualization_type", "display_on_landing", "created_by_user_id", "target_algorithm_id", "target_institution_id", "created_at")
VALUES ('kpi-002', 'Signed University Protocols', 'Formal institutional bilateral cooperation agreements sealed between national institutions and diaspora scientists.', 'Academic Research', '48', '50', 'Protocols', 96, 'exceeded', 'stat_counter', TRUE, 'admin-000', 'algo-001', 'inst-esi', '2026-09-12T09:30:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "custom_kpis" ("id", "name", "description", "category", "current_value", "target_value", "unit", "progress_percentage", "status", "visualization_type", "display_on_landing", "created_by_user_id", "target_algorithm_id", "target_institution_id", "created_at")
VALUES ('kpi-003', 'Global Talent Ingestion Index', 'Verified diaspora scholars actively cataloged and ready for bilateral research missions in Algeria.', 'Diaspora Outreach', '142', '150', 'Scholars', 94, 'on_track', 'gauge', TRUE, 'admin-000', 'algo-001', 'inst-esi', '2026-09-14T11:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "custom_kpis" ("id", "name", "description", "category", "current_value", "target_value", "unit", "progress_percentage", "status", "visualization_type", "display_on_landing", "created_by_user_id", "target_algorithm_id", "target_institution_id", "created_at")
VALUES ('kpi-004', 'Algorithmic Match Latency', 'Average turnaround duration between university challenge publication and deterministic scholar recommendation.', 'Governance', '1.8', '< 2.5', 'Days', 92, 'exceeded', 'sparkline', TRUE, 'admin-000', 'algo-001', 'inst-esi', '2026-09-15T14:15:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "custom_kpis" ("id", "name", "description", "category", "current_value", "target_value", "unit", "progress_percentage", "status", "visualization_type", "display_on_landing", "created_by_user_id", "target_algorithm_id", "target_institution_id", "created_at")
VALUES ('kpi-005', 'Joint International Patents Filed', 'Intellectual property co-filed by Algerian universities alongside diaspora research teams.', 'Academic Research', '17', '25', 'Patents', 68, 'attention_required', 'progress', FALSE, 'admin-000', 'algo-001', 'inst-esi', '2026-09-18T10:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "custom_kpis" ("id", "name", "description", "category", "current_value", "target_value", "unit", "progress_percentage", "status", "visualization_type", "display_on_landing", "created_by_user_id", "target_algorithm_id", "target_institution_id", "created_at")
VALUES ('kpi-006', 'National University Coverage', 'Percentage of Algerian public universities and research centres actively hosting diaspora missions.', 'National Impact', '91', '100', '%', 91, 'on_track', 'gauge', TRUE, 'admin-000', 'algo-001', 'inst-esi', '2026-09-20T12:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "kpi_evaluations" (3 rows)
INSERT INTO "kpi_evaluations" ("id", "kpi_id", "evaluated_by_user_id", "institution_id", "recorded_value", "target_value", "delta_percentage", "compliance_status", "evaluation_notes", "evaluated_at")
VALUES ('ke-001', 'kpi-001', 'admin-000', 'inst-esi', '86%', '90%', -4.44, 'compliant', 'High pace of co-supervision adoption across USTHB and ESI doctoral jury panels.', '2026-09-25T16:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "kpi_evaluations" ("id", "kpi_id", "evaluated_by_user_id", "institution_id", "recorded_value", "target_value", "delta_percentage", "compliance_status", "evaluation_notes", "evaluated_at")
VALUES ('ke-002', 'kpi-002', 'admin-000', 'inst-esi', '48 Protocols', '50 Protocols', -4, 'compliant', 'Near 100% completion of Q3 2026 sovereign target for university-diaspora agreements.', '2026-09-28T14:30:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "kpi_evaluations" ("id", "kpi_id", "evaluated_by_user_id", "institution_id", "recorded_value", "target_value", "delta_percentage", "compliance_status", "evaluation_notes", "evaluated_at")
VALUES ('ke-003', 'kpi-003', 'admin-000', 'inst-esi', '142 Scholars', '150 Scholars', -5.33, 'compliant', 'Outstanding intake of Silicon Valley, European, and Gulf-based Algerian researchers.', '2026-09-29T10:15:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "kpi_institution_targets" (3 rows)
INSERT INTO "kpi_institution_targets" ("id", "kpi_id", "institution_id", "assigned_target_value", "achieved_value", "compliance_rate", "last_updated")
VALUES ('kit-001', 'kpi-001', 'inst-esi', '12 Co-supervisions', '11 Co-supervisions', 91.6, '2026-09-28T12:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "kpi_institution_targets" ("id", "kpi_id", "institution_id", "assigned_target_value", "achieved_value", "compliance_rate", "last_updated")
VALUES ('kit-002', 'kpi-001', 'inst-usthb', '25 Co-supervisions', '24 Co-supervisions', 96, '2026-09-28T12:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "kpi_institution_targets" ("id", "kpi_id", "institution_id", "assigned_target_value", "achieved_value", "compliance_rate", "last_updated")
VALUES ('kit-003', 'kpi-002', 'inst-oran1', '8 Protocols', '8 Protocols', 100, '2026-09-28T12:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "analytics_snapshots" (1 rows)
INSERT INTO "analytics_snapshots" ("id", "snapshot_date", "period_type", "total_registered_experts", "total_registered_organizations", "total_projects_submitted", "total_matches_generated", "total_collaborations_confirmed", "total_collaborations_completed", "avg_time_to_match_days", "collaboration_success_rate", "user_satisfaction_avg_score", "metrics_payload", "generated_by_user_id", "institution_id", "created_at")
VALUES ('as-001', '2026-09-30', 'monthly', 320, 48, 94, 168, 52, 34, 1.6, 94.5, 4.9, '{"diaspora_countries":{"France":110,"USA":65,"Canada":42,"Germany":38,"UK":35,"UAE":30},"domains":{"AI_NLP":42,"Renewable_Energy":28,"Biotech_Health":25,"Material_Science":19}}'::jsonb, 'admin-000', 'inst-esi', '2026-09-30T23:59:59Z')
ON CONFLICT DO NOTHING;

-- Data for Table "project_status_histories" (5 rows)
INSERT INTO "project_status_histories" ("id", "project_id", "previous_status", "new_status", "changed_by_user_id", "notes", "created_at")
VALUES ('psh-001', 'proj-0001-esi', 'draft', 'submitted', 'usr-esi-2001', 'ESI Algiers posted doctoral technology transfer initiative.', '2026-09-18T09:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "project_status_histories" ("id", "project_id", "previous_status", "new_status", "changed_by_user_id", "notes", "created_at")
VALUES ('psh-002', 'proj-0001-esi', 'submitted', 'under_review', 'admin-000', 'MESRS Academic Committee approved project specifications.', '2026-09-20T11:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "project_status_histories" ("id", "project_id", "previous_status", "new_status", "changed_by_user_id", "notes", "created_at")
VALUES ('psh-003', 'proj-0001-esi', 'under_review', 'matched', 'admin-000', 'Standard 4-Factor Deterministic Matcher paired Dr. Amina Benali with 97.5% score.', '2026-09-26T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "project_status_histories" ("id", "project_id", "previous_status", "new_status", "changed_by_user_id", "notes", "created_at")
VALUES ('psh-004', 'proj-0001-esi', 'matched', 'contact_initiated', 'usr-benali-1002', 'Scholar accepted bilateral mission invitation.', '2026-09-27T10:30:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "project_status_histories" ("id", "project_id", "previous_status", "new_status", "changed_by_user_id", "notes", "created_at")
VALUES ('psh-005', 'proj-0001-esi', 'contact_initiated', 'confirmed', 'usr-esi-2001', 'Bilateral institutional partnership confirmed and ratified.', '2026-09-28T14:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "activity_logs" (2 rows)
INSERT INTO "activity_logs" ("id", "user_id", "project_id", "collaboration_id", "user_role", "action_type", "entity_type", "entity_id", "status_before", "status_after", "ip_address", "metadata", "created_at")
VALUES ('log-boot-001', 'admin-000', 'proj-0001-esi', 'collab-001', 'admin', 'SYSTEM_BOOTSTRAP', 'platform', NULL, NULL, NULL, '127.0.0.1', '{"note":"Platform initialized with 28 fully linked relational tables and zero circular loops.","stack":"PostgreSQL 16 + Django 5.1 + React + Vite"}'::jsonb, '2026-09-01T08:00:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "activity_logs" ("id", "user_id", "project_id", "collaboration_id", "user_role", "action_type", "entity_type", "entity_id", "status_before", "status_after", "ip_address", "metadata", "created_at")
VALUES ('log-boot-002', 'usr-esi-2001', 'proj-0001-esi', 'collab-001', 'organization', 'COLLABORATION_CONFIRMED', 'collaboration', NULL, NULL, NULL, '193.194.76.10', '{"scholar":"Dr. Amina Benali","scope":"Doctoral Arabic NLP & Algerian Dialect LLM"}'::jsonb, '2026-09-28T14:00:00Z')
ON CONFLICT DO NOTHING;

-- Data for Table "notifications" (2 rows)
INSERT INTO "notifications" ("id", "user_id", "match_id", "project_id", "collaboration_id", "type", "title", "message", "is_read", "created_at")
VALUES ('notif-001', 'usr-esi-2001', 'match-001', 'proj-0001-esi', 'collab-001', 'match_proposed', 'New Scholar Pairing: Dr. Amina Benali (97.5% Score)', 'The Standard 4-Factor Deterministic Matcher paired Dr. Amina Benali with your Doctoral AI Curriculum project.', TRUE, '2026-09-26T08:15:00Z')
ON CONFLICT DO NOTHING;
INSERT INTO "notifications" ("id", "user_id", "match_id", "project_id", "collaboration_id", "type", "title", "message", "is_read", "created_at")
VALUES ('notif-002', 'admin-000', NULL, NULL, NULL, 'kpi_threshold_alert', 'Strategic KPI Milestone: Doctoral Supervision Target at 95%', 'National diaspora doctoral co-supervision rate reached 86% against target 90%.', FALSE, '2026-09-28T16:00:00Z')
ON CONFLICT DO NOTHING;

-- ==============================================================================
-- 5. RELATIONAL FOREIGN KEY CONSTRAINTS
-- ==============================================================================

-- Constraint: profiles.user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_profiles_user_id_to_users'
    ) THEN
        ALTER TABLE "profiles"
        ADD CONSTRAINT "fk_profiles_user_id_to_users"
        FOREIGN KEY ("user_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: experts.user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_experts_user_id_to_users'
    ) THEN
        ALTER TABLE "experts"
        ADD CONSTRAINT "fk_experts_user_id_to_users"
        FOREIGN KEY ("user_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: expert_availabilities.expert_id -> experts.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_expert_availabilities_expert_id_to_experts'
    ) THEN
        ALTER TABLE "expert_availabilities"
        ADD CONSTRAINT "fk_expert_availabilities_expert_id_to_experts"
        FOREIGN KEY ("expert_id")
        REFERENCES "experts"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: institutions.user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_institutions_user_id_to_users'
    ) THEN
        ALTER TABLE "institutions"
        ADD CONSTRAINT "fk_institutions_user_id_to_users"
        FOREIGN KEY ("user_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: research_laboratories.institution_id -> institutions.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_research_laboratories_institution_id_to_institutions'
    ) THEN
        ALTER TABLE "research_laboratories"
        ADD CONSTRAINT "fk_research_laboratories_institution_id_to_institutions"
        FOREIGN KEY ("institution_id")
        REFERENCES "institutions"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: research_laboratories.director_user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_research_laboratories_director_user_id_to_users'
    ) THEN
        ALTER TABLE "research_laboratories"
        ADD CONSTRAINT "fk_research_laboratories_director_user_id_to_users"
        FOREIGN KEY ("director_user_id")
        REFERENCES "users"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: projects.organization_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_projects_organization_id_to_users'
    ) THEN
        ALTER TABLE "projects"
        ADD CONSTRAINT "fk_projects_organization_id_to_users"
        FOREIGN KEY ("organization_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: projects.institution_id -> institutions.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_projects_institution_id_to_institutions'
    ) THEN
        ALTER TABLE "projects"
        ADD CONSTRAINT "fk_projects_institution_id_to_institutions"
        FOREIGN KEY ("institution_id")
        REFERENCES "institutions"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: projects.laboratory_id -> research_laboratories.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_projects_laboratory_id_to_research_laboratories'
    ) THEN
        ALTER TABLE "projects"
        ADD CONSTRAINT "fk_projects_laboratory_id_to_research_laboratories"
        FOREIGN KEY ("laboratory_id")
        REFERENCES "research_laboratories"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: matching_algorithms.created_by_user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_matching_algorithms_created_by_user_id_to_users'
    ) THEN
        ALTER TABLE "matching_algorithms"
        ADD CONSTRAINT "fk_matching_algorithms_created_by_user_id_to_users"
        FOREIGN KEY ("created_by_user_id")
        REFERENCES "users"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: matching_criteria_weights.algorithm_id -> matching_algorithms.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_matching_criteria_weights_algorithm_id_to_matching_algorithms'
    ) THEN
        ALTER TABLE "matching_criteria_weights"
        ADD CONSTRAINT "fk_matching_criteria_weights_algorithm_id_to_matching_algorithms"
        FOREIGN KEY ("algorithm_id")
        REFERENCES "matching_algorithms"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: matching_runs.algorithm_id -> matching_algorithms.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_matching_runs_algorithm_id_to_matching_algorithms'
    ) THEN
        ALTER TABLE "matching_runs"
        ADD CONSTRAINT "fk_matching_runs_algorithm_id_to_matching_algorithms"
        FOREIGN KEY ("algorithm_id")
        REFERENCES "matching_algorithms"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: matching_runs.project_id -> projects.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_matching_runs_project_id_to_projects'
    ) THEN
        ALTER TABLE "matching_runs"
        ADD CONSTRAINT "fk_matching_runs_project_id_to_projects"
        FOREIGN KEY ("project_id")
        REFERENCES "projects"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: matching_runs.initiated_by_user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_matching_runs_initiated_by_user_id_to_users'
    ) THEN
        ALTER TABLE "matching_runs"
        ADD CONSTRAINT "fk_matching_runs_initiated_by_user_id_to_users"
        FOREIGN KEY ("initiated_by_user_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: matches.project_id -> projects.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_matches_project_id_to_projects'
    ) THEN
        ALTER TABLE "matches"
        ADD CONSTRAINT "fk_matches_project_id_to_projects"
        FOREIGN KEY ("project_id")
        REFERENCES "projects"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: matches.expert_id -> experts.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_matches_expert_id_to_experts'
    ) THEN
        ALTER TABLE "matches"
        ADD CONSTRAINT "fk_matches_expert_id_to_experts"
        FOREIGN KEY ("expert_id")
        REFERENCES "experts"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: matches.algorithm_id -> matching_algorithms.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_matches_algorithm_id_to_matching_algorithms'
    ) THEN
        ALTER TABLE "matches"
        ADD CONSTRAINT "fk_matches_algorithm_id_to_matching_algorithms"
        FOREIGN KEY ("algorithm_id")
        REFERENCES "matching_algorithms"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: matches.matching_run_id -> matching_runs.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_matches_matching_run_id_to_matching_runs'
    ) THEN
        ALTER TABLE "matches"
        ADD CONSTRAINT "fk_matches_matching_run_id_to_matching_runs"
        FOREIGN KEY ("matching_run_id")
        REFERENCES "matching_runs"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: match_evaluations.match_id -> matches.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_match_evaluations_match_id_to_matches'
    ) THEN
        ALTER TABLE "match_evaluations"
        ADD CONSTRAINT "fk_match_evaluations_match_id_to_matches"
        FOREIGN KEY ("match_id")
        REFERENCES "matches"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: match_evaluations.algorithm_id -> matching_algorithms.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_match_evaluations_algorithm_id_to_matching_algorithms'
    ) THEN
        ALTER TABLE "match_evaluations"
        ADD CONSTRAINT "fk_match_evaluations_algorithm_id_to_matching_algorithms"
        FOREIGN KEY ("algorithm_id")
        REFERENCES "matching_algorithms"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: match_evaluations.matching_run_id -> matching_runs.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_match_evaluations_matching_run_id_to_matching_runs'
    ) THEN
        ALTER TABLE "match_evaluations"
        ADD CONSTRAINT "fk_match_evaluations_matching_run_id_to_matching_runs"
        FOREIGN KEY ("matching_run_id")
        REFERENCES "matching_runs"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: match_evaluations.evaluator_user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_match_evaluations_evaluator_user_id_to_users'
    ) THEN
        ALTER TABLE "match_evaluations"
        ADD CONSTRAINT "fk_match_evaluations_evaluator_user_id_to_users"
        FOREIGN KEY ("evaluator_user_id")
        REFERENCES "users"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: conversations.project_id -> projects.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_conversations_project_id_to_projects'
    ) THEN
        ALTER TABLE "conversations"
        ADD CONSTRAINT "fk_conversations_project_id_to_projects"
        FOREIGN KEY ("project_id")
        REFERENCES "projects"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: conversations.expert_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_conversations_expert_id_to_users'
    ) THEN
        ALTER TABLE "conversations"
        ADD CONSTRAINT "fk_conversations_expert_id_to_users"
        FOREIGN KEY ("expert_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: conversations.organization_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_conversations_organization_id_to_users'
    ) THEN
        ALTER TABLE "conversations"
        ADD CONSTRAINT "fk_conversations_organization_id_to_users"
        FOREIGN KEY ("organization_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: conversations.match_id -> matches.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_conversations_match_id_to_matches'
    ) THEN
        ALTER TABLE "conversations"
        ADD CONSTRAINT "fk_conversations_match_id_to_matches"
        FOREIGN KEY ("match_id")
        REFERENCES "matches"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: messages.conversation_id -> conversations.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_messages_conversation_id_to_conversations'
    ) THEN
        ALTER TABLE "messages"
        ADD CONSTRAINT "fk_messages_conversation_id_to_conversations"
        FOREIGN KEY ("conversation_id")
        REFERENCES "conversations"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: messages.sender_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_messages_sender_id_to_users'
    ) THEN
        ALTER TABLE "messages"
        ADD CONSTRAINT "fk_messages_sender_id_to_users"
        FOREIGN KEY ("sender_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: messages.recipient_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_messages_recipient_id_to_users'
    ) THEN
        ALTER TABLE "messages"
        ADD CONSTRAINT "fk_messages_recipient_id_to_users"
        FOREIGN KEY ("recipient_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: collaborations.project_id -> projects.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_collaborations_project_id_to_projects'
    ) THEN
        ALTER TABLE "collaborations"
        ADD CONSTRAINT "fk_collaborations_project_id_to_projects"
        FOREIGN KEY ("project_id")
        REFERENCES "projects"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: collaborations.expert_id -> experts.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_collaborations_expert_id_to_experts'
    ) THEN
        ALTER TABLE "collaborations"
        ADD CONSTRAINT "fk_collaborations_expert_id_to_experts"
        FOREIGN KEY ("expert_id")
        REFERENCES "experts"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: collaborations.organization_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_collaborations_organization_id_to_users'
    ) THEN
        ALTER TABLE "collaborations"
        ADD CONSTRAINT "fk_collaborations_organization_id_to_users"
        FOREIGN KEY ("organization_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: collaborations.institution_id -> institutions.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_collaborations_institution_id_to_institutions'
    ) THEN
        ALTER TABLE "collaborations"
        ADD CONSTRAINT "fk_collaborations_institution_id_to_institutions"
        FOREIGN KEY ("institution_id")
        REFERENCES "institutions"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: collaboration_milestones.collaboration_id -> collaborations.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_collaboration_milestones_collaboration_id_to_collaborations'
    ) THEN
        ALTER TABLE "collaboration_milestones"
        ADD CONSTRAINT "fk_collaboration_milestones_collaboration_id_to_collaborations"
        FOREIGN KEY ("collaboration_id")
        REFERENCES "collaborations"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: collaboration_milestones.assigned_expert_id -> experts.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_collaboration_milestones_assigned_expert_id_to_experts'
    ) THEN
        ALTER TABLE "collaboration_milestones"
        ADD CONSTRAINT "fk_collaboration_milestones_assigned_expert_id_to_experts"
        FOREIGN KEY ("assigned_expert_id")
        REFERENCES "experts"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: collaboration_milestones.verified_by_user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_collaboration_milestones_verified_by_user_id_to_users'
    ) THEN
        ALTER TABLE "collaboration_milestones"
        ADD CONSTRAINT "fk_collaboration_milestones_verified_by_user_id_to_users"
        FOREIGN KEY ("verified_by_user_id")
        REFERENCES "users"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: publications_patents.expert_id -> experts.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_publications_patents_expert_id_to_experts'
    ) THEN
        ALTER TABLE "publications_patents"
        ADD CONSTRAINT "fk_publications_patents_expert_id_to_experts"
        FOREIGN KEY ("expert_id")
        REFERENCES "experts"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: publications_patents.collaboration_id -> collaborations.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_publications_patents_collaboration_id_to_collaborations'
    ) THEN
        ALTER TABLE "publications_patents"
        ADD CONSTRAINT "fk_publications_patents_collaboration_id_to_collaborations"
        FOREIGN KEY ("collaboration_id")
        REFERENCES "collaborations"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: publications_patents.institution_id -> institutions.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_publications_patents_institution_id_to_institutions'
    ) THEN
        ALTER TABLE "publications_patents"
        ADD CONSTRAINT "fk_publications_patents_institution_id_to_institutions"
        FOREIGN KEY ("institution_id")
        REFERENCES "institutions"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: event_promotions.organization_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_event_promotions_organization_id_to_users'
    ) THEN
        ALTER TABLE "event_promotions"
        ADD CONSTRAINT "fk_event_promotions_organization_id_to_users"
        FOREIGN KEY ("organization_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: event_promotions.collaboration_id -> collaborations.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_event_promotions_collaboration_id_to_collaborations'
    ) THEN
        ALTER TABLE "event_promotions"
        ADD CONSTRAINT "fk_event_promotions_collaboration_id_to_collaborations"
        FOREIGN KEY ("collaboration_id")
        REFERENCES "collaborations"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: event_promotions.project_id -> projects.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_event_promotions_project_id_to_projects'
    ) THEN
        ALTER TABLE "event_promotions"
        ADD CONSTRAINT "fk_event_promotions_project_id_to_projects"
        FOREIGN KEY ("project_id")
        REFERENCES "projects"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: event_promotions.approved_by_admin_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_event_promotions_approved_by_admin_id_to_users'
    ) THEN
        ALTER TABLE "event_promotions"
        ADD CONSTRAINT "fk_event_promotions_approved_by_admin_id_to_users"
        FOREIGN KEY ("approved_by_admin_id")
        REFERENCES "users"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: surveys.created_by_user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_surveys_created_by_user_id_to_users'
    ) THEN
        ALTER TABLE "surveys"
        ADD CONSTRAINT "fk_surveys_created_by_user_id_to_users"
        FOREIGN KEY ("created_by_user_id")
        REFERENCES "users"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: survey_responses.survey_id -> surveys.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_survey_responses_survey_id_to_surveys'
    ) THEN
        ALTER TABLE "survey_responses"
        ADD CONSTRAINT "fk_survey_responses_survey_id_to_surveys"
        FOREIGN KEY ("survey_id")
        REFERENCES "surveys"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: survey_responses.user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_survey_responses_user_id_to_users'
    ) THEN
        ALTER TABLE "survey_responses"
        ADD CONSTRAINT "fk_survey_responses_user_id_to_users"
        FOREIGN KEY ("user_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: survey_responses.project_id -> projects.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_survey_responses_project_id_to_projects'
    ) THEN
        ALTER TABLE "survey_responses"
        ADD CONSTRAINT "fk_survey_responses_project_id_to_projects"
        FOREIGN KEY ("project_id")
        REFERENCES "projects"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: survey_responses.collaboration_id -> collaborations.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_survey_responses_collaboration_id_to_collaborations'
    ) THEN
        ALTER TABLE "survey_responses"
        ADD CONSTRAINT "fk_survey_responses_collaboration_id_to_collaborations"
        FOREIGN KEY ("collaboration_id")
        REFERENCES "collaborations"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: ratings.collaboration_id -> collaborations.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_ratings_collaboration_id_to_collaborations'
    ) THEN
        ALTER TABLE "ratings"
        ADD CONSTRAINT "fk_ratings_collaboration_id_to_collaborations"
        FOREIGN KEY ("collaboration_id")
        REFERENCES "collaborations"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: ratings.project_id -> projects.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_ratings_project_id_to_projects'
    ) THEN
        ALTER TABLE "ratings"
        ADD CONSTRAINT "fk_ratings_project_id_to_projects"
        FOREIGN KEY ("project_id")
        REFERENCES "projects"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: ratings.from_user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_ratings_from_user_id_to_users'
    ) THEN
        ALTER TABLE "ratings"
        ADD CONSTRAINT "fk_ratings_from_user_id_to_users"
        FOREIGN KEY ("from_user_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: ratings.to_user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_ratings_to_user_id_to_users'
    ) THEN
        ALTER TABLE "ratings"
        ADD CONSTRAINT "fk_ratings_to_user_id_to_users"
        FOREIGN KEY ("to_user_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: issue_flags.reporter_user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_issue_flags_reporter_user_id_to_users'
    ) THEN
        ALTER TABLE "issue_flags"
        ADD CONSTRAINT "fk_issue_flags_reporter_user_id_to_users"
        FOREIGN KEY ("reporter_user_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: issue_flags.reported_user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_issue_flags_reported_user_id_to_users'
    ) THEN
        ALTER TABLE "issue_flags"
        ADD CONSTRAINT "fk_issue_flags_reported_user_id_to_users"
        FOREIGN KEY ("reported_user_id")
        REFERENCES "users"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: issue_flags.project_id -> projects.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_issue_flags_project_id_to_projects'
    ) THEN
        ALTER TABLE "issue_flags"
        ADD CONSTRAINT "fk_issue_flags_project_id_to_projects"
        FOREIGN KEY ("project_id")
        REFERENCES "projects"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: issue_flags.collaboration_id -> collaborations.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_issue_flags_collaboration_id_to_collaborations'
    ) THEN
        ALTER TABLE "issue_flags"
        ADD CONSTRAINT "fk_issue_flags_collaboration_id_to_collaborations"
        FOREIGN KEY ("collaboration_id")
        REFERENCES "collaborations"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: custom_kpis.created_by_user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_custom_kpis_created_by_user_id_to_users'
    ) THEN
        ALTER TABLE "custom_kpis"
        ADD CONSTRAINT "fk_custom_kpis_created_by_user_id_to_users"
        FOREIGN KEY ("created_by_user_id")
        REFERENCES "users"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: custom_kpis.target_algorithm_id -> matching_algorithms.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_custom_kpis_target_algorithm_id_to_matching_algorithms'
    ) THEN
        ALTER TABLE "custom_kpis"
        ADD CONSTRAINT "fk_custom_kpis_target_algorithm_id_to_matching_algorithms"
        FOREIGN KEY ("target_algorithm_id")
        REFERENCES "matching_algorithms"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: custom_kpis.target_institution_id -> institutions.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_custom_kpis_target_institution_id_to_institutions'
    ) THEN
        ALTER TABLE "custom_kpis"
        ADD CONSTRAINT "fk_custom_kpis_target_institution_id_to_institutions"
        FOREIGN KEY ("target_institution_id")
        REFERENCES "institutions"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: kpi_evaluations.kpi_id -> custom_kpis.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_kpi_evaluations_kpi_id_to_custom_kpis'
    ) THEN
        ALTER TABLE "kpi_evaluations"
        ADD CONSTRAINT "fk_kpi_evaluations_kpi_id_to_custom_kpis"
        FOREIGN KEY ("kpi_id")
        REFERENCES "custom_kpis"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: kpi_evaluations.evaluated_by_user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_kpi_evaluations_evaluated_by_user_id_to_users'
    ) THEN
        ALTER TABLE "kpi_evaluations"
        ADD CONSTRAINT "fk_kpi_evaluations_evaluated_by_user_id_to_users"
        FOREIGN KEY ("evaluated_by_user_id")
        REFERENCES "users"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: kpi_evaluations.institution_id -> institutions.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_kpi_evaluations_institution_id_to_institutions'
    ) THEN
        ALTER TABLE "kpi_evaluations"
        ADD CONSTRAINT "fk_kpi_evaluations_institution_id_to_institutions"
        FOREIGN KEY ("institution_id")
        REFERENCES "institutions"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: kpi_institution_targets.kpi_id -> custom_kpis.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_kpi_institution_targets_kpi_id_to_custom_kpis'
    ) THEN
        ALTER TABLE "kpi_institution_targets"
        ADD CONSTRAINT "fk_kpi_institution_targets_kpi_id_to_custom_kpis"
        FOREIGN KEY ("kpi_id")
        REFERENCES "custom_kpis"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: kpi_institution_targets.institution_id -> institutions.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_kpi_institution_targets_institution_id_to_institutions'
    ) THEN
        ALTER TABLE "kpi_institution_targets"
        ADD CONSTRAINT "fk_kpi_institution_targets_institution_id_to_institutions"
        FOREIGN KEY ("institution_id")
        REFERENCES "institutions"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: project_status_histories.project_id -> projects.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_project_status_histories_project_id_to_projects'
    ) THEN
        ALTER TABLE "project_status_histories"
        ADD CONSTRAINT "fk_project_status_histories_project_id_to_projects"
        FOREIGN KEY ("project_id")
        REFERENCES "projects"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: project_status_histories.changed_by_user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_project_status_histories_changed_by_user_id_to_users'
    ) THEN
        ALTER TABLE "project_status_histories"
        ADD CONSTRAINT "fk_project_status_histories_changed_by_user_id_to_users"
        FOREIGN KEY ("changed_by_user_id")
        REFERENCES "users"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: activity_logs.user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_activity_logs_user_id_to_users'
    ) THEN
        ALTER TABLE "activity_logs"
        ADD CONSTRAINT "fk_activity_logs_user_id_to_users"
        FOREIGN KEY ("user_id")
        REFERENCES "users"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: activity_logs.project_id -> projects.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_activity_logs_project_id_to_projects'
    ) THEN
        ALTER TABLE "activity_logs"
        ADD CONSTRAINT "fk_activity_logs_project_id_to_projects"
        FOREIGN KEY ("project_id")
        REFERENCES "projects"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: activity_logs.collaboration_id -> collaborations.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_activity_logs_collaboration_id_to_collaborations'
    ) THEN
        ALTER TABLE "activity_logs"
        ADD CONSTRAINT "fk_activity_logs_collaboration_id_to_collaborations"
        FOREIGN KEY ("collaboration_id")
        REFERENCES "collaborations"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: notifications.user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_notifications_user_id_to_users'
    ) THEN
        ALTER TABLE "notifications"
        ADD CONSTRAINT "fk_notifications_user_id_to_users"
        FOREIGN KEY ("user_id")
        REFERENCES "users"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: notifications.match_id -> matches.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_notifications_match_id_to_matches'
    ) THEN
        ALTER TABLE "notifications"
        ADD CONSTRAINT "fk_notifications_match_id_to_matches"
        FOREIGN KEY ("match_id")
        REFERENCES "matches"("id")
        ON DELETE CASCADE;
    END IF;
END $$;

-- Constraint: notifications.project_id -> projects.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_notifications_project_id_to_projects'
    ) THEN
        ALTER TABLE "notifications"
        ADD CONSTRAINT "fk_notifications_project_id_to_projects"
        FOREIGN KEY ("project_id")
        REFERENCES "projects"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: notifications.collaboration_id -> collaborations.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_notifications_collaboration_id_to_collaborations'
    ) THEN
        ALTER TABLE "notifications"
        ADD CONSTRAINT "fk_notifications_collaboration_id_to_collaborations"
        FOREIGN KEY ("collaboration_id")
        REFERENCES "collaborations"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: analytics_snapshots.generated_by_user_id -> users.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_analytics_snapshots_generated_by_user_id_to_users'
    ) THEN
        ALTER TABLE "analytics_snapshots"
        ADD CONSTRAINT "fk_analytics_snapshots_generated_by_user_id_to_users"
        FOREIGN KEY ("generated_by_user_id")
        REFERENCES "users"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- Constraint: analytics_snapshots.institution_id -> institutions.id
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_analytics_snapshots_institution_id_to_institutions'
    ) THEN
        ALTER TABLE "analytics_snapshots"
        ADD CONSTRAINT "fk_analytics_snapshots_institution_id_to_institutions"
        FOREIGN KEY ("institution_id")
        REFERENCES "institutions"("id")
        ON DELETE SET NULL;
    END IF;
END $$;

-- ==============================================================================
-- End of Database Dump. Total rows: 83
-- ==============================================================================
