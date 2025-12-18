# JitHost Project

## Project Overview

JitHost is a static site generator project for creating and serving static websites. The system consists of three main components:

1. A new static site host that primarily processes Markdown content with HTML embedding capabilities
2. Extensions to existing content
3. Cleanup and migration from the previous website implementation

### Purpose

Create a toolkit HTML server that makes it easy to do everything from exploring a folder of markdown documents to publishing a website with exact HTML.

The project draws inspiration from the ARSD library (https://github.com/adamdruppe/arsd) and aims to provide both JIT hosting and full site publishing capabilities.

## Architecture & Features

### Core Components
- **Markdown to HTML conversion**: A core function that converts Markdown files to HTML
- **Opinionated file structure**: Predefined patterns for organizing site content
- **Backwards compatibility**: Support for a new `.partialhtml` file format to maintain compatibility with the old site
- **Single CSS file**: Only one CSS file is allowed to serve as the single source of truth for styling
- **HTML embedding**: Ability to embed raw HTML within Markdown using a special syntax ```html <class=foo>```

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
The project will define formal specifications for:
- Acceptable directory layouts for content
- The "partial HTML" format for backward compatibility

### Styling Constraints
- Only one CSS file allowed per site (single source of truth)
- The system will issue warnings if duplicate styling information is detected

## Development Goals

### Testing Strategy
- Recreate the current website in a separate test folder
- Create 3 demo projects in separate folders
- Unit test Markdown to HTML conversion with string inputs

### Current Development Stage
Based on the SPEC.md, the project is in the planning/design phase with requirements defined but implementation not yet begun. Key features still need to be implemented:

- Local hosting functionality
- Markdown processing engine
- JIT hosting capabilities
- WASM embedding support
- Color extension features
- Per-file JIT processing

## Building and Running

TODO: As the implementation is not yet complete, specific build and run commands have not been established. Will need to determine based on chosen technology stack.

## Development Conventions

TODO: As the implementation has not yet begun, specific coding style and contribution guidelines have not been established. Will need to define based on chosen programming language and team preferences.

## Key Dependencies & References

- Current website: https://github.com/crazymonkyyy/crazymonkyyy.github.io
- Library inspiration: https://github.com/adamdruppe/arsd
- Planned features: color extension, CSS unification, WASM embedding, per-file JIT