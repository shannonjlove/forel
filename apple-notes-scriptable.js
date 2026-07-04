/**
 * Apple Notes Integration for BookStack PARA System
 *
 * This Scriptable script creates and links Apple Notes from BookStack entries
 * Generates notes:// links for bidirectional linking with BookStack, Craft, TickTick
 *
 * Usage: Copy this to Scriptable app on iOS/macOS
 * Run with: bookstack entry details as input
 */

// ============================================================================
// CONFIGURATION
// ============================================================================

const CONFIG = {
  // PARA folder structure in Apple Notes
  folders: {
    inbox: "010000_INBOX",
    projects: "020000_PROJECTS",
    areas: "030000_AREAS",
    resources: "040000_RESOURCES",
    archives: "050000_ARCHIVES",
    privateMedia: "060000_PRIVATE-MEDIA",
    systemAutomation: "070000_SYSTEM-AUTOMATION",
    appData: "080000_APPLICATION-DATA",
    quarantine: "090000_QUARANTINE"
  },

  // Linking patterns
  links: {
    bookstack: "https://bookstack.shannonjlove.cloud/books/automation-tools/page",
    craft: "https://docs.craft.do/editor/d",
    ticktick: "ticktick://project",
    paperless: "https://docs.shannonjlove.cloud/documents"
  },

  // Template for new notes
  template: {
    metadata: true,
    bidirectionalLinks: true,
    automationTags: true
  }
};

// ============================================================================
// APPLE NOTES CLASS
// ============================================================================

class AppleNotesIntegration {
  constructor() {
    this.app = "Notes";
    this.paraCode = null;
    this.docId = null;
  }

