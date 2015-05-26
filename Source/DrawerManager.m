// ##############################################################
//  DrawerManager.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "DrawerManager.h"
#import "DataManager.h"
#import "DataFunctions.h"
#import "HistoryCell.h"
#import "Expression.h"
#import "ExpressionSymbols.h"

#import "NSObject+NSPerformSelector.h"

//
// About the DrawerManager
//
// The DrawerManager is an odd collection of both data, behaviour and input
// management for all of the drawers attached to the edge of the window. There
// is only one instance of the DrawerManager in the application.
//
// All the data which statically populates some tables in the drawers is statically
// defined in the consructor (ugly). This includes all the constants and the
// Data functions.
//
// The actual data kept in the "Data" drawers is owned by the DataManager class.
//

@implementation DrawerManager

//
// init
//
// Constructor. Performs the duty of filling the function tables and constants table. Not really
// something that should be loaded in a constructor but there you go.
//
- (instancetype)init
{
	self = [super init];
	if (self)
	{
		activeDrawer = nil;
		numArrayColumns = 3;
		
		historyCell = [[HistoryCell alloc] init];
		
		arrayDataFunctionRows =
			@[@[@"Gaussian Elimination", [NSValue value:&@selector(gaussianelimination:) withObjCType:@encode(SEL)]],
				@[@"Gaussian Elimination w/ Backsub", [NSValue value:&@selector(gaussianeliminationwithbacksub:) withObjCType:@encode(SEL)]],
				@[@"Determinant", [NSValue value:&@selector(determinant:) withObjCType:@encode(SEL)]],
				@[@"Inverse", [NSValue value:&@selector(inverse:) withObjCType:@encode(SEL)]]];
		dataFunctionRows =
			@[@[@"Sum", [NSValue value:&@selector(sum:) withObjCType:@encode(SEL)]],
				@[@"Mean (Average)", [NSValue value:&@selector(mean:) withObjCType:@encode(SEL)]],
				@[@"Mode (Most Frequent)", [NSValue value:&@selector(mode:) withObjCType:@encode(SEL)]],
				@[@"Median (Middle value)", [NSValue value:&@selector(median:) withObjCType:@encode(SEL)]],
				@[@"Variance", [NSValue value:&@selector(variance:) withObjCType:@encode(SEL)]],
				@[@"Standard Deviation", [NSValue value:&@selector(stddev:) withObjCType:@encode(SEL)]],
				@[@"Coefficient of Variation", [NSValue value:&@selector(coefofvariation:) withObjCType:@encode(SEL)]]];
		data2DFunctionRows =
			@[@[@"m (slope, Rank regression on y)", [NSValue value:&@selector(mfromrankregressionony:) withObjCType:@encode(SEL)]],
				@[@"b (y-intercept, Rank regression on y)", [NSValue value:&@selector(bfromrankregressionony:) withObjCType:@encode(SEL)]],
				@[@"a (x-intercept, Rank regression on y)", [NSValue value:&@selector(afromrankregressionony:) withObjCType:@encode(SEL)]],
				@[@"m (slope, Rank regression on x)", [NSValue value:&@selector(mfromrankregressiononx:) withObjCType:@encode(SEL)]],
				@[@"b (y-intercept, Rank regression on x)", [NSValue value:&@selector(bfromrankregressiononx:) withObjCType:@encode(SEL)]],
				@[@"a (x-intercept, Rank regression on x)", [NSValue value:&@selector(bfromrankregressiononx:) withObjCType:@encode(SEL)]],
				@[@"m (slope, regression on y, intercept at origin)", [NSValue value:&@selector(mfromrankregressiononywithoriginintercept:) withObjCType:@encode(SEL)]],
				@[@"m (slope, regression on x, intercept at origin)", [NSValue value:&@selector(mfromrankregressiononxwithoriginintercept:) withObjCType:@encode(SEL)]]];
		
		radixDataRows = @[
			@[@2, @"Binary", @0],
			@[@8, @"Octal", @0],
			@[@10, @"Decimal", @0],
			@[@16, @"Hexadecimal", @0],
			@[@2, @"8-bit Binary", @8],
			@[@8, @"8-bit Octal", @8],
			@[@16, @"8-bit Hex", @8],
			@[@2, @"16-bit Binary", @16],
			@[@8, @"16-bit Octal", @16],
			@[@16, @"16-bit Hex", @16],
			@[@2, @"32-bit Binary", @32],
			@[@8, @"32-bit Octal", @32],
			@[@16, @"32-bit Hex", @32],
			@[@2, @"64-bit Binary", @64],
			@[@8, @"64-bit Octal", @64],
			@[@16, @"64-bit Hex", @64]
		];
		

//		constantsDataRows =
//			@[
//				@[@"a_0",	@"	Bohr radius (m)",							[BigCFloat bigFloatWithDouble:0.5291772085936e-10 radix:10]],
//				@[@"α",		@"	Fine structure constant",					[BigCFloat bigFloatWithDouble:7.297352537650e-3 radix:10]],
//				@[@"atm",	@"	Standard atmosphere (Pa)",					[BigCFloat bigFloatWithInt:101325 radix:10]],
//				@[@"b",		@"	Wien displacement law constant (m K)",		[BigCFloat bigFloatWithDouble:2.897768551e-3 radix:10]],
//				@[@"c_1",	@"	First radiation constant (W m²)",			[BigCFloat bigFloatWithDouble:3.7417711819e-16 radix:10]],
//				@[@"c_2",	@"	Second radiation constant (m K)",			[BigCFloat bigFloatWithDouble:1.438775225e-2 radix:10]],
//				@[@"c",		@"	Speed of light in vacuum (m s⁻¹)",			[BigCFloat bigFloatWithInt:299792458 radix:10]],
//				@[@"E_h",	@"	Hartree energy (J)",						[BigCFloat bigFloatWithDouble:4.3597439422e-18 radix:10]],
//				@[@"e_c",	@"	Elementary charge (C)",						[BigCFloat bigFloatWithDouble:1.60217648740e-19 radix:10]],
//				@[@"ε_0",	@"	Permittivity of vacuum (F m⁻¹)",			[BigCFloat bigFloatWithDouble:8.854187817620389850536563e-12 radix:10]],
//				@[@"eV",	@"	Electron volt (J)",							[BigCFloat bigFloatWithDouble:1.60217648740e-19 radix:10]],
//				@[@"F",		@"	Faraday constant (C mol⁻¹)",				[BigCFloat bigFloatWithDouble:96485.339924 radix:10]],
//				@[@"g_e",	@"	Electron g-factor",							[BigCFloat bigFloatWithDouble:-2.002319304362215 radix:10]],
//				@[@"g_µ",	@"	Muon g-factor",								[BigCFloat bigFloatWithDouble:-2.002331841412 radix:10]],
//				@[@"g_n",	@"	Standard acceleration of gravity (m s⁻²)",	[BigCFloat bigFloatWithDouble:9.80665 radix:10]],
//				@[@"G",		@"	Gravitational constant (m³ kg⁻¹ s⁻²)",		[BigCFloat bigFloatWithDouble:6.6742867e-11 radix:10]],
//			    @[@"G_0",	@"	Conductance quantum (s)",					[BigCFloat bigFloatWithDouble:7.748091700453e-5 radix:10]],
//				@[@"h",		@"	Planck constant (J s)",						[BigCFloat bigFloatWithDouble:6.6260689633e-34 radix:10]],
//				@[@"ħ",		@"	Planck constant/2π (J s)",					[BigCFloat bigFloatWithDouble:1.05457162853e-34 radix:10]],
//				@[@"i",		@"	square-root of -1",							[BigCFloat i]],
//				@[@"k",		@"	Boltzmann constant (J K⁻¹)",				[BigCFloat bigFloatWithDouble:1.380650424e-23 radix:10]],
//				@[@"l_p",	@"	Planck length (m)",							[BigCFloat bigFloatWithDouble:1.61625281e-35 radix:10]],
//				@[@"ƛ_C",	@"	Electron Compton wavelength/2π (m)",		[BigCFloat bigFloatWithDouble:3.861592645953e-13 radix:10]],
//				@[@"λ_C,n", @"	Neutron Compton wavelength (m)",			[BigCFloat bigFloatWithDouble:1.319590895120e-15 radix:10]],
//				@[@"λ_C,p", @"	Proton Compton wavelength (m)",				[BigCFloat bigFloatWithDouble:1.321409844619e-15 radix:10]],
//				@[@"λ_C",	@"	Electron Compton wavelength (m)",			[BigCFloat bigFloatWithDouble:2.426310217533e-12 radix:10]],
//				@[@"m_d",	@"	Deuteron mass (kg)",						[BigCFloat bigFloatWithDouble:3.3435832017e-27 radix:10]],
//				@[@"m_e",	@"	Electron mass (Kg)",						[BigCFloat bigFloatWithDouble:9.1093821545e-31 radix:10]],
//				@[@"m_n",	@"	Neutron mass (kg)",							[BigCFloat bigFloatWithDouble:1.6749286e-27 radix:10]],
//				@[@"m_P",	@"	Planck mass (kg)",							[BigCFloat bigFloatWithDouble:2.1764411e-08 radix:10]],
//				@[@"m_p",	@"	Proton mass (kg)",							[BigCFloat bigFloatWithDouble:1.67262163783e-27 radix:10]],
//				@[@"m_u",	@"	Atomic mass constant (kg)",					[BigCFloat bigFloatWithDouble:1.66053878283e-27 radix:10]],
//				@[@"µ_0",	@"	Magnetic Permittivity of vacuum (N A⁻²)",	[BigCFloat bigFloatWithDouble:12.56637061435917295385057e-7 radix:10]],
//				@[@"µ_B",	@"	Bohr magneton (J T⁻¹)",						[BigCFloat bigFloatWithDouble:9.2740091523e-24 radix:10]],
//				@[@"µ_d",	@"	Deuteron magnetic moment (J T⁻¹)",			[BigCFloat bigFloatWithDouble:4.3307346511e-27 radix:10]],
//				@[@"µ_N",	@"	Nuclear magneton (J T⁻¹)",					[BigCFloat bigFloatWithDouble:5.0507832413e-27 radix:10]],
//				@[@"n_0",	@"	Loschmidt constant (m⁻³)",					[BigCFloat bigFloatWithDouble:2.686777447e+25 radix:10]],
//				@[@"N_A",	@"	Avagadro constant (mol⁻¹)",					[BigCFloat bigFloatWithDouble:6.0221417930e+23 radix:10]],
//				@[@"φ_0",	@"	Magnetic flux quantum (Wb)",				[BigCFloat bigFloatWithDouble:2.06783366752e-15 radix:10]],
//				@[@"π",		@"	Pi",										[BigCFloat piWithRadix:10]],
//				@[@"r_e",	@"	Electron classical radius (m)",				[BigCFloat bigFloatWithDouble:2.817940289458e-15 radix:10]],
//				@[@"R_H",	@"	Quantized Hall resistance (Ω)",				[BigCFloat bigFloatWithDouble:25812.8063 radix:10]],
//				@[@"R",		@"	Molar gas constant (J mol⁻¹ K⁻¹)",			[BigCFloat bigFloatWithDouble:8.31447215 radix:10]],
//				@[@"R_∞",	@"	Rydberg constant (m⁻¹)",					[BigCFloat bigFloatWithDouble:10973731.56852773 radix:10]],
//				@[@"σ_e",	@"	Electron Thomson cross section (m²)",		[BigCFloat bigFloatWithDouble:6.65245855827e-29 radix:10]],
//				@[@"σ",		@"	Stefan-Boltzmann const. (W m⁻² K⁻⁴)",		[BigCFloat bigFloatWithDouble:5.67040040e-08 radix:10]],
//				@[@"t_p",	@"	Planck time (s)",							[BigCFloat bigFloatWithDouble:5.3912427e-44 radix:10]],
//				@[@"T_P",	@"	Planck temperature (K)",					[BigCFloat bigFloatWithDouble:1.416785e32 radix:10]],
//				@[@"V_m",	@"	Molar vol. (ideal gas at STP) (m³ mol⁻¹)",	[BigCFloat bigFloatWithDouble:22.41399639e-3 radix:10]]
//			];
	}
	return self;
}

