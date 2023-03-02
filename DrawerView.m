// ##############################################################
//  DrawerView.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sat Apr 26 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "DrawerView.h"
#import "DataManager.h"

//
// About the DrawerView
//
// Only exists to catch shift and option keys when the focus is in the drawer,
// otherwise we use standard window behaviour.
//

@implementation DrawerView

- (BOOL)allowsVibrancy {
    return YES;
}

//
// flagsChanged
//
// Tells the data manager when the state of the shift or option keys changes.
//
- (void)flagsChanged:(NSEvent*)theEvent
{
	NSEventModifierFlags newFlags = [theEvent modifierFlags];
	
//	[dataManager optionIsPressed:(newFlags & NSAlternateKeyMask) != 0];
    if ((newFlags & NSEventModifierFlagShift) != 0) {
		[dataManager shiftIsPressed];
	}	

	[super flagsChanged:theEvent];
}

@end
