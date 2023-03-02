// ##############################################################
//  ExpressionDisplay.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "ExpressionDisplay.h"
#import "Expression.h"
#import "ExpressionSymbols.h"
#import "DataManager.h"

//
// About the ExpressionDisplay
//
// The ExpressionDisplay is the main view within the window. It displays the
// graphically laid out expression. Most of display though is created in the actual
// expression tree. This view mostly handles centreing and the scrolling and the
// compiling of the result with the expression.
//

#define DEFAULT_HEIGHT (219)		// default expression height -- shouldn't be hard-coded

@implementation ExpressionDisplay

- (BOOL)allowsVibrancy {
	return YES;
}

//
// initWithFrame
//
// Creates empty paths and sets the caret point.
//
// Mike: Updated to be a little more noticeable
//
- (instancetype)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		expressionPath = [NSBezierPath bezierPath];
		resultPath = [NSBezierPath bezierPath];
		
		caretPath = [NSBezierPath bezierPath];
		[caretPath setLineWidth:2];
		[caretPath moveToPoint:NSMakePoint(-6.0, -8.0)];
		[caretPath lineToPoint:NSMakePoint(0.0, 0.0)];
		[caretPath moveToPoint:NSMakePoint(6.0, -8.0)];
		[caretPath lineToPoint:NSMakePoint(0.0, 0.0)];
		
		updateBlocked = false;
	}
	
	return self;
}

//
// GetResultPath
//
// Fetches the result path and moves it into position and puts an equals sign at the front.
//
NSBezierPath* GetResultPath(Expression* expression)
{
	NSBezierPath	  *resultPath;
	NSBezierPath	  *valuePath;
	NSAffineTransform *translateTransform = [NSAffineTransform transform];
	NSRect			  resultBounds;
	
	// Get the result value
	valuePath = [expression getValuePathWithLevel:0];
	
	// Get the equals sign
	resultPath = [ExpressionSymbols equalsPath];
	resultBounds = [resultPath bounds];
	
	// Move the result into place (after the equals sign) 
	[translateTransform translateXBy:12.0 + resultBounds.origin.x + resultBounds.size.width yBy:0.0];
	[valuePath transformUsingAffineTransform:translateTransform];
	
	// Merge the two
	[resultPath appendBezierPath:valuePath];
	
	// Move the expression into its vertical position
	translateTransform = [NSAffineTransform transform];
	[translateTransform translateXBy:0.0 yBy:15.0];			// yBy:5.0  Adjust for scroll bar - Mike
	[resultPath transformUsingAffineTransform:translateTransform];
	
	return resultPath;
}

//
// drawRect
//
// Draws the entire contents of the view at the locations that have already been
// calculated.
//
- (void)drawRect:(NSRect)rect
{
//	NSBezierPath 	*background;
	
	[NSColor.secondaryLabelColor set];
	
	// Clear the background
	if (caretPath)
	{
        // No background drawing for transparency support
//		background = [NSBezierPath bezierPathWithRect:rect];
//		[[NSColor textBackgroundColor] set];
//		[background fill];
	}

	if (updateBlocked)
	{
		return;
	}
	
	if (![expressionPath isEmpty])
	{
		[[NSColor textColor] set];
		[expressionPath fill];
	}
	if (![resultPath isEmpty])
	{
		[[NSColor textColor] set];
		[resultPath fill];
	}
	else if (![expressionPath isEmpty])
	{
		[[NSColor labelColor] set];
		[caretPath stroke];
	}
}

