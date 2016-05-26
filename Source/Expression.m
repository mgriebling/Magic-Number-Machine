// ##############################################################
//  Expression.m
//  Magic Number Machine
//
//	Base class for all elements in an Expression tree. Default implementation is of
//	a no-op. Relies on the Value implementation to handle any input.
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "Expression.h"
#import "Value.h"
#import "BinaryOp.h"
#import "PostOp.h"
#import "PreOp.h"
#import "BigCFloat.h"
#import "DataManager.h"
#import "Bracket.h"

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
@implementation Expression

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

//
// initWithParent
//
// Initialises all of the class's variables.
//
- (instancetype)initWithParent:(Expression*)newParent andManager:(DataManager*)newManager
{
	self = [super init];
	if (self)
	{
		child = nil;
		manager = newManager;
		parent = newParent;
		expressionPath = [NSBezierPath bezierPath];
		isInputPoint = NO;
		pathValidAt = -1;
		isBoundsValid = NO;
		displayBounds = NSZeroRect;
		naturalBounds = NSZeroRect;
		childNaturalBounds = NSZeroRect;
		childDisplayBounds = NSZeroRect;
		value = [BigCFloat zero];
		valueValid = YES;
	}
	return self;
}

//
// initWithCoder
//
// Part of the NSCoder protocol. Required for copy and paste.
//
- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	
	child = [coder decodeObjectForKey:@"MEChild"];
	manager = nil;
	parent = [coder decodeObjectForKey:@"MEParent"];
	expressionPath = [NSBezierPath bezierPath];
	isInputPoint = NO;
	pathValidAt = -1;
	isBoundsValid = NO;
	displayBounds = NSZeroRect;
	naturalBounds = NSZeroRect;
	childNaturalBounds = NSZeroRect;
	childDisplayBounds = NSZeroRect;
	value = [BigCFloat zero];
	valueValid = NO;
	
	return self;
}

//
// encodewithCoder
//
// Part of the NSCoder protocol. Required for copy and paste.
//
- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:child forKey:@"MEChild"];
	[coder encodeConditionalObject:parent forKey:@"MEParent"];
}

//
// dealloc
//
// Releases all retained and allocated memory.
//

//
// scaleWithLevel
//
// A public static function that returns the different in scale between
// a regular number and the numerator or denominator of a fraction.
//
+ (double)scaleWithLevel:(int)level
{
	return (level >= 2) ? (1.0 / pow(1.5, level - 1.0)) : 1.0;
}

//
// appendDigit
//
// Default behaviour is to create a child and send this message to it.
//
- (void)appendDigit:(int)digit
{
	// Create a value at the child node and let it handle the digit
	if (child == nil)
	{
		child = [[Value alloc] initWithParent:self andManager:manager];
		
		[child inputPoint];
		[child appendDigit:digit];
	}
	else
	{
		// We already have a closed child node so this action is the next factor in the term
		[self binaryOpPressed:'.'];
		[[manager getInputPoint] appendDigit:digit];
	}
}

//
// binaryOpPressed
//
// Pass this message through to the parent
//
- (void)binaryOpPressed:(int)op
{
	NSAssert(parent != nil, @"Expression tree node has no parent (it needs one).\n");
	
	// Tell the parent to replace us with a binary operation
	// We will be placed on the left leaf
	[parent replaceChild:self withBinOp:op];
}

//
// bracketPressed
//
// If no child exists, puts a bracket at the child, otherwise creates the bracket as a sibling
// of the bracket.
//
- (void)bracketPressed
{
	if (child != nil)
	{
		// We already have a closed child node so this action is the next factor in the term
		[self binaryOpPressed:'.'];
		[[manager getInputPoint] bracketPressed];
	}
	else
	{
		child = [[Bracket alloc] initWithParent:self andManager:manager];
		[child inputPoint];
		[child valueChanged];
	}
}

//
// child 
//
// Provides basic access to the child of this node
//
- (Expression*)child
{
	return child;
}

//
// childChanged
//
// Accept a new child node if someone else decides to change it.
//
- (void)childChanged:(Expression*)oldChild replacedWith:(Expression*)newChild
{
	NSAssert
	(
		(oldChild == nil && child == nil) || [oldChild isEqual:child], @"Attempt to change child of Expression tree node that doesn't exist.\n"
	);
	
	
	if (newChild != nil)
	{
		child = newChild;
		[child parentChanged:self];
	}
	else
	{
		child = nil;
	}
	
	[self valueChanged];
}

