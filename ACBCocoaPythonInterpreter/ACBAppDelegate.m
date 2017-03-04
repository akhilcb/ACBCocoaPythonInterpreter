//
//  ACBAppDelegate.m
//  ACBCocoaPythonInterpreter
//
//  Created by Akhil on 3/4/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

#import "ACBAppDelegate.h"
#import "ACBPythonViewController.h"


@interface ACBAppDelegate ()


@property (weak) IBOutlet NSWindow *window;


@end


@implementation ACBAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    ACBPythonViewController *pythonViewController = [[ACBPythonViewController alloc] initWithNibName:@"ACBPythonViewController" bundle:nil];
    self.window.contentViewController = pythonViewController;
    self.window.contentView = pythonViewController.view;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
