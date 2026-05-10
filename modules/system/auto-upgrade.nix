# Pull-mode auto-upgrade.
#
# Server A is standalone, so we don't coordinate with cluster maintenance
# windows — the host simply rebuilds against `flake.nix` once a week and
# reboots if the kernel changed.
{ lib, ... }:
{
  system.autoUpgrade = {
    enable = lib.mkDefault true;
    flake = "github:dryvist/nix-ai-server#ai-server-a";
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L"
    ];
    dates = "Sun 03:00";
    randomizedDelaySec = "45min";
    allowReboot = lib.mkDefault true;
    rebootWindow = {
      lower = "03:00";
      upper = "05:00";
    };
  };
}
