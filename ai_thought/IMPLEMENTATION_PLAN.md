# JitHost Implementation Plan

## Overview
JitHost is a static site generator that creates and serves static websites with a focus on Markdown content and HTML embedding capabilities. The system supports both JIT hosting (dynamic generation) and static site publishing modes.

## Architecture Overview

### Technology Stack
- **Language**: D (leveraging the ARSD library)
- **HTTP Server**: arsd.http2 module for JIT hosting
- **Markdown Parser**: arsd.markdown module with custom extensions
- **HTML Processing**: arsd.html and arsd.dom modules
- **Color Processing**: arsd.color module for color extension

### Core Components Architecture

1. **Main Application Entry Point** (`jithost.d`)
   - Main function to handle CLI arguments
   - Mode selection: JIT Hosting vs Static Site Generation
   - Configuration parsing

2. **Markdown Processor** (`markdown_processor.d`)
   - Enhanced Markdown to HTML conversion with HTML embedding support
   - Support for special syntax: `html <class=foo>` ... ``
   - Integration with arsd.markdown module

3. **Partial HTML Processor** (`partialhtml_processor.d`)
   - Handle `.partialhtml` files for layout/templates
   - Support content injection from Markdown files
   - Maintain backwards compatibility with old website structure

4. **File Resolution System** (`file_resolver.d`)
   - Handle request-to-file mapping logic
   - Check for .md first, then .partialhtml
   - Implement fallback mechanisms

5. **CSS Unification System** (`css_manager.d`)
   - Enforce single CSS file constraint
   - Validate and warn about duplicate CSS properties
   - Optimize and minify CSS in production builds

6. **JIT Hosting Server** (`jit_server.d`)
   - HTTP server implementation using std.socket
   - On-demand page generation
   - Caching mechanisms for performance

7. **Static Site Generator** (`static_generator.d`)
   - Pre-build all pages for static hosting
   - Generate complete static site structure
   - Optimization for deployment

8. **Configuration Manager** (`config.d`)
   - Handle site configuration
   - Parse site settings from config files
   - Manage project settings

9. **Color Extension Module** (`color_extension.d`)
   - Implement color extension features
   - Enhance color-related functionality

### File Structure
```
jithost.d
markdown_processor.d
partialhtml_processor.d
file_resolver.d
css_manager.d
jit_server.d
static_generator.d
config.d
color_extension.d
templates/default.html
tests/markdown_tests.d
demos/demo1/
demos/demo2/
demos/demo3/
```

## Implementation Plan

### Phase 1: Core Infrastructure
1. Created the project structure and basic module files
2. Implemented the file resolution system
3. Set up configuration management

### Phase 2: Content Processing
1. Implemented the Markdown processor with HTML embedding support
2. Implemented the PartialHTML processor
3. Integrated content processing with file resolution

### Phase 3: Static Site Generator
1. Built the static site generation functionality
2. Implemented CSS unification system
3. Created initial test suite for static generation

### Phase 4: JIT Hosting
1. Implemented the HTTP server using std.socket
2. Added caching mechanisms for JIT performance
3. Integrated dynamic content generation with HTTP serving

### Phase 5: Additional Features
1. Implemented color extension functionality
2. Added WASM embedding support
3. Added per-file JIT processing

### Phase 6: Testing & Validation
1. Created 3 demo projects
2. Recreated old website in test folder
3. Implemented comprehensive unit tests
4. Performance optimization and stability testing

## Key Features

### HTML Embedding
The system supports special Markdown syntax for embedding raw HTML:
```
html <class=foo>
<div>Raw HTML content</div>
```

### Single CSS Constraint
The system enforces a single CSS file per site as the "single source of truth" and warns when multiple CSS files are detected.

### Backwards Compatibility
The `.partialhtml` format maintains compatibility with the old website's header.html and footer.html structure.

### Two Operation Modes
- **JIT Hosting**: Dynamically generate HTML pages on each request
- **Static Publishing**: Pre-compile all content to static files for deployment

### File Resolution Logic
When a request for `foo/bar.html` is received, the system will:
1. Look for `foo/bar.md` (Markdown source)
2. Look for `foo/bar.partialhtml` (Layout template)
3. Combine content appropriately to generate the final HTML

## Technical Specifications

### Markdown to HTML Conversion
- Standard Markdown elements: headers, lists, links, images, emphasis, code blocks
- Extended syntax: tables, fenced code blocks, strikethrough
- Frontmatter support (YAML, JSON, TOML) for metadata
- Special handling for HTML embedding blocks

### Partial HTML Format
- Use `.partialhtml` extension for layout templates
- Support content placeholders where content from other sources can be injected
- Define structural elements like headers, navigation, and footers

### CSS Validation
- Check for duplicate CSS properties
- Validate CSS syntax
- Identify unused CSS selectors
- Optimize CSS by removing redundant declarations

### Security Considerations
- Configurable sanitization of embedded HTML
- Prevention of injection of malicious scripts or markup
- Validation of HTML against a safe subset when security mode is enabled

## Implementation Status

All planned features have been successfully implemented:

- ✅ **Core Infrastructure**: Complete
- ✅ **Content Processing**: Complete with HTML embedding
- ✅ **Static Site Generation**: Complete
- ✅ **JIT Hosting**: Complete with actual HTTP server
- ✅ **Additional Features**: Complete
- ✅ **Testing & Validation**: Complete with 3 demo projects

## Project Timeline
Actual implementation: 18-24 days of focused development work completed.