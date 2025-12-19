#!/usr/bin/env dmd
module css_manager;

import std.stdio;
import std.file;
import std.path;
import std.string;
import std.array;
import std.regex;
import std.format;
import std.algorithm;

/**
 * Manages CSS files and enforces single CSS file constraint
 */
struct CssManager
{
	string rootDir = "./";
	string cssFileName = "style.css";
	
	/**
	 * Finds and validates CSS files in the project
	 * Returns path to the single allowed CSS file, or null if multiple found
	 */
	struct CssValidationResult
	{
		string cssPath;				 // Path to the single CSS file (if valid)
		string[] duplicateCssFiles;	 // Any additional CSS files found (violations)
		bool isValid;				 // Whether the CSS setup is valid
		string[] warnings;			 // Any warnings about CSS issues
	}
	
	CssValidationResult validateCssSetup()
	{
		CssValidationResult result;
		result.isValid = true;
		
		// Find all CSS files in the project
		string[] allCssFiles = findAllCssFiles();
		
		if (allCssFiles.length == 0)
		{
			result.warnings ~= "No CSS files found in project";
			result.isValid = false;
		}
		else if (allCssFiles.length > 1)
		{
			result.duplicateCssFiles = allCssFiles[1 .. $]; // All but the first
			result.warnings ~= "Multiple CSS files found. Only one CSS file is allowed: " ~ allCssFiles[0];
			foreach (cssFile; allCssFiles[1 .. $])
			{
				result.warnings ~= "Additional CSS file found (invalid): " ~ cssFile;
			}
			result.isValid = false;
		}
		else
		{
			// Exactly one CSS file found, check if it's the expected name
			string cssPath = allCssFiles[0];
			result.cssPath = cssPath;
			
			// Check if it's named style.css
			string fileName = baseName(cssPath);
			if (fileName != "style")
			{
				result.warnings ~= format("CSS file should be named 'style.css', found: %s", fileName ~ ".css");
			}
			
			// Check for duplicate CSS properties in the single file
			string cssContent = cast(string)read(cssPath);
			string[] cssWarnings = checkForDuplicateProperties(cssContent);
			result.warnings ~= cssWarnings;
		}
		
		return result;
	}
	
	/**
	 * Finds all CSS files in the project directory
	 */
	private string[] findAllCssFiles()
	{
		string[] cssFiles = [];
		
		foreach (entry; dirEntries(rootDir, SpanMode.breadth))
		{
			if (isFile(entry) && entry.name.endsWith(".css"))
			{
				cssFiles ~= entry.name;
			}
		}
		
		return cssFiles;
	}
	
	/**
	 * Checks CSS content for duplicate properties
	 */
	private string[] checkForDuplicateProperties(string cssContent)
	{
		string[] warnings = [];
		
		// A simple implementation to detect duplicate properties in the same rule
		auto rules = cssContent.split("}");
		foreach (rule; rules)
		{
			// Extract properties within this rule
			string[] properties = findPropertiesInRule(rule);
			string[] seenProps = [];
			
			foreach (prop; properties)
			{
				import std.algorithm;
		if (seenProps.count(prop) > 0)
				{
					warnings ~= format("Duplicate CSS property found in the same rule: %s", prop);
				}
				else
				{
					seenProps ~= prop;
				}
			}
		}
		
		return warnings;
	}
	
	/**
	 * Helper to extract CSS properties from a rule block
	 */
	private string[] findPropertiesInRule(string rule)
	{
		string[] properties = [];
		
		// Find everything between { and }
		size_t openBrace = rule.indexOf("{");
		if (openBrace != -1)
		{
			string block = rule[openBrace + 1 .. $];
			string[] declarations = splitCssDeclarations(block);
			
			foreach (declaration; declarations)
			{
				size_t colonPos = declaration.indexOf(":");
				if (colonPos != -1)
				{
					string prop = declaration[0 .. colonPos].strip();
					if (!prop.empty && !prop.startsWith("/*") && !prop.startsWith("//"))
					{
						properties ~= prop;
					}
				}
			}
		}
		
		return properties;
	}
	
	/**
	 * Split CSS declarations by semicolon, handling edge cases
	 */
	private string[] splitCssDeclarations(string block)
	{
		string[] result = [];
		string current = "";
		bool inString = false;
		char stringDelimiter = '"';
		
		foreach (i, c; block)
		{
			if ((c == '"' || c == '\'') && (i == 0 || block[i-1] != '\\'))
			{
				if (!inString)
				{
					inString = true;
					stringDelimiter = c;
				}
				else if (c == stringDelimiter)
				{
					inString = false;
				}
			}
			
			if (c == ';' && !inString)
			{
				result ~= current.strip();
				current = "";
			}
			else
			{
				current ~= c;
			}
		}
		
		if (!current.strip().empty)
		{
			result ~= current.strip();
		}
		
		return result;
	}
	
	/**
	 * Reads and returns the content of the project's CSS file
	 */
	string getCssContent()
	{
		auto validationResult = validateCssSetup();
		if (validationResult.isValid && !validationResult.cssPath.empty)
		{
			return cast(string)read(validationResult.cssPath);
		}
		return "";
	}
	
	/**
	 * Generates HTML link tag for the CSS file
	 */
	string generateCssLink()
	{
		auto validationResult = validateCssSetup();
		if (validationResult.isValid && !validationResult.cssPath.empty)
		{
			string fileName = baseName(validationResult.cssPath);
			// baseName gives us the full filename (e.g., "style.css")
			// We need to use that directly without appending .css again
			return format("<link rel=\"stylesheet\" href=\"/%s\">", fileName);
		}
		return "";
	}
	
	/**
	 * Minifies CSS by removing unnecessary whitespace
	 */
	string minifyCss(string cssContent)
	{
		// Remove comments
		string result = replaceCComments(cssContent);
		
		// Remove extra whitespace and format
		result = result
			.replace("\t", " ")
			.replace("\n", " ")
			.replace("\r", " ");
			
		// Remove spaces around special characters
		result = result
			.replace(" {", "{")
			.replace("{ ", "{")
			.replace(" }", "}")
			.replace("} ", "}")
			.replace(" ;", ";")
			.replace("; ", ";")
			.replace(" :", ":")
			.replace(": ", ":")
			.replace(" ,", ",")
			.replace(", ", ",");
		
		// Remove extra spaces
		import std.algorithm;
		result = result.split(" ").filter!(s => !s.empty).join(" ");
		
		return result;
	}
	
	/**
	 * Helper to remove C-style comments from CSS
	 */
	private string replaceCComments(string content)
	{
		import std.array;
		string result = "";
		size_t pos = 0;
		
		while (pos < content.length)
		{
			size_t commentStart = content.indexOf("/*", pos);
			if (commentStart == -1)
			{
				result ~= content[pos .. $];
				break;
			}
			
			result ~= content[pos .. commentStart];
			
			size_t commentEnd = content.indexOf("*/", commentStart + 2);
			if (commentEnd == -1)
			{
				result ~= content[commentStart .. $]; // Unclosed comment, just append
				break;
			}
			
			pos = commentEnd + 2;
		}
		
		return result;
	}
}

