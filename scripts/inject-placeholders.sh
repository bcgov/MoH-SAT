#!/usr/bin/env bash
# Replaces placeholders in metadata files with GitHub environment secret/variable values.
# Usage: VARS_JSON='<json of vars>' SECRETS_JSON='<json of secrets>' .github/scripts/inject-placeholders.sh [config-file]
# Lookup order for each name: secrets first, then variables. Values are never printed.
set -euo pipefail

CONFIG="${1:-.github/config/placeholders.conf}"
VARS_JSON="${VARS_JSON:-{\}}"
SECRETS_JSON="${SECRETS_JSON:-{\}}"

# Escape characters special to sed replacement text
escape() { printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'; }
trim() { local v="$1"; v="${v#"${v%%[![:space:]]*}"}"; printf "%s" "${v%"${v##*[![:space:]]}"}"; }
lookup() { jq -r --arg k "$1" '.[$k] // empty' <<<"$2"; }

while IFS='|' read -r file placeholder name; do
  [[ "$file" =~ ^[[:space:]]*(#|$) ]] && continue
  file=$(trim "$file"); placeholder=$(trim "$placeholder"); name=$(trim "$name")

  source="secrets"; value=$(lookup "$name" "$SECRETS_JSON")
  if [[ -z "$value" ]]; then source="vars"; value=$(lookup "$name" "$VARS_JSON"); fi

  [[ -z "$value" ]] && { echo "::error::'$name' is not defined as a secret or variable for this environment"; exit 1; }
  [[ -f "$file" ]] || { echo "::error::File not found: $file"; exit 1; }
  grep -q "$placeholder" "$file" || { echo "::error::Placeholder '$placeholder' not found in $file"; exit 1; }

  sed -i "s|${placeholder}|$(escape "$value")|g" "$file"
  grep -q "$placeholder" "$file" && { echo "::error::Placeholder '$placeholder' still present in $file"; exit 1; }
  echo "Replaced $placeholder in $file (from $source.$name)"
done < "$CONFIG"
