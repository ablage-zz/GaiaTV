//
//  HDHomeRunUnit.h
//  GaiaTV
//
//  Created by marcel on 10/30/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HDHomeRunTuner;

@interface HDHomeRunUnit : NSObject {
	NSUInteger unitId;
	NSUInteger ip;
	NSString *description;
	NSArray *tuner;
}

@property(readonly) NSUInteger unitId;
@property(readonly) NSUInteger ip;
@property(readonly) NSArray *tuner;


+ (HDHomeRunUnit *)homeRunUnitWithID:(NSUInteger)lUnitId andIp:(NSUInteger)lIp;
- (id)initWithID:(NSUInteger)lUnitId andIp:(NSUInteger)lIp;


- (HDHomeRunTuner *)findTunerById:(NSUInteger)lTunerId;


- (NSString *)description;
- (void)setDescription:(NSString *)value;

- (NSString *)version;
- (NSString *)model;
- (NSString *)copyright;
- (NSString *)debugInfo;

- (NSString *)supportedModulations;
- (NSString *)supportedChannelMaps;

- (NSString *)ipAddress;
- (NSString *)unitIdHex;  

@end