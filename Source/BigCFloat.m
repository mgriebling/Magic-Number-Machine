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
- (instancetype)init
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
// initWithReal
//
// Init real and imaginary parts. You can validly pass nil instead of zero.
//
- (instancetype)initWithReal:(BigFloat *)realPart imaginary:(BigFloat *)imaginaryPart
{
    self = [super init];
    if (self)
    {
        if (!realPart) realPart = [BigFloat bigFloatWithInt:0 radix:bf_radix];
        if (!imaginaryPart) imaginaryPart = [BigFloat bigFloatWithInt:0 radix:bf_radix];

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
- (instancetype)initWithMagnitude:(BigFloat *)r angle:(BigFloat *)theta
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
        
        bcf_has_imaginary = ![imaginaryPart isZero];
        
    }
    return self;
}

//
// initWithInt
//
// Wrapper that adds complex number support around the base class
//
- (instancetype)initWithInt:(signed int)newValue radix:(unsigned short)newRadix
{
    self = [super initWithInt:newValue radix:newRadix];
    
    if (self)
    {
        bcf_imaginary = [BigFloat bigFloatWithInt:0 radix:newRadix];
        bcf_has_imaginary = NO;
    }
    
    return self;
}

//
// initWithDouble
//
// Wrapper that adds complex number support around the base class
//
- (instancetype)initWithDouble:(double)newValue radix:(unsigned short)newRadix
{
    self = [super initWithDouble:newValue radix:newRadix];
    
    if (self)
    {
        bcf_imaginary = [BigFloat bigFloatWithInt:0 radix:newRadix];
        bcf_has_imaginary = NO;
    }
    
    return self;
}

//
// initWithString
//
// Wrapper that adds complex number support around the base class
// Note: we assume an exponent of 'e' where base 15 and higher numbers use character 'E'.
//
- (instancetype)initWithString:(NSString *)newValue radix:(unsigned short)newRadix {
    self = [super initWithInt:0 radix:newRadix];
    if (self && newValue.length > 0) {
        // break apart the string into real and imaginary pieces
        NSCharacterSet *signChars = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
        NSMutableString *number = [NSMutableString stringWithString:@""];
        NSString *inumber = @"";
        char ch = [newValue characterAtIndex:0];
        
        // remove leading sign -- if any
        if ([signChars characterIsMember:ch]) { [number appendFormat:@"%c", ch]; newValue = [newValue substringFromIndex:1]; }
        NSRange range = [newValue rangeOfCharacterFromSet:signChars];
        if (range.length > 0) {
            // check if this is an exponent
            NSRange expRange = [newValue rangeOfString:@"e"];
            if (expRange.length > 0 && expRange.location == range.location-1) {
                // search beyond the exponent
                range.location++; range.length = newValue.length - range.location;
                range = [newValue rangeOfCharacterFromSet:signChars options:0 range:range];
                if (range.length > 0) {
                    // This is likely the start of the second number
                    [number appendString:[newValue substringToIndex:range.location-1]];
                    inumber = [newValue substringFromIndex:range.location];
                } else {
                    // Only one number exists
                    if ([newValue hasSuffix:@"i"]) {
                        inumber = [NSString stringWithFormat:@"%@%@", number, newValue];        // transfer the sign
                        number = [NSMutableString stringWithString:@""];                        // clear the real part
                    } else {
                        number = [NSMutableString stringWithFormat:@"%@%@", number, newValue];  // copy the number
                    }
                }
            } else {
                // This is the start of the second number
                [number appendString:[newValue substringToIndex:range.location-1]];
                inumber = [newValue substringFromIndex:range.location];
            }
        } else {
            // only one number exists
            if ([newValue hasSuffix:@"i"]) {
                inumber = [NSString stringWithFormat:@"%@%@", number, newValue];        // transfer the sign
                number = [NSMutableString stringWithString:@""];                        // clear the real part
            } else {
                number = [NSMutableString stringWithFormat:@"%@%@", number, newValue];  // copy the number
            }
        }
        self = [super initWithString:number radix:newRadix];
        inumber = [inumber stringByReplacingOccurrencesOfString:@"i" withString:@""];    // remove the "i"
        bcf_imaginary = [BigFloat bigFloatWithString:inumber radix:newRadix];
        bcf_has_imaginary = ![bcf_imaginary isZero];
    }
    return self;
}

