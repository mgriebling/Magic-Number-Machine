// ##############################################################
//  TreeHead.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun May 25 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "TreeHead.h"
#import "DataManager.h"

//
// About TreeHead
//
// The root node of the expression tree must always be a TreeHead. Implements some
// default behaviour for a node which never has a parent.
//
@implementation TreeHead

//
// treeHeadWithValue
//
// This is the constructor for this class. Links the class to the manager, sets the starting
// point for the inputPoint.
//
+ (Expression*)treeHeadWithValue:(BigCFloat*)newValue andManager:(DataManager*)newManager
{
	Expression *newExpression;
	
	// Create the expression
	newExpression = [[TreeHead alloc] initWithParent:nil andManager:newManager];
	
	// Link in the manager
	[newManager setCurrentExpression:newExpression];
	
	// Set the inputPoint
	[newExpression inputPoint];

	// Either create a value (and have it be the initial input point) or leave child nil and
	// become the input point ourselves
	if (newValue != nil)
	{
		[newExpression replaceChild:nil withValue:newValue];
	}
	
	return newExpression;
}

//
// binaryOpPressed
//
// Always create a binary operation under this node
//
- (void)binaryOpPressed:(int)op
{
	// Split the child into a binary operation.
	[self replaceChild:child withBinOp:op];
}

//
// getCaretPoint
//
// If the head of the tree is the insertion point, then just return a point at the middle right
// of the bounds
//
- (NSPoint)getCaretPoint
{
	NSPoint	caretPoint;
	
	NSAssert(isBoundsValid == YES, @"Display bounds requested before being received.\n");
	
	caretPoint = displayBounds.origin;
	caretPoint.x += displayBounds.size.width + 3.0;
	caretPoint.y += displayBounds.size.height / 2.0;
	
	return caretPoint;
}

//
// postOpPressed
//
// Always put the post op under this node.
//
- (void)postOpPressed:(int)op
{
	// Create a postOp at the child node and set it as the input point
	[self replaceChild:child withPostOp:op];
}

@end
