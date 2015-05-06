//
//  Channel.h
//  GaiaTV
//
//  Created by marcel on 10/29/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HDHomeRunTuner;
@class HDChannelAddress;


@interface Channel : NSObject <NSCopying, NSCoding> {
	BOOL activated;
	NSString *description;
	
	NSInteger channelNo;
	NSArray *channelAddresses; // HDChannelAddress
}

@property(readwrite, assign) BOOL activated;
@property(readwrite, retain) NSArray *channelAddresses;
@property(readwrite, assign) NSInteger channelNo;

- (NSString *)description;
- (void)setDescription:(NSString *)value;


+ (Channel *)channelWithChannel:(NSInteger)lNumber;
- (id)initWithChannel:(NSInteger)lNumber;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

- (void)activateObserving;
- (void)deactivateObserving;

- (BOOL)isValid;
- (BOOL)repair:(BOOL)force;

- (HDChannelAddress *)getFirstChannelAddressForTuner:(HDHomeRunTuner *)lTuner;

- (BOOL)tuneOnTuner:(HDHomeRunTuner *)lTuner;
- (HDHomeRunTuner *)tuneToChannelAddress:(HDChannelAddress *)address;

- (NSColor *)color;

@end
