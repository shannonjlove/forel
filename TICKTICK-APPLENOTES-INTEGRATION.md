# TickTick & Apple Notes Integration Guide

## Part 1: TickTick Integration

### Prerequisites
TickTick API credentials (if you have them stored on Hostinger VPS):

```bash
# Check for TickTick credentials on your VPS
grep -r "TICKTICK" /root/secrets/ /opt/secrets/ 2>/dev/null
```

### Expected Environment Variables
```
TICKTICK_USERNAME=your_ticktick_email
TICKTICK_PASSWORD=your_ticktick_password
TICKTICK_API_TOKEN=your_api_token
TICKTICK_DEFAULT_PROJECT=project_id
```

### Setup Steps

1. **Get TickTick Credentials**
   - Log into TickTick account
   - Settings → Account → API Token
   - Or generate OAuth token from integrations

2. **Save Credentials** (I'll add to `~/.claude/settings.json`)
   ```json
   {
     "env": {
       "TICKTICK_USERNAME": "your_email@example.com",
       "TICKTICK_API_TOKEN": "your_token_here",
       "TICKTICK_DEFAULT_PROJECT": "project_id"
     }
   }
   ```

3. **Create TickTick Linking Protocol**
   ```
   ticktick://project/[PROJECT_ID]
   ticktick://task/[TASK_ID]
   ticktick://list/[LIST_ID]
   ```

### Integration Points

**BookStack → TickTick:**
- Create tasks from BookStack entries
- Link PARA code to TickTick projects
- Auto-create task checklists from content sections

**TickTick → BookStack:**
- Add TickTick project links in BookStack metadata
- Reference tasks in page update logs
- Create "Related Tasks" section

**Example Linking in BookStack Template:**
```markdown
## Task Tracking (TickTick Integration)

- **Project:** [PPPPPP Project](ticktick://project/[PROJECT_ID])
- **Active Tasks:** [View in TickTick](ticktick://project/[PROJECT_ID])
- **Related Checklist:** [PPPPPP00](ticktick://list/[LIST_ID])

Last Sync: [YYYY-MM-DD]
```

---

## Part 2: Apple Notes Integration with Scriptable

### What's Included

The `apple-notes-scriptable.js` file provides:

1. **AppleNotesIntegration Class**
   - Create notes with PARA metadata
   - Generate `notes://` links
   - Build bidirectional linking
   - Auto-add automation tags

2. **iOS Shortcut Code**
   - Copy-paste ready shortcuts
   - Create notes from BookStack pages
   - Extract PARA codes automatically
   - Link back to source

3. **Browser Console Integration**
   - Run on BookStack page
   - Auto-generate note link
   - Copy linking code

### Installation (iOS/macOS)

#### Step 1: Install Scriptable App
- **iOS:** Download "Scriptable" from App Store
- **macOS:** Download from App Store or Mac App Store

#### Step 2: Add Script
1. Open Scriptable app
2. Create new script
3. Copy entire `apple-notes-scriptable.js` content
4. Paste into Scriptable editor
5. Save as: `BookStack PARA - Apple Notes`

#### Step 3: Create iOS Shortcut
1. Open Shortcuts app on iOS
2. Create new shortcut
3. Add actions:
   ```
   → Ask for [Text] "Enter note content"
   → Select folder from list
   → Add to Notes (iCloud)
   → Show result
   ```

### Usage: From BookStack

#### Method 1: Manual (Fastest)
1. On BookStack page, copy title
2. Open Apple Notes
3. Create new note
4. Title: `[PPPPPP] Page Title`
5. Content: Include BookStack URL in markdown
6. Add tags: `#para:PPPPPP #bookstack`

#### Method 2: Browser Console
1. Open BookStack page
2. Open browser Developer Tools (Cmd+Option+I on Mac)
3. Go to Console tab
4. Run this code:
   ```javascript
   const note = {
     title: document.title,
     url: window.location.href,
     paraCode: document.querySelector('h1')?.innerText?.match(/\[\d+\]/)?.[0] || 'UNKNOWN'
   };
   console.log('Create Apple Note:', note);
   console.log('Title: ' + note.paraCode + ' ' + note.title);
   console.log('Paste this link: ' + note.url);
   ```

#### Method 3: iOS Shortcut Automation
1. Install Scriptable shortcut
2. In Shortcuts app, create automation:
   - Trigger: When Safari page loads
   - Action: Run Scriptable → `BookStack PARA - Apple Notes`
   - Pass: URL and page title
3. Tap share sheet → Run shortcut
4. Note auto-created in correct PARA folder

### Usage: From Apple Notes

#### Folder Structure in Notes App
Organize by PARA code:
```
📱 Apple Notes
├── 010000_INBOX
├── 020000_PROJECTS
├── 030000_AREAS
├── 040000_RESOURCES
├── 050000_ARCHIVES
├── 060000_PRIVATE-MEDIA
├── 070000_SYSTEM-AUTOMATION
├── 080000_APPLICATION-DATA
└── 090000_QUARANTINE
```

#### Add Cross-System Links to Notes
In any note, include:
```markdown
## Cross-System Links

- **BookStack:** https://bookstack.shannonjlove.cloud/books/automation-tools/page/page-template-library
- **Craft:** https://docs.craft.do/editor/d/1f783797...
- **TickTick:** ticktick://project/[PROJECT_ID]
- **Paperless:** https://docs.shannonjlove.cloud/documents/[DOC_ID]
```

---

## Part 3: Complete Bidirectional Linking

### Linking Map

```
┌─────────────────┐
│   BookStack     │
│  PARA Template  │
└────────┬────────┘
         │
         ├─→ 📱 Apple Notes (notes://)
         ├─→ ✅ TickTick (ticktick://)
         ├─→ 📄 Craft (https://docs.craft.do)
         ├─→ 📑 Paperless (https://docs.shannonjlove.cloud)
         └─→ 🔗 Raindrop (raindrop://collection/)
```

### Metadata Tags for All Systems

Use consistent tags across all platforms:
```
#para:[PPPPPP]           - PARA code
#docid:[SJL-XXX-000000]  - Document ID
#status:active           - Status (active/draft/archived)
#type:reference          - Content type
#bookstack-linked:yes    - Cross-linked status
#ticktick-linked:yes
#applenotes-linked:yes
#craft-linked:yes
#paperless-linked:yes
```

---

## Configuration & Automation

### Update BookStack Template with New Integrations

Add to template (under "Cross-System Linking"):

```markdown
### TickTick Integration
- **Project:** [PPPPPP Project](ticktick://project/[PPPPPP])
- **Active Tasks:** [View in TickTick](ticktick://project/[PPPPPP])
- **Task Checklist:** [PPPPPP00](ticktick://list/[LIST_ID])
- Last Sync: [YYYY-MM-DD]

### Apple Notes Integration
- **Note:** [notes://](notes://)
- **Folder:** [PPPPPP_PARA-NAME]
- **DOCID:** [SJL-XXX-000000]
- Last Sync: [YYYY-MM-DD]
```

### Environment Variables (Persistent Storage)

Once confirmed, add to `~/.claude/settings.json`:

```json
{
  "env": {
    "BOOKSTACK_URL": "https://bookstack.shannonjlove.cloud",
    "BOOKSTACK_TOKEN_ID": "0GfibwREHLX4Li8eXoPrARcIkZJjs9n1",
    "BOOKSTACK_TOKEN_SECRET": "5UCfFgn4GlRIIl65VaGUF6Nr8i6s4JRi",
    
    "TICKTICK_USERNAME": "your_email@ticktick.com",
    "TICKTICK_API_TOKEN": "your_token_here",
    "TICKTICK_DEFAULT_PROJECT": "project_id",
    
    "PAPERLESS_URL": "https://docs.shannonjlove.cloud",
    "PAPERLESS_TOKEN": "your_token_here",
    
    "APPLENOTES_FOLDER_PREFIX": "PARA",
    "APPLENOTES_USE_ICLOUD": true
  }
}
```

---

## Quick Start Checklist

### TickTick
- [ ] Find credentials on Hostinger VPS
- [ ] Verify API token is active
- [ ] Add to persistent settings
- [ ] Update BookStack template with TickTick section
- [ ] Test linking from BookStack → TickTick

### Apple Notes
- [ ] Install Scriptable app (iOS/macOS)
- [ ] Copy `apple-notes-scriptable.js` into Scriptable
- [ ] Create note folder structure matching PARA codes
- [ ] Test creating note from BookStack
- [ ] Set up iOS Shortcut automation (optional)

### Bidirectional Linking
- [ ] Update BookStack template with all three integrations
- [ ] Add metadata tags to notes
- [ ] Create linking maps in each system
- [ ] Test: BookStack → Apple Notes → Craft → TickTick → back to BookStack

---

**Status:** Ready for configuration  
**Created:** 2026-07-04  
**Integration Type:** Full cross-system linking with PARA structure