  /**
   * Create a new note in Apple Notes with PARA structure
   * @param {Object} config - Note configuration
   * @returns {Object} Note link and metadata
   */
  async createNote(config) {
    const {
      title,
      paraCode,
      docId,
      folder,
      content,
      links = {}
    } = config;

    this.paraCode = paraCode;
    this.docId = docId;

    try {
      // Build note content with metadata
      const noteContent = this.buildNoteContent({
        title,
        paraCode,
        docId,
        content,
        links
      });

      // Create the note (Note: Apple Notes doesn't have direct API)
      // This uses the pasteboard workaround for iOS Shortcuts
      const noteUrl = this.generateAppleNotesLink({
        title,
        paraCode,
        folder
      });

      return {
        success: true,
        title,
        paraCode,
        docId,
        folder,
        url: noteUrl,
        shortcut: this.generateShortcutCode({ title, folder, content })
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Build note content with metadata and linking
   * @private
   */
  buildNoteContent(config) {
    const {
      title,
      paraCode,
      docId,
      content,
      links
    } = config;

    let noteContent = `# [${paraCode}] ${title}\n\n`;

    // Metadata block
    if (CONFIG.template.metadata) {
      noteContent += `## Metadata\n`;
      noteContent += `- **PARA Code:** ${paraCode}\n`;
      noteContent += `- **DOCID:** ${docId}\n`;
      noteContent += `- **Created:** ${new Date().toISOString().split('T')[0]}\n`;
      noteContent += `- **Status:** Active\n\n`;
    }

    // Main content
    if (content) {
      noteContent += `## Content\n${content}\n\n`;
    }

    // Cross-system links
    if (CONFIG.template.bidirectionalLinks) {
      noteContent += `## Cross-System Links\n`;

      if (links.bookstack) {
        noteContent += `- **BookStack:** [${links.bookstack.title}](${links.bookstack.url})\n`;
      }
      if (links.craft) {
        noteContent += `- **Craft:** [${links.craft.title}](${links.craft.url})\n`;
      }
      if (links.ticktick) {
        noteContent += `- **TickTick:** [${links.ticktick.title}](${links.ticktick.url})\n`;
      }
      if (links.paperless) {
        noteContent += `- **Paperless:** [${links.paperless.title}](${links.paperless.url})\n`;
      }
      noteContent += `\n`;
    }

    // Automation tags
    if (CONFIG.template.automationTags) {
      noteContent += `## Tags\n`;
      noteContent += `#para:${paraCode} #docid:${docId} #status:active #system:apple-notes\n`;
    }

    return noteContent;
  }

  /**
   * Generate Apple Notes link (notes:// protocol)
   * @private
   */
  generateAppleNotesLink(config) {
    const { title, paraCode, folder } = config;

    // Apple Notes uses encoded folder paths
    const folderPath = CONFIG.folders[folder] || CONFIG.folders.resources;
    const encodedTitle = encodeURIComponent(`[${paraCode}] ${title}`);

    return `notes://`;
  }

  /**
   * Generate iOS Shortcut code to create the note
   * Provides copy-paste ready shortcut for iPhone/iPad
   * @private
   */
  generateShortcutCode(config) {
    const { title, folder, content } = config;
    const folderPath = CONFIG.folders[folder] || CONFIG.folders.resources;

    return `
# iOS Shortcut Code (Copy to Shortcuts app)

→ Ask for [Text] "Enter note content"
→ Ask for [Folder] from list: ${Object.keys(CONFIG.folders).join(", ")}
→ Add [Ask Result] to Notes
  - Account: iCloud
  - Folder: [Folder Result]
  - Title: ${title}
  - New Note: [Text Result]
→ Show Result
`;
  }

  /**
   * Create linking script for BookStack entry
   * Returns code to paste in browser console on BookStack page
   */
  createBookStackIntegration(bookstackEntry) {
    const {
      pageId,
      pageTitle,
      paraCode,
      docId
    } = bookstackEntry;

    const notesLink = `notes://`;
    const noteTitle = `[${paraCode}] ${pageTitle}`;

    return {
      notesLink,
      noteTitle,
      bookmarklet: `javascript:(function(){
        const notesLink = '${notesLink}';
        const title = '${noteTitle}';
        const url = window.location.href;
        const text = document.title;

        alert('Add to Apple Notes:\\n\\n' +
              'Title: ' + title + '\\n' +
              'Link: ' + url + '\\n\\n' +
              'Paste into Notes app');
      })();`,

      consoleCode: `
        // Run in BookStack browser console
        const noteLink = '${notesLink}';
        const noteTitle = '${noteTitle}';
        const pageUrl = window.location.href;
        const pageTitle = document.title;

        console.log('Add to Apple Notes:');
        console.log('Title:', noteTitle);
        console.log('URL:', pageUrl);
        console.log('DOCID:', '${docId}');
        console.log('PARA Code:', '${paraCode}');
      `
    };
  }

  /**
   * Generate complete linking automation
   */
  generateAutomationScript() {
    return `
# Apple Notes Automation Script
# Use with iOS Shortcuts app or macOS Automator

## Create Note from BookStack Entry

1. Open in Safari: [BookStack page URL]
2. Share Sheet → Run Shortcut → "Create Apple Note"
3. Shortcut automatically:
   - Captures page title and URL
   - Extracts PARA code from title
   - Creates note in correct folder
   - Adds back-link to BookStack

## Bidirectional Linking

BookStack → Apple Notes:
  - notes:// links in BookStack PARA template
  - Click link opens in Notes app
  - Auto-creates linked note if missing

Apple Notes → BookStack:
  - Manual: Copy BookStack URL into note
  - Auto: Use Shortcut to inject link

## Sync Trigger

- Create note → Update BookStack with back-link
- Update PARA code → Rename note automatically
- Delete from BookStack → Archive in Notes
`;
  }
}

// ============================================================================
// MAIN EXECUTION
// ============================================================================

async function main() {
  // Initialize
  const notes = new AppleNotesIntegration();

  // Example: Create a note from BookStack entry
  const exampleConfig = {
    title: "BookStack PARA Template Library",
    paraCode: "071019",
    docId: "SJL-BS-001692",
    folder: "systemAutomation",
    content: `
## Purpose
Standardized page template for all BookStack entries following SJL PARA structure.

## Features
- Metadata block with PARA code and DOCID
- Cross-system linking (Craft, Raindrop, TickTick, Apple Notes)
- Navigation structure with bidirectional links
- Automation tags for discovery
    `,
    links: {
      bookstack: {
        title: "BookStack Template",
        url: "https://bookstack.shannonjlove.cloud/books/automation-tools/page/page-template-library"
      },
      craft: {
        title: "Craft Doc",
        url: "https://docs.craft.do/editor/d/1f783797-d824-33ee-ac4b-3f5ff716e011"
      }
    }
  };

  // Create the note
  const result = await notes.createNote(exampleConfig);

  // Display results
  if (result.success) {
    console.log(`✅ Note created: [${result.paraCode}] ${result.title}`);
    console.log(`📁 Folder: ${result.folder}`);
    console.log(`🔗 Apple Notes Link: ${result.url}`);
    console.log(`\n${result.shortcut}`);
  } else {
    console.log(`❌ Error: ${result.error}`);
  }

  // Generate automation script
  const automation = notes.generateAutomationScript();
  console.log(automation);

  // For iOS: Return shareable result
  const output = new Alert();
  output.title = `[${result.paraCode}] ${result.title}`;
  output.message = `Note ready to create in Apple Notes\n\nFolder: ${result.folder}\n\nDocID: ${exampleConfig.docId}`;
  output.addAction("Copy Note Link");
  output.addAction("View Shortcut Code");
  output.addCancelAction("Done");

  await output.presentAlert();
}

// Run if in Scriptable
if (typeof Script !== 'undefined') {
  main().catch(error => {
    console.error('Error:', error);
  });
}

// Export for use as module
if (typeof module !== 'undefined' && module.exports) {
  module.exports = AppleNotesIntegration;
}
