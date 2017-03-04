//
//  ACBPythonManager.h
//  ACBCocoaPythonInterpreter
//
//  Created by Akhil on 3/4/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK: Blocks declaration


typedef NSString *(^ACBInputBlock)();
typedef void (^ACBOutputBlock)(NSString *output);


@interface ACBPythonManager : NSObject


//MARK: Public methods


- (void)executeScript:(NSString *)scriptString
       withInputBlock:(ACBInputBlock)inputBlock
          outputBlock:(ACBOutputBlock)outputBlock
           errorBlock:(ACBOutputBlock)errorBlock;
- (instancetype)init __attribute__((unavailable("Use sharedManager")));
- (BOOL)loadScriptAtPath:(NSString *)scriptPath;
+ (instancetype)sharedManager;


@end