//
// addArrayData
//
// Adds a value to the array data, updating the table to display the change
//
- (void)addArrayData:(BigCFloat*)value
{
	[[dataManager arrayData] addObject:value];
	[self updateArrayDataArray];
	return;
}

//
// addData
//
// Adds a value to the data, updating the table to display the change
//
- (void)addData:(BigCFloat*)value
{
	if ([dataTableView selectedRow] < 0 ||
		[dataTableView selectedRow] > [[dataManager data] count])
	{
		[[dataManager data] addObject:value];
		[self updateDataArray];
		return;
	}
	
	[dataManager data][[dataTableView selectedRow]] = value;
	[self updateDataArray];
}

//
// addData2D
//
// Adds a value to the 2D data, updating the table to display the change
//
- (void)addData2D:(BigCFloat*)value
{
	[[dataManager data2D] addObject:value];
	[self updateData2DArray];
	return;
}

//
// arrayColumnsChanged
//
// Changes the number of columns in the array data.
//
- (IBAction)arrayColumnsChanged:(id)sender
{
	NSTableColumn	*column;

	numArrayColumns = [sender intValue];
	
	while ([arrayDataTableView numberOfColumns] > numArrayColumns)
	{
		int numberOfColumns = [arrayDataTableView numberOfColumns];
		column = [arrayDataTableView tableColumnWithIdentifier:[NSString stringWithFormat:@"%d", numberOfColumns - 1]];
		[arrayDataTableView removeTableColumn:column];
	}
	while ([arrayDataTableView numberOfColumns] < numArrayColumns)
	{
		column = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%ld", (long)[arrayDataTableView numberOfColumns]]];
		[[column headerCell] setStringValue:[NSString stringWithFormat:@"%ld", [arrayDataTableView numberOfColumns] + 1]];
		[column setWidth:60.0];
		[arrayDataTableView addTableColumn:column];
	}
	
	[self updateArrayDataArray];
}

