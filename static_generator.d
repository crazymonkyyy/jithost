#!/usr/bin/env dmd
module static_generator;

import std.stdio;
import std.file;
import std.path;
import std.string;
import std.array;
import std.datetime;
import std.algorithm;
import file_resolver;
import markdown_processor;
import partialhtml_processor;
import css_manager;
import color_scheme;

/**
 * Generates a complete static site from source files
 */
class StaticSiteGenerator
{
	FileResolver resolver;
	CssManager cssManager;
	string sourceDir;
	string outputDir;
	
	this(string srcDir, string outDir)
	{
		sourceDir = srcDir;
		outputDir = outDir;
		resolver = FileResolver();
		resolver.rootDir = srcDir;
		cssManager = CssManager();
		cssManager.rootDir = srcDir;
	}
	
	/**
	 * Generates the entire static site
	 */
	void generateSite()
	{
		// Validate CSS setup first
		auto cssValidation = cssManager.validateCssSetup();
		if (!cssValidation.isValid && cssValidation.cssPath.empty)
		{
			foreach (warning; cssValidation.warnings)
			{
				writeln("CSS Warning: ", warning);
			}
			if (cssValidation.duplicateCssFiles.length > 0)
			{
				writeln("Error: Multiple CSS files found. Only one CSS file is allowed.");
			}
		}
		
		// Create output directory if it doesn't exist
		if (!exists(outputDir))
		{
			mkdir(outputDir);
		}
		
		// Copy CSS file to output
		if (cssValidation.isValid && !cssValidation.cssPath.empty)
		{
			string cssContent = cssManager.getCssContent();
			string minifiedCss = cssManager.minifyCss(cssContent);
			std.file.write(outputDir ~ "/style.css", minifiedCss);
		}
		
		// Copy other assets (images, etc.) - for now just copy everything that's not source
		copyAssets();
		
		// Generate HTML pages from all content files
		generateAllPages();
	}
	
	/**
	 * Copies non-source assets to output directory
	 */
	private void copyAssets()
	{
		foreach (entry; dirEntries(sourceDir, SpanMode.breadth))
		{
			if (isFile(entry))
			{
				string fileName = entry.name;
				string ext = extension(fileName).toLower();
				
				// Don't copy source files that will be processed
				if (ext != ".md" && ext != ".partialhtml" && ext != ".d" && fileName != "config" && fileName != "sitegen.d")
				{
					string srcPath = entry;
					string relPath = srcPath[sourceDir.length .. $];
					string destPath = outputDir ~ relPath;
					
					// Create destination directory if needed
					string destDir = std.path.dirName(destPath);
					if (!exists(destDir))
					{
						mkdirRecurse(destDir);
					}
					
					// Copy the file
					copy(srcPath, destPath);
				}
			}
		}
	}
	
