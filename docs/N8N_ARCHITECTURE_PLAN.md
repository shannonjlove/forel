# n8n Architecture & Implementation Plan

**Document Date:** July 4, 2026  
**Status:** Architecture Blueprint  
**Target Platform:** OCI/Hostinger Hybrid + Podman Quadlets  

---

## Executive Summary

This plan positions **n8n as the orchestration control plane** for your existing infrastructure, coordinating events, approvals, retries, and cross-service handoffs without becoming the location for core business logic, heavy file processing, or infrastructure state. n8n integrates with your OCI/Hostinger hybrid setup, Podman Quadlets containerization strategy, PARA organizational system, and existing services (Paperless, PhotoPrism, BookStack, MCP tools).

**Key principle:** One workflow orchestrates; one service computes.

---

## Architecture Layers

### Layer 1: Public Ingress & Reverse Proxy
- **Location:** Hostinger edge  
- **Technology:** Caddy or equivalent  
- **Responsibilities:**
  - TLS termination
  - Subdomain routing (n8n.yourdom.com, webhooks.yourdom.com)
  - Authentication gateway
  - Webhook ingress with rate limiting

### Layer 2: n8n Control Plane
- **Location:** Hostinger stable app node or OCI primary  
- **Deployment:** Podman Quadlet  
- **Components:**
  - n8n main instance (editor, UI, credential storage)
  - PostgreSQL (workflow state, executions, metadata)
  - Redis (queue and cache)

**Environment Variables:**
```bash
N8N_HOST=n8n.yourdom.com
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_EDITOR_BASE_URL=https://n8n.yourdom.com/
N8N_WEBHOOK_URL=https://webhooks.yourdom.com/webhook/
N8N_QUEUE_MODE_ACTIVE=true
```

### Layer 3: n8n Workers
- **Location:** OCI compute or internal node  
- **Deployment:** Podman Quadlets (separate from main)  
- **Count:** 3–6 workers depending on load  
- **Responsibilities:**
  - Execute queued workflows
  - Handle async job dispatch
  - Isolate workflow execution from editor

### Layer 4: Heavy Compute Workers
- **Location:** Separate Python/Bash/MCP services  
- **Responsibilities:**
  - Document classification & OCR
  - Image tagging & analysis
  - Entity extraction & enrichment
  - Filesystem operations
  - Media transforms

**Examples:**
- `/classify-document` (Python + ML model)
- `/extract-entities` (LLM + structured output)
- `/tag-image` (Vision API + PhotoPrism sync)
- `/route-asset` (PARA logic)
- `/backup-now` (shell + logging)
- `/refresh-index` (search indexing)

### Layer 5: Canonical Data Systems
- **Paperless-ngx** (documents)
- **PhotoPrism** (images)
- **BookStack** (knowledge)
- **SQLite / Postgres** (metadata registry)
- **Object storage** (raw assets)

---

## Standard Job Contract

Every handoff between n8n and a worker uses this JSON envelope for consistency and auditability:

```json
{
  "job_id": "fffbbeeddccaabbaa1234567",
  "workflow_name": "intake.document.classify.v1",
  "source_system": "webhook|scheduler|manual",
  "asset_path": "/var/intake/document.pdf",
  "asset_type": "document|image|audio|video",
  "asset_size_bytes": 2048576,
  "project_id": "project-slug",
  "para_bucket": "project|area|resource|archive",
  "requested_action": "classify|extract|route|tag",
  "priority": "normal|high|low",
  "callback_url": "https://n8n.yourdom.com/webhook/job-complete/v1",
  "trace_context": "x-trace-id: 550e8400-e29b-41d4-a716-446655440000",
  "requested_by": "user@example.com",
  "timestamp": "2026-07-04T10:30:45Z"
}
```

**Idempotency:** Use `job_id + asset_path + requested_action` as idempotency key to prevent duplicate executions on retry.

---

## Integration Patterns

### Pattern 1: Intake Orchestration
**Trigger:** File arrives in intake folder / email with attachment / webhook upload  
**Flow:**
1. n8n receives event
2. Create job record + job_id
3. Call `/classify-document` worker
4. Receive classification + confidence + entities
5. Route file to Paperless/PhotoPrism/BookStack based on type
6. Write result to metadata registry
7. If confidence < 0.75 → escalate for review
8. Otherwise → notify user of completion

**Webhook paths:**
- `webhooks.yourdom.com/intake/folder-monitor/v1`
- `webhooks.yourdom.com/intake/email-forward/v1`
- `webhooks.yourdom.com/intake/upload/v1`

### Pattern 2: AI Orchestration Broker
**Trigger:** Manual request / workflow condition / external API call  
**Flow:**
1. n8n packages prompt + context
2. Call selected model (Claude, OpenAI, local endpoint)
3. Capture result + confidence
4. Branch on confidence:
   - High (≥0.85) → Auto-apply tag, write metadata, notify
   - Medium (0.6–0.85) → Request human review, escalate
   - Low (<0.6) → Skip, log, alert
