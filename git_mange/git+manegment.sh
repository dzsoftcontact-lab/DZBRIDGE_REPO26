#!/usr/bin/env bash
# ==============================================================================
#  🩺 GIT PROJECT HEALTH & WORKFLOW MANAGER — PRO EDITION
# ==============================================================================
#  Author  : Degha Houssem Eddine
#  Version : 3.1.0
#  Purpose : Comprehensive, automated, safe interactive Git workflow & DevOps manager.
#            Observe → Analyze → Assess → Recommend → Guide → Execute → Verify
# ==============================================================================

# Terminal Colors & Styling (real escape characters)
if [[ -t 1 ]] || [[ -n "${TERM:-}" && "${TERM:-}" != "dumb" ]]; then
  RESET=$'\e[0m'
  BOLD=$'\e[1m'
  DIM=$'\e[2m'
  UNDERLINE=$'\e[4m'
  RED=$'\e[0;31m'
  GREEN=$'\e[0;32m'
  YELLOW=$'\e[1;33m'
  BLUE=$'\e[0;34m'
  MAGENTA=$'\e[0;35m'
  CYAN=$'\e[0;36m'
  WHITE=$'\e[1;37m'
  GRAY=$'\e[0;90m'
  BG_BLUE=$'\e[44m'
  BG_DARK=$'\e[40m'
else
  RESET=''
  BOLD=''
  DIM=''
  UNDERLINE=''
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  MAGENTA=''
  CYAN=''
  WHITE=''
  GRAY=''
  BG_BLUE=''
  BG_DARK=''
fi

# Clean exit trap
trap 'printf "\n%b\n" "${GREEN}👋 Exiting Git Project Health Manager. Goodbye!${RESET}"; exit 0' SIGINT SIGTERM

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global State Variables
REPO_PATH=""
PROJECT_NAME=""
GIT_OK=0
REPO_OK=0
HAS_COMMITS=0
CURRENT_BRANCH="unknown"
UPSTREAM_BRANCH="none"
REMOTE_NAME="not configured"
REMOTE_URL="not configured"
LAST_COMMIT_HASH="none"
LAST_COMMIT_MSG="No commits yet"
LAST_COMMIT_DATE="none"
CURRENT_VERSION="v0.0.0"
COMMITS_SINCE_TAG=0
UNCOMMITTED_FILES=0
STAGED_FILES=0
UNSTAGED_FILES=0
UNTRACKED_FILES=0
CONFLICTED_FILES=0
FILES_ADDED=0
FILES_MODIFIED=0
FILES_DELETED=0
LINES_ADDED=0
LINES_REMOVED=0
MODULES_AFFECTED=0
AHEAD_COUNT=0
BEHIND_COUNT=0
UNPUSHED_COMMITS=0
REPO_HEALTH=100
WORKFLOW_STATE="HEALTHY"
RECOMMENDATION="Repository is healthy. Continue development."

# ------------------------------------------------------------------------------
# Helper Utilities
# ------------------------------------------------------------------------------

print_line() {
  printf '%b\n' "${1:-}"
}

print_header() {
  printf '\n'
  printf '%b\n' "${CYAN}╔════════════════════════════════════════════════════════════════════════════════════╗${RESET}"
  printf '%b\n' "${CYAN}║${RESET}                   ${BOLD}🩺 GIT PROJECT HEALTH & WORKFLOW MANAGER${RESET}                         ${CYAN}║${RESET}"
  printf '%b\n' "${CYAN}║${RESET}                 ${DIM}Intelligent DevOps Automation • by Degha Houssem Eddine${RESET}             ${CYAN}║${RESET}"
  printf '%b\n' "${CYAN}╚════════════════════════════════════════════════════════════════════════════════════╝${RESET}"
}

press_any_key() {
  printf '\n'
  read -r -p "$(printf '%b' "${BOLD}${WHITE}Press [Enter] to return to the menu...${RESET}")" _dummy || true
}

action_prompt() {
  local prompt="$1"
  local default="${2:-y}"
  local answer=""

  if [[ "$default" == "y" || "$default" == "Y" ]]; then
    read -r -p "$(printf '%b' "${YELLOW}${prompt}${RESET} ${BOLD}[Y/n]:${RESET} ")" answer || answer="y"
    [[ -z "$answer" ]] && answer="y"
  else
    read -r -p "$(printf '%b' "${YELLOW}${prompt}${RESET} ${BOLD}[y/N]:${RESET} ")" answer || answer="n"
    [[ -z "$answer" ]] && answer="n"
  fi

  [[ "$answer" =~ ^[Yy]$ ]]
}

detect_and_setup_portable_git() {
  if command -v git >/dev/null 2>&1; then
    return 0
  fi

  local portable_paths=(
    "$SCRIPT_DIR/git_system/cmd"
    "$SCRIPT_DIR/git_system/bin"
    "$SCRIPT_DIR/git_system/usr/bin"
    "$SCRIPT_DIR/git_system"
  )

  for ppath in "${portable_paths[@]}"; do
    if [[ -d "$ppath" ]]; then
      if [[ -x "$ppath/git" || -f "$ppath/git.exe" || -f "$ppath/git" ]]; then
        export PATH="$ppath:$PATH"
        chmod +x "$ppath/git" 2>/dev/null || true
        if command -v git >/dev/null 2>&1; then
          print_line "${CYAN}ℹ️  System Git not found in PATH. Operating seamlessly using local Portable Git from: ${ppath}${RESET}"
          return 0
        fi
      fi
    fi
  done

  return 1
}

