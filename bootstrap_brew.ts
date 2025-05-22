function isMacOS() {
  const uname = Deno.build.os;
  if (uname !== "darwin") {
    console.error("이 스크립트는 macOS에서만 동작합니다.");
    Deno.exit(1);
  }
}

async function commandExists(cmd: string): Promise<boolean> {
  const p = new Deno.Command("command", {
    args: ["-v", cmd],
    stdout: "null",
    stderr: "null",
  }).spawn();
  const status = await p.status;
  return status.success;
}

async function installHomebrew() {
  if (await commandExists("brew")) {
    console.log("Homebrew가 이미 설치되어 있습니다.");
    return;
  }
  console.log("Homebrew가 설치되어 있지 않습니다. 설치를 시작합니다...");
  const installCmd =
    '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"';
  const p = new Deno.Command("bash", {
    args: ["-c", installCmd],
    stdout: "inherit",
    stderr: "inherit",
    stdin: "inherit",
  }).spawn();
  const status = await p.status;
  if (!status.success) {
    console.error("Homebrew 설치에 실패했습니다.");
    Deno.exit(1);
  }
  console.log("Homebrew 설치 완료!");
}

async function brewInstall(pkgs: string[]) {
  for (const pkg of pkgs) {
    const check = new Deno.Command("brew", {
      args: ["list", pkg],
      stdout: "null",
      stderr: "null",
    }).spawn();
    const status = await check.status;
    if (status.success) {
      console.log(`${pkg}는 이미 설치되어 있습니다.`);
      continue;
    }
    console.log(`${pkg}를 설치합니다...`);
    const install = new Deno.Command("brew", {
      args: ["install", pkg],
      stdout: "inherit",
      stderr: "inherit",
      stdin: "inherit",
    }).spawn();
    const installStatus = await install.status;
    if (installStatus.success) {
      console.log(`${pkg} 설치 완료!`);
    } else {
      console.error(`${pkg} 설치 실패`);
    }
  }
}

async function brewInstallCask(pkgs: string[]) {
  for (const pkg of pkgs) {
    const check = new Deno.Command("brew", {
      args: ["list", "--cask", pkg],
      stdout: "null",
      stderr: "null",
    }).spawn();
    const status = await check.status;
    if (status.success) {
      console.log(`${pkg} (cask)는 이미 설치되어 있습니다.`);
      continue;
    }
    console.log(`${pkg} (cask)를 설치합니다...`);
    const install = new Deno.Command("brew", {
      args: ["install", "--cask", pkg],
      stdout: "inherit",
      stderr: "inherit",
      stdin: "inherit",
    }).spawn();
    const installStatus = await install.status;
    if (installStatus.success) {
      console.log(`${pkg} (cask) 설치 완료!`);
    } else {
      console.error(`${pkg} (cask) 설치 실패`);
    }
  }
}

if (import.meta.main) {
  isMacOS();
  await installHomebrew();
  await brewInstall([
    "fzf",
    "hugo",
    "lua",
    "nvm",
    "sqlite",
    "tldr",
    "tmux",
    "wget",
    "pnpm",
    "nvim",
  ]);
  await brewInstallCask([
    "font-neodunggeunmo-code",
    "ghostty",
    "ngrok",
    "cursor"
  ]);
}
