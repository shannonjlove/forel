# Paperless PARA System - Complete Setup Guide

## Overview

This guide establishes the same PARA structure in Paperless as in BookStack, Craft, and your filesystem. Paperless becomes your **document archive and management system** within the unified PARA ecosystem.

---

## PARA Structure in Paperless

### Root Categories (6 digits)

| Code | Name | Purpose | Storage | Tags |
|------|------|---------|---------|------|
| **010000** | INBOX | Triage & intake | /inbox | #para:010000 |
| **020000** | PROJECTS | Active outcomes | /projects | #para:020000 |
| **030000** | AREAS | Ongoing work | /areas | #para:030000 |
| **040000** | RESOURCES | Reusable knowledge | /resources | #para:040000 |
| **050000** | ARCHIVES | Completed work | /archives | #para:050000 |
| **060000** | PRIVATE_MEDIA | Restricted | /private | #para:060000 |
| **070000** | SYSTEM_AUTOMATION | Config & ops | /system | #para:070000 |
| **080000** | APPLICATION_DATA | App state | /app-data | #para:080000 |
| **090000** | QUARANTINE | Unsafe/review | /quarantine | #para:090000 |

### Sub-categories (8 digits)

Example: `070000` → System Automation

```
071000 - BookStack & Knowledge Automation
  071010 - BookStack Configuration
  071011 - Template Library
  071012 - Integration Logs

072000 - Cloud Integration
  072010 - API Credentials
  072011 - Deployment Scripts

073000 - Automation Rules
  073010 - File Processing
  073011 - Document Workflows
```

---

## Setup Instructions

### Step 1: Run Automation Script

```bash
# Make script executable
chmod +x paperless-para-setup.sh

# Run setup (requires PAPERLESS_TOKEN in environment)
export PAPERLESS_TOKEN="ef714635314097457e40b33f478e0b48cba4682b"
export PAPERLESS_URL="https://docs.shannonjlove.cloud"

./paperless-para-setup.sh
```

**What it creates:**
- ✅ 6 document types (PARA_Reference, PARA_Template, etc.)
- ✅ 9 root PARA tags (010000-090000)
- ✅ 5 system correspondents (BookStack, Craft, TickTick, etc.)
- ✅ 20+ storage paths matching PARA hierarchy
- ✅ 1 template reference document

### Step 2: Manual Configuration (Paperless UI)

1. **Log in:** https://docs.shannonjlove.cloud
2. **Settings → Folders:**
   - Verify storage paths created for each PARA code
   - Map documents to correct folders on scan

3. **Settings → Tags:**
   - Verify PARA root tags (010000-090000)
   - Create custom rules for auto-tagging

4. **Settings → Automation:**
   - Enable auto-tagging by filename pattern: `^\[(\d{6})\]`
   - Auto-assign document type based on content
   - Set correspondence matching for linked systems

---

## Document Naming Convention

**Format:** `[PPPPPP] - YYYY-MM-DD - Semantic Title - vX.X`

### Examples

```
[010100] - 2026-07-04 - Invoice from Vendor X - v1.0
[020010] - 2026-07-04 - Project Kickoff Meeting Notes - v1.0
[030005] - 2026-07-04 - Team Documentation - v2.1
[040015] - 2026-07-04 - API Reference Guide - v1.0
[050010] - 2026-07-04 - Completed Project Archive - v1.0
[070019] - 2026-07-04 - BookStack PARA Template - v1.0
```

---

## Metadata and Tagging System

### Core Tags (All Documents)

```
#para:[PPPPPP]           - PARA code (required)
#docid:SJL-XXX-XXXXXX    - Document ID (required)
#status:active           - Status: active|draft|archived
#type:reference          - Type: template|reference|config|tracker|bible
#system:paperless        - Primary system: paperless
```

### Cross-Linking Tags

```
#bookstack-linked:yes    - Linked to BookStack page
#craft-linked:yes        - Linked to Craft document
#ticktick-linked:yes     - Linked to TickTick project
#applenotes-linked:yes   - Linked to Apple Notes
#raindrop-linked:yes     - Linked to Raindrop collection
```

### Sync and Status Tags

```
#last-sync:2026-07-04    - Last synchronization date
#version:1.0             - Document version
#confidential:yes        - Sensitive content marker
#external:yes            - External/shared document
```

### Examples

