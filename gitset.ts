// gitset.ts
const GIT_CONFIG = `${Deno.env.get("HOME")}/.gitconfig`;
const GIT_CONFIG_TEMPLATE = `${import.meta.dirname ?? '.'}/.gitconfig`;

function log(color: string, label: string, msg: string) {
  const colors: Record<string, string> = {
    blue: "\x1b[34m",
    green: "\x1b[32m",
    yellow: "\x1b[33m",
    red: "\x1b[31m",
    nc: "\x1b[0m",
  };
  console.log(`${colors[color]}[${label}]${colors.nc} ${msg}`);
}
const log_info = (msg: string) => log("blue", "INFO", msg);
const log_success = (msg: string) => log("green", "SUCCESS", msg);
const log_error = (msg: string) => log("red", "ERROR", msg);

async function backupConfig() {
  try {
    const stat = await Deno.stat(GIT_CONFIG);
    if (stat.isFile) {
      const backup = `${GIT_CONFIG}.bak.${new Date().toISOString().replace(/[-:.TZ]/g, "")}`;
      log_info(`기존 Git 설정 파일 백업 중: ${backup}`);
      await Deno.copyFile(GIT_CONFIG, backup);
      log_success("백업 완료");
    }
  } catch {
    // 파일이 없으면 무시
  }
}

async function writeConfig() {
  log_info("Git 설정 파일 생성 중...");
  const configContent = await Deno.readTextFile(GIT_CONFIG_TEMPLATE);
  await Deno.writeTextFile(GIT_CONFIG, configContent);
  await Deno.chmod(GIT_CONFIG, 0o644);
}

async function checkGitConfig() {
  log_info("Git 설정 확인 중...");
  try {
    await Deno.stat(GIT_CONFIG);
    log_success("Git 설정 파일이 생성되었습니다.");
  } catch {
    log_error("Git 설정 파일이 생성되지 않았습니다.");
    Deno.exit(1);
  }

  // user.name, user.email, alias 확인
  const get = async (args: string[]) => {
    const p = new Deno.Command("git", { args, stdout: "piped" }).spawn();
    const { success, stdout } = await p.output();
    return success ? new TextDecoder().decode(stdout).trim() : "";
  };

  const userName = await get(["config", "--get", "user.name"]);
  const userEmail = await get(["config", "--get", "user.email"]);
  if (userName && userEmail) {
    log_success("사용자 정보가 설정되었습니다.");
    log_info(`사용자 이름: ${userName}`);
    log_info(`이메일: ${userEmail}`);
  } else {
    log_error("사용자 정보가 설정되지 않았습니다.");
    Deno.exit(1);
  }

  const aliasList = await get(["config", "--get-regexp", "^alias\\."]);
  if (aliasList) {
    log_success("Git alias가 설정되었습니다.");
    log_info("설정된 alias 목록:");
    console.log(aliasList.replace(/^alias\./gm, ""));
  } else {
    log_error("Git alias가 설정되지 않았습니다.");
    Deno.exit(1);
  }
}

if (import.meta.main) {
  await backupConfig();
  await writeConfig();
  await checkGitConfig();
}
