//
//  HDHomeRun.h
//  GaiaTV
//
//  Created by marcel on 10/30/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HDHomeRunUnit;


typedef enum {
	kUsBCast,
	kUsCable,
	kUsHrc,
	kUsIrc,
	kAuBCast,
	kAuCable,
	kEuBCast,
	kEuCable,
	kTwBCast,
	kTwCable,
	kChannelMapUnknown
} ChannelMap;

typedef enum {
	kHDUnknown = 0,
	kHDFreeToAir = 1,
	kHDEncrypted = 2,
	kHDControlData = 4
} ProgramType;


@interface HDHomeRunControl : NSObject {
}

+ (NSArray *)sharedUnits;
+ (void)setSharedUnits:(NSArray*)value;

+ (HDHomeRunUnit *)findUnitById:(NSUInteger)lunitId;
+ (HDHomeRunUnit *)findUnitByIp:(NSString *)lunitIp;


+ (NSString *)channelMapToString:(ChannelMap)map;
+ (ChannelMap)stringToChannelMap:(NSString *)map;

  
+ (NSArray *)discover;

@end
