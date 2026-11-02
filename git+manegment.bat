@echo off
setlocal enabledelayedexpansion
title Git Project Health and Workflow Manager for Windows
chcp 65001 >nul 2>&1

rem ============================================================================
rem  🩺 GIT PROJECT HEALTH & WORKFLOW MANAGER — PRO EDITION FOR WINDOWS
rem  Author  : Degha Houssem Eddine
rem  Version : 3.1.0
rem  Purpose : Comprehensive, automated, safe interactive Git workflow & DevOps manager.
rem            Observe → Analyze → Assess → Recommend → Guide → Execute → Verify
rem  (Windows .bat port with full 1:1 feature parity with git+manegment.sh)
rem ============================================================================

rem --- Enable Virtual Terminal / ANSI Colors in Windows 10/11 ---
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

rem --- Clean ESC character extraction (zero hanging, completely robust) ---
set "ESC="
for /f "delims=" %%a in ('powershell -NoProfile -Command "[char]27" 2^>nul') do set "ESC=%%a" 

if defined ESC (
  set "RED=%ESC%[0;31m"
  set "GREEN=%ESC%[0;32m"
  set "YELLOW=%ESC%[1;33m"
  set "BLUE=%ESC%[0;34m"
  set "MAGENTA=%ESC%[0;35m"
  set "CYAN=%ESC%[0;36m"
  set "WHITE=%ESC%[1;37m"
  set "GRAY=%ESC%[0;90m"
  set "BOLD=%ESC%[1m"
  set "DIM=%ESC%[2m"
  set "RESET=%ESC%[0m"
  set "NC=%ESC%[0m"
) else (
  set "RED="
  set "GREEN="
  set "YELLOW="
  set "BLUE="
  set "MAGENTA="
  set "CYAN="
  set "WHITE="
  set "GRAY="
  set "BOLD="
  set "DIM="
  set "RESET="
  set "NC="
)

rem Resolve full directory of this script without trailing backslash
for %%I in ("%~dp0.") do set "SCRIPT_DIR=%%~fI"

rem --- CLI Subcommand Argument Support ---
if not "%~1"=="" (
  call :require_git
  if errorlevel 1 exit /b 1
  call :ensure_repo
  if errorlevel 1 exit /b 1

  if /i "%~1"=="status"    ( call :show_detailed_status & exit /b 0 )
  if /i "%~1"=="health"    ( call :show_health_report & exit /b 0 )
  if /i "%~1"=="sync"      ( call :full_two_way_sync & exit /b 0 )
  if /i "%~1"=="commit"    ( call :smart_commit & exit /b 0 )
  if /i "%~1"=="push"      ( call :push_changes_menu & exit /b 0 )
  if /i "%~1"=="pull"      ( call :pull_and_fetch_menu & exit /b 0 )
  if /i "%~1"=="branch"    ( call :branch_manager & exit /b 0 )
  if /i "%~1"=="graph"     ( call :visual_branch_graph & exit /b 0 )
  if /i "%~1"=="keifu"     ( call :commit_navigation_graph & exit /b 0 )
  if /i "%~1"=="nav"       ( call :commit_navigation_graph & exit /b 0 )
  if /i "%~1"=="navigate"  ( call :commit_navigation_graph & exit /b 0 )
  if /i "%~1"=="tag"       ( call :show_version_recommendation & exit /b 0 )
  if /i "%~1"=="abort"     ( call :abort_rebase_or_merge & exit /b 0 )
  if /i "%~1"=="help"      ( goto :cli_help )
  if /i "%~1"=="-h"        ( goto :cli_help )
  if /i "%~1"=="--help"    ( goto :cli_help )
)

:main_loop
call :require_git
if errorlevel 1 (
  echo.
  echo %RED%Git is required to run Git Project Health Manager.%RESET%
  echo %WHITE%Press any key to exit...%RESET%
  pause >nul
  exit /b 1
)
call :ensure_repo
if errorlevel 1 (
  echo.
  echo %YELLOW%A Git repository is required. Exiting.%RESET%
  echo %WHITE%Press any key to exit...%RESET%
  pause >nul
  exit /b 1
)

:interactive_loop
cls
call :refresh_git_metrics
call :render_dashboard
call :render_main_menu

set "choice="
set /p choice="%BOLD%%CYAN%Select option [0-29, or A to Abort Rebase]: %RESET%"
if "!choice!"=="" goto :interactive_loop
echo.

if /i "!choice!"=="A" call :abort_rebase_or_merge & goto :pause_and_loop
if /i "!choice!"=="abort" call :abort_rebase_or_merge & goto :pause_and_loop
if "!choice!"=="0" goto :exit_app
if "!choice!"=="1" call :smart_workflow_guide & goto :pause_and_loop
if "!choice!"=="2" call :show_detailed_status & goto :pause_and_loop
if "!choice!"=="3" call :show_health_report & goto :pause_and_loop
if "!choice!"=="4" call :inspect_changes_diff & goto :pause_and_loop
if "!choice!"=="5" call :stage_changes_menu & goto :pause_and_loop
if "!choice!"=="6" call :unstage_changes_menu & goto :pause_and_loop
if "!choice!"=="7" call :discard_restore_menu & goto :pause_and_loop
if "!choice!"=="8" call :smart_commit & goto :pause_and_loop
if "!choice!"=="9" call :custom_commit & goto :pause_and_loop
if "!choice!"=="10" call :conventional_commit_builder & goto :pause_and_loop
if "!choice!"=="11" call :amend_commit_menu & goto :pause_and_loop
if "!choice!"=="12" call :push_changes_menu & goto :pause_and_loop
if "!choice!"=="13" call :pull_and_fetch_menu & goto :pause_and_loop
if "!choice!"=="14" call :full_two_way_sync & goto :pause_and_loop
if "!choice!"=="15" call :configure_remote_access & goto :pause_and_loop
if "!choice!"=="16" call :branch_manager & goto :pause_and_loop
if "!choice!"=="17" call :merge_rebase_hub & goto :pause_and_loop
if "!choice!"=="18" call :visual_branch_graph & goto :pause_and_loop
if "!choice!"=="19" call :commit_navigation_graph & goto :pause_and_loop
if "!choice!"=="20" call :show_version_recommendation & goto :pause_and_loop
if "!choice!"=="21" call :generate_changelog & goto :pause_and_loop
if "!choice!"=="22" call :stash_manager & goto :pause_and_loop
if "!choice!"=="23" call :undo_and_recovery_menu & goto :pause_and_loop
if "!choice!"=="24" call :abort_rebase_or_merge & goto :pause_and_loop
if "!choice!"=="25" call :configure_git_identity & goto :pause_and_loop
if "!choice!"=="26" call :repo_optimization & goto :pause_and_loop
if "!choice!"=="27" call :display_smart_tips & goto :pause_and_loop
if "!choice!"=="28" call :offline_git_setup_hub & goto :pause_and_loop
if "!choice!"=="29" call :gitignore_manager & goto :pause_and_loop

echo %YELLOW%⚠️ Invalid option selection: '!choice!'. Please choose a number from 0 to 29 (or 'A').%RESET%

:pause_and_loop
echo.
echo %BOLD%%WHITE%Press any key to return to the menu...%RESET%
pause >nul
goto :interactive_loop

:cli_help
call :print_header
echo.
echo Usage: %~nx0 [command]
echo Commands: status, health, sync, commit, push, pull, branch, graph, keifu, tag, abort, help
echo Run without arguments for full interactive dashboard.
echo.
exit /b 0

:exit_app
echo.
echo %GREEN%🎉 Thank you for using Git Project Health Manager!%RESET%
echo %CYAN%Developed with excellence by %BOLD%Degha Houssem Eddine%RESET%
echo.
exit /b 0

rem ============================================================================
rem  GIT REQUIREMENT & REPO CHECKS
rem ============================================================================

:detect_and_setup_portable_git
where git >nul 2>&1
if not errorlevel 1 exit /b 0

rem Check common Windows Git installation paths (in case not in PATH)
if exist "%ProgramFiles%\Git\cmd\git.exe" (
  set "PATH=%ProgramFiles%\Git\cmd;%ProgramFiles%\Git\bin;%ProgramFiles%\Git\usr\bin;!PATH!"
  exit /b 0
)
if exist "%LOCALAPPDATA%\Programs\Git\cmd\git.exe" (
  set "PATH=%LOCALAPPDATA%\Programs\Git\cmd;%LOCALAPPDATA%\Programs\Git\bin;%LOCALAPPDATA%\Programs\Git\usr\bin;!PATH!"
  exit /b 0
)
if exist "%ProgramFiles(x86)%\Git\cmd\git.exe" (
  set "PATH=%ProgramFiles(x86)%\Git\cmd;%ProgramFiles(x86)%\Git\bin;%ProgramFiles(x86)%\Git\usr\bin;!PATH!"
  exit /b 0
)

if exist "%SCRIPT_DIR%\git_system\cmd\git.exe" (
  set "PATH=%SCRIPT_DIR%\git_system\cmd;%SCRIPT_DIR%\git_system\bin;%SCRIPT_DIR%\git_system\usr\bin;!PATH!"
  echo %CYAN%ℹ️  Operating using Portable Git from git_system\cmd%RESET%
  exit /b 0
)
if exist "%SCRIPT_DIR%\git_system\bin\git.exe" (
  set "PATH=%SCRIPT_DIR%\git_system\bin;%SCRIPT_DIR%\git_system\cmd;%SCRIPT_DIR%\git_system\usr\bin;!PATH!"
  echo %CYAN%ℹ️  Operating using Portable Git from git_system\bin%RESET%
  exit /b 0
)
if exist "%SCRIPT_DIR%\git_system\git.exe" (
  set "PATH=%SCRIPT_DIR%\git_system;!PATH!"
  echo %CYAN%ℹ️  Operating using Portable Git from git_system\%RESET%
  exit /b 0
)

rem Check if PortableGit installer package exists and can be extracted
if exist "%SCRIPT_DIR%\git_setup\windows\PortableGit*.7z.exe" (
  echo %YELLOW%⚠️ Portable Git archive detected in git_setup\windows\.%RESET%
  echo Extracting Portable Git into git_system\... Please wait...
  for %%f in ("%SCRIPT_DIR%\git_setup\windows\PortableGit*.7z.exe") do (
    start /wait "" "%%f" -o"%SCRIPT_DIR%\git_system" -y
  )
  if exist "%SCRIPT_DIR%\git_system\cmd\git.exe" (
    set "PATH=%SCRIPT_DIR%\git_system\cmd;%SCRIPT_DIR%\git_system\bin;%SCRIPT_DIR%\git_system\usr\bin;!PATH!"
    echo %GREEN%✅ Portable Git successfully extracted and configured!%RESET%
    exit /b 0
  )
)
exit /b 1

:require_git
  if errorlevel 1 exit /b 1
  call :ensure_repo
  if errorlevel 1 exit /b 1

  if /i "%~1"=="status"    ( call :show_detailed_status & exit /b 0 )
  if /i "%~1"=="health"    ( call :show_health_report & exit /b 0 )
  if /i "%~1"=="sync"      ( call :full_two_way_sync & exit /b 0 )
  if /i "%~1"=="commit"    ( call :smart_commit & exit /b 0 )
  if /i "%~1"=="push"      ( call :push_changes_menu & exit /b 0 )
  if /i "%~1"=="pull"      ( call :pull_and_fetch_menu & exit /b 0 )
  if /i "%~1"=="branch"    ( call :branch_manager & exit /b 0 )
  if /i "%~1"=="graph"     ( call :visual_branch_graph & exit /b 0 )
  if /i "%~1"=="keifu"     ( call :commit_navigation_graph & exit /b 0 )
  if /i "%~1"=="nav"       ( call :commit_navigation_graph & exit /b 0 )
  if /i "%~1"=="navigate"  ( call :commit_navigation_graph & exit /b 0 )
  if /i "%~1"=="tag"       ( call :show_version_recommendation & exit /b 0 )
  if /i "%~1"=="abort"     ( call :abort_rebase_or_merge & exit /b 0 )
  if /i "%~1"=="help"      ( goto :cli_help )
  if /i "%~1"=="-h"        ( goto :cli_help )
  if /i "%~1"=="--help"    ( goto :cli_help )
)

:main_loop
call :require_git
if errorlevel 1 (
  echo.
  echo %RED%Git is required to run Git Project Health Manager.%RESET%
  echo %WHITE%Press any key to exit...%RESET%
  pause >nul
  exit /b 1
)
call :ensure_repo
if errorlevel 1 (
  echo.
  echo %YELLOW%A Git repository is required. Exiting.%RESET%
  echo %WHITE%Press any key to exit...%RESET%
  pause >nul
  exit /b 1
)

:interactive_loop
cls
call :refresh_git_metrics
call :render_dashboard
call :render_main_menu

set "choice="
set /p choice="%BOLD%%CYAN%Select option [0-29, or A to Abort Rebase]: %RESET%"
if "!choice!"=="" goto :interactive_loop
echo.

if /i "!choice!"=="A" call :abort_rebase_or_merge & goto :pause_and_loop
if /i "!choice!"=="abort" call :abort_rebase_or_merge & goto :pause_and_loop
if "!choice!"=="0" goto :exit_app
if "!choice!"=="1" call :smart_workflow_guide & goto :pause_and_loop
if "!choice!"=="2" call :show_detailed_status & goto :pause_and_loop
if "!choice!"=="3" call :show_health_report & goto :pause_and_loop
if "!choice!"=="4" call :inspect_changes_diff & goto :pause_and_loop
if "!choice!"=="5" call :stage_changes_menu & goto :pause_and_loop
if "!choice!"=="6" call :unstage_changes_menu & goto :pause_and_loop
if "!choice!"=="7" call :discard_restore_menu & goto :pause_and_loop
if "!choice!"=="8" call :smart_commit & goto :pause_and_loop
if "!choice!"=="9" call :custom_commit & goto :pause_and_loop
if "!choice!"=="10" call :conventional_commit_builder & goto :pause_and_loop
if "!choice!"=="11" call :amend_commit_menu & goto :pause_and_loop
if "!choice!"=="12" call :push_changes_menu & goto :pause_and_loop
if "!choice!"=="13" call :pull_and_fetch_menu & goto :pause_and_loop
if "!choice!"=="14" call :full_two_way_sync & goto :pause_and_loop
if "!choice!"=="15" call :configure_remote_access & goto :pause_and_loop
if "!choice!"=="16" call :branch_manager & goto :pause_and_loop
if "!choice!"=="17" call :merge_rebase_hub & goto :pause_and_loop
if "!choice!"=="18" call :visual_branch_graph & goto :pause_and_loop
if "!choice!"=="19" call :commit_navigation_graph & goto :pause_and_loop
if "!choice!"=="20" call :show_version_recommendation & goto :pause_and_loop
if "!choice!"=="21" call :generate_changelog & goto :pause_and_loop
if "!choice!"=="22" call :stash_manager & goto :pause_and_loop
if "!choice!"=="23" call :undo_and_recovery_menu & goto :pause_and_loop
if "!choice!"=="24" call :abort_rebase_or_merge & goto :pause_and_loop
if "!choice!"=="25" call :configure_git_identity & goto :pause_and_loop
if "!choice!"=="26" call :repo_optimization & goto :pause_and_loop
if "!choice!"=="27" call :display_smart_tips & goto :pause_and_loop
if "!choice!"=="28" call :offline_git_setup_hub & goto :pause_and_loop
if "!choice!"=="29" call :gitignore_manager & goto :pause_and_loop

