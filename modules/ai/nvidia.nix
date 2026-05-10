# NVIDIA driver + CUDA enablement.
# CUDA-first decision: see docs/adr/0002-cuda-vs-rocm.md.
{ config, lib, ... }:
{
  options.ai.nvidia.enable = lib.mkEnableOption "the NVIDIA proprietary driver and CUDA support";

  config = lib.mkIf config.ai.nvidia.enable {
    nixpkgs.config.allowUnfree = true;

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };

      nvidia = {
        modesetting.enable = true;
        open = false;
        nvidiaSettings = false;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      # Containerized AI workloads (vLLM/Ollama escape-hatch) need the
      # NVIDIA container toolkit to expose GPUs to OCI runtimes.
      nvidia-container-toolkit.enable = true;
    };
  };
}
