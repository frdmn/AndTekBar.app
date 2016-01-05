//
//  AppDelegate.h
//  AndTekBar.app
//
//  Created by Friedmann on 07.09.15.
//  Copyright (c) 2015 frdmn. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    /* Outlets */
    IBOutlet    NSMenu      *statusMenu;
    // Settings
    IBOutlet    NSTextField *macAdresse;
    IBOutlet    NSTextField *serverAdresse;
    IBOutlet    NSTextField *portAdresse;
    IBOutlet    NSTextField *apiAdresse;
    IBOutlet    NSWindow    *settingsWindow;
    IBOutlet    NSTextField    *copyright;
    
    IBOutlet   NSMenuItem *loginItem;
    IBOutlet   NSMenuItem *logoutItem;
    
    /* Anderes */
    NSStatusItem            *statusItem;
    NSImage                 *statusOn;
    NSImage                 *statusOff;
    NSImage                 *statusFailure;
    NSUserDefaults          *preferences;
}

-(IBAction)doLogin:(id)sender;
-(IBAction)doLogout:(id)sender;
-(IBAction)showSettings:(id)sender;
-(IBAction)saveSettings:(id)sender;
-(IBAction)cancelSettings:(id)sender;
-(IBAction)openurl:(id)sender;

@end

