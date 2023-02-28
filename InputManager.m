// ##############################################################
//  InputManager.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "InputManager.h"
#import "Expression.h"
#import "CallBack.h"
#import "DataManager.h"
#import "OpEnumerations.h"
#import "BigCFloat.h"
#import "Value.h"

//
// About the InputManager
//
// The InputManager coordinates input from most of the buttons in the window.
// Not much more than that. It uses the DataManager for everything else. It does
// talk directly to the current input point, but only after requesting it from the
// DataManager.
//
// Naturally, since there is only one window in the application, there is only one
// instance of this class inthe application.
//

@implementation InputManager

//
// allClearPressed
//
// Tells the DataManager to clear the expression when the AC button is pressed.
//
- (IBAction)allClearPressed:(id)sender
{
	[dataManager clearExpression];
}

//
// binaryOpPressed
//
// Inserts the appropriate operation into the expression.
//
- (IBAction)binaryOpPressed:(id)sender
{
	Expression	*inputPoint;
	int			buttonTag = (int)[sender tag];
	
	[dataManager ensureInputWithValue:YES];
	inputPoint = [dataManager getInputPoint];
	
	[inputPoint binaryOpPressed:buttonTag];
	[dataManager valueChanged];
}

//
// bracketPressed
//
// Inserts the appropriate bracket into the expression.
//
- (IBAction)bracketPressed:(id)sender
{
	Expression		*inputPoint;
	
	[dataManager ensureInputWithValue:YES];
	inputPoint = [dataManager getInputPoint];
	
	if ([sender tag] == 0)
		[inputPoint bracketPressed];
	else
		[inputPoint closeBracketPressed];
	[dataManager valueChanged];
}

//
// cancelPreferences
//
// User dismissed the preferences dialog.
//
- (IBAction)cancelPreferences:(id)sender
{
	[NSApp stopModal];
}

//
// clearPressed
//
// Clears the current value.
//
- (IBAction)clearPressed:(id)sender
{
	Expression		*inputPoint;
	
	[dataManager ensureInputWithValue:NO];
	inputPoint = [dataManager getInputPoint];
	
	[inputPoint clear];
	[dataManager valueChanged];
}

//
// commitPreferences
//
// User saved the preferences dialog.
//
- (IBAction)commitPreferences:(id)sender
{	
	// dennis ---------------------------------
	
	BOOL errorFlag = NO;
	
	if ([defaultFixed intValue] > 10)
	{
		[defaultFixed setIntValue:10];
		errorFlag = YES;
	}
	if ([defaultFixed intValue] < 0)
	{
		[defaultFixed setIntValue:0];
		errorFlag = YES;
	}
	
	if ([defaultSignificant intValue] > [dataManager getMaximumLength])
	{
		[defaultSignificant setIntValue:[dataManager getMaximumLength]];
		errorFlag = YES;
	}
	if ([defaultSignificant intValue] < 1)
	{
		[defaultSignificant setIntValue:1];
		errorFlag = YES;
	}
	
	if ([defaultDigits intValue] > [dataManager getMaximumLength])
	{
		[defaultDigits setIntValue:[dataManager getMaximumLength]];
		errorFlag = YES;
	}
	if ([defaultDigits intValue] < 3)
	{
		[defaultDigits setIntValue:3];
		errorFlag = YES;
	}
	
	if (errorFlag)
	{
		NSBeep();
		return;
	}
	
	[dataManager saveDefaultsForThousands:[thousandsSeparator intValue] != 0 
								   digits:[defaultDigits intValue] 
							  significant:[defaultSignificant intValue] 
									fixed:[defaultFixed intValue] 
								  display:(int)[[defaultDisplay selectedCell] tag]];
	
	[dataManager updateLengthLimit];
	[NSApp stopModal];
}

