import std.stdio;
import static_generator;
import config;

void main()
{
    writeln("Running Static Site Generator for Old Website Recreation...");
    
    string sourceDir = "old-website-recreation";
    string outputDir = "output-old-website";
    
    try 
    {
        StaticSiteGenerator generator = new StaticSiteGenerator(sourceDir, outputDir);
        generator.generateSite();
        writeln("Old website successfully generated to: ", outputDir);
    }
    catch (Exception e)
    {
        writeln("Error generating site: ", e.msg);
    }
    
    writeln("Static site generation completed.");
}