offline_git_setup_hub() {
  while true; do
    print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    print_line "${BOLD}📦 OFFLINE GIT INSTALLER & PORTABLE SETUP HUB${RESET}"
    print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    print_line "This module installs Git 100% offline or configures Portable Git in ./git_system/"
    printf '\n'
    cat <<'EOF'
  1) 🪟 Windows Offline Installation (Install from git_setup/windows/*.exe)
  2) 🐧 Linux / Ubuntu Offline Installation (Install from git_setup/linux/*.deb)
  3) 💼 Setup Portable Git in ./git_system/ (Local standalone Portable Git)
  4) 📄 View Offline Setup Guide & Instructions
  0) Back / Cancel
EOF
    read -r -p "${BOLD}Select OS / Installation Option [0-4]:${RESET} " os_choice
    case "$os_choice" in
      1)
        print_line "${CYAN}Searching for Windows Git Installer in ./git_setup/windows/...${RESET}"
        local win_inst=()
        while IFS= read -r f; do
          [[ -n "$f" ]] && win_inst+=("$f")
        done < <(find "$SCRIPT_DIR/git_setup/windows" -maxdepth 2 \( -name "*.exe" -o -name "*.msi" -o -name "*.zip" -o -name "*.7z" \) 2>/dev/null)

        if [[ ${#win_inst[@]} -eq 0 ]]; then
          print_line "${YELLOW}⚠️  No Windows Git installer found in ./git_setup/windows/${RESET}"
          print_line "Please place your Git installer file (e.g. Git-2.44.0-64-bit.exe) into:"
          print_line "  ${CYAN}$SCRIPT_DIR/git_setup/windows/${RESET}"
        else
          print_line "${GREEN}Found ${#win_inst[@]} installer package(s):${RESET}"
          for idx in "${!win_inst[@]}"; do
            printf "  %d) %s\n" "$((idx + 1))" "$(basename "${win_inst[$idx]}")"
          done
          read -r -p "Select package to install [1-${#win_inst[@]}]: " pidx
          if [[ "$pidx" =~ ^[0-9]+$ ]] && (( pidx >= 1 && pidx <= ${#win_inst[@]} )); then
            local target_file="${win_inst[$((pidx - 1))]}"
            print_line "${CYAN}Executing offline Windows installer: $(basename "$target_file")...${RESET}"
            if [[ "$target_file" == *.exe ]]; then
              if command -v cmd.exe >/dev/null 2>&1; then
                cmd.exe /c start "" "$target_file" /VERYSILENT /NORESTART /NOCANCEL /SP-
                print_line "${GREEN}✅ Windows Git installation triggered silently.${RESET}"
              else
                print_line "${YELLOW}Launching executable installer...${RESET}"
                "$target_file" 2>/dev/null || true
              fi
            elif [[ "$target_file" == *.zip ]]; then
              print_line "${CYAN}Extracting portable Git archive to ./git_system/...${RESET}"
              unzip -o "$target_file" -d "$SCRIPT_DIR/git_system" 2>/dev/null || true
              print_line "${GREEN}✅ Extracted portable Git to ./git_system/${RESET}"
            fi
          fi
        fi
        ;;
      2)
        print_line "${CYAN}Searching for Linux / Ubuntu .deb packages in ./git_setup/linux/...${RESET}"
        local deb_files=()
        while IFS= read -r df; do
          [[ -n "$df" ]] && deb_files+=("$df")
        done < <(find "$SCRIPT_DIR/git_setup/linux" -maxdepth 2 -name "*.deb" 2>/dev/null)

        if [[ ${#deb_files[@]} -eq 0 ]]; then
          print_line "${YELLOW}⚠️  No .deb packages found in ./git_setup/linux/${RESET}"
          print_line "Please place your offline Git .deb packages (git_*.deb, git-man_*.deb) into:"
          print_line "  ${CYAN}$SCRIPT_DIR/git_setup/linux/${RESET}"
        else
          print_line "${GREEN}Found ${#deb_files[@]} .deb package(s) for Linux offline installation:${RESET}"
          for df in "${deb_files[@]}"; do
            print_line "  - $(basename "$df")"
          done
          if action_prompt "Install all .deb packages offline using sudo dpkg?" "y"; then
            print_line "${CYAN}Running: sudo dpkg -i $SCRIPT_DIR/git_setup/linux/*.deb${RESET}"
            if sudo dpkg -i "$SCRIPT_DIR/git_setup/linux/"*.deb; then
              print_line "${GREEN}✅ Git installed successfully offline on Linux!${RESET}"
            else
              print_line "${YELLOW}Fixing missing dependencies offline...${RESET}"
              sudo apt-get install -f -y || true
            fi
          fi
        fi
        ;;
      3)
        print_line "${CYAN}💼 PORTABLE GIT SETUP IN ./git_system/${RESET}"
        print_line "Creating portable directory structure in: ${CYAN}$SCRIPT_DIR/git_system${RESET}"
        mkdir -p "$SCRIPT_DIR/git_system/bin" "$SCRIPT_DIR/git_system/cmd" "$SCRIPT_DIR/git_system/usr/bin"
        
        local archive
        archive="$(find "$SCRIPT_DIR/git_setup" -name "*portable*.zip" -o -name "*git*.zip" 2>/dev/null | head -n 1 || echo "")"
        if [[ -n "$archive" ]]; then
          print_line "${CYAN}Found portable archive: $(basename "$archive"). Extracting...${RESET}"
          unzip -o "$archive" -d "$SCRIPT_DIR/git_system" 2>/dev/null || true
          print_line "${GREEN}✅ Extracted portable Git into ./git_system/${RESET}"
        else
          print_line "${YELLOW}Portable directory prepared at:${RESET} $SCRIPT_DIR/git_system/"
          print_line "To enable Portable Git mode, place portable Git binaries into:"
          print_line "  - Linux:   $SCRIPT_DIR/git_system/bin/git"
          print_line "  - Windows: $SCRIPT_DIR/git_system/cmd/git.exe"
        fi
        ;;
      4)
        if [[ -f "$SCRIPT_DIR/git_setup/README.md" ]]; then
          cat "$SCRIPT_DIR/git_setup/README.md"
        else
          print_line "${CYAN}Offline Git Setup Guide:${RESET}"
          print_line "1. Place Windows Git installer (.exe) into git_setup/windows/"
          print_line "2. Place Ubuntu Git .deb packages into git_setup/linux/"
          print_line "3. Place portable Git binaries into git_system/"
        fi
        ;;
      0) break ;;
      *) print_line "${YELLOW}Invalid choice.${RESET}" ;;
    esac
    press_any_key
  done
}

require_git() {
  if detect_and_setup_portable_git; then
    return 0
  fi

  print_line "${RED}❌ Git is not installed on this system, and no portable Git found in ./git_system/.${RESET}"
  print_line "${YELLOW}Would you like to run the Offline Git & Portable Setup Hub now?${RESET}"
  if action_prompt "Launch Offline Git Installer?" "y"; then
    offline_git_setup_hub
    if detect_and_setup_portable_git; then
      return 0
    fi
  fi
  return 1
}

ensure_repo() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print_line "${YELLOW}⚠️  No Git repository detected in current directory (${PWD}).${RESET}"
    if action_prompt "Would you like to initialize a new Git repository here?" "y"; then
      if git init; then
        print_line "${GREEN}✅ Initialized new empty Git repository.${RESET}"
        return 0
      else
        print_line "${RED}❌ Failed to initialize repository.${RESET}"
        return 1
      fi
    else
      print_line "${BLUE}ℹ️  Repository initialization skipped.${RESET}"
      return 1
    fi
  fi
  return 0
}

# ------------------------------------------------------------------------------
# Interactive Selection Helpers (Pick by Number or Enter Manually)
# ------------------------------------------------------------------------------

# Select a branch from a list or manual input
select_branch() {
  local prompt_msg="${1:-Select a branch}"
  local include_remote="${2:-0}"
  local -a branch_list=()

  while IFS= read -r b; do
    [[ -n "$b" ]] && branch_list+=("$b")
  done < <(git for-each-ref --format='%(refname:short)' refs/heads/)

  if [[ "$include_remote" == "1" ]]; then
    while IFS= read -r rb; do
      [[ -n "$rb" && ! "$rb" =~ HEAD ]] && branch_list+=("$rb")
    done < <(git for-each-ref --format='%(refname:short)' refs/remotes/)
  fi

  if [[ ${#branch_list[@]} -eq 0 ]]; then
    print_line "${YELLOW}No branches found.${RESET}" >&2
    return 1
  fi

  {
    print_line "\n${CYAN}${BOLD}📋 Available Branches List:${RESET}"
    local cur_br
    cur_br="$(git branch --show-current 2>/dev/null || true)"
    for i in "${!branch_list[@]}"; do
      local b="${branch_list[$i]}"
      local icon="🌿"
      local tag=""
      if [[ "$b" == "$cur_br" ]]; then
        icon="⭐"
        tag=" ${GREEN}[ACTIVE]${RESET}"
      elif [[ "$b" =~ ^origin/ ]]; then
        icon="🌐"
        tag=" ${BLUE}[REMOTE]${RESET}"
      fi
      local cinfo
      cinfo="$(git log -1 --format='%h - %s (%cr)' "$b" 2>/dev/null || echo '')"
      printf "  %b%2d)%b %s %-28s%b ${DIM}%s${RESET}\n" "${BOLD}" "$((i + 1))" "${RESET}" "$icon" "$b" "$tag" "${cinfo:0:45}"
    done
    printf "  %b M)%b ✍️  Enter branch name manually\n" "${BOLD}" "${RESET}"
    printf "  %b 0)%b ❌ Cancel\n\n" "${BOLD}" "${RESET}"
  } >&2

  local sel=""
  read -r -p "$(printf '%b' "${BOLD}${YELLOW}${prompt_msg}${RESET} [1-${#branch_list[@]}, M, 0]: ")" sel
  if [[ "$sel" == "0" || -z "$sel" ]]; then
    return 1
  elif [[ "$sel" =~ ^[Mm]$ ]]; then
    read -r -p "Enter branch name manually: " man_b
    if [[ -n "$man_b" ]]; then
      printf '%s' "$man_b"
      return 0
    else
      return 1
    fi
  elif [[ "$sel" =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= ${#branch_list[@]} )); then
    printf '%s' "${branch_list[$((sel - 1))]}"
    return 0
  else
    print_line "${YELLOW}Invalid selection.${RESET}" >&2
    return 1
  fi
}

# Select a commit from history or manual input
select_commit() {
  local prompt_msg="${1:-Select a commit}"
  local count="${2:-15}"
  local -a hashes=()
  local -a summaries=()

  while IFS='|' read -r h s cr an; do
    [[ -n "$h" ]] || continue
    hashes+=("$h")
    summaries+=("${h}|${s}|${cr}|${an}")
  done < <(git log -n "$count" --format='%h|%s|%cr|%an' 2>/dev/null || true)

  if [[ ${#hashes[@]} -eq 0 ]]; then
    print_line "${YELLOW}No commits found in history.${RESET}" >&2
    return 1
  fi

  {
    print_line "\n${CYAN}${BOLD}📜 Commit History Timeline (Select a point in time):${RESET}"
    for idx in "${!hashes[@]}"; do
      IFS='|' read -r ch cs cdate cauthor <<< "${summaries[$idx]}"
      local rel_marker=""
      if (( idx == 0 )); then
        rel_marker=" ${GREEN}[HEAD]${RESET}"
      else
        rel_marker=" ${DIM}[HEAD~${idx}]${RESET}"
      fi
      printf "  %b%2d)%b 📦 %s%b - %s ${DIM}(%s by %s)${RESET}\n" \
        "${BOLD}" "$((idx + 1))" "${RESET}" "$ch" "$rel_marker" "${cs:0:45}" "$cdate" "$cauthor"
    done
    printf "  %b M)%b ✍️  Enter commit hash / ref manually\n" "${BOLD}" "${RESET}"
    printf "  %b 0)%b ❌ Cancel\n\n" "${BOLD}" "${RESET}"
  } >&2

  local sel=""
  read -r -p "$(printf '%b' "${BOLD}${YELLOW}${prompt_msg}${RESET} [1-${#hashes[@]}, M, 0]: ")" sel
  if [[ "$sel" == "0" || -z "$sel" ]]; then
    return 1
  elif [[ "$sel" =~ ^[Mm]$ ]]; then
    read -r -p "Enter commit hash or ref (e.g. HEAD~2 or abc1234): " manual_ref
    if [[ -n "$manual_ref" ]]; then
      printf '%s' "$manual_ref"
      return 0
    else
      return 1
    fi
  elif [[ "$sel" =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= ${#hashes[@]} )); then
    printf '%s' "${hashes[$((sel - 1))]}"
    return 0
  else
    print_line "${YELLOW}Invalid selection.${RESET}" >&2
    return 1
  fi
}

# Select a file from working tree / staged / untracked
select_file() {
  local prompt_msg="${1:-Select a file}"
  local filter="${2:-all}" # all, staged, unstaged, untracked
  local -a file_list=()
  local -a status_list=()

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local code="${line:0:2}"
    local fname="${line:3}"
    local include=0

    case "$filter" in
      staged)
        [[ "${code:0:1}" != " " && "${code:0:1}" != "?" ]] && include=1
        ;;
      unstaged)
        [[ "${code:1:1}" != " " && "${code:1:1}" != "?" ]] && include=1
        ;;
      untracked)
        [[ "$code" == "??" ]] && include=1
        ;;
      all|*)
        include=1
        ;;
    esac

    if (( include == 1 )); then
      file_list+=("$fname")
      status_list+=("$code")
    fi
  done < <(git status --porcelain 2>/dev/null || true)

  if [[ ${#file_list[@]} -eq 0 ]]; then
    print_line "${YELLOW}No matching files found for filter: $filter.${RESET}" >&2
    return 1
  fi

  {
    print_line "\n${CYAN}${BOLD}📁 Changed Files List ($filter):${RESET}"
    for i in "${!file_list[@]}"; do
      local fn="${file_list[$i]}"
      local cd="${status_list[$i]}"
      local s_icon="📝"
      if [[ "$cd" == "??" ]]; then s_icon="❓ [Untracked]"
      elif [[ "$cd" =~ A ]]; then s_icon="🟩 [Added]"
      elif [[ "$cd" =~ D ]]; then s_icon="🟥 [Deleted]"
      elif [[ "$cd" =~ [MR] ]]; then s_icon="🟨 [Modified]"
      fi
      printf "  %b%2d)%b %-16s %s\n" "${BOLD}" "$((i + 1))" "${RESET}" "$s_icon" "$fn"
    done
    printf "  %b A)%b ➕ Select ALL files\n" "${BOLD}" "${RESET}"
    printf "  %b M)%b ✍️  Enter file path manually\n" "${BOLD}" "${RESET}"
    printf "  %b 0)%b ❌ Cancel\n\n" "${BOLD}" "${RESET}"
  } >&2

  local sel=""
  read -r -p "$(printf '%b' "${BOLD}${YELLOW}${prompt_msg}${RESET} [1-${#file_list[@]}, A, M, 0]: ")" sel
  if [[ "$sel" == "0" || -z "$sel" ]]; then
    return 1
  elif [[ "$sel" =~ ^[Aa]$ ]]; then
    printf 'ALL'
    return 0
  elif [[ "$sel" =~ ^[Mm]$ ]]; then
    read -r -p "Enter file path manually: " man_f
    if [[ -n "$man_f" ]]; then
      printf '%s' "$man_f"
      return 0
    else
      return 1
    fi
  elif [[ "$sel" =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= ${#file_list[@]} )); then
    printf '%s' "${file_list[$((sel - 1))]}"
    return 0
  else
    print_line "${YELLOW}Invalid selection.${RESET}" >&2
    return 1
  fi
}

# Select a stash
select_stash() {
  local prompt_msg="${1:-Select a stash}"
  local -a stash_list=()

  while IFS= read -r st; do
    [[ -n "$st" ]] && stash_list+=("$st")
  done < <(git stash list 2>/dev/null || true)

  if [[ ${#stash_list[@]} -eq 0 ]]; then
    print_line "${YELLOW}No stashes found in this repository.${RESET}" >&2
    return 1
  fi

  {
    print_line "\n${CYAN}${BOLD}🗄️ Available Stashes:${RESET}"
    for i in "${!stash_list[@]}"; do
      printf "  %b%2d)%b 🗄️  %s\n" "${BOLD}" "$((i + 1))" "${RESET}" "${stash_list[$i]}"
    done
    printf "  %b M)%b ✍️  Enter stash ref manually\n" "${BOLD}" "${RESET}"
    printf "  %b 0)%b ❌ Cancel\n\n" "${BOLD}" "${RESET}"
  } >&2

  local sel=""
  read -r -p "$(printf '%b' "${BOLD}${YELLOW}${prompt_msg}${RESET} [1-${#stash_list[@]}, M, 0]: ")" sel
  if [[ "$sel" == "0" || -z "$sel" ]]; then
    return 1
  elif [[ "$sel" =~ ^[Mm]$ ]]; then
    read -r -p "Enter stash ref (e.g. stash@{0}): " man_st
    if [[ -n "$man_st" ]]; then
      printf '%s' "$man_st"
      return 0
    else
      return 1
    fi
  elif [[ "$sel" =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= ${#stash_list[@]} )); then
    local entry="${stash_list[$((sel - 1))]}"
    local sref="${entry%%:*}"
    printf '%s' "$sref"
    return 0
  else
    print_line "${YELLOW}Invalid selection.${RESET}" >&2
    return 1
  fi
}

# Select a tag
select_tag() {
  local prompt_msg="${1:-Select a tag}"
  local -a tag_list=()

  while IFS= read -r tg; do
    [[ -n "$tg" ]] && tag_list+=("$tg")
  done < <(git tag -l --sort=-v:refname 2>/dev/null || true)

  if [[ ${#tag_list[@]} -eq 0 ]]; then
    print_line "${YELLOW}No tags found in this repository.${RESET}" >&2
    return 1
  fi

  {
    print_line "\n${CYAN}${BOLD}🏷️ Available Tags:${RESET}"
    for i in "${!tag_list[@]}"; do
      local tg="${tag_list[$i]}"
      local tginfo
      tginfo="$(git log -1 --format='%h - %s (%cr)' "$tg" 2>/dev/null || echo '')"
      printf "  %b%2d)%b 🏷️  %-20s ${DIM}%s${RESET}\n" "${BOLD}" "$((i + 1))" "${RESET}" "$tg" "${tginfo:0:45}"
    done
    printf "  %b M)%b ✍️  Enter tag name manually\n" "${BOLD}" "${RESET}"
    printf "  %b 0)%b ❌ Cancel\n\n" "${BOLD}" "${RESET}"
  } >&2

  local sel=""
  read -r -p "$(printf '%b' "${BOLD}${YELLOW}${prompt_msg}${RESET} [1-${#tag_list[@]}, M, 0]: ")" sel
  if [[ "$sel" == "0" || -z "$sel" ]]; then
    return 1
  elif [[ "$sel" =~ ^[Mm]$ ]]; then
    read -r -p "Enter tag name manually: " man_tg
    if [[ -n "$man_tg" ]]; then
      printf '%s' "$man_tg"
      return 0
    else
      return 1
    fi
  elif [[ "$sel" =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= ${#tag_list[@]} )); then
    printf '%s' "${tag_list[$((sel - 1))]}"
    return 0
  else
    print_line "${YELLOW}Invalid selection.${RESET}" >&2
    return 1
  fi
}

# Select a remote
select_remote() {
  local prompt_msg="${1:-Select a remote repository}"
  local -a rem_list=()

  while IFS= read -r r; do
    [[ -n "$r" ]] && rem_list+=("$r")
  done < <(git remote 2>/dev/null || true)

  if [[ ${#rem_list[@]} -eq 0 ]]; then
    print_line "${YELLOW}No remotes configured.${RESET}" >&2
    return 1
  fi

  {
    print_line "\n${CYAN}${BOLD}🌐 Configured Remotes:${RESET}"
    for i in "${!rem_list[@]}"; do
      local rname="${rem_list[$i]}"
      local rurl
      rurl="$(git remote get-url "$rname" 2>/dev/null || echo '')"
      printf "  %b%2d)%b 🌐 %-12s → %s\n" "${BOLD}" "$((i + 1))" "${RESET}" "$rname" "$rurl"
    done
    printf "  %b M)%b ✍️  Enter remote name manually\n" "${BOLD}" "${RESET}"
    printf "  %b 0)%b ❌ Cancel\n\n" "${BOLD}" "${RESET}"
  } >&2

  local sel=""
  read -r -p "$(printf '%b' "${BOLD}${YELLOW}${prompt_msg}${RESET} [1-${#rem_list[@]}, M, 0]: ")" sel
  if [[ "$sel" == "0" || -z "$sel" ]]; then
    return 1
  elif [[ "$sel" =~ ^[Mm]$ ]]; then
    read -r -p "Enter remote name manually: " man_r
    if [[ -n "$man_r" ]]; then
      printf '%s' "$man_r"
      return 0
    else
      return 1
    fi
  elif [[ "$sel" =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= ${#rem_list[@]} )); then
    printf '%s' "${rem_list[$((sel - 1))]}"
    return 0
  else
    print_line "${YELLOW}Invalid selection.${RESET}" >&2
    return 1
  fi
}

# ------------------------------------------------------------------------------
# Repository State Analysis & Metrics
# ------------------------------------------------------------------------------

refresh_git_metrics() {
  REPO_PATH="$(pwd)"
  PROJECT_NAME="$(basename "$REPO_PATH")"
  GIT_OK=0
  REPO_OK=0
  HAS_COMMITS=0
  CURRENT_BRANCH="unknown"
  UPSTREAM_BRANCH="none"
  REMOTE_NAME="not configured"
  REMOTE_URL="not configured"
  LAST_COMMIT_HASH="none"
  LAST_COMMIT_MSG="No commits yet"
  LAST_COMMIT_DATE="none"
  CURRENT_VERSION="v0.0.0"
  COMMITS_SINCE_TAG=0
  UNCOMMITTED_FILES=0
  STAGED_FILES=0
  UNSTAGED_FILES=0
  UNTRACKED_FILES=0
  CONFLICTED_FILES=0
  FILES_ADDED=0
  FILES_MODIFIED=0
  FILES_DELETED=0
  LINES_ADDED=0
  LINES_REMOVED=0
  MODULES_AFFECTED=0
  AHEAD_COUNT=0
  BEHIND_COUNT=0
  UNPUSHED_COMMITS=0
  REPO_HEALTH=100
  WORKFLOW_STATE="HEALTHY"
  RECOMMENDATION="Repository is healthy. Continue development."

  if ! command -v git >/dev/null 2>&1; then
    WORKFLOW_STATE="GIT_MISSING"
    RECOMMENDATION="Install Git to continue."
    return 1
  fi
  GIT_OK=1

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    WORKFLOW_STATE="NOT_A_REPO"
    RECOMMENDATION="Initialize a repository or navigate to a Git folder."
    return 1
  fi
  REPO_OK=1

  # Branch detection
  local branch
  branch="$(git branch --show-current 2>/dev/null || true)"
  if [[ -n "$branch" ]]; then
    CURRENT_BRANCH="$branch"
  else
    local head_short
    head_short="$(git rev-parse --short HEAD 2>/dev/null || true)"
    if [[ -n "$head_short" ]]; then
      CURRENT_BRANCH="DETACHED (${head_short})"
    else
      CURRENT_BRANCH="HEAD (empty repo)"
    fi
  fi

  # Commit existence check
  if git rev-parse HEAD >/dev/null 2>&1; then
    HAS_COMMITS=1
    LAST_COMMIT_HASH="$(git log -1 --pretty=format:'%h' 2>/dev/null || echo 'none')"
    LAST_COMMIT_MSG="$(git log -1 --pretty=format:'%s' 2>/dev/null || echo 'none')"
    LAST_COMMIT_DATE="$(git log -1 --pretty=format:'%cr' 2>/dev/null || echo 'none')"
  fi

  # Remote detection
  if git remote 2>/dev/null | grep -q .; then
    REMOTE_NAME="$(git remote 2>/dev/null | head -n 1)"
    REMOTE_URL="$(git remote get-url "$REMOTE_NAME" 2>/dev/null || echo 'not configured')"
  fi

  # Upstream & Sync tracking
  local upstream
  upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  if [[ -n "$upstream" ]]; then
    UPSTREAM_BRANCH="$upstream"
    local counts
    counts="$(git rev-list --left-right --count "${upstream}...HEAD" 2>/dev/null || echo "0 0")"
    read -r BEHIND_COUNT AHEAD_COUNT <<< "$counts"
    BEHIND_COUNT="${BEHIND_COUNT:-0}"
    AHEAD_COUNT="${AHEAD_COUNT:-0}"
    UNPUSHED_COMMITS="$AHEAD_COUNT"
  else
    UPSTREAM_BRANCH="none"
    BEHIND_COUNT=0
    if [[ $HAS_COMMITS -eq 1 && "$REMOTE_NAME" != "not configured" ]]; then
      local remote_def
      remote_def="refs/remotes/${REMOTE_NAME}/${CURRENT_BRANCH}"
      if git rev-parse "$remote_def" >/dev/null 2>&1; then
        local counts
        counts="$(git rev-list --left-right --count "${remote_def}...HEAD" 2>/dev/null || echo "0 0")"
        read -r BEHIND_COUNT AHEAD_COUNT <<< "$counts"
        UNPUSHED_COMMITS="${AHEAD_COUNT:-0}"
      else
        UNPUSHED_COMMITS="$(git rev-list --count HEAD 2>/dev/null || echo 0)"
      fi
    else
      UNPUSHED_COMMITS=0
    fi
  fi

  # Changes & Status metrics
  local porcelain
  porcelain="$(git status --porcelain 2>/dev/null || true)"
  if [[ -n "$porcelain" ]]; then
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      local xy="${line:0:2}"
      if [[ "$xy" == "??" ]]; then
        UNTRACKED_FILES=$((UNTRACKED_FILES + 1))
        FILES_ADDED=$((FILES_ADDED + 1))
      elif [[ "$xy" =~ [U] || "$xy" == "AA" || "$xy" == "DD" ]]; then
        CONFLICTED_FILES=$((CONFLICTED_FILES + 1))
      fi

      local x="${line:0:1}"
      local y="${line:1:1}"

      if [[ "$x" != " " && "$x" != "?" ]]; then
        STAGED_FILES=$((STAGED_FILES + 1))
      fi
      if [[ "$y" != " " && "$y" != "?" ]]; then
        UNSTAGED_FILES=$((UNSTAGED_FILES + 1))
      fi

      if [[ "$xy" =~ D ]]; then
        FILES_DELETED=$((FILES_DELETED + 1))
      elif [[ "$xy" =~ A ]]; then
        FILES_ADDED=$((FILES_ADDED + 1))
      elif [[ "$xy" =~ [MR] ]]; then
        FILES_MODIFIED=$((FILES_MODIFIED + 1))
      fi
    done <<< "$porcelain"
    UNCOMMITTED_FILES="$(printf '%s\n' "$porcelain" | sed '/^$/d' | wc -l | tr -d ' ')"
  fi

  # Line additions / removals via fast awk pipeline
  read -r LINES_ADDED LINES_REMOVED < <(
    { git diff --numstat 2>/dev/null; git diff --cached --numstat 2>/dev/null; } | \
    awk '{ if ($1 ~ /^[0-9]+$/) a += $1; if ($2 ~ /^[0-9]+$/) r += $2; } END { print (a?a:0), (r?r:0) }'
  )
  LINES_ADDED="${LINES_ADDED:-0}"
  LINES_REMOVED="${LINES_REMOVED:-0}"

  # Modules / folders affected
  MODULES_AFFECTED="$(git status --porcelain 2>/dev/null | awk '{
    f=$2; sub(/[^\/]+$/, "", f); sub(/\/$/, "", f); if (length(f)>0) mods[f]=1;
  } END { count=0; for (m in mods) count++; print count }')"
  MODULES_AFFECTED="${MODULES_AFFECTED:-0}"

  # Tag and version metrics
  local latest_tag
  latest_tag="$(git describe --tags --abbrev=0 2>/dev/null || true)"
  if [[ -n "$latest_tag" ]]; then
    CURRENT_VERSION="$latest_tag"
    COMMITS_SINCE_TAG="$(git rev-list --count "${latest_tag}..HEAD" 2>/dev/null || echo 0)"
  else
    CURRENT_VERSION="v0.0.0 (no tags)"
    if [[ $HAS_COMMITS -eq 1 ]]; then
      COMMITS_SINCE_TAG="$(git rev-list --count HEAD 2>/dev/null || echo 0)"
    else
      COMMITS_SINCE_TAG=0
    fi
  fi
  COMMITS_SINCE_TAG="${COMMITS_SINCE_TAG:-0}"

  # Compute health score & evaluate workflow state
  calculate_health_score
  evaluate_workflow_state
  return 0
}

calculate_health_score() {
  local score=100

  # Conflicts: heavy penalty
  if (( CONFLICTED_FILES > 0 )); then
    score=$((score - 30))
  fi

  # Behind remote upstream
  if (( BEHIND_COUNT > 0 )); then
    score=$((score - 15))
  fi

  # Uncommitted changes
  if (( UNCOMMITTED_FILES > 0 )); then
    score=$((score - 10))
  fi

  # Many unstaged files
  if (( UNSTAGED_FILES > 5 )); then
    score=$((score - 5))
  fi

  # Unpushed commits
  if (( UNPUSHED_COMMITS > 0 )); then
    score=$((score - 5))
  fi

  # Detached HEAD
  if [[ "$CURRENT_BRANCH" =~ DETACHED ]]; then
    score=$((score - 15))
  fi

  # No remote configured
  if [[ "$REMOTE_NAME" == "not configured" ]]; then
    score=$((score - 5))
  fi

  # Too many commits without a release checkpoint
  if (( COMMITS_SINCE_TAG >= 10 )); then
    score=$((score - 5))
  fi

  # High churn / huge uncommitted lines
  if (( LINES_ADDED > 3000 || LINES_REMOVED > 3000 )); then
    score=$((score - 10))
  fi

  (( score < 0 )) && score=0
  (( score > 100 )) && score=100

  REPO_HEALTH="$score"
}

evaluate_workflow_state() {
  if [[ $GIT_OK -eq 0 ]]; then
    WORKFLOW_STATE="GIT_MISSING"
    RECOMMENDATION="Git is not installed. Please install git."
    return
  fi

  if [[ $REPO_OK -eq 0 ]]; then
    WORKFLOW_STATE="INIT"
    RECOMMENDATION="Initialize a new Git repository in this folder."
    return
  fi

  local git_dir
  git_dir="$(git rev-parse --git-dir 2>/dev/null || echo ".git")"

  if [[ -d "$git_dir/rebase-merge" || -d "$git_dir/rebase-apply" ]]; then
    WORKFLOW_STATE="REBASE_IN_PROGRESS"
    RECOMMENDATION="Git rebase is in progress! Type 'A' or Option 23 to ABORT & GO BACK to your original version safely."
    return
  fi

  if [[ -f "$git_dir/MERGE_HEAD" ]]; then
    WORKFLOW_STATE="MERGE_IN_PROGRESS"
    RECOMMENDATION="Git merge in progress with conflicts! Type 'A' or Option 23 to ABORT & GO BACK safely."
    return
  fi

  if (( CONFLICTED_FILES > 0 )); then
    WORKFLOW_STATE="CONFLICT"
    RECOMMENDATION="Conflicts detected ($CONFLICTED_FILES files)! Resolve them, or abort rebase/merge (Option 23) to go back."
    return
  fi

  if [[ "$CURRENT_BRANCH" =~ DETACHED ]]; then
    WORKFLOW_STATE="DETACHED"
    RECOMMENDATION="You are in detached HEAD state. Create or switch to a branch to keep commits."
    return
  fi

  if [[ $HAS_COMMITS -eq 0 ]]; then
    WORKFLOW_STATE="FIRST_COMMIT"
    RECOMMENDATION="Empty repository. Stage your files and make your first initial commit."
    return
  fi

  if (( UNCOMMITTED_FILES > 0 )); then
    if (( UNCOMMITTED_FILES >= 20 || MODULES_AFFECTED >= 4 || LINES_ADDED >= 3000 )); then
      WORKFLOW_STATE="BRANCH_RECOMMENDED"
      RECOMMENDATION="Large change detected. A dedicated feature branch is recommended."
      return
    fi
    if (( STAGED_FILES > 0 && UNSTAGED_FILES == 0 && UNTRACKED_FILES == 0 )); then
      WORKFLOW_STATE="READY_TO_COMMIT"
      RECOMMENDATION="All changes staged! Ready to create a meaningful commit."
      return
    elif (( STAGED_FILES > 0 )); then
      WORKFLOW_STATE="PARTIALLY_STAGED"
      RECOMMENDATION="Some files staged. Review remaining unstaged files or commit staged work."
      return
    else
      WORKFLOW_STATE="CHANGES_PENDING"
      RECOMMENDATION="Uncommitted changes detected. Review diff and stage files when ready."
      return
    fi
  fi

  if (( BEHIND_COUNT > 0 )); then
    WORKFLOW_STATE="PULL_REQUIRED"
    RECOMMENDATION="Local branch is behind remote by $BEHIND_COUNT commit(s). Pull or rebase."
    return
  fi

  if (( UNPUSHED_COMMITS > 0 )); then
    WORKFLOW_STATE="PUSH_READY"
    RECOMMENDATION="$UNPUSHED_COMMITS commit(s) ready to push. Synchronize with remote."
    return
  fi

  if [[ "$REMOTE_NAME" == "not configured" ]]; then
    WORKFLOW_STATE="NO_REMOTE"
    RECOMMENDATION="Local repo is healthy. Connect to a remote repository (GitHub/GitLab/Bitbucket)."
    return
  fi

  if (( COMMITS_SINCE_TAG >= 6 )); then
    WORKFLOW_STATE="CHECKPOINT"
    RECOMMENDATION="Healthy checkpoint ($COMMITS_SINCE_TAG commits since tag). Consider a release version tag."
    return
  fi

  WORKFLOW_STATE="HEALTHY"
  RECOMMENDATION="Repository is clean and fully synchronized. Ready for development!"
}

next_workflow_action_text() {
  case "$WORKFLOW_STATE" in
    GIT_MISSING)        printf '%s' 'Install Git on system' ;;
    INIT)               printf '%s' 'Initialize Git repository (git init)' ;;
    REBASE_IN_PROGRESS) printf '%s' '⏹️  Abort Rebase to go back (Option 23 or "A")' ;;
    MERGE_IN_PROGRESS)  printf '%s' '⏹️  Abort Merge to go back (Option 23 or "A")' ;;
    CONFLICT)           printf '%s' '🚨 Resolve conflicts or abort rebase/merge (Option 23)' ;;
    DETACHED)           printf '%s' '🌿 Switch to named branch (git switch -c <name>)' ;;
    FIRST_COMMIT)       printf '%s' '📝 Stage files & create initial commit' ;;
    CHANGES_PENDING)    printf '%s' '👀 Review diff and stage changes (git add)' ;;
    PARTIALLY_STAGED)   printf '%s' '📦 Stage remaining files or commit staged files' ;;
    READY_TO_COMMIT)    printf '%s' '✨ Create commit with meaningful message' ;;
    BRANCH_RECOMMENDED) printf '%s' '🌿 Create dedicated branch for large changeset' ;;
    PULL_REQUIRED)      printf '%s' '⬇️  Pull remote changes (git pull --rebase)' ;;
    PUSH_READY)         printf '%s' '⬆️  Push local commits to remote (git push)' ;;
    NO_REMOTE)          printf '%s' '🌐 Configure remote repository URL' ;;
    CHECKPOINT)         printf '%s' '🏷️ Create a new version release tag' ;;
    HEALTHY)            printf '%s' '✅ Continue normal development cycle' ;;
    *)                  printf '%s' 'Continue development workflow' ;;
  esac
}

status_health_badge() {
  local score="$REPO_HEALTH"
  if (( score >= 90 )); then
    printf '%b' "${GREEN}${BOLD}🟢 EXCELLENT (${score}/100)${RESET}"
  elif (( score >= 75 )); then
    printf '%b' "${GREEN}${BOLD}🟢 HEALTHY (${score}/100)${RESET}"
  elif (( score >= 60 )); then
    printf '%b' "${YELLOW}${BOLD}🟡 ATTENTION NEEDED (${score}/100)${RESET}"
  elif (( score >= 40 )); then
    printf '%b' "${YELLOW}${BOLD}🟠 MODERATE RISK (${score}/100)${RESET}"
  else
    printf '%b' "${RED}${BOLD}🔴 CRITICAL (${score}/100)${RESET}"
  fi
}

risk_level_badge() {
  local score="$REPO_HEALTH"
  if (( score >= 85 )); then
    printf '%b' "${GREEN}🟢 Low Risk${RESET}"
  elif (( score >= 65 )); then
    printf '%b' "${YELLOW}🟡 Medium Risk${RESET}"
  elif (( score >= 45 )); then
    printf '%b' "${YELLOW}🟠 High Risk${RESET}"
  else
    printf '%b' "${RED}🔴 Critical Risk${RESET}"
  fi
}

working_tree_badge() {
  if (( CONFLICTED_FILES > 0 )); then
    printf '%b' "${RED}🔴 Conflicted (${CONFLICTED_FILES})${RESET}"
  elif (( UNCOMMITTED_FILES > 0 )); then
    printf '%b' "${YELLOW}🟡 Modified (${UNCOMMITTED_FILES} files)${RESET}"
  else
    printf '%b' "${GREEN}🟢 Clean${RESET}"
  fi
}

render_health_bar() {
  local score="$REPO_HEALTH"
  local total_blocks=25
  local filled=$(( score * total_blocks / 100 ))
  local bar=""
  local color="$GREEN"

  if (( score < 50 )); then
    color="$RED"
  elif (( score < 75 )); then
    color="$YELLOW"
  fi

  for ((i=0; i<total_blocks; i++)); do
    if (( i < filled )); then
      bar+="${color}█${RESET}"
    else
      bar+="${GRAY}░${RESET}"
    fi
  done
  printf '%b' "$bar"
}

render_workflow_pipeline() {
  local m_init="○" m_health="○" m_sync="○" m_stage="○" m_commit="○" m_tag="○" m_push="○"

  if [[ $REPO_OK -eq 1 ]]; then m_init="${GREEN}✓${RESET}"; else m_init="${YELLOW}●${RESET}"; fi
  if (( REPO_HEALTH >= 75 )); then m_health="${GREEN}✓${RESET}"; else m_health="${YELLOW}●${RESET}"; fi
  if (( BEHIND_COUNT == 0 )); then m_sync="${GREEN}✓${RESET}"; else m_sync="${RED}●${RESET}"; fi

  if (( UNCOMMITTED_FILES == 0 )); then
    m_stage="${GREEN}✓${RESET}"
    m_commit="${GREEN}✓${RESET}"
  elif (( STAGED_FILES > 0 && UNSTAGED_FILES == 0 && UNTRACKED_FILES == 0 )); then
    m_stage="${GREEN}✓${RESET}"
    m_commit="${YELLOW}●${RESET}"
  else
    m_stage="${YELLOW}●${RESET}"
    m_commit="○"
  fi

  if (( COMMITS_SINCE_TAG == 0 )); then m_tag="${GREEN}✓${RESET}"; else m_tag="○"; fi
  if (( UNPUSHED_COMMITS == 0 )); then m_push="${GREEN}✓${RESET}"; else m_push="${YELLOW}●${RESET}"; fi

  printf '%b\n' "  ${m_init} INIT → ${m_health} HEALTH → ${m_sync} SYNC → ${m_stage} STAGE → ${m_commit} COMMIT → ${m_tag} TAG → ${m_push} PUSH"
}

# ------------------------------------------------------------------------------
# Dashboard Renderer
# ------------------------------------------------------------------------------

print_field() {
  local label="$1"
  local val="$2"
  printf "  ${BOLD}%-18s${RESET} │ %b\n" "$label" "$val"
}

render_dashboard() {
  refresh_git_metrics

  print_header

  # Repository & Branch Overview
  printf '%b\n' "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  printf '%b\n' "${CYAN}📁 PROJECT & ENVIRONMENT${RESET}"
  printf '%b\n' "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_field "Project Name" "${GREEN}${PROJECT_NAME}${RESET} ${DIM}(${REPO_PATH})${RESET}"
  print_field "Current Branch" "${MAGENTA}${BOLD}${CURRENT_BRANCH}${RESET}  ${DIM}Upstream:${RESET} ${CYAN}${UPSTREAM_BRANCH}${RESET}"
  print_field "Remote" "${CYAN}${REMOTE_NAME}${RESET} → ${BLUE}${REMOTE_URL}${RESET}"
  print_field "Version / Tag" "${YELLOW}${CURRENT_VERSION}${RESET} ${DIM}(${COMMITS_SINCE_TAG} commits since tag)${RESET}"
  if [[ $HAS_COMMITS -eq 1 ]]; then
    print_field "Last Commit" "${CYAN}${LAST_COMMIT_HASH}${RESET} ${WHITE}${LAST_COMMIT_MSG:0:45}${RESET} ${DIM}(${LAST_COMMIT_DATE})${RESET}"
  else
    print_field "Last Commit" "${YELLOW}No commits made yet${RESET}"
  fi

  # Health & Next Step
  printf '\n'
  printf '%b\n' "${CYAN}🏥 HEALTH & WORKFLOW STATUS${RESET}"
  printf '%b\n' "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_field "Health Score" "$(render_health_bar)  $(status_health_badge)"
  printf "  ${BOLD}%-18s${RESET} │ %b  │  ${BOLD}%-12s${RESET} │ %b\n" "Working Tree" "$(working_tree_badge)" "Risk Level" "$(risk_level_badge)"
  
  local sync_status=""
  if (( BEHIND_COUNT == 0 && UNPUSHED_COMMITS == 0 )); then
    sync_status="${GREEN}✅ Fully in sync with remote${RESET}"
  else
    sync_status="${YELLOW}⬆️  ${UNPUSHED_COMMITS} unpushed${RESET}  ${RED}⬇️  ${BEHIND_COUNT} behind${RESET}"
  fi
  print_field "Remote Sync" "$sync_status"
  print_field "Next Action" "${YELLOW}${BOLD}💡 $(next_workflow_action_text)${RESET}"
  print_field "Advisory" "${BLUE}📌 ${RECOMMENDATION}${RESET}"

  # Changes Breakdown
  printf '\n'
  printf '%b\n' "${CYAN}📊 CHANGES SNAPSHOT${RESET}"
  printf '%b\n' "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  printf '  Files Changed: %b  (🟩 Staged: %b │ 🟨 Unstaged: %b │ ❓ Untracked: %b)\n' \
    "${BOLD}${UNCOMMITTED_FILES}${RESET}" "${GREEN}${STAGED_FILES}${RESET}" "${YELLOW}${UNSTAGED_FILES}${RESET}" "${GRAY}${UNTRACKED_FILES}${RESET}"
  printf '  Activity Breakdown: %b Added │ %b Modified │ %b Deleted │ %b Modules Affected\n' \
    "${GREEN}${FILES_ADDED}${RESET}" "${YELLOW}${FILES_MODIFIED}${RESET}" "${RED}${FILES_DELETED}${RESET}" "${CYAN}${MODULES_AFFECTED}${RESET}"
  printf '  Code Volume Churn : %b Lines (+)  │  %b Lines (-)\n' \
    "${GREEN}+${LINES_ADDED}${RESET}" "${RED}-${LINES_REMOVED}${RESET}"

  # Pipeline Breadcrumb
  printf '\n'
  printf '%b\n' "${CYAN}🔄 WORKFLOW PIPELINE${RESET}"
  printf '%b\n' "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  render_workflow_pipeline

  # Active Rebase / Merge Warning Alert
  local git_dir
  git_dir="$(git rev-parse --git-dir 2>/dev/null || echo ".git")"
  if [[ -d "$git_dir/rebase-merge" || -d "$git_dir/rebase-apply" ]]; then
    printf '\n%b\n' "${RED}${BOLD}╔══════════════════════════════════════════════════════════════════════════════════════╗${RESET}"
    printf '%b\n' "${RED}${BOLD}║  🚨 ACTIVE REBASE IN PROGRESS!                                                      ║${RESET}"
    printf '%b\n' "${YELLOW}${BOLD}║  To cancel rebase & GO BACK to your previous version: Select Option 23 or type 'A'   ║${RESET}"
    printf '%b\n' "${RED}${BOLD}╚══════════════════════════════════════════════════════════════════════════════════════╝${RESET}"
  elif [[ -f "$git_dir/MERGE_HEAD" ]]; then
    printf '\n%b\n' "${RED}${BOLD}╔══════════════════════════════════════════════════════════════════════════════════════╗${RESET}"
    printf '%b\n' "${RED}${BOLD}║  🚨 ACTIVE MERGE CONFLICT DETECTED!                                                  ║${RESET}"
    printf '%b\n' "${YELLOW}${BOLD}║  To cancel merge & GO BACK to your previous version: Select Option 23 or type 'A'    ║${RESET}"
    printf '%b\n' "${RED}${BOLD}╚══════════════════════════════════════════════════════════════════════════════════════╝${RESET}"
  fi
  printf '\n'
}

# ------------------------------------------------------------------------------
# Feature Functions
# ------------------------------------------------------------------------------

# 1. Smart Workflow Guide (Auto-Execute Recommended Next Step)
smart_workflow_guide() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🚀 SMART WORKFLOW GUIDE — AUTOMATED NEXT STEP${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "Current State  : ${BOLD}${WORKFLOW_STATE}${RESET}"
  print_line "Health Status  : $(status_health_badge)"
  print_line "Recommended    : ${YELLOW}${BOLD}$(next_workflow_action_text)${RESET}"
  print_line "Details        : ${RECOMMENDATION}"
  printf '\n'

  case "$WORKFLOW_STATE" in
    INIT)
      ensure_repo
      ;;
    REBASE_IN_PROGRESS)
      print_line "${YELLOW}Git rebase is currently in progress.${RESET}"
      print_line "Options:"
      print_line "  1) ⏹️  ABORT REBASE & GO BACK to your original version (git rebase --abort)"
      print_line "  2) ▶️  Continue rebase after conflict resolution (git rebase --continue)"
      print_line "  3) 🚨 View conflicted files"
      read -r -p "Select action [1-3]: " rb_act
      case "$rb_act" in
        1) abort_rebase_or_merge "rebase" ;;
        2) git rebase --continue ;;
        3) git diff --name-only --diff-filter=U ;;
        *) print_line "Action cancelled." ;;
      esac
      ;;
    MERGE_IN_PROGRESS)
      print_line "${YELLOW}Git merge is currently in progress.${RESET}"
      if action_prompt "Would you like to ABORT the merge and go back to original state?" "y"; then
        abort_rebase_or_merge "merge"
      fi
      ;;
    CONFLICT)
      print_line "${RED}Conflicts detected in:${RESET}"
      git diff --name-only --diff-filter=U
      print_line "\n${YELLOW}Please inspect the conflicted files and resolve marks (<<<<<<< ======= >>>>>>>).${RESET}"
      local g_dir
      g_dir="$(git rev-parse --git-dir 2>/dev/null || echo ".git")"
      if [[ -d "$g_dir/rebase-merge" || -d "$g_dir/rebase-apply" ]]; then
        if action_prompt "Rebase is in progress. Abort rebase and GO BACK to your original version?" "y"; then
          abort_rebase_or_merge "rebase"
        fi
      elif action_prompt "Would you like to abort the merge and go back?" "y"; then
        abort_rebase_or_merge "merge"
      fi
      ;;
    DETACHED)
      print_line "${YELLOW}You are currently detached from any branch.${RESET}"
      read -r -p "Enter a new branch name to save your work: " new_br
      if [[ -n "$new_br" ]]; then
        git switch -c "$new_br" && print_line "${GREEN}Switched to new branch: $new_br${RESET}"
      fi
      ;;
    FIRST_COMMIT)
      print_line "${CYAN}Preparing initial commit for empty repository...${RESET}"
      git status --short
      if action_prompt "Stage all files and create initial commit?" "y"; then
        git add .
        read -r -p "Enter commit message [default: feat(initial): initial project setup]: " cmsg
        cmsg="${cmsg:-feat(initial): initial project setup}"
        git commit -m "$cmsg"
        print_line "${GREEN}✅ Initial commit created!${RESET}"
      fi
      ;;
    CHANGES_PENDING|PARTIALLY_STAGED)
      print_line "${CYAN}Reviewing changed files...${RESET}"
      git status --short
      printf '\n'
      if action_prompt "Would you like to view diff summary?" "y"; then
        git diff --stat
      fi
      printf '\n'
      if action_prompt "Stage all changed files now?" "y"; then
        git add .
        print_line "${GREEN}All changes staged successfully.${RESET}"
        refresh_git_metrics
        if action_prompt "Proceed to commit now?" "y"; then
          smart_commit
        fi
      fi
      ;;
    READY_TO_COMMIT)
      smart_commit
      ;;
    BRANCH_RECOMMENDED)
      show_branch_advice
      ;;
    PULL_REQUIRED)
      print_line "${YELLOW}Your local branch is behind remote by ${BEHIND_COUNT} commit(s).${RESET}"
      if action_prompt "Pull latest changes with rebase now?" "y"; then
        if git pull --rebase origin "$CURRENT_BRANCH"; then
          print_line "${GREEN}✅ Successfully pulled and rebased.${RESET}"
        else
          print_line "${RED}❌ Pull encountered issues. Check for conflicts.${RESET}"
        fi
      fi
      ;;
    PUSH_READY)
      print_line "${CYAN}You have ${UNPUSHED_COMMITS} commit(s) ready to push.${RESET}"
      if action_prompt "Push commits to remote now?" "y"; then
        smart_git_push "$REMOTE_NAME" "$CURRENT_BRANCH"
      fi
      ;;
    NO_REMOTE)
      configure_remote_access
      ;;
    CHECKPOINT)
      show_version_recommendation
      ;;
    HEALTHY)
      print_line "${GREEN}✅ Repository is completely clean and up to date!${RESET}"
      print_line "No urgent action required. You can start developing new features."
      ;;
    *)
      print_line "${BLUE}Repository is ready. Use the menu options for specific operations.${RESET}"
      ;;
  esac
}

# 2. Detailed Repository Status
show_detailed_status() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}📋 DETAILED REPOSITORY STATUS${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}Repository Path :${RESET} $REPO_PATH"
  print_line "${BOLD}Branch          :${RESET} $CURRENT_BRANCH"
  print_line "${BOLD}Tracking        :${RESET} $UPSTREAM_BRANCH"
  print_line "${BOLD}Remote URL      :${RESET} $REMOTE_URL"
  print_line "${BOLD}Commit Hash     :${RESET} $LAST_COMMIT_HASH"
  print_line "${BOLD}Commit Subject  :${RESET} $LAST_COMMIT_MSG"
  printf '\n'
  print_line "${CYAN}── Git Status Output ────────────────────────────────────────────────────────${RESET}"
  git status
  printf '\n'
  if [[ $UNCOMMITTED_FILES -gt 0 ]]; then
    print_line "${CYAN}── Stat Summary ─────────────────────────────────────────────────────────────${RESET}"
    git diff --stat 2>/dev/null || true
    git diff --cached --stat 2>/dev/null || true
  fi
}

# 3. Health & Diagnostics Report
show_health_report() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🏥 REPOSITORY HEALTH & DIAGNOSTIC REPORT${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  printf '  Overall Health Score : %s  %b\n' "$(render_health_bar)" "$(status_health_badge)"
  printf '  Risk Assessment      : %b\n' "$(risk_level_badge)"
  printf '  Workflow State       : %b\n' "${CYAN}${WORKFLOW_STATE}${RESET}"
  printf '\n'
  print_line "${BOLD}Diagnostic Checks:${RESET}"

  # Diagnostic checks list
  if (( CONFLICTED_FILES == 0 )); then
    print_line "  ${GREEN}✓${RESET} No merge conflicts detected"
  else
    print_line "  ${RED}✗ [CRITICAL]${RESET} $CONFLICTED_FILES conflicted file(s) require resolution"
  fi

  if [[ ! "$CURRENT_BRANCH" =~ DETACHED ]]; then
    print_line "  ${GREEN}✓${RESET} Attached to standard branch (${CURRENT_BRANCH})"
  else
    print_line "  ${RED}✗ [WARNING]${RESET} HEAD is detached! Commits may be lost without a branch"
  fi

  if (( BEHIND_COUNT == 0 )); then
    print_line "  ${GREEN}✓${RESET} Local branch is not behind remote"
  else
    print_line "  ${YELLOW}✗ [BEHIND]${RESET} Local branch is behind remote by $BEHIND_COUNT commit(s)"
  fi

  if (( UNPUSHED_COMMITS == 0 )); then
    print_line "  ${GREEN}✓${RESET} No unpushed commits pending"
  else
    print_line "  ${YELLOW}✗ [UNPUSHED]${RESET} $UNPUSHED_COMMITS commit(s) pending push to remote"
  fi

  if (( UNCOMMITTED_FILES == 0 )); then
    print_line "  ${GREEN}✓${RESET} Working directory is clean"
  else
    print_line "  ${YELLOW}✗ [MODIFIED]${RESET} $UNCOMMITTED_FILES file(s) modified ($STAGED_FILES staged, $UNSTAGED_FILES unstaged, $UNTRACKED_FILES untracked)"
  fi

  if [[ "$REMOTE_NAME" != "not configured" ]]; then
    print_line "  ${GREEN}✓${RESET} Remote repository configured (${REMOTE_NAME})"
  else
    print_line "  ${GRAY}○ [NOTICE]${RESET} No remote repository linked"
  fi

  if (( COMMITS_SINCE_TAG < 10 )); then
    print_line "  ${GREEN}✓${RESET} Tagging cadence is healthy ($COMMITS_SINCE_TAG commits since last tag)"
  else
    print_line "  ${YELLOW}✗ [CHECKPOINT]${RESET} $COMMITS_SINCE_TAG commits since last tag. Version release recommended"
  fi

  printf '\n'
  print_line "${BOLD}Actionable Recommendations:${RESET}"
  print_line "  👉 ${YELLOW}${RECOMMENDATION}${RESET}"
}

# 4. View Changes (Diff Inspector)
inspect_changes_diff() {
  refresh_git_metrics
  while true; do
    print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    print_line "${BOLD}📝 CHANGES & DIFF INSPECTOR${RESET}"
    print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    cat <<'EOF'
  1) View Unstaged Changes (git diff)
  2) View Staged Changes (git diff --cached)
  3) View Diff Summary Statistics (git diff --stat)
  4) View Last Commit Diff (git show HEAD)
  5) View Specific File Diff
  0) Back to Main Menu
EOF
    read -r -p "${BOLD}Select diff option [0-5]:${RESET} " dchoice
    case "$dchoice" in
      1)
        printf '\n%b\n' "${CYAN}── Unstaged Changes ───────────────────────────────────────────────${RESET}"
        git diff || true
        ;;
      2)
        printf '\n%b\n' "${CYAN}── Staged Changes ─────────────────────────────────────────────────${RESET}"
        git diff --cached || true
        ;;
      3)
        printf '\n%b\n' "${CYAN}── Diff Stat Summary ──────────────────────────────────────────────${RESET}"
        print_line "${YELLOW}Unstaged:${RESET}"
        git diff --stat || true
        print_line "${GREEN}Staged:${RESET}"
        git diff --cached --stat || true
        ;;
      4)
        printf '\n%b\n' "${CYAN}── Last Commit Diff ───────────────────────────────────────────────${RESET}"
        git show --stat HEAD || true
        ;;
      5)
        local target_f
        target_f="$(select_file "Select file to inspect diff" "all")"
        if [[ -n "$target_f" && "$target_f" != "ALL" ]]; then
          git diff -- "$target_f" || true
          git diff --cached -- "$target_f" || true
        fi
        ;;
      0) break ;;
      *) print_line "${YELLOW}Invalid option.${RESET}" ;;
    esac
    press_any_key
  done
}

# 5. Staging Actions (git add)
stage_changes_menu() {
  refresh_git_metrics
  while true; do
    print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    print_line "${BOLD}➕ STAGE CHANGES (git add)${RESET}"
    print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    cat <<'EOF'
  1) Stage All Changes (git add .)
  2) Interactive Staging / Patch Mode (git add -p)
  3) Stage Specific File (Choose from list or manual)
  4) Stage Only Tracked Modified/Deleted Files (git add -u)
  0) Back to Main Menu
EOF
    read -r -p "${BOLD}Select staging option [0-4]:${RESET} " schoice
    case "$schoice" in
      1)
        if git add .; then
          print_line "${GREEN}✅ All modified and untracked files staged.${RESET}"
        else
          print_line "${RED}❌ Failed to stage changes.${RESET}"
        fi
        break
        ;;
      2)
        git add -p
        break
        ;;
      3)
        local sf
        sf="$(select_file "Select file to STAGE" "all")"
        if [[ "$sf" == "ALL" ]]; then
          git add . && print_line "${GREEN}✅ Staged all files.${RESET}"
        elif [[ -n "$sf" ]]; then
          if git add "$sf"; then
            print_line "${GREEN}✅ Staged: $sf${RESET}"
          else
            print_line "${RED}❌ Failed to stage $sf${RESET}"
          fi
        fi
        break
        ;;
      4)
        if git add -u; then
          print_line "${GREEN}✅ Staged all tracked modifications and deletions.${RESET}"
        else
          print_line "${RED}❌ Failed to stage.${RESET}"
        fi
        break
        ;;
      0) break ;;
      *) print_line "${YELLOW}Invalid option.${RESET}" ;;
    esac
  done
}

# 6. Unstage Changes (git restore --staged / reset)
unstage_changes_menu() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}➖ UNSTAGE CHANGES${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  cat <<'EOF'
  1) Unstage All Files (git restore --staged .)
  2) Unstage Specific File (Choose from list or manual)
  0) Cancel
EOF
  read -r -p "${BOLD}Select unstage option [0-2]:${RESET} " uchoice
  case "$uchoice" in
    1)
      if git restore --staged . 2>/dev/null || git reset HEAD; then
        print_line "${GREEN}✅ All files unstaged.${RESET}"
      else
        print_line "${RED}❌ Failed to unstage files.${RESET}"
      fi
      ;;
    2)
      local uf
      uf="$(select_file "Select file to UNSTAGE" "staged")"
      if [[ "$uf" == "ALL" ]]; then
        git restore --staged . 2>/dev/null || git reset HEAD
        print_line "${GREEN}✅ All files unstaged.${RESET}"
      elif [[ -n "$uf" ]]; then
        if git restore --staged -- "$uf" 2>/dev/null || git reset HEAD -- "$uf"; then
          print_line "${GREEN}✅ Unstaged: $uf${RESET}"
        else
          print_line "${RED}❌ Failed to unstage $uf${RESET}"
        fi
      fi
      ;;
    0) ;;
    *) print_line "${YELLOW}Invalid option.${RESET}" ;;
  esac
}

# 7. Discard / Restore Changes (Safety Confirmations)
discard_restore_menu() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🧹 DISCARD / RESTORE LOCAL MODIFICATIONS${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${YELLOW}⚠️  Caution: Discarding changes cannot be easily undone!${RESET}"
  cat <<'EOF'
  1) Discard Unstaged Changes in Tracked Files (git restore .)
  2) Discard Changes in a Specific File (Choose from list or manual)
  3) Clean Untracked Files and Folders (git clean -fd)
  4) Discard ALL Changes (Both Staged and Unstaged - Reset to HEAD)
  0) Cancel
EOF
  read -r -p "${BOLD}Select discard option [0-4]:${RESET} " dchoice
  case "$dchoice" in
    1)
      if action_prompt "Discard all unstaged tracked file modifications?" "n"; then
        git restore . 2>/dev/null || git checkout -- .
        print_line "${GREEN}✅ Unstaged changes discarded.${RESET}"
      fi
      ;;
    2)
      local rf
      rf="$(select_file "Select file to RESTORE / DISCARD changes" "unstaged")"
      if [[ -n "$rf" && "$rf" != "ALL" ]]; then
        if action_prompt "Discard changes in '$rf'?" "n"; then
          git restore -- "$rf" 2>/dev/null || git checkout -- "$rf"
          print_line "${GREEN}✅ Restored file: $rf${RESET}"
        fi
      fi
      ;;
    3)
      print_line "${CYAN}Preview of untracked files that would be removed:${RESET}"
      git clean -nd
      if action_prompt "Permanently remove all untracked files and folders above?" "n"; then
        git clean -fd
        print_line "${GREEN}✅ Untracked files cleaned.${RESET}"
      fi
      ;;
    4)
      if action_prompt "DISCARD ALL CHANGES (staged + unstaged) and return to HEAD?" "n"; then
        git restore --staged --worktree . 2>/dev/null || { git reset --hard HEAD; }
        print_line "${GREEN}✅ Working directory reset to HEAD.${RESET}"
      fi
      ;;
    0) ;;
    *) print_line "${YELLOW}Invalid option.${RESET}" ;;
  esac
}

# 8. Smart Commit (Auto Semantic Message with Icons)
suggest_commit_message() {
  if (( CONFLICTED_FILES > 0 )); then
    printf '%s' '🚨 fix(merge): resolve merge conflicts'
    return
  fi

  local changed_files
  changed_files="$(git diff --cached --name-only 2>/dev/null)"
  if [[ -z "$changed_files" ]]; then
    changed_files="$(git status --porcelain 2>/dev/null | awk '{print $2}')"
  fi

  local first_file="" primary_ext="" primary_dir=""
  first_file="$(echo "$changed_files" | head -n 1)"

  if [[ -n "$first_file" ]]; then
    primary_ext="${first_file##*.}"
    primary_dir="$(dirname "$first_file")"
    [[ "$primary_dir" == "." ]] && primary_dir=""
  fi

  local scope="core"
  if [[ -n "$primary_dir" ]]; then
    scope="$(basename "$primary_dir")"
  elif [[ -n "$first_file" ]]; then
    scope="$(basename "$first_file" ."$primary_ext")"
  fi
  scope="$(echo "$scope" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_-')"
  [[ -z "$scope" ]] && scope="core"

  if (( FILES_DELETED > 0 && FILES_ADDED == 0 && FILES_MODIFIED == 0 )); then
    printf '🧹 refactor(%s): remove obsolete files' "$scope"
    return
  fi

  if echo "$changed_files" | grep -Eq '\.(md|txt|rst|doc|pdf|docx|markdown)$|^docs/'; then
    printf '📚 docs(%s): update documentation and guides' "$scope"
    return
  fi

  if echo "$changed_files" | grep -Eq '(package\.json|Cargo\.toml|go\.mod|pom\.xml|requirements\.txt|\.gitignore|Dockerfile|Makefile|CMakeLists\.txt|\.yml|\.yaml|\.json|\.env)'; then
    printf '🔧 chore(%s): update project configuration and dependencies' "$scope"
    return
  fi

  if echo "$changed_files" | grep -Eq '(test|spec|\.test\.|\_test\.|test_|\/tests\/)'; then
    printf '🧪 test(%s): update tests and specifications' "$scope"
    return
  fi

  if echo "$changed_files" | grep -Eq '\.(sh|bat|ps1|bash)$'; then
    local script_name="scripts"
    [[ -n "$first_file" ]] && script_name="$(basename "$first_file")"
    printf '⚙️ feat(scripts): update %s' "$script_name"
    return
  fi

  if (( MODULES_AFFECTED >= 3 || LINES_ADDED >= 1500 )); then
    printf '♻️ refactor(%s): restructure modules and improve code quality' "$scope"
    return
  fi

  if (( FILES_ADDED > 0 )); then
    if [[ -n "$first_file" ]]; then
      printf '✨ feat(%s): add %s' "$scope" "$(basename "$first_file")"
    else
      printf '✨ feat(%s): implement new project features' "$scope"
    fi
    return
  fi

  if [[ -n "$first_file" ]]; then
    printf '🐛 fix(%s): update %s' "$scope" "$(basename "$first_file")"
  else
    printf '🐛 fix(%s): update project files and fix issues' "$scope"
  fi
}

smart_commit() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}✨ SMART COMMIT (AUTO-GENERATED SEMANTIC MESSAGE WITH ICONS)${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  if (( UNCOMMITTED_FILES == 0 )); then
    print_line "${GREEN}Working directory is already clean. Nothing to commit.${RESET}"
    return 0
  fi

  if (( STAGED_FILES == 0 )); then
    print_line "${YELLOW}No changes are currently staged.${RESET}"
    git status --short
    if action_prompt "Stage all changes before committing?" "y"; then
      git add .
      refresh_git_metrics
    else
      print_line "${BLUE}Commit cancelled. Please stage files first.${RESET}"
      return 1
    fi
  fi

  local first_file="$(git diff --cached --name-only 2>/dev/null | head -n 1)"
  [[ -z "$first_file" ]] && first_file="$(git status --porcelain 2>/dev/null | awk '{print $2}' | head -n 1)"
  local fname="$(basename "${first_file:-files}")"
  local fbase="${fname%.*}"
  [[ -z "$fbase" ]] && fbase="project"

  local s1 s2 s3 s4 s5
  s1="$(suggest_commit_message)"
  s2="🐛 fix(${fbase}): update ${fname} and improve stability"
  s3="✨ feat(${fbase}): add new features to ${fname}"
  s4="♻️ refactor(${fbase}): clean up implementation and workflow"
  s5="📚 docs(${fbase}): update documentation and usage notes"

  print_line "Detected Changes : ${UNCOMMITTED_FILES} files (${STAGED_FILES} staged)\n"
  print_line "${CYAN}${BOLD}💡 Recommended Commit Messages (with Semantic Icons):${RESET}"
  printf "  %b1)%b %s\n" "${BOLD}" "${RESET}" "$s1"
  printf "  %b2)%b %s\n" "${BOLD}" "${RESET}" "$s2"
  printf "  %b3)%b %s\n" "${BOLD}" "${RESET}" "$s3"
  printf "  %b4)%b %s\n" "${BOLD}" "${RESET}" "$s4"
  printf "  %b5)%b %s\n" "${BOLD}" "${RESET}" "$s5"
  printf "  %bM)%b ✍️  Enter custom commit message\n" "${BOLD}" "${RESET}"
  printf "  %b0)%b ❌ Cancel commit\n\n" "${BOLD}" "${RESET}"

  local choice=""
  read -r -p "$(printf '%b' "${BOLD}${YELLOW}Select commit option [1-5, M, 0]:${RESET} ")" choice || choice="1"
  choice="${choice:-1}"

  local final_msg=""
  case "$choice" in
    1) final_msg="$s1" ;;
    2) final_msg="$s2" ;;
    3) final_msg="$s3" ;;
    4) final_msg="$s4" ;;
    5) final_msg="$s5" ;;
    [Mm]|custom)
      read -r -p "Enter your custom commit message: " custom_input
      if [[ -z "$custom_input" ]]; then
        print_line "${YELLOW}Empty message entered. Commit aborted.${RESET}"
        return 1
      fi
      final_msg="$custom_input"
      ;;
    0)
      print_line "${BLUE}Commit cancelled by user.${RESET}"
      return 0
      ;;
    *)
      final_msg="$s1"
      ;;
  esac

  print_line "Creating commit: ${YELLOW}${BOLD}${final_msg}${RESET}"
  if git commit -m "$final_msg"; then
    print_line "${GREEN}✅ Commit created successfully!${RESET}"
    refresh_git_metrics
  else
    print_line "${RED}❌ Commit failed.${RESET}"
    return 1
  fi
}

# 9. Custom Commit
custom_commit() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}📝 CUSTOM COMMIT${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  if (( UNCOMMITTED_FILES == 0 )); then
    print_line "${GREEN}Working directory is clean. Nothing to commit.${RESET}"
    return 0
  fi

  if (( STAGED_FILES == 0 )); then
    print_line "${YELLOW}No changes are currently staged.${RESET}"
    if action_prompt "Stage all changes now (git add .)?" "y"; then
      git add .
    else
      print_line "${BLUE}Commit cancelled.${RESET}"
      return 1
    fi
  fi

  read -r -p "Enter commit message: " user_msg
  if [[ -z "$user_msg" ]]; then
    print_line "${YELLOW}Commit message cannot be empty.${RESET}"
    return 1
  fi

  if git commit -m "$user_msg"; then
    print_line "${GREEN}✅ Commit created successfully!${RESET}"
  else
    print_line "${RED}❌ Commit failed.${RESET}"
  fi
}

# 10. Conventional Commit Builder
conventional_commit_builder() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🏗️  CONVENTIONAL COMMIT BUILDER (WITH ICONS)${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  if (( UNCOMMITTED_FILES == 0 )); then
    print_line "${GREEN}Working directory is clean. Nothing to commit.${RESET}"
    return 0
  fi

  if (( STAGED_FILES == 0 )); then
    if action_prompt "No files staged. Stage all changes now?" "y"; then
      git add .
    else
      return 1
    fi
  fi

  print_line "Select conventional commit type:"
  cat <<'EOF'
  1) ✨ feat     - A new feature or capability
  2) 🐛 fix      - A bug fix or correction
  3) 📚 docs     - Documentation changes only
  4) 🎨 style    - Formatting, visual styles, no code behavior change
  5) ♻️  refactor - Code refactoring without new feature or bug fix
  6) 🚀 perf     - Performance optimization
  7) 🧪 test     - Adding or correcting tests
  8) 🧹 chore    - Maintenance, build tasks, configurations
EOF
  read -r -p "${BOLD}Choose type [1-8]:${RESET} " ctype_choice
  local ctype="✨ feat"
  case "$ctype_choice" in
    1) ctype="✨ feat" ;;
    2) ctype="🐛 fix" ;;
    3) ctype="📚 docs" ;;
    4) ctype="🎨 style" ;;
    5) ctype="♻️ refactor" ;;
    6) ctype="🚀 perf" ;;
    7) ctype="🧪 test" ;;
    8) ctype="🧹 chore" ;;
    *) ctype="✨ feat" ;;
  esac

  read -r -p "Enter optional scope (e.g., ui, api, core) [leave empty if none]: " cscope
  read -r -p "Enter short, imperative description: " cdesc

  if [[ -z "$cdesc" ]]; then
    print_line "${YELLOW}Description is required. Aborted.${RESET}"
    return 1
  fi

  local full_msg=""
  if [[ -n "$cscope" ]]; then
    full_msg="${ctype}(${cscope}): ${cdesc}"
  else
    full_msg="${ctype}: ${cdesc}"
  fi

  print_line "\nCommit Header: ${YELLOW}${BOLD}${full_msg}${RESET}"
  read -r -p "Optional longer body message [optional, press Enter to skip]: " cbody

  if [[ -n "$cbody" ]]; then
    git commit -m "$full_msg" -m "$cbody"
  else
    git commit -m "$full_msg"
  fi
  print_line "${GREEN}✅ Conventional commit created!${RESET}"
}

# 11. Amend Commit
amend_commit_menu() {
  refresh_git_metrics
  if [[ $HAS_COMMITS -eq 0 ]]; then
    print_line "${YELLOW}No commits exist to amend.${RESET}"
    return 1
  fi

  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🔄 AMEND LAST COMMIT${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "Last commit: ${YELLOW}${LAST_COMMIT_HASH} ${LAST_COMMIT_MSG}${RESET}"
  printf '\n'
  cat <<'EOF'
  1) Change commit message only
  2) Add currently staged changes to last commit (keep message)
  3) Add staged changes AND update commit message
  0) Cancel
EOF
  read -r -p "${BOLD}Select amend option [0-3]:${RESET} " achoice
  case "$achoice" in
    1)
      read -r -p "Enter new commit message: " nmsg
      if [[ -n "$nmsg" ]]; then
        git commit --amend -m "$nmsg" && print_line "${GREEN}✅ Last commit message amended.${RESET}"
      fi
      ;;
    2)
      git commit --amend --no-edit && print_line "${GREEN}✅ Changes folded into last commit.${RESET}"
      ;;
    3)
      read -r -p "Enter new commit message: " nmsg
      if [[ -n "$nmsg" ]]; then
        git commit --amend -m "$nmsg" && print_line "${GREEN}✅ Commit amended with new message and files.${RESET}"
      fi
      ;;
    0) ;;
    *) print_line "${YELLOW}Invalid option.${RESET}" ;;
  esac
}

# Helper function for smart push execution with automatic error recovery
smart_git_push() {
  local target_remote="${1:-$REMOTE_NAME}"
  local target_branch="${2:-$CURRENT_BRANCH}"
  
  if [[ "$target_remote" == "not configured" ]]; then
    print_line "${RED}❌ No remote repository configured.${RESET}"
    return 1
  fi

  local upstream_short=""
  if [[ "$UPSTREAM_BRANCH" != "none" ]]; then
    upstream_short="${UPSTREAM_BRANCH#*/}"
  fi

  if [[ "$UPSTREAM_BRANCH" == "none" ]]; then
    print_line "${YELLOW}No upstream branch set. Executing 'git push -u $target_remote $target_branch'...${RESET}"
    git push -u "$target_remote" "$target_branch"
    return $?
  fi

  # If upstream short name matches target_branch, try standard git push first
  if [[ "$upstream_short" == "$target_branch" ]]; then
    if git push; then
      print_line "${GREEN}✅ Successfully pushed to remote.${RESET}"
      return 0
    fi
  fi

  # Upstream name mismatch or standard git push failed
  print_line "${YELLOW}⚠️ Upstream branch name ('$upstream_short') does not match local branch ('$target_branch') or push failed.${RESET}"
  print_line "${CYAN}Choose how you would like to push '${target_branch}' to remote '${target_remote}':${RESET}"
  cat <<EOF
  1) 🎯 Push local HEAD to branch of same name on remote (git push $target_remote HEAD)
  2) 🔗 Push & Set Upstream tracking to origin/$target_branch (git push -u $target_remote $target_branch)
  3) ⬆️ Push local HEAD to tracked upstream branch '$upstream_short' (git push $target_remote HEAD:$upstream_short)
  0) Cancel
