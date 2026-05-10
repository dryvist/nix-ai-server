# Lightweight host observability — journald retention + node_exporter
# bound to localhost. Promtail/Loki shipping is owned by
# `modules/monitoring/promtail.nix`.
{ lib, ... }:
{
  services.journald.extraConfig = ''
    SystemMaxUse=2G
    MaxRetentionSec=14day
  '';

  services.prometheus.exporters.node = {
    enable = lib.mkDefault true;
    listenAddress = "127.0.0.1";
    port = 9100;
    enabledCollectors = [
      "systemd"
      "processes"
    ];
  };
}
