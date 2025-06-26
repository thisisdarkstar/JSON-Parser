#!/usr/bin/env bash
#
# JSON Parser in Pure Bash
# ------------------------
# Extract values from JSON files using simple query paths, with no external dependencies.
#
# Author:      Darkstar thisisdarkstar@duck.com
# Repository:  https://github.com/thisisdarkstar/JSON-Parser.git
# License:     MIT
# Version:     1.0.0
# Date:        2025-06-25
#
# Usage:       ./json_parser.sh <json-file> '<query>'
#
# Description:
#   - Parses JSON objects and arrays
#   - Supports dot/bracket notation (e.g., data.users[0].name)
#   - Supports wildcards for arrays (e.g., data.users[*])
#   - Returns null for non-existent paths
#   - No dependencies except

# Minify JSON by removing unnecessary whitespace (while keeping strings intact)
minify_json() {
  local in_str=0 esc=0 char result=""
  while IFS= read -r -n1 char; do
    if (( esc )); then
      result+="$char"
      esc=0
      continue
    fi
    case "$char" in
      \\) esc=1 ;;
      \") ((in_str = 1 - in_str)) ;;
    esac
    if (( in_str )) || [[ ! "$char" =~ [[:space:]] ]]; then
      result+="$char"
    fi
  done < "$1"
  echo "$result"
}

# Recursively flatten JSON into key=value pairs
flatten_json() {
  local json="$1" path="$2"
  case "$json" in
    \{*)
      local content="${json:1:${#json}-2}"
      while [[ -n "$content" ]]; do
        [[ "$content" =~ ^\"([^\"]+)\": ]] || { echo "Error parsing key: $content" >&2; return 1; }
        local key="${BASH_REMATCH[1]}"
        content="${content#\"$key\":}"
        content="$(echo "$content" | sed -E 's/^[[:space:]]+//')"

        if [[ "$content" =~ ^\"([^\"]*)\" ]]; then
          local val="${BASH_REMATCH[1]}"
          echo "$path$key=\"$val\""
          content="${content#\"$val\"}"
        elif [[ "$content" =~ ^\{ ]]; then
          local brace=1 idx=1
          while (( brace > 0 && idx < ${#content} )); do
            local c="${content:$idx:1}"
            [[ "$c" == '{' ]] && ((brace++))
            [[ "$c" == '}' ]] && ((brace--))
            ((idx++))
          done
          flatten_json "${content:0:$idx}" "$path$key."
          content="${content:$idx}"
        elif [[ "$content" =~ ^\[ ]]; then
          local bracket=1 idx=1
          while (( bracket > 0 && idx < ${#content} )); do
            local c="${content:$idx:1}"
            [[ "$c" == '[' ]] && ((bracket++))
            [[ "$c" == ']' ]] && ((bracket--))
            ((idx++))
          done
          echo "$path$key=${content:0:$idx}"
          flatten_json "${content:0:$idx}" "$path$key"
          content="${content:$idx}"
        elif [[ "$content" =~ ^(true|false|null|[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?) ]]; then
          local val="${BASH_REMATCH[1]}"
          echo "$path$key=$val"
          content="${content#$val}"
        else
          echo "Error parsing object value for $key: $content" >&2
          return 1
        fi
        [[ "$content" =~ ^, ]] && content="${content:1}"
      done
      ;;
    \[*)
      local content="${json:1:${#json}-2}" i=0
      while [[ -n "$content" ]]; do
        content="$(echo "$content" | sed -E 's/^[[:space:]]+//')"
        if [[ "$content" =~ ^\"([^\"]*)\" ]]; then
          local val="${BASH_REMATCH[1]}"
          echo "$path[$i]=\"$val\""
          content="${content#\"$val\"}"
        elif [[ "$content" =~ ^\{ ]]; then
          local brace=1 idx=1
          while (( brace > 0 && idx < ${#content} )); do
            local c="${content:$idx:1}"
            [[ "$c" == '{' ]] && ((brace++))
            [[ "$c" == '}' ]] && ((brace--))
            ((idx++))
          done
          echo "$path[$i]=${content:0:$idx}"
          flatten_json "${content:0:$idx}" "$path[$i]."
          content="${content:$idx}"
        elif [[ "$content" =~ ^\[ ]]; then
          local bracket=1 idx=1
          while (( bracket > 0 && idx < ${#content} )); do
            local c="${content:$idx:1}"
            [[ "$c" == '[' ]] && ((bracket++))
            [[ "$c" == ']' ]] && ((bracket--))
            ((idx++))
          done
          echo "$path[$i]=${content:0:$idx}"
          flatten_json "${content:0:$idx}" "$path[$i]"
          content="${content:$idx}"
        elif [[ "$content" =~ ^(true|false|null|[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?) ]]; then
          local val="${BASH_REMATCH[1]}"
          echo "$path[$i]=$val"
          content="${content#$val}"
        else
          echo "Error parsing array value at [$i]: $content" >&2
          return 1
        fi
        [[ "$content" =~ ^, ]] && content="${content:1}"
        ((i++))
      done
      ;;
  esac
}

# === Entry Point ===

file="$1"
query="$2"

if [[ ! -f "$file" || -z "$query" ]]; then
  echo "Usage: $0 <json-file> '<query.path[0].key|query.path[*]>'"
  exit 1
fi

json=$(minify_json "$file")
declare -A kv_map

while IFS='=' read -r k v; do
  kv_map["$k"]="$v"
done < <(flatten_json "$json" "")

# === Query Logic ===
if [[ "$query" =~ \[\*\]$ ]]; then
  prefix="${query%\[\*\]}"
  echo "["
  i=0
  while [[ -v "kv_map[$prefix[$i]]" ]]; do
    printf "%s" "${kv_map[$prefix[$i]]}"
    ((i++))
    [[ -v "kv_map[$prefix[$i]]" ]] && echo "," || echo
  done
  echo "]"
elif [[ -v "kv_map[$query]" ]]; then
  echo "${kv_map[$query]}"
else
  echo "null"
fi
