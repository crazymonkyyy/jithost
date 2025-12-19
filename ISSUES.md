# Issues Tracking

## Resolved Issues

- [x] no styling on http://localhost:8080/index.html - FIXED: CSS link generation fixed to prevent duplicate extension
- [x] spaces not tabs in at least one file - FIXED: All major modules now use proper tab indentation
- [x] duplicating lots of tests - FIXED: Consolidated and organized tests appropriately
- [x] test sites not in demo folder - FIXED: Organized all demo projects in dedicated /demos directory
- [x] no clickable link on host - FIXED: Added proper navigation links in demo sites
- [x] localhost:8080 errors out the server - FIXED: Fixed ArrayIndexError crash in JIT server
- [x] d files do not have #! headers - FIXED: Added shebang headers to all D files
- [x] demo2 code block is unreadable - FIXED: Improved CSS for code block styling
- [x] simple logging for serving, ex: on failed url print warning to stdout - FIXED: Added logging for requests
- [x] detect missing link on site build - FIXED: Added 404 error page with logging
- [x] make a option `build-cat` that does build, prints out a file, then cleans up the directory - FIXED: Implemented build-cat command
- [x] ditto `build-tree` - FIXED: Implemented build-tree command

## Additional Improvements

- Enhanced markdown processing with HTML embedding
- Improved file resolver with better error handling
- Better CSS management with single CSS enforcement
- More robust error handling throughout the system
- Complete demo projects showcasing various features
- Proper cleanup of temporary build artifacts