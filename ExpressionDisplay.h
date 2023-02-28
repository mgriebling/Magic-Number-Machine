// ##############################################################
//  ExpressionDisplay.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Cocoa/Cocoa.h>

@class DataManager;

//
// About the ExpressionDisplay
//
// The ExpressionDisplay is the main view within the window. It displays the
// graphically laid out expression. Most of display though is created in the actual
// expression tree. This view mostly handles centreing and the scrolling and the
// compiling of the result with the expression.
//
@interface ExpressionDisplay : NSView
{
	IBOutlet DataManager	*dataManager;
	NSBezierPath				*expressionPath;
	NSBezierPath				*resultPath;
	NSBezierPath				*caretPath;
	
	bool					updateBlocked;
}
- (instancetype)initWithFrame:(NSRect)frame;

- (void)drawRect:(NSRect)rect;
- (void)expressionChanged;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSBezierPath *expressionPathFlipped;
- (void)mouseDown:(NSEvent*)theEvent;
- (void)setFrame:(NSRect)frameRect;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSData *pdfData;

@end