//
// applyArrayDataFunction
//
// Calls the currently selected function and applies it to the array data
//
- (IBAction)applyArrayDataFunction:(id)sender
{
	BigCFloat *result;
	SEL		method;
	
	if ([[dataManager arrayData] count] == 0)
	{
		return;
	}
	
	[arrayDataFunctionRows[[arrayDataFunctionsTableView selectedRow]][1] getValue:&method];
	
	result = [NSObject target:dataFunctions performSelector:method withObject:[dataManager arrayData]];  // Fixed warning - Mike
//	result = [dataFunctions performSelector:method withObject:[dataManager arrayData]];

	if (result != nil)
	{
		[dataManager ensureInputWithValue:NO];
		[[dataManager getInputPoint] valueInserted:result];
		[dataManager valueChanged];
	}
	else
	{
		[self updateArrayDataArray];
	}
}

//
// applyData2DFunction
//
// Calls the currently selected function and applies it to the 2D data
//
- (IBAction)applyData2DFunction:(id)sender
{
	BigCFloat *result;
	SEL		method;
	
	if ([[dataManager data2D] count] == 0)
	{
		return;
	}
	
	[data2DFunctionRows[[data2DFunctionsTableView selectedRow]][1] getValue:&method];
	
	result = [NSObject target:dataFunctions performSelector:method withObject:[dataManager data2D]];  // Fixed warning - Mike
//	result = [dataFunctions performSelector:method withObject:[dataManager data2D]];
	
	if (result != nil)
	{
		[dataManager ensureInputWithValue:NO];
		[[dataManager getInputPoint] valueInserted:result];
		[dataManager valueChanged];
	}
}

