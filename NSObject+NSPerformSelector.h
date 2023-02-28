//
//  NSObject+NSPerformSelector.h
//  Magic Number Machine
//
//  Created by Mike Griebling on 24 May 2015.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (NSPerformSelector)

+ (id)target:(id)target performSelector:(SEL)selector;
+ (id)target:(id)target performSelector:(SEL)selector withObject:(id)object;
+ (id)target:(id)target performSelector:(SEL)selector withObject:(id)object1 withObject2:(id)object2;

@end
