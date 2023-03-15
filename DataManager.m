// ##############################################################
//  DataManager.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "DataManager.h"
#import "InputManager.h"
#import "ExpressionDisplay.h"
#import "TreeHead.h"
#import "DrawerManager.h"
#import "ExpressionSymbols.h"
#import "Value.h"
#import "History.h"
// #import "SYFlatButton.h"

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

@implementation DataManager

// dennis: start ----------------------------------------------------------------------------------------------------
#pragma mark - Preference Handling

//
// Create a set of factory defaults
//
+ (void) initialize
{
	NSMutableDictionary *factoryDefaults = [NSMutableDictionary dictionary];
	
	factoryDefaults[@"defaultRadix"]		  = @10;
	factoryDefaults[@"defaultComplement"]	  = @0;
	
	factoryDefaults[@"defaultDisplayType"]	  = @0;
	factoryDefaults[@"defaultDigits"]		  = @12;
	factoryDefaults[@"defaultSignificant"]	  = @3;
	factoryDefaults[@"defaultFixed"]		  = @3;
	factoryDefaults[@"useThousandsSeparator"] = @NO;

	factoryDefaults[@"defaultTrigMode"] = @((int)BF_degrees);
	
	[[NSUserDefaults standardUserDefaults] registerDefaults: factoryDefaults];
}

//
// Accessor-like methods for defaults
//
// Mainly for convenience.
//
- (void)setDefaultRadix:(int)base
{
	radix = base;
	[[NSUserDefaults standardUserDefaults] setInteger:radix forKey:@"defaultRadix"];
}

- (int)getDefaultRadixFromPref
{
	return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"defaultRadix"];
}

- (void)setDefaultComplement:(int)bits
{
	complement = bits;
	[[NSUserDefaults standardUserDefaults] setInteger:bits forKey:@"defaultComplement"];
}

- (int)getDefaultComplementFromPref
{
	return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"defaultComplement"];
}

- (void)setDefaultDisplayType:(int)displayType
{
	defaultDisplayType = displayType;
	[[NSUserDefaults standardUserDefaults] setInteger:displayType forKey:@"defaultDisplayType"];
}

- (int)getDefaultDisplayTypeFromPref
{
	return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"defaultDisplayType"];
}

- (void)setDefaultDigits:(int)digits
{
	defaultDigits = MIN(digits, maximumLength);
	[[NSUserDefaults standardUserDefaults] setInteger:defaultDigits forKey:@"defaultDigits"];
}

- (int)getDefaultDigitsFromPref
{
	return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"defaultDigits"];
}

- (void)setDefaultSignificant:(int)significant
{
	defaultSignificant = MIN(significant, maximumLength);
	[[NSUserDefaults standardUserDefaults] setInteger:defaultSignificant forKey:@"defaultSignificant"];
}

- (int)getDefaultSignificantFromPref
{
	return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"defaultSignificant"];
}

- (void)setDefaultFixed:(int)fixed
{
	defaultFixed = MIN(fixed, 10);
	[[NSUserDefaults standardUserDefaults] setInteger:defaultFixed forKey:@"defaultFixed"];
}

- (int)getDefaultFixedFromPref
{
	return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"defaultFixed"];
}

- (void)setDefaultThousandsSeparator:(BOOL)isUsed
{
	thousandsSeparator = isUsed;
	[[NSUserDefaults standardUserDefaults] setBool:isUsed forKey:@"useThousandsSeparator"];
}

- (BOOL)getDefaultThousandsSeparatorFromPref
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"useThousandsSeparator"];
}

- (void)setDefaultFractionSeparator:(BOOL)isUsed
{
    fractionSeparator = isUsed;
    [[NSUserDefaults standardUserDefaults] setBool:isUsed forKey:@"useFractionSeparator"];
}

- (BOOL)getDefaultFractionSeparatorFromPref
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"useFractionSeparator"];
}