//
// childDeleted
//
// Helps the node come to terms with the death of its child.
//
- (void)childDeleted:(Expression*)oldChild
{
	NSAssert
	(
		[oldChild isEqual:child], @"Attempt to change child of Expression tree node that doesn't exist.\n"
	);

	child = nil;
	[self inputPoint];
	[self valueChanged];
}

//
// clear
//
// Does nothing for classes other than Value.
//
- (void)clear
{
	// Has no real effect by default.
}

//
// closeBracketPressed
//
// Pass this message up the tree
//
- (void)closeBracketPressed
{
	if (parent != nil)
		[parent closeBracketPressed];
}

//
// constantPressed
//
// Puts the constant at the child if no child exists, otherwise puts the constant as a sibling
// of the child.
//
- (void)constantPressed:(int)constant
{
	if (child != nil)
	{
		// We already have a closed child node so this action is the next factor in the term
		[self binaryOpPressed:'.'];
		[[manager getInputPoint] constantPressed:constant];
	}
	else
	{
		child = [[Constant alloc] initWithParent:self manager:manager andConstant:constant];
		[child inputPoint];
		[child valueChanged];
	}
}

//
// deleteDigit
//
// If there is a child, we delete it, otherwise we delete ourselves.
//
- (void)deleteDigit
{
	// If we receive a delete message then try to delete ourselves
	if (child != nil)
	{
		[child inputPoint];
		[child deleteDigit];
	}
	else if (parent != nil)
	{
		[parent childDeleted:self];
	}
}

//
// equalsPressed
//
// Passes this message to the child node
//
- (void)equalsPressed
{
	if (child != nil)
	{
		[child equalsPressed];
	}
}

//
// exponentPressed
//
// Default behaviour is to create a child and send this message to it.
//
- (void)exponentPressed
{
	// Create a value at the child node and let it handle the digit
	if (child == nil)
	{
		child = [[Value alloc] initWithParent:self andManager:manager];
		
		[child inputPoint];
		[child exponentPressed];
	}
	else
	{
		// We already have a closed child node so this action is the next factor in the term
		[self binaryOpPressed:'.'];
		[[manager getInputPoint] exponentPressed];
	}
}

//
// expressionInserted
//
// If there is no child, simply insert the expression. Otherwise put this expression after
// the child.
//
- (void)expressionInserted:(Expression*)newExpression
{
	if (child != nil)
	{
		// We already have a closed child node so this action is the next factor in the term
		[self binaryOpPressed:'.'];
		[[manager getInputPoint] expressionInserted:newExpression];
	}
	else
	{
		child = newExpression;
		[child managerChanged:manager];
		[child inputPoint];
		[child parentChanged:self];
		[child refresh];
	}
}

//
// getCaretPoint
//
// Return the default caret pont (3 pixels to the right of the baseline of this node)
//
- (NSPoint)getCaretPoint
{
	NSPoint	caretPoint;
	
	NSAssert(isBoundsValid == YES, @"Display bounds requested before being received.\n");
	
	caretPoint = displayBounds.origin;
	caretPoint.x += displayBounds.size.width + 3.0;
	
	return caretPoint;
}

//
// getDisplayBounds
//
// Provides access to the display bounds of this node
//
- (NSRect)getDisplayBounds
{
	NSAssert(isBoundsValid == YES, @"Display bounds requested before being received.\n");
	
	return displayBounds;
}

//
// getValue
//
// Updates the value if it is not valid and then returns this class's calculated value
//
- (BigCFloat*)getValue
{
	if (valueValid == NO)
	{
		if (child != nil)
		{
			value = [child getValue];
		}
		valueValid = YES;
	}
	
	return value;
}

//
// getExpressionString
//
// Converts the child to a string and returns it.
//
- (NSString*)getExpressionString
{
	NSString *resultString = @"";
	
	if (child != nil)
		resultString = [resultString stringByAppendingString:[child getExpressionString]];

	return resultString;
}

//
// getValuePathWithLevel
//
// Returns an object that is the result value of this class as a bezier path
//
- (NSBezierPath*)getValuePathWithLevel:(int)level
{
	Value *result = [[Value alloc] initWithParent:nil value:[self getValue] andManager:manager];
	NSBezierPath *resultPath = [result pathAtLevel:level];
	
	// There are situations where Value (while drawing the BigFloat) will correct precision errors
	// in the value. We want to update the result to have these fixes.
	[value assign:[result getValue]];
	
	return resultPath;
}

