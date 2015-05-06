//
//  HDHomeRunTuner.h
//  GaiaTV
//
//  Created by marcel on 10/30/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HDHomeRunControl.h"

@class  HDHomeRunUnit;
@class	HDChannelAddress;
@class	HDVideoStatistic;


@interface HDHomeRunTuner : NSObject {
	// ReadWrite Retain
	NSArray *channelAddresses;
	NSString *description;

	// ReadOnly retain/assign
	NSInteger tunerId;
	NSTask *currentReceiverTask;
	HDChannelAddress *lastChannelAddress;
	HDVideoStatistic *lastVideoStatistic;

	// ReadOnly Assign
	HDHomeRunUnit *unit;	

  // Internal
  struct hdhomerun_device_t *handler;
}

@property(readwrite, retain) NSArray *channelAddresses;

@property(readonly) HDHomeRunUnit *unit;

@property(readonly, assign) NSInteger tunerId;
@property(readonly) HDChannelAddress *lastChannelAddress;
@property(readonly) HDVideoStatistic *lastVideoStatistic;


+ (HDHomeRunTuner *)homeRunTuner:(NSInteger)lTunerId onUnit:(HDHomeRunUnit *)lUnit;
- (id)initWithTuner:(NSInteger)lTunerId onUnit:(HDHomeRunUnit *)lUnit;

- (NSString *)description;
- (void)setDescription:(NSString *)value;

- (BOOL)isConnected;

- (BOOL)lock;
- (BOOL)unlock;

- (NSString *)value:(NSString *)identifier;
- (void)setValue:(NSString *)identifier WithData:(NSString *)data;

- (NSString*)tunerValue:(NSString *)identifier;
- (void)setTunerValue:(NSString *)identifier WithData:(NSString *)data;

- (NSString *)channel;
- (void)setChannelWithModulation:(NSString *)modulation AndFrequency:(NSUInteger)frequency;
- (void)setChannelWithFrequency:(NSUInteger)frequency;
- (void)clearChannel;

- (ChannelMap)channelMap;
- (void)setChannelMap:(ChannelMap)map;
- (void)setChannelMapByString:(NSString *)map;

- (NSString *)getFilter;
- (void)setFilter:(NSString *)filter;
- (void)setFilterFrom:(NSUInteger)from AndFrequency:(NSUInteger)to;

- (NSString *)program;
- (void)setProgram:(NSUInteger)prg;
- (void)setProgramWithMajor:(NSUInteger)major AndMinor:(NSUInteger)minor;

- (NSString *)target;
- (void)setTargetIp:(NSString *)ip AndPort:(NSString *)port;
- (void)setTarget:(NSString *)ltarget;
- (void)clearTarget;

- (NSString *)channelGroup;
  
- (NSString *)status;
- (NSString *)streamInfo;
- (NSString *)debugInfo;

- (void)tuneToChannelAddress:(HDChannelAddress *)address;
- (void)clearTune;

- (BOOL)startStream;

- (BOOL)saveDataTo:(NSString *)filename;
- (BOOL)cancelData;
- (BOOL)isReceiving;

- (BOOL)scanWithFilter:(NSInteger)filter;

- (NSDictionary *)detailedStatus;

@end