EOF
  read -r -p "${BOLD}Select push resolution option [0-3]:${RESET} " spchoice
  case "$spchoice" in
    1) git push "$target_remote" HEAD ;;
    2) git push -u "$target_remote" "$target_branch" ;;
    3)
      if [[ -n "$upstream_short" ]]; then
        git push "$target_remote" "HEAD:$upstream_short"
      else
        git push "$target_remote" HEAD
      fi
      ;;
    0) return 1 ;;
    *) print_line "${YELLOW}Invalid choice.${RESET}"; return 1 ;;
  esac
}

# 12. Push Changes
push_changes_menu() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}⬆️  PUSH CHANGES TO REMOTE${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  if [[ "$REMOTE_NAME" == "not configured" ]]; then
    print_line "${RED}❌ No remote repository configured.${RESET}"
    if action_prompt "Configure remote access now?" "y"; then
      configure_remote_access
    fi
    return 1
  fi

  cat <<'EOF'
  1) 🚀 Standard / Smart Push (Auto-detect & handle upstream mismatch)
  2) 🔗 Push & Set Upstream (git push -u origin <current_branch>)
  3) 🎯 Push Local HEAD to Remote Branch of Same Name (git push origin HEAD)
  4) ⬆️  Push Local HEAD to Tracked Upstream Branch (git push origin HEAD:<upstream>)
  5) 🏷️  Push All Tags (git push --tags)
  6) 🌿 Push Specific Branch to Remote (Select from list or manual)
  7) ⚡ Safe Force Push (git push --force-with-lease)
  0) Cancel
