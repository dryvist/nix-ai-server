# ADR 0003: uv2nix for Python, poetry2nix rejected

- Status: Accepted
- Date: 2026-05-10

## Context

vLLM, llama.cpp Python bindings, and JupyterHub all need a Python
environment with non-trivial native dependencies (CUDA wheels, OpenBLAS,
etc.). Two mature ways to express that in Nix:

- **poetry2nix** — converts a `poetry.lock` into a Nix expression.
  Long-lived ecosystem; somewhat slow PEP-517 build paths; coupled to
  poetry's resolver.
- **uv2nix** — converts a `uv.lock` (uv is the modern, Rust-based
  resolver from astral.sh) into a Nix expression. Fast, actively
  maintained, designed around modern PEP standards.

## Decision

Use **uv2nix** (`github:pyproject-nix/uv2nix`) plus its companion
inputs `pyproject-nix` and `build-system-pkgs`. uv is what we already
use for ad-hoc Python work in dev shells, so adopting uv2nix keeps the
upstream-side and Nix-side tooling aligned.

## Consequences

- Python environments under `modules/ai/` are described by a `uv.lock`
  in the host's directory (added in a follow-up PR alongside the real
  vLLM unit).
- We do not maintain a `poetry.lock` for the same packages.
- `nix-ld` (`modules/ai/nix-ld.nix`) is mandatory whenever uv-installed
  wheels with native extensions need to resolve their interpreter on
  NixOS.
