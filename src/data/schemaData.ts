import { SchemaTableDef, SchemaRelation } from '../types';

export const INITIAL_SCHEMA_TABLES: SchemaTableDef[] = [
  {
    "id": "tbl-users",
    "name": "users",
    "description": "System authentication credentials, roles, and status for experts, academic institutions, and MESRS admins",
    "category": "Identity",
    "columns": [
      {
        "id": "col-users-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-users-email",
        "name": "email",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "email field"
      },
      {
        "id": "col-users-password_hash",
        "name": "password_hash",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "password_hash field"
      },
      {
        "id": "col-users-role",
        "name": "role",
        "type": "user_role ENUM",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "role field"
      },
      {
        "id": "col-users-status",
        "name": "status",
        "type": "user_status ENUM",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'pending_verification'",
        "description": "status field"
      },
      {
        "id": "col-users-email_verification_token",
        "name": "email_verification_token",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "email_verification_token field"
      },
      {
        "id": "col-users-email_verified_at",
        "name": "email_verified_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "email_verified_at field"
      },
      {
        "id": "col-users-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      },
      {
        "id": "col-users-updated_at",
        "name": "updated_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "updated_at field"
      }
    ]
  },
  {
    "id": "tbl-profiles",
    "name": "profiles",
    "description": "Polymorphic profile details, multi-select expertise tags, profile completeness %, and collaboration preferences",
    "category": "Identity",
    "columns": [
      {
        "id": "col-profiles-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-profiles-user_id",
        "name": "user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-profiles-full_name",
        "name": "full_name",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "full_name field"
      },
      {
        "id": "col-profiles-organization_name",
        "name": "organization_name",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "organization_name field"
      },
      {
        "id": "col-profiles-organization_type",
        "name": "organization_type",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "organization_type field"
      },
      {
        "id": "col-profiles-bio",
        "name": "bio",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "bio field"
      },
      {
        "id": "col-profiles-phone_number",
        "name": "phone_number",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "phone_number field"
      },
      {
        "id": "col-profiles-country",
        "name": "country",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'Algeria'",
        "description": "country field"
      },
      {
        "id": "col-profiles-city",
        "name": "city",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "city field"
      },
      {
        "id": "col-profiles-is_diaspora",
        "name": "is_diaspora",
        "type": "BOOLEAN",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "FALSE",
        "description": "is_diaspora field"
      },
      {
        "id": "col-profiles-expertise_tags",
        "name": "expertise_tags",
        "type": "TEXT[]",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'{}'",
        "description": "expertise_tags field"
      },
      {
        "id": "col-profiles-collaboration_preferences",
        "name": "collaboration_preferences",
        "type": "JSONB",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'{\"remote_ok\": true, \"in_person_ok\": true}'::jsonb",
        "description": "collaboration_preferences field"
      },
      {
        "id": "col-profiles-profile_completeness_percentage",
        "name": "profile_completeness_percentage",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "85",
        "description": "profile_completeness_percentage field"
      },
      {
        "id": "col-profiles-is_verified",
        "name": "is_verified",
        "type": "BOOLEAN",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "FALSE",
        "description": "is_verified field"
      },
      {
        "id": "col-profiles-documents",
        "name": "documents",
        "type": "JSONB",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'[]'::jsonb",
        "description": "documents field"
      },
      {
        "id": "col-profiles-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-experts",
    "name": "experts",
    "description": "Dedicated registry of verified scientific experts and diaspora laureates with h-index, academic titles, research domains, citations, and credentials",
    "category": "Identity",
    "columns": [
      {
        "id": "col-experts-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-experts-user_id",
        "name": "user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-experts-full_name",
        "name": "full_name",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "full_name field"
      },
      {
        "id": "col-experts-academic_title",
        "name": "academic_title",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "academic_title field"
      },
      {
        "id": "col-experts-highest_degree",
        "name": "highest_degree",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "highest_degree field"
      },
      {
        "id": "col-experts-current_affiliation",
        "name": "current_affiliation",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "current_affiliation field"
      },
      {
        "id": "col-experts-country",
        "name": "country",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'France'",
        "description": "country field"
      },
      {
        "id": "col-experts-city",
        "name": "city",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "city field"
      },
      {
        "id": "col-experts-is_diaspora",
        "name": "is_diaspora",
        "type": "BOOLEAN",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "TRUE",
        "description": "is_diaspora field"
      },
      {
        "id": "col-experts-primary_domain",
        "name": "primary_domain",
        "type": "VARCHAR(150)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "primary_domain field"
      },
      {
        "id": "col-experts-skills",
        "name": "skills",
        "type": "TEXT[]",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'{}'",
        "description": "skills field"
      },
      {
        "id": "col-experts-h_index",
        "name": "h_index",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "18",
        "description": "h_index field"
      },
      {
        "id": "col-experts-citations_count",
        "name": "citations_count",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "1200",
        "description": "citations_count field"
      },
      {
        "id": "col-experts-publications_count",
        "name": "publications_count",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "30",
        "description": "publications_count field"
      },
      {
        "id": "col-experts-bio",
        "name": "bio",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "bio field"
      },
      {
        "id": "col-experts-google_scholar_url",
        "name": "google_scholar_url",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "google_scholar_url field"
      },
      {
        "id": "col-experts-orcid_id",
        "name": "orcid_id",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "orcid_id field"
      },
      {
        "id": "col-experts-verification_status",
        "name": "verification_status",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'verified'",
        "description": "verification_status field"
      },
      {
        "id": "col-experts-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-institutions",
    "name": "institutions",
    "description": "Unified general registry of partner institutions (Universities, National Higher Schools, Research Centers EPST, Enterprises, and Public Directorates)",
    "category": "Academic",
    "columns": [
      {
        "id": "col-institutions-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-institutions-user_id",
        "name": "user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-institutions-code",
        "name": "code",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "code field"
      },
      {
        "id": "col-institutions-name",
        "name": "name",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "name field"
      },
      {
        "id": "col-institutions-acronym",
        "name": "acronym",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "acronym field"
      },
      {
        "id": "col-institutions-institution_type",
        "name": "institution_type",
        "type": "VARCHAR(80)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'university'",
        "description": "institution_type field"
      },
      {
        "id": "col-institutions-sector",
        "name": "sector",
        "type": "VARCHAR(80)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'public'",
        "description": "sector field"
      },
      {
        "id": "col-institutions-wilaya",
        "name": "wilaya",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "wilaya field"
      },
      {
        "id": "col-institutions-country",
        "name": "country",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'Algeria'",
        "description": "country field"
      },
      {
        "id": "col-institutions-rector_or_director",
        "name": "rector_or_director",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "rector_or_director field"
      },
      {
        "id": "col-institutions-contact_email",
        "name": "contact_email",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "contact_email field"
      },
      {
        "id": "col-institutions-website",
        "name": "website",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "website field"
      },
      {
        "id": "col-institutions-total_doctoral_students",
        "name": "total_doctoral_students",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "0",
        "description": "total_doctoral_students field"
      },
      {
        "id": "col-institutions-is_verified",
        "name": "is_verified",
        "type": "BOOLEAN",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "TRUE",
        "description": "is_verified field"
      },
      {
        "id": "col-institutions-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-research_laboratories",
    "name": "research_laboratories",
    "description": "Accredited university research laboratories and doctoral school research units hosting diaspora missions",
    "category": "Academic",
    "columns": [
      {
        "id": "col-research_laboratories-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-research_laboratories-institution_id",
        "name": "institution_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> institutions(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "institutions",
        "foreignColumn": "id"
      },
      {
        "id": "col-research_laboratories-director_user_id",
        "name": "director_user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-research_laboratories-code",
        "name": "code",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "code field"
      },
      {
        "id": "col-research_laboratories-name",
        "name": "name",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "name field"
      },
      {
        "id": "col-research_laboratories-acronym",
        "name": "acronym",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "acronym field"
      },
      {
        "id": "col-research_laboratories-scientific_domain",
        "name": "scientific_domain",
        "type": "VARCHAR(150)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "scientific_domain field"
      },
      {
        "id": "col-research_laboratories-doctoral_school_name",
        "name": "doctoral_school_name",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "doctoral_school_name field"
      },
      {
        "id": "col-research_laboratories-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-expert_availabilities",
    "name": "expert_availabilities",
    "description": "Physical Algeria visit availability windows for diaspora and traveling scholars",
    "category": "Matchmaking",
    "columns": [
      {
        "id": "col-expert_availabilities-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-expert_availabilities-expert_id",
        "name": "expert_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> experts(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "experts",
        "foreignColumn": "id"
      },
      {
        "id": "col-expert_availabilities-city",
        "name": "city",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "city field"
      },
      {
        "id": "col-expert_availabilities-start_date",
        "name": "start_date",
        "type": "DATE",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "start_date field"
      },
      {
        "id": "col-expert_availabilities-end_date",
        "name": "end_date",
        "type": "DATE",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "end_date field"
      },
      {
        "id": "col-expert_availabilities-duration_days",
        "name": "duration_days",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "duration_days field"
      },
      {
        "id": "col-expert_availabilities-notes",
        "name": "notes",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "notes field"
      },
      {
        "id": "col-expert_availabilities-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-matching_algorithms",
    "name": "matching_algorithms",
    "description": "Deterministic 4-factor matchmaking models, weighting matrices, and compatibility thresholds",
    "category": "Matchmaking",
    "columns": [
      {
        "id": "col-matching_algorithms-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-matching_algorithms-name",
        "name": "name",
        "type": "VARCHAR(150)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "name field"
      },
      {
        "id": "col-matching_algorithms-version",
        "name": "version",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'v2.6-prod'",
        "description": "version field"
      },
      {
        "id": "col-matching_algorithms-description",
        "name": "description",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "description field"
      },
      {
        "id": "col-matching_algorithms-skills_weight",
        "name": "skills_weight",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-matching_algorithms-availability_weight",
        "name": "availability_weight",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-matching_algorithms-location_weight",
        "name": "location_weight",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-matching_algorithms-diaspora_bonus_weight",
        "name": "diaspora_bonus_weight",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-matching_algorithms-min_compatibility_threshold",
        "name": "min_compatibility_threshold",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-matching_algorithms-is_active",
        "name": "is_active",
        "type": "BOOLEAN",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "TRUE",
        "description": "is_active field"
      },
      {
        "id": "col-matching_algorithms-created_by_user_id",
        "name": "created_by_user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-matching_algorithms-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-matching_criteria_weights",
    "name": "matching_criteria_weights",
    "description": "Granular mathematical parameters and sub-factor weights configuring the deterministic matching algorithm",
    "category": "Matchmaking",
    "columns": [
      {
        "id": "col-matching_criteria_weights-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-matching_criteria_weights-algorithm_id",
        "name": "algorithm_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> matching_algorithms(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "matching_algorithms",
        "foreignColumn": "id"
      },
      {
        "id": "col-matching_criteria_weights-criterion_code",
        "name": "criterion_code",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "criterion_code field"
      },
      {
        "id": "col-matching_criteria_weights-criterion_name",
        "name": "criterion_name",
        "type": "VARCHAR(150)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "criterion_name field"
      },
      {
        "id": "col-matching_criteria_weights-weight_percentage",
        "name": "weight_percentage",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null
      },
      {
        "id": "col-matching_criteria_weights-is_mandatory",
        "name": "is_mandatory",
        "type": "BOOLEAN",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "FALSE",
        "description": "is_mandatory field"
      },
      {
        "id": "col-matching_criteria_weights-minimum_score_required",
        "name": "minimum_score_required",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-matching_criteria_weights-notes",
        "name": "notes",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "notes field"
      }
    ]
  },
  {
    "id": "tbl-matching_runs",
    "name": "matching_runs",
    "description": "Execution batches and automated algorithm runs scanning projects against expert profiles",
    "category": "Matchmaking",
    "columns": [
      {
        "id": "col-matching_runs-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-matching_runs-algorithm_id",
        "name": "algorithm_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> matching_algorithms(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "matching_algorithms",
        "foreignColumn": "id"
      },
      {
        "id": "col-matching_runs-project_id",
        "name": "project_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> projects(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "projects",
        "foreignColumn": "id"
      },
      {
        "id": "col-matching_runs-initiated_by_user_id",
        "name": "initiated_by_user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-matching_runs-candidates_evaluated",
        "name": "candidates_evaluated",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "0",
        "description": "candidates_evaluated field"
      },
      {
        "id": "col-matching_runs-matches_generated",
        "name": "matches_generated",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "0",
        "description": "matches_generated field"
      },
      {
        "id": "col-matching_runs-avg_compatibility_score",
        "name": "avg_compatibility_score",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-matching_runs-execution_time_ms",
        "name": "execution_time_ms",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "120",
        "description": "execution_time_ms field"
      },
      {
        "id": "col-matching_runs-status",
        "name": "status",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'completed'",
        "description": "status field"
      },
      {
        "id": "col-matching_runs-ran_at",
        "name": "ran_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "ran_at field"
      }
    ]
  },
  {
    "id": "tbl-projects",
    "name": "projects",
    "description": "Collaboration initiatives and doctoral school projects submitted by Algerian universities (Strict 10-phase lifecycle)",
    "category": "Matchmaking",
    "columns": [
      {
        "id": "col-projects-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-projects-organization_id",
        "name": "organization_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-projects-institution_id",
        "name": "institution_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> institutions(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "institutions",
        "foreignColumn": "id"
      },
      {
        "id": "col-projects-laboratory_id",
        "name": "laboratory_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> research_laboratories(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "research_laboratories",
        "foreignColumn": "id"
      },
      {
        "id": "col-projects-title",
        "name": "title",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "title field"
      },
      {
        "id": "col-projects-description",
        "name": "description",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "description field"
      },
      {
        "id": "col-projects-skills_required",
        "name": "skills_required",
        "type": "TEXT[]",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'{}'",
        "description": "skills_required field"
      },
      {
        "id": "col-projects-location",
        "name": "location",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "location field"
      },
      {
        "id": "col-projects-start_date",
        "name": "start_date",
        "type": "DATE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "start_date field"
      },
      {
        "id": "col-projects-end_date",
        "name": "end_date",
        "type": "DATE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "end_date field"
      },
      {
        "id": "col-projects-logistics_offered",
        "name": "logistics_offered",
        "type": "JSONB",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'{\"travel\": false, \"lodging\": false}'::jsonb",
        "description": "logistics_offered field"
      },
      {
        "id": "col-projects-budget_details",
        "name": "budget_details",
        "type": "JSONB",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'{}'::jsonb",
        "description": "budget_details field"
      },
      {
        "id": "col-projects-status",
        "name": "status",
        "type": "project_status ENUM",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'draft'",
        "description": "status field"
      },
      {
        "id": "col-projects-success_level",
        "name": "success_level",
        "type": "VARCHAR(80)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "success_level field"
      },
      {
        "id": "col-projects-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-matches",
    "name": "matches",
    "description": "Multi-factor compatibility pairings generated between university projects and diaspora fellows",
    "category": "Matchmaking",
    "columns": [
      {
        "id": "col-matches-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-matches-project_id",
        "name": "project_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> projects(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "projects",
        "foreignColumn": "id"
      },
      {
        "id": "col-matches-expert_id",
        "name": "expert_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> experts(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "experts",
        "foreignColumn": "id"
      },
      {
        "id": "col-matches-algorithm_id",
        "name": "algorithm_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> matching_algorithms(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "matching_algorithms",
        "foreignColumn": "id"
      },
      {
        "id": "col-matches-matching_run_id",
        "name": "matching_run_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> matching_runs(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "matching_runs",
        "foreignColumn": "id"
      },
      {
        "id": "col-matches-compatibility_score",
        "name": "compatibility_score",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null
      },
      {
        "id": "col-matches-score_breakdown",
        "name": "score_breakdown",
        "type": "JSONB",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'{}'::jsonb",
        "description": "score_breakdown field"
      },
      {
        "id": "col-matches-status",
        "name": "status",
        "type": "match_status ENUM",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'pending'",
        "description": "status field"
      },
      {
        "id": "col-matches-notified_at",
        "name": "notified_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "notified_at field"
      },
      {
        "id": "col-matches-responded_at",
        "name": "responded_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "responded_at field"
      },
      {
        "id": "col-matches-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-match_evaluations",
    "name": "match_evaluations",
    "description": "Scientific precision audits, academic committee evaluations, and ranking quality metrics (Precision@K, NDCG)",
    "category": "Matchmaking",
    "columns": [
      {
        "id": "col-match_evaluations-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-match_evaluations-match_id",
        "name": "match_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "FK -> matches(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "matches",
        "foreignColumn": "id"
      },
      {
        "id": "col-match_evaluations-algorithm_id",
        "name": "algorithm_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "FK -> matching_algorithms(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "matching_algorithms",
        "foreignColumn": "id"
      },
      {
        "id": "col-match_evaluations-matching_run_id",
        "name": "matching_run_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> matching_runs(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "matching_runs",
        "foreignColumn": "id"
      },
      {
        "id": "col-match_evaluations-evaluator_user_id",
        "name": "evaluator_user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-match_evaluations-skills_alignment_score",
        "name": "skills_alignment_score",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null
      },
      {
        "id": "col-match_evaluations-availability_sync_score",
        "name": "availability_sync_score",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null
      },
      {
        "id": "col-match_evaluations-location_affinity_score",
        "name": "location_affinity_score",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null
      },
      {
        "id": "col-match_evaluations-diaspora_priority_score",
        "name": "diaspora_priority_score",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null
      },
      {
        "id": "col-match_evaluations-composite_score",
        "name": "composite_score",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null
      },
      {
        "id": "col-match_evaluations-precision_metric",
        "name": "precision_metric",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-match_evaluations-recall_metric",
        "name": "recall_metric",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-match_evaluations-f1_score",
        "name": "f1_score",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-match_evaluations-committee_verification_notes",
        "name": "committee_verification_notes",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "committee_verification_notes field"
      },
      {
        "id": "col-match_evaluations-is_verified_by_committee",
        "name": "is_verified_by_committee",
        "type": "BOOLEAN",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "TRUE",
        "description": "is_verified_by_committee field"
      },
      {
        "id": "col-match_evaluations-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-conversations",
    "name": "conversations",
    "description": "Secure communication channel established between an expert and organization following mutual match acceptance",
    "category": "Communications",
    "columns": [
      {
        "id": "col-conversations-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-conversations-project_id",
        "name": "project_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> projects(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "projects",
        "foreignColumn": "id"
      },
      {
        "id": "col-conversations-expert_id",
        "name": "expert_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-conversations-organization_id",
        "name": "organization_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-conversations-match_id",
        "name": "match_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> matches(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "matches",
        "foreignColumn": "id"
      },
      {
        "id": "col-conversations-status",
        "name": "status",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'active'",
        "description": "status field"
      },
      {
        "id": "col-conversations-preferred_contact_slot",
        "name": "preferred_contact_slot",
        "type": "VARCHAR(150)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "preferred_contact_slot field"
      },
      {
        "id": "col-conversations-last_message_at",
        "name": "last_message_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "last_message_at field"
      },
      {
        "id": "col-conversations-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-messages",
    "name": "messages",
    "description": "Encrypted communication messages exchanged between matched parties for mission scheduling and terms coordination",
    "category": "Communications",
    "columns": [
      {
        "id": "col-messages-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-messages-conversation_id",
        "name": "conversation_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> conversations(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "conversations",
        "foreignColumn": "id"
      },
      {
        "id": "col-messages-sender_id",
        "name": "sender_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-messages-recipient_id",
        "name": "recipient_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-messages-body",
        "name": "body",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "body field"
      },
      {
        "id": "col-messages-attachments",
        "name": "attachments",
        "type": "JSONB",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'[]'::jsonb",
        "description": "attachments field"
      },
      {
        "id": "col-messages-is_read",
        "name": "is_read",
        "type": "BOOLEAN",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "FALSE",
        "description": "is_read field"
      },
      {
        "id": "col-messages-sent_at",
        "name": "sent_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "sent_at field"
      }
    ]
  },
  {
    "id": "tbl-collaborations",
    "name": "collaborations",
    "description": "Official confirmed bilateral partnerships between Algerian universities and diaspora scholars",
    "category": "Collaborations",
    "columns": [
      {
        "id": "col-collaborations-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-collaborations-project_id",
        "name": "project_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> projects(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "projects",
        "foreignColumn": "id"
      },
      {
        "id": "col-collaborations-expert_id",
        "name": "expert_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> experts(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "experts",
        "foreignColumn": "id"
      },
      {
        "id": "col-collaborations-organization_id",
        "name": "organization_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-collaborations-institution_id",
        "name": "institution_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> institutions(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "institutions",
        "foreignColumn": "id"
      },
      {
        "id": "col-collaborations-status",
        "name": "status",
        "type": "collaboration_status ENUM",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'pending'",
        "description": "status field"
      },
      {
        "id": "col-collaborations-completion_flag",
        "name": "completion_flag",
        "type": "BOOLEAN",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "FALSE",
        "description": "completion_flag field"
      },
      {
        "id": "col-collaborations-confirmed_at",
        "name": "confirmed_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "confirmed_at field"
      },
      {
        "id": "col-collaborations-completed_at",
        "name": "completed_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "completed_at field"
      },
      {
        "id": "col-collaborations-notes",
        "name": "notes",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "notes field"
      },
      {
        "id": "col-collaborations-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-collaboration_milestones",
    "name": "collaboration_milestones",
    "description": "Structured deliverables, doctoral seminars, and on-site mission phases in Algeria",
    "category": "Collaborations",
    "columns": [
      {
        "id": "col-collaboration_milestones-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-collaboration_milestones-collaboration_id",
        "name": "collaboration_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> collaborations(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "collaborations",
        "foreignColumn": "id"
      },
      {
        "id": "col-collaboration_milestones-assigned_expert_id",
        "name": "assigned_expert_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> experts(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "experts",
        "foreignColumn": "id"
      },
      {
        "id": "col-collaboration_milestones-title",
        "name": "title",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "title field"
      },
      {
        "id": "col-collaboration_milestones-phase_number",
        "name": "phase_number",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "1",
        "description": "phase_number field"
      },
      {
        "id": "col-collaboration_milestones-target_completion_date",
        "name": "target_completion_date",
        "type": "DATE",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "target_completion_date field"
      },
      {
        "id": "col-collaboration_milestones-completed_at",
        "name": "completed_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "completed_at field"
      },
      {
        "id": "col-collaboration_milestones-status",
        "name": "status",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'pending'",
        "description": "status field"
      },
      {
        "id": "col-collaboration_milestones-deliverable_description",
        "name": "deliverable_description",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "deliverable_description field"
      },
      {
        "id": "col-collaboration_milestones-verified_by_user_id",
        "name": "verified_by_user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-collaboration_milestones-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-publications_patents",
    "name": "publications_patents",
    "description": "Intellectual property, co-authored peer-reviewed research papers, and patent filings co-produced with diaspora scholars",
    "category": "Collaborations",
    "columns": [
      {
        "id": "col-publications_patents-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-publications_patents-expert_id",
        "name": "expert_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> experts(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "experts",
        "foreignColumn": "id"
      },
      {
        "id": "col-publications_patents-collaboration_id",
        "name": "collaboration_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> collaborations(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "collaborations",
        "foreignColumn": "id"
      },
      {
        "id": "col-publications_patents-institution_id",
        "name": "institution_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> institutions(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "institutions",
        "foreignColumn": "id"
      },
      {
        "id": "col-publications_patents-title",
        "name": "title",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "title field"
      },
      {
        "id": "col-publications_patents-type",
        "name": "type",
        "type": "VARCHAR(80)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'patent'",
        "description": "type field"
      },
      {
        "id": "col-publications_patents-patent_or_doi_number",
        "name": "patent_or_doi_number",
        "type": "VARCHAR(150)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "patent_or_doi_number field"
      },
      {
        "id": "col-publications_patents-publisher_or_patent_office",
        "name": "publisher_or_patent_office",
        "type": "VARCHAR(150)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "publisher_or_patent_office field"
      },
      {
        "id": "col-publications_patents-year",
        "name": "year",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "2026",
        "description": "year field"
      },
      {
        "id": "col-publications_patents-citations_count",
        "name": "citations_count",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "0",
        "description": "citations_count field"
      },
      {
        "id": "col-publications_patents-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-event_promotions",
    "name": "event_promotions",
    "description": "University events, academic workshops, and keynote seminars promoted on DZ-Bridge and linked to collaborations",
    "category": "Collaborations",
    "columns": [
      {
        "id": "col-event_promotions-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-event_promotions-organization_id",
        "name": "organization_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-event_promotions-collaboration_id",
        "name": "collaboration_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> collaborations(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "collaborations",
        "foreignColumn": "id"
      },
      {
        "id": "col-event_promotions-project_id",
        "name": "project_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> projects(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "projects",
        "foreignColumn": "id"
      },
      {
        "id": "col-event_promotions-title",
        "name": "title",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "title field"
      },
      {
        "id": "col-event_promotions-description",
        "name": "description",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "description field"
      },
      {
        "id": "col-event_promotions-event_type",
        "name": "event_type",
        "type": "VARCHAR(80)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'doctoral_seminar'",
        "description": "event_type field"
      },
      {
        "id": "col-event_promotions-location_city",
        "name": "location_city",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "location_city field"
      },
      {
        "id": "col-event_promotions-venue_address",
        "name": "venue_address",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "venue_address field"
      },
      {
        "id": "col-event_promotions-event_date",
        "name": "event_date",
        "type": "DATE",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "event_date field"
      },
      {
        "id": "col-event_promotions-materials_urls",
        "name": "materials_urls",
        "type": "JSONB",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'[]'::jsonb",
        "description": "materials_urls field"
      },
      {
        "id": "col-event_promotions-status",
        "name": "status",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'pending_approval'",
        "description": "status field"
      },
      {
        "id": "col-event_promotions-approved_by_admin_id",
        "name": "approved_by_admin_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-event_promotions-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-surveys",
    "name": "surveys",
    "description": "Configurable survey questionnaires triggered at key platform milestones (post-registration, match, completion)",
    "category": "Feedback",
    "columns": [
      {
        "id": "col-surveys-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-surveys-title",
        "name": "title",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "title field"
      },
      {
        "id": "col-surveys-survey_type",
        "name": "survey_type",
        "type": "VARCHAR(80)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'collaboration_experience'",
        "description": "survey_type field"
      },
      {
        "id": "col-surveys-target_role",
        "name": "target_role",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'all'",
        "description": "target_role field"
      },
      {
        "id": "col-surveys-trigger_event",
        "name": "trigger_event",
        "type": "VARCHAR(80)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'after_collaboration_completion'",
        "description": "trigger_event field"
      },
      {
        "id": "col-surveys-questions",
        "name": "questions",
        "type": "JSONB",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "questions field"
      },
      {
        "id": "col-surveys-is_active",
        "name": "is_active",
        "type": "BOOLEAN",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "TRUE",
        "description": "is_active field"
      },
      {
        "id": "col-surveys-created_by_user_id",
        "name": "created_by_user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-surveys-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-survey_responses",
    "name": "survey_responses",
    "description": "Submitted feedback answers, satisfaction scores (1-5), and Net Promoter Scores (NPS) for platform governance",
    "category": "Feedback",
    "columns": [
      {
        "id": "col-survey_responses-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-survey_responses-survey_id",
        "name": "survey_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> surveys(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "surveys",
        "foreignColumn": "id"
      },
      {
        "id": "col-survey_responses-user_id",
        "name": "user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-survey_responses-project_id",
        "name": "project_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> projects(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "projects",
        "foreignColumn": "id"
      },
      {
        "id": "col-survey_responses-collaboration_id",
        "name": "collaboration_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> collaborations(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "collaborations",
        "foreignColumn": "id"
      },
      {
        "id": "col-survey_responses-responses",
        "name": "responses",
        "type": "JSONB",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "responses field"
      },
      {
        "id": "col-survey_responses-rating",
        "name": "rating",
        "type": "INT",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "rating field"
      },
      {
        "id": "col-survey_responses-nps_score",
        "name": "nps_score",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "nps_score field"
      },
      {
        "id": "col-survey_responses-comments",
        "name": "comments",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "comments field"
      },
      {
        "id": "col-survey_responses-submitted_at",
        "name": "submitted_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "submitted_at field"
      }
    ]
  },
  {
    "id": "tbl-ratings",
    "name": "ratings",
    "description": "Confidential 1-5 scale mutual feedback across categories (communication, professionalism, value, punctuality)",
    "category": "Feedback",
    "columns": [
      {
        "id": "col-ratings-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-ratings-collaboration_id",
        "name": "collaboration_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> collaborations(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "collaborations",
        "foreignColumn": "id"
      },
      {
        "id": "col-ratings-project_id",
        "name": "project_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> projects(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "projects",
        "foreignColumn": "id"
      },
      {
        "id": "col-ratings-from_user_id",
        "name": "from_user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-ratings-to_user_id",
        "name": "to_user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-ratings-overall_score",
        "name": "overall_score",
        "type": "INT",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "overall_score field"
      },
      {
        "id": "col-ratings-category_scores",
        "name": "category_scores",
        "type": "JSONB",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "category_scores field"
      },
      {
        "id": "col-ratings-comment",
        "name": "comment",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "comment field"
      },
      {
        "id": "col-ratings-recommendation_for_future",
        "name": "recommendation_for_future",
        "type": "BOOLEAN",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "TRUE",
        "description": "recommendation_for_future field"
      },
      {
        "id": "col-ratings-is_private_admin_only",
        "name": "is_private_admin_only",
        "type": "BOOLEAN",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "TRUE",
        "description": "is_private_admin_only field"
      },
      {
        "id": "col-ratings-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-issue_flags",
    "name": "issue_flags",
    "description": "Dispute moderation, low-satisfaction alerts, and reported complaints requiring administrator intervention",
    "category": "Feedback",
    "columns": [
      {
        "id": "col-issue_flags-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-issue_flags-reporter_user_id",
        "name": "reporter_user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-issue_flags-reported_user_id",
        "name": "reported_user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-issue_flags-project_id",
        "name": "project_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> projects(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "projects",
        "foreignColumn": "id"
      },
      {
        "id": "col-issue_flags-collaboration_id",
        "name": "collaboration_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> collaborations(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "collaborations",
        "foreignColumn": "id"
      },
      {
        "id": "col-issue_flags-category",
        "name": "category",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "category field"
      },
      {
        "id": "col-issue_flags-description",
        "name": "description",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "description field"
      },
      {
        "id": "col-issue_flags-severity",
        "name": "severity",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'medium'",
        "description": "severity field"
      },
      {
        "id": "col-issue_flags-status",
        "name": "status",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'open'",
        "description": "status field"
      },
      {
        "id": "col-issue_flags-admin_resolution_notes",
        "name": "admin_resolution_notes",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "admin_resolution_notes field"
      },
      {
        "id": "col-issue_flags-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-custom_kpis",
    "name": "custom_kpis",
    "description": "Dynamic platform KPIs configured by MESRS administrators with target thresholds, algorithm links, and front-end visualization modes",
    "category": "Audit",
    "columns": [
      {
        "id": "col-custom_kpis-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-custom_kpis-name",
        "name": "name",
        "type": "VARCHAR(150)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "name field"
      },
      {
        "id": "col-custom_kpis-description",
        "name": "description",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "description field"
      },
      {
        "id": "col-custom_kpis-category",
        "name": "category",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'National Impact'",
        "description": "category field"
      },
      {
        "id": "col-custom_kpis-current_value",
        "name": "current_value",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "current_value field"
      },
      {
        "id": "col-custom_kpis-target_value",
        "name": "target_value",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "target_value field"
      },
      {
        "id": "col-custom_kpis-unit",
        "name": "unit",
        "type": "VARCHAR(30)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "''",
        "description": "unit field"
      },
      {
        "id": "col-custom_kpis-progress_percentage",
        "name": "progress_percentage",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "80",
        "description": "progress_percentage field"
      },
      {
        "id": "col-custom_kpis-status",
        "name": "status",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'on_track'",
        "description": "status field"
      },
      {
        "id": "col-custom_kpis-visualization_type",
        "name": "visualization_type",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'progress'",
        "description": "visualization_type field"
      },
      {
        "id": "col-custom_kpis-display_on_landing",
        "name": "display_on_landing",
        "type": "BOOLEAN",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "TRUE",
        "description": "display_on_landing field"
      },
      {
        "id": "col-custom_kpis-created_by_user_id",
        "name": "created_by_user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-custom_kpis-target_algorithm_id",
        "name": "target_algorithm_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> matching_algorithms(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "matching_algorithms",
        "foreignColumn": "id"
      },
      {
        "id": "col-custom_kpis-target_institution_id",
        "name": "target_institution_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> institutions(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "institutions",
        "foreignColumn": "id"
      },
      {
        "id": "col-custom_kpis-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-kpi_evaluations",
    "name": "kpi_evaluations",
    "description": "Periodic audit assessments and performance checkpoint evaluations measuring strategic KPI targets",
    "category": "Audit",
    "columns": [
      {
        "id": "col-kpi_evaluations-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-kpi_evaluations-kpi_id",
        "name": "kpi_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "FK -> custom_kpis(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "custom_kpis",
        "foreignColumn": "id"
      },
      {
        "id": "col-kpi_evaluations-evaluated_by_user_id",
        "name": "evaluated_by_user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-kpi_evaluations-institution_id",
        "name": "institution_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> institutions(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "institutions",
        "foreignColumn": "id"
      },
      {
        "id": "col-kpi_evaluations-recorded_value",
        "name": "recorded_value",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "recorded_value field"
      },
      {
        "id": "col-kpi_evaluations-target_value",
        "name": "target_value",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "target_value field"
      },
      {
        "id": "col-kpi_evaluations-delta_percentage",
        "name": "delta_percentage",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-kpi_evaluations-compliance_status",
        "name": "compliance_status",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'compliant'",
        "description": "compliance_status field"
      },
      {
        "id": "col-kpi_evaluations-evaluation_notes",
        "name": "evaluation_notes",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "evaluation_notes field"
      },
      {
        "id": "col-kpi_evaluations-evaluated_at",
        "name": "evaluated_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "evaluated_at field"
      }
    ]
  },
  {
    "id": "tbl-kpi_institution_targets",
    "name": "kpi_institution_targets",
    "description": "Institutional allocation of national KPI quotas per university and research centre",
    "category": "Audit",
    "columns": [
      {
        "id": "col-kpi_institution_targets-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-kpi_institution_targets-kpi_id",
        "name": "kpi_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> custom_kpis(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "custom_kpis",
        "foreignColumn": "id"
      },
      {
        "id": "col-kpi_institution_targets-institution_id",
        "name": "institution_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> institutions(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "institutions",
        "foreignColumn": "id"
      },
      {
        "id": "col-kpi_institution_targets-assigned_target_value",
        "name": "assigned_target_value",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "assigned_target_value field"
      },
      {
        "id": "col-kpi_institution_targets-achieved_value",
        "name": "achieved_value",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "achieved_value field"
      },
      {
        "id": "col-kpi_institution_targets-compliance_rate",
        "name": "compliance_rate",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-kpi_institution_targets-last_updated",
        "name": "last_updated",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "last_updated field"
      }
    ]
  },
  {
    "id": "tbl-analytics_snapshots",
    "name": "analytics_snapshots",
    "description": "Automated platform health and conversion funnel snapshots aggregated for executive reporting (Explicit in Specs)",
    "category": "Audit",
    "columns": [
      {
        "id": "col-analytics_snapshots-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-analytics_snapshots-snapshot_date",
        "name": "snapshot_date",
        "type": "DATE",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "snapshot_date field"
      },
      {
        "id": "col-analytics_snapshots-period_type",
        "name": "period_type",
        "type": "VARCHAR(50)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'monthly'",
        "description": "period_type field"
      },
      {
        "id": "col-analytics_snapshots-total_registered_experts",
        "name": "total_registered_experts",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "0",
        "description": "total_registered_experts field"
      },
      {
        "id": "col-analytics_snapshots-total_registered_organizations",
        "name": "total_registered_organizations",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "0",
        "description": "total_registered_organizations field"
      },
      {
        "id": "col-analytics_snapshots-total_projects_submitted",
        "name": "total_projects_submitted",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "0",
        "description": "total_projects_submitted field"
      },
      {
        "id": "col-analytics_snapshots-total_matches_generated",
        "name": "total_matches_generated",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "0",
        "description": "total_matches_generated field"
      },
      {
        "id": "col-analytics_snapshots-total_collaborations_confirmed",
        "name": "total_collaborations_confirmed",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "0",
        "description": "total_collaborations_confirmed field"
      },
      {
        "id": "col-analytics_snapshots-total_collaborations_completed",
        "name": "total_collaborations_completed",
        "type": "INT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "0",
        "description": "total_collaborations_completed field"
      },
      {
        "id": "col-analytics_snapshots-avg_time_to_match_days",
        "name": "avg_time_to_match_days",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-analytics_snapshots-collaboration_success_rate",
        "name": "collaboration_success_rate",
        "type": "DECIMAL(5,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-analytics_snapshots-user_satisfaction_avg_score",
        "name": "user_satisfaction_avg_score",
        "type": "DECIMAL(3,2)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null
      },
      {
        "id": "col-analytics_snapshots-metrics_payload",
        "name": "metrics_payload",
        "type": "JSONB",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'{}'::jsonb",
        "description": "metrics_payload field"
      },
      {
        "id": "col-analytics_snapshots-generated_by_user_id",
        "name": "generated_by_user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-analytics_snapshots-institution_id",
        "name": "institution_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> institutions(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "institutions",
        "foreignColumn": "id"
      },
      {
        "id": "col-analytics_snapshots-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-project_status_histories",
    "name": "project_status_histories",
    "description": "Audit trail for project state machine transitions from draft to confirmed and completed",
    "category": "Audit",
    "columns": [
      {
        "id": "col-project_status_histories-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-project_status_histories-project_id",
        "name": "project_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> projects(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "projects",
        "foreignColumn": "id"
      },
      {
        "id": "col-project_status_histories-previous_status",
        "name": "previous_status",
        "type": "project_status ENUM",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "previous_status field"
      },
      {
        "id": "col-project_status_histories-new_status",
        "name": "new_status",
        "type": "project_status ENUM",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "new_status field"
      },
      {
        "id": "col-project_status_histories-changed_by_user_id",
        "name": "changed_by_user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-project_status_histories-notes",
        "name": "notes",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "notes field"
      },
      {
        "id": "col-project_status_histories-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-activity_logs",
    "name": "activity_logs",
    "description": "Immutable system-wide audit trail with cross-table linkages to actors, projects, and collaborations",
    "category": "Audit",
    "columns": [
      {
        "id": "col-activity_logs-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-activity_logs-user_id",
        "name": "user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-activity_logs-project_id",
        "name": "project_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> projects(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "projects",
        "foreignColumn": "id"
      },
      {
        "id": "col-activity_logs-collaboration_id",
        "name": "collaboration_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> collaborations(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "collaborations",
        "foreignColumn": "id"
      },
      {
        "id": "col-activity_logs-user_role",
        "name": "user_role",
        "type": "user_role ENUM",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "user_role field"
      },
      {
        "id": "col-activity_logs-action_type",
        "name": "action_type",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "action_type field"
      },
      {
        "id": "col-activity_logs-entity_type",
        "name": "entity_type",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "entity_type field"
      },
      {
        "id": "col-activity_logs-entity_id",
        "name": "entity_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "entity_id field"
      },
      {
        "id": "col-activity_logs-status_before",
        "name": "status_before",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "status_before field"
      },
      {
        "id": "col-activity_logs-status_after",
        "name": "status_after",
        "type": "VARCHAR(100)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "status_after field"
      },
      {
        "id": "col-activity_logs-ip_address",
        "name": "ip_address",
        "type": "VARCHAR(45)",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "ip_address field"
      },
      {
        "id": "col-activity_logs-metadata",
        "name": "metadata",
        "type": "JSONB",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "'{}'::jsonb",
        "description": "metadata field"
      },
      {
        "id": "col-activity_logs-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  },
  {
    "id": "tbl-notifications",
    "name": "notifications",
    "description": "System alert routing and messaging linked directly to users, match proposals, and projects",
    "category": "Audit",
    "columns": [
      {
        "id": "col-notifications-id",
        "name": "id",
        "type": "UUID",
        "isPrimary": true,
        "isNullable": false,
        "defaultValue": "uuid_generate_v4()",
        "description": "id field"
      },
      {
        "id": "col-notifications-user_id",
        "name": "user_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> users(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "users",
        "foreignColumn": "id"
      },
      {
        "id": "col-notifications-match_id",
        "name": "match_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> matches(id) ON DELETE CASCADE",
        "isForeign": true,
        "foreignTable": "matches",
        "foreignColumn": "id"
      },
      {
        "id": "col-notifications-project_id",
        "name": "project_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> projects(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "projects",
        "foreignColumn": "id"
      },
      {
        "id": "col-notifications-collaboration_id",
        "name": "collaboration_id",
        "type": "UUID",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": null,
        "description": "FK -> collaborations(id) ON DELETE SET NULL",
        "isForeign": true,
        "foreignTable": "collaborations",
        "foreignColumn": "id"
      },
      {
        "id": "col-notifications-type",
        "name": "type",
        "type": "VARCHAR(80)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "type field"
      },
      {
        "id": "col-notifications-title",
        "name": "title",
        "type": "VARCHAR(255)",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "title field"
      },
      {
        "id": "col-notifications-message",
        "name": "message",
        "type": "TEXT",
        "isPrimary": false,
        "isNullable": false,
        "defaultValue": null,
        "description": "message field"
      },
      {
        "id": "col-notifications-is_read",
        "name": "is_read",
        "type": "BOOLEAN",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "FALSE",
        "description": "is_read field"
      },
      {
        "id": "col-notifications-created_at",
        "name": "created_at",
        "type": "TIMESTAMP WITH TIME ZONE",
        "isPrimary": false,
        "isNullable": true,
        "defaultValue": "CURRENT_TIMESTAMP",
        "description": "created_at field"
      }
    ]
  }
];

export const INITIAL_SCHEMA_RELATIONS: SchemaRelation[] = [
  {
    "id": "fk_profiles_user_id_to_users",
    "sourceTable": "profiles",
    "sourceColumn": "user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "profiles.user_id -> users.id"
  },
  {
    "id": "fk_experts_user_id_to_users",
    "sourceTable": "experts",
    "sourceColumn": "user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "experts.user_id -> users.id"
  },
  {
    "id": "fk_expert_availabilities_expert_id_to_experts",
    "sourceTable": "expert_availabilities",
    "sourceColumn": "expert_id",
    "targetTable": "experts",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "expert_availabilities.expert_id -> experts.id"
  },
  {
    "id": "fk_institutions_user_id_to_users",
    "sourceTable": "institutions",
    "sourceColumn": "user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "institutions.user_id -> users.id"
  },
  {
    "id": "fk_research_laboratories_institution_id_to_institutions",
    "sourceTable": "research_laboratories",
    "sourceColumn": "institution_id",
    "targetTable": "institutions",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "research_laboratories.institution_id -> institutions.id"
  },
  {
    "id": "fk_research_laboratories_director_user_id_to_users",
    "sourceTable": "research_laboratories",
    "sourceColumn": "director_user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "research_laboratories.director_user_id -> users.id"
  },
  {
    "id": "fk_projects_organization_id_to_users",
    "sourceTable": "projects",
    "sourceColumn": "organization_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "projects.organization_id -> users.id"
  },
  {
    "id": "fk_projects_institution_id_to_institutions",
    "sourceTable": "projects",
    "sourceColumn": "institution_id",
    "targetTable": "institutions",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "projects.institution_id -> institutions.id"
  },
  {
    "id": "fk_projects_laboratory_id_to_research_laboratories",
    "sourceTable": "projects",
    "sourceColumn": "laboratory_id",
    "targetTable": "research_laboratories",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "projects.laboratory_id -> research_laboratories.id"
  },
  {
    "id": "fk_matching_algorithms_created_by_user_id_to_users",
    "sourceTable": "matching_algorithms",
    "sourceColumn": "created_by_user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "matching_algorithms.created_by_user_id -> users.id"
  },
  {
    "id": "fk_matching_criteria_weights_algorithm_id_to_matching_algorithms",
    "sourceTable": "matching_criteria_weights",
    "sourceColumn": "algorithm_id",
    "targetTable": "matching_algorithms",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "matching_criteria_weights.algorithm_id -> matching_algorithms.id"
  },
  {
    "id": "fk_matching_runs_algorithm_id_to_matching_algorithms",
    "sourceTable": "matching_runs",
    "sourceColumn": "algorithm_id",
    "targetTable": "matching_algorithms",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "matching_runs.algorithm_id -> matching_algorithms.id"
  },
  {
    "id": "fk_matching_runs_project_id_to_projects",
    "sourceTable": "matching_runs",
    "sourceColumn": "project_id",
    "targetTable": "projects",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "matching_runs.project_id -> projects.id"
  },
  {
    "id": "fk_matching_runs_initiated_by_user_id_to_users",
    "sourceTable": "matching_runs",
    "sourceColumn": "initiated_by_user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "matching_runs.initiated_by_user_id -> users.id"
  },
  {
    "id": "fk_matches_project_id_to_projects",
    "sourceTable": "matches",
    "sourceColumn": "project_id",
    "targetTable": "projects",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "matches.project_id -> projects.id"
  },
  {
    "id": "fk_matches_expert_id_to_experts",
    "sourceTable": "matches",
    "sourceColumn": "expert_id",
    "targetTable": "experts",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "matches.expert_id -> experts.id"
  },
  {
    "id": "fk_matches_algorithm_id_to_matching_algorithms",
    "sourceTable": "matches",
    "sourceColumn": "algorithm_id",
    "targetTable": "matching_algorithms",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "matches.algorithm_id -> matching_algorithms.id"
  },
  {
    "id": "fk_matches_matching_run_id_to_matching_runs",
    "sourceTable": "matches",
    "sourceColumn": "matching_run_id",
    "targetTable": "matching_runs",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "matches.matching_run_id -> matching_runs.id"
  },
  {
    "id": "fk_match_evaluations_match_id_to_matches",
    "sourceTable": "match_evaluations",
    "sourceColumn": "match_id",
    "targetTable": "matches",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "match_evaluations.match_id -> matches.id"
  },
  {
    "id": "fk_match_evaluations_algorithm_id_to_matching_algorithms",
    "sourceTable": "match_evaluations",
    "sourceColumn": "algorithm_id",
    "targetTable": "matching_algorithms",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "match_evaluations.algorithm_id -> matching_algorithms.id"
  },
  {
    "id": "fk_match_evaluations_matching_run_id_to_matching_runs",
    "sourceTable": "match_evaluations",
    "sourceColumn": "matching_run_id",
    "targetTable": "matching_runs",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "match_evaluations.matching_run_id -> matching_runs.id"
  },
  {
    "id": "fk_match_evaluations_evaluator_user_id_to_users",
    "sourceTable": "match_evaluations",
    "sourceColumn": "evaluator_user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "match_evaluations.evaluator_user_id -> users.id"
  },
  {
    "id": "fk_conversations_project_id_to_projects",
    "sourceTable": "conversations",
    "sourceColumn": "project_id",
    "targetTable": "projects",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "conversations.project_id -> projects.id"
  },
  {
    "id": "fk_conversations_expert_id_to_users",
    "sourceTable": "conversations",
    "sourceColumn": "expert_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "conversations.expert_id -> users.id"
  },
  {
    "id": "fk_conversations_organization_id_to_users",
    "sourceTable": "conversations",
    "sourceColumn": "organization_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "conversations.organization_id -> users.id"
  },
  {
    "id": "fk_conversations_match_id_to_matches",
    "sourceTable": "conversations",
    "sourceColumn": "match_id",
    "targetTable": "matches",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "conversations.match_id -> matches.id"
  },
  {
    "id": "fk_messages_conversation_id_to_conversations",
    "sourceTable": "messages",
    "sourceColumn": "conversation_id",
    "targetTable": "conversations",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "messages.conversation_id -> conversations.id"
  },
  {
    "id": "fk_messages_sender_id_to_users",
    "sourceTable": "messages",
    "sourceColumn": "sender_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "messages.sender_id -> users.id"
  },
  {
    "id": "fk_messages_recipient_id_to_users",
    "sourceTable": "messages",
    "sourceColumn": "recipient_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "messages.recipient_id -> users.id"
  },
  {
    "id": "fk_collaborations_project_id_to_projects",
    "sourceTable": "collaborations",
    "sourceColumn": "project_id",
    "targetTable": "projects",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "collaborations.project_id -> projects.id"
  },
  {
    "id": "fk_collaborations_expert_id_to_experts",
    "sourceTable": "collaborations",
    "sourceColumn": "expert_id",
    "targetTable": "experts",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "collaborations.expert_id -> experts.id"
  },
  {
    "id": "fk_collaborations_organization_id_to_users",
    "sourceTable": "collaborations",
    "sourceColumn": "organization_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "collaborations.organization_id -> users.id"
  },
  {
    "id": "fk_collaborations_institution_id_to_institutions",
    "sourceTable": "collaborations",
    "sourceColumn": "institution_id",
    "targetTable": "institutions",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "collaborations.institution_id -> institutions.id"
  },
  {
    "id": "fk_collaboration_milestones_collaboration_id_to_collaborations",
    "sourceTable": "collaboration_milestones",
    "sourceColumn": "collaboration_id",
    "targetTable": "collaborations",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "collaboration_milestones.collaboration_id -> collaborations.id"
  },
  {
    "id": "fk_collaboration_milestones_assigned_expert_id_to_experts",
    "sourceTable": "collaboration_milestones",
    "sourceColumn": "assigned_expert_id",
    "targetTable": "experts",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "collaboration_milestones.assigned_expert_id -> experts.id"
  },
  {
    "id": "fk_collaboration_milestones_verified_by_user_id_to_users",
    "sourceTable": "collaboration_milestones",
    "sourceColumn": "verified_by_user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "collaboration_milestones.verified_by_user_id -> users.id"
  },
  {
    "id": "fk_publications_patents_expert_id_to_experts",
    "sourceTable": "publications_patents",
    "sourceColumn": "expert_id",
    "targetTable": "experts",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "publications_patents.expert_id -> experts.id"
  },
  {
    "id": "fk_publications_patents_collaboration_id_to_collaborations",
    "sourceTable": "publications_patents",
    "sourceColumn": "collaboration_id",
    "targetTable": "collaborations",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "publications_patents.collaboration_id -> collaborations.id"
  },
  {
    "id": "fk_publications_patents_institution_id_to_institutions",
    "sourceTable": "publications_patents",
    "sourceColumn": "institution_id",
    "targetTable": "institutions",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "publications_patents.institution_id -> institutions.id"
  },
  {
    "id": "fk_event_promotions_organization_id_to_users",
    "sourceTable": "event_promotions",
    "sourceColumn": "organization_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "event_promotions.organization_id -> users.id"
  },
  {
    "id": "fk_event_promotions_collaboration_id_to_collaborations",
    "sourceTable": "event_promotions",
    "sourceColumn": "collaboration_id",
    "targetTable": "collaborations",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "event_promotions.collaboration_id -> collaborations.id"
  },
  {
    "id": "fk_event_promotions_project_id_to_projects",
    "sourceTable": "event_promotions",
    "sourceColumn": "project_id",
    "targetTable": "projects",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "event_promotions.project_id -> projects.id"
  },
  {
    "id": "fk_event_promotions_approved_by_admin_id_to_users",
    "sourceTable": "event_promotions",
    "sourceColumn": "approved_by_admin_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "event_promotions.approved_by_admin_id -> users.id"
  },
  {
    "id": "fk_surveys_created_by_user_id_to_users",
    "sourceTable": "surveys",
    "sourceColumn": "created_by_user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "surveys.created_by_user_id -> users.id"
  },
  {
    "id": "fk_survey_responses_survey_id_to_surveys",
    "sourceTable": "survey_responses",
    "sourceColumn": "survey_id",
    "targetTable": "surveys",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "survey_responses.survey_id -> surveys.id"
  },
  {
    "id": "fk_survey_responses_user_id_to_users",
    "sourceTable": "survey_responses",
    "sourceColumn": "user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "survey_responses.user_id -> users.id"
  },
  {
    "id": "fk_survey_responses_project_id_to_projects",
    "sourceTable": "survey_responses",
    "sourceColumn": "project_id",
    "targetTable": "projects",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "survey_responses.project_id -> projects.id"
  },
  {
    "id": "fk_survey_responses_collaboration_id_to_collaborations",
    "sourceTable": "survey_responses",
    "sourceColumn": "collaboration_id",
    "targetTable": "collaborations",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "survey_responses.collaboration_id -> collaborations.id"
  },
  {
    "id": "fk_ratings_collaboration_id_to_collaborations",
    "sourceTable": "ratings",
    "sourceColumn": "collaboration_id",
    "targetTable": "collaborations",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "ratings.collaboration_id -> collaborations.id"
  },
  {
    "id": "fk_ratings_project_id_to_projects",
    "sourceTable": "ratings",
    "sourceColumn": "project_id",
    "targetTable": "projects",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "ratings.project_id -> projects.id"
  },
  {
    "id": "fk_ratings_from_user_id_to_users",
    "sourceTable": "ratings",
    "sourceColumn": "from_user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "ratings.from_user_id -> users.id"
  },
  {
    "id": "fk_ratings_to_user_id_to_users",
    "sourceTable": "ratings",
    "sourceColumn": "to_user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "ratings.to_user_id -> users.id"
  },
  {
    "id": "fk_issue_flags_reporter_user_id_to_users",
    "sourceTable": "issue_flags",
    "sourceColumn": "reporter_user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "issue_flags.reporter_user_id -> users.id"
  },
  {
    "id": "fk_issue_flags_reported_user_id_to_users",
    "sourceTable": "issue_flags",
    "sourceColumn": "reported_user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "issue_flags.reported_user_id -> users.id"
  },
  {
    "id": "fk_issue_flags_project_id_to_projects",
    "sourceTable": "issue_flags",
    "sourceColumn": "project_id",
    "targetTable": "projects",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "issue_flags.project_id -> projects.id"
  },
  {
    "id": "fk_issue_flags_collaboration_id_to_collaborations",
    "sourceTable": "issue_flags",
    "sourceColumn": "collaboration_id",
    "targetTable": "collaborations",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "issue_flags.collaboration_id -> collaborations.id"
  },
  {
    "id": "fk_custom_kpis_created_by_user_id_to_users",
    "sourceTable": "custom_kpis",
    "sourceColumn": "created_by_user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "custom_kpis.created_by_user_id -> users.id"
  },
  {
    "id": "fk_custom_kpis_target_algorithm_id_to_matching_algorithms",
    "sourceTable": "custom_kpis",
    "sourceColumn": "target_algorithm_id",
    "targetTable": "matching_algorithms",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "custom_kpis.target_algorithm_id -> matching_algorithms.id"
  },
  {
    "id": "fk_custom_kpis_target_institution_id_to_institutions",
    "sourceTable": "custom_kpis",
    "sourceColumn": "target_institution_id",
    "targetTable": "institutions",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "custom_kpis.target_institution_id -> institutions.id"
  },
  {
    "id": "fk_kpi_evaluations_kpi_id_to_custom_kpis",
    "sourceTable": "kpi_evaluations",
    "sourceColumn": "kpi_id",
    "targetTable": "custom_kpis",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "kpi_evaluations.kpi_id -> custom_kpis.id"
  },
  {
    "id": "fk_kpi_evaluations_evaluated_by_user_id_to_users",
    "sourceTable": "kpi_evaluations",
    "sourceColumn": "evaluated_by_user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "kpi_evaluations.evaluated_by_user_id -> users.id"
  },
  {
    "id": "fk_kpi_evaluations_institution_id_to_institutions",
    "sourceTable": "kpi_evaluations",
    "sourceColumn": "institution_id",
    "targetTable": "institutions",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "kpi_evaluations.institution_id -> institutions.id"
  },
  {
    "id": "fk_kpi_institution_targets_kpi_id_to_custom_kpis",
    "sourceTable": "kpi_institution_targets",
    "sourceColumn": "kpi_id",
    "targetTable": "custom_kpis",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "kpi_institution_targets.kpi_id -> custom_kpis.id"
  },
  {
    "id": "fk_kpi_institution_targets_institution_id_to_institutions",
    "sourceTable": "kpi_institution_targets",
    "sourceColumn": "institution_id",
    "targetTable": "institutions",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "kpi_institution_targets.institution_id -> institutions.id"
  },
  {
    "id": "fk_project_status_histories_project_id_to_projects",
    "sourceTable": "project_status_histories",
    "sourceColumn": "project_id",
    "targetTable": "projects",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "project_status_histories.project_id -> projects.id"
  },
  {
    "id": "fk_project_status_histories_changed_by_user_id_to_users",
    "sourceTable": "project_status_histories",
    "sourceColumn": "changed_by_user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "project_status_histories.changed_by_user_id -> users.id"
  },
  {
    "id": "fk_activity_logs_user_id_to_users",
    "sourceTable": "activity_logs",
    "sourceColumn": "user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "activity_logs.user_id -> users.id"
  },
  {
    "id": "fk_activity_logs_project_id_to_projects",
    "sourceTable": "activity_logs",
    "sourceColumn": "project_id",
    "targetTable": "projects",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "activity_logs.project_id -> projects.id"
  },
  {
    "id": "fk_activity_logs_collaboration_id_to_collaborations",
    "sourceTable": "activity_logs",
    "sourceColumn": "collaboration_id",
    "targetTable": "collaborations",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "activity_logs.collaboration_id -> collaborations.id"
  },
  {
    "id": "fk_notifications_user_id_to_users",
    "sourceTable": "notifications",
    "sourceColumn": "user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "notifications.user_id -> users.id"
  },
  {
    "id": "fk_notifications_match_id_to_matches",
    "sourceTable": "notifications",
    "sourceColumn": "match_id",
    "targetTable": "matches",
    "targetColumn": "id",
    "onDelete": "CASCADE",
    "label": "notifications.match_id -> matches.id"
  },
  {
    "id": "fk_notifications_project_id_to_projects",
    "sourceTable": "notifications",
    "sourceColumn": "project_id",
    "targetTable": "projects",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "notifications.project_id -> projects.id"
  },
  {
    "id": "fk_notifications_collaboration_id_to_collaborations",
    "sourceTable": "notifications",
    "sourceColumn": "collaboration_id",
    "targetTable": "collaborations",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "notifications.collaboration_id -> collaborations.id"
  },
  {
    "id": "fk_analytics_snapshots_generated_by_user_id_to_users",
    "sourceTable": "analytics_snapshots",
    "sourceColumn": "generated_by_user_id",
    "targetTable": "users",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "analytics_snapshots.generated_by_user_id -> users.id"
  },
  {
    "id": "fk_analytics_snapshots_institution_id_to_institutions",
    "sourceTable": "analytics_snapshots",
    "sourceColumn": "institution_id",
    "targetTable": "institutions",
    "targetColumn": "id",
    "onDelete": "SET NULL",
    "label": "analytics_snapshots.institution_id -> institutions.id"
  }
];

export function generatePostgreSqlDdl(tables: SchemaTableDef[], relations: SchemaRelation[]): string {
  let sql = `-- ==============================================================================
-- DZ-BRIDGE: COMPREHENSIVE POSTGRESQL 16 DATABASE DDL
-- Platform for Algerian Scholar Award & Diaspora Knowledge Transfer
-- Engine: PostgreSQL 16+ with UUID and JSONB
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";\n\n`;

  tables.forEach((t) => {
    sql += `-- Table: ${t.name} (${t.category || 'Custom'})\n`;
    sql += `CREATE TABLE IF NOT EXISTS "${t.name}" (\n`;
    const colDefs = (t.columns || []).map((col) => {
      let line = `    "${col.name}" ${col.type || 'VARCHAR(255)'}`;
      if (col.isPrimary) line += ' PRIMARY KEY';
      if (!col.isNullable && !col.isPrimary) line += ' NOT NULL';
      if (col.defaultValue) line += ` DEFAULT ${col.defaultValue}`;
      return line;
    });
    sql += colDefs.join(',\n');
    sql += '\n);\n\n';
  });

  sql += '-- Relational Foreign Key Integrity Constraints\n';
  relations.forEach((rel) => {
    const constraintName = rel.id || `fk_${rel.sourceTable}_${rel.sourceColumn}_to_${rel.targetTable}`;
    sql += `ALTER TABLE "${rel.sourceTable}" ADD CONSTRAINT "${constraintName}"\n`;
    sql += `    FOREIGN KEY ("${rel.sourceColumn}") REFERENCES "${rel.targetTable}"("${rel.targetColumn}") ON DELETE ${rel.onDelete || 'CASCADE'};\n\n`;
  });

  return sql;
}

export function generateDjangoOrmCode(tables: SchemaTableDef[], relations: SchemaRelation[]): string {
  let py = `"""\nDZ-Bridge Django 5.1 ORM Models\nGenerated automatically by Django Schema Studio\n"""\nimport uuid\nfrom django.db import models\nfrom django.conf import settings\n\n`;

  tables.forEach((tbl) => {
    const className = tbl.name
      .split('_')
      .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
      .join('');
    py += `class ${className}(models.Model):\n`;
    py += `    """${tbl.description || tbl.name}"""\n`;
    (tbl.columns || []).forEach((col) => {
      let fieldCode = '';
      if (col.isPrimary && col.type.includes('UUID')) {
        fieldCode = 'models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)';
      } else if (col.isForeign) {
        const targetModel = (col.foreignTable || 'User')
          .split('_')
          .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
          .join('');
        fieldCode = `models.ForeignKey('${targetModel}', on_delete=models.CASCADE, null=True, blank=True, related_name='${tbl.name}_${col.name}')`;
      } else if (col.type === 'BOOLEAN') {
        fieldCode = `models.BooleanField(default=${col.defaultValue === 'TRUE' ? 'True' : 'False'})`;
      } else if (col.type.includes('INT')) {
        fieldCode = 'models.IntegerField(null=True, blank=True)';
      } else if (col.type === 'TEXT') {
        fieldCode = 'models.TextField(null=True, blank=True)';
      } else if (col.type.includes('TIMESTAMP')) {
        fieldCode = 'models.DateTimeField(auto_now_add=True)';
      } else if (col.type.includes('JSONB') || col.type.includes('[]')) {
        fieldCode = 'models.JSONField(default=dict, blank=True)';
      } else {
        fieldCode = 'models.CharField(max_length=255, null=True, blank=True)';
      }
      py += `    ${col.name} = ${fieldCode}\n`;
    });
    py += `\n    class Meta:\n        db_table = '${tbl.name}'\n        verbose_name = '${className}'\n\n\n`;
  });

  return py;
}