EOF
  read -r -p "${BOLD}Select push option [0-7]:${RESET} " pchoice
  case "$pchoice" in
    1)
      smart_git_push "$REMOTE_NAME" "$CURRENT_BRANCH"
      ;;
    2)
      git push -u "$REMOTE_NAME" "$CURRENT_BRANCH"
      ;;
    3)
      git push "$REMOTE_NAME" HEAD
      ;;
    4)
      if [[ "$UPSTREAM_BRANCH" != "none" ]]; then
        local up_short="${UPSTREAM_BRANCH#*/}"
        git push "$REMOTE_NAME" "HEAD:$up_short"
      else
        print_line "${YELLOW}No upstream branch set. Using 'git push -u $REMOTE_NAME $CURRENT_BRANCH'...${RESET}"
        git push -u "$REMOTE_NAME" "$CURRENT_BRANCH"
      fi
      ;;
    5)
      git push "$REMOTE_NAME" --tags
      ;;
    6)
      local btopush
      btopush="$(select_branch "Select branch to push to remote" 0)"
      if [[ -n "$btopush" ]]; then
        git push -u "$REMOTE_NAME" "$btopush"
      fi
      ;;
    7)
      print_line "${RED}⚠️  FORCE PUSH WARNING: This can overwrite remote history!${RESET}"
      if action_prompt "Are you absolutely sure you want to force-push with lease?" "n"; then
        git push --force-with-lease "$REMOTE_NAME" "$CURRENT_BRANCH"
      fi
      ;;
    0) ;;
    *) print_line "${YELLOW}Invalid option.${RESET}" ;;
  esac
}

