module color_scheme;

import std.stdio;
import std.file;
import std.string;
import std.array;
import std.csv;
import std.algorithm;

/**
 * Handles color schemes from base-16 templates
 */
struct ColorScheme
{
    string name;
    string[] colors; // 16 colors in base16 format: 00, 01, 02... 07, 08... 0F
    
    this(string schemeName, string[] schemeColors)
    {
        name = schemeName;
        colors = schemeColors;
    }
}

/**
 * Manages color schemes based on base-16 specifications
 */
class ColorSchemeManager
{
    ColorScheme[] availableSchemes;
    
    this()
    {
        // Load the base-16 color schemes
        loadBase16Schemes();
    }
    
    /**
     * Loads base-16 color schemes from the base-16.csv file
     */
    private void loadBase16Schemes()
    {
        string csvPath = "base-16.csv";  // Look for this in the working directory
        if (exists(csvPath))
        {
            try 
            {
                string csvContent = cast(string)read(csvPath);
                string[] lines = splitLines(csvContent);
                
                // Assuming CSV format: scheme_name, color_00, color_01, ..., color_0F
                foreach (line; lines[1..$]) // Skip header
                {
                    if (line.empty) continue;
                    
                    string[] parts = line.split(",");
                    if (parts.length >= 17) // name + 16 colors
                    {
                        string schemeName = parts[0].strip();
                        string[] colors = parts[1..17]; // First 16 are the actual colors
                        
                        // Clean up color values (remove quotes, whitespace)
                        for (size_t i = 0; i < colors.length; i++)
                        {
                            colors[i] = colors[i].strip().replace("\"", "").replace("'", "");
                        }
                        
                        availableSchemes ~= ColorScheme(schemeName, colors);
                    }
                }
            }
            catch (Exception e)
            {
                writeln("Could not load color schemes from base-16.csv: ", e.msg);
            }
        }
        else
        {
            // Default scheme if CSV file doesn't exist
            string[] defaultColors = [
                "000000", // base00 - Default Background
                "111111", // base01 - Lighter Background (Used for status bars)
                "222222", // base02 - Selection Background
                "333333", // base03 - Comments, Invisibles, Line Highlighting
                "999999", // base04 - Dark Foreground (Used for status bars)
                "aaaaaa", // base05 - Default Foreground, Caret, Delimiters, Operators
                "dddddd", // base06 - Light Foreground (Not often used)
                "ffffff", // base07 - Light Background (Not often used)
                "ff0000", // base08 - Variables, XML Tags, Markup Link Text, Lists, Inherited Class, Special
                "ff6600", // base09 - Integers, Boolean, Constants, XML Attributes, Markup Link Url
                "ffff00", // base0A - Classes, Markup Bold, Search Text Background
                "00ff00", // base0B - Strings, Inherited Class, Markup Code, Diff Inserted
                "0000ff", // base0C - Support, Regular Expressions, Escape Characters, Markup Quotes
                "aa00ff", // base0D - Functions, Methods, Attribute IDs, Headings
                "ff00ff", // base0E - Keywords, Storage, Selector, Markup Italic, Diff Changed
                "00ffff"  // base0F - Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
            ];
            
            availableSchemes ~= ColorScheme("default", defaultColors);
        }
    }
    
    /**
     * Gets a specific color scheme by name
     */
    ColorScheme getColorScheme(string schemeName)
    {
        foreach (scheme; availableSchemes)
        {
            if (scheme.name.toLower() == schemeName.toLower())
            {
                return scheme;
            }
        }
        
        // Return default if not found
        if (availableSchemes.length > 0)
            return availableSchemes[0];
        
        // Create a fallback scheme
        return ColorScheme("fallback", [
            "000000", "111111", "222222", "333333",
            "999999", "aaaaaa", "dddddd", "ffffff",
            "ff0000", "ff6600", "ffff00", "00ff00",
            "0000ff", "aa00ff", "ff00ff", "00ffff"
        ]);
    }
    
    /**
     * Generates CSS with the specified color scheme
     */
    string generateColorCss(string schemeName = "")
    {
        ColorScheme scheme;
        if (schemeName.empty)
        {
            if (availableSchemes.length > 0)
                scheme = availableSchemes[0];
            else
                return ""; // No schemes available
        }
        else
        {
            scheme = getColorScheme(schemeName);
        }
        
        string css = "/* Generated with " ~ scheme.name ~ " color scheme */\n\n";
        
        // Define CSS variables for the base16 colors
        css ~= ":root {\n";
        css ~= "  --base00: #" ~ scheme.colors[0] ~ ";\n";
        css ~= "  --base01: #" ~ scheme.colors[1] ~ ";\n";
        css ~= "  --base02: #" ~ scheme.colors[2] ~ ";\n";
        css ~= "  --base03: #" ~ scheme.colors[3] ~ ";\n";
        css ~= "  --base04: #" ~ scheme.colors[4] ~ ";\n";
        css ~= "  --base05: #" ~ scheme.colors[5] ~ ";\n";
        css ~= "  --base06: #" ~ scheme.colors[6] ~ ";\n";
        css ~= "  --base07: #" ~ scheme.colors[7] ~ ";\n";
        css ~= "  --base08: #" ~ scheme.colors[8] ~ ";\n";
        css ~= "  --base09: #" ~ scheme.colors[9] ~ ";\n";
        css ~= "  --base0A: #" ~ scheme.colors[10] ~ ";\n";
        css ~= "  --base0B: #" ~ scheme.colors[11] ~ ";\n";
        css ~= "  --base0C: #" ~ scheme.colors[12] ~ ";\n";
        css ~= "  --base0D: #" ~ scheme.colors[13] ~ ";\n";
        css ~= "  --base0E: #" ~ scheme.colors[14] ~ ";\n";
        css ~= "  --base0F: #" ~ scheme.colors[15] ~ ";\n";
        css ~= "}\n\n";
        
        // Add some default styles using the color variables
        css ~= "body {\n  color: var(--base05);\n  background-color: var(--base00);\n}\n\n";
        css ~= "a { color: var(--base0D); }\n";
        css ~= "a:visited { color: var(--base0E); }\n";
        css ~= "h1, h2, h3, h4, h5, h6 { color: var(--base0C); }\n\n";
        
        return css;
    }
}