//
// expressionChanged
//
// Regenerates the paths that are drawn in this view to account for an updated expression.
//
- (void)expressionChanged
{
	Expression *displayExpression;
	
	NSRect		expressionBounds = NSZeroRect;
	NSRect		resultBounds = NSZeroRect;
	NSRect		frameRect = [self frame];
	
	double		availableHeight = frameRect.size.height - 10.0;
	
	// Ensure that the old area is updated
	if (![expressionPath isEmpty])
		[self setNeedsDisplayInRect:[expressionPath bounds]];
	if (![resultPath isEmpty])
		[self setNeedsDisplayInRect:[resultPath bounds]];
	[self setNeedsDisplayInRect:[caretPath bounds]];

	// Lock the focus so that the bezier paths all work correctly
	[self lockFocus];
	
	// Get the expression that this window displays
	displayExpression = [dataManager getCurrentExpression];
	
	// This gets the bezier path for the result (if equals has been pressed)
	if ([dataManager getEqualsPressed])
	{
		resultPath = GetResultPath(displayExpression);
		resultBounds = [resultPath bounds];
		availableHeight -= resultBounds.size.height;
	}
	else
	{
		resultPath = [NSBezierPath bezierPath];
	}

	// Get the bezier path for the expression
	expressionPath = [displayExpression pathAtLevel:0];
	
	frameRect.size = [[self enclosingScrollView] contentSize];

	if (![expressionPath isEmpty])
	{
		NSAffineTransform	*transform = [NSAffineTransform transform];
		double	scale = (frameRect.size.height / DEFAULT_HEIGHT); // 104.0 is the default height

		expressionBounds = [expressionPath bounds];
		
		// Limit the amount that things can scale up.
		if (scale > availableHeight / expressionBounds.size.height)
			scale = availableHeight / expressionBounds.size.height;
		
		// Adjust the scale
		[transform scaleBy:scale];
		[expressionPath transformUsingAffineTransform:transform];
		expressionBounds = [expressionPath bounds];
	}
	
	// Determine the required width of this view and adjust appropriately
	if (expressionBounds.size.width + 10.0 > frameRect.size.width)
		frameRect.size.width = expressionBounds.size.width + 10.0;
	if (resultBounds.size.width + 10.0 > frameRect.size.width)
		frameRect.size.width = resultBounds.size.width + 10.0;
	
	// This call to setFrame causes the expression and result to scale and centre appropriately
	// It also calls the expression and tells it where it has been layed out. This allows us to
	// then interrogate the input point about where it is and both scroll to the input point and
	// place the input caret.
	[self setFrame:frameRect];
	
	if (![expressionPath isEmpty])
		expressionBounds = [expressionPath bounds];
	if (![resultPath isEmpty])
		resultBounds = [resultPath bounds];

	// Corresponding unlock to lock at the start of this function
	[self unlockFocus];
	
	[self setNeedsDisplayInRect:expressionBounds];
	[self setNeedsDisplayInRect:resultBounds];
	[self setNeedsDisplayInRect:[caretPath bounds]];

	if ([dataManager getEqualsPressed] || ![expressionPath isEmpty])
	{
		NSRect	scrollTarget;
		NSSize	visibleSize = [[self enclosingScrollView] contentSize];
		
		if ([dataManager getEqualsPressed])
		{
			scrollTarget = [resultPath bounds];
		}
		else
		{
			scrollTarget = [[dataManager getInputPoint] getDisplayBounds];
			scrollTarget = NSUnionRect(scrollTarget, [caretPath bounds]);
		}
		
		// Many objects are wider than the screen. Focus on the right edge for the entry point.
		if (![dataManager getEqualsPressed] && scrollTarget.size.width > visibleSize.width)
		{
			scrollTarget.origin.x += scrollTarget.size.width - visibleSize.width;
			scrollTarget.size.width = visibleSize.width;
		}
		// Focus on the right edge for the result
		else if ([dataManager getEqualsPressed] && scrollTarget.size.width > visibleSize.width)
		{
			scrollTarget.size.width = visibleSize.width;
		}
		// Centre the result if it is smaller than the window
		else if ([dataManager getEqualsPressed] && scrollTarget.size.width < visibleSize.width)
		{
			scrollTarget.origin.x += 0.5 * (scrollTarget.size.width - visibleSize.width);
			scrollTarget.size.width = visibleSize.width;
		}
		
		[self scrollRectToVisible:scrollTarget];
	}
}

//
// expressionPathFlipped
//
// Returns the expression path flipped vertically for display in the history view which
// has its origin in a different place.
//
- (NSBezierPath*)expressionPathFlipped
{
	NSBezierPath 		*path;
	NSAffineTransform	*transform;
	NSSize				visibleSize = [[self enclosingScrollView] contentSize];
	
	path = [NSBezierPath bezierPath];
	transform = [NSAffineTransform transform];
	
	if (![expressionPath isEmpty])
	{
		NSRect	bounds = [expressionPath bounds];
		
		[path appendBezierPath:expressionPath];
		[transform scaleXBy:DEFAULT_HEIGHT / visibleSize.height yBy:-DEFAULT_HEIGHT / visibleSize.height];
		[transform
			translateXBy:-bounds.origin.x
			yBy:-bounds.size.height - bounds.origin.y
		];
		[path transformUsingAffineTransform:transform];
	}
	
	return path;
}

