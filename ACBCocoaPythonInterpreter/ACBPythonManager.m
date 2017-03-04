//
//  ACBPythonManager.m
//  ACBCocoaPythonInterpreter
//
//  Credit to https://blog.tlensing.org/2008/11/04/embedding-python-in-a-cocoa-application/
//  for redirecting Stdout/Stderr to C code  
//  Created by Akhil on 3/4/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

#import "ACBPythonManager.h"
#import "Python/Python.h"


@interface ACBPythonManager ()


//MARK: Private properties


@property (nonatomic, copy) ACBOutputBlock errorBlock;
@property (nonatomic, copy) ACBInputBlock inputBlock;
@property (nonatomic, copy) ACBOutputBlock outputBlock;


//MARK: Private method declaration


- (void)pythonError:(NSString *)error;
- (NSString *)pythonInput;
- (void)pythonOutput:(NSString *)output;


@end


//MARK: static variable


static ACBPythonManager *pythonManager;


//MARK: C methods


PyObject *logCaptureStderr(PyObject *self, PyObject *pArgs) {
    char *logStr = NULL;
    if (!PyArg_ParseTuple(pArgs, "s", &logStr)) {
        return NULL;
    }
    
    [pythonManager pythonError:[NSString stringWithUTF8String:logStr]];
    Py_INCREF(Py_None);
    
    return Py_None;
}


PyObject *logCaptureStdin(PyObject *self, PyObject *pArgs) {
    NSString *input = [pythonManager pythonInput];
    
    const char *str = [input UTF8String];
    PyObject *objStr = PyString_FromString(str);
    Py_INCREF(objStr);
    
    return objStr;
}


PyObject *logCaptureStdout(PyObject *self, PyObject *pArgs) {
    char *logStr = NULL;
    if (!PyArg_ParseTuple(pArgs, "s", &logStr)) {
        return NULL;
    }
    
    [pythonManager pythonOutput:[NSString stringWithUTF8String:logStr]];
    Py_INCREF(Py_None);
    
    return Py_None;
}


static PyMethodDef logMethods[] = {
    {"CaptureStdout", logCaptureStdout, METH_VARARGS, "Logs stdout"},
    {"CaptureStdin", logCaptureStdin, METH_VARARGS, "Logs stdin"},
    {"CaptureStderr", logCaptureStderr, METH_VARARGS, "Logs stderr"},
    {NULL, NULL, 0, NULL}
};


@implementation ACBPythonManager


//MARK: Initialization methods


- (void)dealloc {
    Py_Finalize();
}


+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pythonManager = [[self alloc] init];
        [pythonManager initializePython];
    });
    
    return pythonManager;
}


//MARK: Public methods


- (void)executeScript:(NSString *)scriptString
       withInputBlock:(ACBInputBlock)inputBlock
          outputBlock:(ACBOutputBlock)outputBlock
           errorBlock:(ACBOutputBlock)errorBlock {
    self.inputBlock = inputBlock;
    self.outputBlock = outputBlock;
    self.errorBlock = errorBlock;
    PyRun_SimpleString([[scriptString stringByAppendingString:@"\n"] UTF8String]);
}


- (BOOL)loadScriptAtPath:(NSString *)scriptPath {
    FILE *mainFile = fopen([scriptPath UTF8String], "r");
    
    return (PyRun_SimpleFile(mainFile, (char *)[[scriptPath lastPathComponent] UTF8String]) == 0);
}


//MARK: Private methods


- (void)initializePython {
    Py_SetProgramName("/usr/bin/python");
    Py_Initialize();
    Py_InitModule("log", logMethods);
    PyRun_SimpleString(
                       "import log\n"
                       "import sys\n"
                       "class StdoutCatcher:\n"
                       "\tdef write(self, str):\n"
                       "\t\tlog.CaptureStdout(str)\n"
                       "class StderrCatcher:\n"
                       "\tdef write(self, str):\n"
                       "\t\tlog.CaptureStderr(str)\n"
                       "class StdinCatcher:\n"
                       "\tdef readline(self):\n"
                       "\t\treturn log.CaptureStdin()\n"
                       "sys.stdout = StdoutCatcher()\n"
                       "sys.stderr = StderrCatcher()\n"
                       "sys.stdin = StdinCatcher()\n"
                       );
    PyRun_SimpleString("print '<Python>: Initializing Python'\n");
}


- (void)pythonError:(NSString *)error {
    if (self.errorBlock) {
        self.errorBlock(error);
    } else {
        NSLog(@"%@", error);
    }
}


- (NSString *)pythonInput {
    if (self.inputBlock) {
        
        return self.inputBlock();
    }
    
    return @"";
}


- (void)pythonOutput:(NSString *)output {
    if (self.outputBlock) {
        self.outputBlock(output);
    } else {
        NSLog(@"%@", output);
    }
}


@end
