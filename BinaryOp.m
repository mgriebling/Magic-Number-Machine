// ##############################################################
//  BinaryOp.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun May 04 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "BinaryOp.h"
#import "ExpressionSymbols.h"
#import "BigCFloat.h"
#import "DataManager.h"
#import "Value.h"
#import "Bracket.h"
#import "Constant.h"
#import "PreOp.h"
#import "PostOp.h"
#import "OpEnumerations.h"

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
// out of the "order of operations". As such, these different behaviours should have
// been different classes. Oh well.
//

@implementation BinaryOp

//
// Constructor
//
// Creates the operator and initialises as default then further initialises the second
// child.
//
- (instancetype)initWithParent:(Expression*)newParent manager:(DataManager*)newManager
	leftChild:(Expression*)newChild andOp:(int)newOp
{
	self = [super initWithParent:newParent andManager:newManager];
	if (self)
	{
		op = newOp;
		
		if (newChild != nil)
		{
			leftChild = newChild;
			[leftChild parentChanged:self];
			userSkippedLeft = NO;
		}
		else
		{
			leftChild = nil;
			userSkippedLeft = YES;
		}
	}
	return self;
}

//
// initWithCoder
//
// Required code for NSCoder protocol. Used to copy and paste.
//
- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	leftChild = [coder decodeObjectForKey:@"MELeftChild"];
	op = [coder decodeIntForKey:@"MEOp"];
	userSkippedLeft = [coder decodeBoolForKey:@"MEUserSkippedLeft"];
	
	return self;
}

//
// encodeWithCoder
//
// Required code for NSCoder protocol. Used to copy and paste.
//
- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeObject:leftChild forKey:@"MELeftChild"];
	[coder encodeInt:op forKey:@"MEOp"];
	[coder encodeBool:userSkippedLeft forKey:@"MEUserSkippedLeft"];
}

//
// Destructor
//
// Release all retained and allocated memory.
//

//
// appendDigit
//
// If there is no left node, we must create one when a digit is entered.
//
- (void)appendDigit:(int)digit
{
	// Create a value at the child node and let it handle the digit
	if (leftChild == nil && !userSkippedLeft)
	{
		leftChild = [[Value alloc] initWithParent:self andManager:manager];
		
		[leftChild inputPoint];
		[leftChild appendDigit:digit];
	}
	else
	{
		[super appendDigit:digit];
	}
}

//
// appendOpToPath
//
// Draws this operation. This method should only be called internally from pathAtLevel.
//
- (void)appendOpToPath:(NSBezierPath*)path atLevel:(int)level
{
	NSBezierPath		*opPath;
	NSAffineTransform	*transform = [NSAffineTransform transform];
	NSRect				boundsRect;
	double				scale = [Expression scaleWithLevel:level];
	
	if (![path isEmpty]) boundsRect = [path bounds];
	else boundsRect = NSZeroRect;
	
	switch (op)
    {
        case '-':
            opPath = [ExpressionSymbols minusPath];
            break;
        case '+':
            opPath = [ExpressionSymbols plusPath];
            break;
        case '*':
            opPath = [ExpressionSymbols multiplyPath];
            break;
        case '%':
            opPath = [ExpressionSymbols modPath];
            break;
        case 'p':
            opPath = [ExpressionSymbols nprPath];
            break;
        case 'c':
            opPath = [ExpressionSymbols ncrPath];
            break;
        case 'a':
            opPath = [ExpressionSymbols andPath];
            break;
        case 'o':
            opPath = [ExpressionSymbols orPath];
            break;
        case 'x':
            opPath = [ExpressionSymbols xorPath];
            break;
        case '.':
            opPath = [ExpressionSymbols dotPath];
            break;
        case '^':
            return;
        case rootOp:
            return;
//            if (leftChild != nil)
//                lvalue = [leftChild getValue];
//            else
//                lvalue = [BigCFloat bigFloatWithInt:2 radix:[manager getRadix]];
//            NSUInteger root = lvalue.realPart.doubleValue;
            //			opPath = [ExpressionSymbols sqrtPath];
//            [opPath appendBezierPath:[ExpressionSymbols nRootPath:2.5]];
//			break;
		default:
			opPath = nil;
			break;
	}
	
//	[transform translateXBy:boundsRect.origin.x + boundsRect.size.width + ((op != '.') ? 12.0 : 4.0) yBy:0];
	[transform translateXBy:boundsRect.origin.x + boundsRect.size.width + ((op != '.') ? 6.0 : 4.0) yBy:0];   // less space is more - Mike

	if (level >= 2) [transform scaleBy:scale];
	
	[opPath transformUsingAffineTransform:transform];
	[path appendBezierPath:opPath];
}

