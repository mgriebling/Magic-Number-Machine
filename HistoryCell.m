// ##############################################################
//  HistoryCell.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Tue Jun 24 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "HistoryCell.h"

//
// About the HistoryCell
//
// The history table contains history cells. The history cells display expressions.
// This custom cell allows them to do so.
//
// There is only one cell for the entire table and it gets reused.
//
@implementation HistoryCell

//
// drawInteriorWithFrame
//
// Does the drawing. Gets the path from the object value.
//
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSArray				*contents = [self objectValue];
	NSBezierPath		*path = [NSBezierPath bezierPath];
	NSRect				contentBounds;
	NSAffineTransform	*transform = [NSAffineTransform transform];
	double				scale = 1.0;
	NSString			*numberString;
	NSBezierPath		*line = [NSBezierPath bezierPath];
	
	[super drawInteriorWithFrame:cellFrame inView:controlView];
	
	[path appendBezierPath:contents[1]];
	contentBounds = [path bounds];
	
	if (cellFrame.size.width / contentBounds.size.width < 1.0)
		scale = cellFrame.size.width / contentBounds.size.width;
	else if (cellFrame.size.height / contentBounds.size.height < 1.0)
		scale = cellFrame.size.height / contentBounds.size.height;
	
	if (scale != 1.0)
	{
		[transform scaleBy:scale];
		[path transformUsingAffineTransform:transform];
		contentBounds = [path bounds];
		transform = [NSAffineTransform transform];
	}
	
	[transform
		translateXBy:(cellFrame.size.width - contentBounds.size.width) / 2.0 + cellFrame.origin.x
		yBy:(cellFrame.size.height - contentBounds.size.height) / 2.0 + cellFrame.origin.y
	];
	[path transformUsingAffineTransform:transform];
	
    // draws the equation path
	[NSColor.labelColor setFill];
	[path fill];
    
    // Draws the small history number
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:NSColor.labelColor forKey:NSForegroundColorAttributeName];
	numberString = [NSString stringWithFormat:@"%d.", [contents[2] intValue]];
    [numberString drawAtPoint:NSMakePoint(cellFrame.origin.x + 2.0, cellFrame.origin.y) withAttributes:attributes];
	
    // Draws the separator line
    [NSColor.labelColor setStroke];
	[line moveToPoint:NSMakePoint(cellFrame.origin.x + 2.0, cellFrame.origin.y + cellFrame.size.height)];
	[line lineToPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - 2.0, cellFrame.origin.y + cellFrame.size.height)];
	[line stroke];
}

@end
