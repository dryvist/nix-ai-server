# llama.cpp server stub.
#
# Currently exposes the binary on PATH; a future PR adds a systemd unit
# bound to a HuggingFace cache path under `tank/models/`.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.ai.llama-cpp.enable = lib.mkEnableOption "the llama.cpp toolchain";

  config = lib.mkIf config.ai.llama-cpp.enable {
    environment.systemPackages = [ pkgs.llama-cpp ];
  };
}
