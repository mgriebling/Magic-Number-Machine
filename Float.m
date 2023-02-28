// ##############################################################
//  BigFloat.h
//  BigFloat Implementation
//
//  Created by Matt Gallagher on Sun Jan 06 2002.
//  Copyright © 2002-2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Foundation/Foundation.h>

//
// About BigFloat
//
// BigFloat is an arbitrary precision (fixed at compile-time) arbitrary radix floating
// point number format. The entire functionality of the class is implemented in a
// single file for simple inclusion in other projects.
//
// Precision is defined by BF_num_values. It defines how many unsigned longs are
// used to hold the number. Though in reality, only half of each long is used. This
// is so that when you multiply then together, there is room for the result  (16 bits
// multiplied by 16 bits requires all 32 bits). If you really wanted to, you could
// change this class so that BF_num_values was chosen at class initialisation time
// (I didn't want to).
//
// Bad design choice: when I created this class, I created it "mutable". What I mean
// is that [object1 add:object:2] changes the value of object1. I thought it was a 
// good idea at the time. Having used it, I now realise I was wrong. Sorry. It is really
// annoying when you return a BigFloat and the calling function mucks it up on you.
// Maybe you can learn from my mistake.
//
// Naturally, functionality has been catered to the needs of Magic Number Machine
// a little (especially the limitedString function).
//

// Basic constants defining the precision used by the class
#define	BF_num_values					8
#define	BF_max_mantissa_length		(BF_num_values * 16 + 3)
#define	BF_max_exponent_length		32

#if (BF_num_values < 2)
	#error BF_num_values must be at least 2
#endif

// Mode for trigonometric operations
typedef enum
{
	BF_degrees,
	BF_radians,
	BF_gradians
} BFTrigMode;

@interface BigFloat : NSObject <NSCopying, NSCoding>
{
@protected
	unsigned long		bf_array[BF_num_values];
	signed int			bf_exponent;
	unsigned short		bf_user_point;
	BOOL				bf_is_negative;

	unsigned short		bf_radix;
	unsigned short		bf_value_precision;
	unsigned int		bf_value_limit;
	unsigned long		bf_exponent_precision;

	BOOL				bf_is_valid;
}

// Constructors
- (id)init;
- (id)initWithMantissa:	(unsigned long long)mantissa
	exponent: 			(short)exp
	isNegative:			(BOOL)flag
	radix:				(unsigned short)newRadix
	userPointAt:		(unsigned short)pointLocation;
- (id)initWithInt:(signed int)newValue radix:(unsigned short)newRadix;
- (id)initWithDouble:(double)newValue radix:(unsigned short)newRadix;
- (id)initPiWithRadix:(unsigned short)newRadix;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone*)zone;

+ (BigFloat*)bigFloatWithInt:(signed int)newValue radix:(unsigned short)newRadix;
+ (BigFloat*)bigFloatWithDouble:(double)newValue radix:(unsigned short)newRadix;
+ (BigFloat*)piWithRadix:(unsigned short)newRadix;

// Public Utility Functions
- (BOOL)appendDigit: (short)digit useComplement:(int)complement;
- (void)appendExpDigit:(short)digit;
- (void)deleteDigit;
- (void)deleteExpDigit;
- (void)convertToRadix:(unsigned short)newRadix;
- (void)setUserPoint:(int)pointLocation;
- (int)getUserPoint;
- (int)mantissaLength;
- (unsigned short)radix;
- (BOOL)isValid;
- (BOOL)isNegative;
- (BOOL)hasExponent;
- (BOOL)isZero;
- (NSComparisonResult)compareWith:(BigFloat*)num;
- (BigFloat*)duplicate;
- (void)assign:(BigFloat*)newValue;
- (void)abs;

// Arithmetic Functions
- (void)add:(BigFloat*)num;
- (void)subtract:(BigFloat*)num;
- (void)multiplyBy:(BigFloat*)num;
- (void)divideBy:(BigFloat*)num;
- (void)moduloBy:(BigFloat*)num;

// Extended Mathematics Functions
- (void)powerOfE;
- (void)ln;
- (void)raiseToPower:(BigFloat*)num;
- (void)sqrt;
- (void)inverse;
- (void)logOfBase:(BigFloat *)base;
- (void)sinWithTrigMode:(BFTrigMode)mode inv:(BOOL)useInverse hyp:(BOOL)useHyp;
- (void)cosWithTrigMode:(BFTrigMode)mode inv:(BOOL)useInverse hyp:(BOOL)useHyp;
- (void)tanWithTrigMode:(BFTrigMode)mode inv:(BOOL)useInverse hyp:(BOOL)useHyp;
- (void)factorial;
- (void)sum;
- (void)nPr: (BigFloat*)r;
- (void)nCr: (BigFloat*)r;
- (void)exp3Up;
- (void)exp3Down:(int)displayDigits;
- (void)wholePart;
- (void)fractionalPart;
- (void)bitnot;
- (void)andWith:(BigFloat*)num;
- (void)orWith:(BigFloat*)num;
- (void)xorWith:(BigFloat*)num;

// Conversion Functions
- (double)doubleValue;
- (NSString*)mantissaString;
- (NSString*)exponentString;
- (NSString*)toString;
- (NSString*)toShortString:(int)precision;
- (void)limitedString:(unsigned int)lengthLimit fixedPlaces:(unsigned int)places fillLimit:(BOOL)fill complement:(unsigned int)complement mantissa:(NSString**)mantissaOut exponent:(NSString**)exponentOut;
- (void)debugDisplay;

@end
// #######################################################################
//  BigFloat.m
//  BigFloat Implementation
//
//  Created by Matt Gallagher on Sun Jan 06 2002.
//  Copyright © 2002-2003 Matt Gallagher. All rights reserved.
// #######################################################################

#import "BigFloat.h"

//
// About BigFloat
//
// BigFloat is an arbitrary precision (fixed at compile-time) arbitrary radix floating
// point number format. The entire functionality of the class is implemented in a
// single file for simple inclusion in other projects.
//
// Precision is defined by BF_num_values. It defines how many unsigned longs are
// used to hold the number. Though in reality, only half of each long is used. This
// is so that when you multiply then together, there is room for the result  (16 bits
// multiplied by 16 bits requires all 32 bits). If you really wanted to, you could
// change this class so that BF_num_values was chosen at class initialisation time
// (I didn't want to).
//
// Bad design choice: when I created this class, I created it "mutable". What I mean
// is that [object1 add:object:2] changes the value of object1. I thought it was a 
// good idea at the time. Having used it, I now realise I was wrong. Sorry. It is really
// annoying when you return a BigFloat and the calling function mucks it up on you.
// Maybe you can learn from my mistake.
//
// Naturally, functionality has been catered to the needs of Magic Number Machine
// a little (especially the limitedString function).
//

// An array for cacheing values of pi (initialised to all nil)
static BigFloat*		pi_array[36] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

// A string containing the unichar digits 0 to 9 and onwards
static NSString*		BF_digits = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

// An internally used structure to get the extra information for a number (its "elements")
typedef struct
{
	unsigned short	bf_radix;
	unsigned short	bf_value_precision;
	unsigned int	bf_value_limit;
	unsigned long	bf_exponent_precision;
	signed int		bf_exponent;
	unsigned short	bf_user_point;
	BOOL			bf_is_negative;
	BOOL			bf_is_valid;
} BigFloatElements;

#pragma mark

@implementation BigFloat

#pragma mark
#pragma mark ### Inline helper functions ###

//
// BF_ClearValuesArray
//
// Sets every value in a values array to zero
//
inline void
BF_ClearValuesArray(unsigned long *values, unsigned int multiple)
{
	int i;
	
	// Set the value to zero
	for (i = 0; i < BF_num_values * multiple; i++)
	{
		values[i] = 0;
	}
}

//
// BF_ArrayIsNonZero
//
// Scans a values array looking for any non-zero digits.
//
inline BOOL
BF_ArrayIsNonZero(unsigned long *values, unsigned int multiple)
{
	int i;
	
	// Set the value to zero
	for (i = 0; i < BF_num_values * multiple; i++)
	{
		if (values[i] != 0) return YES;
	}
	
	return NO;
}

//
// BF_CopyValues
//
// Copies the source values to the destination values.
//
inline void
BF_CopyValues(unsigned long *source, unsigned long *copyArray)
{
	int	i;
	
	// Do a basic copy of the values into the copyArray
	for (i = 0; i < BF_num_values; i++)
	{
		copyArray[i] = source[i];
	}
}

//
// BF_ArrayIsNonZero
//
// Copies the second array into the first. I cannot work out why I have
// both this and the previous function. Oh well.
//
inline void
BF_AssignValues(unsigned long *destination, unsigned long *copyArray)
{
	int	i;
	
	// overwrite the values with those from the copyArray
	for (i = 0; i < BF_num_values; i++)
	{
		destination[i] = copyArray[i];
	}
}

//
// BF_AddToMantissa
//
// Adds a single unsigned long to an array of values.
//
inline void
BF_AddToMantissa(unsigned long *values, unsigned long digit, unsigned long limit, unsigned int multiple)
{
	int i;

	// Multiply through by the bf_radix and add the digit
	for (i = 0; i < BF_num_values * multiple; i++)
	{
		values[i] += digit;
		digit = values[i] / limit;
		values[i] %= limit;
	}
	
	values[BF_num_values - 1] += digit * limit;
}

//
// BF_AppendDigitToMantissa
//
// Appends a single radix digit to the least significant end of the values array. Space
// is made for the digit by multiplying through by the radix first.
//
inline void
BF_AppendDigitToMantissa(unsigned long *values, unsigned long digit, unsigned short radix, unsigned long limit, unsigned int multiple)
{
	int i;

	// Multiply through by the bf_radix and add the digit
	for (i = 0; i < BF_num_values * multiple; i++)
	{
		values[i]	= (values[i] * radix) + digit;
		digit		= values[i] / limit;
		values[i]	= values[i] % limit;
	}
	values[BF_num_values - 1] += digit * limit;
}

//
// BF_RemoveDigitFromMantissa
//
// Chops a single digit off the end of the values array by dividing through by the radix.
//
inline signed long
BF_RemoveDigitFromMantissa(unsigned long *values, unsigned short radix, unsigned long limit, unsigned int multiple)
{
	// Truncate a digit by dividing through by the bf_radix
	unsigned long	carryBits = 0;
	int			i;
	
	for (i = (BF_num_values * multiple) - 1; i >= 0; i--)
	{
		values[i] = values[i] + (carryBits * limit);
		carryBits = values[i] % radix;
		values[i] = values[i] / radix;
	}
	
	return carryBits;
}

//
// BF_RemoveDigitFromMantissaAndFlagEmpty
//
// Chops a single digit off the end of the values array by dividing through by the radix.
// If the result is negative it says so.
//
inline signed long
BF_RemoveDigitFromMantissaAndFlagEmpty(unsigned long *values, unsigned short radix, unsigned long limit, unsigned int multiple, BOOL *isEmpty)
{
	// Truncate a digit by dividing through by the bf_radix
	unsigned long	carryBits = 0;
	int					i;
	BOOL				empty = YES;
	
	for (i = (BF_num_values * multiple) - 1; i >= 0; i--)
	{
		values[i] = values[i] + (carryBits * limit);
		carryBits = values[i] % radix;
		values[i] = values[i] / radix;
		if (values[i] != 0) empty = NO;
	}
	
	*isEmpty = empty;
	
	return carryBits;
}

//
// BF_NumDigitsInArray
//
// Counts the number of digits after and including the most significant non-zero digit.
//
inline long
BF_NumDigitsInArray(unsigned long *values, unsigned short radix, unsigned long precision)
{
	int digitsInNumber;
	int valueNumber;
	int digitNumber;
	
	// Trace through the number looking the the most significant non-zero digit
	digitsInNumber = BF_num_values * precision;
	valueNumber = BF_num_values;
	do
	{
		valueNumber--;
		digitNumber = precision - 1;
		while
		(
			(((int)(values[valueNumber] / pow(radix, digitNumber)) % radix) == 0)
			&&
			digitNumber >= 0
		)
		{
			digitNumber--;
			digitsInNumber--;
		}
	}
	while
	(
		(((int)(values[valueNumber] / pow(radix, digitNumber)) % radix) == 0)
		&&
		valueNumber > 0
	);
	
	return digitsInNumber;
}

//
// BF_NormaliseNumbers
//
// Normalises the mantissas of two floating point numbers so that they can be added
// subtracted or compared.
//
inline void
BF_NormaliseNumbers
(
	unsigned long *values,
	unsigned long *otherTerm,
	BigFloatElements *thisNumElements,
	BigFloatElements *otherNumElements
)
{
	NSCAssert
	(
		otherNumElements->bf_radix == thisNumElements->bf_radix,
		@"Numbers must have same radix before normalisation"
	);
	
	long	thisRoundingNum = 0;
	long	otherRoundingNum = 0;
	BOOL	thisEmpty = NO;
	BOOL	otherEmpty = NO;

	thisNumElements->bf_exponent -= thisNumElements->bf_user_point;
	thisNumElements->bf_user_point = 0;
	otherNumElements->bf_exponent -= otherNumElements->bf_user_point;
	otherNumElements->bf_user_point = 0;
	
	// Normalise due to otherNum.bf_exponent being greater than bf_exponent
	if (otherNumElements->bf_exponent > thisNumElements->bf_exponent)
	{
		// start by normalising otherNum left
		while
		(
			otherNumElements->bf_exponent > thisNumElements->bf_exponent
			&&
			otherTerm[BF_num_values - 1] < (otherNumElements->bf_value_limit / otherNumElements->bf_radix)
		)
		{
			BF_AppendDigitToMantissa(otherTerm, 0, otherNumElements->bf_radix, otherNumElements->bf_value_limit, 1);
			otherNumElements->bf_exponent--;
		}
		
		// then normalise this num to the right
		while(otherNumElements->bf_exponent > thisNumElements->bf_exponent && !thisEmpty)
		{
			thisRoundingNum = BF_RemoveDigitFromMantissaAndFlagEmpty(values, thisNumElements->bf_radix, thisNumElements->bf_value_limit, 1, &thisEmpty);
			thisNumElements->bf_exponent++;
		}
	}
	// Normalise due to this bf_exponent being greater than otherNum->bf_exponent
	else if (thisNumElements->bf_exponent > otherNumElements->bf_exponent)
	{
		// start by normalising this num left
		while
		(
			thisNumElements->bf_exponent > otherNumElements->bf_exponent
			&&
			values[BF_num_values - 1] < (thisNumElements->bf_value_limit / thisNumElements->bf_radix)
		)
		{
			BF_AppendDigitToMantissa(values, 0, thisNumElements->bf_radix, thisNumElements->bf_value_limit, 1);
			thisNumElements->bf_exponent--;
		}
		// then normalise otherNum to the right
		while(thisNumElements->bf_exponent > otherNumElements->bf_exponent && !otherEmpty)
		{
			otherRoundingNum = BF_RemoveDigitFromMantissaAndFlagEmpty(otherTerm, otherNumElements->bf_radix, otherNumElements->bf_value_limit, 1, &otherEmpty);
			otherNumElements->bf_exponent++;
		}
	}
	
	// Apply a round to nearest on any truncated values
	if (!otherEmpty && (double)otherRoundingNum >= ((double)thisNumElements->bf_radix / 2.0))
	{
		BF_AddToMantissa(otherTerm, 1, otherNumElements->bf_value_limit, 1);
	}
	else if (!thisEmpty && (double)thisRoundingNum >= ((double)thisNumElements->bf_radix / 2.0))
	{
		BF_AddToMantissa(values, 1, thisNumElements->bf_value_limit, 1);
	}
	
	if (thisEmpty && !otherEmpty)
	{
		thisNumElements->bf_exponent = otherNumElements->bf_exponent;
	}
	else if (!thisEmpty && otherEmpty)
	{
		otherNumElements->bf_exponent = thisNumElements->bf_exponent;
	}
	else if (thisEmpty && otherEmpty)
	{
		otherNumElements->bf_exponent = 0;
		thisNumElements->bf_exponent = 0;
	}
}

#pragma mark
#pragma mark ##### Private utility functions #####

//
// calculatePi
//
// Calculate π for the current bf_radix and cache it in the array
// Uses the following iterative method to calculate π (quartically convergeant):
//
//	Initial: Set y = sqrt(sqrt(2)-1), c = 0 and p = sqrt(2) - 1
//	Loop: Set c = c+1
// 			Set a = (1-y^4)^(1/4)
//			Set y = (1-a)/(1+a)
//			Set p = p(1+y)^4-y(1+y+y^2)sqrt(2)4^(c+1)
//	π = 1/p
//
//	(for those of you playing at home... this is the Ramanujan II formula for π)
//
- (void)calculatePi
{
	BigFloat	*y;
	BigFloat	*x;
	BigFloat	*w;
	BigFloat	*v;
	BigFloat	*p;
	BigFloat	*a;
	BigFloat	*one;
	BigFloat	*two;
	BigFloat	*four;
	BigFloat	*two_sqrt;
	BigFloat	*quarter;
	BigFloat	*prevIteration;
	
	// Setup the initial conditions
	one 		= [[BigFloat alloc] initWithInt: 1 radix: bf_radix];
	two 		= [[BigFloat alloc] initWithInt: 2 radix: bf_radix];
	four 		= [[BigFloat alloc] initWithInt: 4 radix: bf_radix];
	two_sqrt	= [two copy];
	[two_sqrt sqrt];
	quarter 	= [[BigFloat alloc] initWithDouble: 0.25 radix: bf_radix];
	p 			= [two_sqrt copy];
	[p subtract: one];
	y			= [p copy];
	[y sqrt];
	
	// Just allocate everything that is initially undefined
	a 		= [one copy];
	x 		= [one copy];
	v 		= [one copy];
	w 		= [one copy];
	prevIteration	= [one copy];
	
	// Do the loopy bit
	while([p compareWith: prevIteration] != NSOrderedSame || ![p isValid])
	{
		[prevIteration assign: p];

		// c = c + 1
		
		// a = (1-y^4)^(1/4)
		[x assign: y];
		[x multiplyBy: x];
		[x multiplyBy: x];
		[a assign: one];
		[a subtract: x];
		[a raiseToPower: quarter];
		
		// y = (1-a)/(1+a)
		[y assign: one];
		[y subtract: a];
		[a add: one];
		[y divideBy: a];
		
		// p = p(1+y)^4-y(1+y+y^2)sqrt(2)4^(c+1)
		[w assign: y];
		[w multiplyBy: w];
		[x assign: y];
		[x add: one];
		[w add: x];
		[x multiplyBy: x];
		[x multiplyBy: x];
		[w multiplyBy: y];
		[v multiplyBy: four];
		[w multiplyBy: v];
		[w multiplyBy: two_sqrt];
		
		if ([x isValid] && [w isValid])
		{
			[p multiplyBy: x];
			[p subtract: w];
		}
	}
	
	// pi_array is retained permanently (until the program quits)
	pi_array[bf_radix] = [[p copy] retain];
	[pi_array[bf_radix] inverse];

	// Free all the memory
	[one release];
	[two release];
	[four release];
	[two_sqrt release];
	[quarter release];
	[p release];
	[y release];
	[a release];
	[x release];
	[v release];
	[w release];
	[prevIteration release];
}

//
// copyElements
//
// Copies the non value information in a BigFloat
//
- (void)copyElements: (BigFloatElements *)copy
{
	// Copy this num's elements into the copy structure
	copy->bf_exponent = bf_exponent;
	copy->bf_user_point = bf_user_point;
	copy->bf_is_negative = bf_is_negative;

	copy->bf_radix = bf_radix;
	copy->bf_value_precision = bf_value_precision;
	copy->bf_value_limit = bf_value_limit;
	copy->bf_exponent_precision = bf_exponent_precision;
	
	copy->bf_is_valid = bf_is_valid;
}

//
// assignElements
//
// Sets the non value information in a BigFloat.
//
- (void)assignElements: (BigFloatElements *)copy
{
	bf_exponent = copy->bf_exponent;
	bf_user_point = copy->bf_user_point;
	bf_is_negative = copy->bf_is_negative;

	bf_radix = copy->bf_radix;
	bf_value_precision = copy->bf_value_precision;
	bf_value_limit = copy->bf_value_limit;
	bf_exponent_precision = copy->bf_exponent_precision;
	
	bf_is_valid = copy->bf_is_valid;
}

//
// setElements
//
// Allows the elements of a BigFloat to be safely set.
//
- (void)setElements:(unsigned short)radix negative:(BOOL)isNegative exp:(signed short)exponent valid:(BOOL)isValid userPoint:(unsigned short)userPoint
{
	// Set everything
	bf_exponent = exponent;
	bf_is_negative = isNegative;
	bf_is_valid = isValid;

	// Set the bf_radix (if it is valid)
	if (radix < 2 || radix > 36)
		radix = 10;
	bf_radix = radix;
	
	bf_value_precision = (unsigned long)(log(0xFFFF + 1) / log(radix));
	bf_value_limit = (unsigned long)(pow(radix, bf_value_precision));
	bf_exponent_precision = (unsigned long)(log(0xFFFF + 1) / log(radix));

	// Apply the decimal point
	if (userPoint > (bf_value_precision * BF_num_values - 1))
		userPoint = (bf_value_precision * BF_num_values - 1);
	bf_user_point = userPoint;
}

//
// createUserPoint
//
// Puts a fractional point in a number according to typical expected behaviour.
//
- (void)createUserPoint
{
	if ([self isZero])
	{
		bf_exponent = 0;
		bf_user_point = 0;
		return;
	}
	
	// Extract a user decimal point (because 45.67 is prettier than 4567e-2)
	if (bf_exponent < 0)
	{
		if (-bf_exponent > (bf_value_precision * BF_num_values))
		{
			bf_exponent += (bf_value_precision * BF_num_values) - 1;
			bf_user_point = (bf_value_precision * BF_num_values) - 1;
		}
		else
		{
			bf_user_point = -bf_exponent;
			bf_exponent = 0;
		}
	}
	
	// Standard check on the exponent
	if (bf_exponent > 0xFFFF || bf_exponent < -0xFFFF)
		bf_is_valid = NO;
}

#pragma mark
#pragma mark ##### Constructors #####

//
// init
//
// Hey look, its the default constructor. Bet you've never seen one of these before.
// By default you get a base 10 zero.
//
- (id)init
{
	self = [super init];
	if (self)
	{
		BF_ClearValuesArray(bf_array, 1);
		
		[self setElements:10 negative:NO exp:0 valid:YES userPoint:0];
	}
	return self;
}

