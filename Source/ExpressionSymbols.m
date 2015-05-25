// ##############################################################
// ExpressionSymbols.m
// Magic Number Machine
//
// Created by Matt Gallagher on Sun May 04 2003
// Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "ExpressionSymbols.h"

//
// About ExpressionSymbols
//
// A single instance class that maintains the bezier paths for most drawable symbols
//
@implementation ExpressionSymbols

static NSMutableArray *symbols = nil;

//
// initialize
//
// Called once at program startup. Creates all the symbols.
//
+ (void)initialize
{
	NSArray			*stringSymbols;
	NSLayoutManager	*layoutManager;
	NSTextStorage	*text;
	NSBezierPath	*path;
	NSGlyph			*glyphs;
	int				i;
	int				j;
	int				numGlyphs;
	
	if (symbols != nil)
		return;
	
	// Create the array of strings that we plan to store in the Mutable array
	stringSymbols = @[
		@"+",		// 0
		@"-",		// 1
		@"x",		// 2
		@"=",		// 3
		@"sin",		// 4	
		@"cos",		// 5
		@"tan",		// 6
		@"h",		// 7
		@"Re",		// 8
		@"Im",		// 9
		@"abs",		// 10
		@"arg",		// 11
		@"and",		// 12
		@"or",		// 13
		@"xor",		// 14
		@"not",		// 15
		@"Rnd",		// 16
		@"log",		// 17
		@"ln",		// 18
		@"√",		// 19
		@"∑",		// 20
		@"10",		// 21
		@"e",		// 22
		@"!",		// 23
		@"i",		// 24
		@"π",		// 25
		@"%",		// 26
		@"nPr",		// 27
		@"nCr",		// 28
		@"(",		// 29
		@")",		// 30
		@"•",		// 31
		@"2",		// 32
		@"-1"];
	
	// Create the array for holding the symbols
	symbols = [NSMutableArray arrayWithCapacity:[stringSymbols count]];
	
	// Use a layout manager to get the glyphs for the string
	layoutManager = [[NSLayoutManager alloc] init];

	// Create a text storage area for the string
	text = [[NSTextStorage alloc] initWithString:@""];
	[text addLayoutManager:layoutManager];

	// Get the glyph/path representation of all the strings and store them appropriately
	for (i = 0; i < [stringSymbols count]; i++)
	{
		// Create a bezier path to contain the display
		path = [NSBezierPath bezierPath];
		
		if (i >= [stringSymbols count] - 2)
		{
			[text setAttributedString:
				[[NSAttributedString alloc]
					initWithString:stringSymbols[i]
					attributes:@{NSFontAttributeName: [NSFont labelFontOfSize:16]}
				]
			];
			[path moveToPoint:NSMakePoint(0, 12)];
		}
		else
		{
			[text setAttributedString:
				[[NSAttributedString alloc]
					initWithString:stringSymbols[i]
					attributes:@{NSFontAttributeName: [NSFont labelFontOfSize:24]}
				]
			];
			[path moveToPoint:NSMakePoint(0, 0)];
		}
		numGlyphs = [layoutManager numberOfGlyphs];
		glyphs = (NSGlyph *)malloc(sizeof(NSGlyph) * numGlyphs);
		for (j = 0; j < numGlyphs; j++)
		{
			glyphs[j] = [layoutManager glyphAtIndex:j];
		}
		[path
			appendBezierPathWithGlyphs:glyphs
			count:[text length]
			inFont:[text attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL]
		];
		free(glyphs);
		
		[symbols addObject:path];
	}
}

//
// plusPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)plusPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[0]];
	
	return copy;
}

//
// minusPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)minusPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[1]];
	
	return copy;
}

//
// multiplyPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)multiplyPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[2]];
	
	return copy;
}

//
// equalsPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)equalsPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[3]];
	
	return copy;
}

//
// sinPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)sinPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[4]];
	
	return copy;
}

//
// cosPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)cosPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[5]];
	
	return copy;
}

//
// tanPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)tanPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[6]];
	
	return copy;
}

//
// hypPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)hypPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[7]];
	
	return copy;
}

//
// rePath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)rePath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[8]];
	
	return copy;
}

//
// imPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)imPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[9]];
	
	return copy;
}

//
// absPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)absPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[10]];
	
	return copy;
}

//
// argPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)argPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[11]];
	
	return copy;
}

//
// andPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)andPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[12]];
	
	return copy;
}

//
// orPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)orPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[13]];
	
	return copy;
}

//
// xorPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)xorPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[14]];
	
	return copy;
}

//
// notPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)notPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[15]];
	
	return copy;
}

//
// rndPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)rndPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[16]];
	
	return copy;
}

//
// logPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)logPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[17]];
	
	return copy;
}

//
// lnPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)lnPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[18]];
	
	return copy;
}

//
// sqrtPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)sqrtPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[19]];
	
	return copy;
}

//
// sigmaPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)sigmaPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[20]];
	
	return copy;
}

//
// tenPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)tenPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[21]];
	
	return copy;
}

//
// ePath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)ePath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[22]];
	
	return copy;
}

//
// factorialPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)factorialPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[23]];
	
	return copy;
}

//
// iPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)iPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[24]];
	
	return copy;
}

//
// piPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)piPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[25]];
	
	return copy;
}

//
// modPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)modPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[26]];
	
	return copy;
}

//
// nprPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)nprPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[27]];
	
	return copy;
}

//
// ncrPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)ncrPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[28]];
	
	return copy;
}

//
// leftBracketPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)leftBracketPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[29]];
	
	return copy;
}

//
// rightBracketPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)rightBracketPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[30]];
	
	return copy;
}

//
// dotPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)dotPath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[31]];
	
	return copy;
}

//
// squarePath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)squarePath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[32]];
	
	return copy;
}

//
// inversePath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)inversePath
{
	NSBezierPath		*copy;
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:symbols[33]];
	
	return copy;
}

@end
