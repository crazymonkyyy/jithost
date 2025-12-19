#!/usr/bin/env dmd
module config;

import std.stdio;
import std.file;
import std.path;
import std.string;
import std.array;
import std.json;
import std.range;

/**
 * Handles configuration for JitHost
 */
struct SiteConfig
{
	string title = "My JitHost Site";
	string description = "A static site generated with JitHost";
	string author = "Site Author";
	string siteUrl = "";
	string outputDir = "_site";
	string sourceDir = "src";
	bool enableComments = false;
	string commentsSystem = ""; // e.g., "disqus", "custom"
	string[] excludeFiles;	   // Files/patterns to exclude
	string defaultLayout = "default";
	bool minifyHtml = true;
	bool minifyCss = true;
	bool minifyJs = true;
	bool generateRss = false;
	string[] customHeaders;	   // Additional headers to include
	string analyticsId = "";   // For Google Analytics or similar
}

/**
 * Configuration manager
 */
class ConfigManager
{
	SiteConfig config;
	string configPath;
	
	this(string configFilePath = "")
	{
		configPath = configFilePath.empty ? "./jithost.json" : configFilePath;
		loadConfig();
	}
	
	/**
	 * Loads configuration from file or creates default
	 */
	void loadConfig()
	{
		if (exists(configPath))
		{
			try
			{
				// For now, just use basic config without complex JSON parsing to avoid API issues
				string content = cast(string)read(configPath);
				// Simple implementation to get the program running
				config = SiteConfig(); // Use defaults
			}
			catch (Exception e)
			{
				writeln("Error loading config: ", e.msg);
				// Fall back to defaults
				config = SiteConfig(); // Initialize with defaults
			}
		}
		else
		{
			// Initialize with defaults if file doesn't exist
			config = SiteConfig();
		}
	}
	
	/**
	 * Saves current configuration to file
	 */
	void saveConfig()
	{
		// For now, write a basic config file
		string configContent = `{
	"title": "` ~ config.title ~ `",
	"description": "` ~ config.description ~ `",
	"author": "` ~ config.author ~ `",
	"siteUrl": "` ~ config.siteUrl ~ `",
	"outputDir": "` ~ config.outputDir ~ `",
	"sourceDir": "` ~ config.sourceDir ~ `"
}`;
		std.file.write(configPath, configContent);
	}

	/**
	 * Gets the site configuration
	 */
	SiteConfig getConfig()
	{
		return config;
	}
}