//
// applyDataFunction
//
// Calls the currently selected function and applies it to the data values
//
- (IBAction)applyDataFunction:(id)sender
{
	BigCFloat *result;
	SEL		method;
	
	if ([[dataManager data] count] == 0)
	{
		return;
	}
	
	[dataFunctionRows[[dataFunctionsTableView selectedRow]][1] getValue:&method];

	result = [NSObject target:dataFunctions performSelector:method withObject:[dataManager data]];	// Fixed warning - Mike
//	result = [dataFunctions performSelector:method withObject:[dataManager data]];
	
	if (result != nil)
	{
		[dataManager ensureInputWithValue:NO];
		[[dataManager getInputPoint] valueInserted:result];
		[dataManager valueChanged];
	}
}

//
// changeRadix
//
// Dispatches a change radix instruction to the data manager after the user clicks on a row
// in the radix table.
//
- (IBAction)changeRadix:(id)sender
{
	[dataManager setRadix:[radixDataRows[[sender clickedRow]][0] intValue] useComplement:[radixDataRows[[sender clickedRow]][2] intValue]];
}

//
// clearAllArrayDataValues
//
// Empties the array data
//
- (IBAction)clearAllArrayDataValues:(id)sender
{
	[[dataManager arrayData] removeAllObjects];
	[self updateArrayDataArray];
}

