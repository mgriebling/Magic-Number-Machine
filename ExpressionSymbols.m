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
static NSArray *constantsDataRows = nil;

+ (CGFloat) size { return 40; }

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

	//
	// Constant values were updated from NIST to the known accuracies as of January 2008.
	// A few constant names were changed to make them unique and avoid confusion with
	// other constants since these names are used in the equations.
	//
	// Update by Michael Griebling
	constantsDataRows =
	@[
	  @[@"a_0",	  @"	Bohr radius (m)",							[BigCFloat bigFloatWithString:@"0.5291772085936e-10" radix:10]],
	  @[@"α",	  @"	Fine structure constant",					[BigCFloat bigFloatWithString:@"7.297352537650e-3" radix:10]],
	  @[@"atm",	  @"	Standard atmosphere (Pa)",					[BigCFloat bigFloatWithInt:101325 radix:10]],
	  @[@"b",	  @"	Wien displacement law constant (m K)",		[BigCFloat bigFloatWithString:@"2.897768551e-3" radix:10]],
	  @[@"c_1",	  @"	First radiation constant (W m²)",			[BigCFloat bigFloatWithString:@"3.7417711819e-16" radix:10]],
	  @[@"c_2",	  @"	Second radiation constant (m K)",			[BigCFloat bigFloatWithString:@"1.438775225e-2" radix:10]],
	  @[@"c",	  @"	Speed of light in vacuum (m s⁻¹)",			[BigCFloat bigFloatWithInt:299792458 radix:10]],
	  @[@"E_h",	  @"	Hartree energy (J)",						[BigCFloat bigFloatWithString:@"4.3597439422e-18" radix:10]],
	  @[@"e_c",	  @"	Elementary charge (C)",						[BigCFloat bigFloatWithString:@"1.60217648740e-19" radix:10]],
	  @[@"ε_0",	  @"	Permittivity of vacuum (F m⁻¹)",			[BigCFloat bigFloatWithString:@"8.854187817620389850536563e-12" radix:10]],
	  @[@"eV",	  @"	Electron volt (J)",							[BigCFloat bigFloatWithString:@"1.60217648740e-19" radix:10]],
	  @[@"F",	  @"	Faraday constant (C mol⁻¹)",				[BigCFloat bigFloatWithString:@"96485.339924" radix:10]],
	  @[@"g_e",	  @"	Electron g-factor",							[BigCFloat bigFloatWithString:@"-2.002319304362215" radix:10]],
	  @[@"g_µ",	  @"	Muon g-factor",								[BigCFloat bigFloatWithString:@"-2.002331841412" radix:10]],
	  @[@"g_n",	  @"	Standard acceleration of gravity (m s⁻²)",	[BigCFloat bigFloatWithString:@"9.80665" radix:10]],
	  @[@"G",	  @"	Gravitational constant (m³ kg⁻¹ s⁻²)",		[BigCFloat bigFloatWithString:@"6.6742867e-11" radix:10]],
	  @[@"G_0",	  @"	Conductance quantum (s)",					[BigCFloat bigFloatWithString:@"7.748091700453e-5" radix:10]],
	  @[@"h",	  @"	Planck constant (J s)",						[BigCFloat bigFloatWithString:@"6.6260689633e-34" radix:10]],
	  @[@"ħ",	  @"	Planck constant/2π (J s)",					[BigCFloat bigFloatWithString:@"1.05457162853e-34" radix:10]],
	  @[@"i",	  @"	square-root of -1",							[BigCFloat i]],
	  @[@"k",	  @"	Boltzmann constant (J K⁻¹)",				[BigCFloat bigFloatWithString:@"1.380650424e-23" radix:10]],
	  @[@"l_p",	  @"	Planck length (m)",							[BigCFloat bigFloatWithString:@"1.61625281e-35" radix:10]],
	  @[@"ƛ_C",	  @"	Electron Compton wavelength/2π (m)",		[BigCFloat bigFloatWithString:@"3.861592645953e-13" radix:10]],
	  @[@"λ_C,n", @"	Neutron Compton wavelength (m)",			[BigCFloat bigFloatWithString:@"1.319590895120e-15" radix:10]],
	  @[@"λ_C,p", @"	Proton Compton wavelength (m)",				[BigCFloat bigFloatWithString:@"1.321409844619e-15" radix:10]],
	  @[@"λ_C",	  @"	Electron Compton wavelength (m)",			[BigCFloat bigFloatWithString:@"2.426310217533e-12" radix:10]],
	  @[@"m_d",	  @"	Deuteron mass (kg)",						[BigCFloat bigFloatWithString:@"3.3435832017e-27" radix:10]],
	  @[@"m_e",	  @"	Electron mass (Kg)",						[BigCFloat bigFloatWithString:@"9.1093821545e-31" radix:10]],
	  @[@"m_n",	  @"	Neutron mass (kg)",							[BigCFloat bigFloatWithString:@"1.6749286e-27" radix:10]],
	  @[@"m_P",	  @"	Planck mass (kg)",							[BigCFloat bigFloatWithString:@"2.1764411e-08" radix:10]],
	  @[@"m_p",	  @"	Proton mass (kg)",							[BigCFloat bigFloatWithString:@"1.67262163783e-27" radix:10]],
	  @[@"m_u",	  @"	Atomic mass constant (kg)",					[BigCFloat bigFloatWithString:@"1.66053878283e-27" radix:10]],
	  @[@"µ_0",	  @"	Magnetic Permittivity of vacuum (N A⁻²)",	[BigCFloat bigFloatWithString:@"12.56637061435917295385057e-7" radix:10]],
	  @[@"µ_B",	  @"	Bohr magneton (J T⁻¹)",						[BigCFloat bigFloatWithString:@"9.2740091523e-24" radix:10]],
	  @[@"µ_d",	  @"	Deuteron magnetic moment (J T⁻¹)",			[BigCFloat bigFloatWithString:@"4.3307346511e-27" radix:10]],
	  @[@"µ_N",	  @"	Nuclear magneton (J T⁻¹)",					[BigCFloat bigFloatWithString:@"5.0507832413e-27" radix:10]],
	  @[@"n_0",	  @"	Loschmidt constant (m⁻³)",					[BigCFloat bigFloatWithString:@"2.686777447e+25" radix:10]],
	  @[@"N_A",	  @"	Avagadro constant (mol⁻¹)",					[BigCFloat bigFloatWithString:@"6.0221417930e+23" radix:10]],
	  @[@"φ_0",	  @"	Magnetic flux quantum (Wb)",				[BigCFloat bigFloatWithString:@"2.06783366752e-15" radix:10]],
	  @[@"π",	  @"	Pi",										[BigCFloat piWithRadix:10]],
	  @[@"r_e",	  @"	Electron classical radius (m)",				[BigCFloat bigFloatWithString:@"2.817940289458e-15" radix:10]],
	  @[@"R_H",	  @"	Quantized Hall resistance (Ω)",				[BigCFloat bigFloatWithString:@"25812.8063" radix:10]],
	  @[@"R",	  @"	Molar gas constant (J mol⁻¹ K⁻¹)",			[BigCFloat bigFloatWithString:@"8.31447215" radix:10]],
	  @[@"R_∞",	  @"	Rydberg constant (m⁻¹)",					[BigCFloat bigFloatWithString:@"10973731.56852773" radix:10]],
	  @[@"σ_e",	  @"	Electron Thomson cross section (m²)",		[BigCFloat bigFloatWithString:@"6.65245855827e-29" radix:10]],
	  @[@"σ",	  @"	Stefan-Boltzmann const. (W m⁻² K⁻⁴)",		[BigCFloat bigFloatWithString:@"5.67040040e-08" radix:10]],
	  @[@"t_p",	  @"	Planck time (s)",							[BigCFloat bigFloatWithString:@"5.3912427e-44" radix:10]],
	  @[@"T_P",	  @"	Planck temperature (K)",					[BigCFloat bigFloatWithString:@"1.416785e32" radix:10]],
	  @[@"V_m",	  @"	Molar vol. (ideal gas at STP) (m³ mol⁻¹)",	[BigCFloat bigFloatWithString:@"22.41399639e-3" radix:10]]
	];
}

