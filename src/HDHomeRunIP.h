//
//  HDHomeRunIP.h
//  GaiaTV
//
//  Created by marcel on 11/10/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HDHomeRunIP : NSObject {
	NSUInteger unsignedIntValue;
}

@property(readwrite, assign) NSUInteger unsignedIntValue;

+ (HDHomeRunIP *)ip;
+ (HDHomeRunIP *)ipWithNumber:(NSUInteger)value;
+ (HDHomeRunIP *)ipWithString:(NSString *)value;

- (id)initWithNumber:(NSUInteger)value;
- (id)initWithString:(NSString *)value;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)value;

- (NSString *)description;
	
@end
