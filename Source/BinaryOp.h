// ##############################################################
//  BinaryOp.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun May 04 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "Expression.h"

//
// About BinaryOp
//
// A binary operation is one that requires two inputs, typically one before the operator
// and one afterwards. Examples include +, -, and, x^y, etc.
//
// Most of this class exists to simply extend the default node behaviour to include a
// second child node.
//
// The particular difficulty with a this class is that there are really three types of binary
// operator that have been smushed (sure, that's a word) together: loosely binding (+, -),
// normal binding (*, /, and) and tightly binding (x^y). This different behaviour comes
// out of the "order of operations". As such, theses different behaviours should have
// been different classes. Oh well.
//

@interface BinaryOp : Expression
{
@protected
	int					op;
	BOOL				userSkippedLeft;
	Expression		*leftChild;
	NSRect			leftChildNaturalBounds;
	NSRect			leftChildDisplayBounds;
}
- (instancetype)initWithParent:(Expression*)newParent manager:(DataManager*)newManager
	leftChild:(Expression*)newChild andOp:(int)newOp;
- (instancetype)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)appendDigit:(int)digit;
- (void)appendOpToPath:(NSBezierPath*)path atLevel:(int)level;
- (void)binaryOpPressed:(int)newOp;
- (void)bracketPressed;
- (void)childChanged:(Expression*)oldChild replacedWith:(Expression*)newChild;
- (void)childDeleted:(Expression*)oldChild;
- (void)constantPressed:(int)constant;
- (void)deleteDigit;
- (void)equalsPressed;
- (void)exponentPressed;
- (void)expressionInserted:(Expression*)newExpression;
@property (NS_NONATOMIC_IOSONLY, getter=getCaretPoint, readonly) NSPoint caretPoint;
@property (NS_NONATOMIC_IOSONLY, getter=getExpressionString, readonly, copy) NSString *expressionString;
@property (NS_NONATOMIC_IOSONLY, getter=getValue, readonly, strong) BigCFloat *value;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) Expression *leftChild;
- (void)managerChanged:(DataManager*)newManager;
- (Expression*)nodeContainingPoint:(NSPoint)point;
- (NSBezierPath*)pathAtLevel:(int)level;
- (void)postOpPressed:(int)op;
- (void)preOpPressed:(int)op;
- (void)receiveBounds:(NSRect)bounds;
- (void)refresh;
- (void)replaceChild:(Expression*)oldChild withBinOp:(int)newOp;
- (void)replaceChild:(Expression*)node withPostOp:(int)newOp;
- (void)replaceChild:(Expression*)node withValue:(BigCFloat*)newOp;
- (void)userPointPressed;
- (void)valueInserted:(BigCFloat*)newValue;

@end