//
// copy
//
// Copies the current expression onto the clipboard.
//
- (IBAction)copy:(id)sender
{
	NSPasteboard	*pasteBoard;
	Expression		*expression;
	NSData			*data;
	NSString		*stringValue;

	expression = [[dataManager getCurrentExpression] child];
	data = [NSKeyedArchiver archivedDataWithRootObject:expression];
	
	pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard declareTypes:@[@"MNMExpression", @"NSStringPboardType"] owner:self];
	[pasteBoard setData:data forType:@"MNMExpression"];

	stringValue = [expression getExpressionString];
	
	if ([dataManager getEqualsPressed]) {
		Value *result = [[Value alloc] initWithParent:nil value:[expression getValue] andManager:dataManager];
		stringValue = [[stringValue stringByAppendingString:@" = "] stringByAppendingString:[result getExpressionString]];
	}
	
	[pasteBoard setString:stringValue forType:@"NSStringPboardType"];
}

//
// copyResult
//
// Copies the result onto the clipboard.
//
- (IBAction)copyResult:(id)sender
{
	NSPasteboard	*pasteBoard;
	BigCFloat		*value;
	NSData			*data;
	NSString		*stringValue;
	Value			*result;

	value = [[dataManager getCurrentExpression] getValue];
	data = [NSKeyedArchiver archivedDataWithRootObject:value];
	
	pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard declareTypes:@[@"BigCFloat", @"NSStringPboardType"] owner:self];
	[pasteBoard setData:data forType:@"BigCFloat"];
	
	result = [[Value alloc] initWithParent:nil value:value andManager:dataManager];
	stringValue = [result getExpressionString];
	[pasteBoard setString:stringValue forType:@"NSStringPboardType"];
}

//
// delPressed
//
// Deletes the digit or operation at the current insertion point.
//
- (IBAction)delPressed:(id)sender
{
	Expression		*inputPoint;
	
	[dataManager ensureInputWithValue:NO];
	inputPoint = [dataManager getInputPoint];
	
	[inputPoint deleteDigit];
	[dataManager valueChanged];
}

//
// digitPressed
//
// Inserts another digit into the current number.
//
- (IBAction)digitPressed:(id)sender
{
	Expression		*inputPoint;
	
	[dataManager ensureInputWithValue:NO];
	inputPoint = [dataManager getInputPoint];
	
	[inputPoint appendDigit:(int)[sender tag]];
	[dataManager valueChanged];
}

//
// equalsPressed
//
// Tells the DataManager to show the result.
//
- (IBAction)equalsPressed:(id)sender
{
	[dataManager equalsPressed];
}

//
// exponentShiftPressed
//
// Shifts the result left or right accordingly.
//
- (IBAction)exponentShiftPressed:(NSButton *)sender
{
	Expression *inputPoint;
	
	if (dataManager.shift) {
		[dataManager ensureInputWithValue:YES];
		inputPoint = [dataManager getInputPoint];
		if (sender.tag < 0) {
			[inputPoint binaryOpPressed:xorOp];
		} else {
			[inputPoint preOpPressed:notOp];
		}
		[dataManager valueChanged];		
	} else {
		[dataManager shiftResult:sender.tag < 0];
	}
}

//
// expPressed
//
// Adds a scientific notation style exponent to the current number.
//
- (IBAction)expPressed:(id)sender
{
	Expression		*inputPoint;
	
	[dataManager ensureInputWithValue:NO];
	inputPoint = [dataManager getInputPoint];
	
	[inputPoint exponentPressed];
	[dataManager valueChanged];
}

//
// optionPressed
//
// Toggles the option state.
//
- (IBAction)optionPressed:(id)sender
{
	// We use this wierd CallBack class because the button is already highlighted
	// when this method is called and will be unhighlighted shortly after. By
	// using the CallBack, optionToggled will get called after the unhighlight has
	// occurred, so that we can set the button highlight without it getting mucked
	// up as the stack unwinds.
//	[CallBack callBack:dataManager method:^id(id param) {
//		[dataManager optionToggled];
//		return nil;
//	}];
//	[CallBack callBack:dataManager method:@selector(optionToggled)];
}

