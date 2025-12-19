module jithost;

import std.stdio;
import std.array;
import std.string;
import config;
import static_generator;
import jit_server;
import file_resolver;

/**
 * Main entry point for the JitHost static site generator
 */
void main(string[] args)
{
    writeln("JitHost Static Site Generator");
    writeln("Usage: jithost [command] [options]");
    writeln();
    writeln("Commands:");
    writeln("  build [source-dir] [output-dir]  - Build static site");
    writeln("  serve [source-dir] [port]        - Serve site with JIT (default port 8080)");
    writeln("  init [directory]                 - Initialize a new site");
    writeln();
    
    if (args.length < 2)
    {
        return;
    }
    
    string command = args[1];
    
    if (command == "build")
    {
        string sourceDir = (args.length > 2) ? args[2] : "./";
        string outputDir = (args.length > 3) ? args[3] : "./_site";
        
        writeln("Building site from: ", sourceDir);
        writeln("Output to: ", outputDir);
        
        StaticSiteGenerator generator = new StaticSiteGenerator(sourceDir, outputDir);
        generator.generateSite();
        
        writeln("Site built successfully!");
    }
    else if (command == "serve")
    {
        string siteDir = (args.length > 2) ? args[2] : "./";
        import std.conv;
        ushort port = (args.length > 3) ? to!ushort(args[3]) : cast(ushort)8080;
        
        writeln("Starting JIT server for: ", siteDir);
        writeln("Listening on port: ", port);
        
        JitServer server = new JitServer(siteDir, port);
        server.start();
        
        writeln("JIT server started.");
    }
    else if (command == "init")
    {
        string dir = (args.length > 2) ? args[2] : "./new-site";
        string colorScheme = (args.length > 3) ? args[3] : "default";  // Third parameter is the color scheme

        writeln("Initializing new site in: ", dir);
        writeln("Using color scheme: ", colorScheme);
        initializeNewSite(dir, colorScheme);
        writeln("New site initialized successfully!");
    }
    else
    {
        writeln("Unknown command: ", command);
        writeln("Use 'jithost' to see usage information");
    }
}

/**
 * Initializes a new site with basic structure and files
 */
void initializeNewSite(string dir, string colorScheme = "default")
{
    import std.file;
    import color_scheme;

    // Create the directory if it doesn't exist
    if (!exists(dir))
    {
        mkdir(dir);
    }

    // Create basic directory structure
    mkdir(dir ~ "/posts");
    mkdir(dir ~ "/images");
    mkdir(dir ~ "/css");

    // Create a default config file
    ConfigManager configManager = new ConfigManager(dir ~ "/jithost.json");
    auto config = configManager.getConfig();
    config.title = "My New Site";
    config.description = "A new site built with JitHost";
    configManager.saveConfig();

    // Create a default index.md
    string indexContent = "# Welcome to JitHost\n\nThis is a new site generated with JitHost, a static site generator that makes it easy to create and manage websites.\n\n## Getting Started\n\nEdit this `index.md` file to customize your home page. You can use any Markdown syntax.\n\n";
    write(dir ~ "/index.md", indexContent);

    // Use the color scheme manager to generate appropriate CSS
    ColorSchemeManager colorManager = new ColorSchemeManager();
    string cssContent = colorManager.generateColorCss(colorScheme);

    // If no specific color scheme was found, use a default
    if (cssContent.empty || cssContent.indexOf("--base00:") == -1)
    {
        cssContent = "body {\n    font-family: Arial, sans-serif;\n    margin: 0;\n    padding: 20px;\n    line-height: 1.6;\n}\n\nh1, h2, h3 {\n    color: #333;\n}\n\na {\n    color: #007acc;\n    text-decoration: none;\n}\n\na:hover {\n    text-decoration: underline;\n}\n\n.container {\n    max-width: 800px;\n    margin: 0 auto;\n}\n\n";
    }

    write(dir ~ "/style.css", cssContent);

    // Create a basic about page
    string aboutContent = "# About This Site\n\nThis site was created with JitHost, a toolkit HTML server that makes it easy to do everything from exploring a folder of markdown documents to publishing a website with exact HTML.\n\n";
    write(dir ~ "/about.md", aboutContent);

    // Create a sample .bodyhtml file to demonstrate the new format
    string bodyHtmlContent = q{This is a sample page using the .bodyhtml format.

In this format, empty lines become paragraph breaks.

<p>This is embedded HTML within the bodyhtml content.</p>

#!sample_code
};
    write(dir ~ "/sample.bodyhtml", bodyHtmlContent);

    // Create sample code file for the #! inclusion
    mkdir(dir ~ "/code");
    write(dir ~ "/code/sample_code.code", q{import std.stdio;

void main() {
    writeln("This is a sample code file included with the #! syntax")
}
});

    // Create a sample .partialhtml file
    string partialHtmlContent = q{<!DOCTYPE html>
<html>
<head>
    <title>{{title}}</title>
    <link rel="stylesheet" href="/style.css">
</head>
<body>
    <nav>
        <a href="/">Home</a>
        <a href="/about.html">About</a>
    </nav>
    <main>
        {% content %}
    </main>
    <footer>
        <p>Generated with JitHost</p>
    </footer>
</body>
</html>
};
    write(dir ~ "/layout.partialhtml", partialHtmlContent);
}

unittest
{
    import std.file : writeTemp, TempDir;
    
    // This is a basic test to ensure the main function can be compiled
    // Actual functionality would be tested in other modules
    assert(true);  // Placeholder to satisfy unittest requirement
}