AndTek Agent
============

Handy Cocoa/Objective-C menubar App for Mac OS X to communicate with a AndTek call center.

## Features / changelog

* 0.2: Login and logout out of AndTek queues manually via menubar application
* 0.2.5: Auto login/logout in queues on "Switch user" event via OS X
* 0.3: Auto login/logout in queues on "Enter/exit screensaver" event
* 0.3.1: Auto logout before application gets quit (fixed #1)
* 0.3.2: [GiraHelper](http://git.frd.mn/iWelt/gira-helper/tree/master) integration (fixed #2)
* 0.3.3: Removed [GiraHelper](http://git.frd.mn/iWelt/gira-helper/tree/master) integration (ಠ_ಠ)

## Requirements

1. Cisco Unified Communications Manager
1. AndTek call center
1. OS X workstation
1. Xcode

## Installation

* Clone this repo
* Compile from source
* Build the executable via Xcode
* Copy plist into "Preferences" folder:
`cp opt/de.frdmn.AndTekAgent.plist ~/Library/Preferences/`
* Adjust plist and replace the informations according to your Cisco/AndTek environment

## Screenshots

#### Menubar

![menubar](http://static.yeahwh.at/plugins/AndTekAgent/1_menubar.png)

#### Settings pane

![settings](http://static.yeahwh.at/plugins/AndTekAgent/2_settings.png)

## Version
0.3.3
