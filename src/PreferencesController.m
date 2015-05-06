//
//  PreferencesController.m
//  GaiaTV
//
//  Created by marcel on 11/5/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import "PreferencesController.h"

#import "HDHomeRun.h"
#import "HDHomeRunTuner.h"
#import "HDChannelAddress.h"

#import "Services.h"
#import "Bouquet.h"


@implementation PreferencesController

+ (PreferencesController *)preferencesController {
	return [[[PreferencesController alloc] initWithWindowNibName:@"Preferences"] autorelease];
}


- (void)show {
	[self showWindow:self];
	[[self window] center];
}

- (void)windowWillClose:(NSNotification *)notification {
	[[self services] saveToDisk];
}

- (IBAction)tunerClick:(id)sender {
	[tunerWindow makeKeyAndOrderFront:self];
	[tunerWindow center];
}

- (IBAction)scanClick:(id)sender {
	[scanIndicator setHidden:NO];
	[scanIndicator startAnimation:self];
	
	NSEnumerator *tunerEnum = [[selectedTuner selectedObjects] objectEnumerator];
	HDHomeRunTuner *tuner;
	while(tuner = [tunerEnum nextObject]) {
		if (![tuner scanWithFilter:(([onlyFreeToAirCheckBox state] == 1) ? kHDFreeToAir : kHDUnknown)]) {
			[Services globalMessage:@"Error during scan."];
		}
		break;
	}
	
	// Cleanup
	[[self services] cleanup];
  
  // Save
  if (![[self services] saveToDisk]) {
    [Services globalMessage:@"Error during saving."];
  }
	
	[scanIndicator stopAnimation:self];
	[scanIndicator setHidden:YES];
}
- (IBAction)loadClick:(id)sender {
}

- (IBAction)addChannelToBouquetClick:(id)sender {
	NSEnumerator *selection1Enum = [[selectedBouquets selectedObjects] objectEnumerator];
	Bouquet *bouquet;
	while(bouquet = [selection1Enum nextObject]) {
		NSMutableArray *tempArray = [[bouquet channels] mutableCopy];

		NSEnumerator *selection2Enum = [[selectedChannelsInAll selectedObjects] objectEnumerator];
		Channel *channel;
		while(channel = [selection2Enum nextObject]) {
			[tempArray addObject:channel];
		}
		
		[bouquet setChannels:tempArray];
	}	
}
- (IBAction)addChannelAddressToChannelClick:(id)sender {
	NSEnumerator *selection1Enum = [[selectedChannels selectedObjects] objectEnumerator];
	Channel *channel;
	while(channel = [selection1Enum nextObject]) {
		NSMutableArray *tempArray = [[channel channelAddresses] mutableCopy];
		
		NSEnumerator *selection2Enum = [[selectedChannelAddressesInAll selectedObjects] objectEnumerator];
		HDChannelAddress *channelAddress;
		while(channelAddress = [selection2Enum nextObject]) {
			[tempArray addObject:channelAddress];
		}
		
		[channel setChannelAddresses:tempArray];
	}
}

- (Services *)services {
	return [Services sharedServices];
}
- (NSArray *)units {
	return [HDHomeRunControl sharedUnits];
}

@end