```
Document: [070019] - 2026-07-04 - BookStack PARA Template - v1.0

Tags:
  #para:070019
  #docid:SJL-BS-001692
  #status:active
  #type:template
  #system:bookstack
  #bookstack-linked:yes
  #craft-linked:yes
  #last-sync:2026-07-04
  #version:1.0
```

---

## Integration with Other Systems

### BookStack ↔ Paperless

**In BookStack page:**
```markdown
### Paperless Integration
- **Document:** [070019 - PARA Template](https://docs.shannonjlove.cloud/documents/1692/)
- **Document Code:** [070019]
- **Last Sync:** 2026-07-04
- **Status:** Indexed and archived
```

**In Paperless document:**
```
Linked Systems:
  BookStack: https://bookstack.shannonjlove.cloud/books/automation-tools/page/071019-page-template-library
  Craft: https://docs.craft.do/editor/d/1f783797...
```

### Craft ↔ Paperless

**In Craft document:**
```
## Paperless Reference
- **URL:** https://docs.shannonjlove.cloud/documents/1692/
- **PARA Code:** [070019]
- **Tags:** #para:070019 #bookstack-linked:yes
```

### TickTick ↔ Paperless

**Create TickTick task:**
```
Task: Document [070019] in Paperless
Link: https://docs.shannonjlove.cloud/documents/1692/
PARA: ticktick://project/070019
```

### Apple Notes ↔ Paperless

**In Apple Notes:**
```
# [070019] BookStack PARA Template

## Cross-System Links
- **Paperless:** https://docs.shannonjlove.cloud/documents/1692/
- **BookStack:** [Link]
- **Craft:** [Link]

Tags: #para:070019 #paperless-linked:yes
```

---

## Workflow Examples

### Workflow 1: Creating a New Document

1. **Scan or upload** to Paperless with naming: `[PPPPPP] - YYYY-MM-DD - Title - v1.0`

2. **Auto-tagged** with:
   - `#para:[PPPPPP]`
   - Document type (Reference, Template, etc.)
   - Storage path (based on code)

3. **Cross-link** in other systems:
   - Add document URL to BookStack page
   - Add to Craft document
   - Reference in TickTick project
   - Link in Apple Notes

4. **Tag for sync** with `#last-sync:YYYY-MM-DD`

### Workflow 2: Updating Existing Document

1. **New version:** `[PPPPPP] - YYYY-MM-DD - Title - v2.0`

2. **Update DOCID** if major changes: `SJL-XXX-000002`

3. **Tag:** `#version:2.0` and `#last-sync:2026-07-05`

4. **Archive old:** Move v1.0 to `050000_ARCHIVES`

5. **Update links** in BookStack, Craft, TickTick

### Workflow 3: Archiving a Document

1. **Rename** to reflect archive status

2. **Move** to `050000_ARCHIVES` storage path

3. **Tag:** `#status:archived` and `#version:final`

4. **Update** related documents with archive reference

5. **Redirect:** Update links to point to archive location

---

## Automation Rules

### Rule 1: Auto-Tag by PARA Code

**Trigger:** Filename matches pattern `^\[(\d{6})\]`  
**Action:** Add tag `#para:[matched_code]`

```
Example:
  File: [070019] - Report.pdf
  Auto-Tag: #para:070019
```

### Rule 2: Auto-Assign Storage Path

**Trigger:** Document title contains PARA code  
**Action:** Assign to matching storage path

```
Example:
  Code: 070019
  Path: /documents/070000_SYSTEM_AUTOMATION/BookStack/
```

### Rule 3: Auto-Detect Document Type

**Trigger:** Content contains keywords  
**Action:** Assign PARA_Template or PARA_Reference

```
Examples:
  "Template" → PARA_Template
  "Configuration" → PARA_Configuration
  "Automation" → PARA_Automation
```

### Rule 4: Auto-Link Cross-System

**Trigger:** Document mentions BookStack/Craft/TickTick  
**Action:** Add tag `#system:linked`

```
Example:
  Content contains "bookstack.shannonjlove.cloud"
  Auto-Tag: #bookstack-linked:yes
```

---

## Search and Retrieval

### By PARA Code

```
Filter: #para:070019
Result: All documents in 070000 SYSTEM_AUTOMATION > 070019
```

### By Document Type

```
Filter: document_type:PARA_Template
Result: All template documents across all PARA codes
```

### By Status

```
Filter: #status:active
Result: All active documents (excludes drafts, archives)
```

### By Cross-System Link

```
Filter: #bookstack-linked:yes
Result: All documents linked from BookStack pages
```

