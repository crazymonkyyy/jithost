import file_resolver;
import std.stdio;
import std.file;
import std.path;
import std.string;
import std.algorithm;

void main()
{
    writeln("Testing File Resolver...");
    
    // Create a temporary directory for testing
    string testDir = "test_resolver_dir";
    if (!exists(testDir)) mkdir(testDir);
    
    // Create test files
    string mdFile = testDir ~ "/test.md";
    string partialFile = testDir ~ "/layout.partialhtml";
    string contentFile = testDir ~ "/content";
    
    std.file.write(mdFile, "# Test Markdown\nContent");
    std.file.write(partialFile, "<div>{% content %}</div>");
    std.file.write(contentFile, "Plain content file");
    
    FileResolver resolver;
    resolver.rootDir = testDir;
    
    // Debug: Print all files in testDir
    writeln("Files in test directory:");
    foreach(file; dirEntries(testDir, SpanMode.depth)) {
        writeln(" - ", file.name);
    }
    
    // Test resolution
    auto result = resolver.resolveRequest("/test.html");
    writeln("Test.html resolution result:");
    writeln("  markdownFile: ", result.markdownFile);
    writeln("  partialHtmlFile: ", result.partialHtmlFile);
    writeln("  contentFile: ", result.contentFile);
    writeln("  allFoundFiles: ", result.allFoundFiles);
    
    if (!result.markdownFile.empty && result.markdownFile.count("test.md") > 0) {
        writeln("✓ Markdown file resolution test passed!");
    } else {
        writeln("✗ Markdown file resolution test failed!");
    }
    
    auto result2 = resolver.resolveRequest("/layout.html");
    writeln("Layout.html resolution result:");
    writeln("  markdownFile: ", result2.markdownFile);
    writeln("  partialHtmlFile: ", result2.partialHtmlFile);
    writeln("  contentFile: ", result2.contentFile);
    
    if (!result2.partialHtmlFile.empty && result2.partialHtmlFile.count("layout.partialhtml") > 0) {
        writeln("✓ Partial HTML file resolution test passed!");
    } else {
        writeln("✗ Partial HTML file resolution test failed!");
    }
    
    // Clean up
    std.file.remove(testDir ~ "/test.md");
    std.file.remove(testDir ~ "/layout.partialhtml");
    std.file.remove(testDir ~ "/content");
    rmdir(testDir);
    
    writeln("File resolver testing completed.");
}