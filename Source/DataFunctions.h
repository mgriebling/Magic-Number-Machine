// ##############################################################
//  DataFunctions.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Thu Jun 26 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Cocoa/Cocoa.h>

@class DataManager;
@class DrawerManager;
@class BigCFloat;

//
// About DataFunctions
//
// The functions in this class perform all the functions on the data in the data
// drawers.
//
@interface DataFunctions : NSObject
{
	IBOutlet DataManager	*dataManager;
	IBOutlet DrawerManager	*drawerManager;
}
- (id)afromrankregressiononx:(NSMutableArray *)values;
- (id)afromrankregressionony:(NSMutableArray *)values;
- (id)bfromrankregressiononx:(NSMutableArray *)values;
- (id)bfromrankregressionony:(NSMutableArray *)values;
- (id)coefofvariation:(NSMutableArray *)values;
- (NSMutableArray *)determinantsubmatrix:(NSMutableArray *)values size:(int)size withoutRow:(int)row orColumn:(int)column;
- (BigCFloat *)determinant:(NSMutableArray *)values size:(int)size;
- (id)determinant:(NSMutableArray *)values;
- (void)exchangeRows:(NSMutableArray *)values firstRow:(int)one secondRow:(int)two columns:(int)numColumns;
- (id)gaussianelimination:(NSMutableArray *)values columns:(int)numColumns rows:(int)numRows;
- (id)gaussianelimination:(NSMutableArray *)values;
- (id)backsub:(NSMutableArray *)values columns:(int)num_columns rows:(int)num_rows;
- (id)gaussianeliminationwithbacksub:(NSMutableArray *)values;
- (id)mean:(NSMutableArray *)values;
- (id)median:(NSMutableArray *)values;
- (id)mode:(NSMutableArray *)values;
- (id)mfromrankregressiononx:(NSMutableArray *)values;
- (id)mfromrankregressiononxwithoriginintercept:(NSMutableArray *)values;
- (id)mfromrankregressionony:(NSMutableArray *)values;
- (id)mfromrankregressiononywithoriginintercept:(NSMutableArray *)values;
- (void)prepareArray:(NSMutableArray *)values outColumns:(int *)columns outRows:(int *)rows;
- (id)stddev:(NSMutableArray *)values;
- (id)sum:(NSMutableArray *)values;
- (id)variance:(NSMutableArray *)values;
- (id)zero:(NSMutableArray *)values;
- (id)inverse:(NSMutableArray *)values;

@end