//
// inputPoint
//
// Become the input point for the current expression
//
- (void)inputPoint
{
	// Become the input point simply by telling the manager
	[manager setInputPoint:self];
}

//
// managerChanged
//
// Responds to a change in manager and passes the message to the child to do the same
//
- (void)managerChanged:(DataManager*)newManager
{
	manager = newManager;
	if (child != nil)
	{
		[child managerChanged:newManager];
	}
}

//
// nodeContainingPoint
//
// Returns the node that contains the given pixel point, or nil if the given pixel point
// is not contained by this node or one of its children.
//
- (Expression*)nodeContainingPoint:(NSPoint)point
{
	if (isBoundsValid == NO)
	{
		return self;
	}
	
	if (NSMouseInRect(point, displayBounds, NO))
	{
		Expression *childResult = nil;
		
		if (child != nil)
		{
			childResult = [child nodeContainingPoint:point];
		}
		
		if (childResult != nil)
			return childResult;
		
		return self;
	}
	
	return nil;
}

//
// parent
//
// Provides access to this node's parent
//
- (Expression*)parent
{
	return parent;
}

//
// parentChanged
//
// Accepts a change in parent. Its just like adoption or when your birth parent divorce
// and remarry.
//
- (void)parentChanged:(Expression*)newParent
{
	parent = newParent;
}

//
// pathAtLevel
//
// Draws the node and its children into a bezier path.
//
- (NSBezierPath*)pathAtLevel:(int)level
{
	NSBezierPath		*copy;
	
	if (pathValidAt != level)
	{
		expressionPath = [NSBezierPath bezierPath];
		
		// Append the child's path if it exists.
		if (child != nil)
		{
			[expressionPath appendBezierPath:[child pathAtLevel:level]];
		}
		
		// Record that the path has been properly updated since the last invalidation
		if (![expressionPath isEmpty])
			naturalBounds = [expressionPath bounds];
		else
			naturalBounds = NSZeroRect;
		if (![expressionPath isEmpty])
			childNaturalBounds = [expressionPath bounds];
		else
			childNaturalBounds = NSZeroRect;
		pathValidAt = level;
	}
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:expressionPath];
	
	return copy;
}

//
// postOpPressed
//
// Passes the message up the tree.
//
- (void)postOpPressed:(int)op
{
	NSAssert(parent != nil, @"Expression tree node has no parent (it needs one).\n");

	// Create a postOp at the child node and set it as the input point
	[parent replaceChild:self withPostOp:op];
}

//
// preOpPressed.
//
// Create a child with the preOp or create a sibling to the child and put it there.
//
- (void)preOpPressed:(int)op
{
	if (child != nil)
	{
		// We already have a closed child node so this action is the next factor in the term
		[self binaryOpPressed:'.'];
		[[manager getInputPoint] preOpPressed:op];
	}
	else
	{
		child = [[PreOp alloc] initWithParent:self manager:manager andOp:op];
		[child inputPoint];
		[child valueChanged];
	}
}

//
// receiveBounds
//
// Once this class is displayed by the ExpressionView, it sends this back to us so that
// we can know exactly where we were displayed. This is important for hit testing (we
// can't determine what the user clicked on unless we know where we were drawn).
//
- (void)receiveBounds:(NSRect)bounds
{
	NSBezierPath			*childPath = [NSBezierPath bezierPathWithRect:childNaturalBounds];
	NSAffineTransform	*childTransform = [NSAffineTransform	transform];
	
	displayBounds = bounds;
	
	if (child != nil)
	{
		if (!NSIsEmptyRect(naturalBounds))
		{
			[childTransform
				translateXBy:displayBounds.origin.x
				yBy:displayBounds.origin.y
			];
			[childTransform
				scaleXBy:displayBounds.size.width / naturalBounds.size.width
				yBy:displayBounds.size.height / naturalBounds.size.height
			];
			[childTransform
				translateXBy:-naturalBounds.origin.x
				yBy:-naturalBounds.origin.y
			];
			[childPath transformUsingAffineTransform:childTransform];

			childDisplayBounds = [childPath bounds];
		}
		else
		{
			childDisplayBounds = bounds;
		}
		
		[child receiveBounds:childDisplayBounds];
	}
	
	isBoundsValid = YES;
}

//
// refresh
//
// Some operations require that the node recalculate. This method achieves this and
// tells the child to do the same.
//
- (void)refresh
{
	if (child != nil)
		[child refresh];
	else
		[self valueChanged];
}