# 13. Pull & Fetch
pull_and_fetch_menu() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}⬇️  PULL & FETCH (DOWNLOAD FROM REMOTE)${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  if [[ "$REMOTE_NAME" == "not configured" ]]; then
    print_line "${RED}❌ No remote repository configured.${RESET}"
    return 1
  fi

  cat <<'EOF'
  1) Smart Fetch All & Prune (git fetch --all --prune)
  2) Pull with Rebase (git pull --rebase) [Recommended]
  3) Standard Merge Pull (git pull)
  4) Pull from Specific Remote Branch (Select from list or manual)
  0) Cancel
EOF
  read -r -p "${BOLD}Select pull option [0-4]:${RESET} " plchoice
  case "$plchoice" in
    1)
      print_line "${CYAN}Fetching all branches from remotes...${RESET}"
      if git fetch --all --prune; then
        print_line "${GREEN}✅ Fetch completed.${RESET}"
      fi
      ;;
    2)
      print_line "${CYAN}Pulling with rebase...${RESET}"
      if git pull --rebase "$REMOTE_NAME" "$CURRENT_BRANCH"; then
        print_line "${GREEN}✅ Rebase pull successful.${RESET}"
      else
        print_line "${RED}❌ Pull failed or conflicts occurred.${RESET}"
      fi
      ;;
    3)
      print_line "${CYAN}Pulling and merging...${RESET}"
      if git pull "$REMOTE_NAME" "$CURRENT_BRANCH"; then
        print_line "${GREEN}✅ Pull successful.${RESET}"
      else
        print_line "${RED}❌ Pull failed.${RESET}"
      fi
      ;;
    4)
      local rbranch
      rbranch="$(select_branch "Select remote branch to pull" 1)"
      if [[ -n "$rbranch" ]]; then
        git pull "$REMOTE_NAME" "$rbranch"
      fi
      ;;
    0) ;;
    *) print_line "${YELLOW}Invalid option.${RESET}" ;;
  esac
}

# 14. Full Two-Way Synchronization
full_two_way_sync() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🔄 FULL TWO-WAY SYNCHRONIZATION${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  if [[ "$REMOTE_NAME" == "not configured" ]]; then
    print_line "${RED}❌ No remote configured to synchronize with.${RESET}"
    return 1
  fi

  if (( UNCOMMITTED_FILES > 0 )); then
    print_line "${YELLOW}⚠️  You have $UNCOMMITTED_FILES uncommitted change(s).${RESET}"
    if action_prompt "Commit changes before synchronization?" "y"; then
      smart_commit || return 1
    else
      print_line "${BLUE}Synchronization aborted to protect working tree.${RESET}"
      return 1
    fi
  fi

  print_line "${CYAN}Step 1: Fetching all remote data...${RESET}"
  git fetch --all --prune || { print_line "${RED}Fetch failed.${RESET}"; return 1; }

  refresh_git_metrics
  if (( BEHIND_COUNT > 0 )); then
    print_line "${CYAN}Step 2: Pulling and rebasing $BEHIND_COUNT remote commit(s)...${RESET}"
    git pull --rebase "$REMOTE_NAME" "$CURRENT_BRANCH" || { print_line "${RED}Rebase failed.${RESET}"; return 1; }
  else
    print_line "${GREEN}Step 2: Local branch is already up to date with remote.${RESET}"
  fi

  refresh_git_metrics
  if (( UNPUSHED_COMMITS > 0 || UPSTREAM_BRANCH == "none" )); then
    print_line "${CYAN}Step 3: Pushing local commits to remote...${RESET}"
    git push -u "$REMOTE_NAME" "$CURRENT_BRANCH" --follow-tags || { print_line "${RED}Push failed.${RESET}"; return 1; }
    print_line "${GREEN}✅ Push completed.${RESET}"
  else
    print_line "${GREEN}Step 3: No unpushed commits.${RESET}"
  fi

  print_line "${GREEN}🎉 Full synchronization complete!${RESET}"
}

# Visual Branch List with Rich Icons & Status
list_branches_visual() {
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🌿 REPOSITORY BRANCHES & STATUS OVERVIEW${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  local cur_br
  cur_br="$(git branch --show-current 2>/dev/null || true)"

  print_line "${BOLD}Local Branches:${RESET}"
  while IFS= read -r br; do
    [[ -z "$br" ]] && continue
    local is_cur=0
    if [[ "$br" == "$cur_br" ]]; then is_cur=1; fi

    local upstream
    upstream="$(git rev-parse --abbrev-ref --symbolic-full-name "${br}@{u}" 2>/dev/null || true)"
    local sync_info=""
    if [[ -n "$upstream" ]]; then
      local counts
      counts="$(git rev-list --left-right --count "${upstream}...${br}" 2>/dev/null || echo "0 0")"
      local beh ah
      read -r beh ah <<< "$counts"
      beh="${beh:-0}"; ah="${ah:-0}"
      if (( beh == 0 && ah == 0 )); then
        sync_info="${GREEN}[synced with ${upstream}]${RESET}"
      else
        sync_info="${YELLOW}[↑${ah} ↓${beh} vs ${upstream}]${RESET}"
      fi
    else
      sync_info="${GRAY}[no upstream]${RESET}"
    fi

    local last_c
    last_c="$(git log -1 --format='%h %cr by %an - %s' "$br" 2>/dev/null || echo 'no commits')"

    if (( is_cur == 1 )); then
      printf "  ${GREEN}⭐ %-28s${RESET} %b\n" "$br [ACTIVE]" "$sync_info"
      printf "     ${DIM}└─ %s${RESET}\n" "${last_c:0:70}"
    else
      printf "  ${CYAN}🌿 %-28s${RESET} %b\n" "$br" "$sync_info"
      printf "     ${DIM}└─ %s${RESET}\n" "${last_c:0:70}"
    fi
  done < <(git for-each-ref --format='%(refname:short)' refs/heads/)

  printf '\n'
  print_line "${BOLD}Remote Branches:${RESET}"
  while IFS= read -r rbr; do
    [[ -z "$rbr" || "$rbr" =~ HEAD ]] && continue
    local rlast
    rlast="$(git log -1 --format='%h %cr by %an - %s' "$rbr" 2>/dev/null || echo 'no commits')"
    printf "  ${BLUE}🌐 %-28s${RESET}\n" "$rbr"
    printf "     ${DIM}└─ %s${RESET}\n" "${rlast:0:70}"
  done < <(git for-each-ref --format='%(refname:short)' refs/remotes/)
}

# Compare Branches Menu (Choose from list or manual)
compare_branches_menu() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🔄 COMPARE CURRENT BRANCH ($CURRENT_BRANCH) WITH ANOTHER BRANCH${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  local target_br
  target_br="$(select_branch "Select branch to compare against" 1)" || return 0

  if [[ -z "$target_br" ]]; then
    return 0
  fi

  print_line "\nComparing: ${MAGENTA}${BOLD}${CURRENT_BRANCH}${RESET} ⟷ ${CYAN}${BOLD}${target_br}${RESET}"
  cat <<'EOF'
  1) 📊 Compare Summary Stats (git diff --stat)
  2) 📝 Detailed Line Diff (git diff)
  3) 📜 Commit Timeline Divergence Graph (git log graph)
  4) ⬆️  Commits in current branch NOT in target
  5) ⬇️  Commits in target branch NOT in current
  0) Cancel
EOF
  read -r -p "$(printf '%b' "${BOLD}Select comparison type [0-5]:${RESET} ")" cmptype
  case "$cmptype" in
    1)
      printf '\n%b\n' "${CYAN}── Diff Stat: ${CURRENT_BRANCH} vs ${target_br} ─────────────────────────────${RESET}"
      git diff --stat "${target_br}...${CURRENT_BRANCH}" 2>/dev/null || git diff --stat "${target_br}" "${CURRENT_BRANCH}" || true
      ;;
    2)
      printf '\n%b\n' "${CYAN}── Line Diff: ${CURRENT_BRANCH} vs ${target_br} ─────────────────────────────${RESET}"
      git diff "${target_br}...${CURRENT_BRANCH}" 2>/dev/null || git diff "${target_br}" "${CURRENT_BRANCH}" || true
      ;;
    3)
      printf '\n%b\n' "${CYAN}── Commit Divergence Graph ──────────────────────────────────────────${RESET}"
      git log --graph --oneline --left-right --cherry-pick --decorate "${target_br}...${CURRENT_BRANCH}" -n 25 2>/dev/null || git log --graph --oneline --decorate -n 25 "${target_br}" "${CURRENT_BRANCH}" || true
      ;;
    4)
      printf '\n%b\n' "${CYAN}── Commits in ${CURRENT_BRANCH} only: ───────────────────────────────${RESET}"
      git log --oneline "${target_br}..${CURRENT_BRANCH}" 2>/dev/null || git log -n 15 --oneline "${CURRENT_BRANCH}" || true
      ;;
    5)
      printf '\n%b\n' "${CYAN}── Commits in ${target_br} only: ───────────────────────────────────────${RESET}"
      git log --oneline "${CURRENT_BRANCH}..${target_br}" 2>/dev/null || git log -n 15 --oneline "${target_br}" || true
      ;;
    0) ;;
    *) print_line "${YELLOW}Invalid option.${RESET}" ;;
  esac
}

