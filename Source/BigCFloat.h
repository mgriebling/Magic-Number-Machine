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
- (instancetype)initPiWithRadix:(unsigned short)newRadix ;

- (instancetype)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone*)zone;

+ (BigCFloat*)bigFloatWithReal:(BigFloat *)realPart imaginary:(BigFloat *)imaginaryPart;
+ (BigCFloat*)bigFloatWithMagnitude:(BigFloat *)r angle:(BigFloat *)theta;
+ (BigCFloat*)bigFloatWithInt:(signed int)newValue radix:(unsigned short)newRadix;
+ (BigCFloat*)bigFloatWithDouble:(double)newValue radix:(unsigned short)newRadix;
+ (BigCFloat*)piWithRadix:(unsigned short)newRadix;

+ (BigCFloat *)one;
+ (BigCFloat *)zero;
+ (BigCFloat *)i;

// Complex Functions
@property (NS_NONATOMIC_IOSONLY, readonly, copy) BigFloat *realPartCopy;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) BigFloat *realPart;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) BigFloat *imaginaryPart;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) BigFloat *magnitude;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) BigFloat *angle;
- (void)conjugate;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasImaginary;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL imaginaryHasExponent;

// Public Utility Functions
- (BOOL)appendDigit: (short)digit useComplement:(int)complement;
- (void)appendExpDigit:(short)digit;
- (void)deleteDigitUseComplement:(int)complement;
- (void)deleteExpDigit;
- (void)convertToRadix:(unsigned short)newRadix;
@property (NS_NONATOMIC_IOSONLY, readonly) unsigned short radix;
@property (NS_NONATOMIC_IOSONLY, getter=isValid, readonly) BOOL valid;
- (BOOL)isZero;
@property (NS_NONATOMIC_IOSONLY, getter=getUserPoint) int userPoint;
- (NSComparisonResult)compareWith:(BigFloat*)num;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) BigFloat *duplicate;
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
- (void)bitnotWithComplement:(int)complement;
- (void)andWith:(BigFloat*)num usingComplement:(int)complement;
- (void)orWith:(BigFloat*)num usingComplement:(int)complement;
- (void)xorWith:(BigFloat*)num usingComplement:(int)complement;

// Accessor Functions
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *imaginaryMantissaString;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *imaginaryExponentString;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *toString;
- (NSString*)toShortString:(int)precision;
- (void)limitedString:(unsigned int)lengthLimit fixedPlaces:(unsigned int)places fillLimit:(BOOL)fill complement:(unsigned int)complement mantissa:(NSString**)mantissaOut exponent:(NSString**)exponentOut imaginaryMantissa:(NSString**)imaginaryMantissaOut imaginaryExponent:(NSString**)imaginaryExponentOut;
- (void)debugDisplay;

@end