//
// clearAllData2DValues
//
// Empties the 2D data
//
- (IBAction)clearAllData2DValues:(id)sender
{
	[[dataManager data2D] removeAllObjects];
	[self updateData2DArray];
}

//
// clearAllDataValues
//
// Empties the data
//
- (IBAction)clearAllDataValues:(id)sender
{
	[[dataManager data] removeAllObjects];
	[self updateDataArray];
}

//
// clearArrayValue
//
// Clears the currently selected row in the array data
//
- (IBAction)clearArrayValue:(id)sender
{
	int i;
	
	if ([arrayDataTableView selectedRow] == -1)
	{
		return;
	}
	
	for (i = 0; i < numArrayColumns; i++)
	{
		if ([arrayDataTableView selectedRow] * numArrayColumns < [[dataManager arrayData] count])
		{
			[[dataManager arrayData] removeObjectAtIndex:[arrayDataTableView selectedRow] * numArrayColumns];
		}
	}
	[self updateArrayDataArray];
}

//
// clearData2DValue
//
// Clears the currently selected row in the 2D data
//
- (IBAction)clearData2DValue:(id)sender
{
	if ([data2DTableView selectedRow] == -1)
	{
		return;
	}
	
	[[dataManager data2D] removeObjectAtIndex:[data2DTableView selectedRow] * 2];
	if ([data2DTableView selectedRow] * 2 < [[dataManager data2D] count])
		[[dataManager data2D] removeObjectAtIndex:[data2DTableView selectedRow] * 2];
	[self updateData2DArray];
}

//
// clearDataValue
//
// Clears the currently selected row in the data
//
- (IBAction)clearDataValue:(id)sender
{
	[[dataManager data] removeObjectAtIndex:[dataTableView selectedRow]];
	[self updateDataArray];
}

