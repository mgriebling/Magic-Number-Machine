// ##############################################################
//  CallBack.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Wed Apr 23 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Foundation/Foundation.h>

//
// About CallBack
//
// A small class which creates an object that sends the specified message when it
// is deleted. Useful to have an action called at Autorelease pool time.
//
// Modified by Mike Griebling to use blocks -- was crashing otherwise
//

typedef id (^CallBackType)(id param);

@interface CallBack : NSObject {
	id	callBackObject;
	CallBackType callBackMethod;
}

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithObject:(id)object method:(CallBackType)method NS_DESIGNATED_INITIALIZER;
- (void)dealloc;
+ (instancetype)callBack:(id)object method:(CallBackType)method;

@end
