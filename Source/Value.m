// ##############################################################
//  Value.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "Value.h"
#import "BigCFloat.h"
#import "DataManager.h"

//
// About Value
//
// This class contains any user entered number. The number is store as a BigCFloat
// within the class.
//
// By far the ugliest part of this class is the drawing and user input functions. Drawing
// has to account for a large number of quirks that people expect, plus the layout of
// real and imaginary parts and the scientific exponent. User input has to track a
// number of values like number of fractional point places entered... all of which tend
// to change without notice.
//
// This is the only class which actually implements a number of methods which are
// simply passed through or ignore in other classes.
//

@implementation Value

//
// initWithParent
//
// Initalises the class to default (empty).
//
- (instancetype)initWithParent:(Expression*)newParent andManager:(DataManager*)newManager
{
	self = [super initWithParent:newParent andManager:newManager];
	if (self)
	{
		userPointState = -1;
		imaginaryPointState = -1;
		postPoint = 0;
		postImaginaryPoint = 0;
		hasExponent = NO;
		hasImaginary = NO;
		hasImaginaryExponent = NO;
		usesComplement = 0;
	}
	return self;
}

//
// initWithParent
//
// Initialises the class with a BigCFloat as the initial value.
//
- (instancetype)initWithParent:(Expression*)newParent value:(BigCFloat*)newValue andManager:(DataManager*)newManager
{
	self = [super initWithParent:newParent andManager:newManager];
	if (self)
	{
		userPointState = -1;
		imaginaryPointState = -1;
		postPoint = 0;
		postImaginaryPoint = 0;
		hasExponent = NO;
		hasImaginary = NO;
		hasImaginaryExponent = NO;
		usesComplement = -1;	// force reprocessing of above variables
		
		[value assign:newValue];
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
	
	value = [coder decodeObjectForKey:@"MEValue"];
	userPointState = -1;
	imaginaryPointState = -1;
	postPoint = 0;
	postImaginaryPoint = 0;
	hasExponent = NO;
	hasImaginary = NO;
	hasImaginaryExponent = NO;
	usesComplement = -1;	// force reprocessing of above variables
	
	return self;
}

//
// encodeWithCoder
//
// Part of the NSCoder protocol. Required for copy and paste.
//
- (void)encodeWithCoder:(NSCoder *)coder
{
	// Looks like I have nothing special to do at the moment
	[super encodeWithCoder:coder];
}

//
// appendDigit
//
// Appends a digit to the number contained by this node. This method is made more
// complicated because it has to track decimal points, the user trying to type more digits
// than will fit, the number of digits and imaginary numbers.
//
- (void)appendDigit:(int)digit
{
	int fixedPlaces = [manager getFixedPlaces];
	
	if ((hasExponent && !hasImaginary && digit != 'i') || hasImaginaryExponent)
	{
		[value appendExpDigit:digit];
	}
	else
	{
		if
		(
			!(digit >= 0 && digit <= 15)
			||
			(
				(fixedPlaces == 0 && [value mantissaLength] < [manager getLengthLimit])
				||
				(
					fixedPlaces != 0
					&&
					(
						(!hasImaginary && (postPoint < fixedPlaces))
						||
						(hasImaginary && (postImaginaryPoint < fixedPlaces))
					)
				)
			)
 		)
		{
			BOOL digit_added = [value appendDigit:digit useComplement:usesComplement];
			
			if (!digit_added)
				return;

			if (digit >= 0 && digit <= 15)
			{
				if (hasImaginary && !hasImaginaryExponent && imaginaryPointState != -1)
					postImaginaryPoint++;
				else if (!hasImaginary && !hasExponent && userPointState != -1)
					postPoint++;
			}
		}
	}
	
	if (!hasImaginary && digit == 'i')
	{
		hasImaginary = YES;
		if (userPointState == 0)
		{
			userPointState = -1;
		}
	}
	
	if (digit >= 0 && digit <= 15)
	{
		if (userPointState == 0)
		{
			userPointState = 1;
			[value setUserPoint:1];
		}
		if (imaginaryPointState == 0)
		{
			imaginaryPointState = 1;
			[value setUserPoint:1];
		}
	}
	[self valueChanged];
}

//
// clear
//
// Pretty simple: sets the number contained by this node to zero.
//
- (void)clear
{
	[parent childDeleted:self];
}

//
// deleteDigit
//
// Delete one digit from the right of the number. Does not yet function perfectly
// for numbers not typed by the user as it does not correctly track all values. Sigh.
//
// Most of the logic in this method is trying to track the reverse of appendDigit.
//
- (void)deleteDigit
{
	if (hasExponent || hasImaginaryExponent)
		[value deleteExpDigit];
	else
		[value deleteDigitUseComplement:usesComplement];
	
	// Update any of the things which may have changed
	if (hasImaginary)
	{
		if (hasImaginaryExponent)
		{
			if (![value imaginaryHasExponent])
				hasImaginaryExponent = NO;
		}
		else
		{
			if (imaginaryPointState == 1)
				postImaginaryPoint--;
			
			if (![value hasImaginary] && postImaginaryPoint == 0)
			{
				hasImaginary = NO;
				imaginaryPointState = -1;
			}
			else if (imaginaryPointState != -1 && [value getUserPoint] == 0)
			{
				imaginaryPointState = -1;
			}
		}
	}
	else
	{
		if (hasExponent)
		{
			if (![value hasExponent])
				hasExponent = NO;
		}
		else
		{
			if (userPointState == 1)
				postPoint--;
			
			if (userPointState != -1 && [value getUserPoint] == 0)
			{
				userPointState = -1;
			}
		}
	}
	
	// Delete this node of the expression tree if everything is deleted
	if (!hasImaginary && !hasExponent && [value isZero] && postPoint == 0)
	{
		[parent childDeleted:self];
		return;
	}
	else
	{
		[self valueChanged];
	}
}

//
// exponentPressed
//
// Puts a scientific notation style exponent on this value if none currently exists. If
// there is an imaginary part, it gets it instead.
//
- (void)exponentPressed
{
	if (hasImaginary)
	{
		hasImaginaryExponent = YES;
		if (imaginaryPointState == 0)
			imaginaryPointState = -1;
	}
	else
	{
		hasExponent = YES;
		if (userPointState == 0)
			userPointState = -1;
	}
	[self valueChanged];
}

//
// getExpressionString
//
// Converts the current value to a string. Most of this method would not exist (it is basically
// a duplication of generateValuePath) except this is really late in development and I'm long
// past caring about good programming style :-)
//
- (NSString*)getExpressionString
{
	NSString				*mantissa;
	NSString				*exponent;
	NSString				*imaginary;
	NSString				*imExponent;
	NSString				*resultString = @"";
	unsigned int			lengthLimit;
	BOOL					fillLimit;
	BOOL					radixChanged = NO;
	unsigned int			fixedPlaces;
	NSArray					*splitString;
	int						extraZeros;
	BOOL					showReal = NO;
	BOOL					thousands = NO;
	
	// Get the parameters we will need for drawing
	if (manager != nil)
	{
		thousands = [manager getThousandsSeparator];
		lengthLimit = [manager getLengthLimit];
		fillLimit = [manager getFillLimit];
		fixedPlaces = [manager getFixedPlaces];
		
		if ([manager getRadix] != [value radix])
		{
			[value convertToRadix:[manager getRadix]];
			radixChanged = YES;
		}
		if ([manager getComplement] != usesComplement)
		{
			usesComplement = [manager getComplement];
			radixChanged = YES;
		}
	}
	else
	{
		lengthLimit = 12;
		fillLimit = NO;
		fixedPlaces = 0;
		radixChanged = YES;
	}
	
	// Get the required string representations from the number
	[value
		limitedString:lengthLimit
		fixedPlaces:fixedPlaces
		fillLimit:fillLimit
		complement:usesComplement
		mantissa:&mantissa
		exponent:&exponent
		imaginaryMantissa:&imaginary
		imaginaryExponent:&imExponent
	];
	
	// If the radix has changed since we last updated we may need to adjust class variables.
	// We do this after getting the string values because we may need them to perform
	// the update
	if (radixChanged)
	{
		splitString = [mantissa componentsSeparatedByString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
		if ([splitString count] < 2)
		{
			userPointState = -1;
			postPoint = 0;
		}
		else
		{
			userPointState = 1;
			postPoint = (int)[(NSString*)splitString[1] length];
			
			if (fixedPlaces != 0)
			{
				NSString *afterPoint = (NSString*)splitString[1];
				while (postPoint > 0)
				{
					if ([afterPoint characterAtIndex:postPoint - 1] != L'0')
						break;
					
					postPoint--;
				}
				
				if (postPoint == 0)
					userPointState = -1;
			}
		}
		if ([exponent length] > 0)
		{
			hasExponent = YES;
		}
		else
		{
			hasExponent = NO;
		}
		if ([imaginary length] > 0)
		{
			hasImaginary = YES;
			splitString = [imaginary componentsSeparatedByString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
			if ([splitString count] < 2)
			{
				imaginaryPointState = -1;
				postImaginaryPoint = 0;
			}
			else
			{
				imaginaryPointState = 1;
				postImaginaryPoint = (int)[(NSString*)splitString[1] length];
			
				if (fixedPlaces != 0)
				{
					NSString *afterPoint = (NSString*)splitString[1];
					while (postImaginaryPoint > 0)
					{
						if ([afterPoint characterAtIndex:postImaginaryPoint - 1] != L'0')
							break;
						
						postImaginaryPoint--;
					}
					
					if (postImaginaryPoint == 0)
						imaginaryPointState = -1;
				}
			}
			if ([imExponent length] > 0)
			{
				hasImaginaryExponent = YES;
			}
			else
			{
				hasImaginaryExponent = NO;
			}
		}
		else
		{
			hasImaginary = NO;
			hasImaginaryExponent = NO;
			imaginaryPointState = -1;
			postImaginaryPoint = 0;
		}
	}
	
	// Do we need to show the real part of the number?
	if (![mantissa isEqualToString:@"0"] || hasExponent || !hasImaginary)
		showReal = YES;
	
	// Show the real part of the string
	if (showReal)
	{
		// Append/Prepend certain bits to the real mantissa string
		if (userPointState == 0 && fillLimit == NO)
		{
			mantissa = [mantissa stringByAppendingString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
		}
		else if (userPointState != -1 && fillLimit == NO && postPoint > 0)
		{
			splitString = [mantissa componentsSeparatedByString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
			if ([splitString count] > 1)
			{
				extraZeros = postPoint - (int)[(NSString*)splitString[1] length];
			}
			else
			{
				mantissa = [mantissa stringByAppendingString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
				extraZeros = postPoint;
			}
			while (extraZeros > 0)
			{
				mantissa = [mantissa stringByAppendingString:@"0"];
				extraZeros--;
			}
		}
		if (usesComplement > 0)
		{
			while ([mantissa length] < lengthLimit + ((userPointState != -1) ? 1 : 0))
			{
				mantissa = [@"0" stringByAppendingString:mantissa];
			}
		}
		
		if (thousands)
			mantissa = [self insertThousands:mantissa];

		resultString = [resultString stringByAppendingString:mantissa];
	
		if ((hasExponent && fillLimit == NO) || [exponent length] > 0)
		{
			resultString = [resultString stringByAppendingString:@"x10^"];
			resultString = [resultString stringByAppendingString:exponent];
		}
	}
	if (hasImaginary)
	{
		// Get the text representation of the exponent value
		if (imaginaryPointState == 0 && fillLimit == NO)
		{
			imaginary = [imaginary stringByAppendingString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
		}
		else if (imaginaryPointState == 1 && fillLimit == NO && postImaginaryPoint > 0)
		{
			splitString = [imaginary componentsSeparatedByString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
			if ([splitString count] > 1)
			{
				extraZeros = postImaginaryPoint - (int)[(NSString*)splitString[1] length];
			}
			else
			{
				imaginary = [imaginary stringByAppendingString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
				extraZeros = postImaginaryPoint;
			}
			while (extraZeros > 0)
			{
				imaginary = [imaginary stringByAppendingString:@"0"];
				extraZeros--;
			}
		}
		if (usesComplement > 0)
		{
			while ([imaginary length] < lengthLimit + ((imaginaryPointState != -1) ? 1 : 0))
			{
				imaginary = [@"0" stringByAppendingString:imaginary];
			}
		}
		
		// In the case where the value is simply "1", leave it as implicit
		if ([imaginary isEqualToString:@"1"]) imaginary = @"";
		if ([imaginary isEqualToString:@"-1"]) imaginary = @"-";
		
		// Show a leading plus sign if there is a real part
		if (showReal && ([imaginary length] == 0 || [imaginary characterAtIndex:0] != '-'))
		{
			imaginary = [@"+" stringByAppendingString:imaginary];
		}

		if (thousands) imaginary = [self insertThousands:imaginary];

		resultString = [resultString stringByAppendingString:mantissa];

		if ((hasImaginaryExponent && fillLimit == NO) || [imExponent length] > 0)
		{
			resultString = [resultString stringByAppendingString:@"x10^"];
			resultString = [resultString stringByAppendingString:imExponent];
		}

		resultString = [resultString stringByAppendingString:@"i"];
	}
	
	return resultString;
}

- (void)appendString:(NSString *)string withSize:(CGFloat)size {
	NSTextStorage	*text = [[NSTextStorage alloc] initWithString:@""];
	NSLayoutManager	*layoutManager = [[NSLayoutManager alloc] init];
	int				numGlyphs;
	NSGlyph			*glyphs;
	int				i;
	
	[text addLayoutManager:layoutManager];
	[text setAttributedString:
	 [[NSAttributedString alloc]
	  initWithString:string
	  attributes:@{NSFontAttributeName: [ExpressionSymbols getDisplayFontWithSize:size]}
	  ]
	 ];
	numGlyphs = (int)[layoutManager numberOfGlyphs];
	if (numGlyphs > 0)
	{
		glyphs = (NSGlyph *)malloc(sizeof(NSGlyph) * numGlyphs);
		for (i = 0; i < numGlyphs; i++)
		{
			glyphs[i] = [layoutManager glyphAtIndex:i];
		}
		[expressionPath
		 appendBezierPathWithGlyphs:glyphs
		 count:numGlyphs
		 inFont:[text attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL]
		 ];
		free(glyphs);
	}
}

- (void)appendExponent:(NSString*)exponent {
	NSTextStorage	*text = [[NSTextStorage alloc] initWithString:@""];
	NSLayoutManager	*layoutManager = [[NSLayoutManager alloc] init];
	int				numGlyphs;
	NSGlyph			*glyphs;
	int				i;

	[text addLayoutManager:layoutManager];
	[text setAttributedString:
	 [[NSAttributedString alloc]
	  initWithString:exponent
	  attributes:@{NSFontAttributeName: [ExpressionSymbols getDisplayFontWithSize:12]}
	  ]
	 ];
	numGlyphs = (int)[layoutManager numberOfGlyphs];
	if (numGlyphs > 0)
	{
		glyphs = (NSGlyph *)malloc(sizeof(NSGlyph) * numGlyphs);
		for (i = 0; i < numGlyphs; i++)
		{
			glyphs[i] = [layoutManager glyphAtIndex:i];
		}
		[expressionPath relativeMoveToPoint:NSMakePoint(-10, 8.5)];
		[expressionPath
		 appendBezierPathWithGlyphs:glyphs
		 count:numGlyphs
		 inFont:[text attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL]
		 ];
		[expressionPath relativeMoveToPoint:NSMakePoint(0, -8.5)];
		free(glyphs);
	}
}

//
// generateValuePath
//
// Generates strings for each part of the number and generates bezier paths and then
// assembles the resultant path into a graphically laid out number. There's a lot more
// work to this than you'd expect.
//
- (void)generateValuePath
{
	NSString				*mantissa;
	NSString				*exponent;
	NSString				*imaginary;
	NSString				*imExponent;
	unsigned int			lengthLimit;
	BOOL					fillLimit;
	BOOL					radixChanged = NO;
	unsigned int			fixedPlaces;
	NSArray					*splitString;
	int						extraZeros;
	BOOL					showReal = NO;
	BOOL					thousands = NO;
	
	
	// Get the parameters we will need for drawing
	if (manager != nil)
	{
		lengthLimit = [manager getLengthLimit];
		fillLimit = [manager getFillLimit];
		fixedPlaces = [manager getFixedPlaces];
		thousands = [manager getThousandsSeparator];
		
		if ([manager getRadix] != [value radix])
		{
			[value convertToRadix:[manager getRadix]];
			radixChanged = YES;
		}
		if ([manager getComplement] != usesComplement)
		{
			usesComplement = [manager getComplement];
			radixChanged = YES;
		}
	}
	else
	{
		lengthLimit = 12;
		fillLimit = NO;
		fixedPlaces = 0;
		radixChanged = YES;
	}
	
	// Get the required string representations from the number
	[value
		limitedString:lengthLimit
		fixedPlaces:fixedPlaces
		fillLimit:fillLimit
		complement:usesComplement
		mantissa:&mantissa
		exponent:&exponent
		imaginaryMantissa:&imaginary
		imaginaryExponent:&imExponent
	];
	
	// If the radix has changed since we last updated we may need to adjust class variables.
	// We do this after getting the string values because we may need them to perform
	// the update
	if (radixChanged)
	{
		splitString = [mantissa componentsSeparatedByString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
		if ([splitString count] < 2)
		{
			userPointState = -1;
			postPoint = 0;
		}
		else
		{
			userPointState = 1;
			postPoint = (int)[(NSString*)splitString[1] length];
			
			if (fixedPlaces != 0)
			{
				NSString *afterPoint = (NSString*)splitString[1];
				while (postPoint > 0)
				{
					if ([afterPoint characterAtIndex:postPoint - 1] != L'0')
						break;
					
					postPoint--;
				}
				
				if (postPoint == 0)
					userPointState = -1;
			}
		}
	
		hasExponent = [exponent length] > 0;

		if ([imaginary length] > 0)
		{
			hasImaginary = YES;
			splitString = [imaginary componentsSeparatedByString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
			if ([splitString count] < 2)
			{
				imaginaryPointState = -1;
				postImaginaryPoint = 0;
			}
			else
			{
				imaginaryPointState = 1;
				postImaginaryPoint = (int)[(NSString*)splitString[1] length];
			
				if (fixedPlaces != 0)
				{
					NSString *afterPoint = (NSString*)splitString[1];
					while (postImaginaryPoint > 0)
					{
						if ([afterPoint characterAtIndex:postImaginaryPoint - 1] != L'0')
							break;
						
						postImaginaryPoint--;
					}
					
					if (postImaginaryPoint == 0)
						imaginaryPointState = -1;
				}
			}
			
			hasImaginaryExponent = [imExponent length] > 0;

		}
		else
		{
			hasImaginary = NO;
			hasImaginaryExponent = NO;
			imaginaryPointState = -1;
			postImaginaryPoint = 0;
		}
	}
	
	// Do we need to show the real part of the number?
	if (![mantissa isEqualToString:@"0"] || hasExponent || !hasImaginary)
		showReal = YES;

	// Create a bezier path to contain the display
	expressionPath = [NSBezierPath bezierPath];
	[expressionPath moveToPoint:NSMakePoint(0, 0)];
	
	// Show the real part of the string
	if (showReal)
	{
		// Append/Prepend certain bits to the real mantissa string
		if (userPointState == 0 && fillLimit == NO)
		{
			mantissa = [mantissa stringByAppendingString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
		}
		else if (userPointState != -1 && fillLimit == NO && postPoint > 0)
		{
			splitString = [mantissa componentsSeparatedByString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
			if ([splitString count] > 1)
			{
				extraZeros = postPoint - (int)[(NSString*)splitString[1] length];
			}
			else
			{
				mantissa = [mantissa stringByAppendingString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
				extraZeros = postPoint;
			}
			while (extraZeros > 0)
			{
				mantissa = [mantissa stringByAppendingString:@"0"];
				extraZeros--;
			}
		}
		if (usesComplement > 0)
		{
			while ([mantissa length] < lengthLimit + ((userPointState != -1) ? 1 : 0))
			{
				mantissa = [@"0" stringByAppendingString:mantissa];
			}
		}
		
		if (thousands)
			mantissa = [self insertThousands:mantissa];
		
		[self appendString:mantissa withSize:24];
		
		if ((hasExponent && fillLimit == NO) || [exponent length] > 0)
		{
			// Write the x10 in nice little text
			[self appendString:@"×10" withSize:8.5];
	
			// Get the text representation of the exponent value
			[self appendExponent:exponent];
		}
	}
	if (hasImaginary)
	{
		// Get the text representation of the exponent value
		if (imaginaryPointState == 0 && fillLimit == NO)
		{
			imaginary = [imaginary stringByAppendingString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
		}
		else if (imaginaryPointState == 1 && fillLimit == NO && postImaginaryPoint > 0)
		{
			splitString = [imaginary componentsSeparatedByString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
			if ([splitString count] > 1)
			{
				extraZeros = postImaginaryPoint - (int)[(NSString*)splitString[1] length];
			}
			else
			{
				imaginary = [imaginary stringByAppendingString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
				extraZeros = postImaginaryPoint;
			}
			while (extraZeros > 0)
			{
				imaginary = [imaginary stringByAppendingString:@"0"];
				extraZeros--;
			}
		}
		if (usesComplement > 0)
		{
			while ([imaginary length] < lengthLimit + ((imaginaryPointState != -1) ? 1 : 0))
			{
				imaginary = [@"0" stringByAppendingString:imaginary];
			}
		}
		
		// In the case where the value is simply "1", leave it as implicit
		if ([imaginary isEqualToString:@"1"]) imaginary = @"";
		if ([imaginary isEqualToString:@"-1"])  imaginary = @"-";
		
		// Show a leading plus sign if there is a real part
		if (showReal && ([imaginary length] == 0 || [imaginary characterAtIndex:0] != '-'))
		{
			imaginary = [@"+" stringByAppendingString:imaginary];
		}
		
		if (thousands) imaginary = [self insertThousands:imaginary];

		[self appendString:imaginary withSize:24];
		
		if ((hasImaginaryExponent && fillLimit == NO) || [imExponent length] > 0)
		{
			// Write the x10 in nice little text
			[self appendString:@"×10" withSize:8.5];

			// Get the text representation of the exponent value
			[self appendExponent:imExponent];
		}

		// And finally... actually draw the "i"
		[self appendString:@"i" withSize:24];
	}
}

//
// pathAtLevel
//
// Returns the bezierPath representation of this value. generateValuePath does most
// of the work. This method really just scales the result and sets the bounds.
//
- (NSBezierPath*)pathAtLevel:(int)level
{
	NSAffineTransform	*transform;
	NSBezierPath			*copy;
	double				scale = [Expression scaleWithLevel:level];
	
	// Generate the path if required
	if (pathValidAt != level)
	{
		[self generateValuePath];
	
		if (level >= 2)
		{
			transform = [NSAffineTransform transform];
			[transform scaleBy:scale];
			[expressionPath transformUsingAffineTransform:transform];
		}
	
		// Record that the path has been properly updated since the last invalidation
		if (![expressionPath isEmpty])
			naturalBounds = [expressionPath bounds];
		else
			naturalBounds = NSMakeRect(0.0, 0.0, 0.0, 0.0);
		childNaturalBounds = NSMakeRect(0.0, 0.0, 0.0, 0.0);
		pathValidAt = level;
	}

	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:expressionPath];
	
	return copy;
}

//
// userPointPressed
//
// Puts a user point in the real or imaginary part of the number as appropriate.
//
- (void)userPointPressed
{
	int fixedPlaces = [manager getFixedPlaces];
	
	if ((hasExponent && !hasImaginary) || hasImaginaryExponent)
		return;
	
	if
	(
		(fixedPlaces == 0 && [value mantissaLength] < [manager getLengthLimit])
		||
		(
			fixedPlaces != 0
			&&
			(
				(!hasImaginary && (postPoint < fixedPlaces))
				||
				(hasImaginary && (postImaginaryPoint < fixedPlaces))
			)
		)
	)
	{
		if (!hasImaginary)
		{
			if (userPointState == -1)
			{
				userPointState = 0;
				[self valueChanged];
			}
			else if (userPointState == 0)
			{
				userPointState = -1;
				[self valueChanged];
			}
		}
		else
		{
			if (imaginaryPointState == -1)
			{
				imaginaryPointState = 0;
				[self valueChanged];
			}
			else if (imaginaryPointState == 0)
			{
				imaginaryPointState = -1;
				[self valueChanged];
			}
		}
	}
}

- (NSString *)insertThousands:(NSString *)mantissa
{
	int point;
	int distance;
	int leftEdge;
	NSString *separator;
	NSMutableString *mutable;
	int firstChar;
	
	if ([mantissa length] == 0)
		return mantissa;
	
	firstChar = [mantissa characterAtIndex:0];
	
	// Return immediately if not a valid mantissa (ie "Not a number")
	if
	(
		(firstChar < '-' || firstChar > '9')
		&&
		firstChar != '-'
		&&
		firstChar != '+'
	)
		return mantissa;
	
	switch([value radix])
	{
		case 2: distance = 8; separator = @" "; break;
		case 8: distance = 3; separator = @" "; break;
		case 16: distance = 4; separator = @" "; break;
		default: // includes 10
			distance = 3;
			separator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
			break;
	}
	NSRange range = [mantissa rangeOfString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
	point = (int)range.location;
	if (range.location == NSNotFound) point = (int)[mantissa length];
	if (point >= 1 + distance)
	{
		point -= distance;
		leftEdge = ([mantissa characterAtIndex:0] == '-' || [mantissa characterAtIndex:0] == '+') ? 1 : 0;
		mutable = [NSMutableString stringWithString:mantissa];
		while (point > leftEdge)
		{
			[mutable insertString:separator atIndex:point];
			point -= distance;
		}
		
		mantissa = [NSString stringWithString:mutable];
	}
	
	return mantissa;
}


@end
