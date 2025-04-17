#!/bin/zsh
# Cursor 에디터 설정 스크립트 - 멱등적 실행 지원

# 컬러 설정
typeset -A colors
colors=(
  [blue]=$'\033[0;34m'
  [green]=$'\033[0;32m'
  [yellow]=$'\033[0;33m'
  [red]=$'\033[0;31m'
  [nc]=$'\033[0m'
)

# 로그 함수
function log_info() {
  echo -e "${colors[blue]}[INFO]${colors[nc]} $1"
}

function log_success() {
  echo -e "${colors[green]}[SUCCESS]${colors[nc]} $1"
}

function log_warning() {
  echo -e "${colors[yellow]}[WARNING]${colors[nc]} $1"
}

function log_error() {
  echo -e "${colors[red]}[ERROR]${colors[nc]} $1"
}

# Cursor settings.json 위치
CURSOR_SETTINGS="${HOME}/Library/Application Support/Cursor/User/settings.json"
SETTINGS_DIR="${CURSOR_SETTINGS:h}"

# 설정 디렉토리 존재 여부 확인 및 생성
if [[ ! -d $SETTINGS_DIR ]]; then
  log_info "Cursor 설정 디렉토리 생성 중..."
  mkdir -p $SETTINGS_DIR
  log_success "디렉토리 생성 완료: $SETTINGS_DIR"
fi

# 기존 설정 파일이 있다면 백업
if [[ -f $CURSOR_SETTINGS ]]; then
  BACKUP_FILE="${CURSOR_SETTINGS}.bak.$(date +%Y%m%d%H%M%S)"
  log_info "기존 설정 파일 백업 중: $BACKUP_FILE"
  cp "$CURSOR_SETTINGS" "$BACKUP_FILE"
  log_success "백업 완료"
fi

# 설정 내용
SETTINGS_CONTENT=$(cat <<'EOF'
{
    "editor.formatOnSave": true,
    "editor.fontFamily": "FiraCode Nerd Font, D2Coding ligature, monospace",
    "editor.fontSize": 14,
    "editor.fontLigatures": true,
    "editor.rulers": [80, 100],
    "editor.renderWhitespace": "all",
    "editor.tabSize": 2,
    "editor.lineNumbers": "relative",
    "editor.renderLineHighlight": "all",
    "editor.cursorSurroundingLines": 8,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "terminal.integrated.fontFamily": "FiraCode Nerd Font",
    "terminal.integrated.fontSize": 13,
    "terminal.integrated.fontLigatures": true,

    "debug.console.fontSize": 13,
    "cursor-retrieval.canAttemptGithubLogin": false,
    "cursor.cpp.enablePartialAccepts": true,

    "explorer.fileNesting.patterns": {
        "*.ts": "${capture}.js",
        "*.js": "${capture}.js.map, ${capture}.min.js, ${capture}.d.ts",
        "*.jsx": "${capture}.js",
        "*.tsx": "${capture}.ts",
        "tsconfig.json": "tsconfig.*.json",
        "package.json": "package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb",
        "*.sqlite": "${capture}.${extname}-*",
        "*.db": "${capture}.${extname}-*",
        "*.sqlite3": "${capture}.${extname}-*",
        "*.db3": "${capture}.${extname}-*",
        "*.sdb": "${capture}.${extname}-*",
        "*.s3db": "${capture}.${extname}-*"
    },

    "sqliteViewer.maxFileSize": 1000,
    "workbench.colorTheme": "Kanagawa",
    "haskell.manageHLS": "GHCup",

    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": "always"
    },

    "extensions.experimental.affinity": {
        "asvetliakov.vscode-neovim": 1
    }
}
EOF
)

# 설정 파일 생성
log_info "Cursor 설정 파일 생성 중: $CURSOR_SETTINGS"
echo $SETTINGS_CONTENT > "$CURSOR_SETTINGS"

if [[ $? -eq 0 ]]; then
  log_success "Cursor 에디터 설정이 성공적으로 완료되었습니다."
else
  log_error "Cursor 에디터 설정 중 오류가 발생했습니다."
  exit 1
fi
