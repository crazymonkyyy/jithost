module markdown_tests;

import markdown_processor;
import arsd.markdown;
import std.string;
import std.uni;

void runMarkdownTests()
{
    writeln("Running Markdown processor tests...");
    
    // Test 1: Basic markdown conversion
    string basicMd = "# Hello\n\nThis is **bold** and *italic* text.";
    string result1 = convertMarkdownToHtmlWithEmbedding(basicMd);
    assert(result1.canFind("<h1>Hello</h1>"));
    assert(result1.canFind("<strong>bold</strong>"));
    assert(result1.canFind("<em>italic</em>"));
    writeln("✓ Basic markdown conversion test passed");
    
    // Test 2: HTML embedding
    string htmlEmbedMd = "Text before.\n\n```html <class=embed-test>\n<div>Embedded HTML</div>\n```\n\nText after.";
    string result2 = convertMarkdownToHtmlWithEmbedding(htmlEmbedMd);
    assert(result2.canFind("<div class=\"embed-test\">"));
    assert(result2.canFind("<div>Embedded HTML</div>"));
    assert(result2.canFind("Text before"));
    assert(result2.canFind("Text after"));
    writeln("✓ HTML embedding test passed");
    
    // Test 3: HTML embedding with ID attribute
    string htmlEmbedWithId = "```html <id=my-div class=test-class>\n<p>Content</p>\n```";
    string result3 = convertMarkdownToHtmlWithEmbedding(htmlEmbedWithId);
    assert(result3.canFind("id=\"my-div\""));
    assert(result3.canFind("class=\"test-class\""));
    assert(result3.canFind("<p>Content</p>"));
    writeln("✓ HTML embedding with attributes test passed");
    
    // Test 4: Multiple HTML embeddings
    string multiEmbedMd = "First:\n```html <class=first>\n<div>First</div>\n```\nSecond:\n```html <class=second>\n<span>Second</span>\n```";
    string result4 = convertMarkdownToHtmlWithEmbedding(multiEmbedMd);
    assert(result4.canFind("class=\"first\""));
    assert(result4.canFind("class=\"second\""));
    assert(result4.canFind("<div>First</div>"));
    assert(result4.canFind("<span>Second</span>"));
    writeln("✓ Multiple HTML embeddings test passed");
    
    // Test 5: Regular markdown still works around HTML embeddings
    string mixedMd = "# Title\n\n```html <class=container>\n<div>HTML block</div>\n```\n\n## Subtitle\n\nMore *markdown* content.";
    string result5 = convertMarkdownToHtmlWithEmbedding(mixedMd);
    assert(result5.canFind("<h1>Title</h1>"));
    assert(result5.canFind("<div class=\"container\">"));
    assert(result5.canFind("<h2>Subtitle</h2>"));
    assert(result5.canFind("<em>markdown</em>"));
    writeln("✓ Mixed markdown and HTML test passed");
    
    writeln("All Markdown processor tests passed!");
}

unittest
{
    runMarkdownTests();
}