# noctalia-rclone-control

Noctalia bar plugin (`local/rclone-status`), systemd/FUSE helper (`noctalia-rclone-status`), and standalone OLO-Neon PyQt6 dual-pane `rclone-control` manager.

## Usage

- **Noctalia plugin source**: add this repository as a Noctalia plugin source (`catalog.toml` + `rclone-status/`).
- **Nix flake**: provides `packages.x86_64-linux.rclone-control` (default), `packages.x86_64-linux.helper`, `packages.x86_64-linux.plugin`, `lib.pluginDir`, and `checks.x86_64-linux.{gui,helper,plugin}`.
