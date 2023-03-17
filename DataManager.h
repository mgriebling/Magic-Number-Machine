// ##############################################################
//  DataManager.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Cocoa/Cocoa.h>

@class ExpressionDisplay;
@class DrawerManager;
@class TreeHead;
@class Expression;
@class History;

#import "BigCFloat.h"

//
// About the DataManager
//
// Magic Number Machine maintains a single window and with that window there is
// a single DataManager class that manages all the data for that window.
//
// This class contains the current expression (the data structure viewed through the
// main view of the main window) the history, data arrays and state variables.
//
// Little actual processing occurs in this class, it simply manages interaction between
// the input of data (input manager and sometimes the history or data arrays) and
// the current expression.
//

@interface DataManager : NSObject
{
	__weak IBOutlet ExpressionDisplay	*expressionDisplay;	// window's main display
	__weak IBOutlet DrawerManager		*drawerManager;		// handles all the window drawers
	__weak IBOutlet id					inputManager;			// routes input from buttons
	__weak IBOutlet NSTextField		*precisionDisplay;		// Displays the number of digits
	__weak IBOutlet NSTextField		*trigModeDisplay;		// Displays degress, radians, gradians
	__weak IBOutlet NSTextField		*radixDisplay;			// Displays hex, decimal, etc
	
	// All the little buttons that get updated
	__weak IBOutlet NSButton *shift3Left;
	__weak IBOutlet NSButton *shift3Right;
    
    __weak IBOutlet NSBox *alternateKeys;
    __weak IBOutlet NSBox *mainKeys;
    
    unsigned int				defaultDigits;
	unsigned int				defaultSignificant;
	unsigned int				defaultFixed;
	unsigned int				defaultDisplayType;
	
	short						radix;
	unsigned int				lengthLimit;
	unsigned int				maximumLength;
	BOOL						fillLimit;
	unsigned int				fixedPlaces;
	BOOL						shiftIsActive;
	BOOL						optionIsDown;
    BOOL                        shiftIsDown;
	BOOL						equalsPressed;
	int							complement;
	int							lengthLimitSave;
	int							fixedPlacesSave;
	int							fillLimitSave;
	BFTrigMode					trigMode;
	BOOL						shiftEnabledByToggle;
	BOOL						optionEnabledByToggle;
	BOOL						thousandsSeparator;
    BOOL                        fractionSeparator;
		
	History						*historyArray;
	NSMutableArray				*dataArray;
	NSMutableArray				*data2DArray;
	NSMutableArray				*arrayDataArray;
	TreeHead					*currentExpression;
	Expression					*currentInputPoint;
}

- (instancetype)init;
- (IBAction)exportToPDF:(id)sender;
- (IBAction)addData:(id)sender;
- (NSMutableArray*)arrayData;
- (void)clearExpression;
- (IBAction)clearHistory:(id)sender;
- (NSMutableArray*)data;
- (NSMutableArray*)data2D;
- (void)ensureInputWithValue:(BOOL)preserveValue;
- (void)equalsPressed;
- (int)getComplement;
- (Expression*)getCurrentExpression;
- (BOOL)getEqualsPressed;
- (BOOL)getFillLimit;
- (unsigned int)getFixedPlaces;
- (Expression*)getInputPoint;
- (unsigned int)getLengthLimit;
- (unsigned int)getMaximumLength;
- (BOOL)getOption;
- (short)getRadix;
- (BOOL)getShift;
- (BOOL)getThousandsSeparator;
- (BOOL)getFractionSeparator;
- (int)getTrigMode;
- (History*)history;
- (void)lengthLimit:(unsigned int)limit fillLimit:(BOOL)fill fixedPlaces:(unsigned int)places;
- (void)optionIsPressed:(BOOL)isPressed;
- (void)optionToggled;
- (void)setCurrentExpression:(Expression*)newExpression;
- (void)setInputPoint:(Expression*)point;
- (void)setInputAtPoint:(NSPoint)point;
- (void)setRadix:(short)newRadix useComplement:(int)useComplement;
- (void)setStartupState;
- (void)shiftIsPressed;
- (void)shiftToggled;
- (void)shiftResult:(BOOL)left;
- (void)trigModePressedWithButton:(NSButton *)button;
- (void)valueChanged;
- (id)window;
- (BOOL)windowShouldClose:(id)sender;

// dennis ---------------------------------------------------
//
// Accessor-like methods for defaults
//
// Mainly for convenience.
//
- (void)setDefaultRadix:(int)base;
- (int)getDefaultRadixFromPref;
- (void)setDefaultComplement:(int)bits;
- (int)getDefaultComplementFromPref;
- (void)setDefaultDisplayType:(int)displayType;
- (int)getDefaultDisplayTypeFromPref;
- (void)setDefaultDigits:(int)digits;
- (int)getDefaultDigitsFromPref;
- (void)setDefaultSignificant:(int)significant;
- (int)getDefaultSignificantFromPref;
- (void)setDefaultFixed:(int)fixed;
- (int)getDefaultFixedFromPref;
- (void)setDefaultThousandsSeparator:(BOOL)isUsed;
- (BOOL)getDefaultThousandsSeparatorFromPref;
- (void)setDefaultFractionSeparator:(BOOL)isUsed;
- (BOOL)getDefaultFractionSeparatorFromPref;
- (void)setDefaultTrigMode:(int)mode;
- (BFTrigMode)getDefaultTrigModeFromPref;

// Update the view when the defaults have changed
- (void)updateRadixDisplay;
- (void)updateLengthLimit; 
- (void)updatePrecisionDisplay;
- (void)updateExponentLeftShift;
- (void)updateTrigModeDisplay;
- (void)updateExpressionDisplay;

- (void)saveDefaultsForThousands:(BOOL)separator fractions:(BOOL)fracSeparator digits:(int)digits significant:(int)significant fixed:(int)fixed display:(int)display;


@end

