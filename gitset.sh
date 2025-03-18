#!/bin/bash

# 홈 디렉토리의 .gitconfig 파일 생성/수정
cat > ~/.gitconfig << 'EOL'
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

#[pull]
#rebase = true
EOL

echo "Git 설정이 ~/.gitconfig 파일에 저장되었습니다."
