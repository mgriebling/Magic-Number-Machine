// ##############################################################
//  CallBack.m
//  Magic Number Machine
//
//  Created by Matt Gallagher on Wed Apr 23 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import "CallBack.h"
#import "NSObject+NSPerformSelector.h"

//
// About CallBack
//
// A small class which creates an object that sends the specified message when it
// is deleted. Useful to have an action called at Autorelease pool time.
//
@implementation CallBack

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

//
// initWithObject
//
// Constructor
//
- (instancetype)initWithObject:(id)object method:(CallBackType)method
{
	self = [super init];
	if (self)
	{
		callBackObject = object;
		callBackMethod = method;
	}
	return self;
}

//
// dealloc
//
// The destructor is what calls the message
//
- (void)dealloc
{
//	[NSObject target:callBackObject performSelector:callBackMethod];
	if (callBackMethod) {
		callBackMethod(nil);
	}
//	[callBackObject performSelector:callBackMethod];
}

//
// callBack
//
// Static method to create the object and autorelease it.
//
+ (instancetype)callBack:(id)object method:(CallBackType)method
{
	return [[CallBack alloc] initWithObject:object method:method]; 
}

@end
