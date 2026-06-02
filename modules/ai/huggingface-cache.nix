# Shared HuggingFace cache directory under the ZFS `tank` pool so every
# AI service hits the same downloaded blobs.
{ config, lib, ... }:
{
  options.ai.huggingface-cache = {
    enable = lib.mkEnableOption "a shared HuggingFace cache directory under tank/models";
    path = lib.mkOption {
      type = lib.types.path;
      default = "/tank/models/huggingface";
      description = "Filesystem path used as HF_HOME for AI services.";
    };
  };

  config = lib.mkIf config.ai.huggingface-cache.enable {
    systemd.tmpfiles.rules = [
      "d ${config.ai.huggingface-cache.path} 0755 root root - -"
    ];

    environment.sessionVariables = {
      HF_HOME = config.ai.huggingface-cache.path;
    };
  };
}
