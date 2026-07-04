# BookStack PARA Template - Six-Digit Coded Entry

**Template Version:** 1.0  
**Created:** 2026-07-03  
**Purpose:** Standardized page template for all BookStack entries following SJL PARA structure

---

## Page Header (Replace with actual content)

**[PPPPPP] Semantic Title**

Replace `PPPPPP` with your six-digit PARA code (e.g., `021013`, `041020`)

---

## Metadata Block

```
┌─ METADATA ─────────────────────────────────────────┐
│ PARA Code:           [PPPPPP]                       │
│ DOCID:               [SJL-XXX-000000]               │
│ Title:               [Semantic Page Title]          │
│ Status:              [active|draft|archived]        │
│ Version:             1.0                            │
│ Last Updated:        [YYYY-MM-DD]                   │
│ Sensitivity:         [public|internal|restricted]   │
│                                                      │
│ Parent Hierarchy:                                   │
│   Shelf:             [PPPPPP_PARA-ROOT-NAME]       │
│   Book:              [PPPPPP_Book-Name]            │
│   Chapter:           [PPPPPP_Chapter-Name]         │
│                                                      │
│ Created By:          [Your Name]                    │
│ Owned By:            [Owner Name]                   │
└────────────────────────────────────────────────────┘
```

---

## Content Sections

### Overview
*Brief 1-2 sentence description of what this page contains and its purpose.*

### Key Details
- **Primary Purpose:** [What this page is for]
- **Audience:** [Who needs this information]
- **Update Frequency:** [How often is this updated]
- **Related Projects:** [Links to connected work]

### Main Content
[Your actual content goes here - outline, notes, reference material, etc.]

### Process / Workflow
[If applicable: step-by-step process, workflow diagram, or checklist]

### Resources & References
- **Research:** [Raindrop collection links]
- **Tasks:** [TickTick project links]
- **Source Documents:** [Craft document links]
- **Templates:** [Reference templates]

---

## Cross-System Linking

### Craft Integration
```
Craft Links (Source of Truth):
- craft://doc/[DOCID]
- craft://file/[SJL-XXX-000000]

Status: [not linked | linked | pending]
Last Sync: [YYYY-MM-DD]
```

### Raindrop Integration
```
Research Collections:
- raindrop://collection/[PPPPPP]
- raindrop://item/[SJL-REF-000000]

Status: [no collection | linked | pending]
Last Sync: [YYYY-MM-DD]
```

### TickTick Integration
```
Task/Project Tracking:
- ticktick://project/[PPPPPP]
- ticktick://task/[SJL-TASK-000000]
- ticktick://checklist/[PPPPPP00]

Status: [not tracked | active | completed]
Last Sync: [YYYY-MM-DD]
```

### Apple Notes Integration
```
Apple Notes Companion:
- notes://folder/[PARA-ROOT]
- notes://note/[DOCID]

Status: [not synced | synced | pending]
Last Sync: [YYYY-MM-DD]
```

### Paperless Integration
```
Document Management & Archive:
- https://docs.shannonjlove.cloud/documents/[DOC_ID]
- paperless://document/[PPPPPP]

Status: [not archived | indexed | pending]
Last Sync: [YYYY-MM-DD]
```

---

## Navigation Structure

### Parent Chain
Navigate up the hierarchy:
- **[PPPPPP00] Chapter Index** > 
- **[PPPPPP0] Book Overview** > 
- **[PPPPPP] Root Shelf** >
- **[Archive/Dashboard](link)**

### Sibling Links
Related pages at the same level:
- ← **[PPPPPP-1] Previous Page**
- **[PPPPPP+1] Next Page** →
- **[PPPPPP] Related Cluster**

### Child/Related Pages
Pages that branch from this one:
- **[PPPPPP01] Sub-topic 1**
- **[PPPPPP02] Sub-topic 2**
- **[PPPPPP03] Sub-topic 3**

