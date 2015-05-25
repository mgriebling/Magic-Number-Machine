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

static NSMutableDictionary *symbols = nil;

//
// initialize
//
// Called once at program startup. Creates all the symbols.
//
+ (void)initialize
{
	if (symbols != nil) return;
	
	// Create the array for holding the symbols
	symbols = [NSMutableDictionary dictionary];
}

+ (NSBezierPath *)makeSymbolForString:(NSString *)symbol usingSuperscript:(BOOL)superscript {
	NSLayoutManager	*layoutManager = [[NSLayoutManager alloc] init];
	NSTextStorage	*text = [[NSTextStorage alloc] initWithString:@""];
	NSBezierPath	*path = [NSBezierPath bezierPath];
	NSGlyph			*glyphs;
	int				j;
	int				numGlyphs;
	
	// Use a layout manager to get the glyphs for the string
	// Create a text storage area for the string
	[text addLayoutManager:layoutManager];
	
	if (superscript) {
		[text setAttributedString:
		 [[NSAttributedString alloc]
		  initWithString:symbol
		  attributes:@{NSFontAttributeName: [NSFont labelFontOfSize:16]}
				]
			];
		[path moveToPoint:NSMakePoint(0, 12)];
	} else {
		[text setAttributedString:
		 [[NSAttributedString alloc]
		  initWithString:symbol
		  attributes:@{NSFontAttributeName: [NSFont labelFontOfSize:24]}
				]
			];
		[path moveToPoint:NSMakePoint(0, 0)];
	}
	numGlyphs = [layoutManager numberOfGlyphs];
	glyphs = (NSGlyph *)malloc(sizeof(NSGlyph) * numGlyphs);
	for (j = 0; j < numGlyphs; j++) {
		glyphs[j] = [layoutManager glyphAtIndex:j];
	}
	[path
		appendBezierPathWithGlyphs:glyphs
		count:[text length]
		inFont:[text attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL]
	];
	free(glyphs);
	return path;
}

+ (NSBezierPath *)getSymbolForString:(NSString *)string withSuperscript:(BOOL)superscript {
	NSBezierPath *copy = [NSBezierPath bezierPath];
	NSBezierPath *symbol;
	
	if (![symbols valueForKey:string]) {
		symbol = [ExpressionSymbols makeSymbolForString:string usingSuperscript:superscript];
		symbols[string] = symbol;
	} else {
		symbol = symbols[string];
	}
	[copy appendBezierPath:symbol];
	return copy;
}

+ (NSBezierPath *)getSymbolForString:(NSString *)string {
	return [ExpressionSymbols getSymbolForString:string withSuperscript:NO];
}

//
// plusPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)plusPath
{
	return [ExpressionSymbols getSymbolForString:@"+"];
}

//
// minusPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)minusPath
{
	return [ExpressionSymbols getSymbolForString:@"-"];
}

//
// multiplyPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)multiplyPath
{
	return [ExpressionSymbols getSymbolForString:@"×"];
}

//
// equalsPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)equalsPath
{
	return [ExpressionSymbols getSymbolForString:@"="];
}

//
// sinPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)sinPath
{
	return [ExpressionSymbols getSymbolForString:@"sin"];
}

//
// cosPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)cosPath
{
	return [ExpressionSymbols getSymbolForString:@"cos"];
}

//
// tanPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)tanPath
{
	return [ExpressionSymbols getSymbolForString:@"tan"];
}

//
// hypPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)hypPath
{
	return [ExpressionSymbols getSymbolForString:@"h"];
}

//
// rePath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)rePath
{
	return [ExpressionSymbols getSymbolForString:@"Re"];
}

//
// imPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)imPath
{
	return [ExpressionSymbols getSymbolForString:@"Im"];
}

//
// absPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)absPath
{
	return [ExpressionSymbols getSymbolForString:@"abs"];
}

//
// argPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)argPath
{
	return [ExpressionSymbols getSymbolForString:@"arg"];
}

//
// andPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)andPath
{
	return [ExpressionSymbols getSymbolForString:@"and"];
}

//
// orPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)orPath
{
	return [ExpressionSymbols getSymbolForString:@"or"];
}

//
// xorPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)xorPath
{
	return [ExpressionSymbols getSymbolForString:@"xor"];
}

//
// notPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)notPath
{
	return [ExpressionSymbols getSymbolForString:@"not"];
}

//
// rndPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)rndPath
{
	return [ExpressionSymbols getSymbolForString:@"Rnd"];
}

//
// logPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)logPath
{
	return [ExpressionSymbols getSymbolForString:@"log"];
}

//
// lnPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)lnPath
{
	return [ExpressionSymbols getSymbolForString:@"ln"];
}

//
// sqrtPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)sqrtPath
{
	return [ExpressionSymbols getSymbolForString:@"√"];
}

//
// sigmaPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)sigmaPath
{
	return [ExpressionSymbols getSymbolForString:@"∑"];
}

//
// tenPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)tenPath
{
	return [ExpressionSymbols getSymbolForString:@"10"];
}

//
// ePath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)ePath
{
	return [ExpressionSymbols getSymbolForString:@"e"];
}

//
// factorialPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)factorialPath
{
	return [ExpressionSymbols getSymbolForString:@"!"];
}

//
// iPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)iPath
{
	return [ExpressionSymbols getSymbolForString:@"i"];
}

//
// piPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)piPath
{
	return [ExpressionSymbols getSymbolForString:@"π"];
}

//
// modPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)modPath
{
	return [ExpressionSymbols getSymbolForString:@"%"];
}

//
// nprPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)nprPath
{
	return [ExpressionSymbols getSymbolForString:@"nPr"];
}

//
// ncrPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)ncrPath
{
	return [ExpressionSymbols getSymbolForString:@"nCr"];
}

//
// leftBracketPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)leftBracketPath
{
	return [ExpressionSymbols getSymbolForString:@"("];
}

//
// rightBracketPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)rightBracketPath
{
	return [ExpressionSymbols getSymbolForString:@")"];
}

//
// dotPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)dotPath
{
	return [ExpressionSymbols getSymbolForString:@"•"];
}

//
// squarePath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)squarePath
{
	return [ExpressionSymbols getSymbolForString:@"2" withSuperscript:YES];
}

//
// inversePath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)inversePath
{
	return [ExpressionSymbols getSymbolForString:@"-1" withSuperscript:YES];
}

@end