//
// paste
//
// Inserts the number or expression from the clipboard into the current expression.
//
- (IBAction)paste:(id)sender
{
	NSPasteboard	*pasteBoard;
	NSArray			*pasteBoardTypes;
	NSData			*pasteData;
	Expression		*inputPoint;
	
	pasteBoard = [NSPasteboard generalPasteboard];
	pasteBoardTypes = [pasteBoard types];
	if ([pasteBoardTypes containsObject:@"MNMExpression"])
	{
		pasteData = [pasteBoard dataForType:@"MNMExpression"];
		if(pasteData != nil)
		{
			Expression	*pasteExpression;
			
			pasteExpression = [NSKeyedUnarchiver unarchiveObjectWithData:pasteData];
			[dataManager ensureInputWithValue:NO];
			inputPoint = [dataManager getInputPoint];
//			[inputPoint bracketPressed];						// Mike: why do we need brackets?
//			inputPoint = [dataManager getInputPoint];
			[inputPoint expressionInserted:pasteExpression];
//			[inputPoint closeBracketPressed];
			[dataManager valueChanged];
		}
	}
	else if([pasteBoardTypes containsObject:@"BigCFloat"])
	{
		pasteData = [pasteBoard dataForType:@"BigCFloat"];
		if(pasteData != nil)
		{
			BigCFloat		*pasteValue;
			
			pasteValue = [NSKeyedUnarchiver unarchiveObjectWithData:pasteData];
			[dataManager ensureInputWithValue:NO];
			inputPoint = [dataManager getInputPoint];
			[inputPoint valueInserted:pasteValue];
			[dataManager valueChanged];
		}
	}
	else if([pasteBoardTypes containsObject:@"NSStringPboardType"])
	{
		NSString		*pasteString;

		pasteString = [pasteBoard stringForType:@"NSStringPboardType"];

		if(pasteString != nil && ![pasteString isEqualToString:@""])
		{
			double	value = [pasteString doubleValue];
			
			if (value != 0.0 || [pasteString isEqualToString:@"0"] || [pasteString isEqualToString:@"0.0"])
			{
				BigCFloat *bcf_value = [BigCFloat bigFloatWithDouble:value radix:[dataManager getRadix]];
				
				[dataManager ensureInputWithValue:NO];
				inputPoint = [dataManager getInputPoint];
				[inputPoint valueInserted:bcf_value];
				[dataManager valueChanged];
			}
		}
	}
}

//
// postOpPressed
//
// Inserts the relevant operation into the current expression.
//
- (IBAction)postOpPressed:(id)sender
{
	Expression		*inputPoint;
	int					buttonTag = (int)[sender tag];
	
	[dataManager ensureInputWithValue:YES];
	inputPoint = [dataManager getInputPoint];
	
	if (buttonTag == factorialOp && [dataManager getShift])
	{
		[self preOpPressed:sender];
		return;
	}
	
	[inputPoint postOpPressed:buttonTag];
	[dataManager valueChanged];
}

//
// precisionCancel
//
// Dismiss any sheets over the window because the cancel button is pressed.
//
- (IBAction)precisionCancel:(id)sender
{
    [mainWindow endSheet:[sender window] returnCode:NSModalResponseCancel];
}

