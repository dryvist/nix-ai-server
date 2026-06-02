# Host binding for server A.
# Standalone NixOS AI host — never joins the Proxmox cluster.
{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./networking.nix
  ];

  networking.hostName = "ai-server-a";

  # State version is pinned to the nixpkgs channel; Renovate's channel-bump
  # PR will need to update this in lockstep with the nixpkgs URL in flake.nix.
  system.stateVersion = "25.11";

  # Opt-ins for AI workloads — flip per host. Defaults are off so the
  # scaffold evaluates without pulling huge closures.
  ai = {
    nvidia.enable = lib.mkDefault false;
    nix-ld.enable = lib.mkDefault true;
    python.enable = lib.mkDefault false;
    ollama.enable = lib.mkDefault false;
    llama-cpp.enable = lib.mkDefault false;
    vllm.enable = lib.mkDefault false;
    jupyter.enable = lib.mkDefault false;
    huggingface-cache.enable = lib.mkDefault false;
    model-pull.enable = lib.mkDefault false;
  };

  monitoring.promtail.enable = lib.mkDefault false;
}
