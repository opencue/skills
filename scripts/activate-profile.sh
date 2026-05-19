#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: activate-profile.sh [--profile NAME] [--agent codex|claude] [--target DIR] [--list]

Build a runtime skills directory from Soul profile JSON.

Defaults:
  --profile  ${SOUL_SKILL_PROFILE:-all}
  --agent    codex
  --target   Codex: ${CODEX_HOME:-$HOME/.codex}/skills
             Claude: ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
skills_root="$repo_root/skills"
profiles_root="$repo_root/profiles"

profile="${SOUL_SKILL_PROFILE:-all}"
agent="codex"
target=""
list_only=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      profile="${2:?missing profile name}"
      shift 2
      ;;
    --agent)
      agent="${2:?missing agent name}"
      shift 2
      ;;
    --target)
      target="${2:?missing target dir}"
      shift 2
      ;;
    --list)
      list_only=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$target" ]]; then
  case "$agent" in
    codex)
      target="${CODEX_HOME:-$HOME/.codex}/skills"
      ;;
    claude)
      target="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
      ;;
    *)
      echo "Unsupported agent: $agent" >&2
      exit 2
      ;;
  esac
fi

if [[ "$list_only" -eq 1 ]]; then
  find "$profiles_root" -maxdepth 1 -type f -name '*.json' -printf '%f\n' \
    | sed 's/\.json$//' \
    | sort
  exit 0
fi

entries_file="$(mktemp)"
trap 'rm -f "$entries_file"' EXIT

if ! SOUL_SKILLS_ROOT="$skills_root" \
  SOUL_PROFILES_ROOT="$profiles_root" \
  SOUL_PROFILE="$profile" \
  node >"$entries_file" <<'NODE'
const fs = require("node:fs");
const path = require("node:path");

const skillsRoot = process.env.SOUL_SKILLS_ROOT;
const profilesRoot = process.env.SOUL_PROFILES_ROOT;
const profileName = process.env.SOUL_PROFILE;

function fail(message) {
  process.stderr.write(`${message}\n`);
  process.exit(1);
}

function walk(dir, out = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full, out);
    else if (entry.isFile() && entry.name === "SKILL.md") out.push(path.dirname(full));
  }
  return out;
}

const catalog = new Map();
for (const skillDir of walk(skillsRoot)) {
  catalog.set(path.basename(skillDir), skillDir);
}

function loadProfile(name, stack = []) {
  if (stack.includes(name)) {
    fail(`Profile cycle: ${[...stack, name].join(" -> ")}`);
  }

  const file = path.join(profilesRoot, `${name}.json`);
  if (!fs.existsSync(file)) {
    fail(`Unknown skill profile: ${name}`);
  }

  const parsed = JSON.parse(fs.readFileSync(file, "utf8"));
  const names = [];

  for (const parent of parsed.extends || []) {
    names.push(...loadProfile(parent, [...stack, name]));
  }

  for (const item of parsed.include || []) {
    if (item === "*") {
      names.push(...[...catalog.keys()].sort((a, b) => a.localeCompare(b)));
    } else if (typeof item === "string" && item.startsWith("category:")) {
      const category = item.slice("category:".length);
      for (const [skill, skillDir] of catalog) {
        const relative = path.relative(skillsRoot, skillDir).split(path.sep);
        if (relative[0] === category) names.push(skill);
      }
    } else if (typeof item === "string") {
      names.push(item);
    }
  }

  return names;
}

const seen = new Set();
for (const name of loadProfile(profileName)) {
  if (seen.has(name)) continue;
  seen.add(name);
  const skillDir = catalog.get(name);
  if (!skillDir) fail(`Profile "${profileName}" references missing skill: ${name}`);
  process.stdout.write(`${name}\t${skillDir}\n`);
}
NODE
then
  exit 1
fi

mapfile -t entries < "$entries_file"

mkdir -p "$target"

# Remove only old Soul-managed symlinks. Preserve non-Soul skills and real dirs.
while IFS= read -r -d '' link; do
  resolved="$(readlink -f "$link" || true)"
  case "$resolved" in
    "$skills_root"/*)
      rm -f "$link"
      ;;
  esac
done < <(find "$target" -mindepth 1 -maxdepth 1 -type l -print0)

count=0
for entry in "${entries[@]}"; do
  name="${entry%%$'\t'*}"
  skill_dir="${entry#*$'\t'}"
  ln -sfn "$skill_dir" "$target/$name"
  count=$((count + 1))
done

printf 'profile=%s agent=%s target=%s skills=%s\n' "$profile" "$agent" "$target" "$count"