- (void)setHistoryData:(History *)historyData
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
	NSURL *file = [paths.firstObject URLByAppendingPathComponent:@"MagicNumberMachine" isDirectory:YES];
	NSError *error;
	[fileManager createDirectoryAtURL:file withIntermediateDirectories:YES attributes:nil error:&error];
	file = [file URLByAppendingPathComponent:@"historyData.bin" isDirectory:NO];
    NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:historyData requiringSecureCoding:NO error:nil];
//    NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:historyData];
//    printf("Saving history data. Number of items: %ld", historyData.count);
    [fileData writeToURL:file atomically:YES];
//    [fileData writeToURL:file error:&error];
//    if (error) {
//        NSLog(@"Write error: %@", error);
//    }
}


- (History *)getHistoryDataFromPref {
	History *historyData = [[History alloc] init];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
	NSURL *file = [paths.firstObject URLByAppendingPathComponent:@"MagicNumberMachine" isDirectory:YES];
	file = [file URLByAppendingPathComponent:@"historyData.bin" isDirectory:NO];
	NSData *fileData = [NSData dataWithContentsOfURL:file];
	if (fileData) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
//        historyData = [NSKeyedUnarchiver unarchivedObjectOfClass:History.class fromData:fileData error:nil];
		historyData = [NSKeyedUnarchiver unarchiveTopLevelObjectWithData:fileData error:nil];
#pragma GCC diagnostic pop
	}
	return historyData;
}


- (void)setDefaultTrigMode:(int)mode
{
	trigMode = (BFTrigMode)mode;
	[[NSUserDefaults standardUserDefaults] setInteger:mode forKey:@"defaultTrigMode"];
}

- (BFTrigMode)getDefaultTrigModeFromPref
{
	return (BFTrigMode)[[NSUserDefaults standardUserDefaults] integerForKey:@"defaultTrigMode"];
}

//
// dennis
//
// init (modified)
//
- (instancetype)init
{
	self = [super init];
	if (self)
	{
		// Constants & states
		shiftIsDown           = NO;
		optionIsDown          = NO;
		shiftEnabledByToggle  = NO;
		optionEnabledByToggle = NO;
		equalsPressed         = NO;
		maximumLength         = 50;
		lengthLimitSave       = 0;
		fixedPlacesSave       = 0;
		fillLimitSave         = NO;
		
		// Defaults
		radix                 = [self getDefaultRadixFromPref];
		complement            = [self getDefaultComplementFromPref];
		thousandsSeparator    = [self getDefaultThousandsSeparatorFromPref];
        fractionSeparator     = [self getDefaultFractionSeparatorFromPref];
		defaultDigits         = [self getDefaultDigitsFromPref];
		defaultSignificant    = [self getDefaultSignificantFromPref];
		defaultFixed          = [self getDefaultFixedFromPref];
		defaultDisplayType    = [self getDefaultDisplayTypeFromPref];
		trigMode              = [self getDefaultTrigModeFromPref];
		
		[self updateLengthLimit];
		
		currentExpression = nil;
		currentInputPoint = nil;
		
		// No expression and all empty data sets
		[TreeHead treeHeadWithValue:nil andManager:self];
		arrayDataArray = [NSMutableArray arrayWithCapacity:0];
		dataArray      = [NSMutableArray arrayWithCapacity:0];
		data2DArray    = [NSMutableArray arrayWithCapacity:0];
//		historyArray   = [NSMutableArray arrayWithCapacity:0];
		
		// Read a history array from user defaults
		historyArray = [self getHistoryDataFromPref];
	}
	return self;
}

// dennis
//
// This is called when the preference is committed
//
- (void)saveDefaultsForThousands:(BOOL)separator
                       fractions:(BOOL)fracSeparator
						  digits:(int)digits 
					 significant:(int)significant 
						   fixed:(int)fixed 
						 display:(int)displayType
{
	[self setDefaultThousandsSeparator:separator];
    [self setDefaultFractionSeparator:fracSeparator];
	[self setDefaultDigits:digits];
	[self setDefaultSignificant:significant];
	[self setDefaultFixed:fixed];
	[self setDefaultDisplayType:displayType];
	
	[self updateExpressionDisplay];
}

