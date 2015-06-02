// ##############################################################
//  PreOp.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Wed May 14 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "PreOp.h"
#import "ExpressionSymbols.h"
#import "BigCFloat.h"
#import "DataManager.h"
#import "OpEnumerations.h"

//
// About PreOp
//
// The majority of functions that can be entered are PreOps. Any function that normally
// appears as: function(child) is a PreOp.
//
// Most of this class is devoted to large switch statements that simply apply the relevant
// function for calculations and display.
//
@implementation PreOp

//
// initWithCoder
//
// Initialises the class with the specified operation.
//
- (instancetype)initWithParent:(Expression*)newParent manager:(DataManager*)newManager andOp:(int)newOp
{
	self = [super initWithParent:newParent andManager:newManager];
	if (self)
	{
		op = newOp;
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
	
	op = [coder decodeIntForKey:@"MEOp"];
	
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

	[coder encodeInt:op forKey:@"MEOp"];
}

//
// Adds inverse to the workingPath argument -- Mike (why was this never factored before?)
//
- (NSBezierPath *)addInverseTo: (NSBezierPath *)workingPath {
	NSRect workingBounds;
	NSBezierPath *opPath;
	NSAffineTransform *workingTransform;
	workingBounds = [workingPath bounds];
	workingTransform = [NSAffineTransform transform];
	[workingTransform translateXBy:workingBounds.origin.x + workingBounds.size.width yBy:0];
	opPath = [ExpressionSymbols inversePath];
	[opPath transformUsingAffineTransform:workingTransform];
	[opPath appendBezierPath:workingPath];
	return opPath;
}

//
// Adds hyperbolic to the workingPath argument -- Mike (why was this never factored before?)
//
- (NSBezierPath *)addHyperbolicTo: (NSBezierPath *)workingPath {
	NSRect workingBounds;
	NSBezierPath *opPath;
	NSAffineTransform *workingTransform;
	workingBounds = [workingPath bounds];
	workingTransform = [NSAffineTransform transform];
	[workingTransform translateXBy:workingBounds.origin.x + workingBounds.size.width yBy:0];
	opPath = [ExpressionSymbols hypPath];
	[opPath transformUsingAffineTransform:workingTransform];
	[opPath appendBezierPath:workingPath];
	return opPath;
}

//
// Adds subscript 2 to the workingPath argument -- Mike (why was this never factored before?)
//
- (NSBezierPath *)addSubscript2: (NSBezierPath *)workingPath {
	NSRect workingBounds;
	NSBezierPath *opPath;
	NSAffineTransform *workingTransform;
	workingBounds = [workingPath bounds];
	workingTransform = [NSAffineTransform transform];
	[workingTransform translateXBy:workingBounds.origin.x + workingBounds.size.width yBy:0];
	opPath = [ExpressionSymbols sub2Path];
	[opPath transformUsingAffineTransform:workingTransform];
	[opPath appendBezierPath:workingPath];
	return opPath;
}

//
// appendOpToPath
//
// Creates the bezierPath representation of the operand
//
- (void)appendOpToPath:(NSBezierPath*)path atLevel:(int)level
{
	NSBezierPath		*opPath;
//	NSAffineTransform	*workingTransform;
//	NSBezierPath		*workingPath;
//	NSRect				workingBounds;

	switch (op)
	{
		case sinOp:
			opPath = [ExpressionSymbols sinPath];
			break;
		case cosOp:
			opPath = [ExpressionSymbols cosPath];
			break;
		case tanOp:
			opPath = [ExpressionSymbols tanPath];
			break;
		case arcsinOp:
			opPath = [self addInverseTo:[ExpressionSymbols sinPath]];
			break;
		case arccosOp:
			opPath = [self addInverseTo:[ExpressionSymbols cosPath]];
			break;
		case arctanOp:
			opPath = [self addInverseTo:[ExpressionSymbols tanPath]];
			break;
		case sinhOp:
			opPath = [self addHyperbolicTo:[ExpressionSymbols sinPath]];
			break;
		case coshOp:
			opPath = [self addHyperbolicTo:[ExpressionSymbols cosPath]];
			break;
		case tanhOp:
			opPath = [self addHyperbolicTo:[ExpressionSymbols tanPath]];
			break;
		case arcsinhOp:
			opPath = [self addInverseTo:[self addHyperbolicTo:[ExpressionSymbols sinPath]]];
			break;
		case arccoshOp:
			opPath = [self addInverseTo:[self addHyperbolicTo:[ExpressionSymbols cosPath]]];
			break;
		case arctanhOp:
			opPath = [self addInverseTo:[self addHyperbolicTo:[ExpressionSymbols tanPath]]];
			break;
		case reOp:
			opPath = [ExpressionSymbols rePath];
			break;
		case imOp:
			opPath = [ExpressionSymbols imPath];
			break;
		case argOp:
			opPath = [ExpressionSymbols argPath];
			break;
		case absOp:
			opPath = [ExpressionSymbols absPath];
			break;
		case notOp:
			opPath = [ExpressionSymbols notPath];
			break;
		case rndOp:
			opPath = [ExpressionSymbols rndPath];
			break;
		case logOp:
			opPath = [ExpressionSymbols logPath];
			break;
		case log2Op:
			opPath = [self addSubscript2:[ExpressionSymbols logPath]];			
			break;
		case lnOp:
			opPath = [ExpressionSymbols lnPath];
			break;
		case sqrtOp:
			opPath = [ExpressionSymbols sqrtPath];
			break;
		case cbrtOp:
			opPath = [ExpressionSymbols sqrtPath];
			[opPath appendBezierPath:[ExpressionSymbols nRootPath:3]];
			break;
		case sigmaOp:
			opPath = [ExpressionSymbols sigmaPath];
			break;
		case tenOp:
			opPath = [ExpressionSymbols tenPath];
			break;
		case twoOp:
			opPath = [ExpressionSymbols getSymbolForString:@"2"];
			break;
		case eOp:
			opPath = [ExpressionSymbols ePath];
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
// getCaretPoint
//
// Default behaviour for everything except e^ and 10^ where the caret point is a little
// higher.
//
- (NSPoint)getCaretPoint
{
	NSPoint caretPoint = [super getCaretPoint];
	
	if ((op == eOp || op == tenOp || op == twoOp) && child == nil)
	{
		caretPoint.y += 16.0 * [Expression scaleWithLevel:pathValidAt];
	}
	
	return caretPoint;
}

//
// getExpressionString
//
// Converts the current node to a string. Output is just the preOp as a string with
// the child appended.
//
- (NSString*)getExpressionString
{
	NSString *resultString = @"";
	
	switch (op)
	{
		case sinOp:
			resultString = [resultString stringByAppendingString:@"sin"];
			break;
		case cosOp:
			resultString = [resultString stringByAppendingString:@"cos"];
			break;
		case tanOp:
			resultString = [resultString stringByAppendingString:@"tan"];
			break;
		case arcsinOp:
			resultString = [resultString stringByAppendingString:@"asin"];
			break;
		case arccosOp:
			resultString = [resultString stringByAppendingString:@"acos"];
			break;
		case arctanOp:
			resultString = [resultString stringByAppendingString:@"atan"];
			break;
		case sinhOp:
			resultString = [resultString stringByAppendingString:@"sinh"];
			break;
		case coshOp:
			resultString = [resultString stringByAppendingString:@"cosh"];
			break;
		case tanhOp:
			resultString = [resultString stringByAppendingString:@"tanh"];
			break;
		case arcsinhOp:
			resultString = [resultString stringByAppendingString:@"asinh"];
			break;
		case arccoshOp:
			resultString = [resultString stringByAppendingString:@"acosh"];
			break;
		case arctanhOp:
			resultString = [resultString stringByAppendingString:@"atanh"];
			break;
		case reOp:
			resultString = [resultString stringByAppendingString:@"Re"];
			break;
		case imOp:
			resultString = [resultString stringByAppendingString:@"Im"];
			break;
		case argOp:
			resultString = [resultString stringByAppendingString:@"arg"];
			break;
		case absOp:
			resultString = [resultString stringByAppendingString:@"abs"];
			break;
		case notOp:
			resultString = [resultString stringByAppendingString:@"not"];
			break;
		case rndOp:
			resultString = [resultString stringByAppendingString:@"Rnd"];
			break;
		case logOp:
			resultString = [resultString stringByAppendingString:@"log"];
			break;
		case log2Op:
			resultString = [resultString stringByAppendingString:@"log₂"];
			break;
		case lnOp:
			resultString = [resultString stringByAppendingString:@"ln"];
			break;
		case sqrtOp:
			resultString = [resultString stringByAppendingString:@"√"];
			break;
		case cbrtOp:
			resultString = [resultString stringByAppendingString:@"∛"];
			break;
		case sigmaOp:
			resultString = [resultString stringByAppendingString:@"∑"];
			break;
		case tenOp:
			resultString = [resultString stringByAppendingString:@"10^"];
			break;
		case twoOp:
			resultString = [resultString stringByAppendingString:@"2^"];
			break;
		case eOp:
			resultString = [resultString stringByAppendingString:@"e^"];
			break;
	}

	if (child != nil)
		resultString = [resultString stringByAppendingString:[child getExpressionString]];

	return resultString;
}

//
// getValue
//
// Calculates the value of the node. It is just the pre-op function applied to the child.
//
- (BigCFloat*)getValue
{
	BigCFloat	*temp;
	
	if (valueValid == NO)
	{
		if (child != nil)
		{
			value = (BigCFloat*)[[child getValue] duplicate];
			
			switch (op)
			{
				case sinOp:
					[value sinWithTrigMode:[manager getTrigMode] inv:NO hyp:NO];
					break;
				case cosOp:
					[value cosWithTrigMode:[manager getTrigMode] inv:NO hyp:NO];
					break;
				case tanOp:
					[value tanWithTrigMode:[manager getTrigMode] inv:NO hyp:NO];
					break;
				case arcsinOp:
					[value sinWithTrigMode:[manager getTrigMode] inv:YES hyp:NO];
					break;
				case arccosOp:
					[value cosWithTrigMode:[manager getTrigMode] inv:YES hyp:NO];
					break;
				case arctanOp:
					[value tanWithTrigMode:[manager getTrigMode] inv:YES hyp:NO];
					break;
				case sinhOp:
					[value sinWithTrigMode:[manager getTrigMode] inv:NO hyp:YES];
					break;
				case coshOp:
					[value cosWithTrigMode:[manager getTrigMode] inv:NO hyp:YES];
					break;
				case tanhOp:
					[value tanWithTrigMode:[manager getTrigMode] inv:NO hyp:YES];
					break;
				case arcsinhOp:
					[value sinWithTrigMode:[manager getTrigMode] inv:YES hyp:YES];
					break;
				case arccoshOp:
					[value cosWithTrigMode:[manager getTrigMode] inv:YES hyp:YES];
					break;
				case arctanhOp:
					[value tanWithTrigMode:[manager getTrigMode] inv:YES hyp:YES];
					break;
				case reOp:
					value = [BigCFloat bigFloatWithReal:[value realPart] imaginary:nil];
					break;
				case imOp:
					value = [BigCFloat bigFloatWithReal:[value imaginaryPart] imaginary:nil];
					break;
				case argOp:
					value = [BigCFloat bigFloatWithReal:[value angle] imaginary:nil];
					break;
				case absOp:
					value = [BigCFloat bigFloatWithReal:[value magnitude] imaginary:nil];
					break;
				case notOp:
					[value bitnotWithComplement:[manager getComplement]];
					break;
				case rndOp:
					[value wholePart];
					break;
				case logOp:
					[value logOfBase:[BigCFloat bigFloatWithInt:10 radix:[manager getRadix]]];
					break;
				case log2Op:
					[value logOfBase:[BigCFloat bigFloatWithInt:2 radix:[manager getRadix]]];
					break;
				case lnOp:
					[value ln];
					break;
				case sqrtOp:
					[value sqrt];
					break;
				case cbrtOp:
					[value cbrt];
					break;
				case sigmaOp:
					[value sum];
					break;
				case tenOp:
					temp = [BigCFloat bigFloatWithInt:10 radix:[manager getRadix]];
					[temp raiseToPower:value];
					value = (BigCFloat*)[temp duplicate];
					break;
				case twoOp:
					temp = [BigCFloat bigFloatWithInt:2 radix:[manager getRadix]];
					[temp raiseToPower:value];
					value = (BigCFloat*)[temp duplicate];
					break;
				case eOp:
					[value powerOfE];
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
// Returns the visual representation of this node as a bezier path. Pretty basic
// except for e^x and 10^x which have to raise the exponent a little.
//
- (NSBezierPath*)pathAtLevel:(int)level
{
	NSBezierPath *copy;
	double		 scale = [Expression scaleWithLevel:level];
	
	if (pathValidAt != level)
	{
		NSBezierPath *childPath = [NSBezierPath bezierPath];

		expressionPath = [NSBezierPath bezierPath];

		[self appendOpToPath:expressionPath atLevel:level];
		
		if (child != nil)
		{
			NSAffineTransform *transform;
			NSRect			  boundsRect = [expressionPath bounds];
			
			if (op == eOp || op == tenOp || op == twoOp)
			{
				transform = [NSAffineTransform transform];
				if (level == 0)
					childPath = [child pathAtLevel:level + 2];
				else
					childPath = [child pathAtLevel:level + 1];
				[transform translateXBy:0 * scale yBy:scale * 11];
				[childPath transformUsingAffineTransform:transform];
			}
			else
			{
				childPath = [child pathAtLevel:level];
			}
		
			transform = [NSAffineTransform transform];
			[transform translateXBy:boundsRect.origin.x + boundsRect.size.width yBy:0];
			[childPath transformUsingAffineTransform:transform];
			
			if (op == sqrtOp || op == cbrtOp || op == rootOp)
			{
				NSBezierPath *overLine = [NSBezierPath bezierPath];
				NSRect		 childBounds = [childPath bounds];
				
				transform = [NSAffineTransform transform];
				[transform translateXBy:0.0 yBy:childBounds.origin.y - 0.5 * boundsRect.origin.y];
				[transform
					scaleXBy:1.0
					yBy:(childBounds.size.height / boundsRect.size.height) * 1.25
				];
				[expressionPath transformUsingAffineTransform:transform];
				boundsRect = [expressionPath bounds];
				
				[overLine moveToPoint:
					NSMakePoint
					(
						boundsRect.origin.x + boundsRect.size.width,
						boundsRect.origin.y + boundsRect.size.height
					)
				];
				[overLine relativeLineToPoint:
					NSMakePoint(childBounds.size.width + 5.0, 0)
				];
				[overLine relativeLineToPoint:NSMakePoint(0, -1.5)];
				[overLine relativeLineToPoint:
					NSMakePoint(-(childBounds.size.width + 5.0), 0)
				];
				[overLine closePath];
				[expressionPath appendBezierPath:overLine];
				if (op == cbrtOp) [expressionPath appendBezierPath:[ExpressionSymbols nRootPath:3]];
			}

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
// Replaces the child with the new postOp
//
- (void)postOpPressed:(int)newOp
{
	[self replaceChild:child withPostOp:newOp];
}

//
// replaceChild
//
// Always pass binary operations through to the parent.
//
- (void)replaceChild:(Expression*)oldChild withBinOp:(int)newOp
{
	if (newOp == '^')
		[super replaceChild:oldChild withBinOp:newOp];
	else
		[parent replaceChild:self withBinOp:newOp];
}

@end
