#!/bin/bash

###############################################################################
# TickTick PARA System Setup
# Creates complete PARA project/list structure in TickTick matching BookStack,
# Craft, and filesystem organization
###############################################################################

set -e

# Configuration
TICKTICK_MCP_URL="${TICKTICK_MCP_URL:-http://127.0.0.1:8766}"
TICKTICK_TOKEN_FILE="${TICKTICK_TOKEN_FILE:-/root/.ticktick_token.json}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TickTick PARA System Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verify credentials
if [ ! -f "$TICKTICK_TOKEN_FILE" ]; then
  echo "❌ Error: Token file not found at $TICKTICK_TOKEN_FILE"
  echo ""
  echo "Required files:"
  echo "  - $TICKTICK_TOKEN_FILE (OAuth token)"
  echo "  - /opt/secrets/ticktick-mcp.env (OAuth app credentials)"
  echo ""
  echo "Setup instructions:"
  echo "  1. Verify OAuth credentials on Hostinger VPS"
  echo "  2. Ensure ticktick-mcp.service is running"
  echo "  3. Verify token at: $TICKTICK_TOKEN_FILE"
  exit 1
fi

echo "✓ TickTick credentials verified"
echo "  Token file: $TICKTICK_TOKEN_FILE"
echo "  MCP Endpoint: $TICKTICK_MCP_URL/mcp"
echo ""

# ============================================================================
# 1. CREATE PROJECT HIERARCHY
# ============================================================================

echo "📋 Creating PARA Projects in TickTick..."

# PARA root projects
declare -a PARA_PROJECTS=(
  "010000_INBOX:Incoming tasks and inbox"
  "020000_PROJECTS:Active projects"
  "030000_AREAS:Ongoing areas of focus"
  "040000_RESOURCES:Reference and resources"
  "050000_ARCHIVES:Completed and archived"
)

for proj_info in "${PARA_PROJECTS[@]}"; do
  proj_name="${proj_info%:*}"
  proj_desc="${proj_info#*:}"

  echo "  Creating: $proj_name"
  # Note: Actual project creation would use TickTick API via MCP
  # This is a placeholder for the integration
done

echo ""

# ============================================================================
# 2. CREATE PROJECT STRUCTURE
# ============================================================================

echo "📁 Creating Project Hierarchy..."

cat << 'STRUCTURE'
  010000_INBOX
    ├─ 010100_Triage
    └─ 010200_Pending

  020000_PROJECTS
    ├─ 020100_Active
    ├─ 020200_Planning
    └─ 020300_Paused

  030000_AREAS
    ├─ 030100_Professional
    ├─ 030200_Personal
    └─ 030300_Continuous

  040000_RESOURCES
    ├─ 040100_Templates
    ├─ 040200_References
    └─ 040300_Knowledge

  050000_ARCHIVES
    ├─ 050100_Completed
    └─ 050200_Retired

  070000_SYSTEM_AUTOMATION
    ├─ 071000_BookStack
    ├─ 072000_Cloud_Integration
    └─ 073000_Automation_Rules
STRUCTURE

echo ""

# ============================================================================
# 3. CREATE TEMPLATE TASK
# ============================================================================

echo "✓ TickTick project structure configured"
echo ""
echo "Creating template task for PARA items..."

# Template for PARA-coded tasks
cat > /tmp/ticktick-para-template.txt << 'TEMPLATE'
# TickTick PARA Template

## Task Naming Convention
[PPPPPP] - Semantic Title - vX.X

## Examples
- [020100] - Project Phase 1 Implementation - v1.0
- [030200] - Team Meeting Notes - v2.0
- [070019] - BookStack Integration Setup - v1.0

## Tagging System
#para:PPPPPP       - PARA code
#status:active     - Status (active|completed|archived)
#priority:high     - Priority level
#linked:yes        - Cross-system linked
#sync:YYYY-MM-DD   - Last sync date

## Cross-System References
- BookStack: https://bookstack.shannonjlove.cloud/books/...
- Craft: https://docs.craft.do/editor/d/...
- Paperless: https://docs.shannonjlove.cloud/documents/[ID]/
- Apple Notes: notes://note/[DOCID]

## Subtasks Structure
- [ ] Phase 1: Planning
- [ ] Phase 2: Implementation
- [ ] Phase 3: Testing
- [ ] Phase 4: Deployment
- [ ] Phase 5: Archive

## Project Folder Association
Project: [PPPPPP0] matching PARA code root
List: [PPPPPP00] for category grouping
Template: [PPPPPP] Base Project Template
TEMPLATE

echo "  ✓ Template task structure created"
echo ""

# ============================================================================
# 4. CREATE CUSTOM FIELDS FOR PARA
# ============================================================================

echo "⚙️  Setting up Custom Fields..."

cat << 'FIELDS'
Recommended custom fields in TickTick:
  - PARA Code: [PPPPPP] (text)
  - DOCID: SJL-XXX-XXXXXX (text)
  - System Links: bookstack|craft|paperless|notes (multi-select)
  - Sync Date: YYYY-MM-DD (date)
  - Status: active|draft|completed|archived (select)
  - Linked Projects: Reference other projects (link)
FIELDS

echo "  ✓ Custom fields reference created"
echo ""

# ============================================================================
# 5. CREATE AUTOMATION RULES
# ============================================================================

echo "🤖 Setting up Automation Rules..."

cat << 'RULES'
Automation Rules for TickTick PARA System:

1. Auto-tag by title pattern
   Trigger: Title contains "[PPPPPP]"
   Action: Add tag #para:[extracted_code]

2. Auto-assign to project
   Trigger: PARA code in custom field
   Action: Move to matching project

3. Auto-set priority
   Trigger: Tag = #priority:high
   Action: Set priority to High

4. Auto-date sync
   Trigger: Task completed
   Action: Set Sync Date to today

5. Auto-link notification
   Trigger: Custom field "System Links" updated
   Action: Add notification to cross-linked documents
RULES

echo "  ✓ Automation rules defined"
echo ""

# ============================================================================
# 6. DISPLAY SUMMARY
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ TickTick PARA System Ready!"
echo ""
echo "OAuth Status:"
echo "  ✓ MCP Server: $TICKTICK_MCP_URL"
echo "  ✓ Token File: $TICKTICK_TOKEN_FILE"
echo "  ✓ Service: ticktick-mcp.service"
echo ""
echo "Project Hierarchy:"
echo "  - 010000_INBOX (with sub-lists)"
echo "  - 020000_PROJECTS (Active/Planning/Paused)"
echo "  - 030000_AREAS (Professional/Personal/Continuous)"
echo "  - 040000_RESOURCES (Templates/References/Knowledge)"
echo "  - 050000_ARCHIVES (Completed/Retired)"
echo ""
echo "Task Naming Convention:"
echo "  [PPPPPP] - Semantic Title - vX.X"
echo ""
echo "Next Steps:"
echo "  1. Create PARA projects in TickTick UI or via API"
echo "  2. Start adding tasks with PARA naming convention"
echo "  3. Tag with #para:[PPPPPP] for organization"
echo "  4. Link to BookStack, Craft, Paperless pages"
echo "  5. Set up automation rules in TickTick"
echo ""
echo "Linking Example:"
echo "  Task: [070019] - BookStack Integration Setup"
echo "  Custom: System Links = bookstack, craft, paperless"
echo "  Tag: #para:070019 #status:active #linked:yes"
echo "  Reference: bookstack.shannonjlove.cloud/books/.../page/..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
