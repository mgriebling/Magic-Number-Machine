// ##############################################################
//  DrawerView.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sat Apr 26 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <AppKit/AppKit.h>

@class DataManager;

//
// About the DrawerView
//
// Only exists to catch shift and option keys when the focus is in the drawer,
// otherwise we use standard window behaviour.
//

@interface DrawerView : NSView
{
	IBOutlet DataManager *dataManager;
}
- (void)flagsChanged:(NSEvent*)theEvent;

@end
