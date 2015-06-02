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
- (instancetype)init;
- (instancetype)initWithReal:(BigFloat *)realPart imaginary:(BigFloat *)imaginaryPart;
- (instancetype)initWithMagnitude:(BigFloat *)r angle:(BigFloat *)theta;
- (instancetype)initWithInt:(signed int)newValue radix:(unsigned short)newRadix;
- (instancetype)initWithDouble:(double)newValue radix:(unsigned short)newRadix;
- (instancetype)initWithString:(NSString *)newValue radix:(unsigned short)newRadix;
- (instancetype)initPiWithRadix:(unsigned short)newRadix ;

- (instancetype)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone*)zone;

+ (BigCFloat*)bigFloatWithReal:(BigFloat *)realPart imaginary:(BigFloat *)imaginaryPart;
+ (BigCFloat*)bigFloatWithMagnitude:(BigFloat *)r angle:(BigFloat *)theta;
+ (BigCFloat*)bigFloatWithInt:(signed int)newValue radix:(unsigned short)newRadix;
+ (BigCFloat*)bigFloatWithDouble:(double)newValue radix:(unsigned short)newRadix;
+ (BigCFloat*)bigFloatWithString:(NSString *)newValue radix:(unsigned short)newRadix;
+ (BigCFloat*)piWithRadix:(unsigned short)newRadix;

+ (BigCFloat *)one;
+ (BigCFloat *)zero;
+ (BigCFloat *)i;

// Complex Functions & properties
@property (nonatomic, readonly, copy) BigFloat *realPartCopy;
@property (nonatomic, readonly, copy) BigFloat *realPart;
@property (nonatomic, readonly, copy) BigFloat *imaginaryPart;
@property (nonatomic, readonly, copy) BigFloat *magnitude;
@property (nonatomic, readonly, copy) BigFloat *angle;
@property (nonatomic, readonly) BOOL hasImaginary;
@property (nonatomic, readonly) BOOL imaginaryHasExponent;
- (void)conjugate;

// Public Utility Functions & properties
@property (nonatomic, readonly) unsigned short radix;
@property (nonatomic, getter=isValid, readonly) BOOL valid;
@property (nonatomic, getter=getUserPoint) int userPoint;
@property (nonatomic, readonly, copy) BigFloat *duplicate;

- (BOOL)appendDigit: (short)digit useComplement:(int)complement;
- (void)appendExpDigit:(short)digit;
- (void)deleteDigitUseComplement:(int)complement;
- (void)deleteExpDigit;
- (void)convertToRadix:(unsigned short)newRadix;
- (BOOL)isZero;
- (NSComparisonResult)compareWith:(BigFloat*)num;
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

// Accessor Functions
@property (nonatomic, readonly, copy) NSString *imaginaryMantissaString;
@property (nonatomic, readonly, copy) NSString *imaginaryExponentString;
@property (nonatomic, readonly, copy) NSString *toString;
- (NSString*)toShortString:(int)precision;
- (void)limitedString:(unsigned int)lengthLimit fixedPlaces:(unsigned int)places fillLimit:(BOOL)fill complement:(unsigned int)complement mantissa:(NSString**)mantissaOut exponent:(NSString**)exponentOut imaginaryMantissa:(NSString**)imaginaryMantissaOut imaginaryExponent:(NSString**)imaginaryExponentOut;
- (void)debugDisplay;

@end
