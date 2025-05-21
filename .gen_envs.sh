#!/bin/bash
# generate_env_commands.sh

ENV_FILE="$HOME/.env.json"

if [ ! -f "$ENV_FILE" ]; then
    exit 0
fi

# jq가 설치되어 있는지 확인
if command -v jq >/dev/null 2>&1; then
    PARSER="jq"
else
    echo "Error: jq가 필요합니다." >&2
    exit 1
fi

# 변수 설정만 하고 출력하지 않음
eval "$(jq -r '
    if .variables then
        .variables | to_entries[] | "export \(.key)=\"\(.value)\""
    else empty end,
    if .paths_to_add then
        .paths_to_add[] | "export PATH=\"\(.):$PATH\""
    else empty end
' "$ENV_FILE")"
