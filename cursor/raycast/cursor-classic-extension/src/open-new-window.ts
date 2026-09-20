import { Toast, closeMainWindow, showToast } from "@raycast/api";
import { openNewClassicWindow } from "./open-classic";

export default async function command() {
  try {
    await closeMainWindow();
    await openNewClassicWindow();
  } catch (error) {
    await showToast({
      title: "Failed opening new window",
      style: Toast.Style.Failure,
      message: error instanceof Error ? error.message : String(error),
    });
  }
}
