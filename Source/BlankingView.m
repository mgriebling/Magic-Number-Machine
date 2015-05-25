// ##############################################################
//  BlankingView.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################
#import "BlankingView.h"

//
// About BlankingView
//
// This is an opaque view that sits behind the drawer buttons so that if the window
// gets too small, the scientific buttons are not visible behind the drawer buttons.
//
// Its an aesthetic thing.
//

@implementation BlankingView

//
// isOpaque
//
// Since this view exists only to obscure the view behind it, it needs to be opaque
//
- (BOOL)isOpaque
{
	return YES;
}

//
// drawRect
//
// Draws the background in this view
//
- (void)drawRect:(NSRect)rect
{
	[[NSColor windowBackgroundColor] set];
	[[NSBezierPath bezierPathWithRect:rect] fill];
}

@end