echo %YELLOW%⚠️ Invalid option selection: '!choice!'. Please choose a number from 0 to 29 (or 'A').%RESET%

:pause_and_loop
echo.
echo %BOLD%%WHITE%Press any key to return to the menu...%RESET%
pause >nul
goto :interactive_loop

:cli_help
call :print_header
echo.
echo Usage: %~nx0 [command]
echo Commands: status, health, sync, commit, push, pull, branch, graph, keifu, tag, abort, help
echo Run without arguments for full interactive dashboard.
echo.
exit /b 0

:exit_app
echo.
echo %GREEN%🎉 Thank you for using Git Project Health Manager!%RESET%
echo %CYAN%Developed with excellence by %BOLD%Degha Houssem Eddine%RESET%
echo.
exit /b 0

rem ============================================================================
rem  GIT REQUIREMENT & REPO CHECKS
rem ============================================================================

:detect_and_setup_portable_git
where git >nul 2>&1
if not errorlevel 1 exit /b 0

if exist "%SCRIPT_DIR%\git_system\cmd\git.exe" (
  set "PATH=%SCRIPT_DIR%\git_system\cmd;%SCRIPT_DIR%\git_system\bin;%SCRIPT_DIR%\git_system\usr\bin;%PATH%"
  echo %CYAN%ℹ️  System Git not found in PATH. Operating using Portable Git from git_system\cmd%RESET%
  exit /b 0
)
if exist "%SCRIPT_DIR%\git_system\bin\git.exe" (
  set "PATH=%SCRIPT_DIR%\git_system\bin;%SCRIPT_DIR%\git_system\cmd;%SCRIPT_DIR%\git_system\usr\bin;%PATH%"
  echo %CYAN%ℹ️  System Git not found in PATH. Operating using Portable Git from git_system\bin%RESET%
  exit /b 0
)
if exist "%SCRIPT_DIR%\git_system\git.exe" (
  set "PATH=%SCRIPT_DIR%\git_system;%PATH%"
  echo %CYAN%ℹ️  System Git not found in PATH. Operating using Portable Git from git_system\%RESET%
  exit /b 0
)

rem Check if PortableGit installer package exists and can be extracted
if exist "%SCRIPT_DIR%\git_setup\windows\PortableGit*.7z.exe" (
  echo %YELLOW%⚠️ PortableGit archive detected in git_setup\windows\.%RESET%
  echo Extracting Portable Git into git_system\...
  for %%f in ("%SCRIPT_DIR%\git_setup\windows\PortableGit*.7z.exe") do (
    "%%f" -o"%SCRIPT_DIR%\git_system" -y >nul 2>&1
  )
  if exist "%SCRIPT_DIR%\git_system\cmd\git.exe" (
    set "PATH=%SCRIPT_DIR%\git_system\cmd;%SCRIPT_DIR%\git_system\bin;%SCRIPT_DIR%\git_system\usr\bin;%PATH%"
    echo %GREEN%✅ Portable Git successfully extracted and configured!%RESET%
    exit /b 0
  )
)
exit /b 1

:require_git
call :detect_and_setup_portable_git
if not errorlevel 1 exit /b 0

echo %RED%❌ Git executable was not found on your system or in git_system\.%RESET%
echo %YELLOW%Would you like to run the Offline Git ^& Portable Setup Hub now?%RESET%
set "run_off="
set /p run_off="Launch Offline Git Installer? [Y/n]: "
if /i not "!run_off!"=="n" (
  call :offline_git_setup_hub
  call :detect_and_setup_portable_git
  if not errorlevel 1 exit /b 0
)
exit /b 1