5. Callback writes result to registry
6. Optionally sync tags to PhotoPrism/BookStack

### Pattern 3: Infrastructure Operations
**Trigger:** Daily cron / alert webhook / manual execution  
**Flow:**
1. n8n receives trigger
2. Call worker `/health-check` or `/backup-now`
3. Worker returns status + metrics
4. If anomaly or failure:
   - Create approval task
   - Wait for human decision
   - Execute remediation workflow
   - Log action + result
5. Fan-out notifications to Slack + email + logging

---

## Webhook Naming & Uniqueness

n8n requires unique webhook names across the entire instance. Use a naming convention:

```
{domain}.{purpose}.{action}.{version}
```

**Examples:**
- `intake.document.route.v1`
- `intake.image.tag.v1`
- `ai.extraction.prompt.v1`
- `infra.backup.alert.v1`
- `creative.submission.remind.v1`
- `creative.deadline.escalate.v1`

**Important:** Never use the short-lived test webhook URL in production. Always save and publish before sharing.

---

## Rollout Phases

### Phase 1: Foundation (Week 1–2)
**Goal:** Deploy n8n with correct infrastructure, no workflows yet.

- [ ] Deploy PostgreSQL Quadlet (internal node)
- [ ] Deploy Redis Quadlet (internal node, same network as n8n)
- [ ] Deploy n8n main Quadlet (Hostinger or OCI)
- [ ] Configure reverse proxy (Caddy) for TLS + subdomain routing
- [ ] Set environment variables for webhook URLs and editor base URL
- [ ] Verify n8n editor is reachable at `https://n8n.yourdom.com`
- [ ] Create admin account and set security policy
- [ ] Document n8n deployment in runbook

### Phase 2: Queue Mode & Workers (Week 3–4)
**Goal:** Enable distributed execution.

- [ ] Enable queue mode in n8n configuration
- [ ] Deploy 3 n8n worker Quadlets (OCI or compute node)
- [ ] Connect workers to Redis queue
- [ ] Verify workers pick up jobs from queue
- [ ] Set up monitoring/alerting for queue depth and worker health
- [ ] Create runbook for scaling workers up/down

### Phase 3: Golden Workflows (Week 5–8)
**Goal:** Build three proof-of-concept workflows.

#### 3a. PARA Intake Router
- [ ] Design workflow: intake trigger → classify → route
- [ ] Create `/classify-document` worker endpoint
- [ ] Build n8n workflow with error handling + retry logic
- [ ] Test with sample PDFs, images, documents
- [ ] Add human review gate for confidence < 0.75
- [ ] Document workflow in n8n
- [ ] Deploy to production + monitor

#### 3b. AI Extraction Broker
- [ ] Design workflow: trigger → package prompt → call model → evaluate
- [ ] Integrate Claude API (or OpenAI/local endpoint)
- [ ] Create `/extract-entities` worker endpoint
- [ ] Build n8n workflow with conditional branching
- [ ] Test with diverse document types
- [ ] Add callback to metadata registry
- [ ] Deploy to production + monitor

#### 3c. Infrastructure Alert Pipeline
- [ ] Design workflow: health alert → enrich → approve → execute → notify
- [ ] Integrate with backup/monitoring systems
- [ ] Create `/backup-now` or `/service-restart` worker
- [ ] Build n8n workflow with approval gates
- [ ] Test failure scenarios and escalation
- [ ] Deploy to production + monitor

### Phase 4: Heavy Compute Workers (Week 9–12)
**Goal:** Externalize compute from n8n.

- [ ] Build `/tag-image` worker (vision API + PhotoPrism integration)
- [ ] Build `/route-asset` worker (PARA logic + conflict detection)
- [ ] Build `/extract-metadata` worker (audio, video, document attributes)
- [ ] Build `/refresh-index` worker (search indexing)
- [ ] Build `/backup-vault` worker (incremental backups)
- [ ] Document each worker's API contract
- [ ] Add observability (logs, traces, metrics)
- [ ] Load test workers under expected peak load

### Phase 5: Observability & Governance (Week 13–16)
**Goal:** Make n8n production-ready and auditable.

- [ ] Set up centralized logging (JSON structured logs with job_id)
- [ ] Configure credential policy (rotate secrets, restrict scopes)
- [ ] Add approval gates for destructive actions (delete, move, publish)
- [ ] Create naming conventions document
- [ ] Build dashboard for workflow health + execution rate
- [ ] Set up PagerDuty or alert routing for critical failures
- [ ] Document operational runbook (restart, scale, debug)
- [ ] Train team on workflow authoring guidelines

---

## Operating Rules

1. **One Workflow, One Service Rule**
   - n8n orchestrates; dedicated services compute.
   - No recursive loops or large file processing in Code nodes.

2. **Canonical Logic Placement**
   - Business logic must not live solely in n8n Code nodes.
   - Use Code nodes for glue (data transformation, branching).
   - Implement domain logic in scoped worker endpoints.

