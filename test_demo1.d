import std.stdio;
import static_generator;
import config;

void main()
{
    writeln("Running Static Site Generator for Demo 1...");
    
    string sourceDir = "demo1";
    string outputDir = "output-demo1";
    
    try 
    {
        StaticSiteGenerator generator = new StaticSiteGenerator(sourceDir, outputDir);
        generator.generateSite();
        writeln("Demo 1 successfully generated to: ", outputDir);
    }
    catch (Exception e)
    {
        writeln("Error generating site: ", e.msg);
    }
    
    writeln("Demo 1 site generation completed.");
}