//
// initPiWithRadix
//
// Wrapper that adds complex number support around the base class
//
- (instancetype)initPiWithRadix:(unsigned short)newRadix
{
    self = [super initPiWithRadix:newRadix];
    
    if (self)
    {
        bcf_imaginary = [BigFloat bigFloatWithInt:0 radix:newRadix];
        bcf_has_imaginary = NO;
    }
    
    return self;
}

//
// initWithCoder
//
// Wrapper that adds complex number support around the base class
//
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    bcf_imaginary = [coder decodeObjectForKey:@"BCFImaginary"];
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
    return [[BigCFloat alloc] initWithReal:realPart imaginary:imaginaryPart];
}

//
// bigFloatWithMagnitude
//
// Returns an autoreleased complex number initialised with given polar coordinates
//
+ (BigCFloat*)bigFloatWithMagnitude:(BigFloat *)r angle:(BigFloat *)theta
{
    return [[BigCFloat alloc] initWithMagnitude:r angle:theta];
}

//
// bigFloatWithInt
//
// Wrapper that adds complex number support around the base class
//
+ (BigCFloat*)bigFloatWithInt:(signed int)newValue radix:(unsigned short)newRadix
{
    return [[BigCFloat alloc] initWithInt:newValue radix:newRadix];
}

//
// bigFloatWithDouble
//
// Wrapper that adds complex number support around the base class
//
+ (BigCFloat*)bigFloatWithDouble:(double)newValue radix:(unsigned short)newRadix
{
    return [[BigCFloat alloc] initWithDouble:newValue radix:newRadix];
}

//
// bigFloatWithString
//
// Wrapper that adds complex number support around the base class
//
+ (BigCFloat*)bigFloatWithString:(NSString *)newValue radix:(unsigned short)newRadix {
    return [[BigCFloat alloc] initWithString:newValue radix:newRadix];
}

//
// piWithRadix
//
// Wrapper that adds complex number support around the base class
//
+ (BigCFloat*)piWithRadix:(unsigned short)newRadix
{
    return [[BigCFloat alloc] initPiWithRadix:newRadix];
}

+ (BigCFloat *)one {
    return [BigCFloat bigFloatWithInt:1 radix:10];
}

+ (BigCFloat *)zero {
    return [BigCFloat bigFloatWithInt:0 radix:10];
}

+ (BigCFloat *)i; {
    return [BigCFloat bigFloatWithReal:[BigCFloat bigFloatWithInt:0 radix:10] imaginary:[BigCFloat bigFloatWithInt:1 radix:10]];
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
    return [self realPartCopy];
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
    return [self imaginaryPartCopy];
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
    
    return magnitude;
}

//
// magnitude
//
// Calculates the magnitude and returns it
//
- (BigFloat *)magnitude
{
    return [self magnitudeCopy];
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
            return [BigFloat bigFloatWithInt:0 radix:bf_radix];
    }
    
    angle = [bcf_imaginary copy];
    magnitude = [self magnitudeCopy];
    [angle divideBy:magnitude];
    [angle sinWithTrigMode:BF_radians inv:YES hyp:NO];
    
    if (bf_is_negative)
    {
        BigFloat *piMinusAngle;
        BigFloat *minusOne;
        
        minusOne = [BigFloat bigFloatWithInt:-1 radix:bf_radix];
        piMinusAngle = [minusOne copy];
        [piMinusAngle cosWithTrigMode:BF_radians inv:YES hyp:NO];
        
        if ([bcf_imaginary isNegative])
        {
            [piMinusAngle multiplyBy:minusOne];
        }
        
        [piMinusAngle subtract:angle];
        [angle assign:piMinusAngle];
        
    }
    
    
    return angle;
}

