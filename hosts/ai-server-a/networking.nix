# 1 GbE-only host networking.
#
# Server A is **standalone** — it does NOT join the Proxmox cluster
# (B+C+D) and does NOT participate in any cluster fabric.
# There is intentionally NO `mkEnableOption "ten-gig mesh"` flag here
# (committed decision per ADR 0005). 1 GbE is the only interface;
# the host appears as a normal LAN node.
{ lib, ... }:
{
  networking = {
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = lib.mkDefault true;
      # SSH is opened by modules/system/ssh.nix; per-AI-service ports
      # are opened by their respective modules behind their enable flags.
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };
}
