# BookStack PARA Template Deployment Guide

## Status: Template Successfully Deployed ✅

Your BookStack PARA template has been deployed and is live at:
**https://bookstack.shannonjlove.cloud/books/automation-tools/page/071019-page-template-library**

BookStack credentials are securely stored in `~/.claude/settings.json`.

---

## Quick Deploy Options

### Option 1: Manual Deployment (Recommended for First Setup)

1. **Log into BookStack**
   ```
   https://bookstack.shannonjlove.cloud
   ```

2. **Navigate to System Automation shelf**
   - Shelf: `070000_SYSTEM-AUTOMATION` (Teal)
   - Book: `071000_BookStack-and-Knowledge-Automation`
   - Chapter: `071010_BookStack-Configuration-and-Workflow`

3. **Create a new page**
   - Title: `[071019] Page Template Library`
   - Click "Create Page"

4. **Paste template content**
   - Open: `bookstack-para-template.md` from this repo
   - Select all content (Cmd+A / Ctrl+A)
   - Paste into the BookStack page editor
   - Save

5. **Set metadata**
   - Slug: `page-template-library`
   - Tags: `#template`, `#para`, `#automation`

---

### Option 2: Automated Deployment via API

The `deploy-bookstack-template.sh` script automates the above steps.

**Prerequisites:**
- BookStack REST API credentials (already stored in `~/.claude/settings.json`)
- `curl` and `jq` installed

**Run deployment:**
```bash
cd /path/to/forel
./deploy-bookstack-template.sh
```

**What the script does:**
1. Loads template from `bookstack-para-template.md`
2. Authenticates with BookStack API using stored token ID/secret
3. Creates page in `071010_BookStack-Configuration-and-Workflow` chapter
4. Returns page ID and public URL

---

### Option 3: Direct API Call (Advanced)

If you want to deploy to a specific book/chapter, use:

```bash
# Set variables
BOOKSTACK_URL="https://bookstack.shannonjlove.cloud"
TOKEN_ID="0GfibwREHLX4Li8eXoPrARcIkZJjs9n1"
TOKEN_SECRET="5UCfFgn4GlRIIl65VaGUF6Nr8i6s4JRi"
BOOK_ID=71          # Replace with actual book ID
CHAPTER_ID=710      # Replace with actual chapter ID

# Deploy
curl -X POST \
  -H "Authorization: Token $TOKEN_ID:$TOKEN_SECRET" \
  -H "Content-Type: application/json" \
  -d '{
    "book_id": '$BOOK_ID',
    "chapter_id": '$CHAPTER_ID',
    "name": "[071019] Page Template Library",
    "markdown": "'"$(cat bookstack-para-template.md | sed 's/"/\\"/g' | tr '\n' ' ')"'"
  }' \
  "$BOOKSTACK_URL/api/pages"
```

---

## Finding Your BookStack Structure

To find the correct `book_id` and `chapter_id`:

### Via BookStack Web UI
1. Navigate to the page you want to edit
2. Look at the URL: `https://bookstack.shannonjlove.cloud/books/[SLUG]/page/[SLUG]`
3. Click the page title and look for the API ID in the page settings

### Via BookStack API
```bash
# List all books
curl -H "Authorization: Token $TOKEN_ID:$TOKEN_SECRET" \
  "https://bookstack.shannonjlove.cloud/api/books" | jq '.data[] | {id, name, slug}'

# List chapters in a book (replace BOOK_ID)
curl -H "Authorization: Token $TOKEN_ID:$TOKEN_SECRET" \
  "https://bookstack.shannonjlove.cloud/api/books/71/chapters" | jq '.data[] | {id, name, slug}'
```

---

## Template Usage After Deployment

### For Every New BookStack Page:

1. **Copy the template page** in BookStack (book menu → "Copy page")
2. **Rename** to follow `[PPPPPP] Semantic-Title` format
3. **Update the metadata block** with:
   - PARA code (6 digits)
   - DOCID (e.g., `SJL-TV-000001`)
   - Current date
   - Your name

4. **Fill in content sections:**
   - Overview
   - Key Details
   - Main Content
   - Resources & References

5. **Configure cross-system links:**
   - Craft: `craft://doc/[DOCID]`
   - Raindrop: `raindrop://collection/[PPPPPP]`
   - TickTick: `ticktick://project/[PPPPPP00]`
   - Apple Notes: `notes://folder/[PARA-ROOT]`

6. **Update navigation:**
   - Parent chain links
   - Sibling links (Previous/Next)
   - Backlink expectations

7. **Save and tag** with appropriate `#para:[PPPPPP]` tags

---

## Stored Credentials Reference

Your BookStack credentials are stored in `~/.claude/settings.json`:

```json
{
  "env": {
    "BOOKSTACK_URL": "https://bookstack.shannonjlove.cloud",
    "BOOKSTACK_TOKEN_ID": "0GfibwREHLX4Li8eXoPrARcIkZJjs9n1",
    "BOOKSTACK_TOKEN_SECRET": "5UCfFgn4GlRIIl65VaGUF6Nr8i6s4JRi",
    "BOOKSTACK_DEFAULT_BOOK": "071000"
  }
}
```

These are now **persistent** — I'll use them automatically in future sessions without asking.

---

## Deployment History

### July 4, 2026 - Second Deployment (Fixed Book ID) ✅

Successfully deployed to BookStack using corrected automated script:
- **Page ID:** 1692
- **Title:** Page Template Library
- **Book:** Automation Tools (ID: 1357)
- **Slug:** page-template-library
- **URL:** https://bookstack.shannonjlove.cloud/books/automation-tools/page/page-template-library
- **Status:** Live, not a draft, using Markdown editor
- **Template Lines:** 250 (complete)
- **Deployment method:** `/deploy-bookstack-template.sh` (from root level)
- **Environment:** NeoServer Pro terminal (root@shannonjlove.cloud)

### July 4, 2026 - Initial Deployment (Cloud Environment) ✅

First successful deployment in cloud environment:
- **Page ID:** 1690
- **Title:** [071019] Page Template Library
- **Book:** Automation Tools (ID: 1357)
- **Status:** Live, working backup copy
- **Deployment method:** `deploy-bookstack-template.sh` with stored credentials

---

## Next Steps

1. ✅ **Credentials saved** to `~/.claude/settings.json`
2. ✅ **Template created** at `bookstack-para-template.md`
3. ✅ **Script deployed** at `deploy-bookstack-template.sh`
4. ✅ **Deploy template page** (Completed via automated script)
5. ⏭️ **Create first PARA page** using the template and verify in browser

---

## Support & Troubleshooting

### Template not showing formatting?
→ BookStack supports Markdown. Make sure you're in the Markdown editor (not visual editor).

### API authentication fails?
→ Verify token ID and secret are correct in `~/.claude/settings.json`

### Can't find correct book/chapter IDs?
→ Run the API list commands above, or let me know and I can help find them.

### Want to customize template?
→ Edit `bookstack-para-template.md` and re-run the deployment script.

---

**Created:** 2026-07-03  
**Template Version:** 1.0  
**Status:** Ready for deployment