//
// angle
//
// Calculates the angle (phase)
//
- (BigFloat *)angle
{
    return [self angleCopy];
}

//
// conjugate
//
// Changes the sign of the imaginary part
//
- (void)conjugate
{
    BigFloat *minusOne;
    
    if (!bcf_has_imaginary) return;
    
    minusOne = [BigFloat bigFloatWithInt:-1 radix:bf_radix];
    [bcf_imaginary multiplyBy:minusOne];
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
- (void)deleteDigitUseComplement:(int)complement
{
    if (bcf_has_imaginary)
    {
        [bcf_imaginary deleteDigitUseComplement:complement];
        if ([bcf_imaginary isZero] && [bcf_imaginary getUserPoint] == 0)
        {
            bcf_has_imaginary = NO;
        }
        
        return;
    }
    
    [super deleteDigitUseComplement:complement];
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
    return [self copy];
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
        BigFloat    *magnitude = [self magnitudeCopy];
        
        [self assign:magnitude];
        
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
        BigCFloat    *cnum = (BigCFloat *)num;
        BigFloat    *firstTerm;
        BigFloat    *secondTerm;
        BigFloat    *imaginary;
        
        firstTerm = [self realPartCopy];
        [firstTerm multiplyBy:[cnum realPart]];
        secondTerm = [self imaginaryPartCopy];
        [secondTerm multiplyBy:cnum->bcf_imaginary];
        [firstTerm subtract:secondTerm];
        real = [firstTerm copy];
        
        
        firstTerm = [self imaginaryPartCopy];
        [firstTerm multiplyBy:[cnum realPart]];
        secondTerm = [self realPartCopy];
        [secondTerm multiplyBy:cnum->bcf_imaginary];
        [firstTerm add:secondTerm];
        imaginary = [firstTerm copy];
        
        [self assign:real];
        [bcf_imaginary assign:imaginary];
        
        bcf_has_imaginary = ![bcf_imaginary isZero];
        return;
    }
    
    real = [self realPart];
    [real multiplyBy:num];
    [super assign:real];
    
    if (bcf_has_imaginary)
    {
        [bcf_imaginary multiplyBy: num];
        bcf_has_imaginary = ![bcf_imaginary isZero];
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
        BigCFloat    *cnum = (BigCFloat *)num;
        BigFloat    *firstTerm;
        BigFloat    *secondTerm;
        BigFloat    *denominator;
        BigFloat    *imaginary;
        
        firstTerm = [cnum realPartCopy];
        [firstTerm multiplyBy:firstTerm];
        secondTerm = [cnum imaginaryPartCopy];
        [secondTerm multiplyBy:secondTerm];
        [firstTerm add:secondTerm];
        denominator = [firstTerm copy];
        
        
        firstTerm = [self realPartCopy];
        [firstTerm multiplyBy:[cnum realPart]];
        secondTerm = [self imaginaryPartCopy];
        [secondTerm multiplyBy:cnum->bcf_imaginary];
        [firstTerm add:secondTerm];
        [firstTerm divideBy:denominator];
        real = [firstTerm copy];
        
        
        firstTerm = [self imaginaryPartCopy];
        [firstTerm multiplyBy:[cnum realPart]];
        secondTerm = [self realPartCopy];
        [secondTerm multiplyBy:cnum->bcf_imaginary];
        [firstTerm subtract:secondTerm];
        [firstTerm divideBy:denominator];
        imaginary = [firstTerm copy];
        
        [self assign:real];
        [bcf_imaginary assign:imaginary];
        bcf_has_imaginary = ![bcf_imaginary isZero];
        return;
    }
    
    real = [self realPart];
    [real divideBy:num];
    [super assign:real];
    
    if (bcf_has_imaginary)
    {
        [bcf_imaginary divideBy: num];
        bcf_has_imaginary = ![bcf_imaginary isZero];
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
        cnum = (BigCFloat *)num;
    }
    
    // x % y = (x - (int(x/y) * y))
    quotient = [self copy];
    [quotient divideBy:cnum];
    [quotient wholePart];
    [quotient multiplyBy:cnum];
    [self subtract:quotient];
    
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
        
        bcf_has_imaginary = ![bcf_imaginary isZero];
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
    
}

