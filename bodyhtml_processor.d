#!/usr/bin/env dmd
module bodyhtml_processor;

import std.file;
import std.string;
import std.array;
import std.path;

/**
 * Processes .bodyhtml files which contain HTML content without headers/footers
 * where each line becomes an HTML paragraph if it's not already HTML.
 * This is similar to the old sitegen.d behavior where content lines were used as-is
 * with empty lines becoming <p> tags.
 */
string processBodyHtmlFile(string filePath) {
	if (!exists(filePath)) {
		return "";
	}

	string content = cast(string)read(filePath);
	string[] lines = std.string.splitLines(content);
	string result = "";

	foreach (line; lines) {
		if (line.length == 0) {
			// Empty line becomes a paragraph tag, like in the original sitegen.d
			result ~= "<p>\n";
		} else if (line.length >= 2 && line[0..2] == "#!") {
			// Handle code inclusion like the original sitegen.d
			import std.path : dirName;
			string fileName = line[2..$].strip();
			string codePath = dirName(filePath) ~ "/code/" ~ fileName ~ ".code";
			try {
				import std.file : read;
				string codeContent = cast(string)read(codePath);
				result ~= "<pre>\n";
				result ~= "<div class=\"codetitle\">" ~ fileName ~ "</div>\n";
				result ~= codeContent ~ "\n";
				result ~= "</pre>\n";
			} catch (Exception e) {
				// If code file doesn't exist, just include the title
				result ~= "<pre>\n";
				result ~= "<div class=\"codetitle\">" ~ fileName ~ "</div>\n";
				result ~= "</pre>\n";
			}
		} else {
			// Regular content line - output as is
			result ~= line ~ "\n";
		}
	}

	return result;
}

/**
 * Processes raw HTML content from a .bodyhtml string input
 * with the same logic as the file processing function
 */
string processBodyHtmlContent(string content) {
	import std.string : splitLines;

	string[] lines = splitLines(content);
	string result = "";

	foreach (line; lines) {
		if (line.length == 0) {
			// Empty line becomes a paragraph tag
			result ~= "<p>\n";
		} else if (line.length >= 2 && line[0..2] == "#!") {
			// Handle code inclusion like the original sitegen.d
			string fileName = line[2..$].strip();
			// For content processing without file context, we just create title
			result ~= "<pre>\n";
			result ~= "<div class=\"codetitle\">" ~ fileName ~ "</div>\n";
			result ~= "</pre>\n";
		} else {
			// Regular content line - output as is
			result ~= line ~ "\n";
		}
	}

	return result;
}

unittest {
	// Test basic line processing
	string testContent = q{First line

Second line with more text
Third line};

	string result = processBodyHtmlContent(testContent);
	assert(result.canFind("First line"));
	assert(result.canFind("<p>"));	// Empty line should become <p>
	assert(result.canFind("Second line with more text"));
	assert(result.canFind("Third line"));
}
