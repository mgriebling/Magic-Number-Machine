// ##############################################################
//  Bracket.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun May 25 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "Bracket.h"
#import "ExpressionSymbols.h"

//
// About Bracket
//
// A basic node which exists to wrap a sub-tree.
//

@implementation Bracket

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

//
// initWithParent
//
// Same as inherited except initialises "closed" to no.
//
- (instancetype)initWithParent:(Expression*)newParent andManager:(DataManager*)newManager
{
	self = [super initWithParent:newParent andManager:newManager];
	if (self)
	{
		closed = NO;
	}
	return self;
}

//
// initWithCoder
//
// Part of the NSCoder protocol. Required for copy and paste.
//
- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	closed = [coder decodeBoolForKey:@"MEClosed"];
	
	return self;
}

//
// encodeWithCoder
//
// Part of the NSCoder protocol. Required for copy and paste.
//
- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeBool:closed forKey:@"MEClosed"];
}

//
// binaryOpPressed
//
// Default behaviour if bracket closed, otherwise spilts the child first.
//
- (void)binaryOpPressed:(int)op
{
	if (closed == YES)
		[super binaryOpPressed:op];
	else
		// Split the child into a binary operation.
		[self replaceChild:child withBinOp:op];
}

//
// closeBracketPressed
//
// Closes this node's sub-tree (and causes the right bracket to be drawn)
//
- (void)closeBracketPressed
{
	if (closed == YES)
	{
		[super closeBracketPressed];
		return;
	}
	closed = YES;
	pathValidAt = -1;
	[self inputPoint];
	[self valueChanged];
}

//
// deleteDigit
//
// Same as inherited except opens the sub-tree if this node is closed.
//
- (void)deleteDigit
{
	if (closed == YES)
	{
		closed = NO;
		[self valueChanged];
	}
	else
	{
		[super deleteDigit];
	}
}

//
// equalsPressed
//
// When equals is pressed we want to close all our bracketed groups (it looks prettier)
//
// This behaviour is the only reason for this function to exist.
//
- (void)equalsPressed
{
	[super equalsPressed];
	
	if (closed == NO)
	{
		closed = YES;
		[self valueChanged];
	}
}

//
// getExpressionString
//
// Ouputs this node as a string.
//
- (NSString*)getExpressionString
{
	NSString *resultString = @"(";
	
	if (child != nil)
		resultString = [resultString stringByAppendingString:[child getExpressionString]];
	
	if (closed == YES)
	{
		resultString = [resultString stringByAppendingString:@")"];
	}

	return resultString;
}

//
// pathAtLevel
//
// Drawing this node is pretty simple: it draws the child node and places a left bracket to
// the left of the child and a right bracket to the right if this node is closed.
//
- (NSBezierPath*)pathAtLevel:(int)level
{
	NSBezierPath *copy;
	
	if (pathValidAt != level)
	{
		NSBezierPath 		*rightBracket;
		NSAffineTransform	*transform;
		double				scale = [Expression scaleWithLevel:level];
		NSRect				boundsRect;
		NSBezierPath		*childPath = [NSBezierPath bezierPath];
		double				bracketHeight;
		double				bracketWidth;
		double				bracketBaseline;
		
		expressionPath = [NSBezierPath bezierPath];

		// Get the left bracket
		[expressionPath appendBezierPath:[ExpressionSymbols leftBracketPath]];
		transform = [NSAffineTransform transform];
		[transform scaleBy:scale];
		[expressionPath transformUsingAffineTransform:transform];
		
		boundsRect = [expressionPath bounds];
		bracketWidth = boundsRect.origin.x + boundsRect.size.width;
		bracketHeight = boundsRect.size.height;
		bracketBaseline = boundsRect.origin.y;

		if (child != nil)
		{
			// Get the bracket contents
			childPath = [child pathAtLevel:level];
			
			// Transform the op to the right of the child's value
			transform = [NSAffineTransform transform];
			[transform translateXBy:bracketWidth yBy:0];
			[childPath transformUsingAffineTransform:transform];
		}
		
		if (closed)
		{
			// Get the right bracket
			rightBracket = [ExpressionSymbols rightBracketPath];
			transform = [NSAffineTransform transform];
			[transform scaleBy:scale];
			[rightBracket transformUsingAffineTransform:transform];
			
			transform = [NSAffineTransform transform];
			if (child != nil)
			{
				// Position the right bracket after the bracket contents
				boundsRect = [childPath bounds];
				[transform
					translateXBy:boundsRect.origin.x + boundsRect.size.width + (scale * 2.0) yBy:0
				];
			}
			else
			{
				// Position the right bracket after the left bracket
				transform = [NSAffineTransform transform];
				[transform translateXBy:bracketWidth yBy:0];
			}
			// The left and right bracket now get joined together
			[rightBracket transformUsingAffineTransform:transform];
			[expressionPath appendBezierPath:rightBracket];
		}
		
		if (child != nil)
		{
			// Scale the brackets so that they are the same height as the value that they contain
			boundsRect = [childPath bounds];
			transform = [NSAffineTransform transform];
			[transform
				translateXBy:0.0
				yBy:((boundsRect.origin.y < 0.0) ? boundsRect.origin.y : 0.0) - (3.0 * scale)
			];
			
			if ((boundsRect.size.height + (6.0 * scale)) / bracketHeight > 1.0)
				[transform scaleXBy:1.0 yBy:(boundsRect.size.height + (6.0 * scale)) / bracketHeight];
			[transform translateXBy:0.0 yBy:-bracketBaseline];
			[expressionPath transformUsingAffineTransform:transform];
			[expressionPath appendBezierPath:childPath];
		}
		
		if (![expressionPath isEmpty])
			naturalBounds = [expressionPath bounds];
		else
			naturalBounds = NSMakeRect(0.0, 0.0, 0.0, 0.0);
		if (![childPath isEmpty])
			childNaturalBounds = [childPath bounds];
		else
			childNaturalBounds = NSMakeRect(0.0, 0.0, 0.0, 0.0);
		pathValidAt = level;
	}
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:expressionPath];
	
	return copy;
}

//
// postOpPressed
//
// Not certain what this is doing. I'm sure it has a point, I just can't remember it.
//
- (void)postOpPressed:(int)op
{
	if (closed == YES)
	{
		[super postOpPressed:op];
	}
	else
	{
		// Create a postOp at the child node and set it as the input point
		[self replaceChild:child withPostOp:op];
	}
}

@end
