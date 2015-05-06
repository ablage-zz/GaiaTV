//
//  TvVideoController.m
//  GaiaTV
//
//  Created by marcel on 11/7/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import "TvVideoController.h"

#import "HDChannelAddress.h"
#import "HDHomeRunUnit.h"
#import "HDHomeRunTuner.h"

#import "Services.h"
#import "Channel.h"


@implementation TvVideoController

+ (TvVideoController *)tvVideoController {
	return [[[TvVideoController alloc] initWithWindowNibName:@"TVVideo"] autorelease];
}

- (id)initWithWindowNibName:(NSString *)nibName {
	self = [super initWithWindowNibName:nibName];
	if (self != nil) {
		task1 = nil;
		task2 = nil;
		filename = nil;
		lastTuner = nil;
	}
	return self;
}

- (void)show {
	[self showWindow:self];
	//[[self window] center];
}

- (Services *)services {
	return [Services sharedServices];
}

- (void)windowWillClose:(NSNotification *)notification {
	[self stopMovie];
}


- (void)startMovie:(id)command {
//	system([(NSString *)command cString]);
}
- (void)stopMovie {
//	system([[NSString stringWithFormat:@"/usr/bin/killall VLC"] cString]);
	if (task1 != nil) {
		if ([task1 isRunning]) [task1 terminate];
		[task1 release];
		task1 = nil;
	}
	
	if (task2 != nil) {
		if ([task1 isRunning]) [task2 terminate];
		[task2 release];
		task2 = nil;
	}
	
	if (filename != nil) {
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath:filename]) {
			[fm removeItemAtPath:filename error:nil];
		}
		[filename release];
		filename = nil;
	}
	
	if (lastTuner != nil) {
		if ([lastTuner isReceiving]) {
			[lastTuner cancelData];
		}
		[lastTuner release];
		lastTuner = nil;
	}
}

- (IBAction)loadChannel:(id)sender {

	[self stopMovie];
	
	NSEnumerator *channelAddressEnum;
	HDChannelAddress *currentAddress;
	Channel *selectedChannel1 = [[selectedChannel selection] valueForKey:@"self"];
	
	BOOL tuned = NO;
		if (([selectedChannel1 activated])) { //(sele == i) && 
			channelAddressEnum = [[selectedChannel1 channelAddresses] objectEnumerator];
			while(currentAddress = [channelAddressEnum nextObject]) {
				if ([currentAddress tuner] != nil) {
					
				if ((![[currentAddress tuner] isReceiving])) {
					lastTuner = [[(Channel *)selectedChannel1 tuneToChannelAddress:currentAddress] retain];
					if (lastTuner != nil) {
						
						break;
					}
				}
				}
			}
	}
	
	if (!tuned) {
		NSLog(@"Could not tune to selected channel.");
	}
}

@end
