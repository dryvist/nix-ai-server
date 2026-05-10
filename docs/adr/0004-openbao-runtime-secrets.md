# ADR 0004: OpenBao for runtime secrets, not Vault OSS or Infisical

- Status: Accepted
- Date: 2026-05-10

## Context

Server A's AI services (vLLM API keys, HuggingFace tokens, Splunk HEC
tokens for promtail) all need short-TTL secrets at runtime. The cluster
already runs an **OpenBao LXC** as the dryvist homelab's secret
broker (see `dryvist/ansible-server-apps`), reachable on the LAN.

Earlier drafts of this design used **Infisical**. That was dropped in
favor of OpenBao for two reasons:

1. OpenBao is a community fork of HashiCorp Vault under MPL-2.0 with
   no BSL drift risk, and its Vault-API compatibility means existing
   `community.hashi_vault` Ansible content and the `bao agent` CLI
   work unmodified.
2. Self-hosting Infisical adds an extra service to operate; OpenBao is
   already on the cluster's roadmap.

HashiCorp Vault OSS is also rejected because of the BSL relicense and
the OpenBao fork's rapid maturation.

## Decision

Server A consumes runtime secrets exclusively through an **OpenBao
agent** running as a systemd timer. The agent reads short-TTL secrets
from the cluster's OpenBao LXC and renders them into root-only files
under `/run/openbao/<service>.env`. AI services pick those up via
`systemd.services.<name>.serviceConfig.EnvironmentFile`.

Activation-time secrets (the OpenBao AppRole's initial `secret-id`,
TLS material the host needs before any service is up) live in
`secrets/*.enc.yaml`, encrypted via sops-nix.

## Consequences

- `modules/secrets/openbao-agent.nix` (rather than the older
  `infisical-agent.nix`) is the only runtime-secret broker.
- Per-service env files are declared via `secrets.openbao-agent.envFiles.<name>`.
- The host's age key (derived via `ssh-to-age` after first install)
  must be added to `.sops.yaml` before the AppRole secret-id can be
  encrypted to the host.
- Doppler is **not** used for runtime secrets — keeping it limited to
  the `gh-workflow-tokens` project for `GH_PAT_PROJECTS` injection only.
