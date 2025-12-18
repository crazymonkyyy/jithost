# JitHost Static Site Generator

JitHost is a toolkit HTML server that makes it easy to do everything from exploring a folder of markdown documents to publishing a website with exact HTML. The system consists of three main components: a new static site host, extensions to existing content, and cleanup/migration from previous implementations.

## Architecture & Features

### Core Components
- **Markdown to HTML conversion**: Converts Markdown files to HTML with special HTML embedding support
- **Opinionated file structure**: Predefined patterns for organizing site content
- **Backwards compatibility**: Support for a new `.partialhtml` file format to maintain compatibility with the old site
- **Single CSS file**: Only one CSS file is allowed to serve as the single source of truth for styling
- **HTML embedding**: Ability to embed raw HTML within Markdown using a special syntax ````html <class=foo>```

### Site Generation Modes
The system operates in two modes:
1. **JIT Hosting**: Dynamic generation of pages on request
2. **Full Site Publishing**: Complete static site generation for deployment

### File Resolution Logic
When a request for `foo/bar.html` comes in, the system follows this lookup pattern:
- Searches for `foo/bar.md` (Markdown source)
- Searches for `foo/bar.partialhtml` (Partial HTML content)
- Creates or recreates `bar.html` by combining metadata and content from various sources

## File Formats & Specifications

### Acceptable Site File Structures
The system supports:
- Markdown files (`.md`) for content
- Partial HTML files (`.partialhtml`) for layout templates
- One CSS file (single source of truth)
- Static assets in dedicated directories

### Styling Constraints
- Only one CSS file allowed per site (single source of truth)
- The system will issue warnings if duplicate styling information is detected

## Usage

### Commands

```bash
# Build static site from source to output directory
jithost build [source-dir] [output-dir]

# Serve site with JIT (dynamic generation)
jithost serve [source-dir] [port]  # Default port 8080

# Initialize a new site with basic structure
jithost init [directory]
```

### HTML Embedding
JitHost supports special Markdown syntax for embedding raw HTML:
```
html <class=foo>
<div>Raw HTML content</div>
```

### Partial HTML Files
Use `.partialhtml` files to define layout templates with content placeholders like `{% content %}` or `{{content}}`.

### Demo Projects
- **Demo 1**: Basic site with HTML embedding features
- **Demo 2**: Advanced features with partial HTML layouts
- **Demo 3**: Complex site hierarchy with nested navigation

## Development Status

JitHost is a complete implementation with all required functionality working:

- ✅ Local hosting functionality with JIT server
- ✅ Markdown processing engine with HTML embedding
- ✅ JIT hosting capabilities (dynamic page generation)
- ✅ Color extension features
- ✅ Per-file JIT processing
- ✅ CSS unification system with single CSS enforcement
- ✅ Backwards compatibility with `.partialhtml` format
- ✅ Testing strategy with unit tests and 3 demo projects
- ✅ Old website recreation validated

## Getting Started

1. Run `jithost init mysite` to create a new site
2. Add your content as Markdown files
3. Use `jithost build mysite output` to generate static files
4. Or use `jithost serve mysite 8080` for JIT hosting

The system provides both flexibility for complex sites and simplicity for basic sites, all while maintaining a single source of truth for styling and content.

---
*For more detailed technical specifications, see SPEC.md and JITHOST-SPECS.md*