//
// raiseToPower
//
// Wrapper that adds complex number support around the base class
//
- (void)raiseToPower:(BigFloat*)num
{
    BigCFloat    *cnum;

    if (!bf_is_valid) return;
    
    cnum = (BigCFloat*)num;
    if (!bcf_has_imaginary && !cnum->bcf_has_imaginary)
    {
        [super raiseToPower:num];
        return;
    }
    
    // Promote num to a BigCFloat
    cnum = (BigCFloat*)num;
    if ([self isZero])
    {
        // Zero raised to anything except zero is zero (provided exponent is valid)
        bf_is_valid = [num isValid];
        if ([cnum isZero]) { [self assign:[BigCFloat one]]; }
        return;
    }
    [self ln];
    [self multiplyBy: cnum];
    [self powerOfE];
}

//
// sqrt
//
// Wrapper that adds complex number support around the base class
//
- (void)sqrt
{
    BigFloat     *r;
    BigFloat     *theta;
    BigFloat     *two = [[BigFloat alloc] initWithInt:2 radix:bf_radix];
    BigCFloat    *value;
    
    if (!bf_is_valid) { return; }
    
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
    
}

//
// cbrt
//
// Wrapper that adds complex number support around the base class
//
- (void)cbrt
{
    BigFloat     *r;
    BigFloat     *theta;
    BigFloat     *three = [[BigFloat alloc] initWithInt:3 radix:bf_radix];
    BigCFloat    *value;
    
    if (!bf_is_valid) { return; }
    
    if (!bcf_has_imaginary)
    {
        [super cbrt];
        return;
    }
    
    r = [self magnitudeCopy];
    theta = [self angleCopy];
    
    [r cbrt];
    [theta divideBy:three];
    value = [[BigCFloat alloc] initWithMagnitude:r angle:theta];
    [self assign:value];
    
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

- (void)convertToMode:(BFTrigMode)mode {
    if (mode != BF_radians)
    {
        BigCFloat *pi = [BigCFloat piWithRadix:bf_radix];
        if (mode == BF_degrees)
        {
            BigCFloat *oneEighty = [BigCFloat bigFloatWithInt:180 radix: bf_radix];
            [self divideBy:oneEighty];
        }
        else if (mode == BF_gradians)
        {
            BigCFloat *twoHundred = [BigCFloat bigFloatWithInt:200 radix: bf_radix];
            [self divideBy:twoHundred];
        }
        
        [self multiplyBy:pi];
    }
}

- (void)convertFromMode:(BFTrigMode)mode {
    if (mode != BF_radians)
    {
        BigCFloat *pi = [BigCFloat piWithRadix:bf_radix];
        if (mode == BF_degrees)
        {
            BigCFloat *oneEighty = [[BigCFloat alloc] initWithInt: 180 radix: bf_radix];
            [self multiplyBy:oneEighty];
        }
        else if (mode == BF_gradians)
        {
            BigCFloat *twoHundred = [[BigCFloat alloc] initWithInt: 200 radix: bf_radix];
            [self multiplyBy:twoHundred];
        }
        
        [self divideBy:pi];
    }
}

//
// sinWithTrigMode
//
// Wrapper that adds complex number support around the base class
//
- (void)sinWithTrigMode:(BFTrigMode)mode inv:(BOOL)useInverse hyp:(BOOL)useHyp
{
    BigCFloat    *firstTerm;
    BigCFloat    *secondTerm;
    BigCFloat    *thirdTerm;
    BigCFloat    *one;
    BigCFloat    *two;
    BigCFloat    *zero;
    BigCFloat    *minusOne;
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
        [super sinWithTrigMode:mode inv:useInverse hyp:useHyp];
        return;
    }
    
    two = [[BigCFloat alloc] initWithInt:2 radix: bf_radix];
    zero = [[BigCFloat alloc] initWithInt:0 radix: bf_radix];
    minusOne = [[BigCFloat alloc] initWithInt:-1 radix: bf_radix];

    if (useInverse == NO)
    {
        [self convertToMode:mode];
        
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
    }
    else
    {
        // arcsin(z) = -i ln (iz + sqrt(1 - z^2))
        firstTerm = [self copy];
        [firstTerm multiplyBy:firstTerm];
        secondTerm = [one copy];
        [secondTerm subtract:firstTerm];
        [secondTerm sqrt];
        firstTerm = [[BigCFloat alloc]
            initWithReal:zero
            imaginary:one
        ];
        [firstTerm multiplyBy:self];
        [firstTerm add:secondTerm];
        [firstTerm ln];
        secondTerm = [[BigCFloat alloc]
            initWithReal:zero
            imaginary:minusOne
        ];
        [firstTerm multiplyBy:secondTerm];
        [self assign:firstTerm];
        
        [self convertFromMode:mode];
    }
    
}

