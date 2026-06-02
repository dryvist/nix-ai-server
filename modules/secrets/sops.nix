# sops-nix: decrypt activation-time secrets to /run/secrets/.
#
# Activation-time secrets are SHORT-LIVED bootstrap material — host
# join tokens, the OpenBao agent's initial AppRole secret-id, etc.
# Anything an AI service consumes at runtime should come from the
# OpenBao agent (modules/secrets/openbao-agent.nix), not from here.
{ config, lib, ... }:
{
  sops = {
    age = {
      keyFile = lib.mkDefault "/var/lib/sops-nix/keys.txt";
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };

    defaultSopsFile = lib.mkDefault ../../secrets/system.enc.yaml;
    defaultSopsFormat = "yaml";

    # Per-secret declarations land in a follow-up PR alongside the
    # OpenBao AppRole bootstrap material; the placeholder file
    # `secrets/system.enc.yaml` is intentionally empty for the scaffold.
    secrets = { };
  };

  # Surface a helpful error if anyone enables this on a host that
  # hasn't yet had its age key derived via `ssh-to-age`.
  assertions = [
    {
      assertion = config.sops.age.keyFile != null;
      message = "sops.age.keyFile must point at the host age key (derived via ssh-to-age after first install).";
    }
  ];
}
