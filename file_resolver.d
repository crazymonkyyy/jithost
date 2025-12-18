module file_resolver;

import std.file;
import std.path;
import std.string;
import std.array;

/**
 * Handles file resolution logic for mapping requests to source files
 */
struct FileResolver
{
    string rootDir = "./";
    
    /**
     * Resolves a request path to the appropriate source files
     * Follows the pattern: look for .md first, then .partialhtml, then extensionless
     */
    struct ResolutionResult
    {
        string markdownFile;      // .md file path if found
        string partialHtmlFile;   // .partialhtml file path if found  
        string contentFile;       // extensionless file path if found
        string[] allFoundFiles;   // all source files found for this request
    }
    
    ResolutionResult resolveRequest(string requestPath)
    {
        ResolutionResult result;
        
        // Remove .html extension if present in request
        string cleanPath = requestPath;
        if (cleanPath.endsWith(".html"))
        {
            cleanPath = cleanPath[0 .. $ - 5]; // Remove .html
        }
        
        // Build full paths
        string markdownPath = buildPath(rootDir, cleanPath ~ ".md");
        string partialHtmlPath = buildPath(rootDir, cleanPath ~ ".partialhtml");
        string contentPath = buildPath(rootDir, cleanPath);
        
        // Check which files exist
        if (exists(markdownPath))
        {
            result.markdownFile = markdownPath;
            result.allFoundFiles ~= markdownPath;
        }
        
        if (exists(partialHtmlPath))
        {
            result.partialHtmlFile = partialHtmlPath;
            result.allFoundFiles ~= partialHtmlPath;
        }
        
        if (exists(contentPath) && !isDir(contentPath))
        {
            result.contentFile = contentPath;
            result.allFoundFiles ~= contentPath;
        }
        
        return result;
    }
    
    /**
     * Gets content from the best available source for a given request
     */
    string getContentForRequest(string requestPath)
    {
        auto resolution = resolveRequest(requestPath);
        
        // Priority order: markdown > content file > partialhtml
        if (!resolution.markdownFile.empty)
        {
            return cast(string)read(resolution.markdownFile);
        }
        else if (!resolution.contentFile.empty)
        {
            return cast(string)read(resolution.contentFile);
        }
        else if (!resolution.partialHtmlFile.empty)
        {
            return cast(string)read(resolution.partialHtmlFile);
        }
        
        // If no files found, return empty string
        return "";
    }
    
    /**
     * Gets the appropriate layout/partial HTML for a request
     */
    string getLayoutForRequest(string requestPath)
    {
        auto resolution = resolveRequest(requestPath);
        
        // If we have a partial HTML file, return its content
        if (!resolution.partialHtmlFile.empty)
        {
            return cast(string)read(resolution.partialHtmlFile);
        }
        
        // Otherwise, return empty string (will use default layout)
        return "";
    }
    
    /**
     * Lists all content files in a directory
     */
    string[] getContentFiles(string dirPath)
    {
        string[] result = [];
        
        foreach (entry; dirEntries(buildPath(rootDir, dirPath), SpanMode.breadth))
        {
            if (isFile(entry))
            {
                string ext = extension(entry.name);
                string name = entry.name;
                
                // Look for content files: .md, .partialhtml, or extensionless
                if (ext == ".md" || ext == ".partialhtml" || ext.empty)
                {
                    result ~= name;
                }
            }
        }
        
        return result;
    }
    
    /**
     * Checks if a given path should be treated as a directory-based route
     * (e.g., /about/ should look for about/index.md or about/index.partialhtml)
     */
    string getDirectoryIndexPath(string dirPath)
    {
        string indexPath = buildPath(rootDir, dirPath, "index");
        
        // Check for index.md, index.partialhtml, or index (extensionless)
        if (exists(indexPath ~ ".md"))
        {
            return indexPath ~ ".md";
        }
        else if (exists(indexPath ~ ".partialhtml"))
        {
            return indexPath ~ ".partialhtml";
        }
        else if (exists(indexPath) && !isDir(indexPath))
        {
            return indexPath;
        }
        
        return "";
    }
}

