// ##############################################################
//  BlankingView.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Cocoa/Cocoa.h>

//
// About BlankingView
//
// This is an opaque view that sits behind the drawer buttons so that if the window
// gets too small, the scientific buttons are not visible behind the drawer buttons.
//
// Its an aesthetic thing.
//

@interface BlankingView : NSView
{
}
@property (NS_NONATOMIC_IOSONLY, getter=isOpaque, readonly) BOOL opaque;
- (void)drawRect:(NSRect)rect;

@end
