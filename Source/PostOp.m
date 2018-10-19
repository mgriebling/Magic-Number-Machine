// ##############################################################
//  PostOp.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun May 25 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "PostOp.h"
#import "ExpressionSymbols.h"
#import "BigCFloat.h"
#import "DataManager.h"
#import "OpEnumerations.h"

//
// About PostOp
//
// A PostOp is an operator that goes after the number. The two post operations are
// square (x^2) and factorial (x!).
//
// Only minor behaviour changes relative to the inherited functionality  are required
// for this class.
//
@implementation PostOp

//
// initWithParent
//
// Creates this class enveloping the preceding node.
//
- (instancetype)initWithParent:(Expression*)newParent manager:(DataManager*)newManager child:(Expression*)newChild andOp:(int)newOp
{
	self = [super initWithParent:newParent andManager:newManager];
	if (self)
	{
		op = newOp;
		
		if (newChild != nil)
		{
			child = newChild;
			[child parentChanged:self];
		}
		else
		{
			child = nil;
		}
		[self valueChanged];
	}
	return self;
}

//
// initWithCoder
//
// Part of the NSCoding protocol. Required for copy and paste.
//
- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	op = [coder decodeIntForKey:@"MEOp"];
	
	return self;
}

//
// encodeWithCoder
//
// Part of the NSCoding protocol. Required for copy and paste.
//
- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeInt:op forKey:@"MEOp"];
}

//
// appendOpToPath
//
// Draws the operation for this node (either a raised 2 or an exclamation mark).
//
- (void)appendOpToPath:(NSBezierPath*)path atLevel:(int)level
{
	NSBezierPath			*opPath;

	switch (op)
	{
		case squaredOp:
			opPath = [ExpressionSymbols squarePath];
			break;
		case cubedOp:
			opPath = [ExpressionSymbols cubedPath];
			break;
		case factorialOp:
			opPath = [ExpressionSymbols factorialPath];
			break;
		case invOp:
			opPath = [ExpressionSymbols inversePath];
			break;
		default:
			opPath = nil;
			break;
	}
	
	if (level >= 2)
	{
		NSAffineTransform	*transform = [NSAffineTransform transform];
		double				scale = [Expression scaleWithLevel:level];

		[transform scaleBy:scale];
		[opPath transformUsingAffineTransform:transform];
	}
	
	[path appendBezierPath:opPath];
}

//
// getExpressionString
//
// Converts the node to a string.
//
- (NSString*)getExpressionString
{
	NSString *resultString = @"";
	
	if (child != nil)
		resultString = [resultString stringByAppendingString:[child getExpressionString]];

	switch (op)
	{
		case squaredOp:
			resultString = [resultString stringByAppendingString:@"^2"];
			break;
		case cubedOp:
			resultString = [resultString stringByAppendingString:@"^3"];
			break;
		case factorialOp:
			resultString = [resultString stringByAppendingString:@"!"];
			break;
		case invOp:
			resultString = [resultString stringByAppendingString:@"^(-1)"];
			break;
	}

	return resultString;
}

//
// getValue
//
// Calculates the result for this node depending on the operation.
//
- (BigCFloat*)getValue
{
	if (valueValid == NO)
	{
		if (child != nil)
		{
			value = (BigCFloat*)[[child getValue] duplicate];
			
			switch (op)
			{
				case squaredOp:
					[value multiplyBy:value];
					break;
                case cubedOp: {
                    BigCFloat *newValue = (BigCFloat*)[value duplicate];
					[value multiplyBy:value];
                    [value multiplyBy:newValue];
					break;
                }
				case factorialOp:
					[value factorial];
					break;
				case invOp:
					[value inverse];
					break;
				default:
					break;
			}
			
		}
		valueValid = YES;
	}
	
	return value;
}

//
// pathAtLevel
//
// Returns a bezier path containing the display representation of this node (just the child
// path with the postOp path after it).
//
- (NSBezierPath*)pathAtLevel:(int)level
{
	NSBezierPath		*copy;
	
	if (pathValidAt != level)
	{
		NSBezierPath *childPath = [NSBezierPath bezierPath];

		expressionPath = [NSBezierPath bezierPath];

		[self appendOpToPath:expressionPath atLevel:level];
		
		if (child != nil)
		{
			NSAffineTransform *transform = [NSAffineTransform transform];
			NSRect				boundsRect;
			
			childPath = [child pathAtLevel:level];
			boundsRect = [childPath bounds];

			// Transform the op to the right of the child's value
			[transform translateXBy:boundsRect.origin.x + boundsRect.size.width yBy:0];
			[expressionPath transformUsingAffineTransform:transform];
			
			// Prepend the child
			[expressionPath appendBezierPath:childPath];
		}
		
		if (![expressionPath isEmpty])
			naturalBounds = [expressionPath bounds];
		else
			naturalBounds = NSZeroRect;
		if (![childPath isEmpty])
			childNaturalBounds = [childPath bounds];
		else
			childNaturalBounds = NSZeroRect;
		pathValidAt = level;
	}
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:expressionPath];
	
	return copy;
}

//
// replaceChild
//
// Always pass to the parent when asked to replace the child with a binary operation.
//
- (void)replaceChild:(Expression*)oldChild withBinOp:(int)newOp
{
	[parent replaceChild:self withBinOp:newOp];
}

@end
