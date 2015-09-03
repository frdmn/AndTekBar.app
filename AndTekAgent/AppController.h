//
//  AppController.h
//  AndTekAgent
//
//  Created by Friedmann on 17.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppController : NSObject {
    
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
    NSUserDefaults          *preferences;
}

-(IBAction)doLogin:(id)sender;
-(IBAction)doLogout:(id)sender;
-(IBAction)showSettings:(id)sender;
-(IBAction)saveSettings:(id)sender;
-(IBAction)cancelSettings:(id)sender;
-(IBAction)openurl:(id)sender;

@end
