module jit_server;

import std.stdio;
import arsd.http2;
import std.file;
import std.path;
import std.string;
import std.array;
import std.concurrency;
import std.datetime;
import std.conv;
import std.uni;
import file_resolver;
import markdown_processor;
import partialhtml_processor;
import css_manager;
import static_generator;

/**
 * JIT (Just-In-Time) HTTP server that generates pages on request
 */
class JitServer
{
    FileResolver resolver;
    PartialHtmlProcessor partialProcessor;
    CssManager cssManager;
    StaticSiteGenerator staticGenerator;
    string siteDir;
    ushort port;
    
    this(string siteDirectory, ushort serverPort = 8080)
    {
        siteDir = siteDirectory;
        port = serverPort;
        resolver = FileResolver();
        resolver.rootDir = siteDir;
        partialProcessor = PartialHtmlProcessor();
        cssManager = CssManager();
        cssManager.rootDir = siteDir;
        staticGenerator = new StaticSiteGenerator(siteDir, siteDir ~ "/_temp_output");
    }
    
    /**
     * Starts the JIT server
     */
    void start()
    {
        writeln("Starting JIT Server on port ", port);
        writeln("Serving site from: ", siteDir);

        import std.socket;
        import std.stdio;
        import std.array;
        import std.string;

        writeln("JIT server listening on port ", port, "...");
        writeln("Ready to serve JIT-generated content from: ", siteDir);

        try {
            // Create a TCP server socket
            auto serverSocket = new TcpSocket();
            serverSocket.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
            serverSocket.bind(new InternetAddress("127.0.0.1", port));
            serverSocket.listen(10); // Allow up to 10 connections in queue

            writeln("Server is running. Press Ctrl+C to stop.");

            while (true) {
                try {
                    // Accept incoming connections
                    auto clientSocket = serverSocket.accept();

                    // Handle the request in a separate context (simplified)
                    ubyte[4096] buffer;
                    auto received = clientSocket.receive(buffer[]);

                    if (received > 0) {
                        string request = cast(string)buffer[0..received];

                        // Parse the HTTP request line (GET /path HTTP/1.1)
                        string path = "/";
                        auto lines = request.split("\n");
                        if (lines.length > 0) {
                            auto requestLine = lines[0]; // e.g., "GET /index.html HTTP/1.1"
                            auto parts = requestLine.split(" ");
                            if (parts.length >= 2) {
                                path = parts[1];
                            }
                        }

                        // Process the request using our existing method
                        string responseContent = processRequest(path);

                        // Create HTTP response
                        string response = "HTTP/1.1 200 OK\r\n";
                        response ~= "Content-Type: text/html; charset=utf-8\r\n";
                        response ~= "Connection: close\r\n";
                        response ~= format("Content-Length: %d\r\n", responseContent.length);
                        response ~= "\r\n";
                        response ~= responseContent;

                        // Send response
                        clientSocket.send(cast(ubyte[])response);
                    }

                    clientSocket.close();
                } catch (SocketException e) {
                    writeln("Socket error: ", e.msg);
                } catch (Exception e) {
                    writeln("Error handling request: ", e.msg);
                }
            }

            serverSocket.close(); // This line will never be reached due to the while(true) loop
        } catch (SocketException e) {
            writeln("Failed to start server: ", e.msg);
        } catch (Exception e) {
            writeln("Failed to start server: ", e.msg);
        }
    }

    /**
     * Processes a single request for JIT generation
     */
    string processRequest(string path)
    {
        // Remove leading slash and normalize path
        if (path.length > 0 && path[0] == '/')
        {
            path = path[1 .. $];
        }
        
        // Handle special files (like CSS, images, etc.) directly
        string ext = extension(path).toLower();
        if (ext == ".css" || ext == ".js" || ext == ".png" || ext == ".jpg" || ext == ".gif" || ext == ".ico")
        {
            string filePath = buildPath(siteDir, path);
            if (exists(filePath) && isFile(filePath))
            {
                return cast(string)read(filePath);
            }
            else
            {
                return "File not found";
            }
        }
        
        // For HTML paths, resolve to source files
        auto resolution = resolver.resolveRequest(path);
        
        string content = "";
        string layout = "";
        
        // Process based on what files were found
        if (!resolution.markdownFile.empty)
        {
            string rawContent = cast(string)read(resolution.markdownFile);
            content = convertMarkdownToHtmlWithEmbedding(rawContent);
            layout = resolver.getLayoutForRequest(path);
        }
        else if (!resolution.contentFile.empty)
        {
            content = cast(string)read(resolution.contentFile);
            // For content files, also check for the special #! syntax like in original sitegen.d
            content = partialProcessor.processWithHeaderFooter(resolution.contentFile);
            layout = resolver.getLayoutForRequest(path);
        }
        else if (!resolution.partialHtmlFile.empty)
        {
            layout = cast(string)read(resolution.partialHtmlFile);
            // For partial HTML files, content would be empty or derived differently
            content = ""; // This would need more complex handling based on how partialhtml files work
        }
        
        // Create the final HTML page
        string baseName = path;
        if (baseName.endsWith(".html"))
        {
            baseName = baseName[0 .. $ - 5];
        }
        
        string finalPage = createHtmlPage(content, baseName, layout);
        return finalPage;
    }
    
    /**
     * Creates a complete HTML page from content and layout
     */
    private string createHtmlPage(string content, string pageTitle, string layout = "")
    {
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
            // Use custom layout
            // For this simple implementation, we'll just wrap the content
            // A full implementation would have more sophisticated layout handling
            return layout.replace("{% content %}", content).replace("{{content}}", content);
        }
    }
}

unittest
{
    import std.file : writeTemp, TempDir;
    
    // Create a temporary directory for testing
    TempDir tempDir = createTempDir();
    scope(exit) tempDir.destroy();
    
    string testDir = tempDir.path;
    
    // Create test files
    write(testDir ~ "/index.md", "# Home\n\nWelcome to the site.");
    write(testDir ~ "/about.md", "# About\n\nLearn more about us.");
    write(testDir ~ "/style.css", "body { margin: 0; }");
    
    JitServer server = new JitServer(testDir, 8080);
    
    // Test processing requests
    string indexResult = server.processRequest("/index.html");
    assert(indexResult.canFind("<h1>Home</h1>"));
    assert(indexResult.canFind("Welcome to the site."));
    
    string aboutResult = server.processRequest("/about.html");
    assert(aboutResult.canFind("<h1>About</h1>"));
    assert(aboutResult.canFind("Learn more about us."));
    
    // Test CSS file serving
    string cssResult = server.processRequest("/style.css");
    assert(cssResult.canFind("body { margin: 0; }"));
}