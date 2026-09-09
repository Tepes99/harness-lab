# Harness Lab

This repository is a learning lab, experiment log, and catalog of agent harnesses built on [Pi](https://github.com/earendil-works/pi). Its central question is:

> What is the smallest set of Pi primitives from which we can construct many different agent architectures?

Pi remains the worker runtime. It owns the agent loop, model/provider calls, messages and sessions, tool execution, lifecycle events, context construction, extension loading, and interactive UI. This repository composes those primitives into observable experiments. Durable workflows, queues, databases, and multi-agent scheduling can later live in Python around Pi workers.

The primary experimental model is the locally hosted `qwen3.8-27b-fp8`, exposed through an OpenAI-compatible vLLM endpoint.

## Start here

1. Read the [curriculum](docs/curriculum/roadmap.md) and [repository architecture](docs/architecture/repository-structure.md).
2. Learn the vocabulary in the [primitive taxonomy](docs/concepts/primitives.md).
3. Run the labs in order, beginning with [Lab 1](labs/01-minimal-pi/README.md).
4. Record surprises in the Pi and Qwen findings logs.

Install the editor/type-checking dependencies with `npm install`, then run `npm run check`. Pi itself is currently installed globally and is deliberately treated as the runtime rather than copied into this repository.

## Current checkpoint

Labs 1–15 are implemented. The current milestone includes policy, plan mode, verification, observability, skills, compaction, two memory placements, bounded sub-agents, eleven harness architecture cards, and a six-configuration same-model benchmark. The next lab places a Python controller around Pi's supported process/RPC surface.
