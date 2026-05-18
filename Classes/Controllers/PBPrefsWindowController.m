//
//  PBPrefsWindowController.m
//  GitX
//
//  Created by Christian Jacobsen on 02/10/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBPrefsWindowController.h"
#import "PBGitRepository.h"
#import "PBGitDefaults.h"

#define kPreferenceViewIdentifier @"PBGitXPreferenceViewIdentifier"

@implementation PBPrefsWindowController

# pragma mark DBPrefsWindowController overrides

- (void)buildGeneralWrapperView
{
	CGFloat w = generalPrefsView.frame.size.width;
	CGFloat existingH = generalPrefsView.frame.size.height;
	CGFloat addedH = 70.0;
	CGFloat totalH = existingH + addedH;

	generalWrapperView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, w, totalH)];

	// Existing general prefs sit at the bottom of the wrapper
	[generalPrefsView setFrameOrigin:NSMakePoint(0, 0)];
	[generalWrapperView addSubview:generalPrefsView];

	// Separator between new controls and existing content
	NSBox *sep = [[NSBox alloc] initWithFrame:NSMakeRect(20, existingH + 4, w - 40, 1)];
	sep.boxType = NSBoxSeparator;
	[generalWrapperView addSubview:sep];

	// "Appearance:" label — left-aligned to match other controls in the General tab
	NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(20, existingH + 26, 90, 18)];
	label.stringValue = @"Appearance:";
	label.editable = NO;
	label.bordered = NO;
	label.drawsBackground = NO;
	label.alignment = NSTextAlignmentLeft;
	[generalWrapperView addSubview:label];

	// Three-segment button: System / Light / Dark
	appearanceSegControl = [[NSSegmentedControl alloc]
		initWithFrame:NSMakeRect(116, existingH + 22, 250, 24)];
	[appearanceSegControl setSegmentCount:3];
	[appearanceSegControl setLabel:@"System" forSegment:0];
	[appearanceSegControl setLabel:@"Light"  forSegment:1];
	[appearanceSegControl setLabel:@"Dark"   forSegment:2];
	appearanceSegControl.segmentStyle = NSSegmentStyleRounded;
	appearanceSegControl.trackingMode = NSSegmentSwitchTrackingSelectOne;
	[appearanceSegControl setTarget:self];
	[appearanceSegControl setAction:@selector(appearanceModeChanged:)];
	[generalWrapperView addSubview:appearanceSegControl];
}

- (void)setupToolbar
{
	if (!generalWrapperView)
		[self buildGeneralWrapperView];

	[appearanceSegControl setSelectedSegment:[PBGitDefaults appearanceMode]];

	// GENERAL (wrapped with appearance control at top)
	[self addView:generalWrapperView label:@"General" image:[NSImage imageNamed:@"gitx"]];
	// INTEGRATION
	[self addView:integrationPrefsView label:@"Integration" image:[NSImage imageNamed:NSImageNameNetwork]];
	// UPDATES
	[self addView:updatesPrefsView label:@"Updates"];
}

- (IBAction)appearanceModeChanged:(id)sender
{
	[PBGitDefaults setAppearanceMode:[appearanceSegControl selectedSegment]];
}

- (void)displayViewForIdentifier:(NSString *)identifier animate:(BOOL)animate
{
	[super displayViewForIdentifier:identifier animate:animate];

	[[NSUserDefaults standardUserDefaults] setObject:identifier forKey:kPreferenceViewIdentifier];
}

- (NSString *)defaultViewIdentifier
{
	NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:kPreferenceViewIdentifier];
	if (identifier)
		return identifier;

	return [super defaultViewIdentifier];
}

#pragma mark -
#pragma mark Delegate methods

- (IBAction) checkGitValidity: sender
{
	// FIXME: This does not work reliably, probably due to: http://www.cocoabuilder.com/archive/message/cocoa/2008/9/10/217850
	//[badGitPathIcon setHidden:[PBGitRepository validateGit:[[NSValueTransformer valueTransformerForName:@"PBNSURLPathUserDefaultsTransfomer"] reverseTransformedValue:[gitPathController URL]]]];
}

- (IBAction) resetGitPath: sender
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"gitExecutable"];
}

- (void)pathCell:(NSPathCell *)pathCell willDisplayOpenPanel:(NSOpenPanel *)openPanel
{
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setTreatsFilePackagesAsDirectories:YES];
	[openPanel setAccessoryView:gitPathOpenAccessory];
	[openPanel setResolvesAliases:NO];
	//[[openPanel _navView] setShowsHiddenFiles:YES];

	gitPathOpenPanel = openPanel;
}

- (IBAction)resetAllDialogWarnings:(id)sender
{
	[PBGitDefaults resetAllDialogWarnings];
}

#pragma mark -
#pragma mark Git Path open panel actions

- (IBAction) showHideAllFiles: sender
{
	/* FIXME: This uses undocumented OpenPanel features to show hidden files! */
	NSNumber *showHidden = [NSNumber numberWithBool:[sender state] == NSOnState];
	[[gitPathOpenPanel valueForKey:@"_navView"] setValue:showHidden forKey:@"showsHiddenFiles"];
}

@end
