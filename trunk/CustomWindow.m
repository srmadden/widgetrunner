/* Copyright (c) 2010 Samuel R Madden (madden@csail.mit.edu)
 
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
 CustomWindow.m -- CustomWindow defines a widget window with no title bar and with an unusual boundary,
 as well as capabilities to set where the window floats relative to other applications.
 
 Based on Apple RoundTransparentWindow/CustomWindow.m
http://developer.apple.com/mac/library/samplecode/RoundTransparentWindow/listing6.html 
 */

#import "CustomWindow.h"
#import <AppKit/AppKit.h>
#import "WidgetRunnerAppDelegate.h"
#import "Widget.h"

@implementation CustomWindow

@synthesize initialLocation;
@synthesize webview;

/*
 In Interface Builder, the class for the window is set to this subclass. Overriding the initializer provides a mechanism for controlling how objects of this class are created.
 */
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    // Using NSBorderlessWindowMask results in a window without a title bar.
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        [self doInit];
        
    }
    return self;
}

- (void)awakeFromNib {
    if (!didInit) {
        didInit = TRUE;
        
        webview = [self createWebView:nil widgetid:@"settings"];
        [webview setMainFrameURL:@"file:///Library/Widgets/Weather.wdgt/Weather.html"];
        [webview setNeedsDisplay:TRUE];    
        

    }
}

- (void)doInit {
    // Start with no transparency for all drawing into the window
    [self setAlphaValue:1.0];
    // Turn off opacity so that the parts of the window that are not drawn into are transparent.
    [self setOpaque:NO];
    [self setHasShadow:NO];
    //[self setLevel:kCGDesktopIconWindowLevel];

    
}

- (id)initWithFile:(NSString*)file settings:(NSString *)settings widgetid:(NSString *)widgetid {
    NSRect r;
    r.size.width = 400;
    r.size.height = 400;
    r.origin.x = 0;
    r.origin.y = 0;
    self = [super initWithContentRect:r styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    [self doInit];
    
    key = [widgetid retain];
    widgetFile = [file retain];
    
    webview = [self createWebView:settings widgetid:widgetid];
    [[self contentView] addSubview:webview];
    [self loadWidget:file];
    [webview setNeedsDisplay:YES];
    return self;
}

- (NSString *)getKey {
    return key;
}

- (NSString *)getFile {
    return widgetFile;
}


-(CustomWebView *) createWebView:(NSString *)settings widgetid:(NSString *)widgetid {
    CustomWebView *wv = [[CustomWebView alloc] initWithFrame:[self frame] settings:settings widgetid:widgetid];
    
    [wv setEditable:FALSE];
    [wv setDrawsBackground:FALSE];
    
    //[wv setMainFrameURL:@"file:///Library/Widgets/Weather.wdgt/Weather.html"];
    //[wv setNeedsDisplay:TRUE];
    
    wv->parent = self;
    
    return wv;
}


//load a widget into the window from a specified file
-(void)loadWidget:(NSString *)fileName {
    NSString *plistFile = [NSString stringWithFormat:@"%@/%@",fileName,@"Info.plist"];
    NSData *plistData = [NSData dataWithContentsOfFile:plistFile];
    if (plistData != NULL) {
        NSString *err;
        id ret = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:0 format:nil errorDescription:&err];
        if (ret != NULL) {
            NSDictionary *dict = (NSDictionary *)ret;
            NSString *url = [NSString stringWithFormat:@"file://%@/%@",fileName,[dict objectForKey:@"MainHTML"]];
            webview->skipFirst = TRUE;
            [webview setMainFrameURL:url];
            
            
            //check to see if the widget plist specifies a plugin to load
            NSString *plugin = [dict objectForKey:@"Plugin"];
            NSString *bundleName = [dict objectForKey:@"CFBundleName"];

            if (plugin == NULL) { //check for default plugin name
                plugin = [NSString stringWithFormat:@"%@.plugin",bundleName];
            }
            if (plugin != NULL) {              // if it does, load it
                NSString *pluginfile = [NSString stringWithFormat:@"%@/%@",fileName,plugin];
                NSBundle *myBundle = [NSBundle bundleWithPath:pluginfile];
                
                Class exampleClass;
                id<Widget> newInstance;
                if ((exampleClass = [myBundle principalClass]))
                {
                    newInstance = [[exampleClass alloc] initWithWebView:webview];
                    [newInstance windowScriptObjectAvailable:[webview windowScriptObject]];
                }
                
            }
            
            NSRect r = [webview frame];
            
            NSNumber *wid = [dict objectForKey:@"Width"];
            NSNumber *hgt = [dict objectForKey:@"Height"];

            if (wid != NULL) {
                r.size.width = [wid intValue] + 20;
            }
            if (hgt != NULL) {
                r.size.height = [hgt intValue] + 20;
            }
            
            
            [webview setFrame:r];
        
            [self setFrame:r display:NO];

        }
        
    }
}





