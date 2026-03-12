# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains Docker Compose configurations and reference materials for AI/ML automation infrastructure. It's a collection of modular service setups designed to work independently or together for workflow automation and AI agent development.

## Repository Structure

- `n8n_base/` - Docker Compose for n8n workflow automation platform
- `postgres_base/` - Docker Compose for PostgreSQL with sample schema and seed data
- `quadrant_base/` - Docker Compose for Qdrant vector database
- `s3_n8n_basics/` - Sample n8n workflow exports (JSON files)
- `agentai_bootcamp/` - Reference links and resources for AI/ML tools

## Common Commands

### Docker Infrastructure

All services use external Docker volumes and networks that must be created first:

```bash
# Create shared network (required before starting services)
docker network create n8n_network

# Create volumes (one-time setup)
docker volume create n8n_data
docker volume create postgres_data

# Start individual services
docker compose -f n8n_base/docker-compose.yml up -d
docker compose -f postgres_base/docker-compose.yml up -d
docker compose -f quadrant_base/docker-compose.yml up -d

# Stop services
docker compose -f n8n_base/docker-compose.yml down
docker compose -f postgres_base/docker-compose.yml down
docker compose -f quadrant_base/docker-compose.yml down
```

### Database Operations

```bash
# Connect to PostgreSQL and verify data
docker exec -it n8n_postgres psql -U n8n -d n8n -c "select * from store.products limit 5;"

# Run Qdrant locally (standalone, without compose)
docker run -d --name qdrant \
  -p 6333:6333 -p 6334:6334 \
  -v $(pwd)/qdrant_storage:/qdrant/storage \
  qdrant/qdrant
```

### ngrok Setup (for exposing local services)

```bash
# Install ngrok (Debian/Ubuntu)
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
  | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
  && echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main" \
  | sudo tee /etc/apt/sources.list.d/ngrok.list \
  && sudo apt update \
  && sudo apt install ngrok

# Configure and run
ngrok config add-authtoken <token>
ngrok http <port>
```

## Service Architecture

### n8n Setup
- **Image**: `docker.n8n.io/n8nio/n8n:latest`
- **Port**: 5678
- **Volume**: External `n8n_data` volume mounted at `/home/node/.n8n`
- **Network**: `n8n_network` (external)

### PostgreSQL Setup
- **Image**: `postgres:16`
- **Container**: `n8n_postgres`
- **Port**: 5432 (standard)
- **Database**: `n8n` with user `n8n` / password `n8n_password`
- **Schema**: Creates `store.products` table on first init
- **Seed Data**: Loaded from `initdb/data/electronics_products.csv`
- **Volume**: External `postgres_data`
- **Network**: `n8n_network` (external)

### Qdrant Setup
- **Image**: `qdrant/qdrant:latest`
- **Ports**: 6333 (REST), 6334 (gRPC)
- **Volume**: Local `qdrant_data` directory mapped to `/qdrant/storage`
- **Network**: Default bridge (no external network defined)

## Network Considerations

- **External Ollama**: Available at `http://172.17.0.1:11434` from within Docker containers
- **Shared Network**: `n8n_network` allows n8n and PostgreSQL to communicate

## Reference Materials

The `agentai_bootcamp/important_links.txt` contains categorized links to:
- LLM benchmarks and model providers
- Agent frameworks (LangChain, LangGraph, CrewAI, AutoGen, etc.)
- MCP (Model Context Protocol) resources
- Voice AI platforms (ElevenLabs, LiveKit, Vapi)
- Vector databases (Pinecone, Supabase)
- n8n workflows and templates

The `s3_n8n_basics/` directory contains exported n8n workflow JSON files that can be imported into n8n.

## Important Files

- `startup_notes.txt` - Quick reference for Docker and ngrok commands
- `important_links.txt` - Single link to n8n GitHub repository
- `postgres_base/initdb/001_schema.sql` - Database schema initialization
- `postgres_base/initdb/data/electronics_products.csv` - Sample product data
