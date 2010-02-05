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
//
//  CustomWebView.m --defines a webview that displays a widget
//  WidgetRunner
//

#import "CustomWebView.h"


@implementation CustomWebView
@synthesize initialLocation;




- (id) initWithFrame:(NSRect)frameRect settings:(NSString *)settings widgetid:(NSString *)widgetid {
    [super initWithFrame:frameRect];
    [self doInit:settings windowid:widgetid];
    

    return self;
}




-(void) doInit:(NSString *)settings windowid:(NSString *)windowid; {
    
    [self setUIDelegate:self];
    [self setPolicyDelegate:self];
    
    skipFirst = TRUE;
    
    
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"widget" ofType:@"js"];  
    NSString *myData = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];  
    
        WebScriptObject *scriptObject = [self windowScriptObject];
    
    //load widget.js into the widget
    [scriptObject evaluateWebScript:myData];
    //NSLog(@"%@",result);

    //name the widget
    [scriptObject evaluateWebScript:[NSString stringWithFormat:@"widget.identifier = '%@';",windowid]];
    
    //set the settings of the widget
    if (settings != nil)
        [scriptObject callWebScriptMethod:@"setKeys" withArguments:[NSArray arrayWithObject:settings]];
    
    
    //receive notifications when widget changes size
    [self setPostsFrameChangedNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(somethingChanged:) name:NSViewFrameDidChangeNotification object:nil];
    
    WebPreferences *prefs = [self preferences];
    [prefs setPlugInsEnabled:YES];
    
    
}


// delegate called when a frame changes -- attempt to intercept
// request of widget to change size and also adjust window size
//  at the same time
- (void) somethingChanged:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSView *obj = [notification object];
    
    if ([obj window] == parent) {
        WebScriptObject *scriptObject = [self windowScriptObject];
        //gross hack -- because we cant tell what part of the widget is being resized here,
        //  we set a javascript variable indicating that the widget frame is changing
        //  and read that back here.
        NSNumber *b = (NSNumber *)[scriptObject evaluateWebScript:@"didChangeSize;"];
        if ([b boolValue] == YES || obj == (NSView *)[self mainFrame]) {
            NSRect r = [[[self mainFrame] frameView] documentView].frame;
            //parent.frame;
            //r.size =             
            [parent setFrame:r display:YES];
            //[self setFrame:r];
            
            
            //r = self.frame;
            
            //r.size = self.frame.size;
            r.size.height += 1;
            [self setFrame:r];
            
            //[scriptObject evaluateWebScript:@"didChangeSize = false;"];
            
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(somethingChanged:) name:NSViewFrameDidChangeNotification object:nil];
    
}

- (NSString *) getSettings {
    return [[self windowScriptObject] evaluateWebScript:@"widget.getKeys();"];
}

// this WebUIDelegate method will be called with the window.alert() message
- (void) webView: (WebView*) sender runJavaScriptAlertPanelWithMessage: (NSString*) message
{
    NSLog(@"alert> %@", message);
}


- (void)webView:(WebView *)sender setFrame:(NSRect)frame
{
    [self setFrame:frame];
    //[parent setFrame:frame display:YES];
}

- (BOOL)webViewIsResizable:(WebView *)sender {
    return YES;
}

- (void)webView:(WebView *)sender setContentRect:(NSRect)contentRect {
    [self setFrame:contentRect];
    //[parent setFrame:contentRect display:YES];

}


/** Called when widget tries to load a URL.
 Gross hack, but ignore the first request that is 
 the widget itself loading.
 All other requests are opended in a new browser window (this may not
 be what some widgets want -- could possibly do a better job
 if we did something different in widget.js/openURL
 */
- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation 
        request:(NSURLRequest *)request 
          frame:(WebFrame *)frame 
decisionListener:(id <WebPolicyDecisionListener>)listener {
    if (skipFirst) {
        [listener use];

        skipFirst = FALSE;
    } else {
        [listener ignore];
        [[NSWorkspace sharedWorkspace] openURL:[request URL]];
    }
}

/* Intercept a call to change the frame -- some widgets specify origin of 0,0 and
we don't want to move the widget as a result.
 */
- (void)setFrame:(NSRect)aRect {
    NSLog(@"Move to RECT %f,%f",aRect.origin.x,aRect.origin.y);
    if (aRect.origin.x == 0 && aRect.origin.y == 0) {
        NSRect f = [self frame];
        aRect.origin = f.origin;
    }
    [super setFrame:aRect];
}

- (void)drawRect:(NSRect)rect {
    // Clear the drawing rect.
   [[NSColor clearColor] set];
    NSRectFill([self frame]);
    [super drawRect:rect]; 

}



-(void)closing {
}



@end
