//
//  HDChannelAddress.h
//  GaiaTV
//
//  Created by marcel on 10/30/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HDHomeRunControl.h"

@class HDHomeRunTuner;
@class HDHomeRunUnit;


@interface HDChannelAddress : NSObject <NSCopying, NSCoding> {
	HDHomeRunTuner *tuner;
	
	NSString *uniqueId;
	
	NSInteger frequency;
	NSInteger programNo;
	NSString *modulation;
	
	NSString *programCode;
	NSString *programName;
	
	ChannelMap channelMap;
	NSString *info;
	
	ProgramType channelType;
}

@property(readonly) HDHomeRunTuner *tuner;
@property(readonly) NSString *uniqueId;
@property(readwrite, assign) NSInteger frequency;
@property(readwrite, assign) NSInteger programNo;
@property(readwrite, copy) NSString *modulation;
@property(readwrite, copy) NSString *programCode;
@property(readwrite, copy) NSString *programName;
@property(readwrite, assign) ChannelMap channelMap;
@property(readwrite, copy) NSString *info;
@property(readwrite, assign) ProgramType channelType;

+ (HDChannelAddress *)channelAddressWithTuner:(HDHomeRunTuner *)lTuner;
- (id)initWithTuner:(HDHomeRunTuner *)lTuner;
- (id)initWithTuner:(HDHomeRunTuner *)lTuner andUniqueId:(NSString *)lUniqueId;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;


- (HDHomeRunUnit *)unit;

- (NSString *)description;

- (void)newUniqueId;

- (BOOL)isValidWithResponse:(NSMutableArray *)response;
- (BOOL)repair:(BOOL)force;

- (BOOL)isSimilar:(HDChannelAddress *)lAddress;

- (NSColor *)color;

+ (NSColor *)unknownColor;
+ (NSColor *)freeToAirColor;
+ (NSColor *)encryptedColor;
+ (NSColor *)controlDataColor;

@end