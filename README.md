# nix-ai-server

NixOS bare-metal flake for a GPU-equipped AI host running vLLM, Ollama,
llama.cpp, and (optionally) JupyterHub for local inference and
experimentation.

The host is **standalone**: it exposes no cluster-mesh option and its
1 GbE link is treated as a normal LAN node, never a cluster fabric peer.

## What's in this flake

- **`hosts/ai-server-a/`** — host bindings (placeholder until hardware exists;
  real `by-id` paths land in PR #2)
- **`modules/system/`** — SSH, sudo, fail2ban, auto-upgrade, locale/time,
  observability, nix-settings (functional today)
- **`modules/ai/`** — NVIDIA driver, nix-ld, Python via uv2nix, Ollama,
  llama.cpp, vLLM, JupyterHub, HuggingFace cache, model pre-pull
  (all opt-in via `mkEnableOption`)
- **`modules/secrets/`** — sops-nix activation-time secrets and an
  OpenBao agent driving runtime `/run/openbao/*.env` for AI services
- **`modules/monitoring/promtail.nix`** — log shipping placeholder
- **`docs/architecture/`** — Mermaid `.mmd` source + rendered `.svg`
- **`docs/adr/`** — locked architecture decisions (CUDA vs ROCm, uv2nix
  vs poetry2nix, OpenBao vs Vault, standalone vs cluster member, etc.)

## Installation

This flake is consumed by `nixos-anywhere` from the operator Mac onto
fresh hardware. The host itself does not exist yet — today's scaffold
is structurally complete but the hardware-specific bindings in
`hosts/ai-server-a/{disko,hardware-configuration}.nix` are placeholders.

Real installation (PR #2 onward, when hardware lands):

```sh
# Clone the flake locally
git clone git@github.com:dryvist/nix-ai-server.git
cd nix-ai-server

# Boot the target host into a NixOS installer (or kexec) on the LAN, then:
nix run github:nix-community/nixos-anywhere -- \
  --flake .#ai-server-a root@<host-ip>
```

After the first install, `ssh-to-age` produces the host's age public key,
which is added to `.sops.yaml` so host-specific secrets can be encrypted
to it.

## Usage

```sh
direnv allow              # activates the nix-bare dev shell (one-time)
nix flake check           # formatting + statix + deadnix + module-eval
nix fmt                   # alejandra default + nixfmt-rfc-style fallback

# Evaluate the host without building anything:
nix eval .#nixosConfigurations.ai-server-a.config.system.build.toplevel.drvPath

# Build the system closure locally (NixOS host or remote builder required):
nix build .#nixosConfigurations.ai-server-a.config.system.build.toplevel
```

Per-module opt-ins live behind `lib.mkEnableOption`. To turn on, e.g.,
vLLM and JupyterHub for a host, set in `hosts/ai-server-a/default.nix`:

```nix
{
  ai.vllm.enable = true;
  ai.jupyter.enable = true;
}
```

## Contributing

Branch naming is enforced by the repo ruleset:
`(main|develop|feat|fix|hotfix|release|chore)/<slug>`.
All commits must be signed; PRs are required to land on `main`.
Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`) drive
release-please version bumps.

Workflow:

```sh
cd ~/git/dryvist/nix-ai-server/main
git fetch origin && git pull
git worktree add ../<type>/<slug> -b <type>/<slug> main
cd ../<type>/<slug>
# ...edit, then nix flake check, then PR
```

Never edit files in the `main/` worktree — a hook will block writes there.

## License

MIT — see [LICENSE](./LICENSE).

---

> Part of a [larger ecosystem of ~40 repos](https://docs.jacobpevans.com) — see how it all fits together.
