# macOS 개발 환경 자동 설정 스크립트

이 프로젝트는 macOS 개발 환경을 자동으로 구성하는 스크립트 모음입니다. 주요 개발 도구, 에디터 설정, 쉘 설정을 자동화하여 빠르고 일관된 개발 환경을 구축할 수 있습니다.

## 🔍 주요 기능

- **Homebrew**: 패키지 관리자 자동 설치 및 구성
- **개발 도구**: 필수 개발 도구 설치 (Git, Node.js 등)
- **Cursor 에디터**: 설치 및 확장 프로그램 자동 구성
- **Neovim**: 현대적인 설정으로 자동 구성 및 플러그인 설치
- **쉘 도구**: Zsh 플러그인, 테마, 유틸리티 설치
- **Docker**: 개발 컨테이너 환경 구축

## 🚀 시작하기

### 요구 사항

- 관리자 권한
- 인터넷 연결

### 설치

```bash
# 저장소 복제
git clone https://github.com/username/bootstrap.mac.git
cd bootstrap.mac

# 메인 스크립트 실행
./bootstrap.sh
```

## 📋 설치되는 Cursor 확장 프로그램

- **Haskell**: Haskell 언어 지원 및 구문 강조
- **Kanagawa**: 다크 테마
- **Python**: Python 언어 지원, Pylance, 디버깅
- **Rainbow CSV**: CSV 파일 보기 및 편집
- **SQLite Viewer**: SQLite 데이터베이스 관리
- **VSCode Neovim**: Vim 키바인딩 지원

## 🔧 Neovim 설정

기본 설정으로 다음 플러그인이 자동 설치됩니다:

- **lazy.nvim**: 플러그인 관리자
- **lspconfig + mason**: LSP 지원
- **treesitter**: 향상된 구문 강조
- **telescope**: 파일 및 코드 검색
- **kanagawa**: 다크 테마
- **nvim-cmp**: 자동 완성

## 🛡️ 문제 해결

문제가 발생하면 다음 단계를 시도해보세요:

1. 스크립트에서 발생하는 오류 메시지 확인
2. `~/.bootstrap_state` 파일 확인 (설치 상태 추적)
3. 필요한 경우 `rm ~/.bootstrap_state` 명령으로 상태 초기화 후 재시도
