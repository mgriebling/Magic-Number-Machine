// ##############################################################
//  Expression.h
//  Magic Number Machine
//
//	Base class for all elements in an Expression tree. Default implementation is of
//	a no-op. Relies on the Value implementation to handle any input.
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Foundation/Foundation.h>

@class BigCFloat;
@class DataManager;

//
// About Expression
//
// Expression forms the basis for all the classes in the expression tree. The
// expression tree contains all the data displayed in the ExpressionView of
// Magic Number Machine.
//
// As such, the family of classes which derive from this are the most important
// classes in the program. As the hierarchy parent, this class implements
// most of the default behaviours for Expression nodes.
//
// An expression tree must be headed by a TreeHead (which stops anything
// trying to propagate up past the head of the tree).
//
// An expression tree is built with branches that are operations: BinaryOp, Bracket,
// PostOp, PreOp. The leaves of the tree (at the end of each branch) are either
// Constants or Values (both derive from Constant and can have no children).
//
// The Expression classes (perhaps wrongly) include two types of functionality:
// operational behaviour (creating the tree as the user enters it, passing messages
// through the tree and telling the tree to calculate its result) and display behaviour.
// Anyone who has studied Document/View architectures may tell you this is the
// wrong way to go. I say: I don't care. Yes, the display methods are largely
// independent to the other methods, but to separate them out into specific
// view classes would create more work that I care to do.
//

@interface Expression : NSObject <NSCoding>
{
@protected
	BigCFloat		*value;
	Expression		*child;
	Expression		*parent;
	DataManager	*manager;
	NSBezierPath	*expressionPath;
	NSRect			displayBounds;
	NSRect			naturalBounds;
	NSRect			childNaturalBounds;
	NSRect			childDisplayBounds;
	BOOL			isInputPoint;
	int 			pathValidAt;
	BOOL			isBoundsValid;
	BOOL			valueValid;
}
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithParent:(Expression*)newParent andManager:(DataManager*)newManager NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
- (void)encodeWithCoder:(NSCoder *)coder;
+ (double)scaleWithLevel:(int)level;
- (void)appendDigit:(int)digit;
- (void)binaryOpPressed:(int)op;
- (void)bracketPressed;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) Expression *child;
- (void)childChanged:(Expression*)oldChild replacedWith:(Expression*)newChild;
- (void)childDeleted:(Expression*)oldChild;
- (void)clear;
- (void)closeBracketPressed;
- (void)constantPressed:(int)constant;
- (void)deleteDigit;
- (void)equalsPressed;
- (void)exponentPressed;
- (void)expressionInserted:(Expression*)newExpression;
@property (NS_NONATOMIC_IOSONLY, getter=getCaretPoint, readonly) NSPoint caretPoint;
@property (NS_NONATOMIC_IOSONLY, getter=getDisplayBounds, readonly) NSRect displayBounds;
@property (NS_NONATOMIC_IOSONLY, getter=getValue, readonly, strong) BigCFloat *value;
//@property (NS_NONATOMIC_IOSONLY, getter=getValue, readonly, strong) BigCFloat *value;
@property (NS_NONATOMIC_IOSONLY, getter=getExpressionString, readonly, copy) NSString *expressionString;
- (NSBezierPath*)getValuePathWithLevel:(int)level;
- (void)inputPoint;
- (void)managerChanged:(DataManager*)newManager;
- (Expression*)nodeContainingPoint:(NSPoint)point;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) Expression *parent;
- (void)parentChanged:(Expression*)newParent;
- (NSBezierPath*)pathAtLevel:(int)level;
- (void)postOpPressed:(int)op;
- (void)preOpPressed:(int)op;
- (void)receiveBounds:(NSRect)bounds;
- (void)refresh;
- (void)replaceChild:(Expression*)node withBinOp:(int)newOp;
- (void)replaceChild:(Expression*)node withPostOp:(int)newOp;
- (void)replaceChild:(Expression*)node withValue:(BigCFloat*)newOp;
- (void)shiftValue:(BOOL)left;
- (void)userPointPressed;
- (void)valueChanged;
- (void)valueInserted:(BigCFloat*)newValue;

@end