//
// pdfData
//
// Returns a data encoding of the view as PDF data
//
- (NSData *)pdfData
{
	if (![expressionPath isEmpty])
	{
		NSBezierPath *savedCaret = caretPath;
		caretPath = nil;
		NSData *result = [self dataWithPDFInsideRect:NSInsetRect([expressionPath bounds], -5, -5)];
		caretPath = savedCaret;
		return result;
	}
	
	return [self dataWithPDFInsideRect:[self bounds]];
}

//
// mouseDown
//
// When a mouse click occurs in this view, tell the data manager to set the input point
// at the point of the expression under the mouse.
//
- (void)mouseDown:(NSEvent*)theEvent
{
	[dataManager setInputAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
}

//
// setFrame
//
// When the window resizes, relayout needs to occur. This does that. Involves centreing and
// scrolling.
//
- (void)setFrame:(NSRect)frameRect
{
	NSRect  resultBounds = NSZeroRect;
    double  heightScale = frameRect.size.height / super.frame.size.height;   // _frame.size.height;
	
	// We don't want this call to setFrame to actually do any rendering
	updateBlocked = true;
	
	[super setFrame:frameRect];
	
	// Centre the result horizontally and draw it
	if (![resultPath isEmpty])
	{
		NSAffineTransform *transform = [NSAffineTransform transform];
		double				xTranslate;
		
		resultBounds = [resultPath bounds];

		xTranslate = (frameRect.size.width - resultBounds.size.width) / 2.0 - resultBounds.origin.x;
		[transform translateXBy:xTranslate yBy:0.0];
		[resultPath transformUsingAffineTransform:transform];
	}
	
	// Centre the expression horizontally and vertically in the gap above the result and draw it
	if (![expressionPath isEmpty])
	{
		NSAffineTransform *transform = [NSAffineTransform transform];
		double	xTranslate;
		double	yTranslate;
		NSRect	expressionBounds;
		double	scale = heightScale;
		NSPoint	oldCaretPoint;
		NSPoint	newCaretPoint;

		expressionBounds = [expressionPath bounds];
		
		// Limit the amount that things can scale up.
		if (scale > (frameRect.size.height - 10.0 - resultBounds.size.height) / expressionBounds.size.height)
			scale = (frameRect.size.height - 10.0 - resultBounds.size.height) / expressionBounds.size.height;
		
		if (scale > 0 && scale != 1.0)
		{
			NSRect	tempRect;
			
			// Adjust the scale
			[transform scaleBy:scale];
			[expressionPath transformUsingAffineTransform:transform];
			expressionBounds = [expressionPath bounds];

			tempRect = frameRect;
			tempRect.size = [[self enclosingScrollView] contentSize];
			if (expressionBounds.size.width + 10.0 > tempRect.size.width)
				tempRect.size.width = expressionBounds.size.width + 10.0;
			if (resultBounds.size.width + 10.0 > tempRect.size.width)
				tempRect.size.width = resultBounds.size.width + 10.0;
			
			[self setFrame:tempRect];
		}
		else
		{
			xTranslate = (frameRect.size.width - expressionBounds.size.width) / 2.0 - expressionBounds.origin.x;
			yTranslate = (frameRect.size.height - expressionBounds.size.height - resultBounds.size.height - resultBounds.origin.y - 10.0) / 2.0 + (resultBounds.size.height + resultBounds.origin.y) - expressionBounds.origin.y + 5.0;
			[transform translateXBy:xTranslate yBy:yTranslate];
			[expressionPath transformUsingAffineTransform:transform];
		}
	
		// Tell the current expression where it has been placed
		expressionBounds = [expressionPath bounds];
		[[dataManager getCurrentExpression] receiveBounds:expressionBounds];

		oldCaretPoint = [caretPath currentPoint];
		newCaretPoint = [[dataManager getInputPoint] getCaretPoint];
		
		// Place the caret at the the input point
		transform = [NSAffineTransform transform];
		[transform translateXBy:-oldCaretPoint.x+newCaretPoint.x yBy:-oldCaretPoint.y+newCaretPoint.y];
		[caretPath transformUsingAffineTransform:transform];
	}
	
	// Allow updates again.
	updateBlocked = false;
}

@end
