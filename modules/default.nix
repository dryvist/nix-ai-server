# Aggregator: every module file under modules/ is imported here so any
# host that imports `./modules` from flake.nix picks up the full option
# surface (most behind `mkEnableOption` flags, off by default).
{
  imports = [
    ./system/ssh.nix
    ./system/sudo.nix
    ./system/fail2ban.nix
    ./system/auto-upgrade.nix
    ./system/nix-settings.nix
    ./system/locale-time.nix
    ./system/observability.nix

    ./ai/nvidia.nix
    ./ai/nix-ld.nix
    ./ai/python.nix
    ./ai/ollama.nix
    ./ai/llama-cpp.nix
    ./ai/vllm.nix
    ./ai/jupyter.nix
    ./ai/huggingface-cache.nix
    ./ai/model-pull.nix

    ./secrets/sops.nix
    ./secrets/openbao-agent.nix

    ./monitoring/promtail.nix
  ];
}
