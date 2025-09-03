#!/usr/bin/env bash
set -euo pipefail

##!/bin/sh
#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

# Colors
red="\033[01;31m"; yellow="\033[01;33m"; green="\033[01;32m"; nc="\033[00m"

usage() {
  echo -e "${yellow}Usage:${nc} $0 [projects_path] <repo> [private=true|false]"
  echo -e "Examples:"
  echo -e "  $0 cleancodeExercise"
  echo -e "  $0 cleancodeExercise true"
  echo -e "  $0 /c/temp cleancodeExercise"
  echo -e "  $0 /c/temp cleancodeExercise true"
  exit 1
}

# Load environment variables from .env file
load_env() {
    if [ -f ".env" ]; then
        export $(grep -v '^#' ".env" | xargs)
    fi
}

load_env

# --- Defaults ---
DEFAULT_PROJECTS_PATH="/f/IdeaProjects"
DEFAULT_USERNAME="CesarChaMal"
GITHUB_API="https://api.github.com/user/repos"

# --- Argument parsing: [projects_path] <repo> [private] ---
if [[ $# -lt 1 ]]; then usage; fi

if [[ -d "${1:-}" || "${1:-}" == */ ]]; then
  # First arg is a path -> [projects_path] <repo> [private]
  projects_path="$1"
  repo="${2:-}"; [[ -n "${repo}" ]] || usage
  private="${3:-false}"
else
  # First arg is repo -> <repo> [private]
  projects_path="${PROJECTS_PATH:-$DEFAULT_PROJECTS_PATH}"
  repo="$1"
  private="${2:-false}"
fi

# --- Env-first secrets (from .env file) ---
username="${GITHUB_USERNAME:-$DEFAULT_USERNAME}"
token="${GITHUB_API_TOKEN}"

if [ -z "$token" ]; then
    echo -e "${red}Error: GITHUB_API_TOKEN not found in .env file${nc}"
    echo -e "Please add GITHUB_API_TOKEN=your_token_here to your .env file"
    exit 1
fi

# --- Validate 'private' flag ---
case "$private" in
  true|false) ;;
  *) echo -e "${red}Invalid 'private' value: ${private}. Use 'true' or 'false'.${nc}"; exit 1 ;;
esac

# --- Derived ---
project_directory="${projects_path%/}/${repo}"
url="git@github.com:${username}/${repo}.git"

# --- Check if GitHub repo already exists ---
echo -e "Checking if GitHub repo ${yellow}${repo}${nc} already exists..."
check_status=0
check_resp=$(curl -sS -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer ${token}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${username}/${repo}") || check_status=$?

if [[ $check_status -ne 0 ]]; then
  echo -e "${red}Failed to check GitHub API (network error).${nc}"
  exit 1
elif [[ "$check_resp" == "200" ]]; then
  echo -e "${red}Error: Repository '${repo}' already exists on GitHub.${nc}"
  echo -e "${yellow}Repository URL: https://github.com/${username}/${repo}${nc}"
  echo -e "${yellow}Please choose a different name or delete the existing repository.${nc}"
  exit 1
elif [[ "$check_resp" == "404" ]]; then
  echo -e "${green}Repository '${repo}' does not exist. Proceeding with creation...${nc}"
else
  echo -e "${yellow}GitHub API returned HTTP ${check_resp}. Proceeding anyway...${nc}"
fi

# --- Echo context (never print the token) ---
echo -e "Repo: ${yellow}${repo}${nc}"
echo -e "Private: ${yellow}${private}${nc}"
echo -e "Projects path: ${yellow}${projects_path}${nc}"
echo -e "Git SSH URL: ${yellow}${url}${nc}"
echo -e "GitHub API: ${yellow}${GITHUB_API}${nc}\n"

# --- Ensure dir ---
if [[ ! -d "$project_directory" ]]; then
  mkdir -p "$project_directory"
  echo -e "Created directory ${green}${project_directory}${nc}"
else
  echo -e "Directory ${yellow}${project_directory}${nc} already exists."
fi

cd "$project_directory"

# --- Init or reuse git repo ---
if [[ ! -d ".git" ]]; then
  git init
  echo -e "Initialized git repo in ${green}${project_directory}/.git${nc}"
else
  echo -e "Existing git repository detected."
fi

# --- Ensure README exists on first init (keep your original behavior) ---
if [[ ! -f "README.md" ]]; then
  echo "# ${repo}" > README.md
  git add README.md
  git commit -m "Initial commit with README" >/dev/null 2>&1 || true
  echo "Created and committed README.md"
else
  echo "README.md already exists."
fi

# (Optional: keep your original 'cat README.md')
if [[ -f "README.md" ]]; then
  cat README.md
fi

# --- Create or update remote 'origin' (keep your logic) ---
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "${url}"
  echo -e "Updated remote origin to ${yellow}${url}${nc}"
else
  git remote add origin "${url}"
  echo -e "Added remote origin ${yellow}${url}${nc}"
fi

# --- Create repo on GitHub (idempotent-ish) with jq fallback (kept) ---
create_payload=$(jq -c -n \
  --arg name "$repo" \
  --arg desc "$repo" \
  --argjson private $([[ "$private" == "true" ]] && echo true || echo false) \
  '{name:$name, description:$desc, private:$private}' 2>/dev/null || true)

if [[ -z "${create_payload:-}" ]]; then
  create_payload="{\"name\":\"${repo}\",\"description\":\"${repo}\",\"private\":${private}}"
fi

echo -e "Ensuring GitHub repo exists (private=${yellow}${private}${nc})..."
create_status=0
create_resp=$(curl -sS -o /tmp/gh_create_resp.json -w "%{http_code}" \
  -H "Authorization: Bearer ${token}" \
  -H "Accept: application/vnd.github+json" \
  -d "${create_payload}" \
  "${GITHUB_API}") || create_status=$?

if [[ $create_status -ne 0 ]]; then
  echo -e "${red}Failed calling GitHub API (network error).${nc}"
elif [[ "$create_resp" == "201" ]]; then
  echo -e "${green}GitHub repo created.${nc}"
elif [[ "$create_resp" == "422" ]]; then
  echo -e "${yellow}GitHub repo likely already exists. Continuing...${nc}"
else
  echo -e "${yellow}GitHub API returned HTTP ${create_resp}. Continuing...${nc}"
fi

# --- Add/commit changes if any (kept your flow, just avoids empty commits) ---
git add -A
if ! git diff --cached --quiet; then
  git commit -m "Upload code for ${repo} project." || true
  echo "Committed pending changes."
else
  echo "No changes to commit."
fi

# --- Push main (kept) ---
git branch -M main
git push -u origin main

echo -e "${green}Repository setup and push completed.${nc}"