# 15. Branch Manager (With Interactive Selection)
branch_manager() {
  while true; do
    refresh_git_metrics
    print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    print_line "${BOLD}🌿 BRANCH MANAGER & REPOSITORIES${RESET}"
    print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    cat <<'EOF'
  1) 🌟 List All Branches with Icons & Status (Rich Overview)
  2) ➕ Create and Switch to New Branch
  3) 🔀 Switch Branch (Choose from list or manual)
  4) ✏️  Rename Current Branch
  5) 🔗 Set / Fix Upstream Tracking (git branch --set-upstream-to)
  6) 🎯 Make Local Branch Match Remote HEAD (git reset --hard origin/<branch>)
  7) 🗑️  Delete a Local Branch (Choose from list or manual)
  8) 🌐 Delete a Remote Branch (Choose from list or manual)
  9) 🔄 Compare Current Branch with Another Branch (Choose from list)
 10) 🗺️  Commit Navigation Graph (Interactive Keifu TUI)
  0) Back to Main Menu
EOF
    read -r -p "${BOLD}Select branch option [0-10]:${RESET} " bchoice
    case "$bchoice" in
      1)
        list_branches_visual
        ;;
      2)
        read -r -p "Enter new branch name: " new_br
        if [[ -n "$new_br" ]]; then
          if git switch -c "$new_br" 2>/dev/null || git checkout -b "$new_br"; then
            print_line "${GREEN}✅ Created and switched to branch: $new_br${RESET}"
          else
            print_line "${RED}❌ Failed to create branch $new_br${RESET}"
          fi
        fi
        ;;
      3)
        local sw_br
        sw_br="$(select_branch "Select branch to SWITCH to" 0)"
        if [[ -n "$sw_br" ]]; then
          if git switch "$sw_br" 2>/dev/null || git checkout "$sw_br"; then
            print_line "${GREEN}✅ Switched to branch: $sw_br${RESET}"
          else
            print_line "${RED}❌ Failed to switch to $sw_br${RESET}"
          fi
        fi
        ;;
      4)
        read -r -p "Enter new name for current branch ($CURRENT_BRANCH): " ren_br
        if [[ -n "$ren_br" ]]; then
          if git branch -m "$ren_br"; then
            print_line "${GREEN}✅ Branch renamed to: $ren_br${RESET}"
            if [[ "$UPSTREAM_BRANCH" != "none" ]]; then
              if action_prompt "Push renamed branch '$ren_br' to remote and update upstream?" "y"; then
                git push -u "$REMOTE_NAME" "$ren_br"
              fi
            fi
          fi
        fi
        ;;
      5)
        print_line "${CYAN}🔗 SET / FIX UPSTREAM TRACKING FOR '${CURRENT_BRANCH}'${RESET}"
        print_line "Current Upstream: ${YELLOW}${UPSTREAM_BRANCH}${RESET}"
        local target_upstream
        target_upstream="$(select_branch "Select remote branch to track (or press Enter for origin/${CURRENT_BRANCH})" 1)"
        if [[ -z "$target_upstream" ]]; then
          target_upstream="${REMOTE_NAME}/${CURRENT_BRANCH}"
        fi
        print_line "${CYAN}Setting upstream tracking to '${target_upstream}'...${RESET}"
        if git branch --set-upstream-to="$target_upstream" "$CURRENT_BRANCH" 2>/dev/null; then
          print_line "${GREEN}✅ Upstream tracking set to: ${target_upstream}${RESET}"
        else
          print_line "${YELLOW}Remote branch reference '${target_upstream}' not found locally.${RESET}"
          if action_prompt "Push branch '${CURRENT_BRANCH}' to '${REMOTE_NAME}' and set upstream now?" "y"; then
            git push -u "$REMOTE_NAME" "$CURRENT_BRANCH"
          fi
        fi
        ;;
      6)
        print_line "${CYAN}🎯 MAKE LOCAL BRANCH '${CURRENT_BRANCH}' MATCH REMOTE ORIGIN HEAD${RESET}"
        local target_ref
        if [[ "$UPSTREAM_BRANCH" != "none" ]]; then
          target_ref="$UPSTREAM_BRANCH"
        else
          target_ref="${REMOTE_NAME}/${CURRENT_BRANCH}"
        fi
        print_line "${YELLOW}⚠️  WARNING: Resetting local branch '${CURRENT_BRANCH}' to '${target_ref}' will DISCARD uncommitted changes and local-only commits!${RESET}"
        if action_prompt "Are you sure you want to reset HEAD to '${target_ref}'?" "n"; then
          print_line "${CYAN}Fetching latest references from '${REMOTE_NAME}'...${RESET}"
          git fetch "$REMOTE_NAME"
          if git reset --hard "$target_ref"; then
            print_line "${GREEN}✅ Local branch '${CURRENT_BRANCH}' HEAD is now identical to '${target_ref}'!${RESET}"
          else
            print_line "${RED}❌ Failed to reset to '${target_ref}'. Verify remote branch exists on remote.${RESET}"
          fi
        fi
        ;;
      7)
        local del_br
        del_br="$(select_branch "Select local branch to DELETE" 0)"
        if [[ -n "$del_br" ]]; then
          if [[ "$del_br" == "$CURRENT_BRANCH" ]]; then
            print_line "${RED}Cannot delete the currently active branch ($del_br). Switch first.${RESET}"
          elif git branch -d "$del_br" 2>/dev/null; then
            print_line "${GREEN}✅ Branch deleted: $del_br${RESET}"
          else
            print_line "${YELLOW}Branch '$del_br' is not fully merged.${RESET}"
            if action_prompt "Force delete branch with -D?" "n"; then
              git branch -D "$del_br" && print_line "${GREEN}✅ Force deleted: $del_br${RESET}"
            fi
          fi
        fi
        ;;
      8)
        local rdel_br
        rdel_br="$(select_branch "Select remote branch to DELETE from remote" 1)"
        if [[ -n "$rdel_br" ]]; then
          local clean_rname="${rdel_br#origin/}"
          if action_prompt "Permanently delete branch '$clean_rname' from remote '$REMOTE_NAME'?" "n"; then
            git push "$REMOTE_NAME" --delete "$clean_rname"
          fi
        fi
        ;;
      9)
        compare_branches_menu
        ;;
      10)
        commit_navigation_graph
        ;;
      0) break ;;
      *) print_line "${YELLOW}Invalid option.${RESET}" ;;
    esac
    press_any_key
  done
}

# 16. Merge & Rebase Hub (Choose from list or manual)
merge_rebase_hub() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🔀 MERGE & REBASE HUB${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  cat <<'EOF'
  1) 🔀 Merge Another Branch into Current Branch (Choose from list or manual)
  2) 🔄 Rebase Current Branch onto Another Branch (Choose from list or manual)
  3) ⏹️  Abort Ongoing Merge & Go Back (git merge --abort)
  4) ⏹️  Abort Ongoing Rebase & Go Back to Original State (git rebase --abort)
  5) ▶️  Continue Rebase after Conflict Resolution (git rebase --continue)
  6) 🚨 Show Conflicted Files
  0) Cancel
EOF
  read -r -p "${BOLD}Select option [0-6]:${RESET} " mchoice
  case "$mchoice" in
    1)
      local mbr
      mbr="$(select_branch "Select branch to MERGE into $CURRENT_BRANCH" 1)"
      if [[ -n "$mbr" ]]; then
        if [[ "$mbr" == "$CURRENT_BRANCH" ]]; then
          print_line "${YELLOW}Cannot merge a branch into itself.${RESET}"
        elif action_prompt "Merge branch '$mbr' into '$CURRENT_BRANCH'?" "y"; then
          git merge "$mbr"
        fi
      fi
      ;;
    2)
      local rbr
      rbr="$(select_branch "Select target branch to REBASE $CURRENT_BRANCH onto" 1)"
      if [[ -n "$rbr" ]]; then
        if [[ "$rbr" == "$CURRENT_BRANCH" ]]; then
          print_line "${YELLOW}Cannot rebase a branch onto itself.${RESET}"
        elif action_prompt "Rebase current branch '$CURRENT_BRANCH' onto '$rbr'?" "y"; then
          git rebase "$rbr"
        fi
      fi
      ;;
    3)
      abort_rebase_or_merge "merge"
      ;;
    4)
      abort_rebase_or_merge "rebase"
      ;;
    5)
      git rebase --continue
      ;;
    6)
      git diff --name-only --diff-filter=U
      ;;
    0) ;;
    *) print_line "${YELLOW}Invalid option.${RESET}" ;;
  esac
}

# Abort Rebase / Merge (Emergency Go Back Safely)
abort_rebase_or_merge() {
  local target_mode="${1:-auto}"
  local git_dir
  git_dir="$(git rev-parse --git-dir 2>/dev/null || echo ".git")"
  local is_rebasing=0
  local is_merging=0

  [[ -d "$git_dir/rebase-merge" || -d "$git_dir/rebase-apply" ]] && is_rebasing=1
  [[ -f "$git_dir/MERGE_HEAD" ]] && is_merging=1

  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}⏹️  ABORT REBASE / MERGE — EMERGENCY GO BACK${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  if [[ "$target_mode" == "rebase" || ($target_mode == "auto" && $is_rebasing -eq 1) ]]; then
    if [[ $is_rebasing -eq 1 ]]; then
      print_line "${YELLOW}⚠️  Active rebase detected in repository.${RESET}"
      print_line "Aborting will cancel the rebase and immediately restore your branch to its exact"
      print_line "state before 'git rebase' was started, preserving all your previous commits."
      printf '\n'
      if action_prompt "Confirm: Abort rebase and GO BACK to your original version?" "y"; then
        if git rebase --abort; then
          print_line "${GREEN}✅ Rebase successfully ABORTED! Your branch has been restored to its previous state.${RESET}"
          refresh_git_metrics
          print_line "Current HEAD: ${CYAN}${LAST_COMMIT_HASH}${RESET} - ${WHITE}${LAST_COMMIT_MSG}${RESET}"
        else
          print_line "${RED}❌ git rebase --abort encountered an issue.${RESET}"
        fi
      else
        print_line "${CYAN}Rebase abort cancelled.${RESET}"
      fi
    else
      print_line "${YELLOW}No active rebase was detected via git metadata.${RESET}"
      if action_prompt "Attempt 'git rebase --abort' anyway?" "y"; then
        git rebase --abort 2>&1 || print_line "${CYAN}No rebase in progress to abort.${RESET}"
      fi
    fi
  elif [[ "$target_mode" == "merge" || ($target_mode == "auto" && $is_merging -eq 1) ]]; then
    if [[ $is_merging -eq 1 ]]; then
      print_line "${YELLOW}⚠️  Active merge detected in repository.${RESET}"
      print_line "Aborting will cancel the merge and restore your branch to pre-merge state."
      printf '\n'
      if action_prompt "Confirm: Abort merge and GO BACK to original state?" "y"; then
        if git merge --abort; then
          print_line "${GREEN}✅ Merge successfully ABORTED! Branch restored.${RESET}"
          refresh_git_metrics
        else
          print_line "${RED}❌ git merge --abort failed.${RESET}"
        fi
      fi
    else
      print_line "${YELLOW}No active merge was detected.${RESET}"
      if action_prompt "Attempt 'git merge --abort' anyway?" "y"; then
        git merge --abort 2>&1 || print_line "${CYAN}No merge in progress to abort.${RESET}"
      fi
    fi
  else
    print_line "${GREEN}No active rebase or merge is currently detected.${RESET}"
    print_line "Your repository working tree is in normal mode."
    print_line ""
    print_line "Options:"
    print_line "  1) Try 'git rebase --abort' anyway"
    print_line "  2) Try 'git merge --abort' anyway"
    print_line "  3) ⏪ Backtrack / Time-Travel to a previous commit (Undo Hub)"
    print_line "  4) 📜 View Git Reflog (Find your last commit before rebase)"
    print_line "  0) Return to Main Menu"
    read -r -p "${BOLD}Select action [0-4]:${RESET} " alt_c
    case "$alt_c" in
      1) git rebase --abort 2>&1 || print_line "${CYAN}No rebase in progress to abort.${RESET}" ;;
      2) git merge --abort 2>&1 || print_line "${CYAN}No merge in progress to abort.${RESET}" ;;
      3) undo_and_recovery_menu ;;
      4)
        printf '\n%b\n' "${CYAN}── Git Reflog ─────────────────────────────────────────────────────${RESET}"
        git reflog -n 20
        ;;
      *) ;;
    esac
  fi
}

# 17. Visual Branch Graph
visual_branch_graph() {
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}📈 VISUAL COMMIT & BRANCH GRAPH${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  git log --graph --oneline --decorate --all -n 25 || true
  printf '\n'
  print_line "${GRAY}────────────────────────────────────────────────────────────────────────────${RESET}"
  print_line "💡 ${BOLD}${CYAN}Pro-Tip: Interactive Commit Navigation Graph (Keifu TUI)${RESET}"
  print_line "   Experience a full-screen interactive Git graph with commit metadata,"
  print_line "   diff previews, branch genealogy, and one-key checkout (Option 19)."
  print_line "${GRAY}────────────────────────────────────────────────────────────────────────────${RESET}"
  local launch_choice=""
  read -r -p "$(printf '%b' "${BOLD}${WHITE}Launch interactive Keifu graph now? [y/N]: ${RESET}")" launch_choice
  if [[ "$launch_choice" =~ ^[yY] ]]; then
    commit_navigation_graph
  fi
}

# 17b. Interactive Commit Navigation Graph (Keifu TUI)
find_keifu_bin() {
  # 1. Local portable binary inside project folder (works seamlessly when folder is copied to another PC)
  if [[ -n "${SCRIPT_DIR:-}" && -f "$SCRIPT_DIR/bin/keifu" ]]; then
    chmod +x "$SCRIPT_DIR/bin/keifu" 2>/dev/null || true
    if [[ -x "$SCRIPT_DIR/bin/keifu" ]]; then
      printf '%s' "$SCRIPT_DIR/bin/keifu"
      return 0
    fi
  fi
  if [[ -f "./bin/keifu" ]]; then
    chmod +x "./bin/keifu" 2>/dev/null || true
    if [[ -x "./bin/keifu" ]]; then
      printf '%s' "./bin/keifu"
      return 0
    fi
  fi
  if [[ -n "${SCRIPT_DIR:-}" && -x "$SCRIPT_DIR/bin/keifu.exe" ]]; then
    printf '%s' "$SCRIPT_DIR/bin/keifu.exe"
    return 0
  fi

  # 2. System PATH
  if command -v keifu >/dev/null 2>&1; then
    command -v keifu
    return 0
  fi

  # 3. Standard user directories
  local candidates=(
    "$HOME/.local/bin/keifu"
    "/usr/local/bin/keifu"
    "/usr/bin/keifu"
    "$(dirname "$0")/bin/keifu"
    "/tmp/keifu"
  )
  for c in "${candidates[@]}"; do
    if [[ -x "$c" ]]; then
      printf '%s' "$c"
      return 0
    fi
  done
  return 1
}

install_keifu() {
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}📥 AUTO-INSTALL KEIFU (Interactive Git Commit Navigation Graph)${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "Detecting operating system and CPU architecture..."

  local os arch target_url
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m)"

  case "$os" in
    linux)
      case "$arch" in
        x86_64) target_url="https://github.com/trasta298/keifu/releases/download/v0.6.0/keifu-v0.6.0-x86_64-unknown-linux-musl.tar.gz" ;;
        aarch64|arm64) target_url="https://github.com/trasta298/keifu/releases/download/v0.6.0/keifu-v0.6.0-aarch64-unknown-linux-gnu.tar.gz" ;;
        *) target_url="" ;;
      esac
      ;;
    darwin)
      case "$arch" in
        x86_64) target_url="https://github.com/trasta298/keifu/releases/download/v0.6.0/keifu-v0.6.0-x86_64-apple-darwin.tar.gz" ;;
        arm64|aarch64) target_url="https://github.com/trasta298/keifu/releases/download/v0.6.0/keifu-v0.6.0-aarch64-apple-darwin.tar.gz" ;;
        *) target_url="" ;;
      esac
      ;;
    *)
      target_url=""
      ;;
  esac

  if [[ -z "$target_url" ]]; then
    print_line "${YELLOW}⚠️  Precompiled binary not directly mapped for OS '$os' / ARCH '$arch'.${RESET}"
    print_line "You can install Keifu easily via:"
    print_line "  • ${BOLD}cargo install keifu${RESET}"
    print_line "  • ${BOLD}brew install trasta298/tap/keifu${RESET} (macOS / Linuxbrew)"
    print_line "  • ${BOLD}mise use -g github:trasta298/keifu@latest${RESET}"
    print_line "GitHub: ${UNDERLINE}https://github.com/trasta298/keifu${RESET}"
    return 1
  fi

  local install_dir="$HOME/.local/bin"
  mkdir -p "$install_dir"
  local tmp_archive="/tmp/keifu_install_$$.tar.gz"
  local tmp_extract="/tmp/keifu_extract_$$"
  mkdir -p "$tmp_extract"

  print_line "Downloading Keifu package: ${CYAN}${target_url}${RESET}"
  if curl -sSL "$target_url" -o "$tmp_archive"; then
    if tar -xzf "$tmp_archive" -C "$tmp_extract" 2>/dev/null; then
      local extracted_bin
      extracted_bin="$(find "$tmp_extract" -name "keifu" -type f | head -n 1)"
      if [[ -n "$extracted_bin" && -f "$extracted_bin" ]]; then
        cp -f "$extracted_bin" "$install_dir/keifu"
        chmod +x "$install_dir/keifu"
        # Also copy to local script bin directory if exists/creatable
        if [[ -n "${SCRIPT_DIR:-}" && -d "${SCRIPT_DIR:-}" ]]; then
          mkdir -p "$SCRIPT_DIR/bin" 2>/dev/null || true
          cp -f "$extracted_bin" "$SCRIPT_DIR/bin/keifu" 2>/dev/null || true
          chmod +x "$SCRIPT_DIR/bin/keifu" 2>/dev/null || true
        fi
        rm -rf "$tmp_archive" "$tmp_extract"
        export PATH="$install_dir:$PATH"
        print_line "${GREEN}✅ Keifu installed successfully to ${BOLD}$install_dir/keifu${RESET}!"
        return 0
      fi
    fi
  fi
  rm -rf "$tmp_archive" "$tmp_extract"
  print_line "${RED}❌ Download or extraction failed. Please check internet connection or install via 'cargo install keifu'.${RESET}"
  return 1
}

