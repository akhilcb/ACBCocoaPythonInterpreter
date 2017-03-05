
# Basic Cocoa Python Interpreter ![alt text][logo] 

[logo]: /ACBCocoaPythonInterpreter/Assets.xcassets/AppIcon.appiconset/logo_32.png?raw=true "Logo"

This is a Simple Mac Application which uses Cocoa(Objective C) as GUI for Python Interpreter.

![Basic Cocoa Python Interpreter](/Screenshots/BasicPythonInterpreter.png?raw=true "Basic Cocoa Python Interpreter")

User can enter the script using following methods:

	1. Enter script in "Script Editor" Text Area manually
	2. Open any ".py" file in Mac using "Open Script" button.

Any input required in the script can be provided by using "User Input" Text Area. If multiple inputs are required, separate them by "new line" characters. 

Output and Error will be displayed in bottom "Output" Area.

Major classes are __ACBPythonManager__ and __ACBPythonViewController__. __ACBPythonManager__ class can be used without GUI too. It accepts the following methods for executing scripts with input/output/error blocks.

	- (void)executeScript:(NSString *)scriptString
	       withInputBlock:(ACBInputBlock)inputBlock
  	          outputBlock:(ACBOutputBlock)outputBlock
    	       errorBlock:(ACBOutputBlock)errorBlock;

For loading any script from a file, use the below method.

	- (BOOL)loadScriptAtPath:(NSString *)scriptPath;


