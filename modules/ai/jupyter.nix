# JupyterHub stub for shared notebook access on the AI host.
{ config, lib, ... }:
{
  options.ai.jupyter = {
    enable = lib.mkEnableOption "JupyterHub for shared notebooks";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8888;
      description = "TCP port JupyterHub binds.";
    };
  };

  config = lib.mkIf config.ai.jupyter.enable {
    assertions = [
      {
        assertion = false;
        message = "ai.jupyter.enable is currently a stub; full services.jupyterhub config lands in a follow-up PR.";
      }
    ];
  };
}
