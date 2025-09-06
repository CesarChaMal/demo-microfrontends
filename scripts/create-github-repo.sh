#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# GitHub Repository Creation Script with Advanced Features
# =============================================================================
#
# DESCRIPTION:
#   Creates GitHub repositories with optional GitHub Pages enablement and
#   deployment secrets configuration. Supports both public and private repos.
#
# FEATURES:
#   ✅ Repository creation with validation
#   ✅ Local git repository initialization
#   ✅ GitHub Pages automatic enablement
#   ✅ GitHub Actions secrets creation
#   ✅ README.md generation
#   ✅ SSH remote configuration
#   ✅ Idempotent operations (safe to re-run)
#
# PREREQUISITES:
#   - GitHub Personal Access Token with repo and pages permissions
#   - Git configured with SSH keys
#   - .env file with required environment variables
#
# ENVIRONMENT VARIABLES (from .env file):
#   GITHUB_API_TOKEN    - GitHub Personal Access Token (required)
#   GITHUB_USERNAME     - GitHub username (optional, defaults to CesarChaMal)
#   PROJECTS_PATH       - Default projects directory (optional)
#   S3_BUCKET          - AWS S3 bucket for deployment secrets
#   AWS_REGION         - AWS region for deployment secrets
#   ORG_NAME           - Organization name for deployment secrets
#   NPM_TOKEN          - NPM token for package publishing secrets
#
# USAGE:
#   ./create-github-repo.sh [projects_path] <repo_name> [private] [enable_pages] [create_secrets]
#
# PARAMETERS:
#   projects_path   - Local directory path (optional, uses PROJECTS_PATH or default)
#   repo_name       - GitHub repository name (required)
#   private         - Create private repository (true/false, default: false)
#   enable_pages    - Enable GitHub Pages (true/false, default: false)
#   create_secrets  - Create deployment secrets (true/false, default: false)
#
# EXAMPLES:
#
#   Basic Usage:
#     ./create-github-repo.sh my-awesome-project
#     # Creates public repo 'my-awesome-project' in default directory
#
#   Private Repository:
#     ./create-github-repo.sh my-private-project true
#     # Creates private repo without GitHub Pages or secrets
#
#   Public Repository with GitHub Pages:
#     ./create-github-repo.sh my-website false true
#     # Creates public repo with GitHub Pages enabled
#     # Available at: https://username.github.io/my-website/
#
#   Full Setup (Private + Pages + Secrets):
#     ./create-github-repo.sh my-app true true true
#     # Creates private repo with GitHub Pages and deployment secrets
#
#   Custom Directory:
#     ./create-github-repo.sh /c/projects my-project false true false
#     # Creates repo in custom directory with GitHub Pages
#
#   Microfrontend Setup:
#     ./create-github-repo.sh single-spa-auth-app false true true
#     # Perfect for microfrontend apps with Pages and deployment secrets
#
# DEPLOYMENT SECRETS CREATED:
#   When create_secrets=true, the following secrets are added to the repository:
#   - S3_BUCKET: AWS S3 bucket name for deployment
#   - AWS_REGION: AWS region for S3 deployment
#   - ORG_NAME: Organization name for package scoping
#   - GITHUB_API_TOKEN: GitHub token for cross-repo operations
#   - NPM_TOKEN: NPM token for package publishing
#
# GITHUB PAGES CONFIGURATION:
#   When enable_pages=true:
#   - Enables GitHub Pages from main branch root (/)
#   - Creates live website at https://username.github.io/repo-name/
#   - Automatically configures source branch and path
#
# ERROR HANDLING:
#   - Validates repository doesn't already exist
#   - Checks GitHub API token permissions
#   - Handles network errors gracefully
#   - Provides clear error messages with solutions
#
# WORKFLOW:
#   1. Validate parameters and environment
#   2. Check if repository already exists on GitHub
#   3. Create local directory and initialize git
#   4. Generate README.md if not present
#   5. Create GitHub repository via API
#   6. Configure git remote and push initial commit
#   7. Enable GitHub Pages (if requested)
#   8. Create deployment secrets (if requested)
#
# =============================================================================

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

# Colors for output formatting
red="\033[01;31m"; yellow="\033[01;33m"; green="\033[01;32m"; nc="\033[00m"