//
// constantSelected
//
// Inserts the currently selected constant in the current expression
//
- (IBAction)constantSelected:(id)sender;
{
//	BigCFloat	*pasteValue;
	Expression	*inputPoint;
	NSArray     *constantsDataRows = [ExpressionSymbols getConstants];
	
	if ( [sender clickedRow] == -1 || [constantsDataRows[[sender clickedRow]] count] == 0) return;
	
	[dataManager ensureInputWithValue:NO];
	inputPoint = [dataManager getInputPoint];
	[inputPoint constantPressed:[sender clickedRow]];
	
//	pasteValue = constantsDataRows[[sender clickedRow]][1];
//	[dataManager ensureInputWithValue:NO];
//	inputPoint = [dataManager getInputPoint];
//	[inputPoint valueInserted:pasteValue];
	[dataManager valueChanged];
}

//
// copyDataValueToDisplay
//
// Inserts the value currently selected in the data table into the current expression
//
- (IBAction)copyDataValueToDisplay:(id)sender
{
	if ([dataTableView selectedRow] == -1)
		return;
	
	[dataManager ensureInputWithValue:NO];
	[[dataManager getInputPoint] valueInserted:[dataManager data][[dataTableView selectedRow]]];
	[dataManager valueChanged];
}

//
// historySelected
//
// Inserts the currently selected expression in the history into the current expression
//
- (void)historySelected:(id)sender
{
	Expression	*pasteExpression;
	Expression	*inputPoint;
	
	if ([sender clickedRow] == -1)
		return;
	
	pasteExpression = [NSKeyedUnarchiver unarchiveObjectWithData:[dataManager history][[sender clickedRow]][0]];
	[dataManager ensureInputWithValue:NO];
	inputPoint = [dataManager getInputPoint];
	[inputPoint bracketPressed];
	inputPoint = [dataManager getInputPoint];
	[inputPoint expressionInserted:pasteExpression];
	inputPoint = [dataManager getInputPoint];
	[inputPoint closeBracketPressed];
	[dataManager valueChanged];
}

//
// numberOfArrayColumns
//
// Returns the current number of columns used in the array data.
//
- (int)numberOfArrayColumns
{
	return numArrayColumns;
}

//
// numberOfRowsInTableView
//
// Tells the different tables how many rows of data there are in their respective data sets.
//
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if ([aTableView isEqualTo:arrayDataTableView])
	{
		return ([[dataManager arrayData] count] + (numArrayColumns - 1)) / numArrayColumns;
	}
	else if ([aTableView isEqualTo:arrayDataFunctionsTableView])
	{
		return [arrayDataFunctionRows count];
	}
	else if ([aTableView isEqualTo:constantsTableView])
	{
		return [[ExpressionSymbols getConstants] count]; 
	}
	else if ([aTableView isEqualTo:dataTableView])
	{
		return [[dataManager data] count];
	}
	else if ([aTableView isEqualTo:dataFunctionsTableView])
	{
		return [dataFunctionRows count];
	}
	else if ([aTableView isEqualTo:data2DTableView])
	{
		return ([[dataManager data2D] count] + 1) / 2;
	}
	else if ([aTableView isEqualTo:data2DFunctionsTableView])
	{
		return [data2DFunctionRows count];
	}
	else if ([aTableView isEqualTo:historyTableView])
	{
		return [[dataManager history] count];
	}
	else if ([aTableView isEqualTo:radixTableView])
	{
		return [radixDataRows count];
	}
	else
	{
		return 0;
	}
}

