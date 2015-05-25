// ##############################################################
//  ExpressionSymbols.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun May 04 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Foundation/Foundation.h>

//
// About ExpressionSymbols
//
// A single instance class that maintains the bezier paths for most drawable symbols
//
@interface ExpressionSymbols : NSObject
{
}

+ (NSBezierPath *)getSymbolForString:(NSString *)string;

+ (void)initialize;
+ (NSBezierPath *)plusPath;
+ (NSBezierPath *)minusPath;
+ (NSBezierPath *)multiplyPath;
+ (NSBezierPath *)equalsPath;
+ (NSBezierPath *)sinPath;
+ (NSBezierPath *)cosPath;
+ (NSBezierPath *)tanPath;
+ (NSBezierPath *)hypPath;
+ (NSBezierPath *)rePath;
+ (NSBezierPath *)imPath;
+ (NSBezierPath *)absPath;
+ (NSBezierPath *)argPath;
+ (NSBezierPath *)andPath;
+ (NSBezierPath *)orPath;
+ (NSBezierPath *)xorPath;
+ (NSBezierPath *)notPath;
+ (NSBezierPath *)rndPath;
+ (NSBezierPath *)logPath;
+ (NSBezierPath *)lnPath;
+ (NSBezierPath *)sqrtPath;
+ (NSBezierPath *)sigmaPath;
+ (NSBezierPath *)tenPath;
+ (NSBezierPath *)ePath;
+ (NSBezierPath *)factorialPath;
+ (NSBezierPath *)iPath;
+ (NSBezierPath *)piPath;
+ (NSBezierPath *)modPath;
+ (NSBezierPath *)nprPath;
+ (NSBezierPath *)ncrPath;
+ (NSBezierPath *)leftBracketPath;
+ (NSBezierPath *)rightBracketPath;
+ (NSBezierPath *)dotPath;
+ (NSBezierPath *)squarePath;
+ (NSBezierPath *)inversePath;

@end
