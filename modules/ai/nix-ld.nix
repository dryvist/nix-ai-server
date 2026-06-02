# nix-ld: dynamic loader stub so `uv`-installed wheels with native
# extensions (CUDA, OpenBLAS, etc.) can resolve their interpreter on
# NixOS without rebuilding the world.
{ config, lib, ... }:
{
  options.ai.nix-ld.enable = lib.mkEnableOption "nix-ld for FHS-style dynamic linking of pip/uv wheels";

  config = lib.mkIf config.ai.nix-ld.enable {
    programs.nix-ld = {
      enable = true;
      libraries = with lib; mkDefault [ ];
    };
  };
}
