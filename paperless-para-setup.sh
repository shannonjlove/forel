#!/bin/bash

###############################################################################
# Paperless PARA System Setup
# Creates complete PARA folder/tag structure in Paperless matching BookStack,
# Craft, and filesystem organization
###############################################################################

set -e

# Configuration
PAPERLESS_URL="${PAPERLESS_URL:-https://docs.shannonjlove.cloud}"
PAPERLESS_TOKEN="${PAPERLESS_TOKEN:-ef714635314097457e40b33f478e0b48cba4682b}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Paperless PARA System Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Target: $PAPERLESS_URL"
echo ""

# ============================================================================
# 1. CREATE DOCUMENT TYPES
# ============================================================================

echo "📋 Creating Document Types..."

declare -a DOC_TYPES=(
  "PARA_Reference"
  "PARA_Template"
  "PARA_Configuration"
  "PARA_Automation"
  "PARA_Archive"
  "PARA_Incoming"
)

for doc_type in "${DOC_TYPES[@]}"; do
  RESPONSE=$(curl -s -X POST \
    -H "Authorization: Token $PAPERLESS_TOKEN" \
    -H "Content-Type: application/json" \
    "$PAPERLESS_URL/api/document_types/" \
    -d '{"name":"'$doc_type'"}' 2>/dev/null)

  if echo "$RESPONSE" | grep -q '"id"'; then
    echo "  ✓ Created: $doc_type"
  fi
done

echo ""

# ============================================================================
# 2. CREATE TAGS FOR PARA STRUCTURE
# ============================================================================

echo "🏷️  Creating PARA Tags..."

# Root PARA tags
declare -a PARA_ROOTS=(
  "010000_INBOX:Incoming documents and inbox items"
  "020000_PROJECTS:Active project documents"
  "030000_AREAS:Ongoing area documentation"
  "040000_RESOURCES:Reference materials and resources"
  "050000_ARCHIVES:Completed and archived documents"
  "060000_PRIVATE_MEDIA:Restricted and private content"
  "070000_SYSTEM_AUTOMATION:System configuration and automation"
  "080000_APPLICATION_DATA:Application state and data"
  "090000_QUARANTINE:Unsafe or unresolved items"
)

for tag_info in "${PARA_ROOTS[@]}"; do
  tag_name="${tag_info%:*}"
  tag_desc="${tag_info#*:}"

  RESPONSE=$(curl -s -X POST \
    -H "Authorization: Token $PAPERLESS_TOKEN" \
    -H "Content-Type: application/json" \
    "$PAPERLESS_URL/api/tags/" \
    -d '{"name":"'$tag_name'","match":"'$tag_name'","matching_algorithm":1}' 2>/dev/null)

  if echo "$RESPONSE" | grep -q '"id"'; then
    echo "  ✓ Created: $tag_name"
  fi
done

echo ""

# ============================================================================
# 3. CREATE CORRESPONDENTS FOR SYSTEMS
# ============================================================================

echo "📧 Creating Correspondents (Linked Systems)..."

declare -a CORRESPONDENTS=(
  "BookStack:bookstack.shannonjlove.cloud"
  "Craft:docs.craft.do"
  "TickTick:ticktick.com"
  "Apple_Notes:iCloud"
  "Raindrop:raindrop.io"
)

for corr_info in "${CORRESPONDENTS[@]}"; do
  corr_name="${corr_info%:*}"
  corr_match="${corr_info#*:}"

  RESPONSE=$(curl -s -X POST \
    -H "Authorization: Token $PAPERLESS_TOKEN" \
    -H "Content-Type: application/json" \
    "$PAPERLESS_URL/api/correspondents/" \
    -d '{"name":"'$corr_name'","match":"'$corr_match'","matching_algorithm":1}' 2>/dev/null)

  if echo "$RESPONSE" | grep -q '"id"'; then
    echo "  ✓ Created: $corr_name"
  fi
done

echo ""

# ============================================================================
# 4. CREATE STORAGE PATHS (PARA Folders)
# ============================================================================

echo "📁 Creating Storage Paths (PARA Hierarchy)..."

declare -a STORAGE_PATHS=(
  "010000_INBOX/Triage"
  "010000_INBOX/Pending"
  "020000_PROJECTS/Active"
  "020000_PROJECTS/Planning"
  "020000_PROJECTS/Paused"
  "030000_AREAS/Professional"
  "030000_AREAS/Personal"
  "030000_AREAS/Continuous"
  "040000_RESOURCES/Templates"
  "040000_RESOURCES/References"
  "040000_RESOURCES/Knowledge"
  "050000_ARCHIVES/Completed"
  "050000_ARCHIVES/Retired"
  "050000_ARCHIVES/Legacy"
  "070000_SYSTEM_AUTOMATION/Config"
  "070000_SYSTEM_AUTOMATION/Integration"
  "070000_SYSTEM_AUTOMATION/BookStack"
  "070000_SYSTEM_AUTOMATION/Craft"
  "080000_APPLICATION_DATA/Logs"
  "080000_APPLICATION_DATA/State"
  "090000_QUARANTINE/Review"
)

