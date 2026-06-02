# Single source of truth for `nix flake check` outputs.
# Mirrors the nix-darwin pattern: formatting + static analysis + dead-code
# detection + a NixOS toplevel evaluation gate.
{
  pkgs,
  src,
  nixosConfigurations ? { },
}:
{
  formatting =
    pkgs.runCommand "check-formatting"
      {
        nativeBuildInputs = [ pkgs.nixfmt-rfc-style ];
      }
      ''
        cp -r ${src} $TMPDIR/src
        chmod -R u+w $TMPDIR/src
        cd $TMPDIR/src
        ${pkgs.lib.getExe pkgs.nixfmt-rfc-style} --check $(find . -type f -name '*.nix')
        touch $out
      '';

  statix = pkgs.runCommand "check-statix" { } ''
    cd ${src}
    ${pkgs.lib.getExe pkgs.statix} check .
    touch $out
  '';

  deadnix = pkgs.runCommand "check-deadnix" { } ''
    cd ${src}
    ${pkgs.lib.getExe pkgs.deadnix} -L --fail .
    touch $out
  '';
}
// pkgs.lib.optionalAttrs (nixosConfigurations != { }) {
  # Evaluate every NixOS host to catch import errors, type errors, and
  # assertion failures without performing a full system build.
  module-eval = pkgs.runCommand "check-module-eval" { } ''
    ${pkgs.lib.concatStringsSep "\n" (
      pkgs.lib.mapAttrsToList (
        name: cfg: "echo \"${name}: ${cfg.config.system.build.toplevel.drvPath}\""
      ) nixosConfigurations
    )}
    touch $out
  '';
}
