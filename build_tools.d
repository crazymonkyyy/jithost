module build_tools;

import std.stdio;
import std.file;
import std.path;
import std.array;
import std.string;
import std.algorithm;
import static_generator;

/**
 * Builds site, prints the content of the main index file, then removes the build directory
 */
void buildCat(string sourceDir, string outputDir)
{
    writeln("Running build-cat: Building site, printing index, then cleaning up...");
    
    // Build the site
    StaticSiteGenerator generator = new StaticSiteGenerator(sourceDir, outputDir);
    generator.generateSite();
    
    // Print the content of the main index file
    string indexPath = outputDir ~ "/index.html";
    if (exists(indexPath))
    {
        string content = cast(string)read(indexPath);
        writeln("=== CONTENT OF ", indexPath, " ===");
        writeln(content);
        writeln("=== END OF INDEX.HTML ===");
    }
    else
    {
        writeln("Warning: index.html not found in output directory");
        
        // Show what files exist
        foreach (entry; dirEntries(outputDir, SpanMode.depth))
        {
            if (isFile(entry)) {
                writeln(entry.name);
            }
        }
    }
    
    // Clean up - remove the output directory
    try
    {
        import std.file : exists, isDir;
        if (exists(outputDir) && isDir(outputDir))
            rmdirRecurse(outputDir);
        writeln("Build directory cleaned up: ", outputDir);
    }
    catch (Exception e)
    {
        writeln("Warning: Could not remove output directory: ", e.msg);
    }
}

/**
 * Builds site and shows the directory tree structure
 */
void buildTree(string sourceDir, string outputDir)
{
    writeln("Running build-tree: Building site and showing directory tree...");
    
    // Build the site
    StaticSiteGenerator generator = new StaticSiteGenerator(sourceDir, outputDir);
    generator.generateSite();
    
    // Show directory tree
    writeln("\n=== DIRECTORY TREE FOR ", outputDir, " ===");
    printDirectoryTree(outputDir, 0);
    
    writeln("\nBuild complete. Output in: ", outputDir);
}

/**
 * Recursively prints directory structure with indentation
 */
void printDirectoryTree(string dir, int depth)
{
    import std.file : exists, isDir, dirEntries, isFile, SpanMode;
    import std.path : baseName;
    
    if (!exists(dir) || !isDir(dir))
    {
        writeln("Directory does not exist: ", dir);
        return;
    }

    string indent = "";
    foreach(i; 0 .. depth) {
        indent ~= "  ";
    }
    
    foreach (entry; dirEntries(dir, SpanMode.breadth))
    {
        string name = entry.name;
        string baseNameOnly = baseName(name);
        
        if (isDir(name))
        {
            if (baseNameOnly != "." && baseNameOnly != "..")
            {
                writeln(indent, "├── ", baseNameOnly, "/");
                printDirectoryTree(name, depth + 1);
            }
        }
        else if(isFile(entry))
        {
            writeln(indent, "├── ", baseNameOnly);
        }
    }
}