	/**
	 * Generates HTML pages from all content files
	 */
	private void generateAllPages()
	{
		// Find all content files in the source directory
		string[] contentFiles = resolver.getContentFiles("");
		
		foreach (contentFile; contentFiles)
		{
			writeln("DEBUG: Processing content file: ", contentFile);
			string ext = extension(contentFile).toLower();

			// Calculate baseName relative to sourceDir
			string relativePath = contentFile;
			if (contentFile.startsWith(sourceDir))
			{
				relativePath = contentFile[sourceDir.length .. $];
				if (relativePath.startsWith("/"))
					relativePath = relativePath[1 .. $];
			}

			string baseName = relativePath;
			if (!ext.empty)
			{
				baseName = relativePath[0 .. $ - ext.length];
			}

			string outputPath = outputDir ~ "/" ~ baseName ~ ".html";

			try
			{
				// Get content and layout for this file
				writeln("DEBUG: Requesting content for path: ", baseName ~ ".html");
				string content = resolver.getContentForRequest(baseName ~ ".html");
				writeln("DEBUG: Retrieved content (first 100 chars): ", content.length > 100 ? content[0..100] ~ "..." : content);
				string layout = resolver.getLayoutForRequest(baseName ~ ".html");
				writeln("DEBUG: Retrieved layout (first 100 chars): ", layout.length > 100 ? layout[0..100] ~ "..." : layout);
				
				import bodyhtml_processor;
				import code_includer;

				// Process content based on file type
				string processedContent = content;
				writeln("DEBUG: Processing file with extension: ", ext);
				if (ext == ".md")
				{
					writeln("DEBUG: Processing as markdown file");
					processedContent = convertMarkdownToHtmlWithEmbedding(content);
					writeln("DEBUG: Processed markdown content (first 100 chars): ", processedContent.length > 100 ? processedContent[0..100] ~ "..." : processedContent);
				}
				else if (ext == ".bodyhtml")
				{
					writeln("DEBUG: Processing as bodyhtml file");
					// Process body HTML content with code inclusions and line-break-to-paragraph processing
					string processedWithIncludes = processCodeInclusions(content, sourceDir ~ "/" ~ contentFile);
					processedContent = processBodyHtmlContent(processedWithIncludes);
				}
				else if (ext == ".partialhtml")
				{
					writeln("DEBUG: Processing as partialhtml file");
					// For partial HTML files, process them with content injection
					processedContent = processPartialHtmlFile(sourceDir ~ "/" ~ contentFile, content);
				}
				else
				{
					writeln("DEBUG: Processing as generic content file");
				}
				
				// Create the final HTML page
				string finalPage = createHtmlPage(processedContent, baseName, layout);
				
				// Create output directory if needed
				string outputDirPath = std.path.dirName(outputPath);
				if (!exists(outputDirPath))
				{
					mkdirRecurse(outputDirPath);
				}
				
				// Write the generated page
				std.file.write(outputPath, finalPage);
			}
			catch (Exception e)
			{
				writeln("Error generating page for ", contentFile, ": ", e.msg);
			}
		}
		
		// Handle directory-based pages (like /writings/ which might have writings/index.md)
		generateDirectoryPages();
	}
	
	/**
	 * Generate pages for directory-based content
	 */
	private void generateDirectoryPages()
	{
		foreach (entry; dirEntries(sourceDir, SpanMode.breadth))
		{
			if (entry.isDir)
			{
				string dirName = baseName(entry.name);
				if (dirName != "." && dirName != "..")
				{
					string indexPath = resolver.getDirectoryIndexPath(dirName);
					if (!indexPath.empty)
					{
						string relativePath = indexPath[sourceDir.length .. $];
						if (relativePath.startsWith("/"))
						{
							relativePath = relativePath[1 .. $];
						}
						
						string baseName = relativePath[0 .. $ - extension(relativePath).length];
						string outputPath = outputDir ~ "/" ~ baseName ~ ".html";
						
						try
						{
							string content = cast(string)read(indexPath);
							string layout = resolver.getLayoutForRequest(baseName ~ ".html");
							
							string processedContent = content;
							if (extension(indexPath).toLower() == ".md")
							{
								processedContent = convertMarkdownToHtmlWithEmbedding(content);
							}
							
							string finalPage = createHtmlPage(processedContent, baseName, layout);
							
							string outputDirPath = std.path.dirName(outputPath);
							if (!exists(outputDirPath))
							{
								mkdirRecurse(outputDirPath);
							}
							
							std.file.write(outputPath, finalPage);
						}
						catch (Exception e)
						{
							writeln("Error generating directory index page for ", dirName, ": ", e.msg);
						}
					}
				}
			}
		}
	}
	
	/**
	 * Creates a complete HTML page from content and layout
	 */
	private string createHtmlPage(string content, string pageTitle, string layout = "")
	{
		import std.uni;
		import std.conv;
		string cssLink = cssManager.generateCssLink();

		string title = pageTitle.replace("_", " ").replace("-", " ");
		title = "" ~ to!string(toUpper(title[0])) ~ title[1 .. $];
		
		if (layout.empty)
		{
			// Use default layout
			return q{
<html>
<head>
	<title>} ~ title ~ q{</title>
	} ~ cssLink ~ q{
</head>
<body>
	} ~ content ~ q{
</body>
</html>
};
		}
		else
		{
			// Use custom layout - the layout variable contains the HTML template content
			// Replace placeholders in the layout with actual content
			import std.string : replace;

			// Replace content placeholders in the layout with actual content
			// Support both formats: {% content %} and {{content}}
			string processedLayout = layout;
			processedLayout = processedLayout.replace("{% content %}", content);
			processedLayout = processedLayout.replace("{{content}}", content);

			// Also replace the title placeholder if it exists
			processedLayout = processedLayout.replace("{% title %}", title);
			processedLayout = processedLayout.replace("{{title}}", title);

			return processedLayout;
		}
	}
}