//
// precisionOk
//
// Change the precision (if  the number is valid) and dismiss the sheet.
//
- (IBAction)precisionOk:(id)sender
{
	if ([[sender window] isEqual:fixSettings])
	{
		if ([fixValue intValue] > 10)
		{
			[fixValue setIntValue:10];
			NSBeep();
			return;
		}
		if ([fixValue intValue] < 0)
		{
			[fixValue setIntValue:0];
			NSBeep();
			return;
		}
		[dataManager setDefaultDisplayType:2]; // dennis
		[dataManager setDefaultFixed:[fixValue intValue]]; // dennis
		// [dataManager lengthLimit:20 fillLimit:YES fixedPlaces:[fixValue intValue]];
	}
	else if ([[sender window] isEqual:sciSettings])
	{
		if ([sciValue intValue] > [dataManager getMaximumLength])
		{
			[sciValue setIntValue:[dataManager getMaximumLength]];
			NSBeep();
			return;
		}
		if ([sciValue intValue] < 1)
		{
			[sciValue setIntValue:1];
			NSBeep();
			return;
		}
		[dataManager setDefaultDisplayType:1]; // dennis
		[dataManager setDefaultSignificant:[sciValue intValue]]; // dennis
		// [dataManager lengthLimit:[sciValue intValue] fillLimit:YES fixedPlaces:0];
	}
	else
	{
		if ([dispValue intValue] > [dataManager getMaximumLength])
		{
			[dispValue setIntValue:[dataManager getMaximumLength]];
			NSBeep();
			return;
		}
		if ([dispValue intValue] < 3)
		{
			[dispValue setIntValue:3];
			NSBeep();
			return;
		}
		[dataManager setDefaultDisplayType:0]; // dennis
		[dataManager setDefaultDigits:[dispValue intValue]]; // dennis
		// [dataManager lengthLimit:[dispValue intValue] fillLimit:NO fixedPlaces:0];
	}
	
	[dataManager updateLengthLimit];	// dennis
	
    [mainWindow endSheet:[sender window] returnCode:NSModalResponseCancel];
}

//
// precisionPressed
//
// Display a sheet over the window so that the user can change the precision.
//
- (IBAction)precisionPressed:(id)sender
{
	BOOL		shift = [dataManager getShift];
	BOOL 		option = [dataManager getOption];
	NSWindow	*sheet;
    NSWindow    *targetWindow = [self window];
	
	if (option)
	{
		sheet = fixSettings;
		[fixValue setIntValue: [dataManager getDefaultFixedFromPref]]; // dennis
	}
	else if (shift)
	{
		sheet = sciSettings;
		[sciValue setIntValue: [dataManager getDefaultSignificantFromPref]]; // dennis
	}
	else
	{
		sheet = dispSettings;
		[dispValue setIntValue: [dataManager getDefaultDigitsFromPref]]; // dennis
	}

    [targetWindow beginSheet:sheet completionHandler:nil];
//	[NSApp beginSheet:sheet modalForWindow:mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
//	[NSApp runModalForWindow:sheet];
//	[NSApp endSheet:sheet];
//	[sheet orderOut:self];
	
	// The modal sheet can mess with our shift/option key detection. Clear them here.
//	[dataManager shiftIsPressed:NO];
}

//
// preferences
//
// Brings up the preferences panel and alters settings accordingly.
//
- (IBAction)preferences:(id)sender
{
	// dennis:
	[self setDefaultsForThousands: [dataManager getDefaultThousandsSeparatorFromPref] 
						   digits: [dataManager getDefaultDigitsFromPref] 
					  significant: [dataManager getDefaultSignificantFromPref] 
							fixed: [dataManager getDefaultFixedFromPref] 
						  display: [dataManager getDefaultDisplayTypeFromPref] ];
	
	[NSApp runModalForWindow:preferencesPanel];
	[preferencesPanel orderOut:self];
}

//
// preOpPressed
//
// Insert the relevant operation into the current expression.
//
- (IBAction)preOpPressed:(id)sender
{
	Expression	*inputPoint;
	int			buttonTag = (int)[sender tag];
	
	[dataManager ensureInputWithValue:YES];
	inputPoint = [dataManager getInputPoint];
	
	switch (buttonTag)
	{
		case sinOp:
		case cosOp:
		case tanOp:
		case sinhOp:
		case coshOp:
		case tanhOp:
			if ([dataManager getShift]) buttonTag += 3;
			break;
		case modOp:
			if ([dataManager getShift]) buttonTag = argOp;
			break;
		case tenOp:
			if ([dataManager getShift]) buttonTag = twoOp;
			break;
		case logOp:
			if ([dataManager getShift]) buttonTag = log2Op;
			break;
		case factorialOp:
			NSAssert([dataManager getShift], @"Button input misdirected.");
			buttonTag = sigmaOp;
		default:
			break;
	}
	
	[inputPoint preOpPressed:buttonTag];
	[dataManager valueChanged];
}

