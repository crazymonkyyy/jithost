import jithost;

void main(string[] args)
{
    writeln("Testing main JitHost functionality...");
    
    // Call main with a simple command
    string[] testArgs = ["jithost", "init", "test-site"];
    main(testArgs);
    
    writeln("JitHost main function test completed.");
}