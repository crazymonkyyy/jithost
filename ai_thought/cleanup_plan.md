## Files to be Deleted

### Temporary Test Files
- `test_markdown.d`
- `test_file_resolver.d`
- `debug_resolver.d`
- `test_static_gen.d`
- `test_demo1.d`
- `test_main.d`
- `server_demo1.d`
- `jithost_app` (compiled binary)
- `server.log` (if it exists)

### Temporary/Development Files
- Any `.o` object files
- Any temporary compilation files
- Old backup files or temp files from development

### Duplicate/Unnecessary Documentation
- `JITHOST-SPECS.md` (if it's a duplicate of other specs)
- `SPEC.md` (if it's a duplicate of other specs)
- Any redundant specification files

### Development Artifacts
- Any temporary files created during testing that aren't part of core functionality
- Any temporary output directories created during tests (not the final demo outputs)

### Files to Keep
- `jithost.d` (main application)
- `markdown_processor.d`
- `partialhtml_processor.d`
- `file_resolver.d`
- `css_manager.d`
- `jit_server.d`
- `static_generator.d`
- `config.d`
- `color_extension.d`
- `README.md`
- `IMPLEMENTATION_PLAN.md`
- `CLEANUP_PLAN.md`
- `USER_PERSONAS.md`
- `ENHANCED_DEMOS.md`
- Demo directories and files (`demo1/`, `demo2/`, `demo3/`)
- User persona files in the users/ directory
- All core arsd-lib files (needed for functionality)