# JitHost Technical Specification

## Overview

JitHost is a toolkit HTML server designed to make it easy to do everything from exploring a folder of markdown documents to publishing a website with exact HTML. This document provides detailed technical specifications for implementing the system.

## Table of Contents
1. [Acceptable Site File Structures](#acceptable-site-file-structures)
2. [Partial HTML Format Specification](#partial-html-format-specification)
3. [Markdown to HTML Conversion](#markdown-to-html-conversion)
4. [CSS Unification System](#css-unification-system)
5. [JIT Hosting vs Static Publishing](#jit-hosting-vs-static-publishing)
6. [File Resolution Logic](#file-resolution-logic)
7. [HTML Embedding Feature](#html-embedding-feature)

## Partial HTML Format Specification

### File Extension and Purpose
- Use the `.partialhtml` file extension to designate partial HTML content
- These files serve as layout templates and structural elements similar to the `header.html` and `footer.html` in the old website
- They should contain HTML snippets that can be combined with content from other sources (like markdown files)

### Structure Elements
- Files may contain `<head>` sections with metadata, stylesheets, and scripts
- Should support content placeholders where content from other sources can be injected
- Should define structural elements like headers, navigation, and footers
- May include special markers for dynamic content insertion

### Content Injection Patterns
Based on the old website's sitegen.d script, the system should support:
- Header insertion (similar to `header.html` in the old site)
- Content injection from `.md` or extensionless files
- Footer insertion (similar to `footer.html` in the old site)
- Support for special syntax like the `#!` code inclusion mechanism in the old site

### Backwards Compatibility
- Should be able to process files similar to the old website's extensionless content files
- Allow integration with content that follows the old pattern of content files + header/footer + sitegen.d
- Maintain the flexibility of the old system where content and structure are separated

### File Resolution Integration
- When both `foo.md` and `foo.partialhtml` exist, merge them appropriately
- When only `foo.partialhtml` exists, render as-is
- When only `foo.md` exists, use default layout or specified layout from the partialhtml system

## Acceptable Site File Structures

### Root Directory Structure

The recommended site structure should follow this pattern:

```
site-root/
├── index.md (optional)
├── index.partialhtml (optional)
├── style.css (exactly one CSS file)
├── config.json (optional configuration)
├── posts/
│   ├── article1.md
│   ├── article1.partialhtml
│   └── ...
├── about/
│   ├── index.md
│   └── index.partialhtml
└── assets/
    ├── images/
    └── ...
```

### Core File Types
- **Content files** (extensionless, `*.md`): Contain the main content in raw text or Markdown format (maintaining compatibility with old website format)
- **Partial HTML files** (`*.partialhtml`): Contain HTML snippets for layout and structural elements similar to header.html and footer.html in the old website
- **CSS file** (`style.css`): Single CSS file at the root (only one allowed)
- **Static assets**: Images, fonts, and other resources in dedicated directories

### File Naming Conventions
- Use lowercase alphanumeric characters, hyphens, and underscores
- Prefer hyphens over underscores for word separation
- Directories should contain an `index.md` or `index.partialhtml` for default routing

### Directory Structure Requirements
- Allow arbitrary nesting of directories
- Each directory may have an `index.md` for directory-based routing
- Assets should be placed in dedicated subdirectories (e.g., `assets/`, `images/`)
- Source files (`.md`, `.partialhtml`) and generated HTML should not mix arbitrarily

### Routing Patterns
- `/` → `index`, `index.md`, or `index.partialhtml` at root (in that priority order)
- `/posts/my-article/` → `posts/my-article/index`, `posts/my-article/index.md`, or `posts/my-article/index.partialhtml`
- `/posts/my-article.html` → looks for `posts/my-article`, `posts/my-article.md`, or `posts/my-article.partialhtml` (maintaining compatibility with old website)

## Markdown to HTML Conversion

### Supported Markdown Syntax
- Standard Markdown elements: headers, lists, links, images, emphasis, code blocks
- Extended syntax for tables, fenced code blocks, and strikethrough
- Frontmatter support (YAML, JSON, TOML) for metadata
- Special handling for HTML embedding blocks: `html <class=foo> ... </code>`

### HTML Embedding
- Allow raw HTML to be embedded within Markdown using special code fence syntax
- Format: ```html <class=foo> followed by HTML content and closing ```
- Embedded HTML should be preserved as-is within the generated HTML
- Support for custom attributes within the opening fence

### Conversion Process
- Parse frontmatter for metadata extraction
- Convert Markdown syntax to corresponding HTML elements
- Preserve embedded HTML blocks as-is
- Combine with layout templates and site-wide elements
- Ensure proper HTML5 compliance in output

### Content Integration
- Merge generated HTML from Markdown with layout elements
- Handle title and metadata propagation to page headers
- Link resolution for internal references
- Asset path handling for images and resources

The recommended site structure should follow this pattern:

```
site-root/
├── index.md (optional)
├── index.partialhtml (optional)
├── style.css (exactly one CSS file)
├── config.json (optional configuration)
├── posts/
│   ├── article1.md
│   ├── article1.partialhtml
│   └── ...
├── about/
│   ├── index.md
│   └── index.partialhtml
└── assets/
    ├── images/
    └── ...
```

## CSS Unification System

### Single CSS File Constraint
- The system enforces exactly one CSS file per site
- The CSS file must be named `style.css` and located at the root directory
- Any additional CSS files found should trigger an error or warning
- The system should scan for and report violations of this constraint

### CSS Validation
- Check for duplicate CSS properties and warn about overused styling information
- Validate CSS syntax to ensure no malformed rules exist
- Identify unused CSS selectors that don't match any HTML elements
- Detect conflicting CSS rules and suggest resolution

### CSS Processing
- Apply the single CSS file globally to all generated HTML pages
- Optimize CSS by removing redundant or duplicate declarations
- Minify CSS in production builds to reduce file size
- Preserve CSS comments that are marked as essential

### Styling Consistency
- Enforce consistent styling across the entire site through the single CSS file
- Warn developers when similar styles are repeated unnecessarily
- Suggest consolidation of similar CSS rules
- Provide reports on CSS duplication and overuse

### Integration
- Link the single CSS file in the `<head>` section of all generated HTML pages
- Ensure the CSS file is properly referenced in both JIT hosting and static publishing modes
- Optimize load order to ensure CSS is available before page rendering

### Core File Types
- **Markdown files** (`*.md`): Contain the main content in Markdown format
- **Partial HTML files** (`*.partialhtml`): Contain HTML snippets for layout and structural elements
- **CSS file** (`style.css`): Single CSS file at the root (only one allowed)
- **Static assets**: Images, fonts, and other resources in dedicated directories

## JIT Hosting vs Static Publishing

### JIT Hosting Mode
- Dynamically generate HTML pages on each HTTP request
- Real-time conversion from Markdown to HTML
- Serve content directly from source files without pre-building
- Ideal for development environments and live editing
- Higher CPU usage due to on-demand processing
- Immediate reflection of content changes without rebuilding

### Static Publishing Mode
- Pre-compile all Markdown files to HTML before deployment
- Generate a complete static site that can be served by any web server
- Optimized for performance and reduced server load
- Suitable for production environments
- Files are generated once and served statically
- Includes optimized assets and minified CSS/JS

### Mode Configuration
- Configurable via command-line flags or configuration file
- Default mode may be specified in `config.json`
- Both modes should share the same underlying conversion logic
- Switching between modes should not require content changes

### Feature Parity
- Both modes must support all core features (HTML embedding, CSS unification, etc.)
- File resolution logic must work identically in both modes
- Same template and layout system applies to both
- Metadata handling consistent across modes

## File Resolution Logic

### Request-to-File Mapping
- When a request for `/path/file.html` is received, look for `path/file.md` first
- If no Markdown file is found, check for other supported source formats
- Apply routing rules consistently across both JIT hosting and static modes

### Content Aggregation
- When both `file.md` and `file.partialhtml` exist, merge content appropriately
- If only `file.md` exists, use it as the primary content source
- If only `file.partialhtml` exists, use it as the primary content source
- Resolve conflicts between metadata from different source files

### Fallback Mechanisms
- Implement fallback chains for missing resources
- Provide default templates when custom ones are unavailable
- Maintain consistent behavior between development and production modes

### Path Resolution
- Normalize all file paths to prevent security vulnerabilities
- Resolve relative paths correctly for nested directory structures
- Handle symbolic links according to security policies
- Cache resolved paths to improve performance in JIT mode

## HTML Embedding Feature

### Syntax Definition
- Format: ```html <attribute=value> followed by HTML content and closing ```
- Support for multiple attributes in the opening statement
- Allow space-separated attribute assignments
- Recognize the special syntax without mistaking it for regular code blocks

### Parsing Rules
- Distinguish between regular code blocks and HTML embedding blocks
- Parse attributes from the opening statement correctly
- Extract HTML content while preserving formatting
- Validate HTML content for proper structure

### Processing Steps
- Identify embedding blocks during Markdown parsing
- Process attributes for additional behavior control
- Sanitize embedded HTML according to security policies
- Insert processed HTML directly into the content stream

### Attribute Support
- `class` attribute to assign CSS classes to wrapper elements
- `id` attribute for element identification
- Custom attributes as needed for JavaScript interaction
- Allow attribute combinations in the opening statement

### Security Considerations
- Implement configurable sanitization of embedded HTML
- Prevent injection of malicious scripts or markup
- Validate HTML against a safe subset when security mode is enabled
- Allow full HTML embedding in trusted environments