//
// initWithMantissa
//
// Allows fairly explicit contruction of a BigFloat.
//
- (id)initWithMantissa: (unsigned long long)mantissa exponent: (short)exp isNegative: (BOOL)flag radix: (unsigned short)newRadix userPointAt: (unsigned short)pointLocation
{
	self = [super init];
	if (self)
	{
		[self setElements:newRadix negative:flag exp:exp valid:YES userPoint:pointLocation];

		// Set the values
		bf_array[0] = (mantissa) % bf_value_limit;
		bf_array[1] = (mantissa /= (unsigned long long)bf_value_limit) % bf_value_limit;
		#if BF_num_values > 2
			bf_array[2] = (mantissa /= (unsigned long long)bf_value_limit) % bf_value_limit;
			#if BF_num_values > 3
				bf_array[3] = (mantissa /= (unsigned long long)bf_value_limit) % bf_value_limit;
				#if BF_num_values > 4
					bf_array[4] = (mantissa /= (unsigned long long)bf_value_limit) % bf_value_limit;
					#if BF_num_values > 5
						bf_array[5] = (mantissa /= (unsigned long long)bf_value_limit) % bf_value_limit;
					#endif
				#endif
			#endif
		#endif
	}
	return self;
}

//
// initWithInt
//
// The most common constructor. Simple and delicious.
//
- (id)initWithInt: (signed int)newValue radix: (unsigned short)newRadix
{
	BOOL	negative = (newValue < 0);
	
	if (negative) newValue *= -1;
	
	self = [self initWithMantissa: newValue exponent: 0 isNegative: negative radix: newRadix userPointAt: 0];
	
	return self;
}

//
// initWithDouble
//
// Also good but not as fast as initWithInt.
//
- (id)initWithDouble:(double)newValue radix:(unsigned short)newRadix
{
	unsigned long long	mantissa = 0;
	int						newExponent;
	int						i;
	int						numDigits = 0;
	int						nextDigit;
	double					intPart;
	double					fracPart;
	double					doubleExponent;
	BOOL					negative = NO;
	int						radixValuePrecision;
	
	// Shortcut
	if (newValue == 0.0)
		return self = [self initWithInt:0 radix:newRadix];
	
	// Determine what the bf_value_precision would be for this bf_radix
	radixValuePrecision  = (unsigned int)(log(0xFFFF + 1) / log(newRadix));
	
	// Determine the sign
	if (newValue < 0)
	{
		negative = YES;
		newValue *= -1;
	}
	
	// Get the base bf_radix exponent
	doubleExponent = log(newValue) / log(newRadix);
	
	if (doubleExponent < 0)
		newExponent = (long)floor(doubleExponent);
	else
		newExponent = (long)ceil(doubleExponent);
	
	// Remove the exponent from the newValue
	newValue /= pow(newRadix, newExponent);
	if (*((unsigned long long *)(&newValue)) == 0x8000000000000000ULL)
	{
		// Generate an NaN and return it
		self = [self initWithInt: 0 radix: newRadix];
		bf_is_valid = NO;
		return self;
	}
	
	// Get the digits out one at a time, up to the max precision for a double's mantissa
	for (i = 0; i < (int)(radixValuePrecision * sizeof(double)/sizeof(unsigned short) * 0.8); i++)
	{
		// The next digit should be the only thing left of the decimal point
		fracPart = modf(newValue, &intPart);
		nextDigit = (int)intPart;
		
		// Only add the digit if it is non-zero
		if (nextDigit != 0)
		{
			// Guard against overflow
			if ((0xFFFFFFFFFFFFFFFFULL / newRadix) >= mantissa)
				mantissa = mantissa * (unsigned long long)(pow(newRadix, i - numDigits + 1)) + nextDigit;
				
			numDigits = i + 1;
		}
		
		// Shift the next digit into place
		newValue = fracPart * newRadix;
	}
	fracPart = modf(newValue, &intPart);
	if (newValue > (newRadix / 2) && 0xFFFFFFFFFFFFFFFFULL > mantissa)
	{
		mantissa++;
		while (mantissa % newRadix == 0 && numDigits > 1)
		{
			mantissa /= newRadix;
			numDigits--;
		}
	}
	
	// Now adjust the exponent into its correct spot
	newExponent -= (numDigits - 1);
	
	// Create the big float and return it
	self = [self initWithMantissa:mantissa exponent:newExponent isNegative:negative radix:newRadix userPointAt:0];

	// Create a user point.
	[self createUserPoint];
	if (bf_user_point >= numDigits)
	{
		bf_exponent -= bf_user_point - numDigits + 1;
		bf_user_point -= bf_user_point - numDigits + 1;
	}
	
	return self;
}

//
// initPiWithRadix
//
// Creates a number and initialises it to π. At one point I was going to have more of these.
// Like a zero, a one and other such numbers. Oh well.
//
- (id)initPiWithRadix:(unsigned short)newRadix
{
	self = [self initWithInt:0 radix:newRadix];
	
	if (self != nil)
	{
		// Make certain that we have a pi for this radix
		if (pi_array[newRadix] == nil)
			[self calculatePi];
		
		// Don't actually return our private PI (in case the caller messes it up)
		[self assign:pi_array[newRadix]];
	}
	
	return self;
}

//
// initWithCoder
//
// Part of the NSCoder protocol. Required for copy, paste and other such stuff.
//
- (id)initWithCoder:(NSCoder *)coder
{
	unsigned long	*values;
	int					length;
	
	self = [super init];
	
	values = (unsigned long *)[coder decodeBytesForKey:@"BFArray" returnedLength:&length];
	NSAssert(length == sizeof(unsigned long)*BF_num_values, @"Value array is wrong length");
	BF_AssignValues(bf_array, values);
	
	bf_exponent = [coder decodeIntForKey:@"BFExponent"];
	bf_user_point = [coder decodeIntForKey:@"BFUserPoint"];
	bf_is_negative = [coder decodeBoolForKey:@"BFIsNegative"];
	bf_radix = [coder decodeIntForKey:@"BFRadix"];
	bf_value_precision = [coder decodeIntForKey:@"BFValuePrecision"];
	bf_value_limit = [coder decodeIntForKey:@"BFValueLimit"];
	bf_exponent_precision = [coder decodeIntForKey:@"BFExponentPrecision"];
	bf_is_valid = [coder decodeBoolForKey:@"BFIsValid"];
	
	return self;
}

//
// encodeWithCoder
//
// Part of the NSCoder protocol. Required for copy, paste and other such stuff.
//
- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeBytes:(const uint8_t *)bf_array length:sizeof(unsigned long)*BF_num_values forKey:@"BFArray"];
	[coder encodeInt:bf_exponent forKey:@"BFExponent"];
	[coder encodeInt:bf_user_point forKey:@"BFUserPoint"];
	[coder encodeBool:bf_is_negative forKey:@"BFIsNegative"];
	[coder encodeInt:bf_radix forKey:@"BFRadix"];
	[coder encodeInt:bf_value_precision forKey:@"BFValuePrecision"];
	[coder encodeInt:bf_value_limit forKey:@"BFValueLimit"];
	[coder encodeInt:bf_exponent_precision forKey:@"BFExponentPrecision"];
	[coder encodeBool:bf_is_valid forKey:@"BFIsValid"];
}

//
// copyWithZone
//
// Overrides the standard copy method so that it copies things properly.
//
- (id)copyWithZone:(NSZone*)zone
{
	BigFloat *copy;
	
	copy = [BigFloat allocWithZone:zone];
	BF_CopyValues(self->bf_array, copy->bf_array);
	copy->bf_exponent = self->bf_exponent;
	copy->bf_user_point = self->bf_user_point;
	copy->bf_is_negative = self->bf_is_negative;
	copy->bf_radix = self->bf_radix;
	copy->bf_value_precision = self->bf_value_precision;
	copy->bf_value_limit = self->bf_value_limit;
	copy->bf_exponent_precision = self->bf_exponent_precision;
	copy->bf_is_valid = self->bf_is_valid;
	
	return copy;
}

//
// bigFloatWithInt
//
// A static method to do this quickly and return an autoreleased BigFloat of an int.
//
+ (BigFloat*)bigFloatWithInt: (signed int)newValue radix: (unsigned short)newRadix
{
	return [[[BigFloat alloc] initWithInt:newValue radix:newRadix] autorelease];
}

//
// bigFloatWithDouble
//
// A static method to do this quickly and return an autoreleased BigFloat of a double.
//
+ (BigFloat*)bigFloatWithDouble: (double)newValue radix: (unsigned short)newRadix
{
	return [[[BigFloat alloc] initWithDouble:newValue radix:newRadix] autorelease];
}

//
// piWithRadix
//
// A static method to do this quickly and return an autoreleased BigFloat of π.
//
+ (BigFloat*)piWithRadix:(unsigned short)newRadix
{
	return [[[BigFloat alloc] initPiWithRadix:newRadix] autorelease];
}

#pragma mark
#pragma mark ##### Public Utility Functions #####
//
// appendDigit
//
// Appends a new digit to this BigFloat. As though the next digit had been typed
// into the calculator. 2's complement numbers have some weird stuff that needs
// to be worked through once the digit is appended.
//
- (BOOL)appendDigit:(short)digit useComplement:(int)complement
{
	unsigned long		values[BF_num_values];
	
	if (digit == L'-')
	{
		bf_is_negative = (bf_is_negative == NO) ? YES : NO;
	}
	else if (digit >= 0 && digit <= 36) // append a regular digit
	{
		// Do nothing if overflow could occur
		if (bf_array[BF_num_values - 1] >= (bf_value_limit / bf_radix))
			return NO;
		
		BF_CopyValues(bf_array, values);
		
		// Multiply through by the bf_radix and add the digit
		BF_AppendDigitToMantissa(values, digit, bf_radix, bf_value_limit, 1);

		if (complement)
		{
			BigFloat				*complementNumberFull;
			BigFloat				*complementNumberHalf;
			BigFloat				*mantissaNumber;
			unsigned long long	complementHalf = ((unsigned long long)1 << (complement - 1));
			unsigned long long	complementFull = ((unsigned long long)1 << (complement));
			NSComparisonResult	relative;	
			
			complementNumberHalf = [[BigFloat alloc] initWithMantissa:complementHalf exponent:0 isNegative:0 radix:bf_radix userPointAt:0];
			complementNumberFull = [[BigFloat alloc] initWithMantissa:complementFull exponent:0 isNegative:0 radix:bf_radix userPointAt:0];
			mantissaNumber = [complementNumberHalf copy];
			BF_AssignValues(mantissaNumber->bf_array, values);
			
			if (!bf_is_negative)
			{
				relative = [mantissaNumber compareWith:complementNumberHalf];
				
				if (relative == NSOrderedDescending || relative == NSOrderedSame)
				{
					if  ([mantissaNumber compareWith:complementNumberFull] == NSOrderedAscending)
					{
						[complementNumberFull subtract:mantissaNumber];
						BF_AssignValues(bf_array, complementNumberFull->bf_array);
						if (bf_user_point != 0)
							bf_user_point++;
						bf_is_negative = YES;
						
						[complementNumberHalf release];
						[complementNumberFull release];
						[mantissaNumber release];
						return YES;
					}
					
					// Overflow, don't apply digit
					[complementNumberHalf release];
					[complementNumberFull release];
					[mantissaNumber release];
					return NO;
				}
			}
			else
			{
				// Overflow, don't apply digit
				[complementNumberHalf release];
				[complementNumberFull release];
				[mantissaNumber release];
				return NO;
			}

			[complementNumberHalf release];
			[complementNumberFull release];
			[mantissaNumber release];
		}
		
		BF_AssignValues(bf_array, values);
		
		// Move the decimal point along with the digits
		if (bf_user_point != 0)
			bf_user_point++;
	}
	
	return YES;
}

//
// appendExpDigit
//
// Puts another digit on the exponent
//
- (void)appendExpDigit: (short)digit
{
	// Change the sign when '+/-' is pressed
	if (digit == L'-')
	{
		bf_exponent *= -1;
		return;
	}
	
	// Do the appending stuff
	if (digit >= 0 && digit <= 9)
	{
		// Do nothing if overflow could occur
		if
		(
			bf_exponent < (-(long)pow(bf_radix, bf_exponent_precision) / bf_radix)
			||
			bf_exponent > ((long)pow(bf_radix, bf_exponent_precision) / bf_radix)
		)
		{
			return;
		}
	
		bf_exponent = bf_exponent * bf_radix + digit;
	}
}

//
// deleteDigit
//
// Removes the least significant digit from the number.
//
- (void)deleteDigit
{
	unsigned long	values[BF_num_values];
	
	BF_CopyValues(bf_array, values);
	
	// Truncate a digit by dividing through by the bf_radix
	BF_RemoveDigitFromMantissa(values, bf_radix, bf_value_limit, 1);

	// Move the decimal point along with the digits
	if (bf_user_point != 0)
		bf_user_point--;
	
	BF_AssignValues(bf_array, values);
}

//
// deleteExpDigit
//
// Removes the least significant digit from the exponent.
//
- (void)deleteExpDigit
{
	// Simple truncation by one bf_radix digit
	bf_exponent /= bf_radix;
}

- (void)convertToRadix: (unsigned short)newRadix
{
	unsigned long		values[BF_num_values];
	unsigned long		reverse[BF_num_values * 2];
	unsigned long		result[BF_num_values * 2];
	BigFloatElements	elements;
	int						i;
	unsigned long		carryBits;
	BigFloat				*exponentNum;
	BigFloat				*powerNum;
	
	// Check for a valid new radix
	if (bf_radix == newRadix || newRadix < 2 || newRadix > 36)
	{
		return;
	}

	// ignore invalid numbers
	if (bf_is_valid == NO)
	{
		bf_radix = newRadix;
		return;
	}
	
	// Apply the user's decimal point
	bf_exponent -= bf_user_point;
	bf_user_point = 0;

	// Get a copy of the relevant stuff
	BF_CopyValues(bf_array, values);
	[self copyElements: &elements];

	// Adjust the precision related elements
	elements.bf_radix = newRadix;
	elements.bf_exponent = 0;
	elements.bf_exponent_precision =  (unsigned long)(log(0xFFFF + 1) / log(elements.bf_radix));
	elements.bf_value_precision = (unsigned long)(log(0xFFFF + 1) / log(elements.bf_radix));
	elements.bf_value_limit = (unsigned long)(pow(newRadix, elements.bf_value_precision));

	// Clear the working space
	BF_ClearValuesArray(reverse, 2);
	BF_ClearValuesArray(result, 2);
	
	// Re-encode the mantissa
	for (i = 0; i < (elements.bf_value_precision * BF_num_values * 2); i++)
	{
		// Remove new digits from the old number by integer dividing by the new radix
		carryBits = BF_RemoveDigitFromMantissa(values, newRadix, bf_value_limit, 1);
		
		// Put all the digits in the new number
		BF_AppendDigitToMantissa(reverse, carryBits, newRadix, elements.bf_value_limit, 2);
	}
	
	// Which is fine, except that all the digits are now in reverse
	for (i = 0; i < (elements.bf_value_precision * BF_num_values * 2); i++)
	{
		// Take out backwards
		carryBits = BF_RemoveDigitFromMantissa(reverse, newRadix, elements.bf_value_limit, 2);
		
		// And put in forwards
		BF_AppendDigitToMantissa(result, carryBits, newRadix, elements.bf_value_limit, 2);
	}
	
	// if result is too big, truncate until it fits into the allowed space
	while(result[BF_num_values] > 0)
	{
		BF_RemoveDigitFromMantissa(result, newRadix, elements.bf_value_limit, 2);
		elements.bf_exponent++;
	}
	
	// Create a BigFloat with bf_radix = newRadix and value = oldRadix
	exponentNum = [[BigFloat alloc] initWithInt: bf_radix radix: newRadix];
	
	// Raise the BigFloat to the old exponent power
	powerNum = [[BigFloat alloc] initWithInt: bf_exponent radix: newRadix];
	[exponentNum raiseToPower:powerNum];

	// Set the values and elements of this number
	BF_AssignValues(bf_array, result);
	[self assignElements: &elements];
	
	// multiply this number by the BigFloat
	[self multiplyBy: exponentNum];
	
	[exponentNum release];
	[powerNum release];
}

//
// setUserPoint
//
// Puts a fractional point into the number
//
- (void)setUserPoint:(int)pointLocation
{
	[self setElements:bf_radix negative:bf_is_negative exp:bf_exponent valid:bf_is_valid userPoint:pointLocation];
}

//
// getUserPoint
//
// Reports what the current fractional point's location is.
//
- (int)getUserPoint
{
	return bf_user_point;
}

//
// mantissaLength
//
// Returns the number of digits in the number.
//
- (int)mantissaLength
{
	return BF_NumDigitsInArray(bf_array, bf_radix, bf_value_precision);
}

//
// radix
//
// Returns the radix of the current number
//
- (unsigned short)radix
{
	return bf_radix;
}

//
// isValid
//
// Returns whether or not this number is valid (overflow or divide by zero make numbers
// invalid).
//
- (BOOL)isValid
{
	return bf_is_valid;
}

//
// isNegative
//
// Returns the sign of the current number.
//
- (BOOL)isNegative
{
	return bf_is_negative;
}

//
// hasExponent
//
// Returns the presence of an exponent.
//
- (BOOL)hasExponent
{
	return bf_exponent != 0;
}

//
// isZero
//
// True if the number is empty.
//
- (BOOL)isZero
{
	return !BF_ArrayIsNonZero(bf_array, 1);
}

//
// compareWith
//
// Returns the scale of the receiver with respect to num.
//
- (NSComparisonResult)compareWith: (BigFloat*)num
{
	unsigned long		values[BF_num_values];
	unsigned long		otherNum[BF_num_values];
	int						i;
	BigFloatElements	thisNumElements;
	BigFloatElements	otherNumElements;
	NSComparisonResult	compare;
	BOOL					release = NO;
	
	if ([num radix] != bf_radix)
	{
		num = [num copy];
		[num convertToRadix:bf_radix];
		release = YES;
	}
	
	BF_CopyValues(bf_array, values);
	[self copyElements: &thisNumElements];
	BF_CopyValues(num->bf_array, otherNum);
	[num copyElements: &otherNumElements];
	
	// ignore invalid numbers
	if (otherNumElements.bf_is_valid == NO || bf_is_valid == NO)
	{
		if (release)
			[num release];
		return NSOrderedAscending;
	}
	
	// Handle differences in sign
	if (otherNumElements.bf_is_negative != bf_is_negative)
	{
		if (release)
			[num release];

		if (otherNumElements.bf_is_negative)
			return NSOrderedDescending;
		else
			return NSOrderedAscending;
	}
	
	BF_NormaliseNumbers(values, otherNum, &thisNumElements, &otherNumElements);
	
	// Now that we're normalised, do the actual comparison
	compare = NSOrderedSame;
	for (i = BF_num_values - 1; i >= 0; i--)
	{
		if ((values[i] > otherNum[i] && !bf_is_negative) || (values[i] < otherNum[i] && bf_is_negative))
		{
			compare = NSOrderedDescending;
			break;
		}
		else if ((values[i] < otherNum[i] && !bf_is_negative) || (values[i] > otherNum[i] && bf_is_negative))
		{
			compare = NSOrderedAscending;
			break;
		}
	}
	
	if (release)
		[num release];
	return compare;
}

//
// duplicate
//
// Returns an autoreleased copy (can't you read the code?).
//
- (BigFloat*)duplicate
{
	return [[self copy] autorelease];
}

//
// assign
//
// Makes the receiver the same as newValue.
//
- (void)assign: (BigFloat*)newValue
{
	BigFloatElements	thisNumElements;
	unsigned long		values[BF_num_values];
	
	// Copy the values
	BF_CopyValues(newValue->bf_array, values);
	[newValue copyElements: &thisNumElements];
	
	// Set the values of the BigFloat
	BF_AssignValues(bf_array, values);
	[self assignElements: &thisNumElements];
}

//
// abs
//
// Sets the sign of the number to positive.
//
- (void)abs
{
	bf_is_negative = NO;
}

#pragma mark
#pragma mark ##### Arithmetic Functions #####

//
// add
//
// If I have one apple and you give me another apple, how many apples do I have.
//
- (void)add: (BigFloat*)num
{
	unsigned long		values[BF_num_values];
	unsigned long		otherNum[BF_num_values];
	int						i;
	unsigned long 		carryBits = 0;
	BigFloatElements	thisNumElements;
	BigFloatElements	otherNumElements;
	BOOL					release = NO;
	
	if ([num radix] != bf_radix)
	{
		num = [num copy];
		[num convertToRadix:bf_radix];
		release = YES;
	}

	BF_CopyValues(bf_array, values);
	[self copyElements: &thisNumElements];
	BF_CopyValues(num->bf_array, otherNum);
	[num copyElements: &otherNumElements];
	
	// ignore invalid numbers
	if (otherNumElements.bf_is_valid == NO || bf_is_valid == NO)
	{
		bf_is_valid = NO;
		if (release)
			[num release];
		return;
	}
	
	// Handle differences in sign by calling subtraction instead
	if (otherNumElements.bf_is_negative != thisNumElements.bf_is_negative)
	{
		BigFloat *compareNum;
		
		bf_is_negative = bf_is_negative ? NO : YES;
		[self subtract: num];
		
		compareNum = [[BigFloat alloc] initWithInt:0 radix:bf_radix];
		if (![self isZero])
			bf_is_negative = bf_is_negative ? NO : YES;
		
		[compareNum release];
		
		if (release)
			[num release];
		return;
	}
	
	BF_NormaliseNumbers(values, otherNum, &thisNumElements, &otherNumElements);
	
	// We can finally do the addition at this point (yay!)
	carryBits = 0;
	for (i = 0; i < BF_num_values; i++)
	{
		values[i] = values[i] + otherNum[i] + carryBits;
		carryBits = values[i] / thisNumElements.bf_value_limit;
		values[i] %= thisNumElements.bf_value_limit;
	}
	
	// If we have exceeded the maximum precision, reel it back in
	if (carryBits != 0)
	{
		values[BF_num_values - 1] += carryBits * thisNumElements.bf_value_limit;
		
		carryBits = BF_RemoveDigitFromMantissa(values, thisNumElements.bf_radix, thisNumElements.bf_value_limit, 1);
		thisNumElements.bf_exponent++;
	}
	
	// Apply round to nearest
	if ((double)carryBits >= ((double)thisNumElements.bf_radix / 2.0))
	{
		BF_AddToMantissa(values, 1, thisNumElements.bf_value_limit, 1);
		
		// If by shear fluke that cause the top digit to overflow, then shift back by one digit
		if (values[BF_num_values - 1] > thisNumElements.bf_value_limit)
		{
			BF_RemoveDigitFromMantissa(values, thisNumElements.bf_radix, thisNumElements.bf_value_limit, 1);
			thisNumElements.bf_exponent++;
		}
	}
	
	// Create a user pont, store all the values back in the class and we're done
	BF_AssignValues(bf_array, values);
	[self assignElements: &thisNumElements];
	[self createUserPoint];

	if (release)
		[num release];
}

