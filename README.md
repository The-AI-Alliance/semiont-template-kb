# Semiont Template Knowledge Base

A starting point for creating a new [Semiont](https://github.com/The-AI-Alliance/semiont) knowledge base. Clone this repo, add your documents, and run the start script to get a fully functional semantic wiki backed by AI-powered annotation, linking, and generation.

## Prerequisites

- A container runtime: [Apple Container](https://github.com/apple/container), [Docker](https://www.docker.com/), or [Podman](https://podman.io/)

No npm or Node.js installation required — everything runs in containers.

## Quick Start

```bash
git clone https://github.com/The-AI-Alliance/semiont-template-kb.git my-kb
cd my-kb
.semiont/scripts/start.sh --email admin@example.com --password password
```

This builds and starts the full backend stack: PostgreSQL, Neo4j, Qdrant, Ollama, and the Semiont API server. The script auto-detects your container runtime.

In a second terminal, start the frontend (`container` can be replaced with `docker` or `podman`):

```bash
container run --publish 3000:3000 -it ghcr.io/the-ai-alliance/semiont-frontend:latest
```

Open **http://localhost:3000**, enter **http://localhost:4000** as the knowledge base URL, and log in with the email and password above.

## Inference Configuration

The start script selects an inference config with the `--config` flag. Configs live in `.semiont/containers/semiontconfig/`:

- **`ollama-gemma`** (default) — fully local inference via [Ollama](https://ollama.com/) with Gemma 4 models. No API key needed. On first run, Ollama pulls `gemma4:26b` (17 GB), `gemma4:e2b` (7.2 GB), and `nomic-embed-text` (274 MB) — roughly 24 GB total, downloaded once.
- **`anthropic`** — cloud inference via the Anthropic API. Requires `ANTHROPIC_API_KEY`.

```bash
# Use Anthropic cloud inference
export ANTHROPIC_API_KEY=<your-api-key>
.semiont/scripts/start.sh --config anthropic --email admin@example.com --password password
```

```bash
# List available configs
.semiont/scripts/start.sh --list-configs
```

To create your own config, add a `.toml` file to `.semiont/containers/semiontconfig/`. See the [Configuration Guide](https://github.com/The-AI-Alliance/semiont/blob/main/docs/administration/CONFIGURATION.md) for the full reference.

## Adding Documents

Add documents anywhere in the project root. They become resources in the knowledge base when you upload them through the UI or CLI.

## What's Inside

```
.semiont/
├── config                        # Project name and settings
├── compose/                      # Docker Compose file for backend
├── containers/                   # Dockerfile and inference configs
│   └── semiontconfig/            # Inference config variants (.toml)
└── scripts/                      # Backend startup script
```

## Documentation

See the [Semiont repository](https://github.com/The-AI-Alliance/semiont) for full documentation:

- [Configuration Guide](https://github.com/The-AI-Alliance/semiont/blob/main/docs/administration/CONFIGURATION.md) — inference providers, vector search, graph database settings
- [Project Layout](https://github.com/The-AI-Alliance/semiont/blob/main/docs/PROJECT-LAYOUT.md) — how `.semiont/` and resource files are organized
- [Local Semiont](https://github.com/The-AI-Alliance/semiont/blob/main/docs/LOCAL-SEMIONT.md) — alternative setup paths including the Semiont CLI

## License

Apache 2.0 — See [LICENSE](LICENSE) for details.
