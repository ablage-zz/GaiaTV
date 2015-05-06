//
//  HDHomeRunIP.m
//  GaiaTV
//
//  Created by marcel on 11/10/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import "HDHomeRunIP.h"

//#import "hdhomerun_core.h"


@implementation HDHomeRunIP

@synthesize unsignedIntValue;


+ (HDHomeRunIP *)ip {
	return [[[HDHomeRunIP alloc] init] autorelease];
}
+ (HDHomeRunIP *)ipWithNumber:(NSUInteger)value {
	return [[[HDHomeRunIP alloc] initWithNumber:value] autorelease];
}
+ (HDHomeRunIP *)ipWithString:(NSString *)value {
	return [[[HDHomeRunIP alloc] initWithString:value] autorelease];
}

- (id)init {
	return [self initWithNumber:0];
}
- (id)initWithNumber:(NSUInteger)value {
	self = [super init];
	if (self != nil) {
		[self setUnsignedIntValue:value];
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
	return [NSString stringWithFormat:@"%u.%u.%u.%u", 
		    (unsigned int)([self unsignedIntValue] >> 24) & 0x0FF, (unsigned int)([self unsignedIntValue] >> 16) & 0x0FF,
		    (unsigned int)([self unsignedIntValue] >> 8) & 0x0FF, (unsigned int)([self unsignedIntValue] >> 0) & 0x0FF
		   ];	
}
- (void)setStringValue:(NSString *)value {
	unsigned long a[4];
	char* cStringValue = (char *)[value cStringUsingEncoding:NSASCIIStringEncoding];
	
	if (sscanf(cStringValue, "%lu.%lu.%lu.%lu", &a[0], &a[1], &a[2], &a[3]) != 4) {
		[self setUnsignedIntValue:0];
	} else {
		[self setUnsignedIntValue:(NSUInteger)((a[0] << 24) | (a[1] << 16) | (a[2] << 8) | (a[3] << 0))];
	}
}

- (NSString *)description {
	return [self stringValue];
}

@end