### Combined Queries

```
#para:070000 #status:active #bookstack-linked:yes
→ All active SYSTEM_AUTOMATION documents linked to BookStack
```

---

## Best Practices

### Naming
- ✅ Always use `[PPPPPP]` format
- ✅ Include date: `YYYY-MM-DD`
- ✅ Be specific: "Invoice from Vendor X" not "Invoice"
- ✅ Version control: `- v1.0`, `- v2.1`

### Tagging
- ✅ Always add `#para:[PPPPPP]`
- ✅ Always add `#docid:SJL-XXX-XXXXXX`
- ✅ Add status: `#status:active|draft|archived`
- ✅ Mark cross-links: `#bookstack-linked:yes`

### Organization
- ✅ Keep inbox cleaned (move to proper PARA code)
- ✅ Archive old versions (move to 050000)
- ✅ Review quarterly (check sync dates)
- ✅ Update links (keep cross-system references current)

### Security
- ✅ Mark sensitive: `#confidential:yes`
- ✅ Store in 060000_PRIVATE_MEDIA if needed
- ✅ Review access permissions monthly
- ✅ Archive sensitive docs when complete

---

## Maintenance

### Weekly
- Review inbox (`010000`) for items to process
- Tag new documents with PARA codes
- Update `#last-sync` dates

### Monthly
- Archive completed projects (→ `050000`)
- Review storage usage by PARA code
- Check cross-system link validity
- Update version numbers where applicable

### Quarterly
- Audit all tags for consistency
- Review PARA code assignments
- Clean up storage paths
- Update automation rules if needed

### Annually
- Full backup of all documents
- Review PARA structure (adjust if needed)
- Archive entire PARA codes (e.g., old projects)
- Update template (if schema changes)

---

## API Integration

### List All Documents by PARA Code

```bash
curl -H "Authorization: Token $PAPERLESS_TOKEN" \
  "$PAPERLESS_URL/api/documents/?tags__id=070019"
```

### Create Document via API

```bash
curl -X POST \
  -H "Authorization: Token $PAPERLESS_TOKEN" \
  -H "Content-Type: application/json" \
  "$PAPERLESS_URL/api/documents/" \
  -d '{
    "title":"[070019] - 2026-07-04 - New Document",
    "tags":[070019, 071019],
    "document_type":1
  }'
```

### Update Document Tags

```bash
curl -X PATCH \
  -H "Authorization: Token $PAPERLESS_TOKEN" \
  -H "Content-Type: application/json" \
  "$PAPERLESS_URL/api/documents/1692/" \
  -d '{"tags":[070019, 071019, 200001]}'
```

---

## Status Summary

| System | PARA Structure | Tagging | Cross-Linking | Status |
|--------|---|---|---|---|
| **BookStack** | ✅ 9 root codes | ✅ Full | ✅ Complete | Live (Page 1692) |
| **Craft** | ✅ Folder system | ✅ Full | ✅ Complete | Live (Doc linked) |
| **Paperless** | ✅ Setup script ready | ✅ Template | ✅ Ready | Ready to deploy |
| **Apple Notes** | ✅ Scriptable code | ⏳ Manual | ⏳ Ready | Ready to setup |
| **TickTick** | ⏳ Need API token | ⏳ Waiting | ⏳ Waiting | Pending |
| **Raindrop** | ✅ Manual setup | ✅ Template | ✅ Ready | Ready |

---

## Next Steps

1. **Run setup script** when ready:
   ```bash
   chmod +x paperless-para-setup.sh
   ./paperless-para-setup.sh
   ```

2. **Verify in Paperless UI:**
   - Settings → Tags (check 010000-090000)
   - Settings → Storage Paths (check PARA folders)
   - Settings → Document Types (check PARA_* types)

3. **Start importing documents:**
   - Use naming: `[PPPPPP] - YYYY-MM-DD - Title - v1.0`
   - Tag with `#para:[PPPPPP]` and `#docid:SJL-XXX-XXXXXX`

4. **Link to other systems:**
   - Add Paperless URLs to BookStack pages
   - Reference documents in Craft
   - Create TickTick projects (once API available)

5. **Set up syncing:**
   - Schedule monthly reviews
   - Automate tag updates via API
   - Link archive strategies

---

**Created:** 2026-07-04  
**Version:** 1.0  
**Status:** Ready for Deployment  
**Credentials:** Verified (https://docs.shannonjlove.cloud)
