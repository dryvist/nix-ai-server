# Python toolchain for AI workloads.
#
# Real package builds use uv2nix at the host level (see flake.nix
# inputs). This module exposes the bare interpreter + uv CLI on the
# system PATH so escape-hatch installs ("uv pip install ...") and
# notebooks work even outside a uv2nix-built closure.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.ai.python.enable = lib.mkEnableOption "the system-level Python + uv toolchain";

  config = lib.mkIf config.ai.python.enable {
    environment.systemPackages = with pkgs; [
      python3
      uv
    ];
  };
}
