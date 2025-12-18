module code_includer;

import std.file;
import std.string;
import std.path;

/**
 * Handles the #! syntax for including external code files
 * This replicates the behavior from the original sitegen.d where lines like:
 * #!filename
 * would include the content of code/filename.code
 */
string processCodeInclusions(string content, string currentFilePath) {
    string[] lines = splitLines(content);
    string result = "";
    
    foreach (line; lines) {
        if (line.length >= 2 && line[0..2] == "#!") {
            // This is a code inclusion directive
            string fileName = line[2..$].strip();
            
            // Determine the code file path relative to the current file's directory
            string codeDir = dirName(currentFilePath);
            string codePath = codeDir ~ "/code/" ~ fileName ~ ".code";
            
            try {
                string codeContent = cast(string)read(codePath);
                
                // Wrap code in appropriate HTML tags like the original sitegen.d
                result ~= "<pre>";
                result ~= "<div class=\"codetitle\">" ~ fileName ~ "</div>";
                result ~= codeContent;
                result ~= "</pre>";
            }
            catch (FileException) {
                // If code file doesn't exist, just include the filename as title
                result ~= "<pre>";
                result ~= "<div class=\"codetitle\">" ~ fileName ~ "</div>";
                result ~= "</pre>";
            }
        } else {
            // Regular line, just add it to the result
            result ~= line ~ "\n";
        }
    }
    
    return result;
}

unittest
{
    import std.file : writeTemp, tempDir;
    import std.path : join;
    
    // Create a temporary directory for testing
    auto tempDir = tempDirManager.createTempDir();
    scope(exit) tempDir.dispose();
    
    string testFile = join(tempDir.dir, "test.md");
    string codeDir = join(tempDir.dir, "code");
    mkdir(codeDir);
    
    string codePath = join(codeDir, "example.code");
    write(codePath, "import std.stdio;\n\nvoid main() {\n    writeln(\"Hello, world!\");\n}");
    
    string markdownContent = "This is some content.\n\n#!example\n\nMore content here.";
    string expectedResult = "This is some content.\n\n<pre>\n<div class=\"codetitle\">example</div>\nimport std.stdio;\n\nvoid main() {\n    writeln(\"Hello, world!\");\n}\n</pre>\n\nMore content here.\n";
    
    string result = processCodeInclusions(markdownContent, testFile);
    
    assert(result.canFind("This is some content."), "Original content should be preserved");
    assert(result.canFind("<pre>"), "Code should be wrapped in pre tags");
    assert(result.canFind("example"), "File name should appear as title");
    assert(result.canFind("Hello, world!"), "Code content should be included");
    assert(result.canFind("More content here"), "Content after code inclusion should be preserved");
    
    // Test case where code file doesn't exist
    string markdownMissingCode = "Content before.\n\n#!nonexistent\n\nContent after.";
    string resultMissing = processCodeInclusions(markdownMissingCode, testFile);
    
    assert(resultMissing.canFind("Content before."), "Content before should be preserved");
    assert(resultMissing.canFind("nonexistent"), "Filename should appear even if code doesn't exist");
    assert(resultMissing.canFind("Content after."), "Content after should be preserved");
}