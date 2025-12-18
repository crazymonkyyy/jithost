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

    // Test resolution
    auto result = resolver.resolveRequest("/test.html");
    if (!result.markdownFile.empty && result.markdownFile.endsWith("test.md")) {
        writeln("✓ Markdown file resolution test passed!");
    } else {
        writeln("✗ Markdown file resolution test failed!");
    }

    auto result2 = resolver.resolveRequest("/layout.html");
    if (!result2.partialHtmlFile.empty && result2.partialHtmlFile.endsWith("layout.partialhtml")) {
        writeln("✓ Partial HTML file resolution test passed!");
    } else {
        writeln("✗ Partial HTML file resolution test failed!");
    }

    auto result3 = resolver.resolveRequest("/content.html");
    if (!result3.contentFile.empty && result3.contentFile.endsWith("content")) {
        writeln("✓ Content file resolution test passed!");
    } else {
        writeln("✗ Content file resolution test failed!");
    }

    // Test content retrieval
    string content1 = resolver.getContentForRequest("/test.html");
    if (content1.count("# Test Markdown") > 0) {
        writeln("✓ Content retrieval for markdown test passed!");
    } else {
        writeln("✗ Content retrieval for markdown test failed!");
    }

    // Clean up
    remove(testDir ~ "/test.md");
    remove(testDir ~ "/layout.partialhtml");
    remove(testDir ~ "/content");
    rmdir(testDir);

    writeln("File resolver testing completed.");
}