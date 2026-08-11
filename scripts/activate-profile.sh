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
const repoRoot = path.dirname(skillsRoot);

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

const byId = new Map();
const byName = new Map();
const bySlug = new Map();
for (const skillDir of walk(skillsRoot)) {
  const id = path.relative(skillsRoot, skillDir).split(path.sep).join("/");
  const slug = path.basename(skillDir);
  const skillText = fs.readFileSync(path.join(skillDir, "SKILL.md"), "utf8");
  const nameMatch = skillText.match(/^name:\s*["']?([^"'\n]+)["']?\s*$/m);
  const name = nameMatch ? nameMatch[1].trim() : slug;
  const record = { id, name, slug, skillDir };
  byId.set(id, record);
  if (byName.has(name)) fail(`Duplicate skill name: ${name}`);
  byName.set(name, record);
  const matches = bySlug.get(slug) || [];
  matches.push(record);
  bySlug.set(slug, matches);
}

let aliases = {};
const aliasesFile = path.join(repoRoot, "catalog", "aliases.json");
if (fs.existsSync(aliasesFile)) {
  aliases = JSON.parse(fs.readFileSync(aliasesFile, "utf8")).aliases || {};
}

function resolveSkill(value) {
  const canonical = aliases[value] || value;
  if (byId.has(canonical)) return byId.get(canonical);
  if (byName.has(canonical)) return byName.get(canonical);
  const slugMatches = bySlug.get(canonical) || [];
  if (slugMatches.length === 1) return slugMatches[0];
  if (slugMatches.length > 1) {
    fail(`Ambiguous skill "${value}"; use one of: ${slugMatches.map(x => x.id).join(", ")}`);
  }
  fail(`Unknown skill: ${value}`);
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
      names.push(...[...byId.keys()].sort((a, b) => a.localeCompare(b)));
    } else if (typeof item === "string" && item.startsWith("category:")) {
      const category = item.slice("category:".length);
      for (const [id] of byId) {
        if (id.split("/")[0] === category) names.push(id);
      }
    } else if (typeof item === "string") {
      names.push(resolveSkill(item).id);
    }
  }

  return names;
}

const seen = new Set();
for (const id of loadProfile(profileName)) {
  if (seen.has(id)) continue;
  seen.add(id);
  const record = resolveSkill(id);
  process.stdout.write(`${record.name}\t${record.skillDir}\n`);
}
NODE
then
  exit 1
fi

mapfile -t entries < "$entries_file"

mkdir -p "$target"

# Refuse to hide or nest inside user-managed skill directories. Migration
# prompts can import these first, then ask the user before moving originals.
conflicts=0
for entry in "${entries[@]}"; do
  name="${entry%%$'\t'*}"
  skill_dir="${entry#*$'\t'}"
  destination="$target/$name"
  [ -e "$destination" ] || [ -L "$destination" ] || continue
  resolved="$(readlink -f "$destination" || true)"
  case "$resolved" in
    "$skill_dir"|"$skills_root"/*) ;;
    *)
      echo "Refusing to replace user-managed skill: $destination" >&2
      conflicts=$((conflicts + 1))
      ;;
  esac
done
if [ "$conflicts" -gt 0 ]; then
  echo "Move or archive the conflicting paths, then rerun activation." >&2
  exit 1
fi

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