3. **Auditability & Logging**
   - Every workflow execution must log its job_id + source + action.
   - Logs should be JSON structured (not prose).
   - Query logs by job_id to trace end-to-end flow.

4. **Idempotency & Retries**
   - Every write action must be idempotent (safe to retry).
   - Use `job_id + asset_path + action` as idempotency key.
   - Document idempotency handling in worker APIs.

5. **Access & Security**
   - n8n should NOT have unrestricted filesystem or shell access.
   - All external calls must use allowlisted worker endpoints.
   - Credentials must be rotated and scoped to minimal privileges.
   - Webhook paths must be unpredictable (avoid /test, /webhook, /execute).

6. **Webhook Uniqueness**
   - Every webhook must have a unique name across the instance.
   - Use the naming convention `domain.purpose.action.v{N}`.
   - Never share short-lived test URLs; use published endpoints only.

7. **Human Review Gates**
   - Insert approval checkpoints only where confidence is low or consequences are high.
   - Examples: uncertain classification, destructive file moves, publishing, infra changes.
   - Approvals must include clear context (file, action, confidence, recommendation).

8. **Error Handling**
   - Workflows must handle transient failures (retry with backoff).
   - Workflows must handle permanent failures (escalate, notify, log, move on).
   - No silent failures; every error must be logged and visible.

---

## First Implementation Targets

### Target 1: PARA Intake Router (Highest Value)
**Why:** Central to your file-management workflow.  
**What:** Ingest event → classify file → apply PARA project/area/resource/archive → route to Paperless/PhotoPrism/BookStack.  
**Timeline:** 2–3 weeks (Phase 3a).  
**Success metric:** 100+ files successfully routed with < 2% manual review rate.

### Target 2: AI Extraction Broker (High Value)
**Why:** Unlocks structured metadata from unstructured documents.  
**What:** Trigger → package prompt → call Claude/OpenAI → evaluate confidence → write result → escalate if uncertain.  
**Timeline:** 2–3 weeks (Phase 3b).  
**Success metric:** 95%+ extraction accuracy, < 1% hallucination rate.

### Target 3: Infrastructure Change Pipeline (Medium Value)
**Why:** Moves manual ops into auditable workflows.  
**What:** Alert or request → approval → execute scoped worker → verify → log → notify.  
**Timeline:** 1–2 weeks (Phase 3c).  
**Success metric:** All backup/maintenance events logged; zero unauthorized changes.

---

## Quadlet Examples

### n8n Main Quadlet
```ini
[Unit]
Description=n8n Workflow Orchestration
After=network-online.target

[Container]
Image=docker.io/n8nio/n8n:latest
ContainerName=n8n-main
Environment=N8N_HOST=n8n.yourdom.com
Environment=N8N_PORT=5678
Environment=N8N_PROTOCOL=https
Environment=N8N_EDITOR_BASE_URL=https://n8n.yourdom.com/
Environment=N8N_WEBHOOK_URL=https://webhooks.yourdom.com/webhook/
Environment=N8N_QUEUE_MODE_ACTIVE=true
Environment=N8N_DB_TYPE=postgresdb
Environment=N8N_DB_POSTGRESDB_HOST=postgres-internal
Environment=N8N_REDIS_HOST=redis-internal
Volumes=/var/lib/n8n:/home/node/.n8n:Z
PublishPort=5678:5678

[Service]
Restart=always
RestartSec=10
```

### n8n Worker Quadlet (×3)
```ini
[Unit]
Description=n8n Worker
After=network-online.target

[Container]
Image=docker.io/n8nio/n8n:latest
ContainerName=n8n-worker-1
Environment=N8N_WORKER_TYPE=worker
Environment=N8N_QUEUE_MODE_ACTIVE=true
Environment=N8N_REDIS_HOST=redis-internal
Environment=N8N_DB_POSTGRESDB_HOST=postgres-internal

[Service]
Restart=always
RestartSec=10
```

---

## Success Criteria

- ✅ n8n accessible and production-hardened behind reverse proxy
- ✅ Queue mode active with 3+ workers
- ✅ Three golden workflows live and tested
- ✅ Heavy compute workers externalized and reusable
- ✅ All executions logged with job_id for traceability
- ✅ Human review gates for uncertain/destructive actions
- ✅ Team trained on workflow authoring and operational runbooks
- ✅ Monitoring and alerting in place for worker health + queue depth

---

## Next Steps

1. **Review this plan** with the team and gather feedback on priorities.
2. **Finalize infrastructure:** Decide on primary location for n8n main (Hostinger vs. OCI).
3. **Prepare Quadlet templates** adapted to your environment.
4. **Begin Phase 1** (Foundation) immediately.
5. **Track progress** in TickTick using the task list below.

---

**Document Owner:** Shannon Love  
**Last Updated:** 2026-07-04  
**Status:** Ready for Review & Implementation