//
// replaceChild
//
// Does what its told and replaces the child node.
//
- (void)replaceChild:(Expression*)oldChild withBinOp:(int)newOp
{
	if (child == nil)
	{
		NSAssert(oldChild == nil, @"Attempt to change child of Expression tree node that doesn't exist.\n");
		
		// Create the new child and set it as the input point
		child = [[BinaryOp alloc] initWithParent:self manager:manager leftChild:nil andOp:newOp];
	}
	else
	{
		NSAssert
		(
			[oldChild isEqual:child], @"Attempt to change child of Expression tree node that doesn't exist.\n"
		);

		// We pass ownership of the old child to the new child
		
		// Create the new child and set it as the input point
		child = [[BinaryOp alloc] initWithParent:self manager:manager leftChild:child andOp:newOp];
	}
	
	[child inputPoint];
	[child valueChanged];
}

//
// replaceChild
//
// Does what its told and replaces the child node.
//
- (void)replaceChild:(Expression*)oldChild withPostOp:(int)newOp
{
	if
	(
		(child == nil && oldChild == nil)
		||
		(child != nil && oldChild != nil && [child isEqualTo:oldChild])
	)
	{
		// We pass ownership of the old child to the new child
		
		// Create the new child
		// Important to note that while we have created a child, we do not set it as the input
		// point. That is because postOps can't be modified
		child = [[PostOp alloc] initWithParent:self manager:manager child:child andOp:newOp];
		[child inputPoint];
		[child valueChanged];
	}
	else
	{
		NSAssert(NO, @"Attempt to change child of Expression tree node that doesn't exist.\n");
	}
}

//
// replaceChild
//
// Does what its told and replaces the child node.
//
- (void)replaceChild:(Expression*)oldChild withValue:(BigCFloat*)newValue
{
	if
	(
		(child == nil && oldChild == nil)
		||
		(child != nil && oldChild != nil && [child isEqualTo:oldChild])
	)
	{
		// We pass ownership of the old child to the new child
		
		// Create the new child
		// Important to note that while we have created a child, we do not set it as the input
		// point. That is because postOps can't be modified
		child = [[Value alloc] initWithParent:self value:newValue andManager:manager];
		[child inputPoint];
		[child valueChanged];
	}
	else
	{
		NSAssert(NO, @"Attempt to change child of Expression tree node that doesn't exist.\n");
	}
}

//
// shiftValue
//
// Shifts the BigCFloat associated with this class. Will only really make a different if
// equals has been pressed and this is the head node.
//
- (void)shiftValue:(BOOL)left
{
	if (left)
		[[self getValue] exp3Down:[manager getLengthLimit]];
	else
		[[self getValue] exp3Up];
	
	// Here we do a partial "valueChanged" notification. We don't actually want to
	// propagate a change through the tree -- just to refresh the display
	pathValidAt = -1;
	isBoundsValid = NO;
}

//
// userPointPresed
//
// If no child exists, creates a child and sends this message to it, 
//
- (void)userPointPressed
{
	// Create a value at the child node and let it handle the digit
	if (child == nil)
	{
		child = [[Value alloc] initWithParent:self andManager:manager];
	
		[child inputPoint];
		[child userPointPressed];
	}
	else
	{
		// We already have a closed child node so this action is the next factor in the term
		[self binaryOpPressed:'.'];
		[[manager getInputPoint] userPointPressed];
	}
}

//
// valueChanged
//
// Flags this node and all higher nodes in the tree as needing recalculation
//
- (void)valueChanged
{
	// Mark ourselves as needing a new display path and layout rectangle
	valueValid = NO;
	pathValidAt = -1;
	isBoundsValid = NO;
	
	// Propagate the change through to the parent
	if (parent != nil)
		[parent valueChanged];
}

//
// valueInserted
//
// If there is no child node, inserts the value as a child. If there is a child node, inserts
// the value as a sibling of the child.
//
- (void)valueInserted:(BigCFloat*)newValue
{
	// Create a value at the child node and let it handle the digit
	if (child == nil)
	{
		child = [[Value alloc] initWithParent:self value:newValue andManager:manager];
		[child inputPoint];
		[child valueChanged];
	}
	else
	{
		// We already have a closed child node so this action is the next factor in the term
		[self binaryOpPressed:'.'];
		[[manager getInputPoint] valueInserted:newValue];
	}
}

@end
