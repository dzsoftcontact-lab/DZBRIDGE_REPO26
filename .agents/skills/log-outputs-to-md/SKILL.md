---
name: log-outputs-to-md
description: Automatically logs and archives all task outputs, architecture decisions, refactoring results, and diagnostic reports as timestamped Markdown files in the md_files_log/ directory.
---

# Log Outputs to Markdown (`md_files_log`) Skill

## Overview
This skill enforces that every significant execution output, analysis report, credential update, diagnostic run, and platform refactoring result is archived as a persistent, GitHub-flavored Markdown document in the `md_files_log/` workspace directory.

## Workflow Rules & Guidelines

1. **Target Directory**:
   All reports must be placed inside:
   `md_files_log/`

2. **File Naming Convention**:
   Use descriptive lower_snake_case with the current date suffix (`YYYY-MM-DD`):
   - Format: `<topic_or_task>_report_YYYY-MM-DD.md`
   - Examples:
     - `md_files_log/auth_and_credentials_report_2026-10-26.md`
     - `md_files_log/platform_refactor_and_organization_dashboard_2026-10-26.md`
     - `md_files_log/backend_api_integration_report_2026-10-26.md`

3. **Required Report Structure**:
   Each generated report must contain:
   - **Title & Metadata**: Date, Environment, Target Systems, Author/Role.
   - **Executive Summary**: High-level recap of the task and problems addressed.
   - **Changes & Key Findings**: Files touched, obsolete files removed, newly created features.
   - **Verification & Endpoint Tests**: CLI/curl outputs, HTTP status codes, and test assertions.
   - **Credentials & Access URLs Table**: Clear breakdown of accounts, roles, URLs, and passwords.

4. **Trigger Points**:
   Execute this logging workflow:
   - When finishing a task or major sub-task.
   - When resolving authentication, API, or system bugs.
   - Whenever requested by the user.
