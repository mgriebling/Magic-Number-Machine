// ##############################################################
//  InputManager.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Cocoa/Cocoa.h>

@class DataManager;

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
	
	IBOutlet NSWindow 	*dispSettings;
	IBOutlet NSWindow 	*sciSettings;
	IBOutlet NSWindow 	*fixSettings;
	IBOutlet id 		mainWindow;
	IBOutlet id 		fixValue;
	IBOutlet id 		sciValue;
	IBOutlet id 		dispValue;
	IBOutlet id 		defaultDigits;
	IBOutlet id 		defaultDisplay;
	IBOutlet id 		defaultSignificant;
	IBOutlet id 		defaultFixed;
	IBOutlet id 		thousandsSeparator;
	IBOutlet id 		preferencesPanel;
	
	// All the little buttons that get disabled
	IBOutlet id	twoButton;
	IBOutlet id	threeButton;
	IBOutlet id	fourButton;
	IBOutlet id	fiveButton;
	IBOutlet id	sixButton;
	IBOutlet id	sevenButton;
	IBOutlet id	eightButton;
	IBOutlet id	nineButton;
	IBOutlet id	aButton;
	IBOutlet id	bButton;
	IBOutlet id	cButton;
	IBOutlet id	dButton;
	IBOutlet id	eButton;
	IBOutlet id	fButton;
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
- (void)setDefaultsForThousands:(BOOL)thousands digits:(int)digits significant:(int)significant fixed:(int)fixed display:(int)display;
- (IBAction)shiftPressed:(id)sender;
- (IBAction)trigModePressed:(id)sender;
- (IBAction)userPointPressed:(id)sender;
- (IBAction)valuePressed:(id)sender;
- (void)showKeyboardShortcuts:(id)sender;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL acceptsFirstResponder;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)setControlsForRadix:(short)radix;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) id window;
@end
