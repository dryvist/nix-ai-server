# sudo policy: wheel group only, password required by default.
# Individual host modules may grant passwordless sudo for specific
# automation accounts via `security.sudo.extraRules`.
{ lib, ... }:
{
  security.sudo = {
    enable = true;
    wheelNeedsPassword = lib.mkDefault true;
    execWheelOnly = true;
  };
}