//
// toFormattedString:
//
// Translates the constant with an "_" to a subscript -- Mike
//
+ (NSAttributedString *)toFormattedString: (NSString *)string {
	NSRange location = [string rangeOfString:@"_"];
	NSRange tabLocation = [string rangeOfString:@"\t"];
	string = [string stringByReplacingOccurrencesOfString:@"_" withString:@""];
	if (location.length > 0) {
		location.length = tabLocation.location - location.location - 1;
	}
	NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:string];
	[result addAttribute:NSFontAttributeName value:[ExpressionSymbols getDisplayFontWithSize:[ExpressionSymbols size]/4] range:location];
	[result addAttribute:NSSuperscriptAttributeName value:@-1 range:location];
	return result;
}

+ (NSBezierPath *)makeSymbolForConstant:(enum ConstType)constant {
	NSString *constantName = [ExpressionSymbols getNameForConstant:constant];
	NSArray *constantStrings = [constantName componentsSeparatedByString:@"_"];
	NSBezierPath *path;
	
	if (!symbols[constantName]) {
		path = [ExpressionSymbols makeSymbolForString:constantStrings[0] usingSuperscript:0 withOffset:0];
		if (constantStrings.count > 1) {
			CGFloat offset = path.bounds.size.width;
			[path appendBezierPath:[ExpressionSymbols makeSymbolForString:constantStrings[1] usingSuperscript:-[ExpressionSymbols size]/3 withOffset:offset]];
		}
		symbols[constantName] = path;
	} else {
		path = symbols[constantName];
	}
	return path;
}

+ (BigCFloat *)getValueForConstant:(enum ConstType)constant {
	return constantsDataRows[constant][2];
}

+ (NSString *)getNameForConstant:(enum ConstType)constant {
	return constantsDataRows[constant][0];
}

