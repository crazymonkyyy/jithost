#!/usr/bin/env dmd
module markdown_processor;

import arsd.markdown;
import std.array;
import std.string;
import std.regex;

/**
 * Processes markdown content with special HTML embedding support
 * Supports syntax: ```html <class=foo> ... </code>
 */
string convertMarkdownToHtmlWithEmbedding(const(char)[] markdownContent, MarkdownFlag flags = MarkdownFlag.dialectCommonMark)
{
	// First, extract any HTML embedding blocks from the markdown
	string content = cast(string)markdownContent;
	
	import std.string : strip;

	// Find all HTML embedding blocks
	string result = "";
	size_t pos = 0;

	// Use a different approach to find and replace HTML embedding blocks
	while (pos < content.length) {
		size_t start = content.indexOf("```html", pos);
		if (start == -1) {
			result ~= content[pos .. $]; // Add remaining content
			break;
		}

		result ~= content[pos .. start]; // Add content before the match

		// Find the end of this HTML block
		size_t end = content.indexOf("```", start + 7);
		if (end == -1) {
			result ~= content[start .. $]; // If no end found, add rest as is
			break;
		}

		// Extract the HTML block (excluding the opening and closing markers)
		string blockContent = content[start .. end + 3];

		// Parse attributes part (between ```html and the first newline)
		string attrsLine = "";
		size_t newlinePos = blockContent.indexOf("\n", 7); // After ```html
		if (newlinePos != -1) {
			attrsLine = blockContent[7 .. newlinePos].strip();
		}

		// Extract HTML content (between the first newline and the closing ```)
		string htmlContent = "";
		if (newlinePos != -1) {
			htmlContent = blockContent[newlinePos + 1 .. $ - 3].strip();
		}

		// Parse attributes (for now, just class support)
		string classValue = parseAttributeValue(attrsLine, "class");
		string idValue = parseAttributeValue(attrsLine, "id");

		// Create a wrapper element with specified attributes
		string wrapperTag = "div";
		string wrapperStart = "<" ~ wrapperTag;
		if (!classValue.empty) {
			wrapperStart ~= " class=\"" ~ classValue ~ "\"";
		}
		if (!idValue.empty) {
			wrapperStart ~= " id=\"" ~ idValue ~ "\"";
		}
		wrapperStart ~= ">";

		// Add the wrapped HTML content
		result ~= wrapperStart ~ htmlContent ~ "</" ~ wrapperTag ~ ">";

		pos = end + 3; // Move past the closing ```
	}

	// Now convert the rest of the markdown normally
	return convertMarkdownToHTML(result, flags);
}

/**
 * Helper function to parse attribute values from a string like "class=foo id=bar"
 */
string parseAttributeValue(string attributeString, string attributeName)
{
	// Parse attribute manually without regex to avoid escaping issues
	string searchStr = attributeName ~ "=";
	size_t pos = attributeString.indexOf(searchStr);
	if (pos == -1) {
		return "";
	}

	pos += searchStr.length; // Move past the "attr=" part

	// Skip any whitespace
	while (pos < attributeString.length && (attributeString[pos] == ' ' || attributeString[pos] == '\t')) {
		pos++;
	}

	// Check if the value is quoted
	if (pos < attributeString.length && attributeString[pos] == '"') {
		pos++; // Skip opening quote
		size_t endPos = attributeString.indexOf('"', pos);
		if (endPos != -1) {
			return attributeString[pos .. endPos];
		}
	} else {
		// Unquoted value - find end of word
		size_t endPos = pos;
		while (endPos < attributeString.length &&
			   attributeString[endPos] != ' ' &&
			   attributeString[endPos] != '\t' &&
			   attributeString[endPos] != '>' &&
			   attributeString[endPos] != '\n') {
			endPos++;
		}
		return attributeString[pos .. endPos];
	}

	return "";
}

unittest
{
	// Test basic HTML embedding
	string md = "This is markdown content.\n\n```html <class=embed>\n<div>Raw HTML here</div>\n```\n\nMore markdown.";
	string result = convertMarkdownToHtmlWithEmbedding(md);

	// Should contain the embedded HTML wrapped in a div with class="embed"
	assert(result.indexOf("<div class=\"embed\">") != -1);
	assert(result.indexOf("<div>Raw HTML here</div>") != -1);
	assert(result.indexOf("This is markdown content.") != -1);
	assert(result.indexOf("More markdown.") != -1);
}