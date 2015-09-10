//
//  AppDelegate.m
//  AndTekBar.app
//
//  Created by Friedmann on 07.09.15.
//  Copyright (c) 2015 frdmn. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
- (NSData *) sendRequestWithState: (NSString *) state;
- (void) login: (NSNotification *) notification;
- (void) logoff: (NSNotification *) notification;
@end

@implementation AppDelegate

/*!
 * Function which gets called as soon as the App draws UI
 */
- (void) awakeFromNib{
    // Initiate status bar
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    // Allocate and load the images into the project
    statusOn = [NSImage imageNamed:@"online"];
    statusOff = [NSImage imageNamed:@"offline"];
    [statusOn setTemplate:YES];
    [statusOff setTemplate:YES];
    // Prepare our NSStatusItem
    [statusItem setImage:statusOff]; // off by default
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"AndTekBar.app"];
    [statusItem setHighlightMode:YES];
    
    // Call function to draw version number in settings window
    [self drawVersion];
    
    // Set preferences defaults
    NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"002414B2XXXX",        @"mac",
                                          @"192.168.100.238",     @"server",
                                          @"8080",                @"port",
                                          @"andphone/ACDService", @"api",
                                          nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
   
    // Fill in UI elements
    preferences = [NSUserDefaults standardUserDefaults];
    [macAdresse setStringValue:[preferences stringForKey:@"mac"]];
    [serverAdresse setStringValue:[preferences stringForKey:@"server"]];
    [portAdresse setStringValue:[preferences stringForKey:@"port"]];
    [apiAdresse setStringValue:[preferences stringForKey:@"api"]];
    
    // Check if Cisco server is reachable
    if ([self checkIfServerIsReachable]) {
        // If reachable, login to call center on App start
        [self login: nil];
    } else {
        // Otherwise disable login/logout menues
        NSLog(@"Can't reach server... Hiding login/logout menu item");
        [loginItem setHidden:YES];
        [logoutItem setHidden:YES];
    }
    
    // Listen to screen saver events
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(login:) name:  NSWorkspaceSessionDidBecomeActiveNotification object: nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(logoff:) name: NSWorkspaceSessionDidResignActiveNotification object: nil];
    // ... and lock/unlock events
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(logoff:) name:@"com.apple.screenIsLocked" object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(login:) name:@"com.apple.screenIsUnlocked" object:nil];
    // ... as well as quit event
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
}

/*!
 * Function to render the project version (out of Info.plist) in the GUI
 */
- (void) drawVersion{
    // Set version in settings view
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    copyright.stringValue = [NSString stringWithFormat:@"v%@ - © 2015 by @frdmn", version];
}

/*!
 * Function which gets called as soon as the App gets terminated by the user (or crashes)
 */
- (void) applicationWillTerminate:(NSApplication *)application {
    NSLog(@"AndTekAgent | Application quit");
    if ([self checkIfServerIsReachable]) {
        [self logoff: nil];
    } else {
        NSLog(@"Can't reach server");
    }
}

/*!
 * Function to send a specific state to the AndTek server
 */
- (NSData *)sendRequestWithState: (NSString *) state {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"http://%@:%@/%@", [serverAdresse stringValue], [portAdresse stringValue], [apiAdresse stringValue]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSString *requestFields = @"";
    requestFields = [requestFields stringByAppendingFormat:@"queue=all&"];
    requestFields = [requestFields stringByAppendingFormat:@"setsec=-1&"];
    requestFields = [requestFields stringByAppendingFormat:@"page=available&"];
    requestFields = [requestFields stringByAppendingFormat:@"state=%@&", state];
    requestFields = [requestFields stringByAppendingFormat:@"dev=SEP%@", [macAdresse stringValue]];
    
    requestFields = [requestFields stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *requestData = [requestFields dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestData;
    request.HTTPMethod = @"POST";
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error == nil && response.statusCode == 200) {
        NSLog(@"%li: %@ - %@", (long)response.statusCode, url.absoluteString, requestFields);
    }
    
    return responseData;
}

/*!
 * Login call center using [self sendRequestWithState]
 */
- (void) login: (NSNotification *) notification
{
    [self sendRequestWithState: @"0"];
    [statusItem setImage:statusOn];
}

/*!
 * Logoff call center using [self sendRequestWithState]
 */
- (void) logoff: (NSNotification *) notification
{
    [self sendRequestWithState: @"1"];
    [statusItem setImage:statusOff];
}

/*!
 * Server connectivity check
 */
-(BOOL) checkIfServerIsReachable {
    NSString *url = [NSString stringWithFormat: @"http://%@:%@/%@", [serverAdresse stringValue], [portAdresse stringValue], [apiAdresse stringValue]];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    NSHTTPURLResponse* response = nil;
    NSError* error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if ([response statusCode] == 200){
        return YES;
    } else {
        return NO;
    }
}

/*!
 * Release from memory
 */
- (void) dealloc {
    [statusOn release];
    [statusOff release];
    [super dealloc];
}

/* IB action functions */

-(IBAction)doLogin:(id)sender{
    [self login: nil];
}

-(IBAction)doLogout:(id)sender{
    [self logoff: nil];
}

-(IBAction)showSettings:(id)sender{
    preferences = [NSUserDefaults standardUserDefaults];
    [macAdresse setStringValue:[preferences stringForKey:@"mac"]];
    [serverAdresse setStringValue:[preferences stringForKey:@"server"]];
    [portAdresse setStringValue:[preferences stringForKey:@"port"]];
    [apiAdresse setStringValue:[preferences stringForKey:@"api"]];
    [settingsWindow makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

-(IBAction)saveSettings:(id)sender{
    preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:[macAdresse stringValue] forKey:@"mac"];
    [preferences setObject:[serverAdresse stringValue] forKey:@"server"];
    [preferences setObject:[portAdresse stringValue] forKey:@"port"];
    [preferences setObject:[apiAdresse stringValue] forKey:@"api"];
    [preferences synchronize];
    [settingsWindow orderOut:nil];
}

-(IBAction)cancelSettings:(id)sender{
    [settingsWindow orderOut:nil];
}

-(IBAction)openurl:(id)sender{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://frd.mn/"]];
}

@end