//
// cosWithTrigMode
//
// Wrapper that adds complex number support around the base class
//
- (void)cosWithTrigMode:(BFTrigMode)mode inv:(BOOL)useInverse hyp:(BOOL)useHyp
{
    BigCFloat    *firstTerm;
    BigCFloat    *secondTerm;
    BigCFloat    *thirdTerm;
    BigCFloat    *one;
    BigCFloat    *two;
    BigCFloat    *zero;
    BigCFloat    *minusOne;
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
        [super cosWithTrigMode:mode inv:useInverse hyp:useHyp];
        return;
    }
    
    two = [[BigCFloat alloc] initWithInt:2 radix: bf_radix];
    zero = [[BigCFloat alloc] initWithInt:0 radix: bf_radix];
    minusOne = [[BigCFloat alloc] initWithInt:-1 radix: bf_radix];
    
    if (useInverse == NO)
    {
        [self convertToMode:mode];
        
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
        
    }
    else
    {
        // arccos(z) = pi/2 - arcsin(z)
        [self sinWithTrigMode:mode inv:useInverse hyp:useHyp];
        
        firstTerm = [[BigCFloat alloc] initPiWithRadix:bf_radix];
        [firstTerm divideBy:two];
        [firstTerm subtract:self];
        [self assign:firstTerm];
        
        [self convertFromMode:mode];
//        if (mode != BF_radians)
//        {
//            if (mode == BF_degrees)
//            {
//                BigCFloat *oneEighty = [[BigCFloat alloc] initWithInt: 180 radix: bf_radix];
//                [self multiplyBy:oneEighty];
//            }
//            else if (mode == BF_gradians)
//            {
//                BigCFloat *twoHundred = [[BigCFloat alloc] initWithInt: 200 radix: bf_radix];
//                [self multiplyBy:twoHundred];
//            }
//            
//            [self divideBy:pi];
//        }

    }
    
}