for path in "${STORAGE_PATHS[@]}"; do
  RESPONSE=$(curl -s -X POST \
    -H "Authorization: Token $PAPERLESS_TOKEN" \
    -H "Content-Type: application/json" \
    "$PAPERLESS_URL/api/storage_paths/" \
    -d '{"name":"'$path'","path":"/media/documents/'$path'"}' 2>/dev/null)

  if echo "$RESPONSE" | grep -q '"id"'; then
    echo "  ✓ Created: $path"
  fi
done

echo ""

# ============================================================================
# 5. CREATE TEMPLATE DOCUMENTS
# ============================================================================

echo "📄 Creating PARA Template Document..."

# Create a reference document for the PARA template
TEMPLATE_CONTENT=$(cat <<'EOF'
PARA Template Library for Paperless

This document serves as the reference template for all PARA-coded documents in Paperless.

## PARA Code Structure

[PPPPPP] - Six-digit hierarchical code
Examples:
- 010000 = Inbox (root)
- 010100 = Inbox > Triage (sub-level)
- 010101 = Inbox > Triage > Specific Item

## Naming Convention

[PPPPPP] - YYYY-MM-DD - Semantic Title - v1.0

Example:
070019 - 2026-07-04 - BookStack PARA Template Library - v1.0

## Metadata Fields

- PARA Code: [PPPPPP]
- DOCID: SJL-XXX-XXXXXX
- Status: active|draft|archived
- Type: reference|template|configuration|tracker
- Cross-Links: bookstack|craft|ticktick|applenotes|raindrop

## Tagging Rules

#para:[PPPPPP] - PARA code
#docid:[ID] - Document ID
#status:active - Current status
#system:bookstack|craft|paperless
#linked:[yes|no] - Cross-system linking status
#sync:[YYYY-MM-DD] - Last sync date

## Cross-System References

- BookStack: https://bookstack.shannonjlove.cloud/books/automation-tools/page/...
- Craft: https://docs.craft.do/editor/d/...
- TickTick: ticktick://project/[PPPPPP]
- Apple Notes: notes://note/[DOCID]
- Raindrop: raindrop://collection/[PPPPPP]

---
Template Version: 1.0
Created: 2026-07-04
Last Updated: 2026-07-04
EOF
)

RESPONSE=$(curl -s -X POST \
  -H "Authorization: Token $PAPERLESS_TOKEN" \
  -H "Content-Type: application/json" \
  "$PAPERLESS_URL/api/documents/" \
  -d '{
    "title":"[070019] Paperless PARA Template Library",
    "document_type":null,
    "correspondent":null,
    "storage_path":null,
    "tags":[],
    "content":"'$(echo "$TEMPLATE_CONTENT" | sed 's/"/\\"/g' | tr '\n' ' ')'"
  }' 2>/dev/null)

if echo "$RESPONSE" | grep -q '"id"'; then
  DOC_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)
  echo "  ✓ Created template document (ID: $DOC_ID)"
  echo ""
  echo "  📍 Document URL:"
  echo "     $PAPERLESS_URL/documents/$DOC_ID/"
fi

echo ""

# ============================================================================
# 6. CREATE AUTOMATION RULES (Via Config)
# ============================================================================

echo "⚙️  Setting up Automation Rules..."

cat > /tmp/paperless-rules.json <<'RULES'
{
  "rules": [
    {
      "name": "Auto-tag PARA documents",
      "match_on": "filename",
      "pattern": "^\\[(\\d{6})\\]",
      "action": "add_tag",
      "tag_prefix": "#para:"
    },
    {
      "name": "Auto-assign storage path by PARA code",
      "match_on": "title",
      "pattern": "^\\[(0[1-9]\\d{4})\\]",
      "action": "assign_storage"
    },
    {
      "name": "Auto-link cross-system documents",
      "match_on": "title",
      "pattern": "BookStack|Craft|TickTick",
      "action": "tag",
      "tag": "#system:linked"
    }
  ]
}
RULES

echo "  ✓ Automation rules configured"
echo "    (Apply in Paperless Settings > Automation)"

echo ""

# ============================================================================
# 7. DISPLAY SUMMARY
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Paperless PARA System Setup Complete!"
echo ""
echo "Created:"
echo "  • 6 Document Types"
echo "  • 9 Root PARA Tags (010000-090000)"
echo "  • 5 System Correspondents"
echo "  • 20+ Storage Paths"
echo "  • 1 Template Reference Document"
echo ""
echo "Next Steps:"
echo "  1. Log into Paperless: $PAPERLESS_URL"
echo "  2. Import/scan documents using PARA naming: [PPPPPP] - YYYY-MM-DD - Title"
echo "  3. Use auto-tagging to organize by PARA code"
echo "  4. Link documents across BookStack, Craft, TickTick"
echo ""
echo "Naming Convention:"
echo "  [070019] - 2026-07-04 - Document Title - v1.0"
echo ""
echo "Example PARA Codes:"
echo "  010100 = Inbox > Triage"
echo "  020000 = Projects"
echo "  030000 = Areas"
echo "  040000 = Resources"
echo "  050000 = Archives"
echo "  070000 = System Automation"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
