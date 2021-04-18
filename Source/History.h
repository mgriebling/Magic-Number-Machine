//
//  History.h
//  Magic Number Machine
//
//  Created by Michael Griebling on 28May2015.
//
//

#import <Foundation/Foundation.h>

@interface History : NSObject <NSCoding>

- (instancetype)init;
- (instancetype)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)clear;

- (void)addItem: (NSData *)data withBezierPath:(NSBezierPath*)path;
- (NSArray *)getItemAtIndex: (NSInteger)index;
- (NSInteger)count;

@end