//
// subtract
//
// I have two apples (one of them used to be yours). I eat yours. How many apples do
// I have now?.
//
- (void)subtract: (BigFloat*)num
{
	int						i, peek;
	unsigned long		values[BF_num_values];
	unsigned long		otherNum[BF_num_values];
	BigFloatElements	thisNumElements;
	BigFloatElements	otherNumElements;
	NSComparisonResult	compare;
	BOOL					release = NO;
	
	if ([num radix] != bf_radix)
	{
		num = [num copy];
		[num convertToRadix:bf_radix];
		release = YES;
	}
	
	[self copyElements: &thisNumElements];
	[num copyElements: &otherNumElements];

	// ignore invalid numbers
	if (otherNumElements.bf_is_valid == NO || thisNumElements.bf_is_valid == NO)
	{
		bf_is_valid = NO;
		if (release)
			[num release];
		return;
	}
	
	// Handle differences in sign by calling addition instead
	if (otherNumElements.bf_is_negative != thisNumElements.bf_is_negative)
	{
		bf_is_negative = bf_is_negative ? NO : YES;
		[self add: num];
		bf_is_negative = bf_is_negative ? NO : YES;
		if (release)
			[num release];
		return;
	}

	BF_CopyValues(bf_array, values);
	BF_CopyValues(num->bf_array, otherNum);

	BF_NormaliseNumbers(values, otherNum, &thisNumElements, &otherNumElements);
	
	// Compare the two values
	compare = NSOrderedSame;
	for (i = BF_num_values - 1; i >= 0; i--)
	{
		if (values[i] > otherNum[i])
		{
			compare = NSOrderedDescending;
			break;
		}
		else if (values[i] < otherNum[i])
		{
			compare = NSOrderedAscending;
			break;
		}
	}
	
	if (compare == NSOrderedDescending)
	{
		// Perform the subtraction
		for (i = 0; i < BF_num_values; i++)
		{
			// Borrow from the next column if we need to
			if (otherNum[i] > values[i])
			{
				// Since we know that this num is greater than otherNum, then we know
				// that this will never exceed the bounds of the array
				peek = 1;
				while(values[i + peek] == 0)
				{
					values[i + peek] = thisNumElements.bf_value_limit - 1;
					peek++;
				}
				values[i+peek]--;
				values[i] += thisNumElements.bf_value_limit;
			}
			values[i] = values[i] - otherNum[i];
		}
	}
	else if (compare == NSOrderedAscending)
	{
		// Change the sign of this num
		thisNumElements.bf_is_negative = thisNumElements.bf_is_negative ? NO : YES;
		
		// Perform the subtraction
		for (i = 0; i < BF_num_values; i++)
		{
			// Borrow from the next column if we need to
			if (values[i] > otherNum[i])
			{
				// Since we know that this num is greater than otherNum, then we know
				// that this will never exceed the bounds of the array
				peek = 1;
				while(otherNum[i + peek] == 0)
				{
					otherNum[i + peek] = otherNumElements.bf_value_limit - 1;
					peek++;
				}
				otherNum[i+peek]--;
				otherNum[i] += otherNumElements.bf_value_limit;
			}
			values[i] = otherNum[i] - values[i];
		}
	}
	else
	{
		// Zero the exponent and remove the sign
		thisNumElements.bf_exponent = 0;
		thisNumElements.bf_is_negative = NO;
		
		// Subtraction results in zero
		BF_ClearValuesArray(values, 1);
	}

	// Create a user pont, store all the values back in the class and we're done
	BF_AssignValues(bf_array, values);
	[self assignElements: &thisNumElements];
	[self createUserPoint];

	if (release)
		[num release];
}

//
// multiplyBy
//
// I take the 8 seeds out of my apple. I plant them in the ground and grow 8 trees.
// Each tree has 8 apples, how successful is my orchard?
//
- (void)multiplyBy: (BigFloat*)num
{
	int						i, j;
	long					carryBits;
	unsigned long		result[BF_num_values * 2];
	unsigned long		values[BF_num_values];
	unsigned long		otherNum[BF_num_values];
	BigFloatElements	thisNumElements;
	BigFloatElements	otherNumElements;
	BOOL					shift = NO;
	BOOL					release = NO;
	
	if ([num radix] != bf_radix)
	{
		num = [num copy];
		[num convertToRadix:bf_radix];
		release = YES;
	}
	
	// Get a working copy of the values that will be multiplied
	BF_CopyValues(bf_array, values);
	[self copyElements: &thisNumElements];
	BF_CopyValues(num->bf_array, otherNum);
	[num copyElements: &otherNumElements];

	// ignore invalid numbers
	if (otherNumElements.bf_is_valid == NO || thisNumElements.bf_is_valid == NO)
	{
		bf_is_valid = NO;
		if (release)
			[num release];
		return;
	}

	// Apply the user's decimal point
	thisNumElements.bf_exponent -=thisNumElements. bf_user_point;
	thisNumElements.bf_user_point = 0;
	otherNumElements.bf_exponent -= otherNumElements.bf_user_point;
	otherNumElements.bf_user_point = 0;

	// Multiply exponents through addition
	thisNumElements.bf_exponent += otherNumElements.bf_exponent;
	
	// Two negatives make a positive
	if (otherNumElements.bf_is_negative) (thisNumElements.bf_is_negative) ? (thisNumElements.bf_is_negative = NO) : (thisNumElements.bf_is_negative = YES);
	
	// Clear the result space
	BF_ClearValuesArray(result, 2);
	
	// Now we do the multiplication. Basic stuff: 
	// Multiply each column of each of the otherNums by each other and sum all of the results
	for (j = 0; j < BF_num_values; j++)
	{
		// Add the product of this column of otherNum with this num
		carryBits = 0;
		for (i = 0; i < BF_num_values; i++)
		{
			result[i + j] += (values[i] * otherNum[j]) + carryBits;
			carryBits = result[i + j] / thisNumElements.bf_value_limit;
			result[i + j] = result[i + j] % thisNumElements.bf_value_limit;
			
			if (i + j >= BF_num_values && result[i + j] != 0) shift = YES;
		}
		
		// Add the carry for the last multiplication to the next column
		result[j + BF_num_values] += carryBits;
		if (result[j + BF_num_values] != 0) shift = YES;
	}
	
	// If we have exceeded the precision, divide by the bf_radix until
	// we are reeled back in.
	while(BF_ArrayIsNonZero(&result[BF_num_values], 1))
	{
		carryBits = BF_RemoveDigitFromMantissa(result, thisNumElements.bf_radix, thisNumElements.bf_value_limit, 2);
		thisNumElements.bf_exponent++;
	}
	
	// Apply round to nearest
	if ((double)carryBits >= ((double)bf_radix / 2.0))
	{
		BF_AddToMantissa(result, 1, thisNumElements.bf_value_limit, 1);
		
		// If by shear fluke that caused the top digit to overflow, then shift back by one digit
		if (result[BF_num_values - 1] > thisNumElements.bf_value_limit)
		{
			BF_RemoveDigitFromMantissa(result, thisNumElements.bf_radix, thisNumElements.bf_value_limit, 1);
			thisNumElements.bf_exponent++;
		}
	}
	
	// Create a user pont, store all the values back in the class and we're done
	BF_AssignValues(bf_array, result);
	[self assignElements: &thisNumElements];
	[self createUserPoint];

	if (release)
		[num release];
}

//
// divideBy
//
// You see my orchard and get jealous. You start a fire that takes out half my crop.
// How do you explain your actions to the judge?
//
- (void)divideBy: (BigFloat*)num
{
	int						i, j, peek;
	unsigned long		carryBits;
	unsigned long		values[BF_num_values * 2];
	unsigned long		otherNumValues[BF_num_values * 2];
	unsigned long		result[BF_num_values * 2];
	unsigned long		subValues[BF_num_values * 2];
	BigFloatElements	thisNumElements;
	BigFloatElements	otherNumElements;
	unsigned long		quotient;
	NSComparisonResult	compare;
	BOOL					release = NO;
	
	if ([num radix] != bf_radix)
	{
		num = [num copy];
		[num convertToRadix:bf_radix];
		release = YES;
	}

	// Clear the working space
	BF_ClearValuesArray(otherNumValues, 1);
	BF_ClearValuesArray(values, 1);
	BF_ClearValuesArray(result, 2);
	BF_ClearValuesArray(subValues, 2);

	// Get the numerical values
	BF_CopyValues(bf_array, &values[BF_num_values]);
	[self copyElements: &thisNumElements];
	BF_CopyValues(num->bf_array, &otherNumValues[BF_num_values]);
	[num copyElements: &otherNumElements];
	
	// ignore invalid numbers
	if (otherNumElements.bf_is_valid == NO || thisNumElements.bf_is_valid == NO)
	{
		bf_is_valid = NO;
		if (release)
			[num release];
		return;
	}

	// Apply the user's decimal point
	thisNumElements.bf_exponent -= thisNumElements.bf_user_point;
	thisNumElements.bf_user_point = 0;
	otherNumElements.bf_exponent -= otherNumElements.bf_user_point;
	otherNumElements.bf_user_point = 0;

	// Two negatives make a positive
	if (otherNumElements.bf_is_negative) (thisNumElements.bf_is_negative) ? (thisNumElements.bf_is_negative = NO) : (thisNumElements.bf_is_negative = YES);
	
	// Normalise this num
	// This involves multiplying through by the bf_radix until the number runs up against the
	// left edge or MSD (most significant digit)
	if (BF_ArrayIsNonZero(values, 2))
	{
		while(values[BF_num_values * 2 - 1] < (thisNumElements.bf_value_limit / thisNumElements.bf_radix))
		{
			BF_AppendDigitToMantissa(values, 0, thisNumElements.bf_radix, thisNumElements.bf_value_limit, 2);
			
			thisNumElements.bf_exponent--;
		}
	}
	else
	{
		BF_AssignValues(bf_array, &values[BF_num_values]);
		bf_exponent = 0;
		bf_user_point = 0;
		bf_is_negative = 0;
		if (release)
			[num release];
		return;
	}

	// We have the situation where otherNum had a larger kNumValue'th digit than
	// this num did in the first place. So we may have to divide through by bf_radix
	// once to normalise otherNum
	if (otherNumValues[BF_num_values * 2 - 1] > values[BF_num_values * 2 - 1])
	{
		carryBits = BF_RemoveDigitFromMantissa(otherNumValues, thisNumElements.bf_radix, thisNumElements.bf_value_limit, 2);
		otherNumElements.bf_exponent++;

		if ((double)carryBits >= ((double)otherNumElements.bf_radix / 2.0))
		{
			BF_AddToMantissa(otherNumValues, 1, otherNumElements.bf_value_limit, 2);
		}
	}
	else
	{
		// Normalise otherNum so that it cannot be greater than this num
		// This involves multiplying through by the bf_radix until the number runs up
		// against the left edge or MSD (most significant digit)
		// If the last multiply will make otherNum greater than this num, then we
		// don't do it. This ensures that the first division column will always be non-zero.
		if (BF_ArrayIsNonZero(otherNumValues, 2))
		{
			while
			(
				(otherNumValues[BF_num_values * 2 - 1] < (otherNumElements.bf_value_limit / otherNumElements.bf_radix))
				&&
				(otherNumValues[BF_num_values * 2 - 1] < (values[BF_num_values * 2 - 1] / otherNumElements.bf_radix))
			)
			{
				BF_AppendDigitToMantissa(otherNumValues, 0, thisNumElements.bf_radix, thisNumElements.bf_value_limit, 2);
				otherNumElements.bf_exponent--;
			}
		}
		else
		{
			bf_is_valid = NO;
			if (release)
				[num release];
			return;
		}
	}
	
	// Subtract the exponents
	thisNumElements.bf_exponent -= otherNumElements.bf_exponent;
	
	// Account for the de-normalising effect of division
	thisNumElements.bf_exponent -= (BF_num_values - 1) * thisNumElements.bf_value_precision;

	// Begin the division
	// What we are doing here is lining the divisor up under the divisee and subtracting the largest multiple
	// of the divisor that we can from the divisee with resulting in a negative number. Basically it is what
	// you do without really thinking about it when doing long division by hand.
	for (i = BF_num_values * 2 - 1; i >= BF_num_values - 1; i--)
	{
		// If the divisor is greater or equal to the divisee, leave this result column unchanged.
		if (otherNumValues[BF_num_values * 2 - 1] > values[i])
		{
			if (i > 0)
			{
				values[i - 1] += values[i] * thisNumElements.bf_value_limit;
			}
			continue;
		}
		
		// Determine the quotient of this position (the multiple of  the divisor to use)
		quotient = values[i] / otherNumValues[BF_num_values * 2 - 1];
		carryBits = 0;
		for (j = 0; j <= i; j++)
		{
			subValues[j] = otherNumValues[j + (BF_num_values * 2 - 1 - i)] * quotient + carryBits;
			carryBits = subValues[j] / thisNumElements.bf_value_limit;
			subValues[j] %= thisNumElements.bf_value_limit;
		}
		subValues[i] += carryBits * thisNumElements.bf_value_limit;
		
		// Check that values is greater than subValues (ie check that this subtraction won't
		// result in a negative number)
		compare = NSOrderedSame;
		for (j = i; j >= 0; j--)
		{
			if (values[j] > subValues[j])
			{
				compare = NSOrderedDescending;
				break;
			}
			else if (values[j] < subValues[j])
			{
				compare = NSOrderedAscending;
				break;
			}
		}
		
		// If we have overestimated the quotient, adjust appropriately. This just means that we need
		// to reduce the divisor's multiplier by one.
		while(compare == NSOrderedAscending)
		{
			quotient--;
			carryBits = 0;
			for (j = 0; j <= i; j++)
			{
				subValues[j] = otherNumValues[j + (BF_num_values * 2 - 1 - i)] * quotient + carryBits;
				carryBits = subValues[j] / thisNumElements.bf_value_limit;
				subValues[j] %= thisNumElements.bf_value_limit;
			}
			subValues[i] += carryBits * thisNumElements.bf_value_limit;

			// Check that values is greater than subValues (ie check that this subtraction won't
			// result in a negative number)
			compare = NSOrderedSame;
			for (j = i; j >= 0; j--)
			{
				if (values[j] > subValues[j])
				{
					compare = NSOrderedDescending;
					break;
				}
				else if (values[j] < subValues[j])
				{
					compare = NSOrderedAscending;
					break;
				}
			}
		}
		
		// We now have the number to place in this column of the result. Yay.
		result[i] = quotient;

		// If the subtraction operation will result in no remainder, then finish
		if (compare == NSOrderedSame)
		{
			break;
		}
		
		// Subtract the sub values from values now
		for (j = (BF_num_values * 2 - 1); j >= 0; j--)
		{
			if (subValues[j] > values[j])
			{
				// Since we know that this num is greater than the sub num, then we know
				// that this will never exceed the bounds of the array
				peek = 1;
				while(values[j + peek] == 0)
				{
					values[j + peek] = thisNumElements.bf_value_limit - 1;
					peek++;
				}
				values[j+peek]--;
				values[j] += thisNumElements.bf_value_limit;
			}
			values[j] -= subValues[j];
		}
		
		// Attach the remainder to the next column on the right so that it will be part of the next
		// column's operation
		values[i - 1] += values[i] * thisNumElements.bf_value_limit;
		
		// Clear the remainder from this column
		values[i] = 0;
		subValues[i] = 0;
	}
	
	// Normalise the result
	// This involves multiplying through by the bf_radix until the number runs up against the
	// left edge or MSD (most significant digit)
	while(result[BF_num_values * 2 - 1] < (thisNumElements.bf_value_limit / thisNumElements.bf_radix))
	{
		BF_AppendDigitToMantissa(result, 0, thisNumElements.bf_radix, thisNumElements.bf_value_limit, 2);
		thisNumElements.bf_exponent--;
	}
	
	// Apply a round to nearest on the last digit
	if (((double)result[BF_num_values - 1] / (double)(bf_value_limit / bf_radix)) >= ((double)bf_radix / 2.0))
	{
		BF_AddToMantissa(&result[BF_num_values], 1, thisNumElements.bf_value_limit, 1);
		
		// If by shear fluke that cause the top digit to overflow, then shift back by one digit
		if (result[BF_num_values - 1] > thisNumElements.bf_value_limit)
		{
			carryBits = BF_RemoveDigitFromMantissa(&result[BF_num_values], thisNumElements.bf_radix, thisNumElements.bf_value_limit, 1);
			thisNumElements.bf_exponent++;
			if ((double)carryBits >= ((double)thisNumElements.bf_radix / 2.0))
			{
				BF_AddToMantissa(&result[BF_num_values], 1, thisNumElements.bf_value_limit, 1);
			}
		}
	}

	// Remove any trailing zeros in the decimal places by dividing by the bf_radix until they go away
	carryBits = 0;
	while((thisNumElements.bf_exponent < 0) && (result[BF_num_values] % thisNumElements.bf_radix == 0))
	{
		carryBits = BF_RemoveDigitFromMantissa(&result[BF_num_values], thisNumElements.bf_radix, thisNumElements.bf_value_limit, 1);
		thisNumElements.bf_exponent++;
	}
	if ((double)carryBits >= ((double)thisNumElements.bf_radix / 2.0))
	{
		BF_AddToMantissa(&result[BF_num_values], 1, thisNumElements.bf_value_limit, 1);
	}
	
	
	// Create a user pont, store all the values back in the class and we're done
	BF_AssignValues(bf_array, &result[BF_num_values]);
	[self assignElements: &thisNumElements];
	[self createUserPoint];

	if (release)
		[num release];
}

//
// moduloBy
//
// The judge orders that that the orchard be divided between you, me and the judge. The
// remaining tree is given to charity.
//
- (void)moduloBy: (BigFloat*)num
{
	int						i, j, peek;
	unsigned long		carryBits;
	unsigned long		values[BF_num_values * 2];
	unsigned long		otherNumValues[BF_num_values * 2];
	unsigned long		result[BF_num_values * 2];
	unsigned long		subValues[BF_num_values * 2];
	BigFloatElements	otherNumElements;
	BigFloatElements	thisNumElements;
	unsigned long		quotient;
	NSComparisonResult	compare;
	int						divisionExponent;
	BigFloat				*subNum;
	BOOL					release = NO;
	
	if ([num radix] != bf_radix)
	{
		num = [num copy];
		[num convertToRadix:bf_radix];
		release = YES;
	}

	// Clear the working space
	BF_ClearValuesArray(otherNumValues, 1);
	BF_ClearValuesArray(values, 1);
	BF_ClearValuesArray(result, 2);
	BF_ClearValuesArray(subValues, 2);

	// Get the numerical values
	BF_CopyValues(bf_array, &values[BF_num_values]);
	[self copyElements: &thisNumElements];
	BF_CopyValues(num->bf_array, &otherNumValues[BF_num_values]);
	[num copyElements: &otherNumElements];
	
	// ignore invalid numbers
	if (otherNumElements.bf_is_valid == NO || thisNumElements.bf_is_valid == NO)
	{
		bf_is_valid = NO;
		if (release)
			[num release];
		return;
	}

	compare = [self compareWith: num];
	if (compare == NSOrderedAscending)
	{
		// return unchanged if num is less than the modulor
		if (release)
			[num release];
		return;
	}

	// Apply the user's decimal point
	thisNumElements.bf_exponent -= thisNumElements.bf_user_point;
	thisNumElements.bf_user_point = 0;
	otherNumElements.bf_exponent -= otherNumElements.bf_user_point;
	otherNumElements.bf_user_point = 0;
	
	// Two negatives make a positive
	if (otherNumElements.bf_is_negative) (thisNumElements.bf_is_negative) ? (thisNumElements.bf_is_negative = NO) : (thisNumElements.bf_is_negative = YES);
	
	// Normalise this num
	// This involves multiplying through by the bf_radix until the number runs up against the
	// left edge or MSD (most significant digit)
	if (BF_ArrayIsNonZero(values, 2))
	{
		while(values[BF_num_values * 2 - 1] < (thisNumElements.bf_value_limit / thisNumElements.bf_radix))
		{
			BF_AppendDigitToMantissa(values, 0, thisNumElements.bf_radix, thisNumElements.bf_value_limit, 2);
			
			thisNumElements.bf_exponent--;
		}
	}
	else
	{
		BF_AssignValues(bf_array, &values[BF_num_values]);
		bf_exponent = 0;
		bf_user_point = 0;
		bf_is_negative = 0;
		if (release)
			[num release];
		return;
	}

	// Normalise otherNum so that it cannot be greater than this num
	// This involves multiplying through by the bf_radix until the number runs up
	// against the left edge or MSD (most significant digit)
	// If the last multiply will make otherNum greater than this num, then we
	// don't do it. This ensures that the first division column will always be non-zero.
	if (BF_ArrayIsNonZero(otherNumValues, 2))
	{
		while
		(
			(otherNumValues[BF_num_values * 2 - 1] < (otherNumElements.bf_value_limit / otherNumElements.bf_radix))
			&&
			(otherNumValues[BF_num_values * 2 - 1] < (values[BF_num_values * 2 - 1] / otherNumElements.bf_radix))
		)
		{
			BF_AppendDigitToMantissa(otherNumValues, 0, thisNumElements.bf_radix, thisNumElements.bf_value_limit, 2);
			otherNumElements.bf_exponent--;
		}
	}
	else
	{
		bf_is_valid = NO;
		if (release)
			[num release];
		return;
	}
	
	// Subtract the exponents
	divisionExponent = thisNumElements.bf_exponent - otherNumElements.bf_exponent;
	
	// Account for the de-normalising effect of division
	divisionExponent -= (BF_num_values - 1) * thisNumElements.bf_value_precision;
	
	// Set the re-normalised values so that we can subtract from self later
	BF_AssignValues(bf_array, &values[BF_num_values]);
	[self assignElements: &thisNumElements];

	// Begin the division
	// What we are doing here is lining the divisor up under the divisee and subtracting the largest multiple
	// of the divisor that we can from the divisee with resulting in a negative number. Basically it is what
	// you do without really thinking about it when doing long division by hand.
	for (i = BF_num_values * 2 - 1; i >= BF_num_values - 1; i--)
	{
		// If the divisor is greater or equal to the divisee, leave this result column unchanged.
		if (otherNumValues[BF_num_values * 2 - 1] > values[i])
		{
			if (i > 0)
			{
				values[i - 1] += values[i] * thisNumElements.bf_value_limit;
			}
			continue;
		}
		
		// Determine the quotient of this position (the multiple of  the divisor to use)
		quotient = values[i] / otherNumValues[BF_num_values * 2 - 1];
		carryBits = 0;
		for (j = 0; j <= i; j++)
		{
			subValues[j] = otherNumValues[j + (BF_num_values * 2 - 1 - i)] * quotient + carryBits;
			carryBits = subValues[j] / bf_value_limit;
			subValues[j] %= bf_value_limit;
		}
		subValues[i] += carryBits * bf_value_limit;
		
		// Check that values is greater than subValues (ie check that this subtraction won't
		// result in a negative number)
		compare = NSOrderedSame;
		for (j = i; j >= 0; j--)
		{
			if (values[j] > subValues[j])
			{
				compare = NSOrderedDescending;
				break;
			}
			else if (values[j] < subValues[j])
			{
				compare = NSOrderedAscending;
				break;
			}
		}
		
		// If we have overestimated the quotient, adjust appropriately. This just means that we need
		// to reduce the divisor's multiplier by one.
		if (compare == NSOrderedAscending)
		{
			quotient--;
			carryBits = 0;
			for (j = 0; j <= i; j++)
			{
				subValues[j] = otherNumValues[j + (BF_num_values * 2 - 1 - i)] * quotient + carryBits;
				carryBits = subValues[j] / bf_value_limit;
				subValues[j] %= bf_value_limit;
			}
			subValues[i] += carryBits * bf_value_limit;
		}
		
		// We now have the number to place in this column of the result. Yay.
		result[i] = quotient;

		// If the subtraction operation will result in no remainder, then finish
		if (compare == NSOrderedSame)
		{
			break;
		}
		
		// Subtract the sub values from values now
		for (j = 0; j < BF_num_values * 2; j++)
		{
			if (subValues[j] > values[j])
			{
				// Since we know that this num is greater than the sub num, then we know
				// that this will never exceed the bounds of the array
				peek = 1;
				while(values[j + peek] == 0)
				{
					values[j + peek] = bf_value_limit - 1;
					peek++;
				}
				values[j + peek]--;
				values[j] += bf_value_limit;
			}
			values[j] -= subValues[j];
		}
		
		// Attach the remainder to the next column on the right so that it will be part of the next
		// column's operation
		values[i - 1] += values[i] * bf_value_limit;
		
		// Clear the remainder from this column
		values[i] = 0;
	}
	
	// Remove the fractional part of the division result
	// We know that there must be a non-fractional part since the modulor was tested to
	// be less or equal to the modulee
	while(divisionExponent < 0)
	{
		carryBits = BF_RemoveDigitFromMantissa(&result[BF_num_values], thisNumElements.bf_radix, thisNumElements.bf_value_limit, 1);
		result[BF_num_values - 1] += carryBits * thisNumElements.bf_value_limit;
		carryBits = BF_RemoveDigitFromMantissa(result, thisNumElements.bf_radix, thisNumElements.bf_value_limit, 1);
		divisionExponent++;
	}
	
	// Now create a number that is this dividend times the modulor and subtract it from the
	// modulee to obtain the result
	subNum = [[BigFloat alloc] initWithInt:0 radix:thisNumElements.bf_radix];
	[subNum setElements:thisNumElements.bf_radix negative:thisNumElements.bf_is_negative exp:divisionExponent valid:YES userPoint:0];
	BF_CopyValues(&result[BF_num_values], subNum->bf_array);
	
	[subNum multiplyBy: num];
	[self subtract: subNum];
	[subNum release];
	
	// Remove any trailing zeros in the decimal places by dividing by the bf_radix until they go away
	BF_CopyValues(bf_array, values);
	[self copyElements: &thisNumElements];
	while((thisNumElements.bf_exponent < 0) && (values[0] % thisNumElements.bf_radix == 0))
	{
		carryBits = BF_RemoveDigitFromMantissa(values, thisNumElements.bf_radix, thisNumElements.bf_value_limit, 1);
		bf_exponent++;
	}
		
	// Create a user pont, store all the values back in the class and we're done
	BF_AssignValues(bf_array, values);
	[self assignElements: &thisNumElements];
	[self createUserPoint];
	if (release)
		[num release];
}

