//
//  History.h
//  Magic Number Machine
//
//  Created by Michael Griebling on 28May2015.
//
//

#import <Foundation/Foundation.h>

@interface History : NSObject <NSCoding>

- (instancetype)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

@end