//
// setStartupState
//
// At startup, some of the tables need to be redrawn (bug?) and select the current radix and
// set the class for drawing the history table.
//
- (void)setStartupState
{
	int offset = 0;
	int cluster = 0;
	
	// dennis: selecting the right row is trickier as base 10 is not available for complement other than 0.
	// perhaps a for loop is easier. nevertheless i'll 'patch' over the existing code.
	
	switch ([dataManager getRadix])
	{
		case 2:
			offset = 0;
			break;
		case 8:
			offset = 1;
			break;
		case 10:
			offset = 2;
			break;
		case 16:
			offset = 3;
			break;
	}
	switch ([dataManager getComplement])
	{
		case 0:
			cluster = 0;
			break;
		case 8:
			cluster = 1;
			break;
		case 16:
			cluster = 2;
			break;
		case 32:
			cluster = 3;
			break;
		case 64:
			cluster = 4;
			break;
	}
	
	// dennis: disabled // [radixTableView selectRow:cluster * 4 + offset byExtendingSelection:NO];
	
	// dennis: start -----------------------
	
	// For complement > 0, we now have 3 radices and the offset is different too.
		
	if ([dataManager getComplement] > 0)
	{
		switch ([dataManager getRadix])
		{
			case 2:
				offset = 1;
				break;
			case 8:
				offset = 2;
				break;
			case 16:
				offset = 3;
				break;
		}
	}
	[radixTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:cluster * 3 + offset] byExtendingSelection:NO];   // Mike: fixed deprecation
//	[radixTableView selectRow:cluster * 3 + offset byExtendingSelection:NO]; // dennis
	[dataManager setRadix:[dataManager getRadix] useComplement:[dataManager getComplement]]; // dennis: ensures the format is displayed properly

	
	// dennis: end -----------------------

	
	[[historyTableView tableColumns][0] setDataCell:historyCell];
	
	[data2DFunctionsTableView reloadData];
	[arrayDataFunctionsTableView reloadData];
	[self updateHistory];
	
	[[arrayDataDrawer contentView] setNextResponder:[dataManager window]];
	[[data2DDrawer contentView] setNextResponder:[dataManager window]];
	[[dataDrawer contentView] setNextResponder:[dataManager window]];
	[[historyDrawer contentView] setNextResponder:[dataManager window]];
	[[radixDrawer contentView] setNextResponder:[dataManager window]];
	[[constantsDrawer contentView] setNextResponder:[dataManager window]];
}

//
// tableView
//
// Tells the table views what object is at each table location so that it can draw itself.
//
- (id)tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn row:(int)rowIndex
{
	if ([aTableView isEqualTo:arrayDataTableView])
	{
		int count = [[dataManager arrayData] count];
		int column = [[aTableColumn identifier] intValue];
		BigCFloat *object;
		
		if (rowIndex * numArrayColumns + [[aTableColumn identifier] intValue] >= count)
			return @"";
		
		object = [dataManager arrayData][rowIndex * numArrayColumns + column];
		
		return [object toShortString:3];
	}
	else if ([aTableView isEqualTo:arrayDataFunctionsTableView])
	{
		return arrayDataFunctionRows[rowIndex][0];
	}
	else if ([aTableView isEqualTo:constantsTableView])
	{
		NSArray *constantsDataRows = [ExpressionSymbols getConstants];
		if ([constantsDataRows[rowIndex] count] != 0) {
			NSString *combined = [NSString stringWithFormat:@"%@%@", constantsDataRows[rowIndex][0], constantsDataRows[rowIndex][1]];
			NSAttributedString *str = [ExpressionSymbols toFormattedString:combined];
			return str;
		}
		return @"";
	}
	else if ([aTableView isEqualTo:dataTableView])
	{
		return [[dataManager data][rowIndex] toShortString:7];
	}
	else if ([aTableView isEqualTo:dataFunctionsTableView])
	{
		return dataFunctionRows[rowIndex][0];
	}
	else if ([aTableView isEqualTo:data2DTableView])
	{
		if (rowIndex * 2 + [[aTableColumn identifier] intValue] >= [[dataManager data2D] count]) return @"";
		
		return [[dataManager data2D][rowIndex * 2 + [[aTableColumn identifier] intValue]] toShortString:3];
	}
	else if ([aTableView isEqualTo:data2DFunctionsTableView])
	{
		return data2DFunctionRows[rowIndex][0];
	}
	else if ([aTableView isEqualTo:historyTableView])
	{
		return [dataManager history][rowIndex];
	}
	else if ([aTableView isEqualTo:radixTableView])
	{
		return radixDataRows[rowIndex][[[aTableColumn identifier] intValue]];
	}
	else
	{
		return 0;
	}
}

