# Ollama local model server.
{ config, lib, ... }:
{
  options.ai.ollama = {
    enable = lib.mkEnableOption "the Ollama local LLM server";
    acceleration = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "cuda"
          "rocm"
        ]
      );
      default = "cuda";
      description = "GPU acceleration backend; null disables it.";
    };
  };

  config = lib.mkIf config.ai.ollama.enable {
    services.ollama = {
      inherit (config.ai.ollama) acceleration;
      enable = true;
      host = "127.0.0.1";
      port = 11434;
    };
  };
}
