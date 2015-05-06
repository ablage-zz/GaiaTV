//
//  HDVideoStatistic.h
//  GaiaTV
//
//  Created by marcel on 10/31/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HDVideoStatistic : NSObject <NSCopying> {
	NSNumber *packetsReceived;
	NSNumber *networkError;
	NSNumber *transportError;
	NSNumber *sequenceError;
}

@property(readwrite, copy) NSNumber *packetsReceived;
@property(readwrite, copy) NSNumber *networkError;
@property(readwrite, copy) NSNumber *transportError;
@property(readwrite, copy) NSNumber *sequenceError;

- (NSString *)description;


+ (HDVideoStatistic *)videoStatisticWithString:(NSString *)stat;
- (id)initWithString:(NSString *)stat;

- (BOOL)parseFromString:(NSString *)stat;

@end