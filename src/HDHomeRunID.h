//
//  HDHomeRunID.h
//  GaiaTV
//
//  Created by marcel on 11/10/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HDHomeRunID : NSObject {
	NSUInteger unsignedIntValue;
}

@property(readwrite, assign) NSUInteger unsignedIntValue;

+ (HDHomeRunID *)deviceId;
+ (HDHomeRunID *)deviceIdWithNumber:(NSUInteger)value;
+ (HDHomeRunID *)deviceIdWithString:(NSString *)value;

- (id)initWithNumber:(NSUInteger)value;
- (id)initWithString:(NSString *)value;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)value;

- (NSString *)description;

@end
