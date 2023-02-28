// ##############################################################
//  MainWindow.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun Apr 20 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Cocoa/Cocoa.h>

@class DataManager;

//
// About the MainWindow
//
// Only exists to catch shift and option keys, otherwise we use standard window
// behaviour.
//
@interface MainWindow : NSWindow
{
	IBOutlet DataManager *dataManager;
}
- (void)flagsChanged:(NSEvent*)theEvent;

@end
