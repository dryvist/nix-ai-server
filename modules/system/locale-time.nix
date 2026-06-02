# Locale, keyboard, and timezone defaults.
{ lib, ... }:
{
  time.timeZone = lib.mkDefault "America/New_York";

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  console = {
    keyMap = lib.mkDefault "us";
    earlySetup = true;
  };
}
