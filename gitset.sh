#!/bin/zsh
# Git 설정 스크립트 - 멱등적 실행 지원

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

# Git 설정 파일 경로
GIT_CONFIG="${HOME}/.gitconfig"

# 기존 설정 파일이 있다면 백업
if [[ -f $GIT_CONFIG ]]; then
  BACKUP_FILE="${GIT_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
  log_info "기존 Git 설정 파일 백업 중: $BACKUP_FILE"
  cp "$GIT_CONFIG" "$BACKUP_FILE"
  log_success "백업 완료"
fi

# Git 설정 내용
log_info "Git 설정 파일 생성 중..."

GIT_CONFIG_CONTENT=$(cat <<'EOL'
[column]
ui = auto

[branch]
sort = -committerdate

[tag]
sort = version:refname

[init]
defaultBranch = main

[diff]
algorithm = histogram
colorMoved = plain
mnemonicPrefix = true
renames = true

[push]
default = simple
autoSetupRemote = true
followTags = true

[fetch]
prune = true
pruneTags = true
all = true

[help]
autocorrect = prompt

[commit]
verbose = true

[rerere]
enabled = true
autoupdate = true

[core]
excludesfile = ~/.gitignore

[rebase]
autoSquash = true
autoStash = true
updateRefs = true

# 선택적 설정들 - 필요한 경우 주석을 제거하세요
#[core]
#fsmonitor = true
#untrackedCache = true

#[merge]
#conflictstyle = zdiff3

[user]
name = hwisu
email = hwitticus@gmail.com

[pull]
rebase = true
EOL
)

# 설정 파일 작성
echo $GIT_CONFIG_CONTENT > "$GIT_CONFIG"

if [[ $? -eq 0 ]]; then
  log_success "Git 설정이 ${GIT_CONFIG} 파일에 성공적으로 저장되었습니다."

  # .gitignore 파일 생성 (기존에는 없었지만 설정에서 언급되어 있음)
  if [[ ! -f "${HOME}/.gitignore" ]]; then
    log_info ".gitignore 파일 생성 중..."

    cat > "${HOME}/.gitignore" <<EOL
# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Node.js
node_modules/
npm-debug.log
yarn-error.log
.pnpm-debug.log

# Editor files
.idea/
.vscode/
*.swp
*.swo
*~

# Logs
logs
*.log

# Env files
.env
.env.local
EOL

    log_success ".gitignore 파일이 생성되었습니다."
  else
    log_info "기존 .gitignore 파일을 유지합니다."
  fi
else
  log_error "Git 설정 파일 생성 중 오류가 발생했습니다."
  exit 1
fi
