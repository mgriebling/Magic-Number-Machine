// ##############################################################
//  DrawerManager.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Cocoa/Cocoa.h>

@class HistoryCell;
@class DataManager;
@class BigCFloat;
@class DataFunctions;

//
// About the DrawerManager
//
// The DrawerManager is an odd collection of both data, behaviour and input
// management for all of the drawers attached to the edge of the window. There
// is only one instance of the DrawerManager in the application.
//
// All the data which statically populates some tables in the drawers is statically
// defined in the constructor (ugly). This includes all the constants and the
// Data functions.
//
// The actual data kept in the "Data" drawers is owned by the DataManager class.
//
@interface DrawerManager : NSObject
{
	IBOutlet id				arrayDataDrawer;
	IBOutlet NSTableView	*arrayDataFunctionsTableView;
	IBOutlet NSTableView	*arrayDataTableView;
	IBOutlet id				constantsDrawer;
	IBOutlet NSTableView	*constantsTableView;
	IBOutlet id				data2DDrawer;
	IBOutlet NSTableView	*data2DFunctionsTableView;
	IBOutlet NSTableView	*data2DTableView;
	IBOutlet id				dataDrawer;
	IBOutlet NSTableView	*dataFunctionsTableView;
	IBOutlet DataManager	*dataManager;
	IBOutlet DataFunctions	*dataFunctions;
	IBOutlet NSTableView	*dataTableView;
	IBOutlet id				historyDrawer;
	IBOutlet NSTableView	*historyTableView;
	IBOutlet id				inputManager;
	IBOutlet id				radixDrawer;
	IBOutlet NSTableView	*radixTableView;
	
	NSDrawer				*activeDrawer;
	NSArray					*radixDataRows;
	NSArray					*arrayDataFunctionRows;
	NSArray					*dataFunctionRows;
	NSArray					*data2DFunctionRows;
	HistoryCell				*historyCell;
	int						numArrayColumns;
}
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (void)addArrayData:(BigCFloat*)value;
- (void)addData:(BigCFloat*)value;
- (void)addData2D:(BigCFloat*)value;
- (IBAction)arrayColumnsChanged:(id)sender;
- (IBAction)applyArrayDataFunction:(id)sender;
- (IBAction)applyData2DFunction:(id)sender;
- (IBAction)applyDataFunction:(id)sender;
- (IBAction)changeRadix:(id)sender;
- (IBAction)clearAllArrayDataValues:(id)sender;
- (IBAction)clearAllData2DValues:(id)sender;
- (IBAction)clearAllDataValues:(id)sender;
- (IBAction)clearArrayValue:(id)sender;
- (IBAction)clearData2DValue:(id)sender;
- (IBAction)clearDataValue:(id)sender;
- (IBAction)constantSelected:(id)sender;
- (IBAction)copyDataValueToDisplay:(id)sender;
- (IBAction)historySelected:(id)sender;
@property (NS_NONATOMIC_IOSONLY, readonly) int numberOfArrayColumns;
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (void)setStartupState;
- (id)tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn row:(int)rowIndex;
- (IBAction)toggleDrawer:(id)sender;
- (void)updateArrayDataArray;
- (void)updateData2DArray;
- (void)updateDataArray;
- (void)updateHistory;

@end
