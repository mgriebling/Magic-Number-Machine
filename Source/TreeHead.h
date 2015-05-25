// ##############################################################
//  TreeHead.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun May 25 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Foundation/Foundation.h>
#import "Expression.h"

//
// About TreeHead
//
// The root node of the expression tree must always be a TreeHead. Implements some
// default behaviour for a node which never has a parent.
//
@interface TreeHead : Expression
{

}
+ (Expression*)treeHeadWithValue:(BigCFloat*)newValue andManager:(DataManager*)newManager;
- (void)binaryOpPressed:(int)op;
@property (NS_NONATOMIC_IOSONLY, getter=getCaretPoint, readonly) NSPoint caretPoint;
- (void)postOpPressed:(int)op;

@end
