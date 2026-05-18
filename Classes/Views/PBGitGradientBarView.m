//
//  PBGitGradientBarView.m
//  GitX
//
//  Created by Nathan Kinsinger on 2/22/10.
//  Copyright 2010 Nathan Kinsinger. All rights reserved.
//

#import "PBGitGradientBarView.h"



@implementation PBGitGradientBarView


- (id) initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (!self)
		return nil;
	
	[self setTopShade:1.0 bottomShade:0.0];
	
	return self;
}


- (void) drawRect:(NSRect)dirtyRect
{
	[gradient drawInRect:[self bounds] angle:90];
}


- (void) setTopColor:(NSColor *)topColor bottomColor:(NSColor *)bottomColor
{
	if (!topColor || !bottomColor)
		return;

	lightTopColor    = topColor;
	lightBottomColor = bottomColor;
	[self updateGradient];
	[self setNeedsDisplay:YES];
}


- (void) setTopShade:(float)topShade bottomShade:(float)bottomShade
{
	[self setTopColor:[NSColor colorWithCalibratedWhite:topShade    alpha:1.0]
		  bottomColor:[NSColor colorWithCalibratedWhite:bottomShade alpha:1.0]];
}


- (NSColor *)darkVariantOf:(NSColor *)lightColor
{
	NSColor *c = [lightColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
	CGFloat r, g, b, a;
	[c getRed:&r green:&g blue:&b alpha:&a];
	// Scale light values (~0.85-0.93) down to dark equivalents (~0.19-0.20)
	return [NSColor colorWithCalibratedRed:r * 0.22 green:g * 0.22 blue:b * 0.22 alpha:a];
}


- (void)updateGradient
{
	NSColor *top    = lightTopColor;
	NSColor *bottom = lightBottomColor;

	if (@available(macOS 10.14, *)) {
		NSAppearanceName best = [self.effectiveAppearance
			bestMatchFromAppearancesWithNames:@[NSAppearanceNameAqua, NSAppearanceNameDarkAqua]];
		if ([best isEqualToString:NSAppearanceNameDarkAqua]) {
			top    = [self darkVariantOf:top];
			bottom = [self darkVariantOf:bottom];
		}
	}

	gradient = [[NSGradient alloc] initWithStartingColor:bottom endingColor:top];
}


- (void)viewDidChangeEffectiveAppearance
{
	[self updateGradient];
	[self setNeedsDisplay:YES];
}


@end
