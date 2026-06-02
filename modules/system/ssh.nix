# Hardened OpenSSH defaults. Always on — server A is administered remotely.
{ lib, ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = lib.mkDefault "prohibit-password";
      X11Forwarding = false;
    };
    openFirewall = true;
  };
}
