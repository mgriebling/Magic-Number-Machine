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

- (instancetype)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if (self) {
		NSInteger size = [decoder decodeIntegerForKey:@"historyArray.size"];
		array = [NSMutableArray arrayWithCapacity:size];
		for (int i=0; i<size; i++) {
			NSMutableArray *item = [NSMutableArray array];
			id object = [decoder decodeObjectForKey:[NSString stringWithFormat:@"NSData[%d]", i]];
			if (object) {
				[item addObject:object];
				[item addObject:[decoder decodeObjectForKey:[NSString stringWithFormat:@"NSBezier[%d]", i]]];
				[item addObject:[decoder decodeObjectForKey:[NSString stringWithFormat:@"Index[%d]", i]]];
				[array addObject:item];
			}
			//size--;
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeInteger:array.count forKey:@"historyArray.size"];
	int i = 0;
	for (NSArray *item in array) {
		[encoder encodeObject:item[0] forKey:[NSString stringWithFormat:@"NSData[%d]", i]];		// NSData
		[encoder encodeObject:item[1] forKey:[NSString stringWithFormat:@"NSBezier[%d]", i]];	// NSBezier path
		[encoder encodeObject:item[2] forKey:[NSString stringWithFormat:@"Index[%d]", i]];		// index of item
		i++;
	}
}

- (void)clear {
	array = [NSMutableArray array];
}

@end