#pragma mark
#pragma mark ##### Extended Mathematics Functions #####

//
// powerOfE
//
// The value of the receiver will be e^x where x is the value of the receiver
// before calling this function.
//
- (void)powerOfE
{
	BigFloat	*prevIteration;
	BigFloat	*powerCopy;
	BigFloat	*nextTerm;
	BigFloat	*original;
	BigFloat	*factorialValue;
	BigFloat	*one;
	BigFloat	*two;
	BOOL		use_inverse = NO;
	BigFloat	*i;
	int			squares = 0;
	
	if (!bf_is_valid)
		return;
	
	// Pre-scale the number to aid convergeance
	if (bf_is_negative)
	{
		use_inverse = YES;
		bf_is_negative = NO;
	}
	
	one = [[BigFloat alloc] initWithInt:1 radix:bf_radix];
	two = [[BigFloat alloc] initWithInt:2 radix:bf_radix];
	while ([self compareWith: one] == NSOrderedDescending)
	{
		[self divideBy: two];
		squares++;
	}
	
	// Initialise stuff
	factorialValue = [[BigFloat alloc] initWithInt:1 radix:bf_radix];
	prevIteration = [factorialValue copy];
	original = [self copy];
	powerCopy = [self copy];
	
	// Set the current value to 1 (the zeroth term)
	[self assign:factorialValue];

	// Add the second term
	[self add: original];
	
	// otherwise iterate the Taylor Series until we obtain a stable solution
	i = [[BigFloat alloc] initWithInt:2 radix:bf_radix];;
	nextTerm = [factorialValue copy];
	while([self compareWith: prevIteration] != NSOrderedSame)
	{
		// Get a copy of the current value so that we can see if it changes
		[prevIteration assign:self];
		
		// Determine the next term of the series
		[powerCopy multiplyBy: original];
		[nextTerm assign:powerCopy];
		
		[factorialValue multiplyBy:i];
		[nextTerm divideBy: factorialValue];
		
		// Add the next term if it is valid
		if ([nextTerm isValid])
		{
			[self add: nextTerm];
		}
		
		[i add:one];
	}
	
	// Reverse the prescaling
	while (squares > 0)
	{
		[self multiplyBy: self];
		squares--;
	}
	
	if (use_inverse)
	{
		[self inverse];
	}
	
	[prevIteration release];
	[nextTerm release];
	[factorialValue release];
	[powerCopy release];
	[original release];
	[one release];
	[two release];
	[i release];
}

//
// ln
//
// Takes the natural logarithm of the receiver.
//
- (void)ln
{
	BigFloat				*factorNum;
	BigFloat				*prevIteration;
	BigFloat				*powerCopy;
	BigFloat				*nextTerm;
	BigFloat				*original;
	BigFloat				*one;
	BigFloat				*eigth;
	BigFloat				*i;
	NSComparisonResult	compare;
	BOOL					inverse = NO;
	unsigned long long	outputFactor = 1;
	
	if (!bf_is_valid)
		return;

	prevIteration = [[BigFloat alloc] initWithInt: 0 radix: bf_radix];
	one = [[BigFloat alloc] initWithInt: 1 radix: bf_radix];
	i = [[BigFloat alloc] initWithInt: 2 radix: bf_radix];
	eigth = [[BigFloat alloc] initWithDouble: 0.125 radix: bf_radix];
	
	// ln(x) for x <= 0 is inValid
	compare = [self compareWith: prevIteration];
	if ([self isZero] || compare == NSOrderedAscending)
	{
		bf_is_valid = NO;
		return;
	}
	
	// ln(x) for x > 1 == -ln(1/x)
	compare = [self compareWith: one];
	if (compare == NSOrderedDescending)
	{
		[self inverse];
		inverse = YES;
	}
	
	// Shift the number into a range between 1/8th and 1 (helps convergeance to a solution)
	compare = [self compareWith: eigth];
	while(compare == NSOrderedAscending)
	{
		[self sqrt];
		outputFactor *= 2;
		compare = [self compareWith: eigth];
	}

	// The base of our power is (x-1)
	// This value is also the first term
	[self subtract: one];
	original = [self copy];
	powerCopy = [self copy];
	nextTerm = [self copy];

	// iterate the Taylor Series until we obtain a stable solution
	while([self compareWith: prevIteration] != NSOrderedSame)
	{
		// Get a copy of the current value so that we can see if it changes
		[prevIteration assign: self];

		// Determine the next term of the series
		[powerCopy multiplyBy: original];
		[nextTerm assign: powerCopy];
		[nextTerm divideBy: i];

		// Subtract the next term if it is valid
		if ([nextTerm isValid])
		{
			[self subtract: nextTerm];
		}
		
		[i add: one];

		// Determine the next term of the series
		[powerCopy multiplyBy: original];
		[nextTerm assign: powerCopy];
		[nextTerm divideBy: i];

		// Add the next term if it is valid
		if ([nextTerm isValid])
		{
			[self add: nextTerm];
		}
		
		[i add: one];
	}
	
	if (inverse)
		[self appendDigit:L'-' useComplement:0];
	
	// Descale the result
	factorNum = [[BigFloat alloc] initWithInt: outputFactor radix: bf_radix];
	[self multiplyBy:factorNum];
	
	[factorNum release];
	[prevIteration release];
	[powerCopy release];
	[nextTerm release];
	[original release];
	[one release];
	[eigth release];
	[i release];
}

//
// raiseToPower
//
// Raises the receiver to the exponent "num".
//
- (void)raiseToPower: (BigFloat*)num
{
	BigFloat	*numCopy;
	BigFloat	*one;
	BigFloat	*minus_one;
	BigFloat	*two;
	BOOL		negative = NO;
	
	if (!bf_is_valid)
		return;
	
	if (![num isValid])
	{
		bf_is_valid = NO;
		return;
	}

	numCopy = [num copy];
	one = [[BigFloat alloc] initWithInt: 1 radix: bf_radix];

	if ([self isZero])
	{
		// Zero raised to anything except zero is zero (provided exponent is valid)
		bf_is_valid = [num isValid];
		if ([num isZero])
		{
			[self assign:one];
		}
		[one release];
		return;
	}
	
	if (bf_is_negative)
	{
		bf_is_negative = NO;
		negative = YES;
	}
	
	[self ln];
	[self multiplyBy: numCopy];
	[self powerOfE];
	
	if (negative)
	{
		NSComparisonResult order;
		
		two = [[BigFloat alloc] initWithInt:2 radix: bf_radix];
		minus_one = [[BigFloat alloc] initWithInt:-1 radix: bf_radix];
		if ([numCopy isNegative])
			[numCopy multiplyBy:minus_one];
		[numCopy moduloBy:two];
		
		order = [numCopy compareWith:one];
		if (order == NSOrderedSame)
		{
			bf_is_negative = YES;
		}
		else if (![numCopy isZero])
		{
			bf_is_valid = NO;
		}
		
		[two release];
		[minus_one release];
	}
	
	[numCopy release];
	[one release];
}

//
// sqrt
//
// Takes the square root of the receiver (raises to the power 1/2)
//
- (void)sqrt
{
	BigFloat				*original;
	BigFloat				*prevGuess;
	BigFloat				*newGuess;
	BigFloat				*two;
	int						i, j;
	BOOL					digitNotFound = YES;
	int						numDigits;
	NSComparisonResult	compare;
	
	if (!bf_is_valid)
		return;

	if ([self isNegative])
	{
		bf_is_valid = NO;
		return;
	}
	
	original = [self copy];
	two = [[BigFloat alloc] initWithInt:2 radix: bf_radix];
	
	// Count the number of digits left of the point
	numDigits = BF_num_values * bf_value_precision + bf_exponent - bf_user_point;
	for (i = BF_num_values - 1; i >= 0 && digitNotFound; i--)
	{
		for (j = bf_value_precision - 1; j >= 0 && digitNotFound; j--)
		{
			if ((bf_array[i] / (unsigned long)(pow(bf_radix, j)) % bf_radix) == 0)
			{
				numDigits--;
			}
			else
			{
				digitNotFound = NO;
			}
		}
	}
	
	// The first guess will be this number with its numDigits halved
	bf_exponent -= (numDigits / 2);
	prevGuess = [self copy];
	newGuess = [self copy];
	compare = NSOrderedDescending;
	
	// Do some Newton's method iterations until we converge
	while(compare != NSOrderedSame)
	{
		[prevGuess assign: newGuess];
		
		[newGuess assign: original];
		[newGuess divideBy: prevGuess];
		[newGuess add: prevGuess];
		[newGuess divideBy: two];
		
		compare = [newGuess compareWith: prevGuess];
	}
	
	// Use the last guess
	[self assign: newGuess];
	
	[original release];
	[two release];
	[prevGuess release];
	[newGuess release];
}

//
// inverse
//
// Performs 1/receiver.
//
- (void)inverse
{
	BigFloat	*inverseValue;
	
	if (!bf_is_valid)
		return;

	if ([self isZero])
	{
		bf_is_valid = NO;
		return;
	}
	inverseValue = [[BigFloat alloc] initWithInt:1 radix: bf_radix];
	[inverseValue divideBy: self];
	[self assign: inverseValue];
	
	[inverseValue release];
}

//
// logOfBase
//
// Takes the "base" log of the receiver.
//
- (void)logOfBase:(BigFloat *)base
{
	BigFloat *baseCopy;
	
	if (!bf_is_valid)
		return;
	
	if (![base isValid])
	{
		bf_is_valid = NO;
		return;
	}

	baseCopy = [base copy];
	[self ln];
	[baseCopy ln];
	[self divideBy: baseCopy];
	
	[baseCopy release];
}

//
// sinWithTrigMode
//
// Really this is four different functions in one:
//		sin, arcsin, hypsin and hyparcsin
//
- (void)sinWithTrigMode: (BFTrigMode)mode inv: (BOOL)useInverse hyp: (BOOL)useHyp
{
	unsigned long		values[BF_num_values];
	unsigned long		otherNum[BF_num_values];
	BigFloatElements	thisNumElements;
	BigFloatElements	otherNumElements;
	BigFloat				*prevIteration;
	BigFloat				*powerCopy;
	BigFloat				*nextTerm;
	BigFloat				*factorial;
	BigFloat				*original;
	BigFloat				*value;
	BigFloat				*one;
	BigFloat				*two;
	BigFloat				*zero;
	BigFloat				*four;
	unsigned long		i;

	if (!bf_is_valid)
		return;

	one = [[BigFloat alloc] initWithInt:1 radix: bf_radix];
	two = [[BigFloat alloc] initWithInt:2 radix: bf_radix];
	zero = [[BigFloat alloc] initWithInt:0 radix: bf_radix];
	four = [[BigFloat alloc] initWithInt:4 radix: bf_radix];

	if (useHyp == NO)
	{
		if (useInverse == NO)
		{
			if (pi_array[bf_radix] == nil)
				[self calculatePi];

			if (mode != BF_radians)
			{
				
				if (mode == BF_degrees)
				{
					BigFloat *oneEighty = [[BigFloat alloc] initWithInt: 180 radix: bf_radix];
					BigFloat *threeSixty = [[BigFloat alloc] initWithInt: 360 radix: bf_radix];
					[self divideBy:oneEighty];
					[self moduloBy:threeSixty];
					[oneEighty release];
					[threeSixty release];
				}
				else if (mode == BF_gradians)
				{
					BigFloat *twoHundred = [[BigFloat alloc] initWithInt: 200 radix: bf_radix];
					BigFloat *fourHundred = [[BigFloat alloc] initWithInt: 400 radix: bf_radix];
					[self divideBy:twoHundred];
					[self moduloBy:fourHundred];
					[twoHundred release];
					[fourHundred release];
				}
				
				[self multiplyBy: pi_array[bf_radix]];
			}
			else
			{
				BigFloat *two_pi = [[BigFloat alloc] initWithInt:2 radix: bf_radix];
				[two_pi multiplyBy:pi_array[bf_radix]];
				[self moduloBy:two_pi];
				[two_pi release];
			}
			
			prevIteration = [zero copy];
			factorial = [one copy];
			original = [self copy];
			powerCopy = [self copy];
			nextTerm = [self copy];
			
			i = 1;
			while([self compareWith: prevIteration] != NSOrderedSame)
			{
				BigFloat *twoN;
				BigFloat *twoNPlusOne;
				
				// Get a copy of the current value so that we can see if it changes
				[prevIteration assign:self];
		
				// Determine the next term of the series
				// Numerator is x^(2n+1)
				[powerCopy multiplyBy: original];
				[powerCopy multiplyBy: original];
				[nextTerm assign:powerCopy];
				
				// Divide the term by (2n+1)!
				twoN = [[BigFloat alloc] initWithInt: (i * 2) radix: bf_radix];
				twoNPlusOne = [[BigFloat alloc] initWithInt: (i * 2 + 1) radix: bf_radix];
				[factorial multiplyBy:twoN];
				[factorial multiplyBy:twoNPlusOne];
				[nextTerm divideBy: factorial];
				[twoN release];
				[twoNPlusOne release];
		
				// Add/subtract the next term if it is valid
				if ([nextTerm isValid])
				{
					if (i % 2 == 0)
						[self add: nextTerm];
					else
						[self subtract: nextTerm];
				}
				
				i++;
			}
			
			// Check that accurracy hasn't caused something illegal
			value = [self copy];
			[value abs];
			if ([value compareWith:one] == NSOrderedDescending)
			{
				[self divideBy:value];
			}

			// Normalise to remove built up error (makes a zero output possible)
			nextTerm = [[BigFloat alloc] initWithInt:10000 radix:bf_radix];
			BF_CopyValues(bf_array, values);
			[self copyElements: &thisNumElements];
			BF_CopyValues(nextTerm->bf_array, otherNum);
			[nextTerm copyElements: &otherNumElements];
			BF_NormaliseNumbers(values, otherNum, &thisNumElements, &otherNumElements);
			BF_AssignValues(bf_array, values);
			[self assignElements: &thisNumElements];
			[self createUserPoint];
		}
		else // Inverse sine
		{
			BOOL	arcsinShift = NO;
			BOOL	signChange = NO;
			BigFloat *half = [[BigFloat alloc] initWithDouble:0.5 radix:bf_radix];
			BigFloat *minusHalf = [[BigFloat alloc] initWithDouble:-0.5 radix:bf_radix];
			
			// To speed convergeance, for x >= 0.5, let asin(x) = pi/2-2*asin(sqrt((1-x)/2))
			if ([self compareWith:half] == NSOrderedDescending)
			{
				[self appendDigit:L'-' useComplement:0];
				[self add:one];
				[self divideBy:two];
				[self sqrt];
				arcsinShift = YES;
			}
			if ([self compareWith:minusHalf] == NSOrderedAscending)
			{
				signChange = YES;
				[self add: one];
				[self divideBy: two];
				[self sqrt];
				arcsinShift = YES;
			}
			
			[half release];
			[minusHalf release];
			
			prevIteration = [zero copy];
			factorial = [one copy];
			original = [self copy];
			powerCopy = [self copy];
			nextTerm = [self copy];
			
			i = 1;
			while([self compareWith: prevIteration] != NSOrderedSame)
			{
				BigFloat *twoN;
				BigFloat *twoNMinusOne;
				BigFloat *twoNPlusOne;

				// Get a copy of the current value so that we can see if it changes
				[prevIteration assign: self];
		
				// Determine the next term of the series
				[powerCopy multiplyBy: original];
				[powerCopy multiplyBy: original];
				twoN = [[BigFloat alloc] initWithInt: (i * 2) radix:bf_radix];
				twoNMinusOne = [[BigFloat alloc] initWithInt:(i * 2 - 1) radix:bf_radix];
				[factorial multiplyBy:twoNMinusOne];
				[factorial divideBy:twoN];
				[twoN release];
				[twoNMinusOne release];
				
				[nextTerm assign:powerCopy];
				twoNPlusOne = [[BigFloat alloc] initWithInt:(i * 2 + 1) radix:bf_radix];
				[nextTerm divideBy:twoNPlusOne];
				[nextTerm multiplyBy:factorial];
				[twoNPlusOne release];
				
				if ([nextTerm isValid])
					[self add:nextTerm];
				
				i++;
			}
			
			if (arcsinShift == YES)
			{
				if (pi_array[bf_radix] == nil)
					[self calculatePi];
				[self multiplyBy:four];
				[self appendDigit:L'-' useComplement:0];
				[self add: pi_array[bf_radix]];
				[self divideBy:two];
			}
			
			if (signChange == YES)
				[self appendDigit:L'-' useComplement:0];
			
			if (pi_array[bf_radix] == nil)
				[self calculatePi];

			// Check that accurracy hasn't caused something illegal
			[original assign: pi_array[bf_radix]];
			[original divideBy:two];
			if ([self compareWith: original] == NSOrderedDescending)
				[self assign: original];
			[original appendDigit:L'-' useComplement:0];
			if ([self compareWith: original] == NSOrderedAscending)
				[self assign: original];

			if (mode != BF_radians)
			{
				if (mode == BF_degrees)
				{
					BigFloat *oneEighty = [[BigFloat alloc] initWithInt: 180 radix: bf_radix];
					[self multiplyBy:oneEighty];
					[oneEighty release];
				}
				else if (mode == BF_gradians)
				{
					BigFloat *twoHundred = [[BigFloat alloc] initWithInt: 200 radix: bf_radix];
					[self multiplyBy:twoHundred];
					[twoHundred release];
				}
		
				[self divideBy: pi_array[bf_radix]];
			}
		}

		[prevIteration release];
		[powerCopy release];
		[nextTerm release];
		[factorial release];
		[original release];
	}
	else	// hyperbolic sine
	{
		if (useInverse == NO)
		{
			original = [self copy];
			[original powerOfE];
			[self appendDigit:L'-' useComplement:0];
			[self powerOfE];
			[original subtract:self];
			[original divideBy:two];
			[self assign: original];
		}
		else // inverse hyerbolic sine
		{
			original = [self copy];
			[self multiplyBy: self];
			[self add:one];
			[self sqrt];
			[original add: self];
			[original ln];
			[self assign: original];
		}
		
		[original release];
	}

	[one release];
	[two release];
	[zero release];
	[four release];
}

