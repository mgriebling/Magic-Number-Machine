// ##############################################################
//  InputManager.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Cocoa/Cocoa.h>

@class DataManager;
// @class SYFlatButton;

//
// About the InputManager
//
// The InputManager coordinates input from most of the buttons in the window.
// Not much more than that. It uses the DataManager for everything else. It does
// talk directly to the current input point, but only after requesting it from the
// DataManager.
//
// Naturally, since there is only one window in the application, there is only one
// instance of this class in the application.
//
// Incidentally, this class inherits from NSView so that it can be in the responder
// chain. Curiously the first responder must be a view, not just a responder.
//

@interface InputManager : NSView
{
	IBOutlet DataManager	*dataManager;
	
	__weak IBOutlet NSWindow 	*dispSettings;
	__weak IBOutlet NSWindow 	*sciSettings;
	__weak IBOutlet NSWindow 	*fixSettings;
	__weak IBOutlet id 		mainWindow;
	__weak IBOutlet id 		fixValue;
	__weak IBOutlet id 		sciValue;
	__weak IBOutlet id 		dispValue;
	__weak IBOutlet id 		defaultDigits;
	__weak IBOutlet id 		defaultDisplay;
	__weak IBOutlet id 		defaultSignificant;
	__weak IBOutlet id 		defaultFixed;
	__weak IBOutlet id 		thousandsSeparator;
	__weak IBOutlet id 		preferencesPanel;
    __weak IBOutlet NSButton *fractionSeparator;
    
	// All the little buttons that get disabled
	__weak IBOutlet NSButton *twoButton;
	__weak IBOutlet NSButton *threeButton;
	__weak IBOutlet NSButton *fourButton;
	__weak IBOutlet NSButton *fiveButton;
	__weak IBOutlet NSButton *sixButton;
	__weak IBOutlet NSButton *sevenButton;
	__weak IBOutlet NSButton *eightButton;
	__weak IBOutlet NSButton *nineButton;
	__weak IBOutlet NSButton *aButton;
	__weak IBOutlet NSButton *bButton;
	__weak IBOutlet NSButton *cButton;
	__weak IBOutlet NSButton *dButton;
	__weak IBOutlet NSButton *eButton;
	__weak IBOutlet NSButton *fButton;
}
- (IBAction)allClearPressed:(id)sender;
- (IBAction)binaryOpPressed:(id)sender;
- (IBAction)bracketPressed:(id)sender;
- (IBAction)cancelPreferences:(id)sender;
- (IBAction)clearPressed:(id)sender;
- (IBAction)commitPreferences:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)copyResult:(id)sender;
- (IBAction)delPressed:(id)sender;
- (IBAction)digitPressed:(id)sender;
- (IBAction)equalsPressed:(id)sender;
- (IBAction)expPressed:(id)sender;
- (IBAction)exponentShiftPressed:(id)sender;
- (IBAction)optionPressed:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)postOpPressed:(id)sender;
- (IBAction)precisionCancel:(id)sender;
- (IBAction)precisionOk:(id)sender;
- (IBAction)precisionPressed:(id)sender;
- (IBAction)preferences:(id)sender;
- (IBAction)preOpPressed:(id)sender;
- (void)setDefaultsForThousands:(BOOL)thousands fractions:(BOOL)fractions digits:(int)digits significant:(int)significant fixed:(int)fixed display:(int)display;
- (IBAction)shiftPressed:(id)sender;
- (IBAction)trigModePressed:(id)sender;
- (IBAction)userPointPressed:(id)sender;
- (IBAction)valuePressed:(id)sender;
- (void)showKeyboardShortcuts:(id)sender;

- (IBAction)showHelp:(id)sender;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL acceptsFirstResponder;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)setControlsForRadix:(short)radix;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) id window;
@end
