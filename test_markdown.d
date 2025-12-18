import markdown_processor;
import std.stdio;
import std.string;

void main()
{
    writeln("Testing Markdown Processor...");
    
    // Test basic HTML embedding
    string md = "This is markdown content.\n\n```html <class=embed>\n<div>Raw HTML here</div>\n```\n\nMore markdown.";
    string result = convertMarkdownToHtmlWithEmbedding(md);
    
    writeln("Input: ", md);
    writeln("Output: ", result);
    
    // Check if the expected elements are present
    if (result.indexOf("<div class=\"embed\">") != -1 &&
        result.indexOf("<div>Raw HTML here</div>") != -1 &&
        result.indexOf("This is markdown content.") != -1 &&
        result.indexOf("More markdown.") != -1) {
        writeln("✓ HTML embedding test passed!");
    } else {
        writeln("✗ HTML embedding test failed!");
    }

    // Test HTML embedding with ID attribute
    string md2 = "```html <id=my-div class=highlight>\n<p>Test content</p>\n```";
    string result2 = convertMarkdownToHtmlWithEmbedding(md2);

    writeln("\nTesting HTML embedding with attributes...");
    writeln("Input: ", md2);
    writeln("Output: ", result2);

    if (result2.indexOf("id=\"my-div\"") != -1 &&
        result2.indexOf("class=\"highlight\"") != -1 &&
        result2.indexOf("<p>Test content</p>") != -1) {
        writeln("✓ HTML embedding with attributes test passed!");
    } else {
        writeln("✗ HTML embedding with attributes test failed!");
    }
    
    writeln("Testing completed.");
}