//
// cosWithTrigMode
//
// Really this is four different functions in one:
//		cos, arccos, hypcos and hyparccos
//
- (void)cosWithTrigMode: (BFTrigMode)mode inv: (BOOL)useInverse hyp: (BOOL)useHyp
{
	unsigned long		values[BF_num_values];
	unsigned long		otherNum[BF_num_values];
	BigFloatElements	thisNumElements;
	BigFloatElements	otherNumElements;
	BigFloat				*prevIteration;
	BigFloat				*powerCopy;
	BigFloat				*nextTerm;
	BigFloat				*factorial;
	BigFloat				*original;
	BigFloat				*value;
	BigFloat				*one;
	BigFloat				*two;
	BigFloat				*zero;
	unsigned long	i;
	
	if (!bf_is_valid)
		return;

	one = [[BigFloat alloc] initWithInt:1 radix: bf_radix];
	two = [[BigFloat alloc] initWithInt:2 radix: bf_radix];
	zero = [[BigFloat alloc] initWithInt:0 radix: bf_radix];

	if (useHyp == NO)
	{
		if (useInverse == NO)
		{
			if (pi_array[bf_radix] == nil)
				[self calculatePi];

			if (mode != BF_radians)
			{
				
				if (mode == BF_degrees)
				{
					BigFloat *oneEighty = [[BigFloat alloc] initWithInt: 180 radix: bf_radix];
					BigFloat *threeSixty = [[BigFloat alloc] initWithInt: 360 radix: bf_radix];
					[self divideBy:oneEighty];
					[self moduloBy:threeSixty];
					[oneEighty release];
					[threeSixty release];
				}
				else if (mode == BF_gradians)
				{
					BigFloat *twoHundred = [[BigFloat alloc] initWithInt: 200 radix: bf_radix];
					BigFloat *fourHundred = [[BigFloat alloc] initWithInt: 400 radix: bf_radix];
					[self divideBy:twoHundred];
					[self moduloBy:fourHundred];
					[twoHundred release];
					[fourHundred release];
				}
				
				[self multiplyBy: pi_array[bf_radix]];
			}
			else
			{
				BigFloat *two_pi = [[BigFloat alloc] initWithInt:2 radix: bf_radix];
				[two_pi multiplyBy:pi_array[bf_radix]];
				[self moduloBy:two_pi];
				[two_pi release];
			}
			
			prevIteration = [zero copy];
			factorial = [one copy];
			original = [self copy];
			powerCopy = [factorial copy];
			nextTerm = [factorial copy];
			
			[self assign: factorial];
			
			i = 1;
			while([self compareWith: prevIteration] != NSOrderedSame)
			{
				BigFloat *twoN;
				BigFloat *twoNMinusOne;

				// Get a copy of the current value so that we can see if it changes
				[prevIteration assign: self];
		
				// Determine the next term of the series
				// Numerator is x^(2n)
				[powerCopy multiplyBy: original];
				[powerCopy multiplyBy: original];
				[nextTerm assign:powerCopy];
				
				// Divide the term by (2n)!
				twoN = [[BigFloat alloc] initWithInt: (i * 2) radix:bf_radix];
				twoNMinusOne = [[BigFloat alloc] initWithInt:(i * 2 - 1) radix:bf_radix];
				[factorial multiplyBy:twoN];
				[factorial multiplyBy:twoNMinusOne];
				[nextTerm divideBy: factorial];
				[twoN release];
				[twoNMinusOne release];
		
				// Add/subtract the next term if it is valid
				if ([nextTerm isValid])
				{
					if (i % 2 == 0)
						[self add: nextTerm];
					else
						[self subtract: nextTerm];
				}
				
				i++;
			}
			
			// Check that accurracy hasn't caused something illegal
			value = [self copy];
			[value abs];
			if ([value compareWith:one] == NSOrderedDescending)
			{
				[self divideBy:value];
			}
			
			// Normalise to remove built up error (makes a zero output possible)
			nextTerm = [[BigFloat alloc] initWithInt:10000 radix:bf_radix];
			BF_CopyValues(bf_array, values);
			[self copyElements: &thisNumElements];
			BF_CopyValues(nextTerm->bf_array, otherNum);
			[nextTerm copyElements: &otherNumElements];
			BF_NormaliseNumbers(values, otherNum, &thisNumElements, &otherNumElements);
			BF_AssignValues(bf_array, values);
			[self assignElements: &thisNumElements];
			[self createUserPoint];

			[prevIteration release];
			[powerCopy release];
			[nextTerm release];
			[factorial release];
			[original release];
			[value release];
		}
		else // Inverse cosine
		{
			// arccos = π/2 - arcsin
			original = [self copy];
			[original sinWithTrigMode: BF_radians inv: YES hyp: NO];
			if (pi_array[bf_radix] == nil)
				[self calculatePi];
			factorial = [pi_array[bf_radix] copy];
			[factorial divideBy:two];
			[factorial subtract: original];
			
			[self assign: factorial];
			
			if (mode != BF_radians)
			{
				if (mode == BF_degrees)
				{
					BigFloat *oneEighty = [[BigFloat alloc] initWithInt: 180 radix: bf_radix];
					[self multiplyBy:oneEighty];
					[oneEighty release];
				}
				else if (mode == BF_gradians)
				{
					BigFloat *twoHundred = [[BigFloat alloc] initWithInt: 200 radix: bf_radix];
					[self multiplyBy:twoHundred];
					[twoHundred release];
				}
		
				[self divideBy: pi_array[bf_radix]];
			}
			
			[original release];
			[factorial release];
		}
	}
	else	// hyperbolic cosine
	{
		if (useInverse == NO)
		{
			original = [self copy];
			[original powerOfE];
			bf_is_negative = (bf_is_negative == NO) ? YES : NO;
			[self powerOfE];
			[original add:self];
			[original divideBy:two];
			[self assign: original];
		}
		else // inverse hyerbolic cosine
		{
			original = [self copy];
			[self multiplyBy:self];
			[self subtract:one];
			[self sqrt];
			[original add: self];
			[original ln];
			[self assign:original];
		}
		
		[original release];
	}
	
	[zero release];
	[one release];
	[two release];
}

//
// tanWithTrigMode
//
// Really this is four different functions in one:
//		tan, arctan, hyptan and hyparctan
//
- (void)tanWithTrigMode: (BFTrigMode)mode inv: (BOOL)useInverse hyp: (BOOL)useHyp
{
	unsigned long		values[BF_num_values];
	unsigned long		otherNum[BF_num_values];
	BigFloatElements	thisNumElements;
	BigFloatElements	otherNumElements;
	BigFloat				*one;
	BigFloat				*two;
	BigFloat				*zero;
	BigFloat				*minusOne;
	BigFloat				*prevIteration;
	BigFloat				*powerCopy;
	BigFloat				*nextTerm;
	BigFloat				*factorial;
	BigFloat				*original;
	NSComparisonResult	compare;
	int						path;
	
	if (!bf_is_valid)
		return;

	one = [[BigFloat alloc] initWithInt:1 radix: bf_radix];
	two = [[BigFloat alloc] initWithInt:2 radix: bf_radix];
	zero = [[BigFloat alloc] initWithInt:0 radix: bf_radix];
	minusOne = [[BigFloat alloc] initWithInt:-1 radix: bf_radix];

	if (useHyp == NO)
	{
		if (useInverse == NO)
		{
			if (pi_array[bf_radix] == nil)
				[self calculatePi];

			if (mode != BF_radians)
			{
				
				if (mode == BF_degrees)
				{
					BigFloat *oneEighty = [[BigFloat alloc] initWithInt: 180 radix: bf_radix];
					BigFloat *threeSixty = [[BigFloat alloc] initWithInt: 360 radix: bf_radix];
					[self divideBy:oneEighty];
					[self moduloBy:threeSixty];
					[oneEighty release];
					[threeSixty release];
				}
				else if (mode == BF_gradians)
				{
					BigFloat *twoHundred = [[BigFloat alloc] initWithInt: 200 radix: bf_radix];
					BigFloat *fourHundred = [[BigFloat alloc] initWithInt: 400 radix: bf_radix];
					[self divideBy:twoHundred];
					[self moduloBy:fourHundred];
					[twoHundred release];
					[fourHundred release];
				}
				
				[self multiplyBy: pi_array[bf_radix]];
			}
			else
			{
				BigFloat *two_pi = [[BigFloat alloc] initWithInt:2 radix: bf_radix];
				[two_pi multiplyBy:pi_array[bf_radix]];
				[self moduloBy:two_pi];
				[two_pi release];
			}
			
			original = [self copy];
			[self sinWithTrigMode:BF_radians inv:NO hyp:NO];
			[original cosWithTrigMode:BF_radians inv:NO hyp:NO];
			[self divideBy:original];

			// Normalise to remove built up error (makes a zero output possible)
			nextTerm = [[BigFloat alloc] initWithInt:10000 radix:bf_radix];
			BF_CopyValues(bf_array, values);
			[self copyElements: &thisNumElements];
			BF_CopyValues(nextTerm->bf_array, otherNum);
			[nextTerm copyElements: &otherNumElements];
			BF_NormaliseNumbers(values, otherNum, &thisNumElements, &otherNumElements);
			BF_AssignValues(bf_array, values);
			[self assignElements: &thisNumElements];
			[self createUserPoint];
		}
		else // Inverse tangent
		{
			original = [self copy];
			powerCopy = [original copy];
			factorial = [one copy];
			nextTerm = [factorial copy];
			
			path = 1;
			compare = [original compareWith:one];
			if (compare == NSOrderedDescending)
			{
				path = 2;
			}
			else if (compare != NSOrderedSame)
			{
				compare = [original compareWith:minusOne];
				if (compare == NSOrderedAscending)
				{
					path = 3;
				}
			}
			else
			{
				if (pi_array[bf_radix] == nil)
					[self calculatePi];
	
				// tan-1(1) = pi/4
				[self assign:pi_array[bf_radix]];
				[self divideBy:two];
				[self divideBy:two];
				path = 4;
			}
			
			if (path == 1) // inverse tangent for |x| < 1
			{
				prevIteration = [one copy];
				
				while([self compareWith: prevIteration] != NSOrderedSame)
				{
					[prevIteration assign:self];
					
					[factorial add: two];
					[powerCopy multiplyBy:original];
					[powerCopy multiplyBy:original];
					[nextTerm assign:powerCopy];
					[nextTerm divideBy:factorial];
					
					if ([nextTerm isValid])
						[self subtract: nextTerm];

					[factorial add: two];
					[powerCopy multiplyBy:original];
					[powerCopy multiplyBy:original];
					[nextTerm assign:powerCopy];
					[nextTerm divideBy:factorial];
					
					if ([nextTerm isValid])
						[self add: nextTerm];
				}
			}
			else if (path != 4) // inverse tangent for |x| >= 1
			{
				// arctan = ((x>=1) * -1)π/2 - 1/x + 1/(3x^3) - 1/(5x^5) +...
				if (pi_array[bf_radix] == nil)
					[self calculatePi];
	
				// generate the (+/-) π/2
				[self assign:pi_array[bf_radix]];
				[self divideBy:two];
				if (path == 3)
					[self appendDigit:L'-' useComplement:0];
				prevIteration = [self copy];
				
				// Apply the first term
				[nextTerm assign:original];
				[nextTerm inverse];
				[self subtract: nextTerm];
	
				while([self compareWith: prevIteration] != NSOrderedSame)
				{
					[prevIteration assign: self];
					
					[powerCopy multiplyBy:original];
					[powerCopy multiplyBy:original];
					[factorial add:two];
					[nextTerm assign:factorial];
					[nextTerm multiplyBy:powerCopy];
					[nextTerm inverse];
					
					if ([nextTerm isValid])
						[self add: nextTerm];
					
					[powerCopy multiplyBy:original];
					[powerCopy multiplyBy:original];
					[factorial add:two];
					[nextTerm assign:factorial];
					[nextTerm multiplyBy:powerCopy];
					[nextTerm inverse];

					if ([nextTerm isValid])
						[self subtract: nextTerm];
				}
			}
			else
			{
				prevIteration = [self copy];
			}
			
			if (mode != BF_radians)
			{
				if (mode == BF_degrees)
				{
					BigFloat *oneEighty = [[BigFloat alloc] initWithInt: 180 radix: bf_radix];
					[self multiplyBy:oneEighty];
					[oneEighty release];
				}
				else if (mode == BF_gradians)
				{
					BigFloat *twoHundred = [[BigFloat alloc] initWithInt: 200 radix: bf_radix];
					[self multiplyBy:twoHundred];
					[twoHundred release];
				}
				
				if (pi_array[bf_radix] == nil)
					[self calculatePi];
				
				[self divideBy: pi_array[bf_radix]];
			}

			[prevIteration release];
			[powerCopy release];
			[factorial release];
		}
		[original release];
		[nextTerm release];
	}
	else	// hyperbolic tangent
	{
		if (useInverse == NO)
		{
			original = [self copy];
			[original cosWithTrigMode: BF_radians inv: NO hyp: YES];
			[self sinWithTrigMode: BF_radians inv: NO hyp: YES];
			[self divideBy: original];
		}
		else // inverse hyerbolic tangent
		{
			original = [self copy];
			[self add:one];
			[original appendDigit:L'-' useComplement:0];
			[original add:one];
			[self divideBy:original];
			[self ln];
			[self divideBy:two];
		}
		
		[original release];
	}
	
	[one release];
	[two release];
	[zero release];
	[minusOne release];
}

//
// factorial
//
// Calculates a factorial in the most basic way.
//
- (void)factorial
{
	BigFloat		*counter;
	BigFloat		*zero;
	BigFloat		*one;
	BigFloat		*fractional_part;
	
	if (!bf_is_valid)
		return;

	fractional_part = [self copy];
	[fractional_part fractionalPart];
	
	// Negative numbers have no factorial equivalent
	if (bf_is_negative == YES || ![fractional_part isZero])
	{
		bf_is_valid = NO;
		[fractional_part release];
		return;
	}
	[fractional_part release];

	zero = [[BigFloat alloc] initWithInt: 0 radix: bf_radix];
	one = [[BigFloat alloc] initWithInt: 1 radix: bf_radix];
	
	// Factorial zero is 1
	if ([self isZero])
	{
		[self assign: one];
	}
	else
	{
		// Copy this num and start subtracting down to one
		counter = [self copy];
		[counter subtract: one];
		
		// Perform the basic factorial
		while([counter compareWith: one] == NSOrderedDescending && bf_is_valid)
		{
			[self multiplyBy: counter];
			[counter subtract: one];
		}
		[self multiplyBy: counter];
		[counter subtract: one];
		
		[counter release];
	}

	[one release];
	[zero release];
}

//
// sum
//
// I'm not even certain why I implemented this. Calculates the sum of all integers up
// to and including the receiver.
//
- (void)sum
{
	BigFloat *self_plus_one;
	BigFloat *one;
	BigFloat *two;

	if (!bf_is_valid)
		return;

	one = [[BigFloat alloc] initWithInt:1 radix:bf_radix];
	two = [[BigFloat alloc] initWithInt:2 radix:bf_radix];

	self_plus_one = [self copy];
	[self_plus_one add:one];
	
	[self multiplyBy: self_plus_one];
	[self divideBy:two];
	
	[self_plus_one release];
	[one release];
	[two release];
}

//
// nPr
//
// Permutation of receiver samples made from a range of r options 
//
- (void)nPr: (BigFloat *)r
{
	BigFloat *self_minus_r;
	BigFloat *rCopy = [r copy];
	
	if (!bf_is_valid)
		return;

	if (![r isValid])
	{
		bf_is_valid = NO;
		return;
	}

	[self wholePart];
	[rCopy wholePart];
	
	if ([self compareWith:r] == NSOrderedAscending)
	{
		BigFloat *zero = [[BigFloat alloc] initWithInt:0 radix:bf_radix];
		
		[self assign:zero];
		[zero release];
		return;
	}

	self_minus_r = [self copy];
	[self_minus_r subtract: rCopy];
	
	[self factorial];
	[self_minus_r factorial];
	[self divideBy: self_minus_r];
	
	[self_minus_r release];
	[rCopy release];
}

//
// nCr
//
// Calculates receiver combinations of samples taken from a choice of r candidates.
//
- (void)nCr: (BigFloat *)r
{
	BigFloat *self_minus_r;
	BigFloat *r_factorial;
	BigFloat *rCopy = [r copy];
	
	if (!bf_is_valid)
		return;

	if (![r isValid])
	{
		bf_is_valid = NO;
		return;
	}

	[self wholePart];
	[rCopy wholePart];
	
	if ([self compareWith:r] == NSOrderedAscending)
	{
		BigFloat *zero = [[BigFloat alloc] initWithInt:0 radix:bf_radix];
		
		[self assign:zero];
		[zero release];
		return;
	}

	self_minus_r = [self copy];
	[self_minus_r subtract: rCopy];
	r_factorial = [rCopy copy];
	
	[r_factorial factorial];
	[self factorial];
	[self_minus_r factorial];
	[self divideBy: self_minus_r];
	[self divideBy: r_factorial];

	[r_factorial release];
	[self_minus_r release];
	[rCopy release];
}

//
// exp3Up
//
// Increases the exponent to the next number divisible by 3. Shifts the user point left
// by the same amount that exponent moves.
//
- (void)exp3Up
{
	int 		difference;
	BigFloat	*revertCopy;
	
	if (!bf_is_valid)
		return;
	
	revertCopy = [self copy];
	
	difference = bf_exponent % 3;
	
	if (difference < 0)
		difference = 3 + difference;
	else if (difference > 0)
		difference = 3 - difference;
	
	bf_user_point += 3 - difference;
	bf_exponent += 3 - difference;

	if (bf_user_point > bf_value_precision * BF_num_values - 1)
	{
		int i;
		
		for (i = bf_value_precision * BF_num_values - 2; i < bf_user_point; i++)
		{
			BF_RemoveDigitFromMantissa(bf_array, bf_radix, bf_value_limit, 1);
		}
		bf_user_point = bf_value_precision * BF_num_values - 1;
	}
	
	while (bf_user_point > 0 && (bf_array[0] % bf_radix) == 0)
	{
		BF_RemoveDigitFromMantissa(bf_array, bf_radix, bf_value_limit, 1);
		bf_user_point--;
	}
	
	if ([self isZero])
	{
		[self assign:revertCopy];
	}
	
	[revertCopy release];
}

//
// exp3Down
//
// Decreases the exponent to the next number divisible by 3. Shifts the user point right
// by the same amount that exponent moves.
//
- (void)exp3Down:(int)displayDigits
{
	int difference;
	int bf_user_point_copy = bf_user_point;
	
	if (!bf_is_valid)
		return;
	
	difference = bf_exponent % 3;
	
	if (difference < 0)
		difference = -difference;
	
	bf_user_point_copy -= 3 - difference;

	if ([self mantissaLength] - bf_user_point_copy > displayDigits)
		return;

	bf_exponent -= 3 - difference;

	if
	(
		bf_user_point_copy < 0
	)
	{
		if (	-bf_user_point_copy < bf_value_precision * BF_num_values - 1 - [self mantissaLength])
		{
			int i;
			
			for (i = 0; i < -bf_user_point_copy; i++)
			{
				BF_AppendDigitToMantissa(bf_array, 0, bf_radix, bf_value_limit, 1);
			}
			bf_user_point_copy = 0;
		}
		else
		{
			bf_user_point_copy += 3 - difference;
			bf_exponent += 3 - difference;
		}
	}
	
	bf_user_point = bf_user_point_copy;
}

//
// fractionalPart
//
// 
// Sets the receiver to the receiver modulo 1.
//
- (void)fractionalPart
{
	BigFloat	*one;
	
	if (!bf_is_valid)
		return;

	one = [[BigFloat alloc] initWithInt:1 radix:bf_radix];
	
	[self moduloBy: one];
	[one release];
}

//
// wholePart
//
// Sets the receiver to (receiver - (receiver modulo 1))
//
- (void)wholePart
{
	BigFloat	*fractionalPart;
	BigFloat	*one;
	BOOL		isNegative;
	
	if (!bf_is_valid)
		return;

	isNegative = bf_is_negative;
	bf_is_negative = NO;
	
	fractionalPart = [self copy];
	one = [[BigFloat alloc] initWithInt:1 radix:bf_radix];
	
	[fractionalPart moduloBy: one];
	[self subtract: fractionalPart];
	
	[one release];
	[fractionalPart release];
	
	bf_is_negative = isNegative;
}

//
// bitnot
//
// Set the receiver to ~receiver
//
- (void)bitnot
{
	int					digit;
	int					index;
	unsigned long	offset;
	int					old_radix;
	
	if (!bf_is_valid)
		return;

	// Convert to a radix that is a power of 2
	old_radix = bf_radix;
	if (bf_radix != 2 && bf_radix != 4 && bf_radix != 8 && bf_radix != 16 && bf_radix != 32)
	{
		// Convert to the largest possible binary compatible radix
		[self convertToRadix: 32];
	}
	
	// look for the first digit
	digit = BF_num_values * bf_value_precision - 1;
	index = digit / bf_value_precision;
	offset = pow(bf_radix, digit % bf_value_precision);
	while (bf_array[index] / offset == 0 && digit >= 0)
	{
		digit--;
		index = digit / bf_value_precision;
		offset = pow(bf_radix, digit % bf_value_precision);
	}
	
	// apply a binary NOT to each digit
	while (digit >= 0)
	{
		unsigned long this_digit;
		
		this_digit = (bf_array[index] / offset) % bf_radix;
		bf_array[index] -= this_digit * offset;
		this_digit = (~this_digit) % bf_radix;
		bf_array[index] += this_digit * offset;
		
		digit--;
		index = digit / bf_value_precision;
		offset = pow(bf_radix, digit % bf_value_precision);
	}
	
	// Restore the radix
	if (old_radix != bf_radix)
		[self convertToRadix: old_radix];
}

//
// andWith
//
// receiver = receiver & num
//
- (void)andWith: (BigFloat*)num
{
	int					digit;
	int					index;
	unsigned long	offset;
	unsigned long	otherValues[BF_num_values];
	int					old_radix;
	BigFloat			*otherNum;
	
	if (!bf_is_valid)
		return;

	if (![num isValid])
	{
		bf_is_valid = NO;
		return;
	}

	otherNum = [num copy];
	
	// Convert to a radix that is a power of 2
	old_radix = bf_radix;
	if (bf_radix != 2 && bf_radix != 4 && bf_radix != 8 && bf_radix != 16 && bf_radix != 32)
	{
		// Convert to the largest possible binary compatible radix
		[self convertToRadix: 32];
	}
	[otherNum convertToRadix: bf_radix];
	BF_CopyValues(otherNum->bf_array, otherValues);
	
	// look for the first digit
	digit = BF_num_values * bf_value_precision - 1;
	index = digit / bf_value_precision;
	offset = pow(bf_radix, digit % bf_value_precision);
	while (bf_array[index] / offset == 0 && otherValues[index] / offset == 0 && digit >= 0)
	{
		digit--;
		index = digit / bf_value_precision;
		offset = pow(bf_radix, digit % bf_value_precision);
	}
	
	// apply a binary AND to each digit
	while (digit >= 0)
	{
		unsigned long this_digit;
		unsigned long that_digit;
		
		this_digit = (bf_array[index] / offset) % bf_radix;
		that_digit = (otherValues[index] / offset) % bf_radix;
		bf_array[index] -= this_digit * offset;
		this_digit = (this_digit & that_digit) % bf_radix;
		bf_array[index] += this_digit * offset;
		
		digit--;
		index = digit / bf_value_precision;
		offset = pow(bf_radix, digit % bf_value_precision);
	}
	
	// Restore the radix
	[self convertToRadix: old_radix];
	
	[otherNum release];
}