//
// tanWithTrigMode
//
// Wrapper that adds complex number support around the base class
//
- (void)tanWithTrigMode:(BFTrigMode)mode inv:(BOOL)useInverse hyp:(BOOL)useHyp
{
    BigCFloat    *firstTerm;
    BigCFloat    *secondTerm;
    BigCFloat    *thirdTerm;
    BigCFloat    *one;
    BigCFloat    *minushalf;
    BigCFloat    *zero;

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
    minushalf = [[BigCFloat alloc] initWithDouble:-0.5 radix: bf_radix];
    zero = [[BigCFloat alloc] initWithInt:0 radix: bf_radix];

    if (useInverse == NO)
    {
        [self convertToMode:mode];
        
        // tan(z) = sin(z) / cos(z)
        firstTerm = [self copy];
        [firstTerm sinWithTrigMode:mode inv:useInverse hyp:useHyp];
        secondTerm = [self copy];
        [secondTerm cosWithTrigMode:mode inv:useInverse hyp:useHyp];
        [self assign:firstTerm];
        [self divideBy:secondTerm];
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
        [firstTerm add:one];
        
        [firstTerm debugDisplay];
        [secondTerm debugDisplay];
        
        thirdTerm = [firstTerm copy];
        [thirdTerm divideBy:secondTerm];
        [thirdTerm ln];

        [thirdTerm debugDisplay];

        firstTerm = [[BigCFloat alloc]
                initWithReal:zero
                imaginary:minushalf
        ];
        [thirdTerm multiplyBy:firstTerm];
        [self assign:thirdTerm];
        
        [self convertFromMode:mode];
//        if (mode != BF_radians)
//        {
//            if (mode == BF_degrees)
//            {
//                BigCFloat *oneEighty = [[BigCFloat alloc] initWithInt: 180 radix: bf_radix];
//                [self multiplyBy:oneEighty];
//            }
//            else if (mode == BF_gradians)
//            {
//                BigCFloat *twoHundred = [[BigCFloat alloc] initWithInt: 200 radix: bf_radix];
//                [self multiplyBy:twoHundred];
//            }
//            
//            [self divideBy:pi];
//        }
        
    }

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
- (void)bitnotWithComplement:(int)complement
{
    BigFloat *real;
    
    if (!bf_is_valid)
    {
        return;
    }
    
    real = [self realPart];
    [real bitnotWithComplement:complement];
    [super assign:real];
    
    [bcf_imaginary bitnotWithComplement:complement];
}

//
// andWith
//
// Wrapper that adds complex number support around the base class
//
- (void)andWith:(BigFloat*)num usingComplement:(int)complement
{
    if (!bf_is_valid)
    {
        return;
    }
    
    if ([num isKindOfClass:[BigCFloat class]])
    {
        BigCFloat *cnum = (BigCFloat*)num;
        
        [super andWith:cnum usingComplement:complement];
        [bcf_imaginary andWith:cnum->bcf_imaginary usingComplement:complement];
        return;
    }
    
    [self abs];
    [super andWith:num usingComplement:complement];
}

//
// orWith
//
// Wrapper that adds complex number support around the base class
//
- (void)orWith:(BigFloat*)num usingComplement:(int)complement
{
    if (!bf_is_valid)
    {
        return;
    }
    
    if ([num isKindOfClass:[BigCFloat class]])
    {
        BigCFloat *cnum = (BigCFloat*)num;
        
        [super orWith:cnum usingComplement:complement];
        [bcf_imaginary orWith:cnum->bcf_imaginary usingComplement:complement];
        return;
    }
    
    [self abs];
    [super orWith:num usingComplement:complement];
}

//
// xorWith
//
// Wrapper that adds complex number support around the base class
//
- (void)xorWith:(BigFloat*)num usingComplement:(int)complement
{
    if (!bf_is_valid)
    {
        return;
    }
    
    if ([num isKindOfClass:[BigCFloat class]])
    {
        BigCFloat *cnum = (BigCFloat*)num;
        
        [super xorWith:cnum usingComplement:complement];
        [bcf_imaginary xorWith:cnum->bcf_imaginary usingComplement:complement];
        return;
    }
    
    [self abs];
    [super xorWith:num usingComplement:complement];
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
    NSString    *string;
    
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
    NSString    *string;
    NSString    *mantissa;
    NSString    *exponent;

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
    NSString    *string;
    
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

    printf("%s\n", string.UTF8String);
}

@end
