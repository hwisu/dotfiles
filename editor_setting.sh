#!/bin/bash

# Cursor settings.json 위치
CURSOR_SETTINGS="$HOME/Library/Application Support/Cursor/User/settings.json"

# Cursor 설정 디렉토리가 없다면 생성
mkdir -p "$(dirname "$CURSOR_SETTINGS")"

# Format on Save 설정과 폰트 패밀리 설정
cat > "$CURSOR_SETTINGS" << EOF
{
    "editor.formatOnSave": true,
    "editor.fontFamily": "FiraCode Nerd Font, Menlo, Monaco, 'Courier New', monospace",
    "editor.fontSize": 14,
    "editor.fontLigatures": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.rulers": [80, 100],
    "editor.renderWhitespace": "all",
    "editor.tabSize": 2,
    "editor.lineNumbers": "relative",
    "editor.renderLineHighlight": "all",
    "editor.cursorSurroundingLines": 8,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "terminal.integrated.fontFamily": "FiraCode Nerd Font"
}
EOF

echo "Cursor 에디터 설정이 완료되었습니다."