//
// andWith
//
// receiver = receiver | num
//
- (void)orWith: (BigFloat*)num
{
	int					digit;
	int					index;
	unsigned long	offset;
	unsigned long	otherValues[BF_num_values];
	int					old_radix;
	BigFloat			*otherNum;
	
	if (!bf_is_valid)
		return;

	if (![num isValid])
	{
		bf_is_valid = NO;
		return;
	}

	otherNum = [num copy];
	
	// Convert to a radix that is a power of 2
	old_radix = bf_radix;
	if (bf_radix != 2 && bf_radix != 4 && bf_radix != 8 && bf_radix != 16 && bf_radix != 32)
	{
		// Convert to the largest possible binary compatible radix
		[self convertToRadix: 32];
	}
	[otherNum convertToRadix: bf_radix];
	BF_CopyValues(otherNum->bf_array, otherValues);
	
	// look for the first digit
	digit = BF_num_values * bf_value_precision - 1;
	index = digit / bf_value_precision;
	offset = pow(bf_radix, digit % bf_value_precision);
	while (bf_array[index] / offset == 0 && otherValues[index] / offset == 0 && digit >= 0)
	{
		digit--;
		index = digit / bf_value_precision;
		offset = pow(bf_radix, digit % bf_value_precision);
	}
	
	// apply a binary OR to each digit
	while (digit >= 0)
	{
		unsigned long this_digit;
		unsigned long that_digit;
		
		this_digit = (bf_array[index] / offset) % bf_radix;
		that_digit = (otherValues[index] / offset) % bf_radix;
		bf_array[index] -= this_digit * offset;
		this_digit = (this_digit | that_digit) % bf_radix;
		bf_array[index] += this_digit * offset;
		
		digit--;
		index = digit / bf_value_precision;
		offset = pow(bf_radix, digit % bf_value_precision);
	}
	
	// Restore the radix
	if (old_radix != bf_radix)
		[self convertToRadix: old_radix];

	[otherNum release];
}

//
// andWith
//
// receiver = receiver ^ num
//
- (void)xorWith: (BigFloat*)num
{
	int					digit;
	int					index;
	unsigned long	offset;
	unsigned long	otherValues[BF_num_values];
	int					old_radix;
	BigFloat			*otherNum;
	
	if (!bf_is_valid)
		return;

	if (![num isValid])
	{
		bf_is_valid = NO;
		return;
	}

	otherNum = [num copy];
	
	// Convert to a radix that is a power of 2
	old_radix = bf_radix;
	if (bf_radix != 2 && bf_radix != 4 && bf_radix != 8 && bf_radix != 16 && bf_radix != 32)
	{
		// Convert to the largest possible binary compatible radix
		[self convertToRadix: 32];
	}
	[otherNum convertToRadix: bf_radix];
	BF_CopyValues(otherNum->bf_array, otherValues);
	
	// look for the first digit
	digit = BF_num_values * bf_value_precision - 1;
	index = digit / bf_value_precision;
	offset = pow(bf_radix, digit % bf_value_precision);
	while (bf_array[index] / offset == 0 && otherValues[index] / offset == 0 && digit >= 0)
	{
		digit--;
		index = digit / bf_value_precision;
		offset = pow(bf_radix, digit % bf_value_precision);
	}
	
	// apply a binary XOR to each digit
	while (digit >= 0)
	{
		unsigned long this_digit;
		unsigned long that_digit;
		
		this_digit = (bf_array[index] / offset) % bf_radix;
		that_digit = (otherValues[index] / offset) % bf_radix;
		bf_array[index] -= this_digit * offset;
		this_digit = (this_digit ^ that_digit) % bf_radix;
		bf_array[index] += this_digit * offset;
		
		digit--;
		index = digit / bf_value_precision;
		offset = pow(bf_radix, digit % bf_value_precision);
	}
	
	// Restore the radix
	if (old_radix != bf_radix)
		[self convertToRadix: old_radix];

	[otherNum release];
}


#pragma mark
#pragma mark ##### Accessor Functions #####

//
// doubleValue
//
// Returns the approximate value of the receiver as a double
//
- (double)doubleValue
{
	double	retVal;
	long long	currentValue;
	int		i, j, digit;
	
	// Return NaN if number is not valid
	if (bf_is_valid == NO)
		return (double)1/(double)0;
	
	// Extract all the digits out and put them in the double
	retVal = 0;
	for (i = BF_num_values - 1; i >= 0; i--)
	{
		currentValue = bf_array[i];
		for (j = bf_value_precision - 1; j >= 0; j--)
		{
			digit = (currentValue / (long long)pow(bf_radix, j)) % bf_radix;
			retVal = (retVal * bf_radix) + digit;
		}
	}
	
	// Apply the sign
	if (bf_is_negative == YES)
		retVal *= -1;
	
	// Apply the exponent
	retVal *= pow(bf_radix, bf_exponent - bf_user_point);
			
	return retVal;
}

//
// mantissaString
//
// Returns the mantissa of the receiver as a string.
//
- (NSString*)mantissaString
{
	NSString* mantissa;
	NSString* exponent;
	
	 [self limitedString:BF_num_values * bf_value_precision fixedPlaces:0 fillLimit:NO complement:0 mantissa:&mantissa exponent:&exponent];
	 
	 return mantissa;
}

//
// exponentStringFromInt
//
// Interprets the given int as an exponent and formats it as a string. Why did I do this?
//
- (NSString*)exponentStringFromInt:(int)exp
{
	signed int			workingExponent = exp;
	BOOL				exponentIsNegative = NO;
	unichar				digits[BF_max_exponent_length];
	unichar				*returnString;
	int					currentPosition = BF_max_exponent_length - 1;
							// index of the end of the string
	int					lastNonZero = currentPosition;
	
	if (workingExponent == 0)
	{
		return @"";
	}
	
	// Check for a negative exponent
	if (workingExponent < 0)
	{
		workingExponent *= -1;
		exponentIsNegative = YES;
	}
	
	// Work right to left and fill in the digits
	while(currentPosition > (BF_max_exponent_length - bf_exponent_precision - 2))
	{
		digits[currentPosition] = [BF_digits characterAtIndex:(workingExponent % bf_radix)];
		
		// Keep checking for the leftmost non-zero digit
		if (digits[currentPosition] != L'0')
			lastNonZero = currentPosition;
		
		workingExponent /= bf_radix;
		currentPosition--;
	}
	
	// If all the digits were zeros, force the display of at least one zero
	if (lastNonZero == BF_max_exponent_length)
		lastNonZero--;
	
	// Don't display any superfluous leading zeros
	returnString = digits + lastNonZero;
	
	// Apply the sign
	if (exponentIsNegative)
	{
		returnString--;
		returnString[0] = L'-';
	}
	
	// Return the string
	return [NSString stringWithCharacters:returnString length:&digits[BF_max_exponent_length] - returnString];
}

//
// exponentString
//
// Returns the exponent of the receiver formatted as a string
//
- (NSString*)exponentString
{
	// Check to see if the exponent exists
	if (!bf_is_valid)
	{
		// Return an empty string instead of nil because its a little safer
		return @"";
	}
	
	return [self exponentStringFromInt:bf_exponent];
}

//
// toString
//
// Returns an approximate string representation of the receiver
//
- (NSString*)toString
{
	NSString	*mantissa;
	
	// Get the mantissa string
	mantissa = [self mantissaString];
	
	// Append the exponent string
	if (bf_exponent != 0)
	{
		mantissa = [[mantissa stringByAppendingString: @"e"] stringByAppendingString: [self exponentString]];
	}
	
	return mantissa;
}

//
// toShortString
//
// Returns a very short approximate value of the receiver as a double
//
- (NSString*)toShortString:(int)precision
{
	NSString	*string;
	NSString	*exponent;

	// Get the string pieces
	[self limitedString:4 fixedPlaces:0 fillLimit:NO complement:0 mantissa:&string exponent:&exponent];
	
	// Append the exponent string
	if ([exponent length] != 0)
	{
		string = [[string stringByAppendingString: @"e"] stringByAppendingString:exponent];
	}
	
	return string;
}

//
// limitedString
//
// Returns the mantissa and exponent of the receiver as strings with specific formatting
// according to the information provided.
//
- (void)limitedString:(unsigned int)lengthLimit fixedPlaces:(unsigned int)places fillLimit:(BOOL)fill complement:(unsigned int)complement mantissa:(NSString**)mantissaOut exponent:(NSString**)exponentOut
{
	unichar				digits[BF_max_mantissa_length];
	unichar				*currentChar;
	unsigned long		carryBits;
	unsigned long 		values[BF_num_values];
	int					digitsInNumber;
	int					i;
	int					exponentCopy;
	int					userPointCopy;
	unichar				nextDigit;
	int					zeros = 0;
	NSString			*point = [[NSUserDefaults standardUserDefaults] objectForKey:NSDecimalSeparator];	
	
	// Handle the "not-a-number" case
	if (!bf_is_valid)
	{
		*mantissaOut = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Not a number" value:nil table:nil];
		*exponentOut = @"";
		return;
	}
	
	// Limit the length of the output string
	if (lengthLimit > BF_num_values * bf_value_precision)
	{
		lengthLimit = BF_num_values * bf_value_precision;
	}
	if (lengthLimit < 2)
	{
		// Leave at least room for 2 digits and a decimal point
		lengthLimit = 2;
	}
	if (places < 0)
		places = 0;
	if (places > lengthLimit - 1)
		places = lengthLimit - 1;
	
	// Trace through the number looking the the most significant non-zero digit
	digitsInNumber = [self mantissaLength];

	// Copy the values
	BF_CopyValues(bf_array, values);
	exponentCopy = bf_exponent;
	userPointCopy = bf_user_point;
	
	// Ensure that we don't have too many leading zeros
	if (userPointCopy + 2 > lengthLimit + digitsInNumber)
	{
		bf_exponent -= (userPointCopy - (lengthLimit + digitsInNumber)) + 2;
		exponentCopy -= (userPointCopy - (lengthLimit + digitsInNumber)) + 2;

		bf_user_point -= (userPointCopy - (lengthLimit + digitsInNumber)) + 2;
		userPointCopy -= (userPointCopy - (lengthLimit + digitsInNumber)) + 2;
		
		if (exponentCopy < 0 && userPointCopy >= digitsInNumber)
		{
			bf_exponent -= userPointCopy - digitsInNumber + 1;
			exponentCopy -= userPointCopy - digitsInNumber + 1;

			bf_user_point -= userPointCopy - digitsInNumber + 1;
			userPointCopy -= userPointCopy - digitsInNumber + 1;
		}
	}
	
	// Handle a fixed number of decimal places
	if (places != 0)
	{
		exponentCopy += places- userPointCopy;
		userPointCopy = places;
		
		// If there is not enough room to display the number in the current fixed precision, bail out
		if (digitsInNumber + exponentCopy > lengthLimit)
		{
			*mantissaOut = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Value Exceeds Precision" value:nil table:nil];
			*exponentOut = @"";
			return;
		}
		
		// Result is zero
		if (digitsInNumber + exponentCopy <= 0 || digitsInNumber == 0)
		{
			int d = 0;
			
			digits[0] = L'0';
			while (d < [point length])
			{
				digits[1 + d] = [point characterAtIndex:d];
				d++;
			}
			for (i = 1 + d; i < places + 2; i++)
			{
				digits[i] = L'0';
			}

			*mantissaOut = [NSString stringWithCharacters:digits length:places + 2];
			*exponentOut = @"";
			return;
		}
		
		// Too many digits so strip them back
		carryBits = 0;
		while (exponentCopy < 0)
		{
			carryBits = BF_RemoveDigitFromMantissa(values, bf_radix, bf_value_limit, 1);
			exponentCopy++;
			digitsInNumber--;
		}
		
		// Apply round to nearest
		if ((double)carryBits >= ((double)bf_radix / 2.0))
		{
			BF_AddToMantissa(values, 1, bf_value_limit, 1);
			
			// In the incredibly unlikely case that this rounding increases the number of digits
			// in the number past the precision, then bail out.
			if (values[BF_num_values - 1] / bf_value_limit != 0)
			{
				*mantissaOut = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Value Exceeds Precision" value:nil table:nil];
				*exponentOut = @"";
				return;
			}
		}
		
		// Not enough digits so pad them out
		while (exponentCopy > 0)
		{
			BF_AppendDigitToMantissa(values, 0, bf_radix, bf_value_limit, 1);
			exponentCopy--;
			digitsInNumber++;
		}
		
		if (digitsInNumber > lengthLimit)
		{
			*mantissaOut = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Value Exceeds Precision" value:nil table:nil];
			*exponentOut = @"";
			return;
		}
	}
	else if (digitsInNumber == 0)
	{
		// If there are no non-zero digits, return a zero string
		*mantissaOut = @"0";
		*exponentOut = [self exponentStringFromInt:exponentCopy];
		return;
	}
	else if (digitsInNumber > lengthLimit || (userPointCopy + 1 > (signed)lengthLimit))
	{
		// If we have more digits than we can display, truncate the values
		carryBits = 0;
		while(digitsInNumber > (signed)lengthLimit || (userPointCopy + 1 > (signed)lengthLimit))
		{
			carryBits = BF_RemoveDigitFromMantissa(values, bf_radix, bf_value_limit, 1);

			digitsInNumber--;
			if (userPointCopy > 0)
				userPointCopy--;
			else
				exponentCopy++;
			
			// If all we removed was a zero, then remove it completely from the number
			if (carryBits == 0)
			{
				BF_RemoveDigitFromMantissa(bf_array, bf_radix, bf_value_limit, 1);
	
				if (bf_user_point > 0)
					bf_user_point--;
				else
					bf_exponent++;
			}
		}
	
		// Apply round to nearest
		if ((double)carryBits >= ((double)bf_radix / 2.0))
		{
			BF_AddToMantissa(values, 1, bf_value_limit, 1);
			
			// If by shear fluke that cause the top digit to overflow, then shift back by one digit
			if (values[BF_num_values - 1] / bf_value_limit != 0)
			{
				BF_RemoveDigitFromMantissa(values, bf_radix, bf_value_limit, 1);

				if (userPointCopy > 0)
					userPointCopy--;
				else
					exponentCopy++;
			}
			
			// We may have changed the number of digits... recount
			digitsInNumber = BF_NumDigitsInArray(values, bf_radix, bf_value_precision);
		}
	}
	
	// Scientific notation weirdisms
	if (fill && places == 0)
	{
		int diff = (digitsInNumber - 1) - userPointCopy;
		userPointCopy += diff;
		exponentCopy += diff;

		// Not enough digits so pad them out
		while (digitsInNumber < lengthLimit)
		{
			BF_AppendDigitToMantissa(values, 0, bf_radix, bf_value_limit, 1);
			digitsInNumber++;
			userPointCopy++;
		}
	}
	
	// Handle stuff related to negative numbers
	currentChar = digits;
	if (complement > 0)
	{
		BigFloat				*complementNumber;
		BigFloat				*mantissaNumber;
		unsigned long long	complementBits = ((unsigned long long)1 << (unsigned long long)(complement - 1));
		
		complementNumber = [[BigFloat alloc] initWithMantissa:complementBits exponent:0 isNegative:0 radix:bf_radix userPointAt:0];
		mantissaNumber = [complementNumber copy];
		BF_AssignValues(mantissaNumber->bf_array, values);
		
		carryBits = 0;
		while
		(
			(
				[mantissaNumber compareWith:complementNumber] == NSOrderedDescending
				||
				(
					[mantissaNumber compareWith:complementNumber] == NSOrderedSame
					&&
					!bf_is_negative
				)
			)
			&&
			![mantissaNumber isZero]
		)
		{
			carryBits = BF_RemoveDigitFromMantissa(mantissaNumber->bf_array, bf_radix, bf_value_limit, 1);

			if (userPointCopy > 0)
				userPointCopy--;
			else
				exponentCopy++;
		}
		// Apply round to nearest
		if ((double)carryBits >= ((double)bf_radix / 2.0))
		{
			BF_AddToMantissa(mantissaNumber->bf_array, 1, bf_value_limit, 1);
			
			// If by shear fluke that cause the top digit to overflow, then shift back by one digit
			if (values[BF_num_values - 1] / bf_value_limit != 0)
			{
				BF_RemoveDigitFromMantissa(mantissaNumber->bf_array, bf_radix, bf_value_limit, 1);

				if (userPointCopy > 0)
					userPointCopy--;
				else
					exponentCopy++;
			}
		}
		if
		(
			[mantissaNumber compareWith:complementNumber] == NSOrderedDescending
			||
			(
				[mantissaNumber compareWith:complementNumber] == NSOrderedSame
				&&
				!bf_is_negative
			)
		)
		{
			*mantissaOut = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Value Exceeds Precision" value:nil table:nil];
			*exponentOut = @"";
			[complementNumber release];
			[mantissaNumber release];
			return;
		}
		
		if (bf_is_negative)
		{
			BigFloat *two = [[BigFloat alloc] initWithMantissa:2 exponent:0 isNegative:0 radix:bf_radix userPointAt:0];
			[complementNumber multiplyBy:two];
			[two release];
			[complementNumber subtract:mantissaNumber];
			BF_CopyValues(complementNumber->bf_array, values);
			digitsInNumber = [complementNumber mantissaLength];
		}
		else
		{
			BF_CopyValues(mantissaNumber->bf_array, values);
			digitsInNumber = [mantissaNumber mantissaLength];
		}
		
		[complementNumber release];
		[mantissaNumber release];
	}
	else if (bf_is_negative)
	{
		*currentChar = L'-';
		currentChar++;
	}
	
	// Write any leading zeros to the string
	if (userPointCopy >= digitsInNumber)
	{
		*currentChar = L'0';
		currentChar++;
		
		if (userPointCopy - digitsInNumber > 0)
		{
			int d = 0;
			
			while (d < [point length])
			{
				*currentChar++ = [point characterAtIndex:d];
				d++;
			}
		}

		for (i = 0; i < userPointCopy - digitsInNumber; i++)
		{
			*currentChar = L'0';
			currentChar++;
		}
	}
	
	// Write the digits out to the string
	digitsInNumber--;
	while(digitsInNumber >= 0)
	{
		nextDigit = [BF_digits characterAtIndex:((int)(values[digitsInNumber / bf_value_precision] / pow(bf_radix, digitsInNumber % bf_value_precision)) % bf_radix)];
		
		if (userPointCopy <= digitsInNumber)
		{
			if (userPointCopy != 0 && userPointCopy == (digitsInNumber + 1))
			{
				int d = 0;
				
				while (d < [point length])
				{
					*currentChar++ = [point characterAtIndex:d];
					d++;
				}
			}

			*currentChar = nextDigit;
			currentChar++;
		}
		else if (nextDigit == L'0' && !fill && complement == 0 && userPointCopy > digitsInNumber)
		{
			zeros++;
		}
		else
		{
			if (userPointCopy != 0 && userPointCopy == (digitsInNumber + 1 + zeros))
			{
				int d = 0;
				
				while (d < [point length])
				{
					*currentChar++ = [point characterAtIndex:d];
					d++;
				}
			}

			for (i = 0; i < zeros; i++)
			{
				*currentChar = L'0';
				currentChar++;
			}
			*currentChar = nextDigit;
			currentChar++;
			zeros = 0;
		}
		
		digitsInNumber--;
	}
	
	*mantissaOut = [NSString stringWithCharacters:digits length:(currentChar - digits)];
	*exponentOut = [self exponentStringFromInt:exponentCopy];
}

//
// debugDisplay
//
// Copies the receiver as a string to standard out.
//
- (void)debugDisplay
{
	NSString	*stringValue;
	
	// Get the mantissa string
	stringValue = [self mantissaString];
	
	// Append the exponent string
	if ((bf_exponent - bf_user_point) != 0)
	{
		stringValue = [[stringValue stringByAppendingString: @"e"] stringByAppendingString: [self exponentString]];
	}
	
	printf("%s\n", [stringValue cString]);
}

@end
// ##############################################################
//  BigCFloat.h
//  BigFloat Implementation
//
//  Created by Matt Gallagher on Sat Apr 19 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "BigFloat.h"

//
// About BigCFloat
//
// BigCFloat extends the BigFloat implementation to span the complex domain.
// Not much more complicated than that.
//
// Unless you really want strictly real numbers I actually recommend you use this
// class instead of BigFloat as it smooths over a few glitches in the real domain
// Taylor Series for trigonometric functions. 
//

@interface BigCFloat : BigFloat {
	BigFloat	*bcf_imaginary;
	BOOL		bcf_has_imaginary;
}

// Constructors
- (id)init;
- (id)initWithReal:(BigFloat *)realPart imaginary:(BigFloat *)imaginaryPart;
- (id)initWithMagnitude:(BigFloat *)r angle:(BigFloat *)theta;
- (id)initWithInt:(signed int)newValue radix:(unsigned short)newRadix;
- (id)initWithDouble:(double)newValue radix:(unsigned short)newRadix;
- (id)initPiWithRadix:(unsigned short)newRadix;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone*)zone;

+ (BigCFloat*)bigFloatWithReal:(BigFloat *)realPart imaginary:(BigFloat *)imaginaryPart;
+ (BigCFloat*)bigFloatWithMagnitude:(BigFloat *)r angle:(BigFloat *)theta;
+ (BigCFloat*)bigFloatWithInt:(signed int)newValue radix:(unsigned short)newRadix;
+ (BigCFloat*)bigFloatWithDouble:(double)newValue radix:(unsigned short)newRadix;
+ (BigCFloat*)piWithRadix:(unsigned short)newRadix;

// Complex Functions
- (BigFloat *)realPartCopy;
- (BigFloat *)realPart;
- (BigFloat *)imaginaryPart;
- (BigFloat *)magnitude;
- (BigFloat *)angle;
- (void)conjugate;
- (BOOL)hasImaginary;
- (BOOL)imaginaryHasExponent;

// Public Utility Functions
- (BOOL)appendDigit: (short)digit useComplement:(int)complement;
- (void)appendExpDigit:(short)digit;
- (void)deleteDigit;
- (void)deleteExpDigit;
- (void)convertToRadix:(unsigned short)newRadix;
- (unsigned short)radix;
- (BOOL)isValid;
- (BOOL)isZero;
- (void)setUserPoint:(int)pointLocation;
- (int)getUserPoint;
- (NSComparisonResult)compareWith:(BigFloat*)num;
- (BigFloat*)duplicate;
- (void)assign:(BigFloat*)newValue;
- (void)abs;

// Arithmetic Functions
- (void)add:(BigFloat*)num;
- (void)subtract:(BigFloat*)num;
- (void)multiplyBy:(BigFloat*)num;
- (void)divideBy:(BigFloat*)num;
- (void)moduloBy:(BigFloat*)num;

// Extended Mathematics Functions
- (void)powerOfE;
- (void)ln;
- (void)raiseToPower:(BigFloat*)num;
- (void)sqrt;
- (void)inverse;
- (void)logOfBase:(BigFloat *)base;
- (void)sinWithTrigMode:(BFTrigMode)mode inv:(BOOL)useInverse hyp:(BOOL)useHyp;
- (void)cosWithTrigMode:(BFTrigMode)mode inv:(BOOL)useInverse hyp:(BOOL)useHyp;
- (void)tanWithTrigMode:(BFTrigMode)mode inv:(BOOL)useInverse hyp:(BOOL)useHyp;
- (void)factorial;
- (void)sum;
- (void)nPr: (BigFloat*)r;
- (void)nCr: (BigFloat*)r;
- (void)exp3Up;
- (void)exp3Down:(int)displayDigits;
- (void)wholePart;
- (void)fractionalPart;
- (void)bitnot;
- (void)andWith:(BigFloat*)num;
- (void)orWith:(BigFloat*)num;
- (void)xorWith:(BigFloat*)num;

