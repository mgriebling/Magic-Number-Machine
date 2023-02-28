// ##############################################################
//  ExpressionSymbols.h
//  Magic Number Machine
//
//  Created by Matt Gallagher on Sun May 04 2003.
//  Copyright (c) 2003 Matt Gallagher. All rights reserved.
// ##############################################################

#import <Foundation/Foundation.h>

#import "BigCFloat.h"

//
// About ExpressionSymbols
//
// A single instance class that maintains the bezier paths for most drawable symbols
//

//
// These have to line up with the internal constant definitions in constantsDataRows
// or bad things will happen. -- Mike
//
typedef NS_ENUM(NSInteger, ConstType) {
	BohrRadius=0,
	StructureConstant,
	StandardAtmosphere,
	WienDisplacement,
	RadiationConstant1,
	RadiationConstant2,
	SpeedOfLight,
	HartreeEnergy,
	ElementaryCharge,
	VacuumPermittivity,
	ElectronVolt,
	FaradayConstant,
	ElectronGFactor,
	MuonGFactor,
	GravitationalAcceleration,
	GravitationalConstant,
	QuantumConductance,
	PlanckConstant,
	PlanckConstantPi,
	RootOfMinusOne,
	BoltmannConstant,
	PlanckLength,
	ElectronComptonWavelengthPi,
	NeutronComptonWavelength,
	ProtonComptonWavelength,
	ElectronComptonWavelength,
	DeuteronMass,
	ElectronMass,
	NeutronMass,
	PlanckMass,
	ProtonMass,
	AtomicMassConstant,
	VacuumMagneticPermittivity,
	BohrMagneton,
	DeuteronMagneticMoment,
	NuclearMagneton,
	LoschmidtConstant,
	AvagadroConstant,
	MagneticFluxQuantum,
	Pi,
	ClassicalElectronRadius,
	QuantizedHallResistance,
	MolarGasConstant,
	RydbergConstant,
	ElectronThomsonCrossSection,
	StefanBoltzmannConstant,
	PlanckTime,
	PlanckTemperature,
	MolarVolume
};

@interface ExpressionSymbols : NSObject

+ (NSBezierPath *)getSymbolForString:(NSString *)string;

+ (NSFont *)getDisplayFontWithSize:(CGFloat)size;

+ (NSBezierPath *)makeSymbolForConstant:(enum ConstType)constant;
+ (BigCFloat *)getValueForConstant:(enum ConstType)constant;
+ (NSString *)getNameForConstant:(enum ConstType)constant;
+ (NSAttributedString *)toFormattedString: (NSString *)string;
+ (NSArray *)getConstants;

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
+ (NSBezierPath *)sub2Path;
+ (NSBezierPath *)lnPath;
+ (NSBezierPath *)sqrtPath;
+ (NSBezierPath *)nRootPath:(NSUInteger)n;
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
+ (NSBezierPath *)cubedPath;
+ (NSBezierPath *)inversePath;

@end
