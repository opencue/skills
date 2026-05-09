#!/usr/bin/env bash
# Snapshot the user's MCP server configuration from both Claude and Codex
# into mcps/. Writes:
#
#   mcps/claude-mcp-servers.json  ← from ~/.claude/settings.json (mcpServers)
#   mcps/codex-mcp-servers.json   ← from ~/.codex/config.toml ([mcp_servers.*])
#
# Recursively redacts any key whose name matches token/secret/password/api-key
# /auth-key/private-key/access-key/bearer so nothing sensitive lands in git.
#
# Idempotent: only writes if the sanitized payload would change. Silent on
# no-op. Best-effort: never blocks the session.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_dir="$repo_root/mcps"
plugins_dir="$repo_root/plugins"
mkdir -p "$target_dir" "$plugins_dir"

claude_source="${HOME}/.claude/settings.json"
claude_runtime_source="${HOME}/.claude.json"
codex_source="${HOME}/.codex/config.toml"
claude_target="$target_dir/claude-mcp-servers.json"
claude_runtime_target="$target_dir/claude-runtime-mcp-servers.json"
codex_target="$target_dir/codex-mcp-servers.json"

# ── Claude side (jq on JSON) ────────────────────────────────────────────
sync_claude() {
  [[ -f "$claude_source" ]] || return 0
  command -v jq >/dev/null 2>&1 || return 0

  local new_snapshot
  new_snapshot=$(
    jq -e '
      def redact:
        if type == "object" then
          with_entries(
            if (.key | ascii_downcase
                | test("token|secret|password|api[_-]?key|auth[_-]?key|private[_-]?key|access[_-]?key|bearer"))
            then .value = "<redacted>"
            else .value |= redact
            end
          )
        elif type == "array" then map(redact)
        else .
        end;
      {
        generated: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
        source: "~/.claude/settings.json",
        mcpServers: ((.mcpServers // {}) | redact)
      }
    ' "$claude_source" 2>/dev/null
  ) || return 0

  if [[ -f "$claude_target" ]]; then
    local old_payload new_payload
    old_payload=$(jq 'del(.generated)' "$claude_target" 2>/dev/null || echo '{}')
    new_payload=$(echo "$new_snapshot" | jq 'del(.generated)')
    [[ "$old_payload" == "$new_payload" ]] && return 0
  fi

  echo "$new_snapshot" > "$claude_target"
}

# ── Codex side (Python tomllib for TOML → sanitized JSON) ───────────────
sync_codex() {
  [[ -f "$codex_source" ]] || return 0
  command -v python3 >/dev/null 2>&1 || return 0

  local new_snapshot
  new_snapshot=$(python3 - "$codex_source" "$codex_target" <<'PY' 2>/dev/null
import json, re, sys, datetime, os, pathlib
try:
    import tomllib  # Python 3.11+
except ImportError:
    try:
        import tomli as tomllib  # back-port on 3.8–3.10
    except ImportError:
        sys.exit(0)

src = pathlib.Path(sys.argv[1])
dst = pathlib.Path(sys.argv[2])

SECRET_RE = re.compile(
    r"token|secret|password|api[_-]?key|auth[_-]?key|private[_-]?key|access[_-]?key|bearer",
    re.IGNORECASE,
)

def redact(obj):
    if isinstance(obj, dict):
        return {
            k: ("<redacted>" if SECRET_RE.search(k) else redact(v))
            for k, v in obj.items()
        }
    if isinstance(obj, list):
        return [redact(x) for x in obj]
    return obj

try:
    data = tomllib.loads(src.read_text())
except Exception:
    sys.exit(0)

mcps = redact(data.get("mcp_servers", {}))

payload = {
    "generated": datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
    "source": "~/.codex/config.toml",
    "mcpServers": mcps,
}

# Skip write if existing payload (minus timestamp) matches
if dst.exists():
    try:
        prev = json.loads(dst.read_text())
        prev.pop("generated", None)
        compare = dict(payload); compare.pop("generated", None)
        if prev == compare:
            sys.exit(0)
    except Exception:
        pass

print(json.dumps(payload, indent=2, sort_keys=False))
PY
  ) || return 0

  # Empty stdout = no-op (script exited 0 without writing)
  [[ -z "$new_snapshot" ]] && return 0
  echo "$new_snapshot" > "$codex_target"
}

sync_claude_runtime() {
  [[ -f "$claude_runtime_source" ]] || return 0
  command -v jq >/dev/null 2>&1 || return 0

  local new_snapshot
  new_snapshot=$(
    jq -e '
      def redact:
        if type == "object" then
          with_entries(
            if (.key | ascii_downcase
                | test("token|secret|password|api[_-]?key|auth[_-]?key|private[_-]?key|access[_-]?key|bearer"))
            then .value = "<redacted>"
            else .value |= redact
            end
          )
        elif type == "array" then map(redact)
        else .
        end;
      {
        generated: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
        source: "~/.claude.json",
        mcpServers: ((.mcpServers // {}) | redact),
        projects: ((.projects // {}) | with_entries(
          .value = (.value.mcpServers // {} | redact)
        ) | with_entries(select(.value != {})))
      }
    ' "$claude_runtime_source" 2>/dev/null
  ) || return 0

  if [[ -f "$claude_runtime_target" ]]; then
    local old_payload new_payload
    old_payload=$(jq 'del(.generated)' "$claude_runtime_target" 2>/dev/null || echo '{}')
    new_payload=$(echo "$new_snapshot" | jq 'del(.generated)')
    [[ "$old_payload" == "$new_payload" ]] && return 0
  fi

  echo "$new_snapshot" > "$claude_runtime_target"
}

sync_claude
sync_claude_runtime
sync_codex

sync_plugins() {
  [[ -f "$claude_source" ]] || return 0
  command -v jq >/dev/null 2>&1 || return 0
  command -v python3 >/dev/null 2>&1 || return 0

  local cache_root="${HOME}/.claude/plugins/cache"
  local target_file="$plugins_dir/plugins.sanitized.json"

  local new_snapshot
  new_snapshot=$(python3 - "$claude_source" "$cache_root" <<'PY' 2>/dev/null
import json, re, sys, datetime
from pathlib import Path

settings_path = Path(sys.argv[1])
cache_root = Path(sys.argv[2])

SECRET_RE = re.compile(r"token|secret|password|api[_-]?key|auth[_-]?key|private[_-]?key|access[_-]?key|bearer", re.I)

def redact(obj):
    if isinstance(obj, dict):
        return {k: ("<redacted>" if SECRET_RE.search(k) else redact(v)) for k, v in obj.items()}
    if isinstance(obj, list):
        return [redact(x) for x in obj]
    return obj

try:
    settings = json.loads(settings_path.read_text())
except Exception:
    sys.exit(0)

enabled = settings.get("enabledPlugins") or {}
marketplaces = redact(settings.get("extraKnownMarketplaces") or {})

def latest_version(plugin_root: Path):
    if not plugin_root.is_dir():
        return None
    versions = sorted((p for p in plugin_root.iterdir() if p.is_dir()), key=lambda p: p.stat().st_mtime, reverse=True)
    return versions[0] if versions else None

def read_servers(version_dir: Path):
    inline = version_dir / ".mcp.json"
    if inline.exists():
        try:
            return redact((json.loads(inline.read_text()).get("mcpServers") or {}))
        except Exception:
            return {}
    manifest = version_dir / ".claude-plugin" / "plugin.json"
    if manifest.exists():
        try:
            data = json.loads(manifest.read_text())
            ref = data.get("mcpServers")
            if isinstance(ref, str):
                ref_path = (version_dir / ref).resolve()
                if ref_path.exists():
                    return redact((json.loads(ref_path.read_text()).get("mcpServers") or {}))
            elif isinstance(ref, dict):
                return redact(ref)
        except Exception:
            pass
    return {}

plugins = {}
for plugin_id, is_enabled in sorted(enabled.items()):
    name, _, marketplace = plugin_id.partition("@")
    if not marketplace:
        marketplace = "builtin"
    entry = {"name": name, "marketplace": marketplace, "enabled": bool(is_enabled)}
    version_dir = latest_version(cache_root / marketplace / name)
    if version_dir is not None:
        entry["version"] = version_dir.name
        entry["mcpServers"] = read_servers(version_dir)
    plugins[plugin_id] = entry

print(json.dumps({
    "generated": datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
    "source": "~/.claude/settings.json#enabledPlugins + ~/.claude/plugins/cache/",
    "marketplaces": marketplaces,
    "plugins": plugins,
}, indent=2, sort_keys=True))
PY
  ) || return 0

  [[ -z "$new_snapshot" ]] && return 0

  if [[ -f "$target_file" ]]; then
    local old_payload new_payload
    old_payload=$(jq 'del(.generated)' "$target_file" 2>/dev/null || echo '{}')
    new_payload=$(echo "$new_snapshot" | jq 'del(.generated)')
    [[ "$old_payload" == "$new_payload" ]] && return 0
  fi

  echo "$new_snapshot" > "$target_file"
}

sync_plugins
