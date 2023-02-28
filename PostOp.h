// ##############################################################
//  PostOp.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun May 25 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Foundation/Foundation.h>
#import "Expression.h"

//
// About PostOp
//
// A PostOp is an operator that goes after the number. The two post operations are
// square (x^2) and factorial (x!).
//
// Only minor behaviour changes relative to the inherited functionality  are required
// for this class.
//
@interface PostOp : Expression
{
@protected
	int					op;
}
- (instancetype)initWithParent:(Expression*)newParent manager:(DataManager*)newManager
	child:(Expression*)newChild andOp:(int)newOp ;
- (instancetype)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
@property (NS_NONATOMIC_IOSONLY, getter=getValue, readonly, strong) BigCFloat *value;
- (void)appendOpToPath:(NSBezierPath*)path atLevel:(int)level;
@property (NS_NONATOMIC_IOSONLY, getter=getExpressionString, readonly, copy) NSString *expressionString;
- (NSBezierPath*)pathAtLevel:(int)level;

@end