//
// toggleDrawer
//
// When the user presses a drawer button, we need to retract any open drawers and open
// the selected one (or toggle the selected one if it is already open).
//
- (IBAction)toggleDrawer:(id)sender
{
	BOOL	close = NO;
	
	if (activeDrawer != nil)
	{
		[activeDrawer close];
	}
	
	switch([sender tag])
	{
	case 0:
		if (activeDrawer != nil && [activeDrawer isEqualTo:historyDrawer])
			close = YES;
		else
			activeDrawer = historyDrawer;
		break;
	case 1:
		if (activeDrawer != nil && [activeDrawer isEqualTo:radixDrawer])
			close = YES;
		else
			activeDrawer = radixDrawer;
		break;
	case 2:
		if (activeDrawer != nil && [activeDrawer isEqualTo:dataDrawer])
			close = YES;
		else
			activeDrawer = dataDrawer;
		break;
	case 3:
		if (activeDrawer != nil && [activeDrawer isEqualTo:data2DDrawer])
			close = YES;
		else
			activeDrawer = data2DDrawer;
		break;
	case 4:
		if (activeDrawer != nil && [activeDrawer isEqualTo:arrayDataDrawer])
			close = YES;
		else
			activeDrawer = arrayDataDrawer;
		break;
	case 5:
		if (activeDrawer != nil && [activeDrawer isEqualTo:constantsDrawer])
			close = YES;
		else
			activeDrawer = constantsDrawer;
		break;
	}
	
	if (close)
	{
		if ([activeDrawer state] != NSDrawerClosingState)
			[activeDrawer openOnEdge:NSMinXEdge];
		else
			activeDrawer = nil;
	}
	else
	{
		[activeDrawer setMinContentSize:NSMakeSize(260, 200)];
		[activeDrawer openOnEdge:NSMinXEdge];
	}
}

//
// updateArrayDataArray
//
// Refresh and rescroll the array data table.
//
- (void)updateArrayDataArray
{
	[arrayDataTableView reloadData];
	
	if
	(
		[arrayDataTableView selectedColumn] == -1
		||
		[arrayDataTableView selectedRow] == -1
	)
	{
		[arrayDataTableView scrollRowToVisible:([[dataManager arrayData] count] - 1) / numArrayColumns];
	}
	else
	{
		[arrayDataTableView scrollRowToVisible:[arrayDataTableView selectedRow]];
		[arrayDataTableView scrollColumnToVisible:[arrayDataTableView selectedColumn]];
	}
}

//
// updateData2DArray
//
// Refresh and rescroll the 2D data table.
//
- (void)updateData2DArray
{
	[data2DTableView reloadData];
	
	if
	(
		[data2DTableView selectedColumn] == -1
		||
		[data2DTableView selectedRow] == -1
	)
	{
		[data2DTableView scrollRowToVisible:([[dataManager data2D] count] - 1) / 2];
	}
	else
	{
		[data2DTableView scrollRowToVisible:[data2DTableView selectedRow]];
		[data2DTableView scrollColumnToVisible:[data2DTableView selectedColumn]];
	}
}

//
// updateDataArray
//
// Refresh and rescroll the data table.
//
- (void)updateDataArray
{
	[dataTableView reloadData];
	
	if ([dataTableView selectedRow] == -1)
	{
		[dataTableView scrollRowToVisible:[[dataManager data] count]];
	}
	else
	{
		[dataTableView scrollRowToVisible:[dataTableView selectedRow]];
	}
}

//
// updateHistory
//
// Refresh and rescroll the history table.
//
- (void)updateHistory
{
	[historyTableView reloadData];
	[historyTableView scrollRowToVisible:[[dataManager history] count] - 1];
}

@end
