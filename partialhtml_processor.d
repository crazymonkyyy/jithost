module partialhtml_processor;

import std.file;
import std.string;
import std.array;
import std.path;

/**
 * Processes .partialhtml files which serve as layout templates 
 * similar to header.html and footer.html in the old website
 */
struct PartialHtmlProcessor
{
    string headerPath = "header.html";
    string footerPath = "footer.html";
    
    /**
     * Processes a partial HTML file with content injection
     */
    string processPartialHtml(string partialHtmlPath, string content = "")
    {
        try
        {
            string partialHtml = cast(string)read(partialHtmlPath);
            
            import std.algorithm;
            import std.string;

            // Look for content placeholders in the partial HTML
            // Common placeholders might be {% content %}, {{content}}, etc.
            if (partialHtml.count("{% content %}") > 0)
            {
                return partialHtml.replace("{% content %}", content);
            }
            else if (partialHtml.count("{{content}}") > 0)
            {
                return partialHtml.replace("{{content}}", content);
            }
            else
            {
                // If no placeholder found, append content to the end before closing body tag
                size_t bodyClosePos = partialHtml.indexOf("</body>");
                if (bodyClosePos != -1)
                {
                    return partialHtml[0..bodyClosePos] ~ content ~ partialHtml[bodyClosePos..$];
                }
                else
                {
                    // If no body tag, just append content
                    return partialHtml ~ content;
                }
            }
        }
        catch (FileException)
        {
            // If partial HTML file doesn't exist, return just the content
            return content;
        }
    }
    
    /**
     * Processes content by wrapping it with header and footer like the old sitegen.d
     */
    string processWithHeaderFooter(string contentPath, string outputPath = "")
    {
        string content = "";
        
        // Read the content file
        try
        {
            content = cast(string)read(contentPath);
        }
        catch (FileException)
        {
            // If content file doesn't exist, return empty content
            return "";
        }
        
        // Handle the special "!#" syntax for including code files like in original sitegen.d
        string processedContent = processCodeInclusions(content, contentPath);
        
        // Wrap with header and footer
        string header = "";
        string footer = "";
        
        try
        {
            header = cast(string)read(headerPath);
        }
        catch (FileException)
        {
            // If no header file, continue without it
        }
        
        try
        {
            footer = cast(string)read(footerPath);
        }
        catch (FileException)
        {
            // If no footer file, continue without it
        }
        
        string finalOutput = header ~ processedContent ~ footer;
        
        // Write output if path provided
        if (!outputPath.empty)
        {
            write(outputPath, finalOutput);
        }
        
        return finalOutput;
    }
    
    /**
     * Process the special "#!" syntax for including code files like in sitegen.d
     */
    private string processCodeInclusions(string content, string contentPath)
    {
        string[] lines = splitLines(content);
        string result = "";
        
        foreach (line; lines)
        {
            if (line.length >= 2 && line[0..2] == "#!")
            {
                // This is a code inclusion directive
                string codeFileName = line[2..$].strip();
                
                import std.path;
                // Include the code file content
                string codeFilePath = std.path.dirName(contentPath) ~ "/code/" ~ codeFileName ~ ".code";
                
                try
                {
                    string codeContent = cast(string)read(codeFilePath);
                    result ~= "<pre>";
                    result ~= "<div class=\"codetitle\">" ~ codeFileName ~ "</div>";
                    result ~= codeContent;
                    result ~= "</pre>";
                }
                catch (FileException)
                {
                    // If code file doesn't exist, just include the title
                    result ~= "<pre>";
                    result ~= "<div class=\"codetitle\">" ~ codeFileName ~ "</div>";
                    result ~= "</pre>";
                }
            }
            else
            {
                // Handle empty lines as paragraph breaks like in original sitegen.d
                if (line.empty)
                {
                    result ~= "<p>";
                }
                else
                {
                    result ~= line;
                }
                result ~= "\n";
            }
        }
        
        return result;
    }
}

