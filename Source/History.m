//
//  History.m
//  Magic Number Machine
//
//  Created by Michael Griebling on 28May2015.
//
//

#import "History.h"

//
// Wrapper to support writing out of the history data
//

@implementation History {
	NSMutableArray *array;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		array = [NSMutableArray array];
	}
	return self;
}

- (void)addItem: (NSData *)data withBezierPath:(NSBezierPath*)path {
	NSArray *item = @[data, path, @(self.count+1)];
	[array addObject:item];
}

- (NSArray *)getItemAtIndex: (NSInteger)index {
	if (index > self.count) {
		return nil;
	}
	return array[index];
}

- (NSInteger)count {
	return array.count;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	
}

- (void)encodeWithCoder:(NSCoder *)coder {

}

@end
