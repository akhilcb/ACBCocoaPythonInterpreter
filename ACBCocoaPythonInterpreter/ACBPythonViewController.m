//
//  ACBPythonViewController.m
//  ACBCocoaPythonInterpreter
//
//  Created by Akhil on 3/4/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

#import "ACBPythonViewController.h"
#import "ACBPythonManager.h"


@interface ACBPythonViewController ()


//MARK: IBOutlet properties


@property (nonatomic, unsafe_unretained, readwrite) IBOutlet NSTextView *commandTextView;
@property (nonatomic, unsafe_unretained, readwrite) IBOutlet NSTextView *inputTextView;
@property (nonatomic, unsafe_unretained, readwrite) IBOutlet NSTextView *outputTextView;


//MARK: private properties


@property (nonatomic, copy, readwrite) ACBOutputBlock errorBlock;
@property (nonatomic, copy, readwrite) ACBInputBlock inputBlock;
@property (nonatomic, strong, readwrite) NSString *inputText;
@property (nonatomic, copy, readwrite) ACBOutputBlock outputBlock;
@property (nonatomic, strong, readwrite) ACBPythonManager *pythonManager;


@end


@implementation ACBPythonViewController


//MARK: Viewcontroller overrides


- (void)viewDidLoad {
    [super viewDidLoad];
    //Python initialization
    self.pythonManager = [ACBPythonManager sharedManager];
    
    self.commandTextView.automaticQuoteSubstitutionEnabled = NO;
    self.commandTextView.automaticDashSubstitutionEnabled = NO;
    self.commandTextView.automaticTextReplacementEnabled = NO;
    
    self.inputTextView.automaticQuoteSubstitutionEnabled = NO;
    self.inputTextView.automaticDashSubstitutionEnabled = NO;
    self.inputTextView.automaticTextReplacementEnabled = NO;
    
    self.outputTextView.automaticQuoteSubstitutionEnabled = NO;
    self.outputTextView.automaticDashSubstitutionEnabled = NO;
    self.outputTextView.automaticTextReplacementEnabled = NO;
    
    __weak typeof(self) theWeakSelf = self;
    self.inputBlock = ^NSString *{
        
        return [theWeakSelf inputString];
    };
    
    self.outputBlock = ^(NSString *output) {
        [theWeakSelf appendToOutputWithText:output];
    };
    
    self.errorBlock = ^(NSString *error) {
        [theWeakSelf appendToOutputWithText:error];
        NSLog(@"<Python>: %@", error);
    };
    
    [self executeScript:@"print sys.version;"];
}


//MARK: IBAction methods


- (IBAction)clearAllClicked:(NSButton *)sender {
    [self clearConsoleClicked:sender];
    [self clearEditorClicked:sender];
    [self clearInputClicked:sender];
}


- (IBAction)clearConsoleClicked:(NSButton *)sender {
    self.outputTextView.string = @"";
}


- (IBAction)clearEditorClicked:(NSButton *)sender {
    self.commandTextView.string = @"";
}


- (IBAction)clearInputClicked:(NSButton *)sender {
    self.inputTextView.string = @"";
    self.inputText = @"";
}


- (IBAction)executeScriptClicked:(NSButton *)sender {
    if ([self validateScript:self.commandTextView.string]) {
        [self appendToOutputWithText:@"\n"];
        self.inputText = self.inputTextView.string;
        [self executeScript:self.commandTextView.string];
    }
}


- (IBAction)openFileClicked:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"py", @"PY"]];
    [panel setMessage:NSLocalizedString(@"Import Script", @"")];
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *filePath = [panel URL];
            NSString *aString =
            [[NSString alloc] initWithContentsOfURL:filePath
                                           encoding:NSUTF8StringEncoding
                                              error:nil];
            if (!aString) {
                self.outputTextView.string = NSLocalizedString(@"Invalid file format", @"");
                
                return;
            }
            self.commandTextView.string = aString;
        }
    }];
}


//MARK: Private methods


- (void)appendToOutputWithText:(NSString *)output {
    NSString *prevText = [self.outputTextView string];
    NSString *newText = nil;
    if (prevText) {
        newText = [prevText stringByAppendingString:output];
    } else {
        newText = output;
    }
    
    [self.outputTextView setString:newText];
}


- (void)executeScript:(NSString *)scriptString {
    [self.pythonManager executeScript:scriptString
                       withInputBlock:self.inputBlock
                          outputBlock:self.outputBlock
                           errorBlock:self.errorBlock];
}


- (NSString *)inputString {
    NSCharacterSet *separator = [NSCharacterSet newlineCharacterSet];
    NSArray *array = [self.inputText componentsSeparatedByCharactersInSet:separator];
    
    NSString *aStr = [array firstObject];
    if (array.count > 0) {
        NSMutableArray *aMutableArray = [array mutableCopy];
        [aMutableArray removeObjectAtIndex:0];
        array = aMutableArray;
    }
    
    self.inputText = [array componentsJoinedByString:@"\n"];
    
    return [NSString stringWithFormat:@"%@\n", aStr];
}


- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                     error:(NSString *)error
                      view:(NSView *)view {
    NSAlert *alert = [[NSAlert alloc] init];
    NSString *localizedMessage = NSLocalizedString(message, nil);
    NSString *localizedError = error ? NSLocalizedString(error, nil) : @"";
    NSString *stringMessage = [NSString stringWithFormat:@"%@ %@", localizedMessage, localizedError];
    [alert setMessageText:NSLocalizedString(title, nil)];
    [alert setInformativeText:stringMessage];
    [alert addButtonWithTitle:NSLocalizedString(@"Ok", nil)];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:view.window completionHandler:nil];
}


- (BOOL)validateScript:(NSString *)scriptString {
    if (scriptString && scriptString.length > 0) {
        if (([scriptString containsString:@"= raw_input"]
             || [scriptString containsString:@"= input"])
            && (!self.inputTextView.string
                || self.inputTextView.string.length == 0)) {
                NSString *errorText = @"Please enter a valid input";
                [self showAlertWithTitle:@"Invalid!"
                                 message:NSLocalizedString(errorText, nil)
                                   error:nil
                                    view:self.view];
                [self.inputTextView.window makeFirstResponder:self.inputTextView];
                
                return false;
            }
        
        return true;
    }
    
    NSString *errorText = @"Please enter a valid Script";
    [self showAlertWithTitle:@"Invalid!"
                     message:NSLocalizedString(errorText, nil)
                       error:nil
                        view:self.view];
    [self.commandTextView.window makeFirstResponder:self.commandTextView];
    
    return false;
}


@end
