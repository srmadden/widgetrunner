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
//  WidgetRunnerAppDelegate.m
//  WidgetRunner
//

#import "WidgetRunnerAppDelegate.h"

@implementation WidgetRunnerAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    windows = [[NSMutableArray alloc] init];
    preferences = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:1],@"lastWidget", 
                          nil ]; // terminate the list
    [preferences registerDefaults:dict];
    
    [self loadPrefs];
}

-(void)loadPrefs {
    NSArray *s = [preferences arrayForKey:@"windows"];
    if (s != nil) {
        for (NSString *w in s) {
            NSArray *settings = [preferences arrayForKey:w];

            CustomWindow *win = [[CustomWindow alloc] initWithFile:[settings objectAtIndex:0] settings:[settings objectAtIndex:1] widgetid:w];
            win->parent = self;
            [win setLevel:[(NSNumber *)[settings objectAtIndex:2] intValue]];
            [win setIsVisible:YES];
            
            int x = [(NSNumber *)[settings objectAtIndex:3] intValue];
            int y = [(NSNumber *)[settings objectAtIndex:4] intValue];
            [win setFrameOrigin:NSMakePoint(x,y)];
            
            NSImage *myImage = [[NSImage alloc ]initWithContentsOfFile:[settings objectAtIndex:0]];
            [NSApp setApplicationIconImage: myImage];
            
            [windows addObject:win];
            
        }
    }
}

-(void)savePrefs {
    NSMutableArray *s = [[NSMutableArray alloc] init];
    for (CustomWindow *w in windows) {
        NSString *key = [w getKey];
        NSString *file = [w getFile];
        int level = [w level];
        NSRect r = [w frame];
        int xpos = r.origin.x;
        int ypos = r.origin.y;

        
        
        NSString *settings = [w getSettingsString];
        [s addObject:key];
        [preferences setObject:[NSArray arrayWithObjects:file,settings,[NSNumber numberWithInt:level], [NSNumber numberWithInt:xpos], [NSNumber numberWithInt: ypos], nil] forKey:key];
        
    }
    [preferences setObject:s forKey:@"windows"];
}


- (IBAction)createWidget: (id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowsOtherFileTypes:NO];
    
    [openDlg setAllowedFileTypes:[NSArray arrayWithObject:@"wdgt"]];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModalForDirectory:nil file:nil types:[NSArray arrayWithObject:@"wdgt"]] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg filenames];
        
        // Loop through all the files and process them.
        for( int i = 0; i < [files count]; i++ )
        {
            NSString* fileName = [files objectAtIndex:i];
            
            // Do something with the filename.
           // NSLog(fileName);
            
            int widgetNo = [preferences integerForKey:@"lastWidget"];
            NSString *id = [NSString stringWithFormat:@"%@-%d",fileName,widgetNo];
            widgetNo++;
            [preferences setInteger:widgetNo forKey:@"lastWidget"];
            
            CustomWindow *w = [[CustomWindow alloc] initWithFile:fileName settings:nil widgetid:id];
            w->parent = self;
            [w setIsVisible:YES];
            
            NSImage *myImage = [[NSImage alloc ]initWithContentsOfFile:fileName];
            [NSApp setApplicationIconImage: myImage];

            [windows addObject:w];
        }
    }
    

    
}

- (void) removeWidget:(CustomWindow *)widget {
    [windows removeObject:widget];
}

- (void) applicationWillTerminate: (NSNotification *)note
{
    [self savePrefs];
    [preferences synchronize];

}


@end
