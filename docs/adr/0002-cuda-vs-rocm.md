# ADR 0002: CUDA-first AI stack, ROCm rejected

- Status: Accepted
- Date: 2026-05-10

## Context

Server A is the dryvist GPU host. The candidate runtimes — vLLM, Ollama,
llama.cpp, JupyterHub kernels — all support CUDA out of the box and
ship pre-built CUDA wheels. ROCm support is significantly less mature,
particularly for vLLM (which gates ROCm behind specific GPU SKUs and
extra patches) and for the Python ecosystem in general (most
HuggingFace model cards assume CUDA).

## Decision

The AI stack is **CUDA-first**. Modules under `modules/ai/` assume
NVIDIA hardware and use the proprietary driver via
`hardware.nvidia` plus `nvidia-container-toolkit` for containerized
escape hatches. We do not maintain ROCm-equivalent code paths.

If the eventual hardware turns out to be AMD, that is a re-architecture,
not a configuration toggle — a follow-up ADR would document the change.

## Consequences

- `modules/ai/nvidia.nix` is a hard prerequisite for `modules/ai/vllm.nix`,
  `modules/ai/ollama.nix` (when `acceleration = "cuda"`), and the
  llama.cpp CUDA build.
- `nixpkgs.config.allowUnfree = true` is required at the host level
  whenever `ai.nvidia.enable` is on.
- We accept vendor lock-in to NVIDIA in exchange for a maintainable
  single-codebase AI stack.
