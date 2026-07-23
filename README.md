# Semiont Template Knowledge Base

[![Lint](https://github.com/The-AI-Alliance/semiont-template-kb/actions/workflows/lint.yml/badge.svg?branch=main)](https://github.com/The-AI-Alliance/semiont-template-kb/actions/workflows/lint.yml?query=branch%3Amain)
[![License](https://img.shields.io/github/license/The-AI-Alliance/semiont-template-kb)](https://github.com/The-AI-Alliance/semiont-template-kb/blob/main/LICENSE)
[![Use this template](https://img.shields.io/badge/use%20this-template-2ea44f?logo=github)](https://github.com/new?template_name=semiont-template-kb&template_owner=The-AI-Alliance)

A starting point for creating a new [Semiont](https://github.com/The-AI-Alliance/semiont) knowledge base. Clone this repo, add your documents, and run `semiont start` to get a fully functional semantic wiki backed by AI-powered annotation, linking, and generation.

Pick one path — Local or Codespaces — and follow it end to end.

## Quick Start: Local

**Prerequisites:**

- A container runtime: [Apple Container](https://github.com/apple/container), [Docker](https://www.docker.com/), or [Podman](https://podman.io/)
- An inference provider: [Ollama](https://ollama.com/) for fully local inference, or an [Anthropic](https://www.anthropic.com/) API key for cloud inference. See [Inference Configuration](#inference-configuration) for details.
- [Git](https://git-scm.com/) — for managing your documents and committing the event streams that the backend stages
- The [Semiont launcher](https://github.com/The-AI-Alliance/semiont/tree/main/apps/launcher) — a single static binary: `brew install the-ai-alliance/semiont/semiont`

No npm or Node.js installation required — everything runs in containers.

### Start the stack

```bash
git clone https://github.com/The-AI-Alliance/semiont-template-kb.git my-kb
cd my-kb
semiont start
semiont useradd --email admin@example.com --password password --admin
```

This pulls the published Semiont images and starts everything — the API server, worker, smelter, weaver, and the Semiont browser — plus PostgreSQL, Neo4j, Qdrant, and Ollama. Nothing is built locally. The launcher auto-detects your container runtime. Follow logs with `semiont logs`, check health with `semiont status`, and stop the stack with `semiont stop`.

> **You don't need this template to create a KB.** `semiont init` births one
> anywhere — identity, config (built interactively or copied from here with
> `--from-template`), and Codespaces support (`--devcontainer`). This
> template remains the zero-install path: create a repo from it in the
> browser and open a Codespace, no local tooling required.

### Browse the knowledge base

The Semiont browser starts with the stack. Open **http://localhost:3000** and add your knowledge base in the **Knowledge Bases** panel:

| Field | Value |
|---|---|
| Host | `localhost` |
| Port | `4000` |
| Email | the email you passed to `semiont useradd` |
| Password | the password you passed to `semiont useradd` |

## Quick Start: Codespaces

For a KB you intend to keep, **[use this template](https://github.com/new?template_name=semiont-template-kb&template_owner=The-AI-Alliance) first to create your own repo**, then create a Codespace from there — that gives you write access for committing your annotations and event streams. The commands below target this template directly; useful for trying out, but read-only.

**Prerequisites:** the [Semiont launcher](https://github.com/The-AI-Alliance/semiont/tree/main/apps/launcher) (`brew install the-ai-alliance/semiont/semiont`) and the [GitHub CLI (`gh`)](https://cli.github.com/), signed in with `gh auth login`.

> **Before creating:** add `ANTHROPIC_API_KEY` as a [user secret](https://github.com/settings/codespaces) with your repo selected. Otherwise the backend comes up but inference is non-functional until you add the secret and rebuild the container.

### Start the KB in the cloud

```bash
semiont start --runtime codespace --repo The-AI-Alliance/semiont-template-kb
```

One command does the whole thing: it checks your `gh` auth, scope, and the API-key secret up front, creates the codespace on a premium machine (or resumes the one you already have — one per repo), waits for the stack to actually answer, forwards the KB to your machine, and prints the auto-generated admin credentials. First-time setup takes a few minutes: the Codespace brings the stack up via `docker compose` with the anthropic config, pulling the published images and models.

The KB lands on **http://localhost:4000** — or the next free port, which the launcher prints. Run `semiont status` any time for the codespace's state, health, and credentials.

### Browse the knowledge base

The browser runs **locally** and connects to any number of knowledge bases — cloud or local:

```bash
semiont start --service frontend
```

Open **http://localhost:3000** and add your knowledge base in the **Knowledge Bases** panel:

| Field | Value |
|---|---|
| Host | `localhost` |
| Port | the KB port the launcher printed (`4000` unless it was taken) |
| Email | from the credentials the launcher printed (`semiont status` re-prints them) |
| Password | likewise |

Because the browser is local and each codespace KB gets its own port, you can run several KBs at once — start another with `--repo <owner>/<other-kb>` and add it to the same panel.

### Stop it

```bash
semiont stop --repo The-AI-Alliance/semiont-template-kb            # halt billing; state and credentials persist
semiont stop --repo The-AI-Alliance/semiont-template-kb --delete   # destroy the codespace
```

<details>
<summary>Without the launcher: the raw <code>gh</code> recipe</summary>

```bash
gh codespace create --repo The-AI-Alliance/semiont-template-kb --machine premiumLinux
gh codespace ports forward 3000:3000 4000:4000   # leave running
gh codespace ssh -- cat '/workspaces/*/.devcontainer/admin.json' # in another terminal
#   (ssh lands in /home/vscode, not the workspace — hence the absolute,
#    quoted path: the quotes keep your shell from expanding it locally)
```

This forwards the codespace's own browser as well, so you open **http://localhost:3000** and sign in with those credentials. Setup generates the admin credentials once, at creation, into `.devcontainer/admin.json` — and prints them on every start.

If `gh` rejects the forward with `must have admin rights to Repository`, your `gh` install lacks the codespace OAuth scope. Grant it once and re-run:

```bash
gh auth refresh -h github.com -s codespace
```

</details>

## Adding Documents

Add documents anywhere in the project root. They become resources in the knowledge base when you upload them through the UI or CLI. This repo is a Git repository — use `git` to track your documents, branch, and collaborate just as you would with any other project.

## Inference Configuration

`semiont start` selects an inference config with the `--config` flag. Configs live in `.semiont/semiontconfig/`:

- **`ollama-gemma`** — fully local inference via [Ollama](https://ollama.com/) with Gemma 4 models. No API key needed. On first run, Ollama pulls `gemma4:26b` (17 GB), `gemma4:e2b` (7.2 GB), and `nomic-embed-text` (274 MB) — roughly 24 GB total, downloaded once.
- **`anthropic`** (default for Codespaces) — cloud inference via the Anthropic API. Requires `ANTHROPIC_API_KEY`.

The choice is sticky per knowledge base: a successful `semiont start --config <name>` is remembered, so later bare `semiont start` runs reuse it (the banner says so, and `--config` always overrides). Without a recorded preference, the default is `ollama-gemma`.

```bash
# Use Anthropic cloud inference locally
export ANTHROPIC_API_KEY=<your-api-key>
semiont start --config anthropic
semiont useradd --email admin@example.com --password password --admin
```

Rather than exporting the key every session, you can register where it comes from once — the launcher stores a pointer, never the value, and reads it fresh (with your password manager's approval prompt) on each start:

```bash
semiont secret set ANTHROPIC_API_KEY
```

```bash
# List available configs
semiont start --list-configs
```

To create your own config, add a `.toml` file to `.semiont/semiontconfig/`. See the [Configuration Guide](https://github.com/The-AI-Alliance/semiont/blob/main/docs/system/administration/CONFIGURATION.md) for the full reference.

## Container Images

The stack runs published, attested images from GitHub Container Registry — `semiont-backend`, `semiont-worker`, `semiont-smelter`, `semiont-weaver`, and `semiont-frontend`. Nothing is built locally; a fresh start is a pull, not a compile.

`SEMIONT_VERSION` selects the image version (`latest` by default):

```bash
SEMIONT_VERSION=0.5.12 semiont start
```

Every image is vulnerability- and license-scanned before publish, and ships SLSA build-provenance and SBOM attestations you can verify before running anything:

```bash
gh attestation verify oci://ghcr.io/the-ai-alliance/semiont-backend:latest --owner The-AI-Alliance
```

See [Container Images](https://github.com/The-AI-Alliance/semiont/blob/main/docs/system/administration/IMAGES.md) for the full inventory and verification details.

## What's Inside

```
.devcontainer/                    # GitHub Codespaces configuration
.semiont/
├── config                        # Project name and settings
├── compose/                      # Docker Compose file for the stack
└── semiontconfig/                # Inference config variants (.toml)
```

As you work in the knowledge base, the backend writes event streams (annotations, links, generated content) as JSONL files into `.semiont/events/` and stages them with `git add`. The backend container includes its own Git installation for this purpose. You are responsible for committing and pushing these staged changes — treat the knowledge base like any other Git repository.

## Documentation

See the [Semiont repository](https://github.com/The-AI-Alliance/semiont) for full documentation:

- [Configuration Guide](https://github.com/The-AI-Alliance/semiont/blob/main/docs/system/administration/CONFIGURATION.md) — inference providers, vector search, graph database settings
- [Project Layout](https://github.com/The-AI-Alliance/semiont/blob/main/docs/system/PROJECT-LAYOUT.md) — how `.semiont/` and resource files are organized
- [Local Semiont](https://github.com/The-AI-Alliance/semiont/blob/main/docs/system/LOCAL-SEMIONT.md) — alternative setup paths including the Semiont CLI

## License

Apache 2.0 — See [LICENSE](LICENSE) for details.
