#!/usr/bin/env bash
#
# organize-repos.sh
# One-shot script to apply repo descriptions, topics, renames, and archiving
# for the MORAWA-dev GitHub account.
#
# USAGE:
#   1. Create a GitHub Personal Access Token (classic) with the "repo" scope:
#      https://github.com/settings/tokens
#   2. Run:  GITHUB_TOKEN=ghp_xxx bash organize-repos.sh
#
# The script is idempotent and safe to re-run. It only changes what you tell it to.
# Comment out any line you DON'T want applied.

set -euo pipefail

OWNER="MORAWA-dev"
API="https://api.github.com"

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "ERROR: set GITHUB_TOKEN first. Example:"
  echo "  GITHUB_TOKEN=ghp_xxx bash organize-repos.sh"
  exit 1
fi

AUTH=(-H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github+json")

# --- helper: update description ---
set_desc() {
  local repo="$1"; local desc="$2"
  echo "  -> description: $repo"
  curl -s -o /dev/null -X PATCH "${AUTH[@]}" "$API/repos/$OWNER/$repo" \
    -d "$(printf '{"description":"%s"}' "$desc")"
}

# --- helper: set topics (space-separated list) ---
set_topics() {
  local repo="$1"; shift
  local json_topics
  json_topics=$(printf '"%s",' "$@" | sed 's/,$//')
  echo "  -> topics: $repo [$*]"
  curl -s -o /dev/null -X PUT "${AUTH[@]}" \
    -H "Accept: application/vnd.github.mercy-preview+json" \
    "$API/repos/$OWNER/$repo/topics" \
    -d "{\"names\":[$json_topics]}"
}

# --- helper: rename repo ---
rename_repo() {
  local old="$1"; local new="$2"
  echo "  -> rename: $old -> $new"
  curl -s -o /dev/null -X PATCH "${AUTH[@]}" "$API/repos/$OWNER/$old" \
    -d "$(printf '{"name":"%s"}' "$new")"
}

# --- helper: archive repo ---
archive_repo() {
  local repo="$1"
  echo "  -> archive: $repo"
  curl -s -o /dev/null -X PATCH "${AUTH[@]}" "$API/repos/$OWNER/$repo" \
    -d '{"archived":true}'
}

echo "==> STEP 3a: Updating descriptions"
set_desc "MORAWA-dev.github.io" "Personal website and blog"
set_desc "yacou-portfolio" "Portfolio website built with HTML & CSS"
set_desc "hello-git" "First steps learning Git version control"
set_desc "NNN" "AI-generated wild news and conspiracy stories (satire app)"
set_desc "soil" "Soil Organic Matter (SOM) prediction workflows in R"
set_desc "soil_spec" "Vis-NIR soil spectroscopy models for soil property prediction (R)"
set_desc "soil_spec_som_pred" "Machine learning models for Soil Organic Matter prediction from spectral data"
set_desc "crewai_agents_stufss" "CrewAI multi-agent experiments: music, books, and travel recommendations"
set_desc "ai_studio_apps" "Collection of experimental web apps built with Google AI Studio"
set_desc "git-journey" "Learning Git: commands, workflows, and best practices"
set_desc "data_science_learning_journey" "Data science learning notebooks: statistics, ML, and visualization exercises"

echo "==> STEP 3b: Adding topics (searchable tags)"
set_topics "dakikobo" agriculture ai rag gemini burkina-faso
set_topics "mssl" soil-science spectroscopy vis-nir chemometrics r-language
set_topics "soil_spec" soil-science spectroscopy vis-nir r-language
set_topics "soil_spec_som_pred" soil-science machine-learning spectroscopy
set_topics "AgroHydrology-Hybrid-Model" hydrology machine-learning agriculture
set_topics "predictive-agriculture-model" agriculture machine-learning classification
set_topics "auto_read_me_generator" typescript developer-tools readme
set_topics "vibe_music_by_your_mood" typescript ai spotify web-app
set_topics "crewai_agents_stufss" ai-agents crewai llm

echo "==> STEP 3c: Renaming repos (GitHub auto-redirects old URLs)"
# Comment out any you want to keep as-is.
rename_repo "crewai_agents_stufss" "crewai-agents-experiments"
rename_repo "Birthday-card-designer-" "birthday-card-designer"
# rename_repo "soil" "soil-som-workflows"
# rename_repo "soil_spec" "soil-spectral-models"
# rename_repo "soil_spec_som_pred" "soil-som-prediction"
# rename_repo "NNN" "nnn-wild-news"

echo "==> STEP 4: Archiving completed learning repos (read-only, still visible)"
# Comment out any you DON'T want archived.
archive_repo "hello-git"
archive_repo "git-journey"
archive_repo "html-portfolio"
archive_repo "project-making-flag-of-burkina"

echo ""
echo "==> DONE. Note: if you renamed repos, update the links in your profile README,"
echo "    or just re-run the README generation. GitHub redirects old URLs automatically."