+ (NSArray *)getConstants {
	return constantsDataRows;
}

+ (NSFont *)getDisplayFontWithSize:(CGFloat)size {
	NSFont *font = [NSFont fontWithName:@"HelveticaNeue-Light" size:size];
	if (font == nil) font = [NSFont labelFontOfSize:size];
	// NSLog(@"Found font = %@", font);
	return font;
}

+ (NSFont *)getKeyFontWithSize:(CGFloat)size {
    NSFont *font = [NSFont fontWithName:@"HelveticaNeue" size:size];
    if (font == nil) font = [NSFont labelFontOfSize:size];
    // NSLog(@"Found font = %@", font);
    return font;
}

+ (NSFont *)getDisplayFont {
    return [ExpressionSymbols getDisplayFontWithSize:[ExpressionSymbols size]];
}

// This one is for iOS
//func appendString(string: String, withSize size: CGFloat) {
//	var unichars = [UniChar](string.utf16)
//	var glyphs = [CGGlyph](count: unichars.count, repeatedValue: 0)
//	let font = CTFontCreateWithName("HelveticaNeue", size, nil)
//	let gotGlyphs = CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
//	if gotGlyphs {
//		let cgpath = CTFontCreatePathForGlyph(font, glyphs[0], nil)
//		let path = UIBezierPath(CGPath: cgpath)
//		println(path)
//	}
//}

+ (NSBezierPath *)makeSymbolForString:(NSString *)symbol usingSuperscript:(NSInteger)superscript withOffset:(CGFloat)offsetx {
	NSLayoutManager	*layoutManager = [[NSLayoutManager alloc] init];
	NSTextStorage	*text = [[NSTextStorage alloc] initWithString:@""];
	NSBezierPath	*path = [NSBezierPath bezierPath];
	CGGlyph			*glyphs;
	int				j;
	int				numGlyphs;
	CGFloat			offsety = superscript;
    CGFloat         size = superscript == 0 ? [ExpressionSymbols size] : 2 * [ExpressionSymbols size] / 3;
	
	// Use a layout manager to get the glyphs for the string
	// Create a text storage area for the string
	[text addLayoutManager:layoutManager];
	NSFont *font = [ExpressionSymbols getDisplayFontWithSize:size];
	[text setAttributedString: [[NSAttributedString alloc] initWithString:symbol attributes:@{NSFontAttributeName:font}]];
	[path moveToPoint:NSMakePoint(offsetx, offsety)];
	numGlyphs = (int)[layoutManager numberOfGlyphs];
	glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * numGlyphs);
	for (j = 0; j < numGlyphs; j++) {
		glyphs[j] = [layoutManager CGGlyphAtIndex:j];
	}
//    [path appendBezierPathWithCGGlyphs:glyphs count:[text length] inFont:[text attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL]];
	[path
		appendBezierPathWithCGGlyphs:glyphs
		count:[text length]
		inFont:[text attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL]
	 ];
	free(glyphs);
	return path;
}

+ (NSBezierPath *)getSymbolForString:(NSString *)string withSuperscript:(NSInteger)superscript {
	NSBezierPath *copy = [NSBezierPath bezierPath];
	NSBezierPath *symbol;
	NSString *index = [NSString stringWithFormat:@"%@-%ld", string, superscript]; // distinguish between sub- and super-script
	if (![symbols valueForKey:index]) {
		symbol = [ExpressionSymbols makeSymbolForString:string usingSuperscript:superscript withOffset:0];
		symbols[index] = symbol;	// cache the symbol
	} else {
		symbol = symbols[index];
	}
	[copy appendBezierPath:symbol];
	return copy;
}

+ (NSBezierPath *)getSymbolForString:(NSString *)string {
	return [ExpressionSymbols getSymbolForString:string withSuperscript:0];
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
	return [ExpressionSymbols getSymbolForString:@"−"];
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
// log2Path
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)log2Path
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
// nRootPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)nRootPath:(NSUInteger)n
{
	NSString *root = [NSString stringWithFormat:@"%lu", (unsigned long)n];
	NSBezierPath *path = [ExpressionSymbols makeSymbolForString:root usingSuperscript:6 withOffset:0];
	return path;
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
	return [ExpressionSymbols getSymbolForString:@"∙"];
}

//
// squarePath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)squarePath
{
	return [ExpressionSymbols getSymbolForString:@"2" withSuperscript:[ExpressionSymbols size]/3];
}

//
// sub2Path
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)sub2Path
{
	return [ExpressionSymbols getSymbolForString:@"2" withSuperscript:-[ExpressionSymbols size]/3];
}

//
// cubedPath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)cubedPath
{
	return [ExpressionSymbols getSymbolForString:@"3" withSuperscript:[ExpressionSymbols size]/3];
}

//
// inversePath
//
// Returns the relevant bezier path.
//
+ (NSBezierPath *)inversePath
{
	return [ExpressionSymbols getSymbolForString:@"-1" withSuperscript:[ExpressionSymbols size]/3];
}

@end
