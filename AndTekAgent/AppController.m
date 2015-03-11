//
//  AppController.m
//  AndTekAgent
//
//  Created by Friedmann on 17.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"

@interface AppController()
- (NSData *) sendRequestWithState: (NSString *) state;
- (void) login: (NSNotification *) notification;
- (void) logoff: (NSNotification *) notification;
@end

@implementation AppController

- (void) awakeFromNib{
    //Create the NSStatusBar and set its length
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    
    //Allocates and loads the images into the application which will be used for our NSStatusItem
    statusOn = [NSImage imageNamed:@"iconon"];
    statusOff = [NSImage imageNamed:@"iconoff"];
    
    [statusOn setTemplate:YES];
    [statusOff setTemplate:YES];
    
    //Sets the images in our NSStatusItem
    [statusItem setImage:statusOff];
    
    //Tells the NSStatusItem what menu to load
    [statusItem setMenu:statusMenu];
    //Sets the tooptip for our item
    [statusItem setToolTip:@"AndTekAgent"];
    //Enables highlighting
    [statusItem setHighlightMode:YES];
    
    // Check if we need to create default NSUserDefaults (._.)
    BOOL isRunMoreThanOnce = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRunMoreThanOnce"];
    if(!isRunMoreThanOnce){
        // Then set the first run flag
        [[NSUserDefaults standardUserDefaults] setObject:@"andphone/ACDService" forKey:@"api"];
        [[NSUserDefaults standardUserDefaults] setObject:@"002414B2XXXX" forKey:@"mac"];
        [[NSUserDefaults standardUserDefaults] setObject:@"8080" forKey:@"port"];
        [[NSUserDefaults standardUserDefaults] setObject:@"192.168.100.238" forKey:@"server"];
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"gira"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"isRunMoreThanOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    //UserDefaults holen
    preferences = [NSUserDefaults standardUserDefaults];
    //In TextField schreiben
    [macAdresse setStringValue:[preferences stringForKey:@"mac"]];
    [serverAdresse setStringValue:[preferences stringForKey:@"server"]];
    [portAdresse setStringValue:[preferences stringForKey:@"port"]];
    [apiAdresse setStringValue:[preferences stringForKey:@"api"]];
    
    [self login: nil];
    // TODO // [self checkCurrentState];
}

- (id) init
{
    
    self = [super init];
    
    if (self)
    {
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(login:) name:  NSWorkspaceSessionDidBecomeActiveNotification object: nil];
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(logoff:) name: NSWorkspaceSessionDidResignActiveNotification object: nil];
        
        // Add support for screensaver switch
        // [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(logoff:) name:@"com.apple.screensaver.didstart" object:nil];
        // [NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(logoff:) name:@"com.apple.screensaver.willstop" object:nil];
        // [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(login:) name:@"com.apple.screensaver.didstop" object:nil];

        // Add support for locked screens
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(logoff:) name:@"com.apple.screenIsLocked" object:nil];
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(login:) name:@"com.apple.screenIsUnlocked" object:nil];
        
        // Add observer to logout before quit
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];

    }
        
    return self;
}

- (void) applicationWillTerminate:(NSApplication *)application {
    NSLog(@"AndTekAgent | Application got quit");
    [self logoff: nil];
}

// TODO // implement this somehow
- (NSString *)checkCurrentState {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"http://%@:%@/%@", [serverAdresse stringValue], [portAdresse stringValue], [apiAdresse stringValue]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSString *requestFields = @"";
    requestFields = [requestFields stringByAppendingFormat:@"queue=all&"];
    requestFields = [requestFields stringByAppendingFormat:@"setsec=-1&"];
    requestFields = [requestFields stringByAppendingFormat:@"page=available&"];
    requestFields = [requestFields stringByAppendingFormat:@"dev=SEP%@", [macAdresse stringValue]];
    
    requestFields = [requestFields stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *requestData = [requestFields dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestData;
    request.HTTPMethod = @"POST";
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding];

    if (error == nil && response.statusCode == 200 && responseString) {
        NSLog(@"%i: %@ - %@", response.statusCode, url.absoluteString, requestFields);
        NSLog(@"%@", responseString);
    } else {
        //Error handling
    }
}

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
        NSLog(@"%i: %@ - %@", response.statusCode, url.absoluteString, requestFields);
    } else {
        //Error handling
    }
    
    return responseData;
}

- (void) login: (NSNotification *) notification
{
    [self sendRequestWithState: @"0"];
    [statusItem setImage:statusOn];
}

- (void) logoff: (NSNotification *) notification
{
	[self sendRequestWithState: @"1"];
    [statusItem setImage:statusOff];
}

- (void) dealloc {
    //Releases the 2 images we loaded into memory
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
    //UserDefaults holen
    preferences = [NSUserDefaults standardUserDefaults];
    //In TextField schreiben
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
