// ##############################################################
//  Constant.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Wed May 14 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "Constant.h"
#import "ExpressionSymbols.h"
#import "BigCFloat.h"
#import "DataManager.h"
#import "OpEnumerations.h"
#import "PreOp.h"

//
// About Constant
//
// This class exists to handle the two mathematical constants that can be entered
// as though they are numbers: pi and i.
//
// Most of the behaviour in this class comes from the fact that a Constant cannot
// have a child node, so a new node must be created every time one is required.
//
// Since this class handles a lot of the behaviour for numbers entered into an
// expression, it also forms the basis for Value (the user entered value class). 
//
// Modified: 25 May 2015 - Mike: Now support all constant symbols defined in the
// constants drawer.

@implementation Constant

//
// initWithParent
//
// Initialises this class with the constant set to either pi or i
//
- (instancetype)initWithParent:(Expression*)newParent manager:(DataManager*)newManager andConstant:(int)newConstant
{
	self = [super initWithParent:newParent andManager:newManager];
	if (self)
	{
		constant = newConstant;
		value = [ExpressionSymbols getValueForConstant:constant];
		negative = NO;
	}
	return self;
}

//
// initWithCoder
//
// Required for the NSCoder protocol, which is used by copy and paste.
//
- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	constant = [coder decodeIntForKey:@"MEConstant"];
	value = [coder decodeObjectForKey:@"MEValue"];

	return self;
}

//
// encodeWithCoder
//
// Required for the NSCoder protocol, which is used by copy and paste.
//
- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeInt:(int)constant forKey:@"MEConstant"];
	[coder encodeObject:value forKey:@"MEValue"];
}

//
// appendDigit
//
// Since this node can't be edited, we need a new node that can be.
//
- (void)appendDigit:(int)digit
{
	if (digit == '-')
	{
		BigCFloat *minusOne = [BigCFloat bigFloatWithInt:-1 radix:[manager getRadix]];
		[value multiplyBy:minusOne];
		negative = !negative;
		[self valueChanged];
		return;
	}
	
	// Behave as though we already have a child and spawn off another node
	[self binaryOpPressed:'.'];
	[[manager getInputPoint] appendDigit:digit];
}

//
// bracketPressed
//
// Since this node can't be edited, we need a new node that can be.
//
- (void)bracketPressed
{
	// Behave as though we already have a child and spawn off another node
	[self binaryOpPressed:'.'];
	[[manager getInputPoint] bracketPressed];
}

//
// constantPressed
//
// Since this node can't be edited, we need a new node that can be.
//
- (void)constantPressed:(enum ConstType)newConstant
{
	// Behave as though we already have a child and spawn off another node
	[self binaryOpPressed:'.'];
	[[manager getInputPoint] constantPressed:(int)newConstant];
}

//
// expressionInserted
//
// Since this node can't be edited, we need a new node that can be.
//
- (void)expressionInserted:(Expression*)newExpression
{
	// Behave as though we already have a child and spawn off another node
	[self binaryOpPressed:'.'];
	[[manager getInputPoint] expressionInserted:newExpression];
}

//
// getExpressionString
//
// Creates an output string for this node.
//
- (NSString*)getExpressionString
{
	NSString *resultString = negative ? @"-" : @"";
	resultString = [resultString stringByAppendingString:[ExpressionSymbols getNameForConstant:constant]];
	return resultString;
}

//
// pathAtLevel
//
// Creates a path containing either π or i
//
- (NSBezierPath*)pathAtLevel:(int)level
{
	NSBezierPath		*copy;
	
	if (pathValidAt != level)
	{
		expressionPath = [NSBezierPath bezierPath];
		[expressionPath appendBezierPath:[ExpressionSymbols makeSymbolForConstant:constant]];
		
		if (negative)
		{
			NSBezierPath		*minusPath = [NSBezierPath bezierPath];
			NSAffineTransform	*signTransform = [NSAffineTransform transform];
			NSRect				boundsRect;

			[minusPath appendBezierPath:[ExpressionSymbols minusPath]];
			boundsRect = [minusPath bounds];
			
			[signTransform translateXBy:boundsRect.origin.x + boundsRect.size.width + 4.0 yBy:0];
			[expressionPath transformUsingAffineTransform:signTransform];
			[expressionPath appendBezierPath:minusPath];
		}

		if (level >= 2)
		{
			NSAffineTransform	*transform = [NSAffineTransform transform];
			double				scale = [Expression scaleWithLevel:level];
	
			[transform scaleBy:scale];
			[expressionPath transformUsingAffineTransform:transform];
		}
		
		if (![expressionPath isEmpty])
			naturalBounds = [expressionPath bounds];
		else
			naturalBounds = NSMakeRect(0.0, 0.0, 0.0, 0.0);

		pathValidAt = level;
	}
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:expressionPath];
	
	return copy;
}

//
// preOpPressed
//
// Since this node can't be edited, we need a new node that can be.
//
- (void)preOpPressed:(int)newOp
{
	// Can't change the child so spawn another factor
	[self binaryOpPressed:'.'];
	[[manager getInputPoint] preOpPressed:newOp];
}

//
// valueInserted
//
// Since this node can't be edited, we need a new node that can be.
//
- (void)valueInserted:(BigCFloat*)newValue
{
	// Behave as though we already have a child (ie can't accept a new child)
	[self binaryOpPressed:'.'];
	[[manager getInputPoint] valueInserted:newValue];
}

@end
