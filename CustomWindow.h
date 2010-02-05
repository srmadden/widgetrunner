/* Copyright (c) 2010 Samuel R Madden (madden@csai.mit.edu)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.<
 */

/*
CustomWindow.h -- CustomWindow defines a widget window with no title bar and with an unusual boundary,
 as well as capabilities to set where the window floats relative to other applications.
 
 Based on Apple RoundTransparentWindow/CustomWindow.h
 http://developer.apple.com/mac/library/samplecode/RoundTransparentWindow/listing6.html
 
 */

#import <Cocoa/Cocoa.h>

#import <WebKit/WebKit.h>
#import "CustomWebView.h"

@interface CustomWindow : NSWindow {
    NSPoint initialLocation;
    bool didInit;
    NSString *key;
    NSString *widgetFile;
    
@public
    CustomWebView *webview;
    id parent;

}

- (id)initWithFile:(NSString*)file settings:(NSString *)settings widgetid:(NSString *)widgetid;
-(void)doInit;
-(CustomWebView *) createWebView:(NSString *)settings widgetid:(NSString *)widgetid;
-(void)loadWidget:(NSString *)fileName;

- (void)closeWidget:(id) sender;
- (void)setTop:(id) sender;
- (void)setNormal:(id) sender ;
- (void)setDesktop:(id) sender ;
- (NSString *)getKey;
- (NSString *)getFile;
-(NSString *)getSettingsString;

@property (assign) IBOutlet CustomWebView *webview;

@property (assign) NSPoint initialLocation;
@end
