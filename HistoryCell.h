// ##############################################################
//  HistoryCell.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Tue Jun 24 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Foundation/Foundation.h>

///
/// The history table contains history cells. The history cells display expressions.
/// This custom cell allows them to do so.
///
/// There is only one cell for the entire table and it gets reused.
///
@interface HistoryCell : NSCell
{
}
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end
