AndTekAgent
===========

Handy Cocoa/Objective-C menubar App for Mac OS X to communicate with a AndTek call center.

### Requirements

* Cisco Unified Communications Manager
* AndTek call center
* ~~Xcode to compile~~ (only for development)

### Usage

#### Installation

1. Download the latest release:  
  https://github.com/frdmn/AndTekAgent/releases
1. Drop the applicaton in your `/Applications` folder
1. Open it and adjust the informations according to your Cisco/AndTek environment

#### Develoment

1. Clone this repo
1. Build and run the project via Xcode
1. Adjust plist and replace the informations according to your Cisco/AndTek environment

### Screenshots

![menubar](http://up.frd.mn/q56wA.png)

![settings](http://up.frd.mn/C0sMr.png)

### Features / Changelog

* 0.2: Login and logout out of AndTek queues manually via menubar application
* 0.2.5: Auto login/logout in queues on "Switch user" event via OS X
* 0.3: Auto login/logout in queues on "Enter/exit screensaver" event
* 0.3.1: Auto logout before application gets quit (fixed #1)
* 0.3.2: [GiraHelper](http://git.frd.mn/iWelt/gira-helper/tree/master) integration (fixed #2)
* 0.3.3: Removed [GiraHelper](http://git.frd.mn/iWelt/gira-helper/tree/master) integration (ಠ_ಠ)
* 0.3.4: OS X 10.10 Yosemite deployment target
* 0.3.5: ~~Finally working default preferences~~
* 0.3.6: Finally working default preferences
* 0.4.0: New dark mode compatible menu bar icon, native OS X shortcuts in preferences
* 0.4.1: Implement Sparkle framework to automate updates! Whoop!

### Version

0.4.1

### License

[WTFPL](LICENSE)