//
// setDefaultsForThousands
//
// Default states for panels.
//
- (void)setDefaultsForThousands:(BOOL)thousands digits:(int)digits significant:(int)significant fixed:(int)fixed display:(int)display
{
	[thousandsSeparator setIntValue:thousands ? 1 : 0];
	[defaultDigits setIntValue:digits];
	[defaultSignificant setIntValue:significant];
	[defaultFixed setIntValue:fixed];
	[defaultDisplay selectCellAtRow:display column:0];
}

//
// shiftPressed
//
// Toggles the shift button.
//
- (IBAction)shiftPressed:(id)sender
{
	[dataManager shiftIsPressed];	// toggle the shift flag

}

//
// trigModePressed
//
// Tells the DataManager to cycle the trigonometric mode.
//
- (IBAction)trigModePressed:(NSButton *)sender
{
	[dataManager trigModePressedWithButton:sender];
}

//
// userPointPressed
//
// Inserts a fractional point into the number in the current expression.
//
- (IBAction)userPointPressed:(id)sender
{
	Expression		*inputPoint;
	
	[dataManager ensureInputWithValue:YES];
	inputPoint = [dataManager getInputPoint];
	
	[inputPoint userPointPressed];
	[dataManager valueChanged];
}

//
// valuePressed
//
// Inserts pi or i into the current expression.
//
- (IBAction)valuePressed:(id)sender
{
	Expression		*inputPoint;
	
	[dataManager ensureInputWithValue:NO];
	inputPoint = [dataManager getInputPoint];
	
	if ([sender tag] == 0) {
		// "π" Pressed
		[inputPoint constantPressed:Pi];
	} else {
		// "i" Pressed
		[inputPoint constantPressed:RootOfMinusOne];

	}
	[dataManager valueChanged];
}

//
// acceptsFirstResponder
//
// We want to get the focus (this is for copy and paste and stuff).
//
- (BOOL)acceptsFirstResponder
{
	return YES;
}

//
// applicationDidFinishLaunching
//
// Handles this for the main window. Tells the DataManager to dispatch the
// result to everything else.
//
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[dataManager setStartupState];
}
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
}
- (void)applicationDidUnhide:(NSNotification *)aNotification
{
	[mainWindow makeKeyAndOrderFront:self];
}

//
// setControlsForRadix
//
// Enable only the digits that are valid for the current radix.
//
// Simplified and cleaned up to work for any radix 2 - 16
- (void)setControlsForRadix:(short)radix
{
	[twoButton	 setEnabled:radix > 2];
	[threeButton setEnabled:radix > 3];
	[fourButton  setEnabled:radix > 4];
	[fiveButton  setEnabled:radix > 5];
	[sixButton   setEnabled:radix > 6];
	[sevenButton setEnabled:radix > 7];
	[eightButton setEnabled:radix > 8];
	[nineButton  setEnabled:radix > 9];
	[aButton	 setEnabled:radix > 10];
	[bButton	 setEnabled:radix > 11];
	[cButton	 setEnabled:radix > 12];
	[dButton	 setEnabled:radix > 13];
	[eButton	 setEnabled:radix > 14];
	[fButton	 setEnabled:radix > 15];
}

//
// window
//
// Returns a pointer to the current window.
//
- (id)window
{
	return [dataManager window];
}

//
// showKeyboardShortcuts:
//
// Invoked from the help menu.
//
- (void)showKeyboardShortcuts:(id)sender
{
	NSString *path =
		[[NSBundle mainBundle]
			pathForResource:@"Magic_Number_Machine_Buttons"
			ofType:@"html"];
	[[NSWorkspace sharedWorkspace] openFile:path];
}

@end
