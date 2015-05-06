//
//  Bouquet.h
//  GaiaTV
//
//  Created by marcel on 10/29/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HDChannelAddress;
@class Channel;


@interface Bouquet : NSObject <NSCopying, NSCoding> {
	NSString *description;
	NSArray *channels; // Channels
}

@property(readwrite, retain) NSArray *channels;

- (NSString *)description;
- (void)setDescription:(NSString *)value;


+ (Bouquet *)bouquetListWithDescription:(NSString *)lDescription;
- (id)initWithDescription:(NSString *)lDescription;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

- (void)activateObserving;
- (void)deactivateObserving;

- (BOOL)isValid;
- (BOOL)repair:(BOOL)force;

@end
