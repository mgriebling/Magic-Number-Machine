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
	__weak IBOutlet NSButton *modButton;
	__weak IBOutlet NSButton *tenToXButton;
	__weak IBOutlet NSButton *logButton;
	__weak IBOutlet NSButton *shift3Left;
	__weak IBOutlet NSButton *shift3Right;
	__weak IBOutlet NSButton *tanhButton;
	__weak IBOutlet NSButton *coshButton;
	__weak IBOutlet NSButton *sinhButton;
	__weak IBOutlet NSButton *tanButton;
	__weak IBOutlet NSButton *cosButton;
	__weak IBOutlet NSButton *sinButton;
	__weak IBOutlet NSButton *reciprocalButton;	
	__weak IBOutlet NSButton *secondButton;
    __weak IBOutlet NSButton *cubeRootButton;
    __weak IBOutlet NSButton *anyRootButton;
    __weak IBOutlet NSButton *expToXButton;
    __weak IBOutlet NSButton *xToYButton;
    __weak IBOutlet NSButton *factorialButton;
    __weak IBOutlet NSButton *addDataButton;
    __weak IBOutlet NSButton *dispButton;
    
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

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (IBAction)exportToPDF:(id)sender;
- (IBAction)addData:(id)sender;
- (NSMutableArray*)arrayData;
- (void)clearExpression;
- (IBAction)clearHistory:(id)sender;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableArray *data;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableArray *data2D;
- (void)ensureInputWithValue:(BOOL)preserveValue;
- (void)equalsPressed;
@property (NS_NONATOMIC_IOSONLY, getter=getComplement, readonly) int complement;
@property (NS_NONATOMIC_IOSONLY, getter=getCurrentExpression, strong) Expression *currentExpression;
@property (NS_NONATOMIC_IOSONLY, getter=getEqualsPressed, readonly) BOOL equalsPressed;
@property (NS_NONATOMIC_IOSONLY, getter=getFillLimit, readonly) BOOL fillLimit;
@property (NS_NONATOMIC_IOSONLY, getter=getFixedPlaces, readonly) unsigned int fixedPlaces;
@property (NS_NONATOMIC_IOSONLY, getter=getInputPoint, strong) Expression *inputPoint;
@property (NS_NONATOMIC_IOSONLY, getter=getLengthLimit, readonly) unsigned int lengthLimit;
@property (NS_NONATOMIC_IOSONLY, getter=getMaximumLength, readonly) unsigned int maximumLength;
@property (NS_NONATOMIC_IOSONLY, getter=getOption, readonly) BOOL option;
@property (NS_NONATOMIC_IOSONLY, getter=getRadix, readonly) short radix;
@property (NS_NONATOMIC_IOSONLY, getter=getShift, readonly) BOOL shift;
@property (NS_NONATOMIC_IOSONLY, getter=getThousandsSeparator) BOOL thousandsSeparator;
@property (NS_NONATOMIC_IOSONLY, getter=getTrigMode, readonly) int trigMode;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) History *history;
- (void)lengthLimit:(unsigned int)limit fillLimit:(BOOL)fill fixedPlaces:(unsigned int)places;
- (void)optionIsPressed:(BOOL)isPressed;
- (void)optionToggled;
- (void)setInputAtPoint:(NSPoint)point;
- (void)setRadix:(short)newRadix useComplement:(int)useComplement;
- (void)setStartupState;
- (void)shiftIsPressed;
- (void)shiftToggled;
- (void)shiftResult:(BOOL)left;
- (void)trigModePressedWithButton:(NSButton *)button;
- (void)valueChanged;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) id window;
- (BOOL)windowShouldClose:(id)sender;

// dennis ---------------------------------------------------
//
// Accessor-like methods for defaults
//
// Mainly for convenience.
//
- (void)setDefaultRadix:(int)base;
@property (NS_NONATOMIC_IOSONLY, getter=getDefaultRadixFromPref, readonly) int defaultRadixFromPref;
- (void)setDefaultComplement:(int)bits;
@property (NS_NONATOMIC_IOSONLY, getter=getDefaultComplementFromPref, readonly) int defaultComplementFromPref;
- (void)setDefaultDisplayType:(int)displayType;
@property (NS_NONATOMIC_IOSONLY, getter=getDefaultDisplayTypeFromPref, readonly) int defaultDisplayTypeFromPref;
- (void)setDefaultDigits:(int)digits;
@property (NS_NONATOMIC_IOSONLY, getter=getDefaultDigitsFromPref, readonly) int defaultDigitsFromPref;
- (void)setDefaultSignificant:(int)significant;
@property (NS_NONATOMIC_IOSONLY, getter=getDefaultSignificantFromPref, readonly) int defaultSignificantFromPref;
- (void)setDefaultFixed:(int)fixed;
@property (NS_NONATOMIC_IOSONLY, getter=getDefaultFixedFromPref, readonly) int defaultFixedFromPref;
- (void)setDefaultThousandsSeparator:(BOOL)isUsed;
@property (NS_NONATOMIC_IOSONLY, getter=getDefaultThousandsSeparatorFromPref, readonly) BOOL defaultFractionSeparatorFromPref;
- (void)setDefaultFractionSeparator:(BOOL)isUsed;
@property (NS_NONATOMIC_IOSONLY, getter=getDefaultFractionSeparatorFromPref, readonly) BOOL defaultThousandsSeparatorFromPref;
- (void)setDefaultTrigMode:(int)mode;
@property (NS_NONATOMIC_IOSONLY, getter=getDefaultTrigModeFromPref, readonly) BFTrigMode defaultTrigModeFromPref;

// Update the view when the defaults have changed
- (void)updateRadixDisplay;
- (void)updateLengthLimit; 
- (void)updatePrecisionDisplay;
- (void)updateExponentLeftShift;
- (void)updateTrigModeDisplay;
- (void)updateExpressionDisplay;

- (void)saveDefaultsForThousands:(BOOL)separator fractions:(BOOL)fracSeparator digits:(int)digits significant:(int)significant fixed:(int)fixed display:(int)display;


@end

