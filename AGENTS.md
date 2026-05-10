# nix-ai-server — AI Agent Instructions

@github:JacobPEvans/ai-assistant-instructions

## Repository Purpose

NixOS bare-metal flake for **server A**, the dryvist homelab AI host.
Server A is **standalone** — it never joins the Proxmox cluster (B+C+D)
and exposes no cluster-mesh option. CUDA-first AI stack (vLLM, Ollama,
llama.cpp, JupyterHub) layered on top of NixOS 25.11 with disko, sops-nix,
nix-ld, and uv2nix-managed Python environments.

Bootstrap path: `nixos-anywhere` from the operator Mac onto fresh hardware.
Runtime secrets: SOPS+age (committed) for activation-time material; OpenBao
agent (NOT Infisical) drives `/run/openbao/*.env` at runtime via systemd timer.

## Critical Constraints

1. **Standalone host**: never add a Proxmox/Corosync/cluster-fabric option
   flag. No `mkEnableOption "ten-gig mesh"`. The host has 1 GbE only.
2. **Flakes only**: no `nix-env`, no channels.
3. **NixOS 25.11+ pinned**: Renovate auto-PR will bump to `nixos-26.05`
   when the channel ships.
4. **CUDA-first**: ROCm path rejected (see `docs/adr/0002-cuda-vs-rocm.md`).
5. **uv2nix for Python**: Poetry / poetry2nix rejected
   (see `docs/adr/0003-uv2nix-vs-poetry2nix.md`).
6. **OpenBao runtime secrets**: Vault OSS, Infisical, and Doppler runtime
   are all out of scope (see `docs/adr/0004-openbao-runtime-secrets.md`).
7. **Real hardware paths land in PR #2**: today's `disko.nix` /
   `hardware-configuration.nix` are placeholders; do not commit any
   stable `by-id` paths until the host actually exists.
8. **Worktrees required**: never edit files in `~/git/dryvist/nix-ai-server/main/`.
   Use `~/git/dryvist/nix-ai-server/<type>/<name>/` for any change.

## Commands

```sh
# Format every Nix file (alejandra default + nixfmt-rfc-style fallback)
nix fmt

# Static analysis
statix check
deadnix -L --fail .

# Full flake check (formatting + statix + deadnix + module-eval)
nix flake check

# Evaluate the host without building
nix eval .#nixosConfigurations.ai-server-a.config.system.build.toplevel.drvPath
```

## File Conventions

- Pure Nix everywhere — no inline shell, no `python -c`, no script smuggling.
  Anything procedural must live in a NixOS module or `writeShellApplication`.
- Modules follow `{ config, lib, pkgs, ... }:` and gate optional behavior
  behind `lib.mkEnableOption`.
- Secrets live under `secrets/*.enc.yaml`, encrypted via `.sops.yaml` rules.

## Related Repos (dryvist homelab)

| Repo | Role |
| --- | --- |
| `dryvist/ansible-proxmox-cluster` | Configures B+C+D (cluster init, ZFS, PBS) |
| `dryvist/tofu-proxmox-cluster` | OpenTofu IaC for cluster VMs/LXCs |
| `dryvist/ansible-server-apps` | App deployments inside cluster guests |
| `dryvist/homelab-schemas` | JSON Schema source of truth for inventory |
| `dryvist/nix-pxe-bootstrap` | NixOS-on-Pi PXE host for bare-metal installs |
| `dryvist/nix-ai-server` (this) | Server A bare-metal NixOS — standalone |

## Documentation Map

- `docs/architecture/` — Mermaid `.mmd` source + rendered `.svg`
- `docs/adr/` — Architecture Decision Records (locked, do not revise without ADR superseding)
- `hosts/ai-server-a/` — host bindings (placeholder until hardware lands)
- `modules/` — composable NixOS modules; `default.nix` aggregator imports them all
- `lib/checks.nix` — single source of truth for `nix flake check` outputs