// Accessor Functions
- (NSString*)imaginaryMantissaString;
- (NSString*)imaginaryExponentString;
- (NSString*)toString;
- (NSString*)toShortString:(int)precision;
- (void)limitedString:(unsigned int)lengthLimit fixedPlaces:(unsigned int)places fillLimit:(BOOL)fill complement:(unsigned int)complement mantissa:(NSString**)mantissaOut exponent:(NSString**)exponentOut imaginaryMantissa:(NSString**)imaginaryMantissaOut imaginaryExponent:(NSString**)imaginaryExponentOut;
- (void)debugDisplay;

@end
// ##############################################################
//  BigCFloat.m
//  BigFloat Implementation
//
//  Created by Matt Gallagher on Sat Apr 19 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "BigCFloat.h"

//
// About BigCFloat
//
// BigCFloat extends the BigFloat implementation to span the complex domain.
// Not much more complicated than that.
//
// Unless you really want strictly real numbers I actually recommend you use this
// class instead of BigFloat as it smooths over a few glitches in the real domain
// Taylor Series for trigonometric functions. 
//

@implementation BigCFloat

#pragma mark
#pragma mark ### Constructors ###
//
// init
//
// Wrapper that adds complex number support around the base class
//
- (id)init
{
	self = [super init];
	if (self)
	{
		bcf_imaginary = [[BigFloat alloc] init];
		bcf_has_imaginary = NO;
	}
	return self;
}

//
// dealloc
//
// Frees the imaginary part
//
- (void)dealloc
{
	// Release the imaginary part
	[bcf_imaginary release];
	[super dealloc];
}

//
// initWithReal
//
// Init real and imaginary parts. You can validly pass nil instead of zero.
//
- (id)initWithReal:(BigFloat *)realPart imaginary:(BigFloat *)imaginaryPart
{
	self = [super init];
	if (self)
	{
		if (!realPart)
			realPart = [[BigFloat alloc] initWithInt:0 radix:bf_radix];
		if (!imaginaryPart)
			imaginaryPart = [[BigFloat alloc] initWithInt:0 radix:bf_radix];

		[super assign:realPart];
		if ([imaginaryPart isKindOfClass:[BigCFloat class]])
		{
			BigCFloat *cnum = (BigCFloat *)imaginaryPart;
			bcf_imaginary = [cnum realPartCopy];
		}
		else
		{
			bcf_imaginary = [imaginaryPart copy];
		}
		bcf_has_imaginary = ![bcf_imaginary isZero];

		if ([bcf_imaginary radix] != bf_radix)
			[bcf_imaginary convertToRadix:bf_radix];
	}
	return self;
}

//
// initWithMagnitude
//
// Initialisation in polar coordinates.
//
- (id)initWithMagnitude:(BigFloat *)r angle:(BigFloat *)theta
{
	self = [super init];
	if (self)
	{
		BigFloat *realPart;
		BigFloat *imaginaryPart;

		if ([theta isKindOfClass:[BigCFloat class]])
		{
			BigCFloat *cnum = (BigCFloat *)theta;
			imaginaryPart = [cnum realPartCopy];
			realPart = [cnum realPartCopy];
		}
		else
		{
			imaginaryPart = [theta copy];
			realPart = [theta copy];
		}

		[realPart cosWithTrigMode:BF_radians inv:NO hyp:NO];
		[super assign:r];
		[super multiplyBy:realPart];
		
		[imaginaryPart sinWithTrigMode:BF_radians inv:NO hyp:NO];
		[imaginaryPart multiplyBy:r];
		bcf_imaginary = [[BigFloat alloc] init];
		[bcf_imaginary assign:imaginaryPart];
		
		if ([bcf_imaginary radix] != bf_radix)
			[bcf_imaginary convertToRadix:bf_radix];
		
		if ([imaginaryPart isZero])
			bcf_has_imaginary = NO;
		else
			bcf_has_imaginary = YES;
		
		[realPart release];
		[imaginaryPart release];
	}
	return self;
}

//
// initWithInt
//
// Wrapper that adds complex number support around the base class
//
- (id)initWithInt:(signed int)newValue radix:(unsigned short)newRadix
{
	self = [super initWithInt:newValue radix:newRadix];
	
	if (self)
	{
		bcf_imaginary = [[BigFloat alloc] initWithInt:0 radix:newRadix];
		bcf_has_imaginary = NO;
	}
	
	return self;
}

//
// initWithDouble
//
// Wrapper that adds complex number support around the base class
//
- (id)initWithDouble:(double)newValue radix:(unsigned short)newRadix
{
	self = [super initWithDouble:newValue radix:newRadix];
	
	if (self)
	{
		bcf_imaginary = [[BigFloat alloc] initWithInt:0 radix:newRadix];
		bcf_has_imaginary = NO;
	}
	
	return self;
}

//
// initPiWithRadix
//
// Wrapper that adds complex number support around the base class
//
- (id)initPiWithRadix:(unsigned short)newRadix
{
	self = [super initPiWithRadix:newRadix];
	
	if (self)
	{
		bcf_imaginary = [[BigFloat alloc] initWithInt:0 radix:newRadix];
		bcf_has_imaginary = NO;
	}
	
	return self;
}

//
// initWithCoder
//
// Wrapper that adds complex number support around the base class
//
- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	bcf_imaginary = [[coder decodeObjectForKey:@"BCFImaginary"] retain];
	bcf_has_imaginary = [coder decodeBoolForKey:@"BCFHasImaginary"];
	
	return self;
}

//
// encodeWithCoder
//
// Wrapper that adds complex number support around the base class
//
- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	[coder encodeObject:bcf_imaginary forKey:@"BCFImaginary"];
	[coder encodeBool:bcf_has_imaginary forKey:@"BCFHasImaginary"];
}

//
// copyWithZone
//
// Wrapper that adds complex number support around the base class
//
- (id)copyWithZone:(NSZone*)zone
{
	BigCFloat *copy;
	
	copy = [[BigCFloat allocWithZone:zone] init];
	[copy assign:self];
	[copy->bcf_imaginary assign:self->bcf_imaginary];
	copy->bcf_has_imaginary = self->bcf_has_imaginary;
	
	return copy;
}

//
// bigFloatWithReal
//
// Returns an autoreleased complex number initialised with given real and imaginary
//
+ (BigCFloat*)bigFloatWithReal:(BigFloat *)realPart imaginary:(BigFloat *)imaginaryPart
{
	return [[[BigCFloat alloc] initWithReal:realPart imaginary:imaginaryPart] autorelease];
}

//
// bigFloatWithMagnitude
//
// Returns an autoreleased complex number initialised with given polar coordinates
//
+ (BigCFloat*)bigFloatWithMagnitude:(BigFloat *)r angle:(BigFloat *)theta
{
	return [[[BigCFloat alloc] initWithMagnitude:r angle:theta] autorelease];
}

//
// bigFloatWithInt
//
// Wrapper that adds complex number support around the base class
//
+ (BigFloat*)bigFloatWithInt:(signed int)newValue radix:(unsigned short)newRadix
{
	return [[[BigCFloat alloc] initWithInt:newValue radix:newRadix] autorelease];
}

//
// bigFloatWithDouble
//
// Wrapper that adds complex number support around the base class
//
+ (BigFloat*)bigFloatWithDouble:(double)newValue radix:(unsigned short)newRadix
{
	return [[[BigCFloat alloc] initWithDouble:newValue radix:newRadix] autorelease];
}

//
// piWithRadix
//
// Wrapper that adds complex number support around the base class
//
+ (BigFloat*)piWithRadix:(unsigned short)newRadix
{
	return [[[BigCFloat alloc] initPiWithRadix:newRadix] autorelease];
}

#pragma mark
#pragma mark ### Complex Functions ###
//
// realPartCopy
//
// Returns a copy of the real part of the number
//
- (BigFloat *)realPartCopy
{
	return [super copyWithZone:nil];
}

//
// realPart
//
// Returns an autoreleased copy of the real part of the number
//
- (BigFloat *)realPart
{
	return [[self realPartCopy] autorelease];
}

//
// imaginaryPartCopy
//
// Returns a copy of the imaginary part of the number
//
- (BigFloat *)imaginaryPartCopy;
{
	return [bcf_imaginary copyWithZone:nil];
}

//
// imaginaryPart
//
// Returns an autoreleased copy of the imaginary part of the number
//
- (BigFloat *)imaginaryPart;
{
	return [[self imaginaryPartCopy] autorelease];
}

//
// magnitudeCopy
//
// Calculates the magnitude and returns a copy of it
//
- (BigFloat *)magnitudeCopy
{
	BigFloat *magnitude;
	BigFloat *imSquared;
	
	if (!bcf_has_imaginary)
	{
		magnitude = [super copyWithZone:nil];
		[magnitude abs];
		
		return magnitude;
	}
	
	magnitude = [super copyWithZone:nil];
	[magnitude multiplyBy:magnitude];
	
	imSquared = [bcf_imaginary copy];
	[imSquared multiplyBy:imSquared];
	
	[magnitude add:imSquared];
	[magnitude sqrt];
	
	[imSquared release];
	return magnitude;
}

//
// magnitude
//
// Calculates the magnitude and returns it
//
- (BigFloat *)magnitude
{
	return [[self magnitudeCopy] autorelease];
}

//
// angleCopy
//
// Calculates the angle (phase) and returns a copy of it
//
- (BigFloat *)angleCopy
{
	BigFloat *angle;
	BigFloat *magnitude;
	
	if (!bcf_has_imaginary)
	{
		if (bf_is_negative)
			return [[BigFloat alloc] initPiWithRadix:bf_radix];
		else
			return [[BigFloat alloc] initWithInt:0 radix:bf_radix]; 
	}
	
	angle = [bcf_imaginary copy];
	magnitude = [self magnitudeCopy];
	[angle divideBy:magnitude];
	[angle sinWithTrigMode:BF_radians inv:YES hyp:NO];
	
	if (bf_is_negative)
	{
		BigFloat *piMinusAngle;
		BigFloat *minusOne;
		
		minusOne = [[BigFloat alloc] initWithInt:-1 radix:bf_radix];
		piMinusAngle = [minusOne copy];
		[piMinusAngle cosWithTrigMode:BF_radians inv:YES hyp:NO];
		
		if ([bcf_imaginary isNegative])
		{
			[piMinusAngle multiplyBy:minusOne];
		}
		
		[piMinusAngle subtract:angle];
		[angle assign:piMinusAngle];
		
		[piMinusAngle release];
		[minusOne release];
	}
	
	[magnitude release];
	
	return angle;
}

//
// angle
//
// Calculates the angle (phase)
//
- (BigFloat *)angle
{
	return [[self angleCopy] autorelease];
}

//
// conjugate
//
// Changes the sign of the imaginary part
//
- (void)conjugate
{
	BigFloat *minusOne;
	
	if (!bcf_has_imaginary)
		return;
	
	minusOne = [[BigFloat alloc] initWithInt:-1 radix:bf_radix];
	[bcf_imaginary multiplyBy:minusOne];
	[minusOne release];
}

//
// hasImaginary
//
// Returns whether the number has an imaginary component 
//
- (BOOL)hasImaginary
{
	return bcf_has_imaginary;
}

//
// imaginaryHasExponent
//
// Returns whether the imaginary component has an exponent
//
- (BOOL)imaginaryHasExponent
{
	return bcf_has_imaginary && [bcf_imaginary hasExponent];
}

#pragma mark
#pragma mark ### Public Utility Functions ###
//
// appendDigit
//
// Wrapper that adds complex number support around the base class
//
- (BOOL)appendDigit:(short)digit useComplement:(int)complement
{
	if (digit == L'i')
	{
		bcf_has_imaginary = YES;
		return YES;
	}
	
	if (bcf_has_imaginary)
	{
		return [bcf_imaginary appendDigit:digit useComplement:complement];
	}
	
	return [super appendDigit:digit useComplement:complement];
}

//
// appendExpDigit
//
// Wrapper that adds complex number support around the base class
//
- (void)appendExpDigit:(short)digit
{
	if (bcf_has_imaginary)
	{
		[bcf_imaginary appendExpDigit:digit];
		return;
	}
	
	[super appendExpDigit:digit];
}

//
// deleteDigit
//
// Wrapper that adds complex number support around the base class
//
- (void)deleteDigit
{
	if (bcf_has_imaginary)
	{
		[bcf_imaginary deleteDigit];
		if ([bcf_imaginary isZero] && [bcf_imaginary getUserPoint] == 0)
		{
			bcf_has_imaginary = NO;
		}
		
		return;
	}
	
	[super deleteDigit];
}

//
// deleteExpDigit
//
// Wrapper that adds complex number support around the base class
//
- (void)deleteExpDigit
{
	if (bcf_has_imaginary)
	{
		[bcf_imaginary deleteExpDigit];
		return;
	}
	
	[super deleteExpDigit];
}

//
// convertToRadix
//
// Wrapper that adds complex number support around the base class
//
- (void)convertToRadix:(unsigned short)newRadix
{
	BigFloat *real = [self realPart];
	[real convertToRadix:newRadix];
	[super assign:real];
	[bcf_imaginary convertToRadix:newRadix];
}

//
// radix
//
// Wrapper that adds complex number support around the base class
//
- (unsigned short)radix
{
	return [super radix];
}

//
// isValid
//
// Wrapper that adds complex number support around the base class
//
- (BOOL)isValid
{
	return bf_is_valid && [bcf_imaginary isValid];
}

//
// isZero
//
// Wrapper that adds complex number support around the base class
//
- (BOOL)isZero
{
	return [super isZero] && [bcf_imaginary isZero];
}

//
// setUserPoint
//
// Wrapper that adds complex number support around the base class
//
- (void)setUserPoint:(int)pointLocation
{
	if (bcf_has_imaginary)
	{
		[bcf_imaginary setUserPoint:pointLocation];
		return;
	}
	
	[super setUserPoint:pointLocation];
}

//
// getUserPoint
//
// Wrapper that adds complex number support around the base class
//
- (int)getUserPoint
{
	if (bcf_has_imaginary)
	{
		return [bcf_imaginary getUserPoint];
	}
	
	return [super getUserPoint];
}

//
// compareWith
//
// Wrapper that adds complex number support around the base class
//
- (NSComparisonResult)compareWith:(BigFloat*)num
{
	NSComparisonResult real_result;
	NSComparisonResult im_result;
	
	// We're actually comparing with another BigCFloat
	if ([num isKindOfClass:[BigCFloat class]])
	{
		BigCFloat *cnum = (BigCFloat *)num;
		
		real_result = [[self realPart] compareWith:[cnum realPart]];
		im_result = [bcf_imaginary compareWith:cnum->bcf_imaginary];
		
		if (real_result == NSOrderedSame && im_result == NSOrderedSame)
		{
			return NSOrderedSame;
		}
		else if (real_result == NSOrderedSame)
		{
			return im_result;
		}
		else if (im_result == NSOrderedSame)
		{
			return real_result;
		}
		
		return NSOrderedAscending;
	}
	
	real_result = [[self realPart] compareWith:num];
	
	if (bcf_has_imaginary && real_result == NSOrderedSame)
	{
		if ([bcf_imaginary isNegative])
			return NSOrderedAscending;
		else
			return NSOrderedDescending;
	}
	else if (bcf_has_imaginary)
	{
		return NSOrderedAscending;
	}
	
	return real_result;
}

//
// duplicate
//
// Wrapper that adds complex number support around the base class
//
- (BigFloat*)duplicate
{
	return [[self copy] autorelease];
}

//
// assign
//
// Wrapper that adds complex number support around the base class
//
- (void)assign:(BigFloat*)newValue
{
	if ([newValue isKindOfClass:[BigCFloat class]])
	{
		BigCFloat *cvalue = (BigCFloat*)newValue;
		
		[super assign:cvalue];
		[bcf_imaginary assign:cvalue->bcf_imaginary];
		bcf_has_imaginary = [cvalue hasImaginary];
		
		return;
	}
	
	if (bcf_has_imaginary)
	{
		[bcf_imaginary release];
		bcf_imaginary = [[BigFloat alloc] initWithInt:0 radix:bf_radix];
		bcf_has_imaginary = NO;
	}
	
	[super assign:newValue];
}

//
// abs
//
// Wrapper that adds complex number support around the base class
//
- (void)abs
{
	if (bcf_has_imaginary)
	{
		BigFloat	*magnitude = [self magnitudeCopy];
		
		[self assign:magnitude];
		[magnitude release];
		
		return;
	}
	
	[super abs];
}

#pragma mark
#pragma mark ### Arithmetic Functions ###
//
// add
//
// Wrapper that adds complex number support around the base class
//
- (void)add:(BigFloat*)num
{
	BigFloat *real = [self realPart];
	[real add:num];
	[super assign:real];
	
	if ([num isKindOfClass:[BigCFloat class]])
	{
		BigCFloat *cnum = (BigCFloat *)num;
		
		if ([cnum hasImaginary])
		{
			[bcf_imaginary add:cnum->bcf_imaginary];
			if ([bcf_imaginary isZero])
				bcf_has_imaginary = NO;
			else
				bcf_has_imaginary = YES;
		}
	}
}

//
// subtract
//
// Wrapper that adds complex number support around the base class
//
- (void)subtract:(BigFloat*)num
{
	BigFloat *real = [self realPart];
	[real subtract:num];
	[super assign:real];
	
	if ([num isKindOfClass:[BigCFloat class]])
	{
		BigCFloat *cnum = (BigCFloat *)num;
		
		if ([cnum hasImaginary])
		{
			[bcf_imaginary subtract:cnum->bcf_imaginary];
			if ([bcf_imaginary isZero])
				bcf_has_imaginary = NO;
			else
				bcf_has_imaginary = YES;
		}
	}
}

//
// multiplyBy
//
// Wrapper that adds complex number support around the base class
//
- (void)multiplyBy:(BigFloat*)num
{
	BigFloat *real;
	
	if ([num isKindOfClass:[BigCFloat class]] && [(BigCFloat *)num hasImaginary])
	{
		BigCFloat	*cnum = (BigCFloat *)num;
		BigFloat	*firstTerm;
		BigFloat	*secondTerm;
		BigFloat	*imaginary;
		
		firstTerm = [self realPartCopy];
		[firstTerm multiplyBy:[cnum realPart]];
		secondTerm = [self imaginaryPartCopy];
		[secondTerm multiplyBy:cnum->bcf_imaginary];
		[firstTerm subtract:secondTerm];
		real = [firstTerm copy];
		
		[firstTerm release];
		[secondTerm release];
		
		firstTerm = [self imaginaryPartCopy];
		[firstTerm multiplyBy:[cnum realPart]];
		secondTerm = [self realPartCopy];
		[secondTerm multiplyBy:cnum->bcf_imaginary];
		[firstTerm add:secondTerm];
		imaginary = [firstTerm copy];
		
		[self assign:real];
		[bcf_imaginary assign:imaginary];
		
		if ([bcf_imaginary isZero])
			bcf_has_imaginary = NO;
		else
			bcf_has_imaginary = YES;
		
		[firstTerm release];
		[secondTerm release];
		[real release];
		[imaginary release];
		
		return;
	}
	
	real = [self realPart];
	[real multiplyBy:num];
	[super assign:real];
	
	if (bcf_has_imaginary)
	{
		[bcf_imaginary multiplyBy: num];
		if ([bcf_imaginary isZero])
			bcf_has_imaginary = NO;
		else
			bcf_has_imaginary = YES;
	}
}

//
// divideBy
//
// Wrapper that adds complex number support around the base class
//
- (void)divideBy:(BigFloat*)num
{
	BigFloat *real;
	
	if ([num isKindOfClass:[BigCFloat class]] && [(BigCFloat *)num hasImaginary])
	{
		BigCFloat	*cnum = (BigCFloat *)num;
		BigFloat	*firstTerm;
		BigFloat	*secondTerm;
		BigFloat	*denominator;
		BigFloat	*imaginary;
		
		firstTerm = [cnum realPartCopy];
		[firstTerm multiplyBy:firstTerm];
		secondTerm = [cnum imaginaryPartCopy];
		[secondTerm multiplyBy:secondTerm];
		[firstTerm add:secondTerm];
		denominator = [firstTerm copy];
		
		[firstTerm release];
		[secondTerm release];
		
		firstTerm = [self realPartCopy];
		[firstTerm multiplyBy:[cnum realPart]];
		secondTerm = [self imaginaryPartCopy];
		[secondTerm multiplyBy:cnum->bcf_imaginary];
		[firstTerm add:secondTerm];
		[firstTerm divideBy:denominator];
		real = [firstTerm copy];
		
		[firstTerm release];
		[secondTerm release];
		
		firstTerm = [self imaginaryPartCopy];
		[firstTerm multiplyBy:[cnum realPart]];
		secondTerm = [self realPartCopy];
		[secondTerm multiplyBy:cnum->bcf_imaginary];
		[firstTerm subtract:secondTerm];
		[firstTerm divideBy:denominator];
		imaginary = [firstTerm copy];
		
		[self assign:real];
		[bcf_imaginary assign:imaginary];
		
		if ([bcf_imaginary isZero])
			bcf_has_imaginary = NO;
		else
			bcf_has_imaginary = YES;

		[firstTerm release];
		[secondTerm release];
		[real release];
		[imaginary release];
		[denominator release];

		return;
	}
	
	real = [self realPart];
	[real divideBy:num];
	[super assign:real];
	
	if (bcf_has_imaginary)
	{
		[bcf_imaginary divideBy: num];
		if ([bcf_imaginary isZero])
			bcf_has_imaginary = NO;
		else
			bcf_has_imaginary = YES;
	}
}

//
// moduloBy
//
// Wrapper that adds complex number support around the base class
//
- (void)moduloBy:(BigFloat*)num
{
	BigCFloat *cnum;
	BigCFloat *quotient;
	
	if (![num isKindOfClass:[BigCFloat class]] || ![(BigCFloat *)num hasImaginary])
	{
		if (!bcf_has_imaginary)
		{
			// if there are no imaginary parts then just do the super's work
			[super moduloBy:num];
		}
		
		// otherwise promote to a Complex number
		cnum = [[BigCFloat alloc] init];
		[cnum assign:num];
	}
	else
	{
		cnum = (BigCFloat *)[num retain];
	}
	
	// x % y = (x - (int(x/y) * y))
	quotient = [self copy];
	[quotient divideBy:cnum];
	[quotient wholePart];
	[quotient multiplyBy:cnum];
	[self subtract:quotient];
	
	[cnum release];
	[quotient release];
}

