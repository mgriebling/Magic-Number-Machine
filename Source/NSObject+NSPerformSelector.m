//
//  NSObject+NSPerformSelector.m
//  Magic Number Machine
//
//  Created by Mike Griebling on 24 May 2015.
//
//

#import "NSObject+NSPerformSelector.h"

@implementation NSObject (NSPerformSelector)

+ (id)target:(id)target performSelector:(SEL)selector {
	
	IMP imp = [target methodForSelector:selector];
	id (*func)(id, SEL) = (void *)imp;
	return func(target, selector);
}

+ (id)target:(id)target performSelector:(SEL)selector withObject:(id)object {
	
	IMP imp = [target methodForSelector:selector];
	id (*func)(id, SEL, id) = (void *)imp;
	return func(target, selector, object);
}

+ (id)target:(id)target performSelector:(SEL)selector withObject:(id)object1 withObject2:(id)object2 {
	
	IMP imp = [target methodForSelector:selector];
	id (*func)(id, SEL, id, id) = (void *)imp;
	return func(target, selector, object1, object2);
}

@end