### Backlinks (Expected To Link Here)
Pages that should reference this page:
- **[PPPPPP-10] Parent overview** (links to this page)
- **[PPPPPP+10] Related resource** (links to this page)
- **[PP0000] Shelf index** (links to this page)

---

## Collaboration & Change Log

### Contributors
- **Creator:** [Name] ([Date])
- **Last Editor:** [Name] ([Date])
- **Reviewers:** [Names]

### Version History
| Version | Date | Editor | Changes |
|---------|------|--------|---------|
| 1.0 | [YYYY-MM-DD] | [Name] | Initial creation |
| | | | |

### Change Log (Most Recent First)
- **[YYYY-MM-DD]:** [Summary of change]
- **[YYYY-MM-DD]:** [Summary of change]

### Review Notes
[Any review comments, pending tasks, or quality notes]

---

## Tags & Labels

**PARA Category:** `[010000-090000]`  
**Content Type:** `[outline|reference|tracker|checklist|bible|index]`  
**Project Status:** `[active|planning|paused|completed|archived]`  
**Sensitivity Level:** `[public|team|internal|restricted]`  
**Priority:** `[low|medium|high|critical]`

---

## Supersession & Archival

### Current Status
- ✓ Active and in use
- ○ Draft / In development
- ○ Archived / Superseded
- ○ Moved to: [PPPPPP] [New Location]

### Archive Target (When Completed)
Retire to: **[050000]** → **[051000]** → **[051010]** [Archive Chapter]

### Provenance
- **Original Location:** [PPPPPP] [Original Path]
- **Move Date:** [If moved]
- **Reason for Archive:** [If applicable]

---

## Metadata Tags for Automation

```
#para:[PPPPPP]
#docid:SJL-XXX-000000
#status:active
#type:reference
#craft-linked:yes
#raindrop-linked:yes
#ticktick-linked:no
#apple-notes-linked:no
#paperless-linked:no
#last-sync:2026-07-03
```

---

## Footer Navigation

```
┌─────────────────────────────────────────────────────┐
← [PPPPPP-1] Previous | [PPPPPP00] Index | [PPPPPP+1] Next →
Related: [PPPPPP+10] [PPPPPP+20] [PPPPPP-10]
Craft: craft://doc/[DOCID] | Raindrop: [collection] | TickTick: [project]
Notes: notes://note/[DOCID] | Paperless: [DOC_ID]
Archive Target: [051010] | Last Updated: 2026-07-03 by [Name]
└─────────────────────────────────────────────────────┘
```

---

## Usage Instructions

1. **Copy this template** when creating a new BookStack page
2. **Replace all [BRACKETED] sections** with your actual content
3. **Maintain the PARA six-digit code** consistently across all pages
4. **Update the metadata block** at the top and footer at bottom
5. **Link cross-system references** (Craft, Raindrop, TickTick, Apple Notes)
6. **Keep version and change log current** as you edit
7. **Use the tags at bottom** for automation and discovery
8. **Verify bidirectional links** — this page should link outward, and parent pages should link back

---

## PARA Code Reference

| Code Range | Shelf Name | Purpose | Color |
|---|---|---|---|
| `010000` | INBOX | Intake & triage | Gray |
| `020000` | PROJECTS | Active outcomes | Blue |
| `030000` | AREAS | Ongoing work | Green |
| `040000` | RESOURCES | Reusable knowledge | Amber |
| `050000` | ARCHIVES | Completed work | Brown |
| `060000` | PRIVATE MEDIA | Restricted content | Plum |
| `070000` | SYSTEM AUTOMATION | Scripts & ops | Teal |
| `080000` | APPLICATION DATA | App state | Slate |
| `090000` | QUARANTINE | Unsafe/unresolved | Red |

---

**Template Created By:** Claude Code System  
**For:** shannonjlove / SJL BookStack  
**Last Updated:** 2026-07-03
