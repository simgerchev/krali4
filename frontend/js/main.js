import { initTerminalApp } from "./terminal.js";

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initTerminalApp);
} else {
  initTerminalApp();
}
