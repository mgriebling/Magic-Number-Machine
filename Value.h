// ##############################################################
//  Value.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "Constant.h"

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
@interface Value : Constant
{
@protected
	int					userPointState;
	int					postPoint;
	int					postImaginaryPoint;
	int					imaginaryPointState;
	BOOL				hasExponent;
	BOOL				hasImaginary;
	BOOL				hasImaginaryExponent;
	BOOL				requiresReprocessing;
	int					usesComplement;
}
- (instancetype)initWithParent:(Expression*)newParent andManager:(DataManager*)newManager;
- (instancetype)initWithParent:(Expression*)newParent value:(BigCFloat*)newValue andManager:(DataManager*)newManager;
- (instancetype)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)appendDigit:(int)digit;
- (void)clear;
- (void)deleteDigit;
- (void)exponentPressed;
@property (NS_NONATOMIC_IOSONLY, getter=getExpressionString, readonly, copy) NSString *expressionString;
- (void)generateValuePath;
//@property (NS_NONATOMIC_IOSONLY, getter=getExpressionString, readonly, copy) NSString *expressionString;
- (NSBezierPath*)pathAtLevel:(int)level;
- (void)userPointPressed;
- (NSString *)insertThousands:(NSString *)mantissa;

@end
