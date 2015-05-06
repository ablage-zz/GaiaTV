//
//  TvVideoController.h
//  GaiaTV
//
//  Created by marcel on 11/7/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Services;
@class HDHomeRunTuner;


@interface TvVideoController : NSWindowController {
  IBOutlet NSView *tvFrame;
	IBOutlet NSObjectController *selectedChannel;
	IBOutlet NSComboBox *channelCombo;
	
	NSTask *task1;
	NSTask *task2;
	NSString *filename;
	HDHomeRunTuner *lastTuner;
}

+ (TvVideoController *)tvVideoController;
- (IBAction)loadChannel:(id)sender;

- (void)show;

- (Services *)services;

- (void)stopMovie;

@end
