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
#define	BF_num_values				16   // was 8
#define	BF_max_mantissa_length		(BF_num_values * 16 + 3)
#define	BF_max_exponent_length		32

#if (BF_num_values < 2)
	#error BF_num_values must be at least 2
#endif

// Mode for trigonometric operations
typedef NS_ENUM(unsigned int, BFTrigMode)
{
	BF_degrees,
	BF_radians,
	BF_gradians
};

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
	unsigned int		bf_exponent_precision;

	BOOL				bf_is_valid;
}

// Constructors
- (instancetype)init;
- (instancetype)initWithMantissa:	(unsigned long long)mantissa
	exponent: 			(short)exp
	isNegative:			(BOOL)flag
	radix:				(unsigned short)newRadix
	userPointAt:		(unsigned short)pointLocation;
- (instancetype)initWithString:(NSString *)newValue radix:(unsigned short)newRadix;
- (instancetype)initWithInt:(signed int)newValue radix:(unsigned short)newRadix;
- (instancetype)initWithDouble:(double)newValue radix:(unsigned short)newRadix;
- (instancetype)initPiWithRadix:(unsigned short)newRadix;

- (instancetype)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone*)zone;

+ (BigFloat*)bigFloatWithString:(NSString *)newValue radix:(unsigned short)newRadix;
+ (BigFloat*)bigFloatWithInt:(signed int)newValue radix:(unsigned short)newRadix;
+ (BigFloat*)bigFloatWithDouble:(double)newValue radix:(unsigned short)newRadix;
+ (BigFloat*)piWithRadix:(unsigned short)newRadix;

// Public Utility Functions and properties
@property (nonatomic, getter=getUserPoint) int userPoint;
@property (nonatomic, readonly) int mantissaLength;
@property (nonatomic, readonly) unsigned short radix;
@property (nonatomic, getter=isValid, readonly) BOOL valid;
@property (nonatomic, getter=isNegative, readonly) BOOL negative;
@property (nonatomic, readonly) BOOL hasExponent;
@property (nonatomic, getter=isZero, readonly) BOOL zero;
@property (nonatomic, readonly, copy) BigFloat *duplicate;
@property (nonatomic, readonly, copy) BigFloat *pi;

- (BOOL)appendDigit: (short)digit useComplement:(int)complement;
- (void)appendExpDigit:(short)digit;
- (void)deleteDigitUseComplement:(int)complement;
- (void)deleteExpDigit;
- (void)convertToRadix:(unsigned short)newRadix;
- (NSComparisonResult)compareWith:(BigFloat*)num;
- (void)assign:(BigFloat*)newValue;
- (void)abs;
- (void)negate;

// Arithmetic Functions
- (void)add:(BigFloat*)num;
- (void)subtract:(BigFloat*)num;
- (void)multiplyBy:(BigFloat*)num;
- (void)divideBy:(BigFloat*)num;
- (void)moduloBy:(BigFloat*)num;

// Extended Mathematics Functions
- (void)powerOfE;
- (void)ln;
- (void)raiseToIntPower: (NSInteger)n;
- (void)raiseToPower:(BigFloat*)num;
- (void)sqrt;
- (void)cbrt;
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
- (void)bitnotWithComplement:(int)complement;
- (void)andWith:(BigFloat*)num usingComplement:(int)complement;
- (void)orWith:(BigFloat*)num usingComplement:(int)complement;
- (void)xorWith:(BigFloat*)num usingComplement:(int)complement;

// Conversion Functions
@property (nonatomic, readonly) double doubleValue;
@property (nonatomic, readonly, copy) NSString *mantissaString;
@property (nonatomic, readonly, copy) NSString *exponentString;
@property (nonatomic, readonly, copy) NSString *toString;
- (NSString*)toShortString:(int)precision;
- (void)limitedString:(unsigned int)lengthLimit fixedPlaces:(unsigned int)places fillLimit:(BOOL)fill complement:(unsigned int)complement mantissa:(NSString**)mantissaOut exponent:(NSString**)exponentOut;
- (void)debugDisplay;

@end
