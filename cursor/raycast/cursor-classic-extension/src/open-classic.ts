import { execFile } from "child_process";
import { homedir } from "os";
import { promisify } from "util";
import { fileURLToPath } from "url";

const execFileAsync = promisify(execFile);

export function classicWrapperPath(): string {
  return process.env.CURSOR_CLASSIC_WRAPPER || `${homedir()}/dotfiles/cursor/scripts/cursor-classic-wrapper.sh`;
}

export function uriOrPathToFsPath(target: string): string {
  const value = String(target || "");
  if (value.startsWith("file://")) {
    try {
      return fileURLToPath(value);
    } catch {
      return decodeURIComponent(value.replace(/^file:\/\//, ""));
    }
  }
  return value;
}

export async function openInClassicCursor(target: string): Promise<void> {
  const path = uriOrPathToFsPath(target);
  await execFileAsync(classicWrapperPath(), ["--classic", path]);
}

export async function openNewClassicWindow(): Promise<void> {
  await execFileAsync(classicWrapperPath(), ["--classic", "--new-window"]);
}