commit_navigation_graph() {
  refresh_git_metrics
  if [[ "$HAS_COMMITS" -eq 0 ]]; then
    print_line "${YELLOW}⚠️  No commits found in repository yet.${RESET}"
    print_line "Create an initial commit first before navigating the commit graph."
    return 0
  fi

  local keifu_cmd
  keifu_cmd="$(find_keifu_bin || true)"
  if [[ -z "$keifu_cmd" ]]; then
    print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    print_line "${BOLD}🗺️  COMMIT NAVIGATION GRAPH (KEIFU)${RESET}"
    print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    print_line "${YELLOW}Keifu is not currently installed.${RESET}"
    print_line "Keifu (https://github.com/trasta298/keifu) is a modern terminal UI tool providing:"
    print_line "  • Real-time visual Git commit graph with colored branch genealogy"
    print_line "  • Full commit metadata (hash, author, date, parent commits)"
    print_line "  • Commit message & changed files / diff inspection panel"
    print_line "  • Quick keyboard navigation, branch switching, and remote fetching"
    printf '\n'
    if action_prompt "Would you like to auto-download and install Keifu now?" "y"; then
      if install_keifu; then
        keifu_cmd="$(find_keifu_bin || true)"
      fi
    fi
  fi

  if [[ -n "$keifu_cmd" && -x "$keifu_cmd" ]]; then
    print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    print_line "${BOLD}🗺️  OPENING COMMIT NAVIGATION GRAPH (KEIFU)${RESET}"
    print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    print_line "Keifu Navigation Controls:"
    print_line "  • ${BOLD}j / k${RESET} or ${BOLD}↑ / ↓${RESET} : Move through commits in graph"
    print_line "  • ${BOLD}Enter${RESET}       : Checkout branch / commit details"
    print_line "  • ${BOLD}b${RESET}           : Branch operations"
    print_line "  • ${BOLD}f${RESET}           : Fetch from remote"
    print_line "  • ${BOLD}?${RESET}           : Help & keybindings"
    print_line "  • ${BOLD}q${RESET}           : Exit back to Git Manager"
    printf '\n'
    printf '%b' "${DIM}Starting interactive session...${RESET}\n"
    sleep 0.4
    "$keifu_cmd"
    local ret=$?
    stty sane 2>/dev/null || true
    clear 2>/dev/null || true
    print_line "${GREEN}✓ Returned from Commit Navigation Graph.${RESET}"
    return $ret
  else
    print_line "${YELLOW}Opening visual Git log graph fallback:${RESET}"
    git log --graph --color=always --format='%C(auto)%h%d %C(bold white)%s %C(dim green)(%cr) %C(cyan)<%an>' --all -n 40 | less -R
  fi
}

# 18. Release & Tag Manager (SemVer Recommendation)
classify_commit_type() {
  local msg="${1,,}"
  if [[ "$msg" =~ ^(break|breaking|major|rewrite) || "$msg" =~ BREAKING[[:space:]]CHANGE ]]; then
    printf 'breaking'
  elif [[ "$msg" =~ ^(feat|feature|add|new) ]]; then
    printf 'feat'
  elif [[ "$msg" =~ ^(fix|bug|hotfix|patch) ]]; then
    printf 'fix'
  elif [[ "$msg" =~ ^(refactor|improve|perf) ]]; then
    printf 'refactor'
  else
    printf 'other'
  fi
}

compute_version_suggestion() {
  local tag_base="${CURRENT_VERSION#v}"
  tag_base="${tag_base%%-*}"
  local major=0 minor=1 patch=0
  if [[ "$tag_base" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    patch="${BASH_REMATCH[3]}"
  fi

  local breaking_cnt=0 feat_cnt=0 fix_cnt=0
  while IFS= read -r msg; do
    [[ -z "$msg" ]] && continue
    local k
    k="$(classify_commit_type "$msg")"
    case "$k" in
      breaking) breaking_cnt=$((breaking_cnt + 1)) ;;
      feat) feat_cnt=$((feat_cnt + 1)) ;;
      fix) fix_cnt=$((fix_cnt + 1)) ;;
    esac
  done < <(git log --format='%s' -n 30 2>/dev/null || true)

  if (( breaking_cnt > 0 )); then
    printf '%s.%s.%s' "$((major + 1))" 0 0
  elif (( feat_cnt > 0 || COMMITS_SINCE_TAG >= 5 )); then
    printf '%s.%s.%s' "$major" "$((minor + 1))" 0
  else
    printf '%s.%s.%s' "$major" "$minor" "$((patch + 1))"
  fi
}

show_version_recommendation() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🏷️  VERSION & TAG MANAGER (SemVer)${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  local rec_tag
  rec_tag="$(compute_version_suggestion)"
  print_line "Current Version     : ${YELLOW}${CURRENT_VERSION}${RESET}"
  print_line "Commits Since Tag   : ${CYAN}${COMMITS_SINCE_TAG}${RESET}"
  print_line "Recommended Version : ${GREEN}${BOLD}v${rec_tag}${RESET}"
  printf '\n'

  cat <<'EOF'
  1) Create Recommended Version Tag (and optional Changelog entry)
  2) Create Custom Tag Name
  3) List All Tags
  4) Push All Tags to Remote
  5) Delete a Tag (Choose from list or manual)
  0) Cancel
EOF
  read -r -p "${BOLD}Select tag option [0-5]:${RESET} " tchoice
  case "$tchoice" in
    1)
      if action_prompt "Create release tag v${rec_tag}?" "y"; then
        read -r -p "Enter tag annotation message [default: Release v${rec_tag}]: " tmsg
        tmsg="${tmsg:-Release v${rec_tag}}"
        if git tag -a "v${rec_tag}" -m "$tmsg"; then
          print_line "${GREEN}✅ Tag v${rec_tag} created!${RESET}"
          if action_prompt "Push tag to remote now?" "y"; then
            git push "$REMOTE_NAME" "v${rec_tag}"
          fi
        fi
      fi
      ;;
    2)
      read -r -p "Enter tag name (e.g., v1.0.0): " custom_t
      read -r -p "Enter tag message: " custom_tmsg
      if [[ -n "$custom_t" ]]; then
        if git tag -a "$custom_t" -m "${custom_tmsg:-Release $custom_t}"; then
          print_line "${GREEN}✅ Tag $custom_t created!${RESET}"
          if action_prompt "Push tag to remote now?" "y"; then
            git push "$REMOTE_NAME" "$custom_t"
          fi
        fi
      fi
      ;;
    3)
      git tag -n --sort=-v:refname
      ;;
    4)
      git push "$REMOTE_NAME" --tags
      ;;
    5)
      local dt
      dt="$(select_tag "Select tag to DELETE")"
      if [[ -n "$dt" ]]; then
        if action_prompt "Delete local tag '$dt'?" "y"; then
          git tag -d "$dt" && print_line "${GREEN}✅ Tag deleted: $dt${RESET}"
        fi
      fi
      ;;
    0) ;;
    *) print_line "${YELLOW}Invalid option.${RESET}" ;;
  esac
}

# 19. Generate Changelog
generate_changelog() {
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}📄 CHANGELOG GENERATOR${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  local cl_file="CHANGELOG.md"
  local today
  today="$(date +%Y-%m-%d)"
  local rec_tag
  rec_tag="$(compute_version_suggestion)"

  if action_prompt "Generate/Update ${cl_file} for version v${rec_tag}?" "y"; then
    if [[ ! -f "$cl_file" ]]; then
      printf '# Changelog\n\nAll notable changes to this project are documented in this file.\n\n' > "$cl_file"
    fi

    local temp_log
    temp_log="$(mktemp)"
    printf '\n## [v%s] - %s\n\n' "$rec_tag" "$today" >> "$cl_file"

    printf '### Features\n' >> "$cl_file"
    git log --format='- %s' -n 20 2>/dev/null | grep -Ei 'feat|feature|add' >> "$cl_file" || printf -- '- General enhancements\n' >> "$cl_file"

    printf '\n### Fixes\n' >> "$cl_file"
    git log --format='- %s' -n 20 2>/dev/null | grep -Ei 'fix|bug|hotfix' >> "$cl_file" || printf -- '- Bug fixes and stability improvements\n' >> "$cl_file"

    printf '\n### Maintenance & Refactoring\n' >> "$cl_file"
    git log --format='- %s' -n 20 2>/dev/null | grep -Ei 'refactor|chore|clean' >> "$cl_file" || printf -- '- Code and repository maintenance\n' >> "$cl_file"

    rm -f "$temp_log"
    print_line "${GREEN}✅ Updated ${cl_file}!${RESET}"
  fi
}

# 20. Git Stash Manager (Choose from list or manual)
stash_manager() {
  while true; do
    print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    print_line "${BOLD}🗄️  GIT STASH MANAGER (TEMPORARY STORAGE)${RESET}"
    print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    cat <<'EOF'
  1) 📥 Stash Current Changes (git stash push -m "...")
  2) 📦 Stash Including Untracked Files (git stash push -u)
  3) 📋 List Stashes
  4) 🔍 Show Stash Diff (Choose from list or manual)
  5) 📤 Pop Latest Stash (Apply & Remove)
  6) ♻️  Apply Stash (Choose from list or manual)
  7) 🗑️  Drop / Delete a Stash (Choose from list or manual)
  8) ⚠️  Clear All Stashes (git stash clear)
  0) Back to Main Menu
EOF
    read -r -p "${BOLD}Select stash option [0-8]:${RESET} " stchoice
    case "$stchoice" in
      1)
        read -r -p "Enter stash message / note: " stmsg
        if [[ -n "$stmsg" ]]; then
          git stash push -m "$stmsg"
        else
          git stash push
        fi
        ;;
      2)
        read -r -p "Enter stash message: " stmsg
        git stash push -u -m "${stmsg:-wip}"
        ;;
      3)
        printf '\n%b\n' "${CYAN}── Current Stash List ─────────────────────────────────────────────${RESET}"
        git stash list
        ;;
      4)
        local stidx
        stidx="$(select_stash "Select stash to inspect")"
        if [[ -n "$stidx" ]]; then
          git stash show -p "$stidx" || true
        fi
        ;;
      5)
        git stash pop
        ;;
      6)
        local st_app
        st_app="$(select_stash "Select stash to apply")"
        if [[ -n "$st_app" ]]; then
          git stash apply "$st_app"
        fi
        ;;
      7)
        local st_drp
        st_drp="$(select_stash "Select stash to drop")"
        if [[ -n "$st_drp" ]]; then
          git stash drop "$st_drp"
        fi
        ;;
      8)
        if action_prompt "Are you sure you want to delete ALL stashes?" "n"; then
          git stash clear
          print_line "${GREEN}Stashes cleared.${RESET}"
        fi
        ;;
      0) break ;;
      *) print_line "${YELLOW}Invalid option.${RESET}" ;;
    esac
    press_any_key
  done
}

# 21. Undo, Backtrack & Recovery (Choose from commit list or manual)
backtrack_commit_hub() {
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}⏪ COMMIT BACKTRACKING & TIME-TRAVEL HUB${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  local target_commit
  target_commit="$(select_commit "Select target commit to backtrack/inspect" 15)" || return 0

  if [[ -z "$target_commit" ]]; then
    return 0
  fi

  local commit_desc
  commit_desc="$(git log -1 --format='%h - %s (%cr)' "$target_commit" 2>/dev/null || echo "$target_commit")"
  print_line "\nSelected Target: ${YELLOW}${BOLD}${commit_desc}${RESET}"
  cat <<'EOF'
  1) ⏪ Soft Backtrack (Reset to commit, KEEP all changes STAGED) [Safe]
  2) ♻️  Mixed Backtrack (Reset to commit, KEEP all changes in files UNSTAGED) [Safe]
  3) 🕵️  Time-Travel & Inspect (Checkout commit in read-only detached state)
  4) 🔄 Revert this commit (Create a reverse commit: git revert)
  5) 📜 View Commit Diff & Details (git show)
  6) ⚠️  Hard Reset to this commit (DISCARD all changes newer than this commit)
  0) Cancel
EOF
  read -r -p "$(printf '%b' "${BOLD}Select action [0-6]:${RESET} ")" b_action
  case "$b_action" in
    1)
      if action_prompt "Soft-backtrack to $target_commit? (Your code will remain staged)" "y"; then
        git reset --soft "$target_commit" && print_line "${GREEN}✅ Reset --soft to $target_commit completed.${RESET}"
      fi
      ;;
    2)
      if action_prompt "Mixed-backtrack to $target_commit? (Your code will remain unstaged in files)" "y"; then
        git reset --mixed "$target_commit" && print_line "${GREEN}✅ Reset --mixed to $target_commit completed.${RESET}"
      fi
      ;;
    3)
      if action_prompt "Time-travel to $target_commit in detached HEAD? (Use branch manager to return)" "y"; then
        git checkout "$target_commit" && print_line "${GREEN}✅ Checked out $target_commit.${RESET}"
      fi
      ;;
    4)
      if action_prompt "Revert commit $target_commit?" "y"; then
        git revert "$target_commit"
      fi
      ;;
    5)
      printf '\n%b\n' "${CYAN}── Commit Details: ${target_commit} ──────────────────────────────────${RESET}"
      git show "$target_commit"
      ;;
    6)
      print_line "${RED}⚠️  WARNING: HARD RESET WILL PERMANENTLY DISCARD COMMITS AFTER ${target_commit}!${RESET}"
      if action_prompt "Are you completely sure you want to HARD RESET to $target_commit?" "n"; then
        git reset --hard "$target_commit" && print_line "${GREEN}✅ Hard reset to $target_commit completed.${RESET}"
      fi
      ;;
    0) ;;
    *) print_line "${YELLOW}Invalid option.${RESET}" ;;
  esac
}

undo_and_recovery_menu() {
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}⏪ UNDO, RESET & RECOVERY (SAFETY NET)${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  cat <<'EOF'
  1) ⏪ Interactive Commit Backtracking (Pick from commit timeline or manual)
  2) ↩️  Soft Undo Last Commit (HEAD~1: keeps changes staged)
  3) ♻️  Mixed Undo Last Commit (HEAD~1: keeps changes in files unstaged)
  4) 📜 View Git Reflog (Find and recover lost commits or deleted branches)
  5) ⏹️  Abort Ongoing Rebase & Go Back to Original State (git rebase --abort)
  6) ⏹️  Abort Ongoing Merge & Go Back to Original State (git merge --abort)
  0) Cancel
EOF
  read -r -p "${BOLD}Select option [0-6]:${RESET} " rchoice
  case "$rchoice" in
    1)
      backtrack_commit_hub
      ;;
    2)
      if action_prompt "Soft-undo last commit? (Changes will stay staged)" "y"; then
        git reset --soft HEAD~1 && print_line "${GREEN}✅ Last commit undone (changes kept staged).${RESET}"
      fi
      ;;
    3)
      if action_prompt "Mixed-undo last commit? (Changes will stay in files unstaged)" "y"; then
        git reset --mixed HEAD~1 && print_line "${GREEN}✅ Last commit undone (changes preserved in files).${RESET}"
      fi
      ;;
    4)
      printf '\n%b\n' "${CYAN}── Git Reflog ─────────────────────────────────────────────────────${RESET}"
      git reflog -n 25
      ;;
    5)
      abort_rebase_or_merge "rebase"
      ;;
    6)
      abort_rebase_or_merge "merge"
      ;;
    0) ;;
    *) print_line "${YELLOW}Invalid option.${RESET}" ;;
  esac
}

# Helper: Prompt and Configure Git Identity (Name & Email)
prompt_and_configure_identity() {
  local cur_name cur_email
  cur_name="$(git config user.name 2>/dev/null || echo '')"
  cur_email="$(git config user.email 2>/dev/null || echo '')"

  print_line ""
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}👤 GIT IDENTITY & EMAIL CONFIGURATION${RESET}"
  print_line "  Current Name  : ${YELLOW}${cur_name:-'not set'}${RESET}"
  print_line "  Current Email : ${YELLOW}${cur_email:-'not set'}${RESET}"

  local do_config=false
  if [[ -z "$cur_name" || -z "$cur_email" ]]; then
    print_line "${YELLOW}⚠️  Git identity is incomplete! Name and Email are required for git commits.${RESET}"
    do_config=true
  else
    if action_prompt "Do you want to configure or update your Git User Name and Email?" "n"; then
      do_config=true
    fi
  fi

  if $do_config; then
    cat <<'EOF'
  Select Identity Scope:
  1) Set Identity for THIS Repository Only (local)
  2) Set Identity Globally for All Repositories (global)
EOF
    read -r -p "${BOLD}Select scope [1-2, default 1]:${RESET} " idscope
    local flag="--local"
    [[ "$idscope" == "2" ]] && flag="--global"

    read -r -p "Enter Git User Name [${cur_name:-'no default'}]: " in_name
    in_name="${in_name:-$cur_name}"

    read -r -p "Enter Git User Email [${cur_email:-'no default'}]: " in_email
    in_email="${in_email:-$cur_email}"

    if [[ -n "$in_name" ]]; then
      git config $flag user.name "$in_name"
      print_line "${GREEN}✅ user.name set to '$in_name' ($flag).${RESET}"
    fi

    if [[ -n "$in_email" ]]; then
      git config $flag user.email "$in_email"
      print_line "${GREEN}✅ user.email set to '$in_email' ($flag).${RESET}"
    else
      print_line "${RED}⚠️  Warning: user.email was left empty. Git requires an email address for commit identity!${RESET}"
    fi
  fi
}

