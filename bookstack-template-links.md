# BookStack PARA Template - Raindrop & Craft Links

## Live Template URLs

### Primary Template (Page ID 1692)
**BookStack URL:**
```
https://bookstack.shannonjlove.cloud/books/automation-tools/page/page-template-library
```

### Backup Template (Page ID 1690)
**BookStack URL:**
```
https://bookstack.shannonjlove.cloud/books/automation-tools/page/071019-page-template-library
```

---

## For Raindrop

**Collection:** BookStack Templates / PARA System  
**Type:** Reference / Template  
**Tags:** `#bookstack`, `#para`, `#template`, `#automation`, `#knowledge-management`

**Add to Raindrop:**
1. Go to Raindrop.io
2. Create or select collection: "BookStack Templates"
3. Add bookmark:
   - Title: `BookStack PARA Template Library`
   - URL: `https://bookstack.shannonjlove.cloud/books/automation-tools/page/page-template-library`
   - Tags: `bookstack`, `para`, `template`, `automation`
   - Description: `Standardized PARA page template for six-digit coded BookStack entries with cross-system linking (Craft, Raindrop, TickTick, Apple Notes)`

**Raindrop Collection ID:** `[raindrop://collection/PPPPPP]`

---

## For Craft

**Document Type:** Reference  
**Tags:** `#bookstack`, `#para-system`, `#templates`  
**Project:** Knowledge Management / System Automation

**Add to Craft:**
1. Go to Craft app
2. Create new document or add to System Automation folder
3. Title: `[071019] BookStack PARA Template Library`
4. Content:
   ```
   # BookStack PARA Template Library
   
   Standardized page template for all BookStack entries following SJL PARA structure
   
   ## Live Template
   - **URL:** https://bookstack.shannonjlove.cloud/books/automation-tools/page/page-template-library
   - **Page ID:** 1692
   - **Status:** Active
   
   ## Template Features
   - Metadata block with PARA code, DOCID, version tracking
   - Content sections (Overview, Key Details, Main Content, Resources)
   - Cross-system linking (Craft, Raindrop, TickTick, Apple Notes)
   - Navigation structure with bidirectional links
   - Collaboration and change log tracking
   - Automation tags for discovery and filtering
   
   ## Usage
   1. Copy template page in BookStack
   2. Replace [PPPPPP] with your six-digit PARA code
   3. Update metadata and cross-system links
   4. Maintain bidirectional linking to parent pages
   
   ## Related
   - Parent: [System Automation / 070000]
   - Book: Automation Tools (ID: 1357)
   - Template Type: Reference
   ```
5. Add tags: `#bookstack`, `#para-system`, `#templates`, `#automation`

**Craft Document ID:** `[SJL-BS-001692]` (BookStack Page 1692)

---

## Automation Scripts

### Save to Raindrop (curl)
```bash
RAINDROP_TOKEN="YOUR_RAINDROP_API_TOKEN"
COLLECTION_ID="YOUR_COLLECTION_ID"

curl -X POST https://api.raindrop.io/rest/v1/raindrops \
  -H "Authorization: Bearer $RAINDROP_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "collectionId": '$COLLECTION_ID',
    "link": "https://bookstack.shannonjlove.cloud/books/automation-tools/page/page-template-library",
    "title": "BookStack PARA Template Library",
    "tags": ["bookstack", "para", "template", "automation"],
    "note": "Standardized PARA page template for BookStack entries"
  }'
```

### Save to Craft (via Craft CLI or API)
```bash
CRAFT_TOKEN="YOUR_CRAFT_API_TOKEN"

curl -X POST https://api.craft.do/graphql \
  -H "Authorization: Bearer $CRAFT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation createDoc($input: CreateDocumentInput!) { createDocument(input: $input) { id } }",
    "variables": {
      "input": {
        "title": "[071019] BookStack PARA Template Library",
        "content": "...",
        "tags": ["bookstack", "para-system", "templates"]
      }
    }
  }'
```

---

## Manual Steps

### Raindrop
1. Visit: https://raindrop.io
2. New → Bookmark
3. Paste URL and title
4. Add tags
5. Save

### Craft
1. Open Craft app
2. Create new document in System Automation folder
3. Paste content above
4. Add tags
5. Save

---

**Created:** 2026-07-04  
**Template Version:** 1.0  
**Status:** Ready for Integration
