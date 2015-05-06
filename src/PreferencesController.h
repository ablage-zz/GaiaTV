//
//  PreferencesController.h
//  GaiaTV
//
//  Created by marcel on 11/5/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Services;


@interface PreferencesController : NSWindowController {
    IBOutlet NSWindow *tunerWindow;
	
	IBOutlet NSArrayController *selectedTuner;
	IBOutlet NSArrayController *selectedBouquets;
	IBOutlet NSArrayController *selectedChannels;

	IBOutlet NSArrayController *selectedChannelsInAll;
	IBOutlet NSArrayController *selectedChannelAddressesInAll;
	
	IBOutlet NSProgressIndicator *loadIndicator;
	IBOutlet NSProgressIndicator *scanIndicator;
	
	IBOutlet NSButton *onlyFreeToAirCheckBox;
}

+ (PreferencesController *)preferencesController;

- (void)show;

- (IBAction)tunerClick:(id)sender;

- (IBAction)scanClick:(id)sender;
- (IBAction)loadClick:(id)sender;

- (IBAction)addChannelToBouquetClick:(id)sender;
- (IBAction)addChannelAddressToChannelClick:(id)sender;

- (Services *)services;
- (NSArray *)units;
	
@end
