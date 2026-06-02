---
applyTo: '**'
description: "Instruction for launching and testing the game"
---

# Launch Tank Game on Two iOS Simulators

This game is multiplayer over MultipeerConnectivity. To exercise networking, run two iOS
simulators side by side, each with its own copy of the app. Use **XcodeBuildMCP tools only**
— do not fall back to raw `xcrun simctl`.

## Pinned project facts (do not rediscover)

| Field | Value |
| --- | --- |
| Workspace | `tankgame.xcworkspace` (NOT the `.xcodeproj` — workspace resolves local MultiPlayKit) |
| Scheme | `tankgame iOS` |
| Configuration | `Debug` |
| Platform | `iOS Simulator` |
| Bundle ID | `com.joshspicer.tankgame` |

## Preflight (one-shot — skip on repeat runs)

Call `mcp_xcodebuildmcp_list_sims`. If `data.simulators` is empty, STOP and tell the user
to install an iOS Simulator runtime via Xcode → Settings → Platforms (or
`xcodebuild -downloadPlatform iOS`). Do not attempt the download yourself — it is multi-GB.

If `xcode-select -p` is `/Library/Developer/CommandLineTools`, STOP and ask the user to run
`sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`. CoreSimulatorService
will not start without it.

## Recipe (copy-paste-able tool calls)

Pick two distinct iPhone simulators on the same iOS runtime from `list_sims` and bind their
udids to `SIM_A` and `SIM_B`.

1. **Set defaults targeting Sim A.** `mcp_xcodebuildmcp_session_set_defaults`:
   ```json
   {
     "workspacePath": "/Users/josh/git/tankgame/tankgame.xcworkspace",
     "scheme": "tankgame iOS",
     "configuration": "Debug",
     "simulatorId": "<SIM_A>",
     "simulatorPlatform": "iOS Simulator",
     "bundleId": "com.joshspicer.tankgame"
   }
   ```
2. **Build, install, launch on Sim A.** `mcp_xcodebuildmcp_build_run_sim` with no args.
   This boots Sim A, opens Simulator.app, installs, and launches in one step.
3. **Capture the built .app path** so Sim B reuses the artifact:
   `mcp_xcodebuildmcp_get_sim_app_path` with `{ "platform": "iOS Simulator" }` → save the
   returned path as `APP_PATH`.
4. **Switch defaults to Sim B.** `mcp_xcodebuildmcp_session_set_defaults`:
   ```json
   { "simulatorId": "<SIM_B>" }
   ```
   (workspace/scheme/bundleId carry over within the profile.)
5. **Boot Sim B and reveal both windows side by side:**
   - `mcp_xcodebuildmcp_boot_sim` (no args)
   - `mcp_xcodebuildmcp_open_sim` (no args)
6. **Install and launch on Sim B (no rebuild):**
   - `mcp_xcodebuildmcp_install_app_sim` with `{ "appPath": "<APP_PATH>" }`
   - `mcp_xcodebuildmcp_launch_app_sim` (no args — uses `bundleId` from defaults)

Both simulators are now running the app and will discover each other on the local network.
Drive in-game actions with `mcp_xcodebuildmcp_tap` / `screenshot` / `snapshot_ui` against
whichever sim is currently selected via defaults.

## Iterating after a code change

- Sim A: switch defaults back to `SIM_A`, call `mcp_xcodebuildmcp_stop_app_sim`, then
  `mcp_xcodebuildmcp_build_run_sim`.
- Sim B: switch defaults to `SIM_B`, recapture `APP_PATH` with `get_sim_app_path`, then
  `stop_app_sim` → `install_app_sim` → `launch_app_sim`. No rebuild needed.
- Keep both sims **booted** between iterations — re-booting costs ~20s each.
