// ##############################################################
//  PreOp.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Wed May 14 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Foundation/Foundation.h>
#import "Expression.h"

//
// About PreOp
//
// The majority of functions that can be entered are PreOps. Any function that normally
// appears as: function(child) is a PreOp.
//
// Most of this class is devoted to large switch statements that simply apply the relevant
// function for calculations and display.
//
@interface PreOp : Expression
{
@protected int	op;
}
- (instancetype)initWithParent:(Expression*)newParent manager:(DataManager*)newManager
	andOp:(int)newOp;
- (instancetype)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)appendOpToPath:(NSBezierPath*)path atLevel:(int)level;
@property (NS_NONATOMIC_IOSONLY, getter=getExpressionString, readonly, copy) NSString *expressionString;
@property (NS_NONATOMIC_IOSONLY, getter=getValue, readonly, strong) BigCFloat *value;
- (NSBezierPath*)pathAtLevel:(int)level;
- (void)postOpPressed:(int)op;
- (void)replaceChild:(Expression*)oldChild withBinOp:(int)newOp;

@end