/*
 Custom windows that use the NSBorderlessWindowMask can't become key by default. Override this method so that controls in this window will be enabled.
 */
- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (void)closeWidget:(id) sender {
    [(WidgetRunnerAppDelegate *)parent removeWidget:self];
    [self->webview closing];
    [self close];

}


-(NSString *)getSettingsString {
    return [self->webview getSettings];
}

- (void)setTop:(id) sender {
    [self setLevel:NSFloatingWindowLevel];

    
}
- (void)setNormal:(id) sender {
    [self setLevel:NSNormalWindowLevel];

}
- (void)setDesktop:(id) sender {
    [self setLevel:kCGDesktopIconWindowLevel];

}



- (void)sendEvent:(NSEvent*)event
{
    static BOOL isDragging = FALSE;
    NSView* hitView;
    switch([event type])
    {
        case NSLeftMouseDown:
        case NSRightMouseDown:
            if ([event modifierFlags] & NSControlKeyMask || [event type] == NSRightMouseDown) {
                NSLog(@"control click");

                NSMenu *theMenu = [[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];
                NSMenu *submenu = [[[NSMenu alloc] initWithTitle:@"Widget Position"] autorelease];
                [submenu insertItemWithTitle:@"Top" action:@selector(setTop:) keyEquivalent:@"" atIndex:0];
                [submenu insertItemWithTitle:@"Normal" action:@selector(setNormal:) keyEquivalent:@"" atIndex:0];
                [submenu insertItemWithTitle:@"Desktop" action:@selector(setDesktop:) keyEquivalent:@"" atIndex:0];

                NSMenuItem *it;
                
                if ([self level] == kCGDesktopIconWindowLevel) 
                    it = [submenu itemAtIndex:0];
                else if ([self level] == NSFloatingWindowLevel)
                    it = [submenu itemAtIndex:2];
                else
                    it = [submenu itemAtIndex:1];

                
                [it setState:NSOnState];
                
                NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Widget Position" action:nil keyEquivalent:@""];
                [item setSubmenu:submenu];
                
                [theMenu addItem:item];
                [theMenu insertItemWithTitle:@"Close Widget" action:@selector(closeWidget:) keyEquivalent:@"" atIndex:0];
             
                [NSMenu popUpContextMenu:theMenu withEvent:event forView:[self contentView]];
             
                break;
            }
        case NSLeftMouseDragged:

            hitView = [webview hitTest:[event locationInWindow]];
            if(isDragging || ([hitView isDescendantOf:webview] && 
               !([hitView isKindOfClass:[NSScroller class]] || 
                 [hitView isKindOfClass:[NSScrollView class]])))
            {
                if ([event type] == NSLeftMouseDown)  {

                    self.initialLocation = [event locationInWindow];
                    [super sendEvent:event];

                }
                else {
                    isDragging = TRUE;
                    [self mouseDragged:event];
                }
            } else {
                [super sendEvent:event];
            }
            break;
        case NSLeftMouseUp:
            if (isDragging) {
                isDragging = FALSE;
            } else {
                [super sendEvent:event];
            }

            break;
      /*  case NSKeyUp: {
            NSString *js = [NSString stringWithFormat:@"e = {}; e.charCode = %d; alert(e.charCode); document.keyReleased(e);", [event keyCode]];
            [webview stringByEvaluatingJavaScriptFromString:js];
        }
            break;
       */
        default:
            [super sendEvent:event];

            break;
    }

}


/*
 Once the user starts dragging the mouse, move the window with it. The window has no title bar for the user to drag (so we have to implement dragging ourselves)
 */
- (void)mouseDragged:(NSEvent *)theEvent {
    NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
    NSRect windowFrame = [self frame];
    NSPoint newOrigin = windowFrame.origin;
    
    // Get the mouse location in window coordinates.
    NSPoint currentLocation = [theEvent locationInWindow];
    // Update the origin with the difference between the new mouse location and the old mouse location.
    newOrigin.x += (currentLocation.x - initialLocation.x);
    newOrigin.y += (currentLocation.y - initialLocation.y);
    
    // Don't let window get dragged up under the menu bar
    if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height)) {
        newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
    }
    
    // Move the window to the new location
    [self setFrameOrigin:newOrigin];
}

- (void)setFrameOrigin:(NSPoint)aPoint {
    NSLog(@"Move to %f,%f",aPoint.x,aPoint.y);
    [super setFrameOrigin:aPoint];
}


-(void)moveToSavedLoc {
    NSLog(@"Deferred move to %f,%f",org_x,org_y);

    NSPoint p = NSMakePoint(org_x, org_y);
    [super setFrameOrigin:p];
}



@end
