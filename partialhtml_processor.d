#!/usr/bin/env dmd
module partialhtml_processor;

import std.file;
import std.string;
import std.array;
import std.path;

/**
 * Processes .partialhtml files which serve as layout templates
 * similar to header.html and footer.html in the old website
 * Replicates the old behavior where content was stitched between header and footer
 */
string processPartialHtmlFile(string filePath, string content) {
	if (!exists(filePath)) {
		return content;	 // If layout doesn't exist, return just the content
	}

	try {
		string layoutTemplate = cast(string)read(filePath);
		
		import std.string : replace, indexOf;

		// Replace the content placeholder with the actual content
		// Support both the new {% content %} format and the old-style concatenation
		if (layoutTemplate.indexOf("{% content %}") != -1) {
			return replace(layoutTemplate, "{% content %}", content);
		}
		else if (layoutTemplate.indexOf("{{content}}") != -1) {
			return replace(layoutTemplate, "{{content}}", content);
		}
		else {
			// For backward compatibility with old header/footer behavior
			// Just append content to the template (similar to how header+content+footer worked)
			return layoutTemplate ~ content;
		}
	}
	catch (FileException) {
		// If we can't read the layout file, return just the content
		return content;
	}
}

/**
 * Processes raw HTML content from a .partialhtml string input
 * with the same logic as the file processing function
 */
string processPartialHtmlContent(string layoutTemplate, string content) {
	import std.string : replace, indexOf;

	// Replace content placeholders in the layout with actual content
	if (layoutTemplate.indexOf("{% content %}") != -1) {
		return replace(layoutTemplate, "{% content %}", content);
	}
	else if (layoutTemplate.indexOf("{{content}}") != -1) {
		return replace(layoutTemplate, "{{content}}", content);
	}
	else {
		// For backward compatibility with old header/footer behavior
		return layoutTemplate ~ content;
	}
}

unittest
{
	import std.string : replace;

	// Test content replacement
	string template = q{<header>Site Header</header>{% content %}<footer>Site Footer</footer>};
	string content = q{<main><h1>Main Content</h1></main>};
	string result = processPartialHtmlContent(template, content);

	assert(result.indexOf("<header>Site Header</header>") != -1);
	assert(result.indexOf("<main><h1>Main Content</h1></main>") != -1);
	assert(result.indexOf("<footer>Site Footer</footer>") != -1);
	assert(result.indexOf("{% content %}") == -1);	// Placeholder should be replaced

	// Test with different placeholder style
	string template2 = q{<header>Site Header</header>{{content}}<footer>Site Footer</footer>};
	string result2 = processPartialHtmlContent(template2, content);

	assert(result2.indexOf("<header>Site Header</header>") != -1);
	assert(result2.indexOf("<main><h1>Main Content</h1></main>") != -1);
	assert(result2.indexOf("<footer>Site Footer</footer>") != -1);
	assert(result2.indexOf("{{content}}") == -1);  // Placeholder should be replaced

	// Test with no placeholder (backward compatibility with old header/footer behavior)
	string template3 = q{<header>Fixed Header</header>};
	string result3 = processPartialHtmlContent(template3, content);
	assert(result3.indexOf("Fixed Header") != -1);
	assert(result3.indexOf("Main Content") != -1);
}
