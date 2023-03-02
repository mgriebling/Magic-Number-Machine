// ##############################################################
//  MainWindow.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "MainWindow.h"
#import "DataManager.h"

//
// About the MainWindow
//
// Only exists to catch shift and option keys, otherwise we use standard window
// behaviour.
//
@implementation MainWindow

- (void)awakeFromNib {
	[super awakeFromNib];
	
	// just need to make the title bar transparent and the window vibrate - Mike
	self.titlebarAppearsTransparent = YES;
	self.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
//	self.window.styleMask = self.window.styleMask | NSFullSizeContentViewWindowMask;
//	self.window.titleVisibility = NSWindowTitleHiddenWhenActive;
//	self.window.titlebarAppearsTransparent = YES;
	self.movableByWindowBackground = YES;
}

//
// flagsChanged
//
// Tells the data manager when the state of the shift or option keys changes.
//
- (void)flagsChanged:(NSEvent*)theEvent
{
	NSEventModifierFlags newFlags = [theEvent modifierFlags];
	
//	[dataManager optionIsPressed:(newFlags & NSAlternateKeyMask) != 0];
    if ((newFlags & NSEventModifierFlagShift) != 0) {
		[dataManager shiftIsPressed];
	}

	[super flagsChanged:theEvent];
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
	NSEvent *alteredEvent;
    NSEventModifierFlags modifiers = [theEvent modifierFlags];
	NSString *chars = [theEvent characters];
	NSString *charsWithout = [[theEvent charactersIgnoringModifiers] lowercaseString];
	BOOL needNewEvent = NO;
	
    if ([theEvent type] == NSEventTypeKeyUp)
	{
		return false;
	}
	
	// Handle the window close shortcut (which is not associated with any UI
	// element).
    if ((modifiers & NSEventModifierFlagCommand) &&
        !(modifiers & (NSEventModifierFlagShift | NSEventModifierFlagOption | NSEventModifierFlagControl)) &&
		[charsWithout isEqualTo:@"w"])
	{
		[self performClose:self];
		return YES;
	}
	
	// Handle the shortcut for the AC button ("clear" key) manually. This is
	// because "clear" and "ESC" are treated as synonyms by the standard
	// performKeyEquivalent processing and we wish to differentiate.
	if ([charsWithout isEqualTo:@""])
	{
		const int acButtonTag = 1234;
		
		[[[self contentView] viewWithTag:acButtonTag] performClick:self];
		return YES;
	}
	
	// Strip the shift key and alternate key so that Shft and Opt buttons
	// work in conjunction with other buttons.
    if (modifiers & (NSEventModifierFlagShift | NSEventModifierFlagOption))
	{
        modifiers &= ~(NSEventModifierFlagShift | NSEventModifierFlagOption);
		needNewEvent = YES;
	}
	
	// Convert the locale radix point to a period
	if ([charsWithout isEqualTo:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]])
	{
		chars = @".";
		charsWithout = chars;
		needNewEvent = YES;
	}
	
	// Convert equals and return to be a synonym of "return"
	else if ([charsWithout isEqualTo:@"="])
	{
		chars = @"\r";
		charsWithout = chars;
		needNewEvent = YES;
	}
	
	// Let "PageUp" key make the window floatin
    else if ([theEvent keyCode] == 116 && [theEvent type] == NSEventTypeKeyDown)
	{
		[self setLevel:NSFloatingWindowLevel];
		needNewEvent = YES;
	}

	// Let "PageDown" key make the window normal again
    else if ([theEvent keyCode] == 121 && [theEvent type] ==  NSEventTypeKeyDown)
	{
		[self setLevel:NSNormalWindowLevel];
		needNewEvent = YES;
	}
	
	if (needNewEvent)
	{
		// Dispatch the event with shift and option stripped out
		alteredEvent = [NSEvent
			keyEventWithType:[theEvent type]
			location:[theEvent locationInWindow]
			modifierFlags:modifiers
			timestamp:[theEvent timestamp]
			windowNumber:[theEvent windowNumber]
			context:nil
			characters:chars
			charactersIgnoringModifiers:charsWithout
			isARepeat:[theEvent isARepeat]
			keyCode:[theEvent keyCode]
		];
	}
	else
	{
		alteredEvent = theEvent;
	}
	
	return [super performKeyEquivalent:alteredEvent];
}

@end
