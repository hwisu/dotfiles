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

cat > "$GIT_CONFIG" << 'EOL'
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

[alias]
    # 기본 명령어 단축
    st = status
    co = checkout
    br = branch
    ci = commit
    unstage = reset HEAD --
    last = log -1 HEAD
    lg = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    # 브랜치 관련
    b = branch
    ba = branch -a
    bd = branch -d
    bD = branch -D
    # 원격 저장소 관련
    r = remote
    rv = remote -v
    # 스태시 관련
    ss = stash save
    sl = stash list
    sp = stash pop
    sa = stash apply
    # 리베이스 관련
    rc = rebase --continue
    ra = rebase --abort
    rs = rebase --skip
    # 병합 관련
    mt = mergetool
    # 태그 관련
    t = tag
    ta = tag -a
    td = tag -d
    # 기타 유용한 명령어
    undo = reset --soft HEAD^
    amend = commit --amend --no-edit
    uncommit = reset --soft HEAD^
    unstage = reset HEAD --
    discard = checkout --
    cleanup = "!git branch --merged | grep -v '\\*\\|master\\|main\\|develop' | xargs -n 1 git branch -d"
EOL

# 설정 파일 권한 설정
chmod 644 "$GIT_CONFIG"

# 설정 확인
log_info "Git 설정 확인 중..."
if [[ -f $GIT_CONFIG ]]; then
  # 설정 파일이 존재하는지 확인
  log_success "Git 설정 파일이 생성되었습니다."

  # 설정 내용 확인
  if git config --get user.name >/dev/null && git config --get user.email >/dev/null; then
    log_success "사용자 정보가 설정되었습니다."
    log_info "사용자 이름: $(git config --get user.name)"
    log_info "이메일: $(git config --get user.email)"
  else
    log_error "사용자 정보가 설정되지 않았습니다."
    exit 1
  fi

  # alias 설정 확인
  if git config --get-regexp '^alias\.' >/dev/null; then
    log_success "Git alias가 설정되었습니다."
    log_info "설정된 alias 목록:"
    git config --get-regexp '^alias\.' | sed 's/^alias\.//'
  else
    log_error "Git alias가 설정되지 않았습니다."
    exit 1
  fi
else
  log_error "Git 설정 파일이 생성되지 않았습니다."
  exit 1
fi
