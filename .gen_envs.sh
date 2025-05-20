#!/bin/bash
# generate_env_commands.sh

ENV_FILE="$HOME/.env.json"

if [ ! -f "$ENV_FILE" ]; then
    exit 0
fi

# 쉘 종류 감지 (bash, zsh, fish만 고려)
SHELL_TYPE="bash"
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
fi

# jq가 설치되어 있는지 확인
if command -v jq >/dev/null 2>&1; then
    PARSER="jq"
else
    echo "Error: jq가 필요합니다." >&2
    exit 1
fi

# JSON 예시 구조:
# {
#   "variables": { "DENO_INSTALL": "$HOME/.deno", "PNPM_HOME": "$HOME/Library/pnpm" },
#   "paths_to_add": [ "$DENO_INSTALL/bin", "$PNPM_HOME" ]
# }

# jq를 사용하여 JSON 파싱 및 출력
if [ "$SHELL_TYPE" = "fish" ]; then
    # Fish commands
    jq -r '
        if .variables then
            .variables | to_entries[] | "set -gx \(.key) \"\(.value | @sh)\""
        else empty end,
        if .paths_to_add then
            .paths_to_add[] | "set -l __new_path \"\(. | @sh)\"\ncontains \$__new_path \$PATH; or set -gx PATH \$__new_path \$PATH;"
        else empty end
    ' "$ENV_FILE"
else # bash/zsh
    # Bash/Zsh commands
    jq -r '
        if .variables then
            .variables | to_entries[] | "export \(.key)=\"\(.value | @sh)\""
        else empty end,
        if .paths_to_add then
            .paths_to_add[] | "export PATH=\"\(. | @sh):\$PATH\""
        else empty end
    ' "$ENV_FILE"
fi
