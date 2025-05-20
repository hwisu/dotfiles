_

---

## 실행 흐름 도식

```mermaid
flowchart TD
    A[bootstrap.sh 실행] --> B{Deno 설치 여부 확인}
    B -- 미설치시 설치 --> C[deno 설치]
    B -- 이미 설치됨 --> D[deno 사용]
    C --> D
    D --> E[deno run bootstrap_brew.ts]
    E --> F[deno run gitset.ts]
    F --> G[.gen_envs.sh 복사 및 실행권한]
    G --> H[각 쉘 설정파일에 source .gen_envs.sh 추가]
```

- `bootstrap.sh`가 전체 설치의 진입점입니다.
- Deno가 없으면 설치 후, Deno 기반 TypeScript 스크립트(`bootstrap_brew.ts`,
  `gitset.ts`)를 실행합니다.
- 환경 변수 스크립트(`.gen_envs.sh`)를 홈 디렉토리에 복사하고, 각 쉘 설정 파일에
  자동으로 소스합니다.
