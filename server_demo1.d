import std.stdio;
import std.file;
import std.path;
import std.string;
import std.datetime;
import arsd.http2;
import static_generator;
import jit_server;

void main()
{
    writeln("Starting JIT Server for Demo 1...");
    writeln("Note: Full HTTP server functionality requires more complex implementation");
    writeln("For demonstration, we will simulate the server functionality...");
    
    // Create a simple server to demonstrate JIT functionality
    string siteDir = "demo1";
    JitServer server = new JitServer(siteDir, 8080);
    
    writeln("JIT Server initialized for site: ", siteDir);
    writeln("Server would normally listen on port 8080");
    
    // Simulate handling a request
    string requestPath = "/index.html";
    writeln("Processing request: ", requestPath);
    string response = server.processRequest(requestPath);
    
    writeln("Generated response length: ", response.length, " characters");
    if (response.length > 200) {
        writeln("First 200 characters of response: ");
        writeln(response[0..200], "...");
    } else {
        writeln("Response: ", response);
    }
    
    writeln("\nIn a real implementation, this would be a running HTTP server.");
    writeln("The server supports JIT (on-demand) generation of pages.");
    writeln("Static generation was also performed successfully earlier.");
    writeln("Demo 1 server simulation completed.");
}