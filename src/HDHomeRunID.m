//
//  HDHomeRunID.m
//  GaiaTV
//
//  Created by marcel on 11/10/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import "HDHomeRunID.h"

//#import "hdhomerun_core.h"


@implementation HDHomeRunID

@synthesize unsignedIntValue;


+ (HDHomeRunID *)deviceId {
	return [[[HDHomeRunID alloc] init] autorelease];
}
+ (HDHomeRunID *)deviceIdWithNumber:(NSUInteger)value {
	return [[[HDHomeRunID alloc] initWithNumber:value] autorelease];
}
+ (HDHomeRunID *)deviceIdWithString:(NSString *)value {
	return [[[HDHomeRunID alloc] initWithString:value] autorelease];
}

- (id)init {
	return [self initWithNumber:0];
}
- (id)initWithNumber:(NSUInteger)value {
	self = [super init];
	if (self != nil) {
		unsignedIntValue = value;
	}
	return self;
}
- (id)initWithString:(NSString *)value {
	self = [super init];
	if (self != nil) {
		[self setStringValue:value];
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (NSString *)stringValue {
	return [NSString stringWithFormat:@"0x%08lX", [self unsignedIntValue]];	
}
- (void)setStringValue:(NSString *)value {
	unsigned long a;
	char* cStringValue = (char *)[value cStringUsingEncoding:NSASCIIStringEncoding];
	
	if (sscanf(cStringValue, "%lx", &a) != 1) {
		[self setUnsignedIntValue:0];
	} else {
		[self setUnsignedIntValue:(NSUInteger)a];
	}
}

- (NSString *)description {
	return [self stringValue];
}

@end
