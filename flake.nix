{
  description = "Noctalia local/rclone-status bar plugin, helper, and full-control rclone PyQt6 GUI";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      rclone-control = pkgs.callPackage ./gui { };
      helper = pkgs.writeShellApplication {
        name = "noctalia-rclone-status";
        runtimeInputs = [ pkgs.python3 pkgs.coreutils pkgs.systemd ];
        text = ''
          exec python3 ${./helper/rclone-status.py} "$@"
        '';
      };
      plugin = pkgs.runCommand "noctalia-plugin-rclone-status" { } ''
        cp -r ${./rclone-status} $out
      '';
    in {
      lib = {
        pluginDir = ./rclone-status;
        helperScript = ./helper/rclone-status.py;
      };
      packages.${system} = {
        inherit rclone-control helper plugin;
        default = rclone-control;
      };
      checks.${system} = {
        gui = rclone-control;
        helper = pkgs.runCommand "noctalia-rclone-status-checked" {
          nativeBuildInputs = [ pkgs.python3 ];
        } ''
          python3 ${./tests/test-rclone-status.py} ${./helper/rclone-status.py}
          touch $out
        '';
        plugin = pkgs.runCommand "noctalia-rclone-status-plugin-checked" {
          nativeBuildInputs = [ pkgs.luau ];
        } ''
          for entry in service bar panel; do
            {
              printf 'local TEST_ENTRY = "%s"\n' "$entry"
              cat ${./tests/test-rclone-status-plugin.luau}
            } | sed -e '/^--@COMMON@$/{r ${./rclone-status/common.luau}' -e 'd}' \
                    -e "/^--@ENTRY@$/{r ${./rclone-status}/$entry.luau" -e 'd}' \
              | sed 's|require("./common\.luau")|commonModule|g' > "test_$entry.luau"
            luau "test_$entry.luau"
          done
          touch $out
        '';
      };
    };
}
