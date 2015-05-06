//
//  Services.h
//  GaiaTV
//
//  Created by marcel on 11/4/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HDChannelAddress;
@class HDHomeRunTuner;

@class Bouquet;
@class Channel;


@interface Services : NSObject {
	NSArray *bouquets; //Bouquets
}

+ (Services *)sharedServices;
+ (void)setSharedServices:(Services *)value;

+ (void)globalMessage:(NSString *)message;

@property(readwrite, retain) NSArray *bouquets;

- (NSString *)description;

- (void)informationUpdated;

- (NSArray *)channels;
- (NSArray *)channelAddressesFromTuner;
- (NSArray *)channelAddressesFromChannels;

+ (Services *)services;

- (void)activateObserving;
- (void)deactivateObserving;
	
- (BOOL)loadFromDisk;
- (BOOL)saveToDisk;

- (BOOL)isValid;
- (BOOL)repair:(BOOL)force;

- (BOOL)cleanup;

- (Bouquet *)getDefaultBouquet;

- (NSInteger)getNewChannelNumberFrom:(NSInteger)startIndex positive:(BOOL)positive;

- (BOOL)addChannelAddresses:(NSArray *)addresses andRemoveOld:(BOOL)removeOld onTuner:(HDHomeRunTuner *)lTuner;
- (BOOL)removeChannelAddresses:(NSArray *)addresses;

@end
