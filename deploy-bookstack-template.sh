#!/bin/bash

###############################################################################
# BookStack PARA Template Deployment Script
# Deploys the BookStack PARA page template to your BookStack instance
# via the REST API
###############################################################################

set -e

# Configuration
BOOKSTACK_URL="${BOOKSTACK_URL:-https://bookstack.shannonjlove.cloud}"
TOKEN_ID="${BOOKSTACK_TOKEN_ID:-0GfibwREHLX4Li8eXoPrARcIkZJjs9n1}"
TOKEN_SECRET="${BOOKSTACK_TOKEN_SECRET:-5UCfFgn4GlRIIl65VaGUF6Nr8i6s4JRi}"

# BookStack destination (071019 in SYSTEM AUTOMATION > BookStack Configuration)
BOOK_ID="71"  # Will be fetched dynamically
CHAPTER_ID="71"  # Will be fetched dynamically
PAGE_TITLE="Page Template Library"
PAGE_SLUG="page-template-library"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "BookStack PARA Template Deployment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Target: $BOOKSTACK_URL"
echo "Book ID: $BOOK_ID"
echo "Chapter ID: $CHAPTER_ID"
echo ""

# Find template content
# Accept template path as first argument, or search common locations
TEMPLATE_PATH="${1:-bookstack-para-template.md}"

# If not found, try root
if [[ ! -f "$TEMPLATE_PATH" ]] && [[ -f "/bookstack-para-template.md" ]]; then
    TEMPLATE_PATH="/bookstack-para-template.md"
fi

# If still not found, try current directory fallback
if [[ ! -f "$TEMPLATE_PATH" ]]; then
    echo "❌ Error: Template file not found"
    echo "   Searched: $1, /bookstack-para-template.md, bookstack-para-template.md"
    echo ""
    echo "Usage: $0 [path/to/template.md]"
    echo "Example: $0 /bookstack-para-template.md"
    exit 1
fi

TEMPLATE_CONTENT=$(cat "$TEMPLATE_PATH")
echo "✓ Template loaded from: $TEMPLATE_PATH ($(wc -l < "$TEMPLATE_PATH") lines)"
echo ""

# Get CSRF token
echo "🔐 Authenticating with BookStack..."
CSRF_TOKEN=$(curl -s -c /tmp/bookstack-cookies.txt "$BOOKSTACK_URL/login" | grep -oP 'name="_token" value="\K[^"]+' || echo "")

if [[ -z "$CSRF_TOKEN" ]]; then
    echo "⚠️  CSRF token not found, using API token authentication instead..."
fi

# Create or update page via BookStack API
echo "📝 Deploying template page to BookStack..."

API_ENDPOINT="$BOOKSTACK_URL/api/pages"

# Create the page with proper formatting
PAGE_PAYLOAD=$(cat <<EOF
{
  "book_id": $BOOK_ID,
  "chapter_id": $CHAPTER_ID,
  "name": "$PAGE_TITLE",
  "markdown": $(echo "$TEMPLATE_CONTENT" | jq -R -s .)
}
EOF
)

# POST to BookStack API
RESPONSE=$(curl -s -X POST \
  -H "Authorization: Token $TOKEN_ID:$TOKEN_SECRET" \
  -H "Content-Type: application/json" \
  "$API_ENDPOINT" \
  -d "$PAGE_PAYLOAD")

# Check response
if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
    PAGE_ID=$(echo "$RESPONSE" | jq -r '.id')
    echo "✅ Template deployed successfully!"
    echo "   Page ID: $PAGE_ID"
    echo "   URL: $BOOKSTACK_URL/books/bookstack-configuration-workflow/page/$PAGE_SLUG"
    echo ""
else
    echo "❌ Deployment failed"
    echo "Response: $RESPONSE"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "1. Visit your BookStack instance to verify the page"
echo "2. Update cross-system links (Craft, Raindrop, TickTick, Apple Notes)"
echo "3. Use this template when creating new pages"
echo ""