#pragma mark
#pragma mark ### Extended Mathematics Functions ###
//
// powerOfE
//
// Wrapper that adds complex number support around the base class
//
- (void)powerOfE
{
	BigFloat *realPart;
	BigFloat *cosPart;
	BigFloat *sinPart;
	
	if (!bf_is_valid)
		return;
	
	if (bcf_has_imaginary)
	{
		realPart = [self realPartCopy];
		cosPart = [self imaginaryPartCopy];
		sinPart = [self imaginaryPartCopy];
		[cosPart cosWithTrigMode:BF_radians inv:NO hyp:NO];
		[sinPart sinWithTrigMode:BF_radians inv:NO hyp:NO];
		
		[realPart powerOfE];
		[self assign:realPart];
		[self multiplyBy:cosPart];
		
		[bcf_imaginary assign:realPart];
		[bcf_imaginary multiplyBy:sinPart];
		
		if ([bcf_imaginary isZero])
			bcf_has_imaginary = NO;
		else
			bcf_has_imaginary = YES;
		
		[realPart release];
		[cosPart release];
		[sinPart release];
		
		return;
	}
	
	[super powerOfE];
}

//
// ln
//
// Wrapper that adds complex number support around the base class
//
- (void)ln
{
	BigFloat *r;
	BigFloat *theta;
	
	if (!bf_is_valid)
		return;
	
	if (!bcf_has_imaginary && !bf_is_negative)
	{
		[super ln];
		return;
	}
	
	r = [self magnitudeCopy];
	theta = [self angleCopy];
	
	[r ln];
	[self assign:r];
	[bcf_imaginary assign:theta];
	bcf_has_imaginary = YES;
	
	[r release];
	[theta release];
}

//
// raiseToPower
//
// Wrapper that adds complex number support around the base class
//
- (void)raiseToPower:(BigFloat*)num
{
	BigCFloat	*cnum;
	BigCFloat	*one;

	if (!bf_is_valid)
		return;
	
	if (!bcf_has_imaginary && ![num isKindOfClass:[BigCFloat class]])
	{
		[super raiseToPower:num];
		return;
	}
	
	one = [[BigCFloat alloc] initWithInt:1 radix:bf_radix];
	
	// Promote num to a BigCFloat
	cnum = (BigCFloat*)num;
	if ([self isZero])
	{
		// Zero raised to anything except zero is zero (provided exponent is valid)
		bf_is_valid = [num isValid];
		if ([cnum isZero])
		{
			
			[self assign:one];
		}
		[one release];
		return;
	}
	[self ln];
	[self multiplyBy: cnum];
	[self powerOfE];
	
	[one release];
}

//
// sqrt
//
// Wrapper that adds complex number support around the base class
//
- (void)sqrt
{
	BigFloat 	*r;
	BigFloat 	*theta;
	BigFloat 	*two = [[BigFloat alloc] initWithInt:2 radix:bf_radix];
	BigCFloat	*value;
	
	if (!bf_is_valid)
	{
		[two release];
		return;
	}
	
	if(!bcf_has_imaginary && !bf_is_negative)
	{
		[super sqrt];
		return;
	}
	
	r = [self magnitudeCopy];
	theta = [self angleCopy];
	
	[r sqrt];
	[theta divideBy:two];
	value = [[BigCFloat alloc] initWithMagnitude:r angle:theta];
	[self assign:value];
	
	[two release];
	[value release];
	[r release];
	[theta release];
}

//
// inverse
//
// Wrapper that adds complex number support around the base class
//
- (void)inverse
{
	if (!bf_is_valid)
	{
		return;
	}
	
	[super inverse];
}

//
// logOfBase
//
// Wrapper that adds complex number support around the base class
//
- (void)logOfBase:(BigFloat *)base
{
	if (!bf_is_valid)
	{
		return;
	}
	
	[super logOfBase:base];
}

//
// sinWithTrigMode
//
// Wrapper that adds complex number support around the base class
//
- (void)sinWithTrigMode:(BFTrigMode)mode inv:(BOOL)useInverse hyp:(BOOL)useHyp
{
	BigCFloat	*firstTerm;
	BigCFloat	*secondTerm;
	BigCFloat	*thirdTerm;
	BigCFloat	*one;
	BigCFloat	*two;
	BigCFloat	*zero;
	BigCFloat	*minusOne;
	BigCFloat	*pi;
	BigCFloat *abs;
	NSComparisonResult result;

	if (!bf_is_valid)
	{
		return;
	}
	
	one = [[BigCFloat alloc] initWithInt:1 radix: bf_radix];
	abs = [self copy];
	[abs abs];
	result = [abs compareWith:one];

	if
	(
		(useHyp || !bcf_has_imaginary)
		&&
		(!(useInverse && !useHyp) || (result == NSOrderedAscending || result == NSOrderedSame))
	)
	{
		[one release];
		[abs release];
		[super sinWithTrigMode:mode inv:useInverse hyp:useHyp];
		return;
	}
	
	two = [[BigCFloat alloc] initWithInt:2 radix: bf_radix];
	zero = [[BigCFloat alloc] initWithInt:0 radix: bf_radix];
	minusOne = [[BigCFloat alloc] initWithInt:-1 radix: bf_radix];
	pi = [[BigCFloat alloc] initPiWithRadix:bf_radix];

	if (useInverse == NO)
	{
		if (mode != BF_radians)
		{
			if (mode == BF_degrees)
			{
				BigCFloat *oneEighty = [[BigCFloat alloc] initWithInt: 180 radix: bf_radix];
				[self divideBy:oneEighty];
				[oneEighty release];
			}
			else if (mode == BF_gradians)
			{
				BigCFloat *twoHundred = [[BigCFloat alloc] initWithInt: 200 radix: bf_radix];
				[self divideBy:twoHundred];
				[twoHundred release];
			}
			
			[self multiplyBy:pi];
		}
		
		// sin(z) = (e^iz - e^-iz) / 2i
		firstTerm = [[BigCFloat alloc]
			initWithReal:zero
			imaginary:one
		];
		[firstTerm multiplyBy:self];
		[firstTerm powerOfE];
		secondTerm = [[BigCFloat alloc]
			initWithReal:zero
			imaginary:minusOne
		];
		[secondTerm multiplyBy:self];
		[secondTerm powerOfE];
		[firstTerm subtract:secondTerm];
		thirdTerm = [[BigCFloat alloc]
			initWithReal:zero
			imaginary:two
		];
		[firstTerm divideBy:thirdTerm];
		[self assign:firstTerm];
		[firstTerm release];
		[secondTerm release];
		[thirdTerm release];
	}
	else
	{
		// arcsin(z) = -i ln (iz + sqrt(1 - z^2))
		firstTerm = [self copy];
		[firstTerm multiplyBy:firstTerm];
		secondTerm = [one copy];
		[secondTerm subtract:firstTerm];
		[secondTerm sqrt];
		[firstTerm release];
		firstTerm = [[BigCFloat alloc]
			initWithReal:zero
			imaginary:one
		];
		[firstTerm multiplyBy:self];
		[firstTerm add:secondTerm];
		[firstTerm ln];
		[secondTerm release];
		secondTerm = [[BigCFloat alloc]
			initWithReal:zero
			imaginary:minusOne
		];
		[firstTerm multiplyBy:secondTerm];
		[self assign:firstTerm];
		[firstTerm release];
		[secondTerm release];
		
		if (mode != BF_radians)
		{
			if (mode == BF_degrees)
			{
				BigCFloat *oneEighty = [[BigCFloat alloc] initWithInt: 180 radix: bf_radix];
				[self multiplyBy:oneEighty];
				[oneEighty release];
			}
			else if (mode == BF_gradians)
			{
				BigCFloat *twoHundred = [[BigCFloat alloc] initWithInt: 200 radix: bf_radix];
				[self multiplyBy:twoHundred];
				[twoHundred release];
			}
			
			[self divideBy:pi];
		}
	}
	
	[one release];
	[two release];
	[zero release];
	[minusOne release];
	[pi release];
	[abs release];
}

//
// cosWithTrigMode
//
// Wrapper that adds complex number support around the base class
//
- (void)cosWithTrigMode:(BFTrigMode)mode inv:(BOOL)useInverse hyp:(BOOL)useHyp
{
	BigCFloat	*firstTerm;
	BigCFloat	*secondTerm;
	BigCFloat	*thirdTerm;
	BigCFloat	*one;
	BigCFloat	*two;
	BigCFloat	*zero;
	BigCFloat	*minusOne;
	BigCFloat	*pi;
	BigCFloat *abs;
	NSComparisonResult result;

	if (!bf_is_valid)
	{
		return;
	}
	
	one = [[BigCFloat alloc] initWithInt:1 radix: bf_radix];
	abs = [self copy];
	[abs abs];
	result = [abs compareWith:one];

	if
	(
		(useHyp || !bcf_has_imaginary)
		&&
		(!(useInverse && !useHyp) || (result == NSOrderedAscending || result == NSOrderedSame))
	)
	{
		[one release];
		[abs release];
		[super cosWithTrigMode:mode inv:useInverse hyp:useHyp];
		return;
	}
	
	two = [[BigCFloat alloc] initWithInt:2 radix: bf_radix];
	zero = [[BigCFloat alloc] initWithInt:0 radix: bf_radix];
	minusOne = [[BigCFloat alloc] initWithInt:-1 radix: bf_radix];
	pi = [[BigCFloat alloc] initPiWithRadix:bf_radix];
	
	if (useInverse == NO)
	{
		if (mode != BF_radians)
		{
			if (mode == BF_degrees)
			{
				BigCFloat *oneEighty = [[BigCFloat alloc] initWithInt: 180 radix: bf_radix];
				[self divideBy:oneEighty];
				[oneEighty release];
			}
			else if (mode == BF_gradians)
			{
				BigCFloat *twoHundred = [[BigCFloat alloc] initWithInt: 200 radix: bf_radix];
				[self divideBy:twoHundred];
				[twoHundred release];
			}
			
			[self multiplyBy:pi];
		}
		
		// cos(z) = (e^iz + e^-iz) / 2
		firstTerm = [[BigCFloat alloc]
			initWithReal:zero
			imaginary:one
		];
		[firstTerm multiplyBy:self];
		[firstTerm powerOfE];
		secondTerm = [[BigCFloat alloc]
			initWithReal:zero
			imaginary:minusOne
		];
		[secondTerm multiplyBy:self];
		[secondTerm powerOfE];
		[firstTerm add:secondTerm];
		thirdTerm = [[BigCFloat alloc]
			initWithReal:two
			imaginary:zero
		];
		[firstTerm divideBy:thirdTerm];
		[self assign:firstTerm];
		
		[firstTerm release];
		[secondTerm release];
		[thirdTerm release];
	}
	else
	{
		// arccos(z) = pi/2 - arcsin(z)
		[self sinWithTrigMode:mode inv:useInverse hyp:useHyp];
		
		firstTerm = [[BigCFloat alloc] initPiWithRadix:bf_radix];
		[firstTerm divideBy:two];
		[firstTerm subtract:self];
		[self assign:firstTerm];
		
		if (mode != BF_radians)
		{
			if (mode == BF_degrees)
			{
				BigCFloat *oneEighty = [[BigCFloat alloc] initWithInt: 180 radix: bf_radix];
				[self multiplyBy:oneEighty];
				[oneEighty release];
			}
			else if (mode == BF_gradians)
			{
				BigCFloat *twoHundred = [[BigCFloat alloc] initWithInt: 200 radix: bf_radix];
				[self multiplyBy:twoHundred];
				[twoHundred release];
			}
			
			[self divideBy:pi];
		}

		[firstTerm release];
	}
	
	[one release];
	[two release];
	[zero release];
	[minusOne release];
	[pi release];
}

//
// tanWithTrigMode
//
// Wrapper that adds complex number support around the base class
//
- (void)tanWithTrigMode:(BFTrigMode)mode inv:(BOOL)useInverse hyp:(BOOL)useHyp
{
	BigCFloat	*firstTerm;
	BigCFloat	*secondTerm;
	BigCFloat	*thirdTerm;
	BigCFloat	*one;
	BigCFloat	*two;
	BigCFloat	*minushalf;
	BigCFloat	*zero;
	BigCFloat	*pi;

	if (!bf_is_valid)
	{
		return;
	}
	
	if ((useHyp || !bcf_has_imaginary) && !useInverse)
	{
		[super tanWithTrigMode:mode inv:useInverse hyp:useHyp];
		return;
	}
	
	one = [[BigCFloat alloc] initWithInt:1 radix: bf_radix];
	two = [[BigCFloat alloc] initWithInt:2 radix: bf_radix];
	minushalf = [[BigCFloat alloc] initWithDouble:-0.5 radix: bf_radix];
	zero = [[BigCFloat alloc] initWithInt:0 radix: bf_radix];
	pi = [[BigCFloat alloc] initPiWithRadix:bf_radix];

	if (useInverse == NO)
	{
		if (mode != BF_radians)
		{
			if (mode == BF_degrees)
			{
				BigCFloat *oneEighty = [[BigCFloat alloc] initWithInt: 180 radix: bf_radix];
				[self divideBy:oneEighty];
				[oneEighty release];
			}
			else if (mode == BF_gradians)
			{
				BigCFloat *twoHundred = [[BigCFloat alloc] initWithInt: 200 radix: bf_radix];
				[self divideBy:twoHundred];
				[twoHundred release];
			}
			
			[self multiplyBy:pi];
		}
		
		// tan(z) = sin(z) / cos(z)
		firstTerm = [self copy];
		[firstTerm sinWithTrigMode:mode inv:useInverse hyp:useHyp];
		secondTerm = [self copy];
		[secondTerm cosWithTrigMode:mode inv:useInverse hyp:useHyp];
		[self assign:firstTerm];
		[self divideBy:secondTerm];
		[firstTerm release];
		[secondTerm release];
	}
	else
	{
		// arctan(z) = (ln(1 + iz) - ln(1 - iz)) * (-0.5i)
		firstTerm = [[BigCFloat alloc]
				initWithReal:zero
				imaginary:one
		];
		[firstTerm multiplyBy:self];
		secondTerm = [[BigCFloat alloc]
				initWithReal:one
				imaginary:zero
		];
		[secondTerm subtract:firstTerm];
		thirdTerm = [[BigCFloat alloc]
				initWithReal:one
				imaginary:zero
		];
		[thirdTerm add:firstTerm];
		[thirdTerm divideBy:secondTerm];
		[thirdTerm ln];

		[firstTerm release];
		firstTerm = [[BigCFloat alloc]
				initWithReal:zero
				imaginary:minushalf
		];
		[thirdTerm multiplyBy:firstTerm];
		[self assign:thirdTerm];
		
		if (mode != BF_radians)
		{
			if (mode == BF_degrees)
			{
				BigCFloat *oneEighty = [[BigCFloat alloc] initWithInt: 180 radix: bf_radix];
				[self multiplyBy:oneEighty];
				[oneEighty release];
			}
			else if (mode == BF_gradians)
			{
				BigCFloat *twoHundred = [[BigCFloat alloc] initWithInt: 200 radix: bf_radix];
				[self multiplyBy:twoHundred];
				[twoHundred release];
			}
			
			[self divideBy:pi];
		}
		
		[firstTerm release];
		[secondTerm release];
		[thirdTerm release];
	}

	[one release];
	[two release];
	[zero release];
	[pi release];
	[minushalf release];
}

//
// factorial
//
// Wrapper that adds complex number support around the base class
//
- (void)factorial
{
	if (!bf_is_valid)
	{
		return;
	}
	
	// I really tried to implement a gamma function which would extend factorial functionality
	// into the complex plane but it was not meant to be

	// doesn't really make sense for a complex number so throw away the complex part
	[self abs];

	[super factorial];
}

//
// sum
//
// Wrapper that adds complex number support around the base class
//
- (void)sum
{
	if (!bf_is_valid)
	{
		return;
	}
	
	// doesn't really make sense for a complex number so throw away the complex part
	[self abs];
	
	[super sum];
}

//
// nPr
//
// Wrapper that adds complex number support around the base class
//
- (void)nPr: (BigFloat*)r
{
	if (!bf_is_valid)
	{
		return;
	}
	
	// doesn't really make sense for a complex number so throw away the complex part
	[self abs];
	
	[super nPr:r];
}

//
// nCr
//
// Wrapper that adds complex number support around the base class
//
- (void)nCr: (BigFloat*)r
{
	if (!bf_is_valid)
	{
		return;
	}
	
	// doesn't really make sense for a complex number so throw away the complex part
	[self abs];
	
	[super nCr:r];
}

//
// exp3Up
//
// Wrapper that adds complex number support around the base class
//
- (void)exp3Up
{
	BigFloat *real;
	
	if (!bf_is_valid)
	{
		return;
	}
	
	real = [self realPart];
	[real exp3Up];
	[super assign:real];
	
	[bcf_imaginary exp3Up];
}

//
// exp3Down
//
// Wrapper that adds complex number support around the base class
//
- (void)exp3Down:(int)displayDigits
{
	BigFloat *real;
	
	if (!bf_is_valid)
	{
		return;
	}
	
	real = [self realPart];
	[real exp3Down:displayDigits];
	[super assign:real];
	
	if (bcf_has_imaginary)
		[bcf_imaginary exp3Down:displayDigits];
}

//
// wholePart
//
// Wrapper that adds complex number support around the base class
//
- (void)wholePart
{
	BigFloat *real;
	BigFloat *imPart;

	if (!bf_is_valid)
	{
		return;
	}
	
	real = [self realPartCopy];
	imPart = [self imaginaryPartCopy];
	
	[real wholePart];
	[self assign:real];
	[imPart wholePart];
	[bcf_imaginary assign:imPart];
}

//
// fractionalPart
//
// Wrapper that adds complex number support around the base class
//
- (void)fractionalPart
{
	BigFloat *real;
	
	if (!bf_is_valid)
	{
		return;
	}
	
	real = [self realPart];
	[real fractionalPart];
	[super assign:real];

	[bcf_imaginary fractionalPart];
}

//
// bitnot
//
// Wrapper that adds complex number support around the base class
//
- (void)bitnot
{
	BigFloat *real;
	
	if (!bf_is_valid)
	{
		return;
	}
	
	real = [self realPart];
	[real bitnot];
	[super assign:real];
	
	[bcf_imaginary bitnot];
}

//
// andWith
//
// Wrapper that adds complex number support around the base class
//
- (void)andWith:(BigFloat*)num
{
	if (!bf_is_valid)
	{
		return;
	}
	
	if ([num isKindOfClass:[BigCFloat class]])
	{
		BigCFloat *cnum = (BigCFloat*)num;
		
		[super andWith:cnum];
		[bcf_imaginary andWith:cnum->bcf_imaginary];
		return;
	}
	
	[self abs];
	[super andWith:num];
}

//
// orWith
//
// Wrapper that adds complex number support around the base class
//
- (void)orWith:(BigFloat*)num
{
	if (!bf_is_valid)
	{
		return;
	}
	
	if ([num isKindOfClass:[BigCFloat class]])
	{
		BigCFloat *cnum = (BigCFloat*)num;
		
		[super orWith:cnum];
		[bcf_imaginary orWith:cnum->bcf_imaginary];
		return;
	}
	
	[self abs];
	[super orWith:num];
}

//
// xorWith
//
// Wrapper that adds complex number support around the base class
//
- (void)xorWith:(BigFloat*)num
{
	if (!bf_is_valid)
	{
		return;
	}
	
	if ([num isKindOfClass:[BigCFloat class]])
	{
		BigCFloat *cnum = (BigCFloat*)num;
		
		[super xorWith:cnum];
		[bcf_imaginary xorWith:cnum->bcf_imaginary];
		return;
	}
	
	[self abs];
	[super xorWith:num];
}


#pragma mark
#pragma mark ### Accessor Functions ###
//
// imaginaryMantissaString
//
// Returns the mantissaString for the imaginary component
//
- (NSString*)imaginaryMantissaString
{
	return [bcf_imaginary mantissaString];
}

//
// imaginaryExponentString
//
// Returns the exponentString for the imaginary component
//
- (NSString*)imaginaryExponentString
{
	return [bcf_imaginary exponentString];
}

//
// toString
//
// Wrapper that adds complex number support around the base class
//
- (NSString*)toString
{
	NSString	*string;
	
	// Get the mantissa string
	string = [self mantissaString];
	
	// Append the exponent string
	if (bf_exponent != 0)
	{
		string = [[string stringByAppendingString: @"e"] stringByAppendingString: [self exponentString]];
	}
	
	// And the imaginary part
	if (bcf_has_imaginary)
	{
		string = [[string stringByAppendingString: @" + i"] stringByAppendingString: [bcf_imaginary mantissaString]];
		
		if ([bcf_imaginary hasExponent])
			string = [[string stringByAppendingString: @"e"] stringByAppendingString: [bcf_imaginary exponentString]];
	}
	
	return string;
}

//
// toShortString
//
// Wrapper that adds complex number support around the base class
//
- (NSString*)toShortString:(int)precision
{
	NSString	*string;
	NSString	*mantissa;
	NSString	*exponent;

	// Get the string pieces
	[self limitedString:precision fixedPlaces:0 fillLimit:NO complement:0 mantissa:&string exponent:&exponent];
	
	// Append the exponent string
	if ([exponent length] != 0)
	{
		string = [[string stringByAppendingString: @"e"] stringByAppendingString:exponent];
	}
	
	// And the imaginary part
	if (bcf_has_imaginary)
	{
		[bcf_imaginary limitedString:precision fixedPlaces:0 fillLimit:NO complement:0 mantissa:&mantissa exponent:&exponent];
		
		string = [[string stringByAppendingString: @" + i"] stringByAppendingString:mantissa];
		
		if ([exponent length] != 0)
			string = [[string stringByAppendingString: @"e"] stringByAppendingString:exponent];
	}
	
	return string;
}

//
// limitedString
//
// Wrapper that adds complex number support around the base class
//
- (void)limitedString:(unsigned int)lengthLimit fixedPlaces:(unsigned int)places fillLimit:(BOOL)fill complement:(unsigned int)complement mantissa:(NSString**)mantissaOut exponent:(NSString**)exponentOut imaginaryMantissa:(NSString**)imaginaryMantissaOut imaginaryExponent:(NSString**)imaginaryExponentOut;
{
	[super limitedString:lengthLimit fixedPlaces:places fillLimit:fill complement:complement mantissa:mantissaOut exponent:exponentOut];
	
	if (bcf_has_imaginary)
	{
		[bcf_imaginary limitedString:lengthLimit fixedPlaces:places fillLimit:fill complement:complement mantissa:imaginaryMantissaOut exponent:imaginaryExponentOut];
	}
	else
	{
		*imaginaryMantissaOut = @"";
		*imaginaryExponentOut = @"";
	}
}

//
// debugDisplay
//
// Wrapper that adds complex number support around the base class
//
- (void)debugDisplay
{
	NSString	*string;
	
	// Get the mantissa string
	string = [self mantissaString];
	
	// Append the exponent string
	if (bf_exponent != 0)
	{
		string = [[string stringByAppendingString: @"e"] stringByAppendingString: [self exponentString]];
	}
	
	// And the imaginary part
	if (bcf_has_imaginary)
	{
		string = [[string stringByAppendingString: @" + i"] stringByAppendingString: [bcf_imaginary mantissaString]];
		if ([bcf_imaginary hasExponent])
			string = [[string stringByAppendingString: @"e"] stringByAppendingString: [bcf_imaginary exponentString]];
	}
	
	printf("%s\n", [string cString]);
}

@end
