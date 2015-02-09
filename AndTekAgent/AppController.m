//
//  AppController.m
//  AndTekAgent
//
//  Created by Friedmann on 17.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"

@interface AppController()
- (void) sendRequestWithState: (NSString *) state;
- (void) login: (NSNotification *) notification;
- (void) logoff: (NSNotification *) notification;
@end

@implementation AppController

- (void) awakeFromNib{
    //Create the NSStatusBar and set its length
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    
    //Used to detect where our files are
    NSBundle *bundle = [NSBundle mainBundle];
    
    //Allocates and loads the images into the application which will be used for our NSStatusItem
    statusOn = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"iconon" ofType:@"png"]];
    statusOff = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"iconoff" ofType:@"png"]];
    
    //Sets the images in our NSStatusItem
    [statusItem setImage:statusOff];
    //[statusItem setAlternateImage:statusHighlightImage];
    
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
}

- (id) init
{
    
    self = [super init];
    
    if (self)
    {
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(login:) name:  NSWorkspaceSessionDidBecomeActiveNotification object: nil];
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(logoff:) name: NSWorkspaceSessionDidResignActiveNotification object: nil];
        
        // Add support for screensaver switch
//        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(logoff:) name:@"com.apple.screensaver.didstart" object:nil];
//        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(logoff:) name:@"com.apple.screensaver.willstop" object:nil];
//        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(login:) name:@"com.apple.screensaver.didstop" object:nil];

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

- (void) sendRequestWithState: (NSString *) state
{
    
    NSString * ServerURL = [NSString stringWithFormat: @"http://%@:%@/%@", [serverAdresse stringValue], [portAdresse stringValue], [apiAdresse stringValue]];

	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: ServerURL]
															  cachePolicy: NSURLRequestUseProtocolCachePolicy
														  timeoutInterval: 20.0];
	[theRequest setHTTPMethod: @"POST"];
	const char *stringToSend = [[NSString stringWithFormat: @"queue=all&setsec=-1&page=available&state=%@&dev=SEP%@", state, [macAdresse stringValue]] UTF8String];
	[theRequest setHTTPBody:[NSData dataWithBytes: stringToSend length: strlen(stringToSend)]];
	
	NSURLResponse *response;
    [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error:nil];
        
    NSLog(@"AndTekAgent | Version %@ (http://frd.mn/)", [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"]);
    NSLog(@"AndTekAgent | -- Server-Socket: \t%@:%@", [serverAdresse stringValue], [portAdresse stringValue]);
    NSLog(@"AndTekAgent | -- API-Pfad: \t\t%@", [apiAdresse stringValue]);
    NSLog(@"AndTekAgent | -- Device-MAC: \t%@", [macAdresse stringValue]);
    
    if ([state intValue] == 0) {
        NSLog(@"AndTekAgent | -- Forderung: \tLogin");
    } else if  ([state intValue] == 1) {
        NSLog(@"AndTekAgent | -- Forderung: \tLogout");
    } else {
        NSLog(@"AndTekAgent | -- Forderung: \tFehler bei der Parsen der Statusanforderung");
    }
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
