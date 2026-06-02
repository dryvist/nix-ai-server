# vLLM serving stub.
#
# This stub registers the option surface and reserves the systemd unit
# slot. The real package + DynamicUser unit lands in a follow-up PR
# alongside the uv2nix-built environment.
{ config, lib, ... }:
{
  options.ai.vllm = {
    enable = lib.mkEnableOption "the vLLM OpenAI-compatible model server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "TCP port the vLLM HTTP server binds.";
    };
  };

  config = lib.mkIf config.ai.vllm.enable {
    # Placeholder: real systemd.services.vllm definition lands with
    # the uv2nix-built closure. Until then, fail loudly if anyone
    # tries to enable this in production.
    assertions = [
      {
        assertion = false;
        message = "ai.vllm.enable is currently a stub; the systemd unit lands in a follow-up PR.";
      }
    ];
  };
}