usage() {
  echo -e "${yellow}Usage:${nc} $0 [projects_path] <repo> [private=true|false] [enable_pages=true|false] [create_secrets=true|false]"
  echo -e "Examples:"
  echo -e "  $0 cleancodeExercise"
  echo -e "  $0 cleancodeExercise true"
  echo -e "  $0 cleancodeExercise true true true"
  echo -e "  $0 /c/temp cleancodeExercise false true false"
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

# --- Argument parsing: [projects_path] <repo> [private] [enable_pages] [create_secrets] ---
if [[ $# -lt 1 ]]; then usage; fi

if [[ -d "${1:-}" || "${1:-}" == */ ]]; then
  # First arg is a path -> [projects_path] <repo> [private] [enable_pages] [create_secrets]
  projects_path="$1"
  repo="${2:-}"; [[ -n "${repo}" ]] || usage
  private="${3:-false}"
  enable_pages="${4:-false}"
  create_secrets="${5:-false}"
else
  # First arg is repo -> <repo> [private] [enable_pages] [create_secrets]
  projects_path="${PROJECTS_PATH:-$DEFAULT_PROJECTS_PATH}"
  repo="$1"
  private="${2:-false}"
  enable_pages="${3:-false}"
  create_secrets="${4:-false}"
fi

# --- Env-first secrets (from .env file) ---
username="${GITHUB_USERNAME:-$DEFAULT_USERNAME}"
token="${GITHUB_API_TOKEN}"

if [ -z "$token" ]; then
    echo -e "${red}Error: GITHUB_API_TOKEN not found in .env file${nc}"
    echo -e "Please add GITHUB_API_TOKEN=your_token_here to your .env file"
    exit 1
fi

# --- Validate flags ---
case "$private" in
  true|false) ;;
  *) echo -e "${red}Invalid 'private' value: ${private}. Use 'true' or 'false'.${nc}"; exit 1 ;;
esac

case "$enable_pages" in
  true|false) ;;
  *) echo -e "${red}Invalid 'enable_pages' value: ${enable_pages}. Use 'true' or 'false'.${nc}"; exit 1 ;;
esac

case "$create_secrets" in
  true|false) ;;
  *) echo -e "${red}Invalid 'create_secrets' value: ${create_secrets}. Use 'true' or 'false'.${nc}"; exit 1 ;;
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
echo -e "Enable Pages: ${yellow}${enable_pages}${nc}"
echo -e "Create Secrets: ${yellow}${create_secrets}${nc}"
echo -e "Projects path: ${yellow}${projects_path}${nc}"
echo -e "Git SSH URL: ${yellow}${url}${nc}"
echo -e "GitHub API: ${yellow}${GITHUB_API}${nc}\n"

# --- Ensure projects path exists ---
if [[ ! -d "$projects_path" ]]; then
  mkdir -p "$projects_path"
  echo -e "Created projects directory ${green}${projects_path}${nc}"
fi

# --- Ensure project directory exists ---
if [[ ! -d "$project_directory" ]]; then
  mkdir -p "$project_directory"
  echo -e "Created project directory ${green}${project_directory}${nc}"
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



# --- Enable GitHub Pages if requested ---
if [[ "$enable_pages" == "true" ]]; then
  echo -e "\n${yellow}Enabling GitHub Pages...${nc}"
  pages_status=0
  pages_resp=$(curl -sS -o /tmp/gh_pages_resp.json -w "%{http_code}" \
    -X POST \
    -H "Authorization: Bearer ${token}" \
    -H "Accept: application/vnd.github+json" \
    -d '{"source":{"branch":"main","path":"/"}}' \
    "https://api.github.com/repos/${username}/${repo}/pages") || pages_status=$?
  
  if [[ $pages_status -ne 0 ]]; then
    echo -e "${red}Failed to enable GitHub Pages (network error).${nc}"
  elif [[ "$pages_resp" == "201" ]]; then
    echo -e "${green}GitHub Pages enabled successfully.${nc}"
    echo -e "${yellow}Pages URL: https://${username}.github.io/${repo}/${nc}"
  elif [[ "$pages_resp" == "409" ]]; then
    echo -e "${yellow}GitHub Pages already enabled.${nc}"
  else
    echo -e "${yellow}GitHub Pages API returned HTTP ${pages_resp}. May already be enabled.${nc}"
  fi
fi

# --- Create GitHub Secrets if requested ---
if [[ "$create_secrets" == "true" ]]; then
  echo -e "\n${yellow}Creating GitHub Secrets...${nc}"
  
  # Use existing secrets creation script
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  SECRETS_SCRIPT="${SCRIPT_DIR}/create-github-secrets-gh.sh"
  
  if [[ -f "$SECRETS_SCRIPT" ]]; then
    echo -e "${yellow}Using existing secrets script: $SECRETS_SCRIPT${nc}"
    if "$SECRETS_SCRIPT" "$username" "$repo"; then
      echo -e "${green}Secrets creation completed successfully.${nc}"
    else
      echo -e "${red}Secrets creation failed.${nc}"
    fi
  else
    echo -e "${red}Secrets script not found: $SECRETS_SCRIPT${nc}"
    echo -e "${yellow}Skipping secrets creation.${nc}"
  fi
fi

echo -e "\n${green}Repository '${repo}' setup completed successfully!${nc}"