:offline_git_setup_hub
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%📦 OFFLINE GIT INSTALLER ^& PORTABLE SETUP HUB%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo This module installs Git 100%% offline or configures Portable Git in git_system\
echo.
echo   1) 🪟 Windows Offline Installation (Install from git_setup\windows\Git-*.exe)
echo   2) 🐧 Linux / Ubuntu Instructions (For WSL or Linux systems)
echo   3) 💼 Setup Portable Git in git_system\ (Extract PortableGit archive)
echo   4) 📄 View Offline Setup Guide
echo   5) 🌐 Download Git Installers ^& Portable Versions
echo   0) Cancel
set "os_sel="
set /p os_sel="Select option [0-5]: "
if "!os_sel!"=="1" (
  echo Searching for Windows Git Installer in git_setup\windows\...
  set "found_inst="
  for %%f in ("%SCRIPT_DIR%\git_setup\windows\Git-*.exe") do (
    set "found_inst=%%f"
    echo Found installer: %%~nxf
    echo Executing offline installer silently...
    start /wait "" "%%f" /VERYSILENT /NORESTART /NOCANCEL /SP-
    echo %GREEN%✅ Offline Windows Git Installer launched.%RESET%
  )
  if not defined found_inst (
    echo %YELLOW%⚠️ No Windows Git installer (Git-*.exe) found in git_setup\windows\%RESET%
    echo Please copy Git-2.x.x-64-bit.exe into: %SCRIPT_DIR%\git_setup\windows\
  )
)
if "!os_sel!"=="2" (
  echo %CYAN%For Linux / Ubuntu offline installation:%RESET%
  echo 1. Copy .deb packages into git_setup\linux\
  echo 2. Run: sudo dpkg -i git_setup/linux/*.deb
)
if "!os_sel!"=="3" (
  echo %CYAN%Setting up Portable Git folder...%RESET%
  if not exist "%SCRIPT_DIR%\git_system" mkdir "%SCRIPT_DIR%\git_system"
  if not exist "%SCRIPT_DIR%\git_system\cmd" mkdir "%SCRIPT_DIR%\git_system\cmd"
  if not exist "%SCRIPT_DIR%\git_system\bin" mkdir "%SCRIPT_DIR%\git_system\bin"
  
  set "found_7z="
  for %%f in ("%SCRIPT_DIR%\git_setup\windows\PortableGit*.7z.exe") do (
    set "found_7z=%%f"
    echo Extracting %%~nxf to git_system\...
    start /wait "" "%%f" -o"%SCRIPT_DIR%\git_system" -y
    echo %GREEN%✅ Portable Git extracted into: %SCRIPT_DIR%\git_system\%RESET%
  )
  if not defined found_7z (
    echo %YELLOW%Place portable git archive (PortableGit-*.7z.exe) in git_setup\windows\ or binaries in git_system\%RESET%
  )
  call :detect_and_setup_portable_git
)
if "!os_sel!"=="4" (
  if exist "%SCRIPT_DIR%\git_setup\README.md" type "%SCRIPT_DIR%\git_setup\README.md"
)
if "!os_sel!"=="5" (
  echo %CYAN%Downloading Git installers and portable versions...%RESET%
  if not exist "%SCRIPT_DIR%\git_setup\windows" mkdir "%SCRIPT_DIR%\git_setup\windows"
  if not exist "%SCRIPT_DIR%\git_setup\linux" mkdir "%SCRIPT_DIR%\git_setup\linux"
  
  echo %YELLOW%Downloading Windows Portable Git...%RESET%
  curl -L -o "%SCRIPT_DIR%\git_setup\windows\PortableGit-2.45.2-64-bit.7z.exe" "https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/PortableGit-2.45.2-64-bit.7z.exe"
  
  echo %YELLOW%Downloading Windows Git Installer...%RESET%
  curl -L -o "%SCRIPT_DIR%\git_setup\windows\Git-2.45.2-64-bit.exe" "https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-64-bit.exe"
  
  echo %YELLOW%Downloading Linux source...%RESET%
  curl -L -o "%SCRIPT_DIR%\git_setup\linux\git-2.45.2.tar.gz" "https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.45.2.tar.gz"
  
  echo %GREEN%✅ Downloads complete.%RESET%
)
goto :eof

:ensure_repo
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo %YELLOW%⚠️ Current directory is not a Git repository (%CD%).%RESET%
  set "init_ans="
  set /p init_ans="Initialize a new Git repository here? [Y/n]: "
  if /i "!init_ans!"=="n" (
    echo %RED%Operation aborted.%RESET%
    exit /b 1
  )
  git init
  echo %GREEN%✅ Initialized empty Git repository in %CD%%RESET%
)
exit /b 0

rem ============================================================================
rem  INTERACTIVE SELECTOR HELPERS
rem ============================================================================

:select_branch
rem Usage: call :select_branch "Prompt text" [include_remotes: 0 or 1]
rem Output: SELECTED_BRANCH
set "SELECTED_BRANCH="
set "SEL_PROMPT=%~1"
if "!SEL_PROMPT!"=="" set "SEL_PROMPT=Select a branch"
set "INC_REM=%~2"

echo.
echo %CYAN%%BOLD%📋 Available Branches List:%RESET%
set /a b_count=0
for /f "tokens=*" %%b in ('git for-each-ref --format^="%%(refname:short)" refs/heads/ 2^>nul') do (
  set /a b_count+=1
  set "b_item_!b_count!=%%b"
  set "b_icon=🌿"
  set "b_tag="
  if "%%b"=="!CURRENT_BRANCH!" (
    set "b_icon=⭐"
    set "b_tag= %GREEN%[ACTIVE]%RESET%"
  )
  set "b_info="
  for /f "tokens=*" %%c in ('git log -1 --format^="%%h - %%s (%%cr)" "%%b" 2^>nul') do set "b_info=%%c"
  if defined b_info set "b_info=!b_info:~0,45!"
  echo   %BOLD%!b_count!)%RESET% !b_icon! %%b!b_tag! %GRAY%!b_info!%RESET%
)

if "%INC_REM%"=="1" (
  for /f "tokens=*" %%r in ('git for-each-ref --format^="%%(refname:short)" refs/remotes/ 2^>nul') do (
    echo %%r | findstr /i "HEAD" >nul 2>&1
    if errorlevel 1 (
      set /a b_count+=1
      set "b_item_!b_count!=%%r"
      set "b_info="
      for /f "tokens=*" %%c in ('git log -1 --format^="%%h - %%s (%%cr)" "%%r" 2^>nul') do set "b_info=%%c"
      if defined b_info set "b_info=!b_info:~0,45!"
      echo   %BOLD%!b_count!)%RESET% 🌐 %%r %BLUE%[REMOTE]%RESET% %GRAY%!b_info!%RESET%
    )
  )
)

if !b_count! EQU 0 (
  echo %YELLOW%No branches found.%RESET%
  exit /b 1
)

echo   %BOLD%M)%RESET% ✍️  Enter branch name manually
echo   %BOLD%0)%RESET% ❌ Cancel
echo.
set "b_sel="
set /p b_sel="%BOLD%%YELLOW%!SEL_PROMPT! [1-!b_count!, M, 0]: %RESET%"
if "!b_sel!"=="" exit /b 1
if "!b_sel!"=="0" exit /b 1
if /i "!b_sel!"=="M" (
  set /p SELECTED_BRANCH="Enter branch name manually: "
  if "!SELECTED_BRANCH!"=="" exit /b 1
  exit /b 0
)

set "SELECTED_BRANCH=!b_item_%b_sel%!"
if "!SELECTED_BRANCH!"=="" (
  echo %YELLOW%Invalid selection.%RESET%
  exit /b 1
)
exit /b 0

:select_commit
rem Usage: call :select_commit "Prompt text" [count]
rem Output: SELECTED_COMMIT
set "SELECTED_COMMIT="
set "C_PROMPT=%~1"
if "!C_PROMPT!"=="" set "C_PROMPT=Select a commit"
set "C_COUNT=%~2"
if "!C_COUNT!"=="" set "C_COUNT=15"

echo.
echo %CYAN%%BOLD%📜 Commit History Timeline (Select a point in time):%RESET%
set /a c_count=0
for /f "tokens=1* delims= " %%a in ('git log -n !C_COUNT! --format^="%%h %%s (%%cr)" 2^>nul') do (
  set /a c_count+=1
  set "c_item_!c_count!=%%a"
  echo   %BOLD%!c_count!)%RESET% %YELLOW%%%a%RESET% - %%b
)

if !c_count! EQU 0 (
  echo %YELLOW%No commits found in history.%RESET%
  exit /b 1
)

echo   %BOLD%M)%RESET% ✍️  Enter commit hash manually
echo   %BOLD%0)%RESET% ❌ Cancel
echo.
set "c_sel="
set /p c_sel="%BOLD%%YELLOW%!C_PROMPT! [1-!c_count!, M, 0]: %RESET%"
if "!c_sel!"=="" exit /b 1
if "!c_sel!"=="0" exit /b 1
if /i "!c_sel!"=="M" (
  set /p SELECTED_COMMIT="Enter commit hash manually: "
  if "!SELECTED_COMMIT!"=="" exit /b 1
  exit /b 0
)

set "SELECTED_COMMIT=!c_item_%c_sel%!"
if "!SELECTED_COMMIT!"=="" (
  echo %YELLOW%Invalid selection.%RESET%
  exit /b 1
)
exit /b 0

:select_file
rem Usage: call :select_file "Prompt text" "filter: all|staged|unstaged"
rem Output: SELECTED_FILE
set "SELECTED_FILE="
set "F_PROMPT=%~1"
if "!F_PROMPT!"=="" set "F_PROMPT=Select a file"
set "F_FILTER=%~2"
if "!F_FILTER!"=="" set "F_FILTER=all"

set /a f_count=0
echo.
echo %CYAN%%BOLD%📁 Changed Files List (!F_FILTER!):%RESET%
for /f "delims=" %%L in ('git status --porcelain 2^>nul') do (
  set "f_line=%%L"
  set "f_code=!f_line:~0,2!"
  set "f_name=!f_line:~3!"
  set "f_inc=0"

  if "!F_FILTER!"=="staged" (
    set "x=!f_code:~0,1!"
    if not "!x!"==" " if not "!x!"=="?" set "f_inc=1"
  ) else if "!F_FILTER!"=="unstaged" (
    set "y=!f_code:~1,1!"
    if not "!y!"==" " if not "!y!"=="?" set "f_inc=1"
  ) else (
    set "f_inc=1"
  )

  if "!f_inc!"=="1" (
    set /a f_count+=1
    set "f_item_!f_count!=!f_name!"
    set "f_icon=📝"
    if "!f_code!"=="??" set "f_icon=❓ [Untracked]"
    if "!f_code:~0,1!"=="A" set "f_icon=🟩 [Added]    "
    if "!f_code:~1,1!"=="A" set "f_icon=🟩 [Added]    "
    if "!f_code:~0,1!"=="D" set "f_icon=🟥 [Deleted]  "
    if "!f_code:~1,1!"=="D" set "f_icon=🟥 [Deleted]  "
    if "!f_code:~0,1!"=="M" set "f_icon=🟨 [Modified] "
    if "!f_code:~1,1!"=="M" set "f_icon=🟨 [Modified] "
    echo   %BOLD%!f_count!)%RESET% !f_icon! !f_name!
  )
)

if !f_count! EQU 0 (
  echo %YELLOW%No matching files found for filter: !F_FILTER!.%RESET%
  exit /b 1
)

echo   %BOLD%A)%RESET% ➕ Select ALL files
echo   %BOLD%M)%RESET% ✍️  Enter file path manually
echo   %BOLD%0)%RESET% ❌ Cancel
echo.
set "f_sel="
set /p f_sel="%BOLD%%YELLOW%!F_PROMPT! [1-!f_count!, A, M, 0]: %RESET%"
if "!f_sel!"=="" exit /b 1
if "!f_sel!"=="0" exit /b 1
if /i "!f_sel!"=="A" (
  set "SELECTED_FILE=ALL"
  exit /b 0
)
if /i "!f_sel!"=="M" (
  set /p SELECTED_FILE="Enter file path manually: "
  if "!SELECTED_FILE!"=="" exit /b 1
  exit /b 0
)

set "SELECTED_FILE=!f_item_%f_sel%!"
if "!SELECTED_FILE!"=="" (
  echo %YELLOW%Invalid selection.%RESET%
  exit /b 1
)
exit /b 0

:select_stash
set "SELECTED_STASH="
echo.
echo %CYAN%%BOLD%🗄️ Available Stashes:%RESET%
set /a st_count=0
for /f "tokens=1* delims=:" %%a in ('git stash list 2^>nul') do (
  set /a st_count+=1
  set "st_ref_!st_count!=%%a"
  echo   %BOLD%!st_count!)%RESET% 🗄️  %%a:%%b
)
if !st_count! EQU 0 (
  echo %YELLOW%No stashes found in this repository.%RESET%
  exit /b 1
)
echo   %BOLD%M)%RESET% ✍️  Enter stash ref manually (e.g. stash@{0})
echo   %BOLD%0)%RESET% ❌ Cancel
echo.
set "st_sel="
set /p st_sel="%BOLD%%YELLOW%Select stash [1-!st_count!, M, 0]: %RESET%"
if "!st_sel!"=="" exit /b 1
if "!st_sel!"=="0" exit /b 1
if /i "!st_sel!"=="M" (
  set /p SELECTED_STASH="Enter stash ref: "
  if "!SELECTED_STASH!"=="" exit /b 1
  exit /b 0
)
set "SELECTED_STASH=!st_ref_%st_sel%!"
if "!SELECTED_STASH!"=="" (
  echo %YELLOW%Invalid selection.%RESET%
  exit /b 1
)
exit /b 0

:select_tag
set "SELECTED_TAG="
echo.
echo %CYAN%%BOLD%🏷️ Available Tags:%RESET%
set /a tg_count=0
for /f "tokens=*" %%t in ('git tag -l --sort^=-v:refname 2^>nul') do (
  set /a tg_count+=1
  set "tg_item_!tg_count!=%%t"
  set "tg_info="
  for /f "tokens=*" %%c in ('git log -1 --format^="%%h - %%s (%%cr)" "%%t" 2^>nul') do set "tg_info=%%c"
  if defined tg_info set "tg_info=!tg_info:~0,45!"
  echo   %BOLD%!tg_count!)%RESET% 🏷️  %%t %GRAY%!tg_info!%RESET%
)
if !tg_count! EQU 0 (
  echo %YELLOW%No tags found in this repository.%RESET%
  exit /b 1
)
echo   %BOLD%M)%RESET% ✍️  Enter tag name manually
echo   %BOLD%0)%RESET% ❌ Cancel
echo.
set "tg_sel="
set /p tg_sel="%BOLD%%YELLOW%Select tag [1-!tg_count!, M, 0]: %RESET%"
if "!tg_sel!"=="" exit /b 1
if "!tg_sel!"=="0" exit /b 1
if /i "!tg_sel!"=="M" (
  set /p SELECTED_TAG="Enter tag name manually: "
  if "!SELECTED_TAG!"=="" exit /b 1
  exit /b 0
)
set "SELECTED_TAG=!tg_item_%tg_sel%!"
if "!SELECTED_TAG!"=="" (
  echo %YELLOW%Invalid selection.%RESET%
  exit /b 1
)
exit /b 0

:select_remote
set "SELECTED_REMOTE="
echo.
echo %CYAN%%BOLD%🌐 Configured Remotes:%RESET%
set /a rm_count=0
for /f "tokens=*" %%r in ('git remote 2^>nul') do (
  set /a rm_count+=1
  set "rm_item_!rm_count!=%%r"
  set "rm_url="
  for /f "tokens=*" %%u in ('git remote get-url "%%r" 2^>nul') do set "rm_url=%%u"
  echo   %BOLD%!rm_count!)%RESET% 🌐 %%r → !rm_url!
)
if !rm_count! EQU 0 (
  echo %YELLOW%No remotes configured.%RESET%
  exit /b 1
)
echo   %BOLD%M)%RESET% ✍️  Enter remote name manually
echo   %BOLD%0)%RESET% ❌ Cancel
echo.
set "rm_sel="
set /p rm_sel="%BOLD%%YELLOW%Select remote [1-!rm_count!, M, 0]: %RESET%"
if "!rm_sel!"=="" exit /b 1
if "!rm_sel!"=="0" exit /b 1
if /i "!rm_sel!"=="M" (
  set /p SELECTED_REMOTE="Enter remote name manually: "
  if "!SELECTED_REMOTE!"=="" exit /b 1
  exit /b 0
)
set "SELECTED_REMOTE=!rm_item_%rm_sel%!"
if "!SELECTED_REMOTE!"=="" (
  echo %YELLOW%Invalid selection.%RESET%
  exit /b 1
)
exit /b 0

rem ============================================================================
rem  METRICS REFRESH & DIAGNOSTICS
rem ============================================================================

:refresh_git_metrics
for %%F in ("%CD%") do set "PROJECT_NAME=%%~nxF"
set "REPO_PATH=%CD%"

set "HAS_COMMITS=0"
git rev-parse HEAD >nul 2>&1
if not errorlevel 1 set "HAS_COMMITS=1"

set "CURRENT_BRANCH="
for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set "CURRENT_BRANCH=%%b"
if "!CURRENT_BRANCH!"=="" (
  for /f "tokens=*" %%h in ('git rev-parse --short HEAD 2^>nul') do set "CURRENT_BRANCH=DETACHED (%%h)"
  if "!CURRENT_BRANCH!"=="" set "CURRENT_BRANCH=HEAD (empty repo)"
)

set "UPSTREAM_BRANCH="
for /f "tokens=*" %%u in ('git rev-parse --abbrev-ref --symbolic-full-name @{u} 2^>nul') do set "UPSTREAM_BRANCH=%%u"
if "!UPSTREAM_BRANCH!"=="" set "UPSTREAM_BRANCH=none"

set "REMOTE_NAME=origin"
set "REMOTE_URL="
for /f "tokens=*" %%r in ('git remote 2^>nul') do (
  if "!REMOTE_NAME!"=="origin" set "REMOTE_NAME=%%r"
)
for /f "tokens=*" %%r in ('git remote get-url "!REMOTE_NAME!" 2^>nul') do set "REMOTE_URL=%%r"
if "!REMOTE_URL!"=="" (
  set "REMOTE_NAME=not configured"
  set "REMOTE_URL=none"
)

set "LATEST_TAG=v0.0.0"
for /f "tokens=*" %%t in ('git describe --tags --abbrev=0 2^>nul') do set "LATEST_TAG=%%t"

set "COMMITS_SINCE_TAG=0"
if not "!LATEST_TAG!"=="v0.0.0" (
  for /f "tokens=*" %%c in ('git rev-list !LATEST_TAG!..HEAD --count 2^>nul') do set "COMMITS_SINCE_TAG=%%c"
) else (
  if !HAS_COMMITS! EQU 1 (
    for /f "tokens=*" %%c in ('git rev-list --count HEAD 2^>nul') do set "COMMITS_SINCE_TAG=%%c"
  )
)

set "LAST_COMMIT_HASH=none"
set "LAST_COMMIT_MSG=No commits yet"
set "LAST_COMMIT_AGE=none"
if !HAS_COMMITS! EQU 1 (
  for /f "tokens=1* delims= " %%a in ('git log -1 --format^="%%h %%s" 2^>nul') do (
    set "LAST_COMMIT_HASH=%%a"
    set "LAST_COMMIT_MSG=%%b"
  )
  for /f "tokens=*" %%a in ('git log -1 --format^="%%cr" 2^>nul') do set "LAST_COMMIT_AGE=%%a"
)

set /a UNCOMMITTED_FILES=0
set /a STAGED_FILES=0
set /a UNSTAGED_FILES=0
set /a UNTRACKED_FILES=0
set /a FILES_ADDED=0
set /a FILES_MODIFIED=0
set /a FILES_DELETED=0
set /a CONFLICTED_FILES=0

rem Preserving leading spaces by using delims=
for /f "delims=" %%L in ('git status --porcelain 2^>nul') do (
  set "line=%%L"
  set /a UNCOMMITTED_FILES+=1
  set "xy=!line:~0,2!"
  set "x=!line:~0,1!"
  set "y=!line:~1,1!"

  if "!xy!"=="??" (
    set /a UNTRACKED_FILES+=1
    set /a FILES_ADDED+=1
  ) else (
    if not "!x!"==" " if not "!x!"=="?" (
      set /a STAGED_FILES+=1
      if "!x!"=="A" set /a FILES_ADDED+=1
      if "!x!"=="D" set /a FILES_DELETED+=1
      if "!x!"=="M" set /a FILES_MODIFIED+=1
      if "!x!"=="R" set /a FILES_MODIFIED+=1
    )
    if not "!y!"==" " if not "!y!"=="?" (
      set /a UNSTAGED_FILES+=1
      if "!y!"=="M" set /a FILES_MODIFIED+=1
      if "!y!"=="D" set /a FILES_DELETED+=1
    )
    if "!xy!"=="UU" set /a CONFLICTED_FILES+=1
    if "!xy!"=="AA" set /a CONFLICTED_FILES+=1
    if "!xy!"=="DD" set /a CONFLICTED_FILES+=1
    if "!xy!"=="UD" set /a CONFLICTED_FILES+=1
    if "!xy!"=="DU" set /a CONFLICTED_FILES+=1
  )
)

set /a LINES_ADDED=0
set /a LINES_REMOVED=0
for /f "tokens=1,2" %%A in ('git diff --numstat 2^>nul') do (
  set /a LINES_ADDED+=%%A 2>nul
  set /a LINES_REMOVED+=%%B 2>nul
)
for /f "tokens=1,2" %%A in ('git diff --cached --numstat 2^>nul') do (
  set /a LINES_ADDED+=%%A 2>nul
  set /a LINES_REMOVED+=%%B 2>nul
)

set /a BEHIND_COUNT=0
set /a AHEAD_COUNT=0
set /a UNPUSHED_COMMITS=0

if not "!UPSTREAM_BRANCH!"=="none" (
  for /f "tokens=1" %%a in ('git rev-list --count @{u}..HEAD 2^>nul') do set "AHEAD_COUNT=%%a"
  for /f "tokens=1" %%a in ('git rev-list --count HEAD..@{u} 2^>nul') do set "BEHIND_COUNT=%%a"
  set "UNPUSHED_COMMITS=!AHEAD_COUNT!"
) else (
  if !HAS_COMMITS! EQU 1 if not "!REMOTE_NAME!"=="not configured" (
    git rev-parse "refs/remotes/!REMOTE_NAME!/!CURRENT_BRANCH!" >nul 2>&1
    if not errorlevel 1 (
      for /f "tokens=1" %%a in ('git rev-list --count "refs/remotes/!REMOTE_NAME!/!CURRENT_BRANCH!..HEAD" 2^>nul') do set "UNPUSHED_COMMITS=%%a"
      for /f "tokens=1" %%a in ('git rev-list --count "HEAD..refs/remotes/!REMOTE_NAME!/!CURRENT_BRANCH!" 2^>nul') do set "BEHIND_COUNT=%%a"
      set "AHEAD_COUNT=!UNPUSHED_COMMITS!"
    ) else (
      for /f "tokens=1" %%a in ('git rev-list --count HEAD 2^>nul') do set "UNPUSHED_COMMITS=%%a"
      set "AHEAD_COUNT=!UNPUSHED_COMMITS!"
    )
  )
)

rem Check active rebase or merge
set "IS_REBASING=0"
set "IS_MERGING=0"
set "GIT_DIR=.git"
for /f "tokens=*" %%g in ('git rev-parse --git-dir 2^>nul') do set "GIT_DIR=%%g"
if exist "!GIT_DIR!\rebase-merge" set "IS_REBASING=1"
if exist "!GIT_DIR!\rebase-apply" set "IS_REBASING=1"
if exist "!GIT_DIR!\MERGE_HEAD" set "IS_MERGING=1"

call :calculate_health_score
call :evaluate_workflow_state
goto :eof

:calculate_health_score
set /a HEALTH_SCORE=100

if !CONFLICTED_FILES! GTR 0 set /a HEALTH_SCORE-=30
if !BEHIND_COUNT! GTR 0 set /a HEALTH_SCORE-=15
if !UNCOMMITTED_FILES! GTR 0 set /a HEALTH_SCORE-=10
if !UNSTAGED_FILES! GTR 5 set /a HEALTH_SCORE-=5
if !UNPUSHED_COMMITS! GTR 0 set /a HEALTH_SCORE-=5
echo !CURRENT_BRANCH! | findstr /i "DETACHED" >nul 2>&1
if not errorlevel 1 set /a HEALTH_SCORE-=15
if "!REMOTE_NAME!"=="not configured" set /a HEALTH_SCORE-=5
if !COMMITS_SINCE_TAG! GEQ 10 set /a HEALTH_SCORE-=5
if !LINES_ADDED! GTR 3000 set /a HEALTH_SCORE-=10

if !HEALTH_SCORE! LSS 0 set "HEALTH_SCORE=0"
if !HEALTH_SCORE! GTR 100 set "HEALTH_SCORE=100"

if !HEALTH_SCORE! GEQ 90 (
  set "HEALTH_COLOR=%GREEN%"
  set "HEALTH_STATUS=🟢 EXCELLENT"
  set "RISK_LEVEL=🟢 Low Risk"
) else if !HEALTH_SCORE! GEQ 75 (
  set "HEALTH_COLOR=%GREEN%"
  set "HEALTH_STATUS=🟢 HEALTHY"
  set "RISK_LEVEL=🟢 Low Risk"
) else if !HEALTH_SCORE! GEQ 60 (
  set "HEALTH_COLOR=%YELLOW%"
  set "HEALTH_STATUS=🟡 ATTENTION NEEDED"
  set "RISK_LEVEL=🟡 Medium Risk"
) else if !HEALTH_SCORE! GEQ 40 (
  set "HEALTH_COLOR=%YELLOW%"
  set "HEALTH_STATUS=🟠 MODERATE RISK"
  set "RISK_LEVEL=🟠 High Risk"
) else (
  set "HEALTH_COLOR=%RED%"
  set "HEALTH_STATUS=🔴 CRITICAL"
  set "RISK_LEVEL=🔴 Critical Risk"
)
goto :eof

:evaluate_workflow_state
if !IS_REBASING! EQU 1 (
  set "WORKFLOW_STATE=REBASE_IN_PROGRESS"
  set "NEXT_ACTION=⏹️  Abort Rebase to go back (Option 23 or 'A')"
  set "ADVISORY=Git rebase is in progress! Type 'A' or Option 23 to ABORT & GO BACK safely."
  goto :eof
)
if !IS_MERGING! EQU 1 (
  set "WORKFLOW_STATE=MERGE_IN_PROGRESS"
  set "NEXT_ACTION=⏹️  Abort Merge to go back (Option 23 or 'A')"
  set "ADVISORY=Git merge in progress with conflicts! Type 'A' or Option 23 to ABORT & GO BACK safely."
  goto :eof
)
if !CONFLICTED_FILES! GTR 0 (
  set "WORKFLOW_STATE=CONFLICT"
  set "NEXT_ACTION=🚨 Resolve conflicts or abort rebase/merge (Option 23)"
  set "ADVISORY=Conflicts detected (!CONFLICTED_FILES! files)! Resolve them, or abort rebase/merge."
  goto :eof
)
echo !CURRENT_BRANCH! | findstr /i "DETACHED" >nul 2>&1
if not errorlevel 1 (
  set "WORKFLOW_STATE=DETACHED"
  set "NEXT_ACTION=🌿 Switch to named branch (git switch -c <name>)"
  set "ADVISORY=You are in detached HEAD state. Create or switch to a branch to keep commits."
  goto :eof
)
if !HAS_COMMITS! EQU 0 (
  set "WORKFLOW_STATE=FIRST_COMMIT"
  set "NEXT_ACTION=📝 Stage files & create initial commit"
  set "ADVISORY=Empty repository. Stage your files and make your first initial commit."
  goto :eof
)
if !UNCOMMITTED_FILES! GTR 0 (
  if !UNCOMMITTED_FILES! GEQ 20 (
    set "WORKFLOW_STATE=BRANCH_RECOMMENDED"
    set "NEXT_ACTION=🌿 Create dedicated branch for large changeset"
    set "ADVISORY=Large change detected. A dedicated feature branch is recommended."
    goto :eof
  )
  if !STAGED_FILES! GTR 0 if !UNSTAGED_FILES! EQU 0 if !UNTRACKED_FILES! EQU 0 (
    set "WORKFLOW_STATE=READY_TO_COMMIT"
    set "NEXT_ACTION=✨ Create commit with meaningful message"
    set "ADVISORY=All changes staged! Ready to create a meaningful commit."
    goto :eof
  )
  if !STAGED_FILES! GTR 0 (
    set "WORKFLOW_STATE=PARTIALLY_STAGED"
    set "NEXT_ACTION=📦 Stage remaining files or commit staged files"
    set "ADVISORY=Some files staged. Review remaining unstaged files or commit staged work."
    goto :eof
  )
  set "WORKFLOW_STATE=CHANGES_PENDING"
  set "NEXT_ACTION=👀 Review diff and stage changes (git add)"
  set "ADVISORY=Uncommitted changes detected. Review diff and stage files when ready."
  goto :eof
)
if !BEHIND_COUNT! GTR 0 (
  set "WORKFLOW_STATE=PULL_REQUIRED"
  set "NEXT_ACTION=⬇️  Pull remote changes (git pull --rebase)"
  set "ADVISORY=Local branch is behind remote by !BEHIND_COUNT! commit(s). Pull or rebase."
  goto :eof
)
if !UNPUSHED_COMMITS! GTR 0 (
  set "WORKFLOW_STATE=PUSH_READY"
  set "NEXT_ACTION=⬆️  Push local commits to remote (git push)"
  set "ADVISORY=!UNPUSHED_COMMITS! commit(s) ready to push. Synchronize with remote."
  goto :eof
)
if "!REMOTE_NAME!"=="not configured" (
  set "WORKFLOW_STATE=NO_REMOTE"
  set "NEXT_ACTION=🌐 Configure remote repository URL"
  set "ADVISORY=Local repo is healthy. Connect to a remote repository (GitHub/GitLab/Bitbucket)."
  goto :eof
)
if !COMMITS_SINCE_TAG! GEQ 6 (
  set "WORKFLOW_STATE=CHECKPOINT"
  set "NEXT_ACTION=🏷️ Create a new version release tag"
  set "ADVISORY=Healthy checkpoint (!COMMITS_SINCE_TAG! commits since tag). Consider a release version tag."
  goto :eof
)
set "WORKFLOW_STATE=HEALTHY"
set "NEXT_ACTION=✅ Continue normal development cycle"
set "ADVISORY=Repository is clean and fully synchronized. Ready for development!"
goto :eof

rem ============================================================================
rem  DASHBOARD & MENU RENDERING
rem ============================================================================

:render_health_bar
set /a total_blocks=25
set /a filled=HEALTH_SCORE * total_blocks / 100
set "H_BAR="
set "B_COLOR=%GREEN%"
if !HEALTH_SCORE! LSS 50 set "B_COLOR=%RED%"
if !HEALTH_SCORE! GEQ 50 if !HEALTH_SCORE! LSS 75 set "B_COLOR=%YELLOW%"

for /l %%i in (1,1,!filled!) do set "H_BAR=!H_BAR!█"
set /a empty=total_blocks - filled
set "E_BAR="
if !empty! GTR 0 (
  for /l %%i in (1,1,!empty!) do set "E_BAR=!E_BAR!░"
)
set "HEALTH_BAR=!B_COLOR!!H_BAR!%GRAY%!E_BAR!%RESET%"
goto :eof

:render_workflow_pipeline
set "p_init=○" & set "p_health=○" & set "p_sync=○" & set "p_stage=○" & set "p_commit=○" & set "p_tag=○" & set "p_push=○"

set "p_init=%GREEN%✓%RESET%"
if !HEALTH_SCORE! GEQ 75 (set "p_health=%GREEN%✓%RESET%") else (set "p_health=%YELLOW%●%RESET%")
if !BEHIND_COUNT! EQU 0 (set "p_sync=%GREEN%✓%RESET%") else (set "p_sync=%RED%●%RESET%")

if !UNCOMMITTED_FILES! EQU 0 (
  set "p_stage=%GREEN%✓%RESET%"
  set "p_commit=%GREEN%✓%RESET%"
) else if !STAGED_FILES! GTR 0 if !UNSTAGED_FILES! EQU 0 if !UNTRACKED_FILES! EQU 0 (
  set "p_stage=%GREEN%✓%RESET%"
  set "p_commit=%YELLOW%●%RESET%"
) else (
  set "p_stage=%YELLOW%●%RESET%"
  set "p_commit=○"
)

if !COMMITS_SINCE_TAG! EQU 0 (set "p_tag=%GREEN%✓%RESET%") else (set "p_tag=○")
if !UNPUSHED_COMMITS! EQU 0 (set "p_push=%GREEN%✓%RESET%") else (set "p_push=%YELLOW%●%RESET%")

echo   !p_init! INIT → !p_health! HEALTH → !p_sync! SYNC → !p_stage! STAGE → !p_commit! COMMIT → !p_tag! TAG → !p_push! PUSH
goto :eof

:print_header
echo %CYAN%╔════════════════════════════════════════════════════════════════════════════════════╗%RESET%
echo %CYAN%║%RESET%                   %BOLD%🩺 GIT PROJECT HEALTH ^& WORKFLOW MANAGER%RESET%                   %CYAN%║%RESET%
echo %CYAN%║%RESET%                 %GRAY%Intelligent DevOps Automation • by Degha Houssem Eddine%RESET%      %CYAN%║%RESET%
echo %CYAN%╚════════════════════════════════════════════════════════════════════════════════════╝%RESET%
goto :eof

:render_dashboard
call :render_health_bar
call :print_header
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%📁 PROJECT ^& ENVIRONMENT%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo   Project Name       │ %GREEN%%BOLD%!PROJECT_NAME!%RESET% %GRAY%(!REPO_PATH!)%RESET%
echo   Current Branch     │ %MAGENTA%%BOLD%!CURRENT_BRANCH!%RESET%  %GRAY%Upstream:%RESET% %CYAN%!UPSTREAM_BRANCH!%RESET%
echo   Remote             │ %CYAN%!REMOTE_NAME!%RESET% → %BLUE%!REMOTE_URL!%RESET%
echo   Version / Tag      │ %YELLOW%!LATEST_TAG!%RESET% %GRAY%(!COMMITS_SINCE_TAG! commits since tag)%RESET%
if !HAS_COMMITS! EQU 1 (
  echo   Last Commit        │ %CYAN%!LAST_COMMIT_HASH!%RESET% %WHITE%!LAST_COMMIT_MSG:~0,45!%RESET% %GRAY%(!LAST_COMMIT_AGE!)%RESET%
) else (
  echo   Last Commit        │ %YELLOW%No commits made yet%RESET%
)
echo.
echo %BOLD%🏥 HEALTH ^& WORKFLOW STATUS%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo   Health Score       │ !HEALTH_BAR!  !HEALTH_COLOR!%BOLD%!HEALTH_STATUS! (!HEALTH_SCORE!/100)%RESET%

set "WT_BADGE=%GREEN%🟢 Clean%RESET%"
if !CONFLICTED_FILES! GTR 0 (
  set "WT_BADGE=%RED%🔴 Conflicted (!CONFLICTED_FILES!)%RESET%"
) else if !UNCOMMITTED_FILES! GTR 0 (
  set "WT_BADGE=%YELLOW%🟡 Modified (!UNCOMMITTED_FILES! files)%RESET%"
)
echo   Working Tree       │ !WT_BADGE!  │  Risk Level   │ !RISK_LEVEL!

if !BEHIND_COUNT! EQU 0 if !UNPUSHED_COMMITS! EQU 0 (
  set "SYNC_TXT=%GREEN%✅ Fully in sync with remote%RESET%"
) else (
  set "SYNC_TXT=%YELLOW%⬆️  !UNPUSHED_COMMITS! unpushed%RESET%  %RED%⬇️  !BEHIND_COUNT! behind%RESET%"
)
echo   Remote Sync        │ !SYNC_TXT!
echo   Next Action        │ %YELLOW%%BOLD%💡 !NEXT_ACTION!%RESET%
echo   Advisory           │ %BLUE%📌 !ADVISORY!%RESET%
echo.
echo %BOLD%📊 CHANGES SNAPSHOT%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo   Files Changed: %BOLD%!UNCOMMITTED_FILES!%RESET%  (%GREEN%🟩 Staged: !STAGED_FILES!%RESET% │ %YELLOW%🟨 Unstaged: !UNSTAGED_FILES!%RESET% │ %GRAY%❓ Untracked: !UNTRACKED_FILES!%RESET%)
echo   Activity Breakdown: %GREEN%!FILES_ADDED! Added%RESET% │ %YELLOW%!FILES_MODIFIED! Modified%RESET% │ %RED%!FILES_DELETED! Deleted%RESET%
echo   Code Volume Churn : %GREEN%+!LINES_ADDED! Lines (+)%RESET%  │  %RED%-!LINES_REMOVED! Lines (-)%RESET%
echo.
echo %BOLD%🔄 WORKFLOW PIPELINE%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
call :render_workflow_pipeline

if !IS_REBASING! EQU 1 (
  echo.
  echo %RED%%BOLD%╔══════════════════════════════════════════════════════════════════════════════════════╗%RESET%
  echo %RED%%BOLD%║  🚨 ACTIVE REBASE IN PROGRESS!                                                      ║%RESET%
  echo %YELLOW%%BOLD%║  To cancel rebase ^& GO BACK to your previous version: Select Option 23 or type 'A'   ║%RESET%
  echo %RED%%BOLD%╚══════════════════════════════════════════════════════════════════════════════════════╝%RESET%
) else if !IS_MERGING! EQU 1 (
  echo.
  echo %RED%%BOLD%╔══════════════════════════════════════════════════════════════════════════════════════╗%RESET%
  echo %RED%%BOLD%║  🚨 ACTIVE MERGE CONFLICT DETECTED!                                                  ║%RESET%
  echo %YELLOW%%BOLD%║  To cancel merge ^& GO BACK to your previous version: Select Option 23 or type 'A'    ║%RESET%
  echo %RED%%BOLD%╚══════════════════════════════════════════════════════════════════════════════════════╝%RESET%
)
echo.
goto :eof

:render_main_menu
echo %BOLD%📌 MAIN MENU — SELECT AN ACTION%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo  %BOLD%🧭 GUIDED WORKFLOW:%RESET%
echo   1) 🚀 Smart Workflow Guide       - Auto-detect state ^& execute recommended action
echo.
echo  %BOLD%📊 STATUS, DIFF ^& HEALTH:%RESET%
echo   2) 📋 Detailed Repository Status - Complete status, tracking ^& commit details
echo   3) 🏥 Health ^& Diagnostic Report - Deep-dive score breakdown ^& fix advice
echo   4) 📝 View Changes (Diff)        - Inspect unstaged ^& staged differences
echo.
echo  %BOLD%📦 STAGING ^& WORKING TREE:%RESET%
echo   5) ➕ Stage Changes (git add)    - Stage all, interactive stage, or pick from list
echo   6) ➖ Unstage Changes            - Safely unstage all or pick from staged list
echo   7) 🧹 Discard / Restore Changes  - Discard local modifications or clean untracked
echo.
echo  %BOLD%💾 COMMITS:%RESET%
echo   8) ✨ Smart Commit (Icons)       - Auto-generate semantic message with icons
echo   9) 📝 Custom Commit              - Write your own custom commit message
echo  10) 🏗️  Conventional Commit Hub   - Guided builder (feat, fix, docs, refactor...)
echo  11) 🔄 Amend Last Commit          - Update last commit message or fold in staged files
echo.
echo  %BOLD%☁️ REMOTE ^& SYNCHRONIZATION:%RESET%
echo  12) ⬆️  Push Changes (Upload)     - Push branch, set upstream, push tags
echo  13) ⬇️  Pull ^& Fetch (Download)   - Fetch all, pull with rebase, or standard pull
echo  14) 🔄 Full Two-Way Sync         - 1-click safe sync (Fetch -^> Pull -^> Push)
echo  15) 🌐 Configure Remote ^& Identity - Smart config (GitHub/Bitbucket), remotes, name ^& email
echo.
echo  %BOLD%🌿 BRANCHES ^& MERGING:%RESET%
echo  16) 🌿 Branch Manager             - Visual branch list, switch, delete ^& compare
echo  17) 🔀 Merge / Rebase Hub         - Merge or rebase branches (pick from list)
echo  18) 📈 Visual Branch Graph        - Interactive visual ASCII branch ^& commit tree
echo  19) 🗺️  Commit Navigation Graph   - Interactive TUI commit graph ^& inspector (Keifu)
echo.
echo  %BOLD%🏷️ TAGS, RELEASES ^& CHANGELOG:%RESET%
echo  20) 🏷️  Version ^& Tag Manager     - SemVer version advice, create ^& push release tags
echo  21) 📄 Generate Changelog         - Create or update CHANGELOG.md automatically
echo.
echo  %BOLD%🗄️ STASH ^& SAFETY NET:%RESET%
echo  22) 🗄️  Git Stash Manager         - Save work-in-progress, list, pop, apply, drop
echo  23) ⏪ Undo ^& Backtrack (Reset)   - Interactive commit timeline backtrack ^& reflog
echo  24) ⏹️  Abort Rebase / Merge       - Emergency cancel ^& go back to original state (rebase/merge --abort)
echo.
echo  %BOLD%⚙️ SETTINGS, OFFLINE ^& HELP:%RESET%
echo  25) 👤 Git Identity Config       - Set user.name ^& user.email (local or global)
echo  26) 🧹 Repository Optimization    - Prune branches ^& run garbage collection (gc)
echo  27) 💡 Smart Tips ^& Cheatsheet    - Best practices, shortcuts ^& advice
echo  28) 📦 Offline Git ^& Portable Setup - Install Git offline (Win/Linux) or setup portable Git
echo  29) 🙈 .gitignore Manager         - Add/remove folders ^& files from ignore list
echo   0) 🚪 Exit
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
goto :eof

rem ============================================================================
rem  OPTION IMPLEMENTATIONS (1 - 29)
rem ============================================================================

rem --- 1. Smart Workflow Guide ---
:smart_workflow_guide
call :refresh_git_metrics
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🚀 SMART WORKFLOW GUIDE — AUTOMATED NEXT STEP%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo Current State  : %BOLD%!WORKFLOW_STATE!%RESET%
echo Health Status  : !HEALTH_STATUS! (!HEALTH_SCORE!/100)
echo Recommended    : %YELLOW%%BOLD%!NEXT_ACTION!%RESET%
echo Details        : !ADVISORY!
echo.
set "wf_ans="
set /p wf_ans="Execute recommended action now? [Y/n]: "
if /i "!wf_ans!"=="n" goto :eof

if "!WORKFLOW_STATE!"=="REBASE_IN_PROGRESS" (
  call :abort_rebase_or_merge
) else if "!WORKFLOW_STATE!"=="MERGE_IN_PROGRESS" (
  call :abort_rebase_or_merge
) else if "!WORKFLOW_STATE!"=="CONFLICT" (
  call :inspect_changes_diff
) else if "!WORKFLOW_STATE!"=="READY_TO_COMMIT" (
  call :smart_commit
) else if "!WORKFLOW_STATE!"=="PARTIALLY_STAGED" (
  call :smart_commit
) else if "!WORKFLOW_STATE!"=="CHANGES_PENDING" (
  git add .
  echo %GREEN%✅ Staged all local changes.%RESET%
  call :smart_commit
) else if "!WORKFLOW_STATE!"=="PUSH_READY" (
  call :push_changes_menu
) else if "!WORKFLOW_STATE!"=="PULL_REQUIRED" (
  call :pull_and_fetch_menu
) else if "!WORKFLOW_STATE!"=="NO_REMOTE" (
  call :configure_remote_access
) else if "!WORKFLOW_STATE!"=="CHECKPOINT" (
  call :show_version_recommendation
) else (
  echo %GREEN%✅ Nothing to automate. Your repository is clean and up to date!%RESET%
)
goto :eof

rem --- 2. Detailed Repository Status ---
:show_detailed_status
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%📋 DETAILED REPOSITORY STATUS%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
git status --long --branch
echo.
echo %BOLD%Recent 5 Commits:%RESET%
git log -n 5 --oneline --decorate --graph
goto :eof

rem --- 3. Health & Diagnostic Report ---
:show_health_report
call :refresh_git_metrics
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🏥 HEALTH ^& DIAGNOSTIC REPORT%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo   Health Score : !HEALTH_COLOR!!HEALTH_SCORE!/100 (!HEALTH_STATUS!)%RESET%
echo   Risk Level   : !RISK_LEVEL!
echo.
echo %BOLD%Score Breakdown:%RESET%
if !CONFLICTED_FILES! GTR 0 echo   %RED%-30 pts: Unresolved merge conflicts (!CONFLICTED_FILES! files)%RESET%
if !BEHIND_COUNT! GTR 0 echo   %YELLOW%-15 pts: Local branch behind remote (!BEHIND_COUNT! commits)%RESET%
if !UNCOMMITTED_FILES! GTR 0 echo   %YELLOW%-10 pts: Uncommitted changes (!UNCOMMITTED_FILES! files)%RESET%
if !UNSTAGED_FILES! GTR 5 echo   %YELLOW%-5 pts: High unstaged files volume (!UNSTAGED_FILES!)%RESET%
if !UNPUSHED_COMMITS! GTR 0 echo   %YELLOW%-5 pts: Unpushed commits (!UNPUSHED_COMMITS!)%RESET%
if "!REMOTE_NAME!"=="not configured" echo   %YELLOW%-5 pts: No remote repository configured%RESET%
if !COMMITS_SINCE_TAG! GEQ 10 echo   %YELLOW%-5 pts: 10+ commits since last release tag%RESET%
if !LINES_ADDED! GTR 3000 echo   %YELLOW%-10 pts: Huge uncommitted churn (+!LINES_ADDED! lines)%RESET%
if !HEALTH_SCORE! EQU 100 echo   %GREEN%+100 pts: Repository is in pristine health!%RESET%
echo.
echo %BOLD%Advice ^& Recommendations:%RESET%
echo   • !ADVISORY!
goto :eof

rem --- 4. View Changes (Diff) ---
:inspect_changes_diff
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%📝 VIEW CHANGES (DIFF)%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo   1) View Unstaged Changes (git diff)
echo   2) View Staged Changes   (git diff --cached)
echo   3) View Summary of Changed Files (git status --short)
echo   4) View Diff Statistics (git diff --stat)
echo   0) Back
set "dchoice="
set /p dchoice="Select diff option [0-4]: "
if "!dchoice!"=="1" git diff
if "!dchoice!"=="2" git diff --cached
if "!dchoice!"=="3" git status --short
if "!dchoice!"=="4" git diff --stat
goto :eof

rem --- 5. Stage Changes ---
:stage_changes_menu
call :refresh_git_metrics
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%➕ STAGE CHANGES (GIT ADD)%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo   1) Stage ALL Modified ^& Untracked Files (git add .)
echo   2) Interactive Staging / Patch Mode (git add -p)
echo   3) Stage Specific File (Pick from list or manual)
echo   4) Stage Only Tracked Modified/Deleted Files (git add -u)
echo   0) Back
set "schoice="
set /p schoice="Select staging option [0-4]: "
if "!schoice!"=="1" (
  git add .
  echo %GREEN%✅ All modified and untracked files staged.%RESET%
)
if "!schoice!"=="2" (
  git add -p
)
if "!schoice!"=="3" (
  call :select_file "Select file to STAGE" "all"
  if "!SELECTED_FILE!"=="ALL" (
    git add .
    echo %GREEN%✅ All files staged.%RESET%
  ) else if defined SELECTED_FILE (
    git add "!SELECTED_FILE!"
    echo %GREEN%✅ Staged: !SELECTED_FILE!%RESET%
  )
)
if "!schoice!"=="4" (
  git add -u
  echo %GREEN%✅ Staged all tracked modifications and deletions.%RESET%
)
goto :eof

rem --- 6. Unstage Changes ---
:unstage_changes_menu
call :refresh_git_metrics
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%➖ UNSTAGE CHANGES%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo   1) Unstage ALL Staged Files (git restore --staged .)
echo   2) Unstage Specific File (Pick from list or manual)
echo   0) Cancel
set "uschoice="
set /p uschoice="Select unstage option [0-2]: "
if "!uschoice!"=="1" (
  git restore --staged . 2>nul || git reset HEAD .
  echo %GREEN%✅ All files unstaged.%RESET%
)
if "!uschoice!"=="2" (
  call :select_file "Select file to UNSTAGE" "staged"
  if "!SELECTED_FILE!"=="ALL" (
    git restore --staged . 2>nul || git reset HEAD .
    echo %GREEN%✅ All files unstaged.%RESET%
  ) else if defined SELECTED_FILE (
    git restore --staged "!SELECTED_FILE!" 2>nul || git reset HEAD "!SELECTED_FILE!"
    echo %GREEN%✅ Unstaged: !SELECTED_FILE!%RESET%
  )
)
goto :eof

rem --- 7. Discard / Restore Changes ---
:discard_restore_menu
call :refresh_git_metrics
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🧹 DISCARD / RESTORE LOCAL MODIFICATIONS%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %YELLOW%⚠️ Caution: Discarding changes cannot be easily undone!%RESET%
echo   1) Discard Unstaged Changes in Tracked Files (git restore .)
echo   2) Discard Changes in a Specific File (Pick from list or manual)
echo   3) Clean Untracked Files and Folders (git clean -fd)
echo   4) DISCARD ALL CHANGES (Hard Reset to HEAD)
echo   0) Cancel
set "clean_choice="
set /p clean_choice="Select discard option [0-4]: "
if "!clean_choice!"=="1" (
  set "c_ans="
  set /p c_ans="Discard all unstaged tracked file modifications? [y/N]: "
  if /i "!c_ans!"=="y" (
    git restore . 2>nul || git checkout -- .
    echo %GREEN%✅ Unstaged changes discarded.%RESET%
  )
)
if "!clean_choice!"=="2" (
  call :select_file "Select file to RESTORE / DISCARD changes" "unstaged"
  if defined SELECTED_FILE if not "!SELECTED_FILE!"=="ALL" (
    set "c_ans="
    set /p c_ans="Discard changes in '!SELECTED_FILE!'? [y/N]: "
    if /i "!c_ans!"=="y" (
      git restore "!SELECTED_FILE!" 2>nul || git checkout -- "!SELECTED_FILE!"
      echo %GREEN%✅ Restored file: !SELECTED_FILE!%RESET%
    )
  )
)
if "!clean_choice!"=="3" (
  echo %CYAN%Preview of untracked files to remove:%RESET%
  git clean -nd
  set "c_ans="
  set /p c_ans="Permanently remove all untracked files and folders above? [y/N]: "
  if /i "!c_ans!"=="y" (
    git clean -fd
    echo %GREEN%✅ Untracked files and folders cleaned.%RESET%
  )
)
if "!clean_choice!"=="4" (
  set "confirm_reset="
  set /p confirm_reset="%RED%⚠️ DISCARD ALL LOCAL CHANGES (staged + unstaged)? [y/N]: %RESET%"
  if /i "!confirm_reset!"=="y" (
    git reset --hard HEAD
    git clean -fd
    echo %GREEN%✅ Working tree reset to HEAD.%RESET%
  )
)
goto :eof

rem --- 8. Smart Commit ---
:suggest_commit_message
set "SUGGESTED_MSG="
if !CONFLICTED_FILES! GTR 0 (
  set "SUGGESTED_MSG=🚨 fix(merge): resolve merge conflicts"
  goto :eof
)

set "FIRST_FILE="
set "FIRST_BASE="
set "FIRST_NAME="
for /f "tokens=*" %%f in ('git diff --cached --name-only 2^>nul') do (
  if "!FIRST_FILE!"=="" set "FIRST_FILE=%%f"
)
if "!FIRST_FILE!"=="" (
  for /f "tokens=2" %%f in ('git status --porcelain 2^>nul') do (
    if "!FIRST_FILE!"=="" set "FIRST_FILE=%%f"
  )
)

if not "!FIRST_FILE!"=="" (
  for %%A in ("!FIRST_FILE!") do (
    set "FIRST_NAME=%%~nxA"
    set "FIRST_BASE=%%~nA"
  )
)
if "!FIRST_BASE!"=="" set "FIRST_BASE=core"

if !FILES_DELETED! GTR 0 if !FILES_ADDED! EQU 0 if !FILES_MODIFIED! EQU 0 (
  set "SUGGESTED_MSG=🧹 refactor(!FIRST_BASE!): remove obsolete files"
  goto :eof
)

git status --porcelain 2>nul | findstr /I /R "\.md$ \.txt$ \.rst$ \.doc$ \.pdf$ \.docx$ docs/" >nul 2>&1
if not errorlevel 1 (
  set "SUGGESTED_MSG=📚 docs(!FIRST_BASE!): update documentation and guides"
  goto :eof
)

git status --porcelain 2>nul | findstr /I /R "package\.json Cargo\.toml go\.mod pom\.xml requirements\.txt \.gitignore Dockerfile Makefile" >nul 2>&1
if not errorlevel 1 (
  set "SUGGESTED_MSG=🔧 chore(!FIRST_BASE!): update project configuration and dependencies"
  goto :eof
)

git status --porcelain 2>nul | findstr /I /R "test spec \.test\. \_test\. test_" >nul 2>&1
if not errorlevel 1 (
  set "SUGGESTED_MSG=🧪 test(!FIRST_BASE!): update tests and specifications"
  goto :eof
)

git status --porcelain 2>nul | findstr /I /R "\.sh$ \.bat$ \.ps1$ \.bash$" >nul 2>&1
if not errorlevel 1 (
  if not "!FIRST_NAME!"=="" (
    set "SUGGESTED_MSG=⚙️ feat(scripts): update !FIRST_NAME!"
  ) else (
    set "SUGGESTED_MSG=⚙️ feat(scripts): update script automation"
  )
  goto :eof
)

if !FILES_ADDED! GTR 0 (
  if not "!FIRST_NAME!"=="" (
    set "SUGGESTED_MSG=✨ feat(!FIRST_BASE!): add !FIRST_NAME!"
  ) else (
    set "SUGGESTED_MSG=✨ feat(!FIRST_BASE!): implement new project capabilities"
  )
  goto :eof
)

if not "!FIRST_NAME!"=="" (
  set "SUGGESTED_MSG=🐛 fix(!FIRST_BASE!): update !FIRST_NAME!"
) else (
  set "SUGGESTED_MSG=🐛 fix(!FIRST_BASE!): update project files and fix issues"
)
goto :eof

:smart_commit
call :refresh_git_metrics
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%✨ SMART COMMIT (AUTO-GENERATED SEMANTIC MESSAGE WITH ICONS)%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%

if !UNCOMMITTED_FILES! EQU 0 (
  echo %GREEN%Working directory is clean. Nothing to commit.%RESET%
  goto :eof
)

if !STAGED_FILES! EQU 0 (
  echo %YELLOW%No changes are currently staged.%RESET%
  git status --short
  set "stage_ans="
  set /p stage_ans="Stage all changes before committing? [Y/n]: "
  if /i "!stage_ans!"=="n" (
    echo %BLUE%Commit cancelled. Please stage files first.%RESET%
    goto :eof
  )
  git add .
  call :refresh_git_metrics
)

call :suggest_commit_message
set "s1=!SUGGESTED_MSG!"
set "s2=🐛 fix(!FIRST_BASE!): update !FIRST_NAME! and improve stability"
set "s3=✨ feat(!FIRST_BASE!): add new capabilities to !FIRST_NAME!"
set "s4=♻️ refactor(!FIRST_BASE!): clean up implementation and workflow"
set "s5=📚 docs(!FIRST_BASE!): update documentation and usage notes"

echo Detected Changes : !UNCOMMITTED_FILES! files (!STAGED_FILES! staged)
echo.
echo %CYAN%%BOLD%💡 Recommended Commit Messages (with Semantic Icons):%RESET%
echo   %BOLD%1)%RESET% !s1!
echo   %BOLD%2)%RESET% !s2!
echo   %BOLD%3)%RESET% !s3!
echo   %BOLD%4)%RESET% !s4!
echo   %BOLD%5)%RESET% !s5!
echo   %BOLD%M)%RESET% ✍️  Enter custom commit message
echo   %BOLD%0)%RESET% ❌ Cancel commit
echo.
set "c_choice="
set /p c_choice="Select commit option [1-5, M, 0]: "

set "final_msg="
if "!c_choice!"=="1" set "final_msg=!s1!"
if "!c_choice!"=="2" set "final_msg=!s2!"
if "!c_choice!"=="3" set "final_msg=!s3!"
if "!c_choice!"=="4" set "final_msg=!s4!"
if "!c_choice!"=="5" set "final_msg=!s5!"
if /i "!c_choice!"=="m" (
  set /p final_msg="Enter your custom commit message: "
)
if "!c_choice!"=="0" (
  echo %BLUE%Commit cancelled.%RESET%
  goto :eof
)
if "!final_msg!"=="" set "final_msg=!s1!"

echo Creating commit: %YELLOW%%BOLD%!final_msg!%RESET%
git commit -m "!final_msg!"
if not errorlevel 1 (
  echo %GREEN%✅ Commit created successfully!%RESET%
) else (
  echo %RED%❌ Commit failed.%RESET%
)
goto :eof

rem --- 9. Custom Commit ---
:custom_commit
call :refresh_git_metrics
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%📝 CUSTOM COMMIT%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
if !UNCOMMITTED_FILES! EQU 0 (
  echo %GREEN%Working directory is clean. Nothing to commit.%RESET%
  goto :eof
)
if !STAGED_FILES! EQU 0 (
  echo %YELLOW%No changes staged.%RESET%
  set "stg_all="
  set /p stg_all="Stage all changes now (git add .)? [Y/n]: "
  if /i "!stg_all!"=="n" goto :eof
  git add .
)
set "user_msg="
set /p user_msg="Enter commit message: "
if not "!user_msg!"=="" (
  git commit -m "!user_msg!"
  echo %GREEN%✅ Commit created successfully!%RESET%
)
goto :eof

rem --- 10. Conventional Commit Hub ---
:conventional_commit_builder
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🏗️  CONVENTIONAL COMMIT HUB%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo Select Commit Type:
echo   1) ✨ feat     (New feature)
echo   2) 🐛 fix      (Bug fix)
echo   3) 📚 docs     (Documentation)
echo   4) 💄 style    (Formatting, missing semi-colons, etc.)
echo   5) ♻️  refactor (Code restructuring)
echo   6) ⚡ perf     (Performance improvement)
echo   7) 🧪 test     (Adding or updating tests)
echo   8) 🔧 chore    (Build tasks, dependencies, tooling)
echo   0) Cancel
set "ctype_sel="
set /p ctype_sel="Select type [0-8]: "

set "ctype=feat"
if "!ctype_sel!"=="2" set "ctype=fix"
if "!ctype_sel!"=="3" set "ctype=docs"
if "!ctype_sel!"=="4" set "ctype=style"
if "!ctype_sel!"=="5" set "ctype=refactor"
if "!ctype_sel!"=="6" set "ctype=perf"
if "!ctype_sel!"=="7" set "ctype=test"
if "!ctype_sel!"=="8" set "ctype=chore"
if "!ctype_sel!"=="0" goto :eof

set "cscope="
set /p cscope="Enter scope (optional, e.g. auth, api): "
set "csummary="
set /p csummary="Enter concise summary: "
if "!csummary!"=="" (
  echo %YELLOW%Summary cannot be empty.%RESET%
  goto :eof
)

if not "!cscope!"=="" (
  set "conv_msg=!ctype!(!cscope!): !csummary!"
) else (
  set "conv_msg=!ctype!: !csummary!"
)

if !STAGED_FILES! EQU 0 git add .
echo Creating conventional commit: %YELLOW%!conv_msg!%RESET%
git commit -m "!conv_msg!"
goto :eof

rem --- 11. Amend Last Commit ---
:amend_commit_menu
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🔄 AMEND LAST COMMIT%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo Last Commit: %YELLOW%!LAST_COMMIT_HASH! !LAST_COMMIT_MSG!%RESET%
echo.
echo   1) Update Message of Last Commit
echo   2) Fold Currently Staged Files into Last Commit (keep message)
echo   0) Cancel
set "amend_sel="
set /p amend_sel="Select option [0-2]: "
if "!amend_sel!"=="1" (
  set "new_amend_msg="
  set /p new_amend_msg="Enter new commit message: "
  if not "!new_amend_msg!"=="" (
    git commit --amend -m "!new_amend_msg!"
    echo %GREEN%✅ Commit message updated.%RESET%
  )
) else if "!amend_sel!"=="2" (
  git commit --amend --no-edit
  echo %GREEN%✅ Staged files folded into last commit.%RESET%
)
goto :eof

rem --- 12. Push Changes ---
:push_changes_menu
call :refresh_git_metrics
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%⬆️  PUSH CHANGES TO REMOTE%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
if "!REMOTE_NAME!"=="not configured" (
  echo %RED%❌ No remote repository configured.%RESET%
  call :configure_remote_access
  goto :eof
)
echo Current Branch: %YELLOW%!CURRENT_BRANCH!%RESET%  Upstream: %CYAN%!UPSTREAM_BRANCH!%RESET%
echo   1) Standard / Smart Push (Auto-detect ^& push with fallback)
echo   2) Push ^& Set Upstream (git push -u origin !CURRENT_BRANCH!)
echo   3) Push Local HEAD to Remote Branch of Same Name (git push origin HEAD)
echo   4) Push Local HEAD to Tracked Upstream Branch
echo   5) Push All Tags (git push --tags)
echo   0) Cancel
set "push_sel="
set /p push_sel="Select option [0-5]: "
if "!push_sel!"=="1" (
  git push
  if errorlevel 1 (
    echo.
    echo %YELLOW%⚠️ Standard push failed or upstream branch is not set.%RESET%
    echo   1) Push local HEAD to branch of same name on remote (git push origin HEAD)
    echo   2) Push ^& Set Upstream tracking (git push -u origin !CURRENT_BRANCH!)
    echo   0) Cancel
    set "ps_fb="
    set /p ps_fb="Select resolution option [0-2]: "
    if "!ps_fb!"=="1" git push origin HEAD
    if "!ps_fb!"=="2" git push -u origin "!CURRENT_BRANCH!"
  )
)
if "!push_sel!"=="2" git push -u origin "!CURRENT_BRANCH!"
if "!push_sel!"=="3" git push origin HEAD
if "!push_sel!"=="4" (
  if not "!UPSTREAM_BRANCH!"=="none" (
    git push origin "HEAD:!UPSTREAM_BRANCH!"
  ) else (
    git push -u origin "!CURRENT_BRANCH!"
  )
)
if "!push_sel!"=="5" git push --tags
goto :eof

rem --- 13. Pull & Fetch ---
:pull_and_fetch_menu
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%⬇️  PULL ^& FETCH FROM REMOTE%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo   1) Fetch All Remote Branches ^& Tags (git fetch --all --prune)
echo   2) Pull with Rebase (git pull --rebase)
echo   3) Standard Pull (git pull)
echo   0) Cancel
set "pull_sel="
set /p pull_sel="Select option [0-3]: "
if "!pull_sel!"=="1" git fetch --all --prune
if "!pull_sel!"=="2" git pull --rebase
if "!pull_sel!"=="3" git pull
goto :eof

rem --- 14. Full Two-Way Sync ---
:full_two_way_sync
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🔄 FULL TWO-WAY SYNC (FETCH -^> PULL -^> PUSH)%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo Step 1/3: Fetching all remote branches...
git fetch --all --prune
echo Step 2/3: Pulling remote changes with rebase...
git pull --rebase
if errorlevel 1 (
  echo %RED%❌ Pull encountered merge conflicts. Resolve conflicts or abort.%RESET%
  goto :eof
)
echo Step 3/3: Pushing local commits to remote...
git push
if not errorlevel 1 (
  echo %GREEN%✅ Full 1-click sync completed successfully!%RESET%
) else (
  echo %YELLOW%⚠️ Push required upstream tracking. Trying 'git push -u origin !CURRENT_BRANCH!'...%RESET%
  git push -u origin "!CURRENT_BRANCH!"
)
goto :eof

rem --- 15. Configure Remote & Identity ---
:configure_remote_access
call :refresh_git_metrics
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🌐 REMOTE REPOSITORY ^& IDENTITY CONFIGURATION%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
set "CUR_NAME="
set "CUR_EMAIL="
for /f "tokens=*" %%a in ('git config user.name 2^>nul') do set "CUR_NAME=%%a"
for /f "tokens=*" %%a in ('git config user.email 2^>nul') do set "CUR_EMAIL=%%a"
if "!CUR_NAME!"=="" set "CUR_NAME=not set"
if "!CUR_EMAIL!"=="" set "CUR_EMAIL=not set"
echo Current Git User Name  : %YELLOW%!CUR_NAME!%RESET%
echo Current Git User Email : %YELLOW%!CUR_EMAIL!%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo   1) View Current Remotes (git remote -v)
echo   2) Set or Change Origin URL (Manual)
echo   3) Add a New Remote (Manual)
echo   4) 🐙 Smart Config for GitHub (HTTPS/SSH)
echo   5) 🪣 Smart Config for Bitbucket (HTTPS/SSH)
echo   6) 👤 Configure Git Identity ^& Email (Name ^& Email)
echo   8) Remove a Remote (Pick from list)
echo   9) 🚀 Smart Push Fix & Reconciliation (Resolve Non-Fast-Forward & Push)
echo  10) ⚡ Fully Force Push (Emergency Force Overwrite & Sync)
echo   0) Cancel
set "rmchoice="
set /p rmchoice="Select option [0-10]: "
if "!rmchoice!"=="1" git remote -v
if "!rmchoice!"=="2" (
  set "new_url="
  set /p new_url="Enter new remote URL for 'origin': "
  if not "!new_url!"=="" (
    git remote set-url origin "!new_url!" 2>nul || git remote add origin "!new_url!"
    echo %GREEN%✅ Remote origin updated.%RESET%
    call :prompt_identity
  )
)
if "!rmchoice!"=="3" (
  set "rname="
  set "rurl="
  set /p rname="Enter remote name (e.g. upstream): "
  set /p rurl="Enter remote URL: "
  if not "!rname!"=="" if not "!rurl!"=="" (
    git remote add "!rname!" "!rurl!"
    echo %GREEN%✅ Remote !rname! added.%RESET%
    call :prompt_identity
  )
)
if "!rmchoice!"=="4" call :smart_config_github_bat
if "!rmchoice!"=="5" call :smart_config_bitbucket_bat
if "!rmchoice!"=="6" call :prompt_identity
if "!rmchoice!"=="7" (
  call :select_remote
  if defined SELECTED_REMOTE (
    echo Testing connection to '!SELECTED_REMOTE!'...
    git ls-remote "!SELECTED_REMOTE!" >nul 2>&1
    if not errorlevel 1 (
      echo %GREEN%✅ Remote '!SELECTED_REMOTE!' is reachable.%RESET%
    ) else (
      echo %RED%❌ Could not connect to remote '!SELECTED_REMOTE!'.%RESET%
    )
  )
)
if "!rmchoice!"=="8" (
  call :select_remote
  if defined SELECTED_REMOTE (
    git remote remove "!SELECTED_REMOTE!"
    echo %GREEN%✅ Removed remote: !SELECTED_REMOTE!%RESET%
  )
)
if "!rmchoice!"=="9" call :smart_fix_push_rejection_bat
if "!rmchoice!"=="10" call :fully_force_push_bat
goto :eof

:fully_force_push_bat
echo.
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%💥 FULLY FORCE PUSH — FIX ALL PUSH BLOCKERS ^& SYNC%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo Executing git push --force -u origin !CURRENT_BRANCH!...
git push --force -u origin !CURRENT_BRANCH!
if not errorlevel 1 (
  echo %GREEN%🎉 FULLY FORCE PUSH SUCCESSFUL!%RESET%
) else (
  echo %RED%❌ Force push failed. Check network or repository permissions.%RESET%
)
goto :eof

:smart_fix_push_rejection_bat
echo.
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🚀 SMART PUSH REJECTION RESOLVER & RECONCILIATION%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo Resolving non-fast-forward / unrelated histories push rejection...
git fetch origin !CURRENT_BRANCH! 2>nul || git fetch origin 2>nul
echo Merging remote changes preserving all local work...
git merge origin/!CURRENT_BRANCH! --allow-unrelated-histories -s ort -X ours -m "🔀 Merge remote repository into local branch"
if not errorlevel 1 (
  echo %GREEN%✅ Merge completed.%RESET%
  echo Pushing to origin !CURRENT_BRANCH!...
  git push -u origin !CURRENT_BRANCH!
  if not errorlevel 1 (
    echo %GREEN%🎉 PUSH SUCCESSFUL! Local and remote branches are now synchronized.%RESET%
  ) else (
    echo %RED%❌ Push failed. Check credentials/network.%RESET%
  )
) else (
  echo %RED%❌ Merge encountered an issue. Aborting merge...%RESET%
  git merge --abort 2>nul
)
goto :eof

:prompt_identity
echo.
echo %CYAN%------------------------------------------------------------%RESET%
echo %BOLD%👤 CONFIGURE GIT IDENTITY ^& EMAIL%RESET%
echo %CYAN%------------------------------------------------------------%RESET%
set "in_name="
set "in_email="
set /p in_name="Enter Git User Name: "
set /p in_email="Enter Git User Email: "
if not "!in_name!"=="" git config user.name "!in_name!"
if not "!in_email!"=="" git config user.email "!in_email!"
echo %GREEN%✅ Git identity updated successfully.%RESET%
goto :eof

:smart_config_github_bat
echo.
echo %CYAN%------------------------------------------------------------%RESET%
echo %BOLD%🐙 SMART CONFIGURATION FOR GITHUB%RESET%
echo %CYAN%------------------------------------------------------------%RESET%
echo 1. HTTPS (https://github.com/owner/repo.git)
echo 2. SSH   (git@github.com:owner/repo.git)
set "gh_proto="
set /p gh_proto="Select protocol [1-2, default 1]: "
set "gh_owner="
set /p gh_owner="Enter GitHub Username or Organization: "
if "!gh_owner!"=="" (
  echo %YELLOW%Username/Organization cannot be empty.%RESET%
  goto :eof
)
set "gh_repo="
set /p gh_repo="Enter Repository Name: "
if "!gh_repo!"=="" (
  echo %YELLOW%Repository Name cannot be empty.%RESET%
  goto :eof
)
if "!gh_proto!"=="2" (
  set "target_url=git@github.com:!gh_owner!/!gh_repo!.git"
) else (
  set "target_url=https://github.com/!gh_owner!/!gh_repo!.git"
)
git remote set-url origin "!target_url!" 2>nul || git remote add origin "!target_url!"
echo %GREEN%✅ Remote origin configured to: !target_url!%RESET%
call :prompt_identity
goto :eof

:smart_config_bitbucket_bat
echo.
echo %CYAN%------------------------------------------------------------%RESET%
echo %BOLD%🪣 SMART CONFIGURATION FOR BITBUCKET%RESET%
echo %CYAN%------------------------------------------------------------%RESET%
echo 1. HTTPS (https://bitbucket.org/workspace/repo.git)
echo 2. SSH   (git@bitbucket.org:workspace/repo.git)
set "bb_proto="
set /p bb_proto="Select protocol [1-2, default 1]: "
set "bb_ws="
set /p bb_ws="Enter Bitbucket Workspace or Username: "
if "!bb_ws!"=="" (
  echo %YELLOW%Workspace/Username cannot be empty.%RESET%
  goto :eof
)
set "bb_repo="
set /p bb_repo="Enter Repository Name: "
if "!bb_repo!"=="" (
  echo %YELLOW%Repository Name cannot be empty.%RESET%
  goto :eof
)
if "!bb_proto!"=="2" (
  set "target_url=git@bitbucket.org:!bb_ws!/!bb_repo!.git"
) else (
  set "target_url=https://bitbucket.org/!bb_ws!/!bb_repo!.git"
)
git remote set-url origin "!target_url!" 2>nul || git remote add origin "!target_url!"
echo %GREEN%✅ Remote origin configured to: !target_url!%RESET%
call :prompt_identity
goto :eof

rem --- 16. Branch Manager ---
:branch_manager
:bm_loop
call :refresh_git_metrics
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🌿 BRANCH MANAGER ^& REPOSITORIES%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo Current Branch: %MAGENTA%%BOLD%!CURRENT_BRANCH!%RESET%
echo.
echo   1) 🌟 List All Branches with Icons ^& Status (Rich Overview)
echo   2) ➕ Create and Switch to New Branch
echo   3) 🔀 Switch Branch (Choose from list or manual)
echo   4) ✏️  Rename Current Branch
echo   5) 🔗 Set / Fix Upstream Tracking (git branch --set-upstream-to)
echo   6) 🎯 Make Local Branch Match Remote HEAD (git reset --hard origin/^<branch^>)
echo   7) 🗑️  Delete a Local Branch (Choose from list or manual)
echo   8) 🌐 Delete a Remote Branch (Choose from list or manual)
echo   9) 🔄 Compare Current Branch with Another Branch (Choose from list)
echo  10) 🗺️  Commit Navigation Graph (Interactive Keifu TUI)
echo   0) Back to Main Menu
set "bchoice="
set /p bchoice="Select branch option [0-10]: "
if "!bchoice!"=="0" goto :eof
if "!bchoice!"=="1" (
  echo.
  echo %BOLD%Local Branches:%RESET%
  for /f "tokens=*" %%b in ('git for-each-ref --format^="%%(refname:short)" refs/heads/ 2^>nul') do (
    set "b_icon=🌿"
    set "b_tag="
    if "%%b"=="!CURRENT_BRANCH!" (
      set "b_icon=⭐"
      set "b_tag= %GREEN%[ACTIVE]%RESET%"
    )
    set "b_c="
    for /f "tokens=*" %%c in ('git log -1 --format^="%%h - %%s (%%cr)" "%%b" 2^>nul') do set "b_c=%%c"
    echo   !b_icon! %BOLD%%%b%RESET%!b_tag!
    if defined b_c echo      %GRAY%└─ !b_c:~0,65!%RESET%
  )
  echo.
  echo %BOLD%Remote Branches:%RESET%
  for /f "tokens=*" %%r in ('git for-each-ref --format^="%%(refname:short)" refs/remotes/ 2^>nul') do (
    echo %%r | findstr /i "HEAD" >nul 2>&1
    if errorlevel 1 (
      set "r_c="
      for /f "tokens=*" %%c in ('git log -1 --format^="%%h - %%s (%%cr)" "%%r" 2^>nul') do set "r_c=%%c"
      echo   🌐 %BLUE%%%r%RESET%
      if defined r_c echo      %GRAY%└─ !r_c:~0,65!%RESET%
    )
  )
  echo.
  pause
)
if "!bchoice!"=="2" (
  set "new_bname="
  set /p new_bname="Enter new branch name: "
  if not "!new_bname!"=="" (
    git checkout -b "!new_bname!"
    echo %GREEN%✅ Created and switched to branch: !new_bname!%RESET%
  )
)
if "!bchoice!"=="3" (
  call :select_branch "Select branch to switch to" 1
  if defined SELECTED_BRANCH (
    git checkout "!SELECTED_BRANCH!"
    echo %GREEN%✅ Switched to branch: !SELECTED_BRANCH!%RESET%
  )
)
if "!bchoice!"=="4" (
  set "ren_bname="
  set /p ren_bname="Enter new name for current branch (!CURRENT_BRANCH!): "
  if not "!ren_bname!"=="" (
    git branch -m "!ren_bname!"
    echo %GREEN%✅ Renamed branch to: !ren_bname!%RESET%
  )
)
if "!bchoice!"=="5" (
  echo Current Branch: !CURRENT_BRANCH!
  call :select_branch "Select remote tracking branch" 1
  if defined SELECTED_BRANCH (
    git branch --set-upstream-to="!SELECTED_BRANCH!" "!CURRENT_BRANCH!"
    if not errorlevel 1 (
      echo %GREEN%✅ Tracking upstream set to: !SELECTED_BRANCH!%RESET%
    ) else (
      git push -u origin "!CURRENT_BRANCH!"
    )
  )
)
if "!bchoice!"=="6" (
  echo %YELLOW%⚠️ WARNING: Hard reset will discard local changes and unpushed commits!%RESET%
  set "confirm_rst="
  set /p confirm_rst="Reset !CURRENT_BRANCH! to match origin/!CURRENT_BRANCH!? [y/N]: "
  if /i "!confirm_rst!"=="y" (
    git fetch origin
    git reset --hard "origin/!CURRENT_BRANCH!"
    echo %GREEN%✅ Branch reset to origin/!CURRENT_BRANCH!.%RESET%
  )
)
if "!bchoice!"=="7" (
  call :select_branch "Select local branch to DELETE" 0
  if defined SELECTED_BRANCH (
    if "!SELECTED_BRANCH!"=="!CURRENT_BRANCH!" (
      echo %YELLOW%Cannot delete the currently active branch.%RESET%
    ) else (
      set "del_conf="
      set /p del_conf="Delete local branch '!SELECTED_BRANCH!'? [y/N]: "
      if /i "!del_conf!"=="y" (
        git branch -d "!SELECTED_BRANCH!" 2>nul || git branch -D "!SELECTED_BRANCH!"
        echo %GREEN%✅ Local branch '!SELECTED_BRANCH!' deleted.%RESET%
      )
    )
  )
)
if "!bchoice!"=="8" (
  call :select_branch "Select remote branch to DELETE" 1
  if defined SELECTED_BRANCH (
    echo Selected remote branch: !SELECTED_BRANCH!
    set "del_conf="
    set /p del_conf="%RED%⚠️ Permanently DELETE remote branch '!SELECTED_BRANCH!' from server? [y/N]: %RESET%"
    if /i "!del_conf!"=="y" (
      for /f "tokens=1* delims=/" %%a in ("!SELECTED_BRANCH!") do (
        git push "%%a" --delete "%%b"
      )
    )
  )
)
if "!bchoice!"=="9" (
  call :compare_branches_menu
)
if "!bchoice!"=="10" (
  call :commit_navigation_graph
)
goto :bm_loop

:compare_branches_menu
call :select_branch "Select branch to compare against !CURRENT_BRANCH!" 1
if not defined SELECTED_BRANCH goto :eof

echo.
echo Comparing: %MAGENTA%%BOLD%!CURRENT_BRANCH!%RESET% ⟷ %CYAN%%BOLD%!SELECTED_BRANCH!%RESET%
echo   1) 📊 Compare Summary Stats (git diff --stat)
echo   2) 📝 Detailed Line Diff (git diff)
echo   3) 📜 Commit Timeline Divergence Graph
echo   4) ⬆️  Commits in current branch NOT in target
echo   5) ⬇️  Commits in target branch NOT in current
echo   0) Cancel
set "cmp_sel="
set /p cmp_sel="Select comparison type [0-5]: "
if "!cmp_sel!"=="1" git diff --stat "!SELECTED_BRANCH!...!CURRENT_BRANCH!" 2>nul || git diff --stat "!SELECTED_BRANCH!" "!CURRENT_BRANCH!"
if "!cmp_sel!"=="2" git diff "!SELECTED_BRANCH!...!CURRENT_BRANCH!" 2>nul || git diff "!SELECTED_BRANCH!" "!CURRENT_BRANCH!"
if "!cmp_sel!"=="3" git log --graph --oneline --left-right --cherry-pick --decorate "!SELECTED_BRANCH!...!CURRENT_BRANCH!" -n 25 2>nul || git log --graph --oneline -n 25 "!SELECTED_BRANCH!" "!CURRENT_BRANCH!"
if "!cmp_sel!"=="4" git log --oneline "!SELECTED_BRANCH!..!CURRENT_BRANCH!" 2>nul
if "!cmp_sel!"=="5" git log --oneline "!CURRENT_BRANCH!..!SELECTED_BRANCH!" 2>nul
echo.
pause
goto :eof

rem --- 17. Merge / Rebase Hub ---
:merge_rebase_hub
call :refresh_git_metrics
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🔀 MERGE ^& REBASE HUB%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo Current Branch: %YELLOW%!CURRENT_BRANCH!%RESET%
echo   1) 🔀 Merge Another Branch into Current Branch (Pick from list)
echo   2) 🔄 Rebase Current Branch onto Another Branch (Pick from list)
echo   3) ⏹️  Abort Ongoing Merge ^& Go Back (git merge --abort)
echo   4) ⏹️  Abort Ongoing Rebase ^& Go Back (git rebase --abort)
echo   5) ▶️  Continue Rebase after Conflict Resolution (git rebase --continue)
echo   6) 🚨 Show Conflicted Files
echo   0) Back
set "mchoice="
set /p mchoice="Select option [0-6]: "
if "!mchoice!"=="1" (
  call :select_branch "Select branch to MERGE into !CURRENT_BRANCH!" 1
  if defined SELECTED_BRANCH (
    if "!SELECTED_BRANCH!"=="!CURRENT_BRANCH!" (
      echo %YELLOW%Cannot merge a branch into itself.%RESET%
    ) else (
      set "conf_m="
      set /p conf_m="Merge branch '!SELECTED_BRANCH!' into '!CURRENT_BRANCH!'? [Y/n]: "
      if /i not "!conf_m!"=="n" git merge "!SELECTED_BRANCH!"
    )
  )
)
if "!mchoice!"=="2" (
  call :select_branch "Select target branch to REBASE !CURRENT_BRANCH! onto" 1
  if defined SELECTED_BRANCH (
    if "!SELECTED_BRANCH!"=="!CURRENT_BRANCH!" (
      echo %YELLOW%Cannot rebase a branch onto itself.%RESET%
    ) else (
      set "conf_r="
      set /p conf_r="Rebase current branch '!CURRENT_BRANCH!' onto '!SELECTED_BRANCH!'? [Y/n]: "
      if /i not "!conf_r!"=="n" git rebase "!SELECTED_BRANCH!"
    )
  )
)
if "!mchoice!"=="3" call :abort_rebase_or_merge
if "!mchoice!"=="4" call :abort_rebase_or_merge
if "!mchoice!"=="5" git rebase --continue
if "!mchoice!"=="6" git diff --name-only --diff-filter=U
goto :eof

rem --- 18. Visual Branch Graph ---
:visual_branch_graph
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%📈 VISUAL ASCII BRANCH ^& COMMIT GRAPH%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
git log --graph --oneline --decorate -n 25
goto :eof

rem --- 19. Commit Navigation Graph (Keifu / Git Log) ---
:commit_navigation_graph
call :refresh_git_metrics
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🗺️  COMMIT NAVIGATION GRAPH (KEIFU / GIT LOG)%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
if !HAS_COMMITS! EQU 0 (
  echo %YELLOW%⚠️ No commits found in repository yet.%RESET%
  goto :eof
)

if exist "%SCRIPT_DIR%\bin\keifu.exe" (
  "%SCRIPT_DIR%\bin\keifu.exe"
  goto :eof
)
where keifu >nul 2>&1
if not errorlevel 1 (
  keifu
  goto :eof
)

echo %YELLOW%Keifu interactive TUI binary not found at bin\keifu.exe.%RESET%
echo Falling back to colored git log commit graph:
echo.
git log --graph --color --format=format:"%%C(bold blue)%%h%%C(reset) - %%C(bold green)(%%ar)%%C(reset) %%C(white)%%s%%C(reset) %%C(dim white)- %%an%%C(reset)%%C(bold yellow)%%d%%C(reset)" --abbrev-commit -n 25
goto :eof

rem --- 20. Version & Tag Manager ---
:compute_version_suggestion
set "v_major=0"
set "v_minor=1"
set "v_patch=0"

rem Parse latest tag if available
if not "!LATEST_TAG!"=="v0.0.0" (
  set "clean_tag=!LATEST_TAG!"
  if "!clean_tag:~0,1!"=="v" set "clean_tag=!clean_tag:~1!"
  for /f "tokens=1,2,3 delims=." %%a in ("!clean_tag!") do (
    set "v_major=%%a"
    set "v_minor=%%b"
    set "v_patch=%%c"
  )
)

set /a has_breaking=0
set /a has_feat=0
set /a has_fix=0

for /f "tokens=*" %%m in ('git log -30 --format^="%%s" 2^>nul') do (
  echo %%m | findstr /i "BREAKING break rewrite" >nul 2>&1
  if not errorlevel 1 set /a has_breaking+=1

  echo %%m | findstr /i "feat feature add" >nul 2>&1
  if not errorlevel 1 set /a has_feat+=1

  echo %%m | findstr /i "fix bug patch" >nul 2>&1
  if not errorlevel 1 set /a has_fix+=1
)

if !has_breaking! GTR 0 (
  set /a v_major+=1
  set "v_minor=0"
  set "v_patch=0"
) else if !has_feat! GTR 0 (
  set /a v_minor+=1
  set "v_patch=0"
) else (
  set /a v_patch+=1
)
set "REC_TAG=!v_major!.!v_minor!.!v_patch!"
goto :eof

:show_version_recommendation
call :refresh_git_metrics
call :compute_version_suggestion
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🏷️  VERSION ^& TAG MANAGER (SemVer)%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo   Current Version     : %YELLOW%!LATEST_TAG!%RESET%
echo   Commits Since Tag   : %CYAN%!COMMITS_SINCE_TAG!%RESET%
echo   Recommended Version : %GREEN%%BOLD%v!REC_TAG!%RESET%
echo.
echo   1) Create Recommended Version Tag (v!REC_TAG!)
echo   2) Create Custom Tag Name
echo   3) List All Tags
echo   4) Push All Tags to Remote (git push --tags)
echo   5) Delete a Tag (Pick from list)
echo   0) Cancel
set "tag_sel="
set /p tag_sel="Select option [0-5]: "
if "!tag_sel!"=="1" (
  set "tmsg="
  set /p tmsg="Enter tag annotation message [default: Release v!REC_TAG!]: "
  if "!tmsg!"=="" set "tmsg=Release v!REC_TAG!"
  git tag -a "v!REC_TAG!" -m "!tmsg!"
  echo %GREEN%✅ Tag v!REC_TAG! created!%RESET%
  set "p_tag_ans="
  set /p p_tag_ans="Push tag to remote now? [Y/n]: "
  if /i not "!p_tag_ans!"=="n" git push "!REMOTE_NAME!" "v!REC_TAG!"
)
if "!tag_sel!"=="2" (
  set "custom_t="
  set /p custom_t="Enter tag name (e.g. v1.0.0): "
  if not "!custom_t!"=="" (
    set "custom_tmsg="
    set /p custom_tmsg="Enter tag message [default: Release !custom_t!]: "
    if "!custom_tmsg!"=="" set "custom_tmsg=Release !custom_t!"
    git tag -a "!custom_t!" -m "!custom_tmsg!"
    echo %GREEN%✅ Tag !custom_t! created!%RESET%
    set "p_tag_ans="
    set /p p_tag_ans="Push tag to remote now? [Y/n]: "
    if /i not "!p_tag_ans!"=="n" git push "!REMOTE_NAME!" "!custom_t!"
  )
)
if "!tag_sel!"=="3" (
  git tag -n --sort=-v:refname
)
if "!tag_sel!"=="4" (
  git push "!REMOTE_NAME!" --tags
)
if "!tag_sel!"=="5" (
  call :select_tag
  if defined SELECTED_TAG (
    set "conf_del="
    set /p conf_del="Delete tag '!SELECTED_TAG!'? [y/N]: "
    if /i "!conf_del!"=="y" (
      git tag -d "!SELECTED_TAG!"
      echo %GREEN%✅ Tag deleted: !SELECTED_TAG!%RESET%
    )
  )
)
goto :eof

rem --- 21. Generate Changelog ---
:generate_changelog
call :compute_version_suggestion
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%📄 GENERATE CHANGELOG%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
set "cl_ans="
set /p cl_ans="Generate/Update CHANGELOG.md for version v!REC_TAG!? [Y/n]: "
if /i "!cl_ans!"=="n" goto :eof

for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set "TODAY=%%c-%%a-%%b"
if not exist CHANGELOG.md (
  (
    echo # Changelog
    echo.
    echo All notable changes to project %PROJECT_NAME% will be documented in this file.
    echo.
  ) > CHANGELOG.md
)

(
  echo.
  echo ## [v!REC_TAG!] - !DATE!
  echo.
  echo ### Features
  for /f "tokens=*" %%m in ('git log -20 --format^="- %%s" 2^>nul ^| findstr /i "feat feature add"') do echo %%m
  echo.
  echo ### Fixes
  for /f "tokens=*" %%m in ('git log -20 --format^="- %%s" 2^>nul ^| findstr /i "fix bug hotfix"') do echo %%m
  echo.
  echo ### Maintenance ^& Refactoring
  for /f "tokens=*" %%m in ('git log -20 --format^="- %%s" 2^>nul ^| findstr /i "refactor chore clean"') do echo %%m
) >> CHANGELOG.md

echo %GREEN%✅ CHANGELOG.md generated successfully!%RESET%
goto :eof

rem --- 22. Git Stash Manager ---
:stash_manager
:sm_loop
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🗄️  GIT STASH MANAGER (TEMPORARY STORAGE)%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo   1) 📥 Stash Current Changes (git stash push -m "...")
echo   2) 📦 Stash Including Untracked Files (git stash push -u)
echo   3) 📋 List Saved Stashes (git stash list)
echo   4) 🔍 Show Stash Diff (Pick from list)
echo   5) 📤 Pop Latest Stash (Apply ^& Remove)
echo   6) ♻️  Apply Stash (Pick from list)
echo   7) 🗑️  Drop / Delete Stash (Pick from list)
echo   8) ⚠️  Clear All Stashes (git stash clear)
echo   0) Back to Main Menu
set "st_choice="
set /p st_choice="Select stash option [0-8]: "
if "!st_choice!"=="0" goto :eof
if "!st_choice!"=="1" (
  set "st_msg="
  set /p st_msg="Enter stash description message: "
  if not "!st_msg!"=="" (
    git stash push -m "!st_msg!"
  ) else (
    git stash push
  )
)
if "!st_choice!"=="2" (
  git stash push -u
  echo %GREEN%✅ Stashed changes including untracked files.%RESET%
)
if "!st_choice!"=="3" git stash list
if "!st_choice!"=="4" (
  call :select_stash
  if defined SELECTED_STASH git stash show -p "!SELECTED_STASH!"
)
if "!st_choice!"=="5" git stash pop
if "!st_choice!"=="6" (
  call :select_stash
  if defined SELECTED_STASH git stash apply "!SELECTED_STASH!"
)
if "!st_choice!"=="7" (
  call :select_stash
  if defined SELECTED_STASH git stash drop "!SELECTED_STASH!"
)
if "!st_choice!"=="8" (
  set "conf_clr="
  set /p conf_clr="%RED%⚠️ Permanently delete ALL stashes? [y/N]: %RESET%"
  if /i "!conf_clr!"=="y" git stash clear
)
goto :sm_loop

rem --- 23. Undo & Backtrack ---
:undo_and_recovery_menu
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%⏪ UNDO, RESET ^& RECOVERY (SAFETY NET)%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo   1) ⏪ Interactive Commit Backtracking (Pick from commit timeline)
echo   2) ↩️  Soft Undo Last Commit (HEAD~1: keeps changes staged)
echo   3) ♻️  Mixed Undo Last Commit (HEAD~1: keeps changes unstaged in files)
echo   4) 📜 View Git Reflog (Find and recover lost commits)
echo   5) ⏹️  Abort Ongoing Rebase ^& Go Back (git rebase --abort)
echo   6) ⏹️  Abort Ongoing Merge ^& Go Back (git merge --abort)
echo   0) Cancel
set "rchoice="
set /p rchoice="Select option [0-6]: "
if "!rchoice!"=="1" call :backtrack_commit_hub
if "!rchoice!"=="2" (
  set "conf_u="
  set /p conf_u="Soft-undo last commit? (Changes stay staged) [Y/n]: "
  if /i not "!conf_u!"=="n" (
    git reset --soft HEAD~1
    echo %GREEN%✅ Last commit undone (changes kept staged).%RESET%
  )
)
if "!rchoice!"=="3" (
  set "conf_u="
  set /p conf_u="Mixed-undo last commit? (Changes stay in files) [Y/n]: "
  if /i not "!conf_u!"=="n" (
    git reset --mixed HEAD~1
    echo %GREEN%✅ Last commit undone (changes preserved in files).%RESET%
  )
)
if "!rchoice!"=="4" (
  echo %CYAN%── Git Reflog ─────────────────────────────────────────────────────%RESET%
  git reflog -n 25
)
if "!rchoice!"=="5" call :abort_rebase_or_merge
if "!rchoice!"=="6" call :abort_rebase_or_merge
goto :eof

:backtrack_commit_hub
call :select_commit "Select target commit to backtrack/inspect" 15
if not defined SELECTED_COMMIT goto :eof

echo.
echo Selected Target: %YELLOW%%BOLD%!SELECTED_COMMIT!%RESET%
echo   1) ⏪ Soft Backtrack (Reset to commit, KEEP all changes STAGED) [Safe]
echo   2) ♻️  Mixed Backtrack (Reset to commit, KEEP changes in files UNSTAGED) [Safe]
echo   3) 🕵️  Time-Travel ^& Inspect (Checkout commit in read-only detached state)
echo   4) 🔄 Revert this commit (Create a reverse commit: git revert)
echo   5) 📜 View Commit Diff ^& Details (git show)
echo   6) ⚠️  Hard Reset to this commit (DISCARD all changes newer than this commit)
echo   0) Cancel
set "b_action="
set /p b_action="Select action [0-6]: "
if "!b_action!"=="1" (
  git reset --soft "!SELECTED_COMMIT!"
  echo %GREEN%✅ Reset --soft to !SELECTED_COMMIT! completed.%RESET%
)
if "!b_action!"=="2" (
  git reset --mixed "!SELECTED_COMMIT!"
  echo %GREEN%✅ Reset --mixed to !SELECTED_COMMIT! completed.%RESET%
)
if "!b_action!"=="3" (
  git checkout "!SELECTED_COMMIT!"
  echo %GREEN%✅ Checked out !SELECTED_COMMIT!. Use Branch Manager to return.%RESET%
)
if "!b_action!"=="4" (
  git revert "!SELECTED_COMMIT!"
)
if "!b_action!"=="5" (
  git show "!SELECTED_COMMIT!"
)
if "!b_action!"=="6" (
  echo %RED%⚠️ WARNING: HARD RESET PERMANENTLY DISCARDS COMMITS AFTER !SELECTED_COMMIT!%RESET%
  set "conf_hr="
  set /p conf_hr="Are you sure you want to HARD RESET to !SELECTED_COMMIT!? [y/N]: "
  if /i "!conf_hr!"=="y" (
    git reset --hard "!SELECTED_COMMIT!"
    echo %GREEN%✅ Hard reset to !SELECTED_COMMIT! completed.%RESET%
  )
)
goto :eof

rem --- 24. Abort Rebase / Merge ---
:abort_rebase_or_merge
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%⏹️  ABORT REBASE / MERGE — EMERGENCY GO BACK%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%

if !IS_REBASING! EQU 1 (
  echo %YELLOW%⚠️ Active rebase detected in repository.%RESET%
  echo Aborting will cancel the rebase and immediately restore your branch to its exact
  echo state before 'git rebase' was started, preserving all your previous commits.
  echo.
  set "conf_ab="
  set /p conf_ab="Confirm: Abort rebase and GO BACK to your original version? [Y/n]: "
  if /i not "!conf_ab!"=="n" (
    git rebase --abort
    if not errorlevel 1 (
      echo %GREEN%✅ Rebase successfully ABORTED! Restored to previous state.%RESET%
    ) else (
      echo %RED%❌ git rebase --abort encountered an issue.%RESET%
    )
  )
  goto :eof
)

if !IS_MERGING! EQU 1 (
  echo %YELLOW%⚠️ Active merge conflict detected in repository.%RESET%
  echo Aborting will cancel the merge and restore your branch to pre-merge state.
  echo.
  set "conf_ab="
  set /p conf_ab="Confirm: Abort merge and GO BACK to your original version? [Y/n]: "
  if /i not "!conf_ab!"=="n" (
    git merge --abort
    if not errorlevel 1 (
      echo %GREEN%✅ Merge successfully ABORTED! Restored to pre-merge state.%RESET%
    ) else (
      echo %RED%❌ git merge --abort encountered an issue.%RESET%
    )
  )
  goto :eof
)

echo Attempting rebase abort...
git rebase --abort 2>nul
if not errorlevel 1 (
  echo %GREEN%✅ Rebase aborted successfully.%RESET%
  goto :eof
)
echo Attempting merge abort...
git merge --abort 2>nul
if not errorlevel 1 (
  echo %GREEN%✅ Merge aborted successfully.%RESET%
  goto :eof
)
echo %YELLOW%No rebase or merge currently in progress to abort.%RESET%
goto :eof

rem --- 25. Git Identity Config ---
:configure_git_identity
call :prompt_identity
goto :eof

rem --- 26. Repository Optimization ---
:repo_optimization
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🧹 REPOSITORY OPTIMIZATION ^& CLEANUP%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo Step 1/2: Pruning deleted remote tracking branches...
git remote prune origin 2>nul
echo Step 2/2: Running aggressive garbage collection...
git gc --prune=now --aggressive
echo %GREEN%✅ Garbage collection and pruning complete!%RESET%
goto :eof

rem --- 27. Smart Tips & Cheatsheet ---
:display_smart_tips
echo %CYAN%╔════════════════════════════════════════════════════════════════════════════════════╗%RESET%
echo %CYAN%║%RESET%                         %BOLD%💡 GIT BEST PRACTICES ^& PRO TIPS%RESET%                           %CYAN%║%RESET%
echo %CYAN%╠════════════════════════════════════════════════════════════════════════════════════╣%RESET%
echo %CYAN%║%RESET% 1. %BOLD%Commit Often, Polish Before Pushing%RESET%                                        %CYAN%║%RESET%
echo %CYAN%║%RESET%    Make small, atomic commits for single logical units of work.                     %CYAN%║%RESET%
echo %CYAN%║%RESET% 2. %BOLD%Pull with Rebase%RESET%                                                           %CYAN%║%RESET%
echo %CYAN%║%RESET%    Use 'git pull --rebase' to maintain a clean linear commit graph.                 %CYAN%║%RESET%
echo %CYAN%║%RESET% 3. %BOLD%Conventional Commit Format with Icons%RESET%                                      %CYAN%║%RESET%
echo %CYAN%║%RESET%    '✨ feat', '🐛 fix', '📚 docs' makes history readable and changelogs easy.       %CYAN%║%RESET%
echo %CYAN%║%RESET% 4. %BOLD%Emergency Escape Plan%RESET%                                                      %CYAN%║%RESET%
echo %CYAN%║%RESET%    If rebase or merge goes wrong, type 'A' from the menu to abort instantly!        %CYAN%║%RESET%
echo %CYAN%╚════════════════════════════════════════════════════════════════════════════════════╝%RESET%
goto :eof

rem --- 29. .gitignore Manager ---
:gitignore_manager
:gm_loop
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo %BOLD%🙈 .GITIGNORE MANAGER%RESET%
echo %CYAN%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%RESET%
echo Current ignored entries:
if exist .gitignore (
  for /f "tokens=*" %%a in (.gitignore) do echo   - %%a
) else (
  echo   (No .gitignore file found)
)
echo.
echo   1) ➕ Add a file or folder to .gitignore
echo   2) ➖ Remove an entry from .gitignore
echo   3) 📄 View raw .gitignore file
echo   0) 🔙 Back
set "gchoice="
set /p gchoice="Select option [0-3]: "
if "!gchoice!"=="0" goto :eof
if "!gchoice!"=="1" (
  set "gadd="
  set /p gadd="Enter file or folder name to ignore: "
  if not "!gadd!"=="" (
    echo !gadd!>>.gitignore
    echo %GREEN%✅ Added '!gadd!' to .gitignore%RESET%
  )
)
if "!gchoice!"=="2" (
  set "grem="
  set /p grem="Enter exact entry to remove: "
  if exist .gitignore if not "!grem!"=="" (
    findstr /V /C:"!grem!" .gitignore > .gitignore.tmp
    move /Y .gitignore.tmp .gitignore >nul
    echo %GREEN%✅ Removed '!grem!' from .gitignore if it existed.%RESET%
  )
)
if "!gchoice!"=="3" (
  if exist .gitignore (
    type .gitignore
  ) else (
    echo %YELLOW%No .gitignore file exists.%RESET%
  )
)
goto :gm_loop