//
// binaryOpPressed
//
// Changes the operation of this node.
//
- (void)binaryOpPressed:(int)newOp
{
	if (child == nil)
	{
		op = newOp;
		[self valueChanged];
		return;
	}
	
	[self replaceChild:child withBinOp:newOp];
}

//
// bracketPressed
//
// Same as inherited except creates bracket at leftChild if no left child exists.
//
- (void)bracketPressed
{
	if (leftChild == nil && !userSkippedLeft)
	{
		leftChild = [[Bracket alloc] initWithParent:self andManager:manager];
		[leftChild inputPoint];
		[leftChild valueChanged];
	}
	else
	{
		[super bracketPressed];
	}
}

//
// childChanged
//
// Same as inherited except can change both left and right children.
//
- (void)childChanged:(Expression*)oldChild replacedWith:(Expression*)newChild
{
	if ([leftChild isEqualTo:oldChild])
	{
		if (newChild != nil)
		{
			leftChild = newChild;
			[leftChild parentChanged:self];
		}
		else
		{
			leftChild = nil;
		}
	}
	else
	{
		NSAssert
		(
			oldChild == nil || [oldChild isEqual:child], @"Attempt to change child of Expression tree node that doesn't exist.\n"
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
	}
	[self valueChanged];
}

//
// childDeleted
//
// Same as inherited except can delete both left and right children.
//
- (void)childDeleted:(Expression*)oldChild
{
	if ([oldChild isEqual:leftChild])
	{
		leftChild = nil;
		
		if (child != nil)
		{
			[child inputPoint];
			[parent childChanged:self replacedWith:child];
		}
		else if (parent != nil)
		{
			[parent childDeleted:self];
		}
		else
		{
			[self inputPoint];
			[self valueChanged];
		}
	}
	else
	{
		NSAssert
		(
			[oldChild isEqual:child], @"Attempt to change child of Expression tree node that doesn't exist.\n"
		);

		child = nil;

		if (leftChild == nil && parent != nil)
		{
			[parent childDeleted:self];
		}
		else
		{
			[self inputPoint];
			[self valueChanged];
		}
	}
}

//
// constantPressed
//
// Same as inherited except creates the constant at the leftChild if no left child exists.
//
- (void)constantPressed:(int)constant
{
	if (leftChild == nil && !userSkippedLeft)
	{
		leftChild = [[Constant alloc] initWithParent:self manager:manager andConstant:constant];
		[leftChild inputPoint];
		[leftChild valueChanged];
	}
	else
	{
		[super constantPressed:constant];
	}
}

//
// deleteDigit
//
// Same as inherited except can track deletion through both left and right children.
//
- (void)deleteDigit
{
	if (child != nil)
	{
		[child inputPoint];
		[child deleteDigit];
	}
	else if (leftChild != nil)
	{
		[leftChild inputPoint];
		[parent childChanged:self replacedWith:leftChild];
	}
	else if (parent != nil)
	{
		[parent childDeleted:self];
	}
}

//
// equalsPressed
//
// Same as inherited except dispatches to the left child as well as the right.
//
- (void)equalsPressed
{
	if (leftChild != nil)
	{
		[leftChild equalsPressed];
	}
	if (child != nil)
	{
		[child equalsPressed];
	}
}

//
// exponentPressed
//
// Same as inherited except adds the exponent at the leftChild if no left child exists.
//
- (void)exponentPressed
{
	// Create a value at the child node and let it handle the digit
	if (leftChild == nil && !userSkippedLeft)
	{
		leftChild = [[Value alloc] initWithParent:self andManager:manager];
		
		[leftChild inputPoint];
		[leftChild exponentPressed];
	}
	else
	{
		[super exponentPressed];
	}
}

//
// expressionInserted
//
// Same as inherited except adds the expression at the leftChild if no left child exists.
//
- (void)expressionInserted:(Expression*)newExpression
{
	if (leftChild == nil && !userSkippedLeft)
	{
		leftChild = newExpression;
		[leftChild managerChanged:manager];
		[leftChild inputPoint];
		[leftChild refresh];
	}
	else
	{
		[super expressionInserted:newExpression];
	}
}

//
// getCaretPoint
//
// Determines if the caretPoint is in the left child and returns that caret point if it is,
// or returns the default behaviour with some tweaks to account for exponents and
// division.
//
- (NSPoint)getCaretPoint
{
	NSPoint caretPoint;
	
	if (leftChild == nil && !userSkippedLeft)
	{
		caretPoint = displayBounds.origin;
		caretPoint.x -= 9.0 * [Expression scaleWithLevel:pathValidAt];
		return caretPoint;
	}
	
	caretPoint = [super getCaretPoint];
	
	if (op == '^' && child == nil)
	{
		caretPoint.y += 16.0 * [Expression scaleWithLevel:pathValidAt];
	}
	else if (op == '/' && child == nil)
	{
		caretPoint.x -= 0.5 * (displayBounds.size.width) + 3.0;
		caretPoint.y -= 12.0 * [Expression scaleWithLevel:pathValidAt + 1];
	}
	else if (op == '/')
	{
		caretPoint.y += 20.0 * [Expression scaleWithLevel:pathValidAt + 1];
	}
	
	return caretPoint;
}

//
// getExpressionString
//
// Performs string conversion of this node.
//
- (NSString*)getExpressionString
{
	NSString *resultString = @"";
	
	if (leftChild != nil)
		resultString = [resultString stringByAppendingString:[leftChild getExpressionString]];
	
	switch (op)
	{
		case '-':
			resultString = [resultString stringByAppendingString:@" - "];
			break;
		case '+':
			resultString = [resultString stringByAppendingString:@" + "];
			break;
		case '*':
			resultString = [resultString stringByAppendingString:@" x "];
			break;
		case '/':
			resultString = [resultString stringByAppendingString:@" / "];
			break;
		case '%':
			resultString = [resultString stringByAppendingString:@" % "];
			break;
		case 'p':
			resultString = [resultString stringByAppendingString:@" npr "];
			break;
		case 'c':
			resultString = [resultString stringByAppendingString:@" ncr "];
			break;
		case 'a':
			resultString = [resultString stringByAppendingString:@" and "];
			break;
		case 'o':
			resultString = [resultString stringByAppendingString:@" or "];
			break;
		case 'x':
			resultString = [resultString stringByAppendingString:@" xor "];
			break;
		case '.':
			resultString = [resultString stringByAppendingString:@" x "];
			break;
		case '^':
			resultString = [resultString stringByAppendingString:@"^"];
			break;
		case rootOp:
			resultString = [resultString stringByAppendingString:@" √ "];
			break;
		default:
			resultString = [resultString stringByAppendingString:@" "];
			break;
	}

	if (child != nil)
		resultString = [resultString stringByAppendingString:[child getExpressionString]];

	return resultString;
}

//
// getValue
//
// Depending on the operation associated with this node, calculates the resultant value
// from the combination of the left and right child nodes.
//
- (BigCFloat*)getValue
{
	BigCFloat *leftChildValue;
	BigCFloat *rightChildValue;
	
	if (valueValid == NO)
	{
		if (child != nil) rightChildValue = [child getValue];
		else rightChildValue = [BigCFloat zero];
		
		if (leftChild != nil) leftChildValue = [leftChild getValue];
		else leftChildValue = [BigCFloat zero];
		
		value = (BigCFloat*)[leftChildValue duplicate];
		
		switch (op)
		{
			case '-':
				[value subtract:rightChildValue];
				break;
			case '+':
				[value add:rightChildValue];
				break;
			case '*':
			case '.':
				[value multiplyBy:rightChildValue];
				break;
			case '/':
				[value divideBy:rightChildValue];
				break;
			case '%':
				[value moduloBy:rightChildValue];
				break;
			case 'p':
				[value nPr:rightChildValue];
				break;
			case 'c':
				[value nCr:rightChildValue];
				break;
			case '^':
				[value raiseToPower:rightChildValue];
				break;
			case 'a':
				[value andWith:rightChildValue usingComplement:[manager getComplement]];
				break;
			case 'o':
				[value orWith:rightChildValue usingComplement:[manager getComplement]];
				break;
			case 'x':
				[value xorWith:rightChildValue usingComplement:[manager getComplement]];
				break;
			case rootOp:
				[value inverse];
				[rightChildValue raiseToPower:value];
				[value assign:rightChildValue];
				break;
			default:
				break;
		}
	
	}
	return value;
}

//
// leftChild
//
// Provides access to this node's left child.
//
- (Expression*)leftChild
{
	return leftChild;
}

//
// managerChanged
//
// Same as inherited behaviour except that this passes the information to the left child
// as well.
//
- (void)managerChanged:(DataManager*)newManager
{
	manager = newManager;
	if (child != nil)
	{
		[child managerChanged:newManager];
	}
	if (leftChild != nil)
	{
		[leftChild managerChanged:newManager];
	}
}

//
// nodeContainingPoint
//
// Same as inherited behaviour except that this method hit tests the left child as well
// as the right.
//
- (Expression*)nodeContainingPoint:(NSPoint)point
{
	NSAssert(isBoundsValid == YES, @"Point in bounds requested before bounds received.\n");
	
	if (NSMouseInRect(point, displayBounds, NO))
	{
		Expression *childResult = nil;
		
		if (child != nil)
		{
			childResult = [child nodeContainingPoint:point];
		}
		
		if (childResult == nil && leftChild != nil)
		{
			childResult = [leftChild nodeContainingPoint:point];
		}
		
		if (childResult != nil)
			return childResult;
		
		userSkippedLeft = NO;
		
		return self;
	}
	
	return nil;
}

//
// pathAtLevel
//
// Draws the bezier path for this node. The child nodes are drawn through their own
// methods. The operators are drawn by appendOpToPath. Most of this method is about
// handling the different layout caused by the division operator and exponents.
//
- (NSBezierPath*)pathAtLevel:(int)level
{
	NSBezierPath		*copy;
	double			scale = [Expression scaleWithLevel:level];
	
	if (pathValidAt != level)
	{
		NSBezierPath *rightChildPath = [NSBezierPath bezierPath];
		NSBezierPath *leftChildPath = [NSBezierPath bezierPath];

		expressionPath = [NSBezierPath bezierPath];

		if (op == '/')
		{
			NSRect	numeratorBounds = NSZeroRect;
			NSRect	denominatorBounds = NSZeroRect;
			NSRect	combinedBounds = NSZeroRect;
			NSRect	lineBounds = NSZeroRect;
			NSAffineTransform *transform;
			
			if (leftChild != nil)
			{
				leftChildPath = [leftChild pathAtLevel:level + 1];
				numeratorBounds = [leftChildPath bounds];
				transform = [NSAffineTransform transform];
				[transform translateXBy:3 * scale yBy:scale * 11 - numeratorBounds.origin.y];
				[leftChildPath transformUsingAffineTransform:transform];
			}
			if (child != nil)
			{
				rightChildPath = [child pathAtLevel:level + 1];
				denominatorBounds = [rightChildPath bounds];
				
				transform = [NSAffineTransform transform];
				[transform translateXBy:3 * scale yBy:(scale * 5) - (denominatorBounds.size.height + denominatorBounds.origin.y)];
				
				if (leftChild != nil)
				{
					if (denominatorBounds.size.width < numeratorBounds.size.width)
					{
						[transform
							translateXBy:
								(numeratorBounds.size.width - denominatorBounds.size.width) / 2.0
								+
								numeratorBounds.origin.x - denominatorBounds.origin.x
							yBy:0
						];
					}
					else
					{
						NSAffineTransform	*numeratorTransform = [NSAffineTransform transform];
						
						[numeratorTransform
							translateXBy:
								(denominatorBounds.size.width - numeratorBounds.size.width) / 2.0
								+
								denominatorBounds.origin.x - numeratorBounds.origin.x
							yBy:0
						];
						[leftChildPath transformUsingAffineTransform:numeratorTransform];
					}
				}
				[rightChildPath transformUsingAffineTransform:transform];
			}
			
			if (![leftChildPath isEmpty])
				[expressionPath appendBezierPath:leftChildPath];
			if (![rightChildPath isEmpty])
				[expressionPath appendBezierPath:rightChildPath];
			
			if (![expressionPath isEmpty])
			{
				combinedBounds = [expressionPath bounds];
			}
			else
			{
				combinedBounds = NSMakeRect(0.0, 0.0, 16.0, 0.0);
			}
			
			lineBounds = NSMakeRect	(combinedBounds.origin.x - (scale * 3.0), (scale * 7.25), combinedBounds.size.width + (scale * 6.0), (scale * 1.5));
			[expressionPath appendBezierPath:[NSBezierPath bezierPathWithRect:lineBounds]];
		}
		else if (op == '^')
		{
			if (leftChild != nil)
			{
				leftChildPath = [leftChild pathAtLevel:level];
				[expressionPath appendBezierPath:leftChildPath];
			}
		
			[self appendOpToPath:expressionPath atLevel:level];
			
			if (child != nil)
			{
				NSAffineTransform *transform = [NSAffineTransform transform];
				NSRect				boundsRect = [expressionPath bounds];
			
				if (level == 0)
					rightChildPath = [child pathAtLevel:level + 2];
				else
					rightChildPath = [child pathAtLevel:level + 1];
				[transform translateXBy:boundsRect.origin.x + boundsRect.size.width yBy:scale * 11];
				[rightChildPath transformUsingAffineTransform:transform];
				
				[expressionPath appendBezierPath:rightChildPath];
			}
        }
        else if (op == rootOp)
        {
            NSInteger root = 2;
            
            if (leftChild != nil) {
                root = leftChild.value.realPart.doubleValue;
            }
            [expressionPath appendBezierPath:[ExpressionSymbols nRootPath:root]];
            [self appendOpToPath:expressionPath atLevel:level];
            
            if (child != nil) {
                NSAffineTransform *transform = [NSAffineTransform transform];
                NSBezierPath *overLine  = [NSBezierPath bezierPath];
                NSRect       boundsRect = [expressionPath bounds];
           
                rightChildPath = [child pathAtLevel:level];
                NSRect childBounds = [rightChildPath bounds];
                
                [transform translateXBy:boundsRect.origin.x + boundsRect.size.width yBy:0];
                [rightChildPath transformUsingAffineTransform:transform];
                
                transform = [NSAffineTransform transform];
                [transform translateXBy:0.0 yBy:childBounds.origin.y - 0.8 * boundsRect.origin.y];
                [transform scaleXBy:1.0 yBy:(childBounds.size.height / boundsRect.size.height) * 1.25];
                [expressionPath transformUsingAffineTransform:transform];
                boundsRect = [expressionPath bounds];
                
                [overLine moveToPoint:
                    NSMakePoint
                    (boundsRect.origin.x + boundsRect.size.width,
                     boundsRect.origin.y + boundsRect.size.height)
                ];
                [overLine relativeLineToPoint: NSMakePoint(childBounds.size.width + 5.0, 0) ];
                [overLine relativeLineToPoint:NSMakePoint(-0.5, -1.5)];
                [overLine relativeLineToPoint: NSMakePoint(-(childBounds.size.width + 5.0), 0)];
                [overLine closePath];
                [expressionPath appendBezierPath:overLine];
                [expressionPath appendBezierPath:rightChildPath];
            }
        }
        else
        {
			if (leftChild != nil)
			{
				leftChildPath = [leftChild pathAtLevel:level];
				[expressionPath appendBezierPath:leftChildPath];
			}
		
			[self appendOpToPath:expressionPath atLevel:level];
			
			if (child != nil)
			{
				NSAffineTransform *transform = [NSAffineTransform transform];
				NSRect				boundsRect = [expressionPath bounds];
				double				spacing;
				
				spacing = (op == '.' || leftChild == nil) ? (scale * 4.0) : (scale * 6.0);	 // less space is more - Mike
//				spacing = (op == '.' || leftChild == nil) ? (scale * 4.0) : (scale * 12.0);
				
				rightChildPath = [child pathAtLevel:level];
			
				[transform translateXBy:boundsRect.origin.x + boundsRect.size.width + spacing yBy:0];
				[rightChildPath transformUsingAffineTransform:transform];
				
				[expressionPath appendBezierPath:rightChildPath];
			}
		}
		
		if (![expressionPath isEmpty])
			naturalBounds = [expressionPath bounds];
		else
			naturalBounds = NSZeroRect;
		if (![rightChildPath isEmpty])
			childNaturalBounds = [rightChildPath bounds];
		else
			childNaturalBounds = NSZeroRect;
		if (![leftChildPath isEmpty])
			leftChildNaturalBounds = [leftChildPath bounds];
		else
			leftChildNaturalBounds = NSZeroRect;
		pathValidAt = level;
	}
	
	copy = [NSBezierPath bezierPath];
	[copy appendBezierPath:expressionPath];
	
	return copy;
}

//
// postOpPressed
//
// Not certain what I was doing here. I'm sure it had a point, I just can't remember now.
//
- (void)postOpPressed:(int)newOp
{
	[self replaceChild:child withPostOp:newOp];
}

//
// preOpPressed
//
// Same as inherited behaviour except will create a left child and send the preOp to that
// if no left child exists
//
- (void)preOpPressed:(int)newOp
{
	if (leftChild == nil && !userSkippedLeft)
	{
		leftChild = [[PreOp alloc] initWithParent:self manager:manager andOp:newOp];
		[leftChild inputPoint];
		[leftChild valueChanged];
	}
	else
	{
		[super preOpPressed:newOp];
	}
}

//
// receiveBounds
//
// Performs the inherited behaviour plus sends the message to the left child as well.
//
- (void)receiveBounds:(NSRect)bounds
{
	NSBezierPath		*leftChildPath = [NSBezierPath bezierPathWithRect:leftChildNaturalBounds];
	NSAffineTransform	*leftChildTransform = [NSAffineTransform transform];
	
	[super receiveBounds:bounds];
	
	if (leftChild != nil)
	{
		if (!NSIsEmptyRect(naturalBounds))
		{
			[leftChildTransform
				translateXBy:displayBounds.origin.x
				yBy:displayBounds.origin.y
			];
			[leftChildTransform
				scaleXBy:displayBounds.size.width / naturalBounds.size.width
				yBy:displayBounds.size.height / naturalBounds.size.height
			];
			[leftChildTransform
				translateXBy:-naturalBounds.origin.x
				yBy:-naturalBounds.origin.y
			];
			[leftChildPath transformUsingAffineTransform:leftChildTransform];

			leftChildDisplayBounds = [leftChildPath bounds];
		}
		else
		{
			leftChildDisplayBounds = bounds;
		}
		
		[leftChild receiveBounds:leftChildDisplayBounds];
	}
}

//
// refresh
//
// Updates the left and right children.
//
- (void)refresh
{
	if (leftChild != nil)
		[leftChild refresh];
	if (child != nil)
		[child refresh];
	if (leftChild == nil && child == nil)
		[self valueChanged];
}

//
// replaceChild
//
// Inserts a new binary op into the tree structure.
//
// This method is very ugly because it has the onorous task of maintaining order of
// operations for binary nodes. To do this properly, low binding operators extend in
// one direction and higher binding operators extend in another.
//
// The problem comes when the structure of the tree necessitates that an entire branch
// be cut and moved higher up the tree for reattachment at another node.
//
// See the help documentation for a diagram of this behaviour.
//
- (void)replaceChild:(Expression*)oldChild withBinOp:(int)newOp
{
	// This first condition only gets entered if the user has gone back to an earlier node
	// and is replacing a left child with a plus or minus sign.
	if
	(
		parent != nil
		&&
		(newOp == '+' || newOp == '-')
		&&
		leftChild != nil && [leftChild isEqualTo:oldChild]
	)
	{
		BinaryOp *newTerm;

		// The new node binds equally loosely or more loosely than the current node, so
		// we must move the branch as high up the tree as we can before attaching.
		if ([parent class] == [BinaryOp class])
		{
			Expression	*traceUpwardsParent;
			Expression	*traceUpwards;
			
			[parent childChanged:self replacedWith:leftChild];
			leftChild = nil;
			
			traceUpwards = parent;
			while
			(
				[[traceUpwards parent] class] == [BinaryOp class]
				&&
				[[traceUpwards parent] child] != nil
				&&
				[traceUpwards isEqualTo:[[traceUpwards parent] child]]
			)
				traceUpwards = [traceUpwards parent];
			
			traceUpwardsParent = [traceUpwards parent];
			
			// Attach the branch at this point
			newTerm = [[BinaryOp alloc] initWithParent:traceUpwardsParent manager:manager leftChild:traceUpwards andOp:newOp];
			[newTerm childChanged:nil replacedWith:self];
			[traceUpwardsParent childChanged:traceUpwards replacedWith:newTerm];
			
			[self inputPoint];
			[self valueChanged];
		}
		// Otherwise we can safely just attach the new operation here
		else
		{
			if (op != '+' && op != '-')
			{
				newTerm = [[BinaryOp alloc] initWithParent:parent manager:manager leftChild:leftChild andOp:newOp];
				[parent childChanged:self replacedWith:newTerm];
				[newTerm childChanged:nil replacedWith:self];
				leftChild = nil;
				[self inputPoint];
				[self valueChanged];
			}
			else
			{
				newTerm = [[BinaryOp alloc] initWithParent:self manager:manager leftChild:leftChild andOp:newOp];
				[self childChanged:leftChild replacedWith:newTerm];
				[newTerm inputPoint];
				[self valueChanged];
			}
		}
		return;
	}
	// This is the branch that is normally taken while entering the expression in order
	else
	{
		int oldChildOp = -1;
		
		if ([oldChild class] == [BinaryOp class])
		{
			BinaryOp	*binOpOldChild = (BinaryOp*)oldChild;
			
			oldChildOp = binOpOldChild->op;
		}
		
		// Left associative operators (plus or minus) simply get passed to the parent
		// to be added as high in the tree as possible. Naturally if this is the head of the
		// tree, we don't do this.
		if
		(
			(
				(newOp == '+' || newOp == '-')
				&&
				!(oldChildOp == '+' || oldChildOp == '-')
			)
			||
			(
				op == '/' && newOp != '.' && newOp != '^'
			)
			||
			(
				op == '^' && newOp != '^'
			)
		)
		{
			[parent replaceChild:self withBinOp:newOp];
			return;
		}
		
		// We enter this branch if we are replacing a left child (out of order entry)
		if (newOp != '+' && newOp != '-' && leftChild != nil && [leftChild isEqualTo:oldChild])
		{
			BinaryOp *newNode;
			
			if (newOp != '/')
			{
				newNode = [[BinaryOp alloc] initWithParent:parent manager:manager leftChild:oldChild andOp:newOp];
				[parent childChanged:self replacedWith:newNode];
				[newNode childChanged:nil replacedWith:self];
				leftChild = nil;
				[self inputPoint];
				[self valueChanged];
			}
			else
			{
				leftChild = [[BinaryOp alloc] initWithParent:self manager:manager leftChild:leftChild andOp:newOp];
				[leftChild inputPoint];
				[leftChild valueChanged];
			}
		}
		else
		{
			// If the current node binds as tightly as the new node, move higher up the tree
			if (op != '+' && op != '-' && [self isEqualTo:[manager getInputPoint]])
			{
				[parent replaceChild:self withBinOp:newOp];
				return;
			}
			
			// This final point is where we get if we are adding to the right child (most
			// common) and the new operation binds tightly enough to be added here.
			// At last.
			child = [[BinaryOp alloc] initWithParent:self manager:manager leftChild:child andOp:newOp];
			[child inputPoint];
			[child valueChanged];
		}
	}
}

//
// replaceChild
//
// Same as inherited but can replace the left child as well.
//
- (void)replaceChild:(Expression*)oldChild withPostOp:(int)newOp
{
	if
	(
		(leftChild == nil && oldChild == nil)
		||
		(leftChild != nil && oldChild != nil && [leftChild isEqualTo:oldChild])
	)
	{
		// We pass ownership of the old child to the new child
		
		// Create the new child
		// Important to note that while we have created a child, we do not set it as the input
		// point. That is because postOps can't be modified
		leftChild = [[PostOp alloc] initWithParent:self manager:manager child:leftChild andOp:newOp];
		[leftChild inputPoint];
		[leftChild valueChanged];
	}
	else
	{
		[super replaceChild:oldChild withPostOp:newOp];
	}
}

//
// replaceChild
//
// Same as inherited but can replace the left child as well.
//
- (void)replaceChild:(Expression*)oldChild withValue:(BigCFloat*)newValue
{
	if
	(
		(leftChild == nil && oldChild == nil)
		||
		(leftChild != nil && oldChild != nil && [leftChild isEqualTo:oldChild])
	)
	{
		// We pass ownership of the old child to the new child
		
		// Create the new child
		// Important to note that while we have created a child, we do not set it as the input
		// point. That is because postOps can't be modified
		leftChild = [[Value alloc] initWithParent:self value:newValue andManager:manager];
		[leftChild inputPoint];
		[leftChild valueChanged];
	}
	else
	{
		NSAssert(NO, @"Attempt to change child of Expression tree node that doesn't exist.\n");
	}
}

//
// userPointPressed
//
// Same as inherited but can create the left child as well and pass control to it if it does not
// exist.
//
- (void)userPointPressed
{
	// Create a value at the child node and let it handle the digit
	if (leftChild == nil && !userSkippedLeft)
	{
		leftChild = [[Value alloc] initWithParent:self andManager:manager];
	
		[leftChild inputPoint];
		[leftChild userPointPressed];
	}
	else
	{
		[super userPointPressed];
	}
}

//
// valueInserted
//
// Same as inherited but will create a left child and pass the value to it if the left child
// does not exist.
//
- (void)valueInserted:(BigCFloat*)newValue
{
	// Create a value at the child node and let it handle the digit
	if (leftChild == nil && !userSkippedLeft)
	{
		leftChild = [[Value alloc] initWithParent:self value:newValue andManager:manager];
		[leftChild inputPoint];
		[leftChild valueChanged];
	}
	else
	{
		[super valueInserted:newValue];
	}
}

@end