# Smart Remote Config: GitHub
smart_config_github() {
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🐙 SMART CONFIGURATION FOR GITHUB${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  local cur_dir_name="$(basename "$PWD")"

  cat <<'EOF'
  Choose Protocol for GitHub:
  1) HTTPS (https://github.com/owner/repo.git)
  2) SSH   (git@github.com:owner/repo.git)
EOF
  read -r -p "${BOLD}Select protocol [1-2, default 1]:${RESET} " proto_choice

  local gh_owner="" gh_repo=""
  read -r -p "Enter GitHub Username or Organization: " gh_owner
  if [[ -z "$gh_owner" ]]; then
    print_line "${YELLOW}⚠️  Username/Organization cannot be empty.${RESET}"
    return 1
  fi

  read -r -p "Enter Repository Name [default: ${cur_dir_name}]: " gh_repo
  gh_repo="${gh_repo:-$cur_dir_name}"
  gh_repo="${gh_repo%.git}"

  local target_url=""
  if [[ "$proto_choice" == "2" ]]; then
    target_url="git@github.com:${gh_owner}/${gh_repo}.git"
  else
    target_url="https://github.com/${gh_owner}/${gh_repo}.git"
  fi

  print_line "${CYAN}Generated GitHub Remote URL: ${BOLD}${target_url}${RESET}"

  read -r -p "Enter Remote Name [default: origin]: " r_name
  r_name="${r_name:-origin}"

  if git remote get-url "$r_name" >/dev/null 2>&1; then
    git remote set-url "$r_name" "$target_url"
  else
    git remote add "$r_name" "$target_url"
  fi
  print_line "${GREEN}✅ Remote '$r_name' successfully configured to: $target_url${RESET}"

  prompt_and_configure_identity

  if action_prompt "Test connectivity to GitHub remote '$r_name' now?" "y"; then
    print_line "${CYAN}Testing connectivity to $r_name...${RESET}"
    if git ls-remote "$r_name" >/dev/null 2>&1; then
      print_line "${GREEN}✅ Connection successful! GitHub remote '$r_name' is reachable.${RESET}"
    else
      print_line "${RED}❌ Could not connect to GitHub remote '$r_name'. Check network or repository permissions.${RESET}"
    fi
  fi
}

# Smart Remote Config: Bitbucket
smart_config_bitbucket() {
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🪣 SMART CONFIGURATION FOR BITBUCKET${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  local cur_dir_name="$(basename "$PWD")"

  cat <<'EOF'
  Choose Protocol for Bitbucket:
  1) HTTPS (https://bitbucket.org/workspace/repo.git)
  2) SSH   (git@bitbucket.org:workspace/repo.git)
EOF
  read -r -p "${BOLD}Select protocol [1-2, default 1]:${RESET} " proto_choice

  local bb_workspace="" bb_repo=""
  read -r -p "Enter Bitbucket Workspace or Username: " bb_workspace
  if [[ -z "$bb_workspace" ]]; then
    print_line "${YELLOW}⚠️  Workspace/Username cannot be empty.${RESET}"
    return 1
  fi

  read -r -p "Enter Repository Name [default: ${cur_dir_name}]: " bb_repo
  bb_repo="${bb_repo:-$cur_dir_name}"
  bb_repo="${bb_repo%.git}"

  local target_url=""
  if [[ "$proto_choice" == "2" ]]; then
    target_url="git@bitbucket.org:${bb_workspace}/${bb_repo}.git"
  else
    target_url="https://bitbucket.org/${bb_workspace}/${bb_repo}.git"
  fi

  print_line "${CYAN}Generated Bitbucket Remote URL: ${BOLD}${target_url}${RESET}"

  read -r -p "Enter Remote Name [default: origin]: " r_name
  r_name="${r_name:-origin}"

  if git remote get-url "$r_name" >/dev/null 2>&1; then
    git remote set-url "$r_name" "$target_url"
  else
    git remote add "$r_name" "$target_url"
  fi
  print_line "${GREEN}✅ Remote '$r_name' successfully configured to: $target_url${RESET}"

  prompt_and_configure_identity

  if action_prompt "Test connectivity to Bitbucket remote '$r_name' now?" "y"; then
    print_line "${CYAN}Testing connectivity to $r_name...${RESET}"
    if git ls-remote "$r_name" >/dev/null 2>&1; then
      print_line "${GREEN}✅ Connection successful! Bitbucket remote '$r_name' is reachable.${RESET}"
    else
      print_line "${RED}❌ Could not connect to Bitbucket remote '$r_name'. Check network or repository permissions.${RESET}"
    fi
  fi
}

# 22. Remote Repository Configuration (Choose from list or manual)
configure_remote_access() {
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🌐 REMOTE REPOSITORY & IDENTITY CONFIGURATION${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  local cur_name cur_email
  cur_name="$(git config user.name 2>/dev/null || echo 'not set')"
  cur_email="$(git config user.email 2>/dev/null || echo 'not set')"
  print_line "Current Git User Name  : ${YELLOW}${cur_name}${RESET}"
  print_line "Current Git User Email : ${YELLOW}${cur_email}${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  cat <<'EOF'
  1) View Current Remotes (git remote -v)
  2) Set or Change Origin URL (Manual)
  3) Add a New Remote (Manual)
  4) 🐙 Smart Config for GitHub (Remote & Identity)
  5) 🪣 Smart Config for Bitbucket (Remote & Identity)
  6) 👤 Configure Git Identity & Email (Name & Email)
  7) Test Remote Connectivity (Choose from list or manual)
  8) Remove a Remote (Choose from list or manual)
  0) Cancel
EOF
  read -r -p "${BOLD}Select remote option [0-8]:${RESET} " rmchoice
  case "$rmchoice" in
    1)
      git remote -v
      ;;
    2)
      read -r -p "Enter new remote URL for 'origin': " new_url
      if [[ -n "$new_url" ]]; then
        if git remote get-url origin >/dev/null 2>&1; then
          git remote set-url origin "$new_url"
        else
          git remote add origin "$new_url"
        fi
        print_line "${GREEN}✅ Remote origin updated: $new_url${RESET}"
        prompt_and_configure_identity
      fi
      ;;
    3)
      read -r -p "Enter remote name (e.g. upstream): " rname
      read -r -p "Enter remote URL: " rurl
      if [[ -n "$rname" && -n "$rurl" ]]; then
        git remote add "$rname" "$rurl" && print_line "${GREEN}✅ Remote $rname added.${RESET}"
        prompt_and_configure_identity
      fi
      ;;
    4)
      smart_config_github
      ;;
    5)
      smart_config_bitbucket
      ;;
    6)
      prompt_and_configure_identity
      ;;
    7)
      local tname
      tname="$(select_remote "Select remote to test connectivity")"
      if [[ -n "$tname" ]]; then
        print_line "${CYAN}Testing connectivity to $tname...${RESET}"
        if git ls-remote "$tname" >/dev/null 2>&1; then
          print_line "${GREEN}✅ Connection successful! Remote '$tname' is reachable.${RESET}"
        else
          print_line "${RED}❌ Could not connect to remote '$tname'. Check network and credentials.${RESET}"
        fi
      fi
      ;;
    8)
      local del_r
      del_r="$(select_remote "Select remote to remove")"
      if [[ -n "$del_r" ]]; then
        if action_prompt "Remove remote '$del_r'?" "n"; then
          git remote remove "$del_r" && print_line "${GREEN}Remote '$del_r' removed.${RESET}"
        fi
      fi
      ;;
    0) ;;
    *) print_line "${YELLOW}Invalid option.${RESET}" ;;
  esac
}

# 23. Git Identity Configuration
configure_git_identity() {
  prompt_and_configure_identity
}

# 24. Repository Optimization & Cleanup
repo_optimization() {
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🧹 REPOSITORY OPTIMIZATION & CLEANUP${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  cat <<'EOF'
  1) Prune Stale Remote Branches (git remote prune origin)
  2) Run Git Garbage Collection & Optimization (git gc --prune=now)
  3) Check .git Folder Size
  0) Cancel
EOF
  read -r -p "${BOLD}Select optimization option [0-3]:${RESET} " optchoice
  case "$optchoice" in
    1)
      git remote prune "${REMOTE_NAME:-origin}" 2>/dev/null || true
      print_line "${GREEN}✅ Pruned stale tracking branches.${RESET}"
      ;;
    2)
      print_line "${CYAN}Optimizing repository database...${RESET}"
      git gc --prune=now --aggressive
      print_line "${GREEN}✅ Garbage collection complete.${RESET}"
      ;;
    3)
      du -sh .git 2>/dev/null || print_line "Cannot determine size."
      ;;
    0) ;;
    *) print_line "${YELLOW}Invalid option.${RESET}" ;;
  esac
}

# 25. Smart Tips & Cheatsheet
display_smart_tips() {
  print_line "${CYAN}╔════════════════════════════════════════════════════════════════════════════════════╗${RESET}"
  print_line "${CYAN}║${RESET}                         ${BOLD}💡 GIT BEST PRACTICES & PRO TIPS${RESET}                           ${CYAN}║${RESET}"
  print_line "${CYAN}╠════════════════════════════════════════════════════════════════════════════════════╣${RESET}"
  print_line "${CYAN}║${RESET} 1. ${BOLD}Commit Often, Polish Before Pushing${RESET}                                        ${CYAN}║${RESET}"
  print_line "${CYAN}║${RESET}    Make small, atomic commits for single logical units of work.                     ${CYAN}║${RESET}"
  print_line "${CYAN}║${RESET} 2. ${BOLD}Pull with Rebase${RESET}                                                           ${CYAN}║${RESET}"
  print_line "${CYAN}║${RESET}    Use 'git pull --rebase' to maintain a clean linear commit graph.                 ${CYAN}║${RESET}"
  print_line "${CYAN}║${RESET} 3. ${BOLD}Conventional Commit Format with Icons${RESET}                                      ${CYAN}║${RESET}"
  print_line "${CYAN}║${RESET}    '✨ feat', '🐛 fix', '📚 docs' makes history readable and changelogs easy.       ${CYAN}║${RESET}"
  print_line "${CYAN}║${RESET} 4. ${BOLD}Branch for Every Feature${RESET}                                                   ${CYAN}║${RESET}"
  print_line "${CYAN}║${RESET}    Keep master/main stable. Do development in feature/<name> or fix/<name>.         ${CYAN}║${RESET}"
  print_line "${CYAN}║${RESET} 5. ${BOLD}Safety Net: Git Reflog & Backtracking${RESET}                                      ${CYAN}║${RESET}"
  print_line "${CYAN}║${RESET}    Almost nothing is truly lost in Git. 'git reflog' can rescue lost commits.       ${CYAN}║${RESET}"
  print_line "${CYAN}╚════════════════════════════════════════════════════════════════════════════════════╝${RESET}"
}

# Branch Advice Assistant
show_branch_advice() {
  refresh_git_metrics
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  print_line "${BOLD}🌿 BRANCH RECOMMENDATION ASSISTANT${RESET}"
  print_line "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  local suggested="feature/improvement"
  if (( FILES_DELETED > 0 )); then
    suggested="refactor/cleanup"
  elif (( LINES_ADDED > 1500 || MODULES_AFFECTED >= 3 )); then
    suggested="feature/architecture-update"
  elif (( FILES_ADDED > 0 )); then
    suggested="feature/new-capabilities"
  fi

  print_line "Current Branch      : ${YELLOW}${CURRENT_BRANCH}${RESET}"
  print_line "Detected Workload   : ${UNCOMMITTED_FILES} files, ${MODULES_AFFECTED} modules, +${LINES_ADDED} lines"
  print_line "Recommended Branch  : ${GREEN}${BOLD}${suggested}${RESET}"
  printf '\n'
  if action_prompt "Create and switch to recommended branch '${suggested}' now?" "y"; then
    git switch -c "$suggested" 2>/dev/null || git checkout -b "$suggested"
  fi
}

# ------------------------------------------------------------------------------
# Main Menu & Interactive Event Loop
# ------------------------------------------------------------------------------

render_main_menu() {
  printf '%b\n' "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  printf '%b\n' "${CYAN}${BOLD}📌 MAIN MENU — SELECT AN ACTION${RESET}"
  printf '%b\n' "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  cat <<'EOF'
 🧭 GUIDED WORKFLOW:
  1) 🚀 Smart Workflow Guide       - Auto-detect state & execute recommended action

 📊 STATUS, DIFF & HEALTH:
  2) 📋 Detailed Repository Status - Complete status, tracking & commit details
  3) 🏥 Health & Diagnostic Report - Deep-dive score breakdown & fix advice
  4) 📝 View Changes (Diff)        - Inspect unstaged & staged differences

 📦 STAGING & WORKING TREE:
  5) ➕ Stage Changes (git add)    - Stage all, interactive stage, or pick from list
  6) ➖ Unstage Changes            - Safely unstage all or pick from staged list
  7) 🧹 Discard / Restore Changes  - Discard local modifications or clean untracked

 💾 COMMITS:
  8) ✨ Smart Commit (Icons)       - Auto-generate semantic message with icons
  9) 📝 Custom Commit              - Write your own custom commit message
 10) 🏗️  Conventional Commit Hub   - Guided builder (feat, fix, docs, refactor...)
 11) 🔄 Amend Last Commit          - Update last commit message or fold in staged files

 ☁️ REMOTE & SYNCHRONIZATION:
 12) ⬆️  Push Changes (Upload)     - Push branch, set upstream, push tags
 13) ⬇️  Pull & Fetch (Download)   - Fetch all, pull with rebase, or standard pull
 14) 🔄 Full Two-Way Sync         - 1-click safe sync (Fetch -> Pull -> Push)
 15) 🌐 Configure Remote & Identity - Smart config (GitHub/Bitbucket), remotes, name & email

 🌿 BRANCHES & MERGING:
 16) 🌿 Branch Manager             - Visual branch list, switch, delete & compare
 17) 🔀 Merge / Rebase Hub         - Merge or rebase branches (pick from list)
 18) 📈 Visual Branch Graph        - Interactive visual ASCII branch & commit tree
 19) 🗺️  Commit Navigation Graph   - Interactive TUI commit graph & inspector (Keifu)

 🏷️ TAGS, RELEASES & CHANGELOG:
 20) 🏷️  Version & Tag Manager     - SemVer version advice, create & push release tags
 21) 📄 Generate Changelog         - Create or update CHANGELOG.md automatically

 🗄️ STASH & SAFETY NET:
 22) 🗄️  Git Stash Manager         - Save work-in-progress, list, pop, apply, drop
 23) ⏪ Undo & Backtrack (Reset)   - Interactive commit timeline backtrack & reflog
 24) ⏹️  Abort Rebase / Merge       - Emergency cancel & go back to original state (rebase/merge --abort)

 ⚙️ SETTINGS & HELP:
 25) 👤 Git Identity Config       - Set user.name & user.email (local or global)
 26) 🧹 Repository Optimization    - Prune branches & run garbage collection (gc)
 27) 💡 Smart Tips & Cheatsheet    - Best practices, shortcuts & advice
 28) 📦 Offline Git & Portable Setup - Install Git offline (Win/Linux) or setup portable Git
  0) 🚪 Exit
EOF
  printf '%b\n' "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

interactive_main_loop() {
  require_git || exit 1
  ensure_repo || exit 1

  while true; do
    clear 2>/dev/null || true
    render_dashboard
    render_main_menu

    local choice=""
    read -r -p "$(printf '%b' "${BOLD}${CYAN}Select option [0-28, or A to Abort Rebase]:${RESET} ")" choice
    printf '\n'

    case "$choice" in
      1)  smart_workflow_guide ;;
      2)  show_detailed_status ;;
      3)  show_health_report ;;
      4)  inspect_changes_diff ;;
      5)  stage_changes_menu ;;
      6)  unstage_changes_menu ;;
      7)  discard_restore_menu ;;
      8)  smart_commit ;;
      9)  custom_commit ;;
      10) conventional_commit_builder ;;
      11) amend_commit_menu ;;
      12) push_changes_menu ;;
      13) pull_and_fetch_menu ;;
      14) full_two_way_sync ;;
      15) configure_remote_access ;;
      16) branch_manager ;;
      17) merge_rebase_hub ;;
      18) visual_branch_graph ;;
      19) commit_navigation_graph ;;
      20) show_version_recommendation ;;
      21) generate_changelog ;;
      22) stash_manager ;;
      23) undo_and_recovery_menu ;;
      24|[aA]|abort|ABORT) abort_rebase_or_merge ;;
      25) configure_git_identity ;;
      26) repo_optimization ;;
      27) display_smart_tips ;;
      28) offline_git_setup_hub ;;
      0)
        print_line ""
        print_line "${GREEN}🎉 Thank you for using Git Project Health Manager!${RESET}"
        print_line "${CYAN}Developed with excellence by ${BOLD}Degha Houssem Eddine${RESET}"
        print_line ""
        exit 0
        ;;
      *)
        print_line "${YELLOW}⚠️  Invalid option selection: '$choice'. Please choose a number from 0 to 28 (or 'A' to abort rebase).${RESET}"
        ;;
    esac

    press_any_key
  done
}

# ------------------------------------------------------------------------------
# Entry Point & CLI Subcommand Support
# ------------------------------------------------------------------------------

main() {
  if [[ $# -gt 0 ]]; then
    case "$1" in
      status)  show_detailed_status ;;
      health)  show_health_report ;;
      sync)    full_two_way_sync ;;
      commit)  smart_commit ;;
      push)    push_changes_menu ;;
      pull)    pull_and_fetch_menu ;;
      branch)  branch_manager ;;
      graph)   visual_branch_graph ;;
      keifu|nav|navigate) commit_navigation_graph ;;
      tag)     show_version_recommendation ;;
      abort)   abort_rebase_or_merge ;;
      help|-h|--help)
        print_header
        print_line "Usage: $0 [command]"
        print_line "Commands: status, health, sync, commit, push, pull, branch, graph, keifu, tag, abort, help"
        print_line "Run without arguments for full interactive dashboard."
        ;;
      *)
        interactive_main_loop
        ;;
    esac
  else
    interactive_main_loop
  fi
}

main "$@"
