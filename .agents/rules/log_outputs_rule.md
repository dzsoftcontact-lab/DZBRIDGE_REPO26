# Rule: Automatic Markdown Output Logging in `md_files_log/`

All task execution results, architectural refactoring summaries, authentication diagnostics, and major deliverables MUST be persistently documented and saved into the `md_files_log/` directory as dated Markdown files (format: `<task_name>_YYYY-MM-DD.md`).

Key requirements:
1. Every time a major task or diagnosis is completed, create or update a corresponding report in `md_files_log/`.
2. Do not omit verification curl/status results or accounts and passwords.
3. Keep the file structured with Executive Summary, Implemented Changes, API/URL Endpoints, and Verification Data.