- (void)updateLengthLimit
{
	switch (defaultDisplayType)
	{
		case 0:
			[self lengthLimit:defaultDigits fillLimit:NO fixedPlaces:0];
			break;
		case 1:
			[self lengthLimit:defaultSignificant fillLimit:YES fixedPlaces:0];
			break;
		case 2:
			[self lengthLimit:20 fillLimit:YES fixedPlaces:defaultFixed];
			break;
	}
}

- (void)updateRadixDisplay
{
    switch (radix)
    {
        case 2:
            [radixDisplay setStringValue:NSLocalizedString(@"Radix: Binary", description: "Base 2 radix display")];
            break;
        case 8:
            [radixDisplay setStringValue:NSLocalizedString(@"Radix: Octal", description: "Base 8 radix display")];
            break;
        case 10:
            [radixDisplay setStringValue:NSLocalizedString(@"Radix: Decimal", description: "Base 10 radix display")];
            break;
        case 16:
            [radixDisplay setStringValue:NSLocalizedString(@"Radix: Hexadecimal", description: "Base 16 radix display")];
            break;
    }
}

- (void)updatePrecisionDisplay
{
	if (complement != 0)
	{
		[precisionDisplay setStringValue:[NSString stringWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Precision: %d-bit 2's Complement" value:nil table:nil], complement]];
	}
	else
	{
		switch (defaultDisplayType)
		{
            case 0:
				[precisionDisplay setStringValue:[NSString stringWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Precision: %d digits" value:nil table:nil], defaultDigits]];
				break;
			case 1:
				[precisionDisplay setStringValue:[NSString stringWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Precision: %d significant figures" value:nil table:nil], defaultSignificant]];
				break;
			case 2:
				[precisionDisplay setStringValue:[NSString stringWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Precision: %d point places" value:nil table:nil], defaultFixed]];
				break;
		}
	}
}

- (void)enable:(NSButton *)button enable:(BOOL) enable {
    //SYFlatButton *b = (SYFlatButton *)button;
    [button setEnabled: enable];
    //b.titleNormalColor = enable ? NSColor.labelColor : NSColor.grayColor;
}

- (void)updateExponentLeftShift
{
    [self enable:shift3Left enable:(shiftIsActive || (fixedPlaces == 0 && complement == 0))];
    [self enable:shift3Right enable:(shiftIsActive || (fixedPlaces == 0 && complement == 0))];
}

- (NSString *)getTrigStringForMode:(BFTrigMode)mode {
	switch (mode) {
		case BF_degrees:
			return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Degrees" value:nil table:nil];
		case BF_radians:
			return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Radians" value:nil table:nil];
		case BF_gradians:
			return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Gradians" value:nil table:nil];
	}
}

- (NSString *)getTrigAbbreviationForMode:(BFTrigMode)mode {
	switch (mode) {
		case BF_degrees:
			return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Deg" value:nil table:nil];
		case BF_radians:
			return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Rad" value:nil table:nil];
		case BF_gradians:
			return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Grad" value:nil table:nil];
	}
}

- (BFTrigMode)increment:(BFTrigMode)mode {
	switch (mode) {
		case BF_degrees:
			return BF_radians;
		case BF_radians:
			return BF_gradians;
		case BF_gradians:
			return BF_degrees;
	}
}

- (void)updateTrigModeDisplay {
	[trigModeDisplay setStringValue:[self getTrigStringForMode:trigMode]];
}

- (void)updateExpressionDisplay {
	[currentExpression refresh];
	[self valueChanged];
}



//
// exportToPDF:
//
// Save the expression view to a PDF file.
//
- (IBAction)exportToPDF:(id)sender
{
	NSData *pdfData = [expressionDisplay pdfData];
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];

	//
	// Show the window as a modal sheet
	//
	// Updated for new interfaces - Mike
	[savePanel beginSheetModalForWindow:[expressionDisplay window] completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
			NSURL *filename = [savePanel URL];
			if (filename.pathExtension.length == 0) { filename = [filename URLByAppendingPathExtension:@"pdf"]; }
			[pdfData writeToURL:filename atomically:YES];
		} else {
			[savePanel close];
		}
	}];
}

//
// addData
//
// Breaks the InputManager control of all the buttons by handling the "Add to Data" button.
// Appends the value in the expression display to the appropriate data array.
//
- (IBAction)addData:(id)sender
{
	BigCFloat	*numberCopy;
    NSButton    *button = sender;
    NSString    *title = button.title;
    
	if (!equalsPressed) [self equalsPressed];
	
	numberCopy = [[currentExpression getValue] copy];
	
	if ([title isEqual:@"Add 2D"]) // && !self.getOption)
	{
		[drawerManager addData2D:numberCopy];
	}
	else if ([title isEqual:@"Add Array"])
	{
		[drawerManager addArrayData:numberCopy];
	}
	else
	{
		[drawerManager addData:numberCopy];
	}
}

//
// arrayData
//
// Allows access to the array data
//
- (NSMutableArray*)arrayData
{
	return arrayDataArray;
}

//
// awakeFromNib
//
// Fill out the display strings based on values restored from preferences
//
- (void)awakeFromNib
{
	[self updateRadixDisplay];		// dennis
	[self updatePrecisionDisplay];	// dennis
	[self updateTrigModeDisplay];	// dennis
	
    // force shifted keys to be updated
    shiftIsActive = !shiftIsActive;   // this is undone in shiftIsPressed
    [self shiftIsPressed];
}

//
// clearExpression
//
// Does what you'd expect... clears the whole expression.
//
- (void)clearExpression
{
	equalsPressed = NO;
	[TreeHead treeHeadWithValue:nil andManager:self];

	[self valueChanged];
}

//
// clearHistory
//
// Again, pretty obvious... clears the history.
//
- (IBAction)clearHistory:(id)sender
{
	historyArray = [[History alloc] init];
	[self setHistoryData:historyArray];
	[drawerManager updateHistory];
}

//
// data
//
// Allows access to the data array.
//
- (NSMutableArray*)data
{
	return dataArray;
}

//
// data2D
//
// Allows access to the 2D data.
//
- (NSMutableArray*)data2D
{
	return data2DArray;
}

//
// ensureInputWithValue
//
// A behaviour thing... if the user presses equals, sometimes the next button pressed
// will use the result as the first number in the new expression, sometimes it will not.
// Calling this function with preserveValue set appropriately before 
//
- (void)ensureInputWithValue:(BOOL)preserveValue
{
	if (equalsPressed)
	{
		if (preserveValue)
		{
			[TreeHead treeHeadWithValue:[currentExpression getValue] andManager:self];
		}
		else
		{
			[TreeHead treeHeadWithValue:nil andManager:self];
		}
		
		equalsPressed = NO;
	}
}

//
// equalsPressed
//
// When equals is pressed we enable display of the result and append the expression to
// the history
//
- (void)equalsPressed
{
	if (equalsPressed) return;
	
	// Enable dispaly of the result
	equalsPressed = YES;
	[currentExpression equalsPressed];
	
	[self valueChanged];
	
	// Append the current expression to the history
	if ([currentExpression child] != nil)
	{
		[historyArray addItem:[NSKeyedArchiver archivedDataWithRootObject:[currentExpression child] requiringSecureCoding:NO error:nil]
			   withBezierPath:[expressionDisplay expressionPathFlipped]];
		[self setHistoryData:historyArray];   // save the data to user preferences
		[drawerManager updateHistory];
	}
}

//
// getComplement
//
// Allows access to the complement variable
//
- (int)getComplement
{
	return complement;
}

//
// getCurrentExpression
//
// Allows access to the current expression
//
- (Expression*)getCurrentExpression
{
	return currentExpression;
}

//
// getCurrentExpression
//
// Returns whether or not the equals button has been pressed on the current expression
//
- (BOOL)getEqualsPressed
{
	return equalsPressed;
}

//
// getFillLimit
//
// Returns whether or not the equals button has been pressed on the current expression
//
- (BOOL)getFillLimit
{
	return fillLimit;
}

//
// getFixedPlaces
//
// Gives the number of fixes places in the display (if any)
//
- (unsigned int)getFixedPlaces
{
	return fixedPlaces;
}

//
// getInputPoint
//
// Gives a pointer to the current input point in the current expression
//
- (Expression*)getInputPoint
{
	return currentInputPoint;
}

//
// getLengthLimit
//
// Maximum number of digits. This returns it.
//
- (unsigned int)getLengthLimit
{
	return lengthLimit;
}

//
// getMaximumLength
//
// Maximum number of digits allowable at any time. This returns it.
//
- (unsigned int)getMaximumLength
{
	return maximumLength;
}

//
// getOption
//
// Returns whether the option key is down.
//
- (BOOL)getOption
{
	//BOOL option = self // [shiftOption isSelectedForSegment:1];
    return optionIsDown;
}

//
// getRadix
//
// Returns the current radix.
//
- (short)getRadix
{
	return radix;
}

//
// getShift
//
// Tells whether the shift key is down
//
- (BOOL)getShift
{
	return shiftIsActive;
}

//
// getThousandsSeparator
//
// Returns whether to separate digits in groups.
//
- (BOOL)getThousandsSeparator
{
	return thousandsSeparator;
}

//
// getTrigMode
//
// Degrees, radians or gradians.
//
- (int)getTrigMode
{
	return trigMode;
}

//
// history
//
// Allows access to the history array.
//
- (History *)history
{
	return historyArray;
}

//
// lengthLimit
//
// Allows the "Disp" button sheets to set the precision, scientific notation or fixed
// display.
//
- (void)lengthLimit:(unsigned int)limit fillLimit:(BOOL)fill fixedPlaces:(unsigned int)places
{
	if (limit > maximumLength)
		limit = maximumLength;
	
	if (lengthLimitSave == 0)
	{
		lengthLimit = limit;
		fillLimit = fill;
		fixedPlaces = places;
	}
	else
	{
		lengthLimitSave = limit;
		fixedPlacesSave = places;
		fillLimitSave = fill;
		
		if (places > lengthLimit - 1)
			fixedPlaces = lengthLimit - 1;
		else
			fixedPlaces = places;
	}
	
	[self updatePrecisionDisplay];	// dennis
	[self updateExponentLeftShift]; // dennis
	[self updateExpressionDisplay]; // dennis
}

//
// optionIsPressed
//
// Set the option key's state
//
- (void)optionIsPressed:(BOOL)isPressed
{
	// No longer needed - Mike
//    if (!optionIsDown && isPressed) {
//		optionIsDown = isPressed;
//        addDataButton.title = @"Add Array";
//        dispButton.title = @"Fixed";
////		[optionButton highlight:optionIsDown];
//    } else if (optionIsDown && isPressed) {
//        addDataButton.title =  @"Add Data";
//        dispButton.title = @"Disp";
//        optionIsDown = NO;
//    }

	optionEnabledByToggle = NO;
}

//
// optionToggled
//
// Toggle the option key's state
//
- (void)optionToggled
{
	// No longer needed - Mike
//	optionIsDown = !optionIsDown;
////	[optionButton highlight:optionIsDown];
//
//	if (optionIsDown)
//		optionEnabledByToggle = YES;
}

//
// setCurrentExpression
//
// Replace the current expression with the one that is passed in.
//
- (void)setCurrentExpression:(Expression*)newExpression
{
	currentExpression = (TreeHead *)newExpression;
	[self valueChanged];
}

//
// setInputPoint
//
// Set the current input point in the current expression to the point passed in.
//
- (void)setInputPoint:(Expression*)point
{
	currentInputPoint = point;
}

//
// setInputAtPoint
//
// Determine the point clicked by the mouse and move the insertion point to it.
//
- (void)setInputAtPoint:(NSPoint)point
{
	Expression	*node;
	
	node = [currentExpression nodeContainingPoint:point];
	
	if (node == nil)
		node = currentExpression;

	equalsPressed = NO;
	[self setInputPoint:node];
	[self valueChanged];
}

//
// setRadix
//
// Respond to a radix change from the radix drawer
//
- (void)setRadix:(short)newRadix useComplement:(int)useComplement
{
	[self setDefaultRadix: (int)newRadix];		// dennis
	[self setDefaultComplement: useComplement];	// dennis
	
	if (useComplement != 0)
	{
		if (lengthLimitSave == 0)
		{
			lengthLimitSave = lengthLimit;
			fixedPlacesSave = fixedPlaces;
			fillLimitSave = fillLimit;
		}
		lengthLimit = useComplement / (int)(log(radix) / log(2.0));
		
		fixedPlaces = 0;
		fillLimit = NO;
	}
	else if (lengthLimitSave != 0)
	{
		lengthLimit = lengthLimitSave;
		fixedPlaces = fixedPlacesSave;
		fillLimit = fillLimitSave;
		lengthLimitSave = 0;
		fixedPlacesSave = 0;
		fillLimitSave = NO;
	}
	
	[self updateRadixDisplay]; // dennis
	[self updatePrecisionDisplay];	// dennis
	[self updateExponentLeftShift]; // dennis
	[self updateExpressionDisplay]; // dennis
	
	[inputManager setControlsForRadix:radix]; // dennis
}

//
// setStartupState
//
// Tell all the other bits to go to first positions.
//
- (void)setStartupState
{
	[drawerManager setStartupState];
	[inputManager setControlsForRadix:radix];
	[inputManager setNextResponder:[self window]];
	
	// In 10.3, I started noticing a button update problem on startup. This is to try to fix that.
	[[self window] makeKeyAndOrderFront:self];
	[[self window] display];
    shiftIsActive = !shiftIsActive;
    [self shiftIsPressed];

	// Sanity check to ensure window is well-sized and visible (although this should be
	// enforced in the NIB file also).
	NSRect windowRect = [[self window] frame];
	NSRect screenRect = [[[self window] screen] frame];
	if (!NSIntersectsRect(windowRect, screenRect))
	{
		[[self window] setContentSize:NSMakeSize(330, 278)];
		[[self window] cascadeTopLeftFromPoint:NSZeroPoint];
	}
}

// dennis: setThousandsSeparator is no longer needed
//
// setThousandsSeparator
//
// Sets whether to separate digits in groups.
//
- (void)setThousandsSeparator:(BOOL)separator
{
	thousandsSeparator = separator;
}

//
// toFormattedString:
//
// Translates the constant with an "_" to a subscript or "^" to a superscript -- Mike
//
- (NSAttributedString *)toFormattedString: (NSString *)string {
	NSRange subLocation = [string rangeOfString:@"_"];
	NSRange superLocation = [string rangeOfString:@"^"];
    NSRange location = NSMakeRange(0, 0);
	NSNumber *number;
	NSNumber *baseOffset;
	string = [string stringByReplacingOccurrencesOfString:@"_" withString:@""];
	string = [string stringByReplacingOccurrencesOfString:@"^" withString:@""];
	if (subLocation.length > 0) {
		location.length = string.length - subLocation.location;
		location.location = subLocation.location;
		number = @-1;
		baseOffset = @8;
	}
	if (superLocation.length > 0) {
		location.length = string.length - superLocation.location;
		location.location = superLocation.location;
		number = @1;
		baseOffset = @8;
	}
	NSRange full = NSMakeRange(0, string.length);
	NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:string];
    [result setAlignment:NSTextAlignmentCenter range:full];   //kCTTextAlignmentCenter range:full];
	[result addAttribute:NSKernAttributeName value:@-0.5 range:full];
	[result addAttribute:NSBaselineOffsetAttributeName value:baseOffset range:full];
	[result addAttribute:NSFontAttributeName value:[ExpressionSymbols getKeyFontWithSize:16] range:full];
	[result addAttribute:NSFontAttributeName value:[ExpressionSymbols getKeyFontWithSize:12] range:location];
	[result addAttribute:NSSuperscriptAttributeName value:number range:location];
	return result;
}

//
// shiftIsPressed
//
// Set the current state of the shift button.
//
- (void)shiftIsPressed
{
	shiftIsActive = !shiftIsActive;
	if (shiftIsActive) {
        [mainKeys setHidden:true];
        [alternateKeys setHidden:false];
//        secondButton.state = NSControlStateValueOn;
//		sinButton. title = @"sin⁻¹";     // attributedTitle = [self toFormattedString:@"sin^-1"];
//		cosButton. title = @"cos⁻¹";     // attributedTitle = [self toFormattedString:@"cos^-1"];
//		tanButton. title = @"tan⁻¹";     // attributedTitle = [self toFormattedString:@"tan^-1"];
//		sinhButton.title = @"sinh⁻¹";     // attributedTitle = [self toFormattedString:@"sinh^-1"];
//		coshButton.title = @"cosh⁻¹";     // attributedTitle = [self toFormattedString:@"cosh^-1"];
//		tanhButton.title = @"tanh⁻¹";     // attributedTitle = [self toFormattedString:@"tanh^-1"];
//        tenToXButton.image = [NSImage imageNamed:@"2tox"];
//        logButton.title = @"log₂";
//		shift3Left.title = @"xor";
//		shift3Right.title = @"not";
//		modButton.title = @"arg";
//        factorialButton.title = @"∑x";
//        dispButton.title = @"Sci";
	} else {
        [mainKeys setHidden:false];
        [alternateKeys setHidden:true];
//        secondButton.state = NSControlStateValueOff;
//		sinButton.title = @"sin";
//		cosButton.title = @"cos";
//		tanButton.title = @"tan";
//		sinhButton.title = @"sinh";
//		coshButton.title = @"cosh";
//		tanhButton.title = @"tanh";
//        tenToXButton.image = [NSImage imageNamed:@"10tox"];
//		logButton.title = @"log";
//		shift3Left.title = @"<3";
//		shift3Right.title = @">3";
//		modButton.title = @"mod";
//        factorialButton.title = @"x!";
//        dispButton.title = @"Disp";
	}
}

//
// shiftResult
//
// Perform a shift left or a shift right on the current value.
//
- (void)shiftResult:(BOOL)left
{
	if (!equalsPressed)
		[self equalsPressed];
	
	[currentExpression shiftValue:(BOOL)left];
	[self valueChanged];
}

//
// shiftToggled
//
// Toggle the current state of the shift button.
//
- (void)shiftToggled
{
//	shiftIsDown = !shiftIsDown;
//	[shiftButton highlight:shiftIsDown];
//	
//	if (shiftIsDown)
//		shiftEnabledByToggle = YES;
}

//
// trigModePressed
//
// Toggle the current state of the trig mode.
//
- (void)trigModePressedWithButton:(NSButton *)button {
	trigMode = [self increment:trigMode];
	
	[self setDefaultTrigMode:(int)trigMode];	// dennis
	[self updateTrigModeDisplay];				// dennis
	
	NSString *title = [self getTrigAbbreviationForMode:[self increment:trigMode]];
	[button setTitle:title];   // Mike
}

//
// valueChanged
//
// This is called when something in the expression changes. Tells the expression
// display to update itself to reflect the change.
//
- (void)valueChanged
{
	[expressionDisplay expressionChanged];
	
	if (self.getShift) {
		[self shiftIsPressed];
	}
}


//
// window
//
// Allows access to this object's window.
//
- (id)window
{
	return [expressionDisplay window];
}

- (BOOL)windowShouldClose:(id)sender
{
	[NSApp terminate:self];
	return YES;
}

@end
