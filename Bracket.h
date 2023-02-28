// ##############################################################
//  Bracket.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun May 25 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Foundation/Foundation.h>
#import "Expression.h"

//
// About Bracket
//
// A basic node which exists to wrap a sub-tree.
//

@interface Bracket : Expression
{
@protected
	bool	closed;
}
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithParent:(Expression*)newParent andManager:(DataManager*)newManager NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)binaryOpPressed:(int)op;
- (void)closeBracketPressed;
- (void)deleteDigit;
- (void)equalsPressed;
@property (NS_NONATOMIC_IOSONLY, getter=getExpressionString, readonly, copy) NSString *expressionString;
- (NSBezierPath*)pathAtLevel:(int)level;
- (void)postOpPressed:(int)op;

@end
