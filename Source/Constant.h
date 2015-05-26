// ##############################################################
//  Constant.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Wed May 14 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Foundation/Foundation.h>

#import "Expression.h"
#import "ExpressionSymbols.h"

//
// About Constant
//
// This class exists to handle the two mathematical constants that can be entered
// as though they are numbers: pi and i.
//
// Most of the behaviour in this class comes from the fact that a Constant cannot
// have a child node, so a new node must be created every time one is required.
//
// Since this class handles a lot of the behaviour for numbers entered into an
// expression, it also forms the basis for Value (the user entered value class). 
//



//
// Constant values were updated from NIST to the known accuracies as of January 2008.
// A few constant names were changed to make them unique and avoid confusion with
// other constants since these names are used in the equations.
//
// Update by Michael Griebling

@interface Constant : Expression {
	@protected
	enum ConstType constant;
	bool negative;
}

- (instancetype)initWithParent:(Expression*)newParent manager:(DataManager*)newManager andConstant:(int)newConstant;
- (instancetype)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

- (void)appendDigit:(int)digit;
- (void)bracketPressed;
- (void)constantPressed:(enum ConstType)newConstant;
- (void)expressionInserted:(Expression*)newExpression;
@property (NS_NONATOMIC_IOSONLY, getter=getExpressionString, readonly, copy) NSString *expressionString;
- (NSBezierPath*)pathAtLevel:(int)level;
- (void)preOpPressed:(int)newOp;
- (void)valueInserted:(BigCFloat*)newValue;

@end