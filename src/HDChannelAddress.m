//
//  HDChannelAddress.m
//  GaiaTV
//
//  Created by marcel on 10/30/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import "HDChannelAddress.h"

#import "HDHomeRunUnit.h"
#import "HDHomeRunTuner.h"


@implementation HDChannelAddress

// Private
+ (NSString *)generateUniqueId {
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	CFStringRef lUniqueId = CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	return [NSMakeCollectable(lUniqueId) autorelease];
}

@synthesize tuner;
@synthesize uniqueId;
@synthesize frequency;
@synthesize programNo;
@synthesize modulation;
@synthesize programCode;
@synthesize programName;
@synthesize channelMap;
@synthesize info;
@synthesize channelType;


+ (HDChannelAddress *)channelAddressWithTuner:(HDHomeRunTuner *)lTuner {
	return [[[HDChannelAddress alloc] initWithTuner:lTuner] autorelease];
}
- (id)initWithTuner:(HDHomeRunTuner *)lTuner {
	return [self initWithTuner:lTuner andUniqueId:[HDChannelAddress generateUniqueId]];
}
- (id)initWithTuner:(HDHomeRunTuner *)lTuner andUniqueId:(NSString *)lUniqueId {
	self = [super init];
	
	if (self != nil) {
		tuner = lTuner; // Not owner (no retain)
		uniqueId = [[lUniqueId copy] retain];
		
		[self setFrequency:0];
		[self setProgramNo:0];
		[self setModulation:@"auto"];
		[self setProgramCode:nil];
		[self setProgramName:nil];
		[self setChannelMap:kChannelMapUnknown];
		[self setInfo:nil];
		[self setChannelType:kHDUnknown];
	}
	
	return self;	
}
- (void)dealloc {
	tuner = nil;
	
	[uniqueId release];
	
	[modulation release];
	[programCode release];
	[programName release];
	[info release];

	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
	NSUInteger lUnitId = [coder decodeIntForKey:@"unitId"];
	HDHomeRunUnit *lunit = [HDHomeRunControl findUnitById:lUnitId];

	NSUInteger lTunerId = [coder decodeIntForKey:@"tunerId"];
	HDHomeRunTuner *lTuner = [lunit findTunerById:lTunerId];
	
	self = [self initWithTuner:lTuner andUniqueId:[coder decodeObjectForKey:@"uniqueId"]];
	
	if (self != nil) {
	
		[self setFrequency:[coder decodeIntForKey:@"frequency"]];
		[self setProgramNo:[coder decodeIntForKey:@"programNo"]];
		[self setModulation:[coder decodeObjectForKey:@"modulation"]];
		[self setProgramCode:[coder decodeObjectForKey:@"programCode"]];
		[self setProgramName:[coder decodeObjectForKey:@"programName"]];
		[self setChannelMap:[coder decodeIntForKey:@"channelMap"]];
		[self setInfo:[coder decodeObjectForKey:@"info"]];
		[self setChannelType:[coder decodeIntForKey:@"channelType"]];
	}
	return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:[[[self tuner] unit] unitId] forKey:@"unitId"];
	[coder encodeInt:[[self tuner] tunerId] forKey:@"tunerId"];
	[coder encodeObject:[self uniqueId] forKey:@"uniqueId"];
	[coder encodeInt:[self frequency] forKey:@"frequency"];
	[coder encodeInt:[self programNo] forKey:@"programNo"];
	[coder encodeObject:[self modulation] forKey:@"modulation"];
	[coder encodeObject:[self programCode] forKey:@"programCode"];
	[coder encodeObject:[self programName] forKey:@"programName"];
	[coder encodeInt:[self channelMap] forKey:@"channelMap"];
	[coder encodeObject:[self info] forKey:@"info"];
	[coder encodeInt:[self channelType] forKey:@"channelType"];
}
- (id)copyWithZone:(NSZone *)zone {
	HDChannelAddress *copy = [[[self class] allocWithZone:zone] initWithTuner:[self tuner] andUniqueId:[self uniqueId]];
	
	[copy setFrequency:[self frequency]];
	[copy setProgramNo:[self programNo]];
	[copy setModulation:[self modulation]];
	[copy setProgramCode:[self programCode]];
	[copy setProgramName:[self programName]];
	[copy setChannelMap:[self channelMap]];
	[copy setInfo:[self info]];
	[copy setChannelType:[self channelType]];
	
	return copy;
}




- (HDHomeRunUnit *)unit {
	return [[self tuner] unit];
}

- (NSString *)description {
	if ([self uniqueId] != nil) {
		return [self uniqueId];
	} else {
		if (([self frequency] != 0) && ([self modulation] != nil) && ([self programNo] != 0)) {
			return [NSString stringWithFormat:@"(Frequency:%d; Program-No.:%d Modulation: %@)", [self frequency], [self programNo], [self modulation]];
		} else {
			return @"[unknown]";
		}
	}
}


- (void)newUniqueId {
	[uniqueId release];
	[self willChangeValueForKey:@"uniqueId"];
	uniqueId = [[HDChannelAddress generateUniqueId] retain];
	[self didChangeValueForKey:@"uniqueId"];
}

- (BOOL)isValidWithResponse:(NSMutableArray *)response {
	BOOL result = YES;
	
	if ([self tuner] == nil) {
		if (response != nil) [response addObject:[NSString stringWithFormat:@"Tuner is unknown at address %@.", self]];
		result = NO;
	}
	if ([[self tuner] tunerId] == -1) {
		if (response != nil) [response addObject:[NSString stringWithFormat:@"Tuner-id is unknown at address %@.", self]];
		result = NO;
	}
	if ([[self tuner] unit] == nil) {
		if (response != nil) [response addObject:[NSString stringWithFormat:@"Unit is unknown at address %@.", self]];
		result = NO;
	}
	if ([[[self tuner] unit] unitId] == -1) {
		if (response != nil) [response addObject:[NSString stringWithFormat:@"Unit-id is unknown at address %@.", self]];
		result = NO;
	}
	if ([self uniqueId] == nil) {
		if (response != nil) [response addObject:@"Unique-id is unknown."];
		result = NO;
	}
	if ([self frequency] == 0) {
		if (response != nil) [response addObject:[NSString stringWithFormat:@"Frequency is unknown at address %@.", self]];
		result = NO;
	}
	if (([self programNo] == 0)) {
		if (response != nil) [response addObject:[NSString stringWithFormat:@"Program number is unknown at address %@.", self]];
		result = NO;
	}
	if ([self modulation] == nil) {
		if (response != nil) [response addObject:[NSString stringWithFormat:@"Modulation is unknown at address %@.", self]];
		result = NO;
	}
	
	return result;
}
- (BOOL)repair:(BOOL)force {
	if ([self tuner] != nil) {
		return NO;
	}
	if ([[self tuner] tunerId] != -1) {
		return NO;
	}
	if ([[self tuner] unit] != nil) {
		return NO;
	}
	if ([[[self tuner] unit] unitId] != -1) {
		return NO;
	}
	if ([self uniqueId] != nil) {
		return NO;
	}
	if ([self frequency] != 0) {
		return NO;
	}
	if (([self programNo] != 0)) {
		return NO;
	}
	if ([self modulation] != nil) {
		[self setModulation:@"auto"];
	}
	return YES;
}

- (BOOL)isSimilar:(HDChannelAddress *)lAddress {
	return (([self frequency] == [lAddress frequency]) && ([self programNo] == [lAddress programNo]));
}

- (NSColor *)color {
	if ([self channelType] == kHDUnknown) {
		return [HDChannelAddress unknownColor];
	} else if ([self channelType] == kHDFreeToAir) {
		return [HDChannelAddress freeToAirColor];
	} else if ([self channelType] == kHDEncrypted) {
		return [HDChannelAddress encryptedColor];
	} else {
		return [HDChannelAddress controlDataColor];
	}
}

+ (NSColor *)unknownColor {
	return [NSColor yellowColor];
}
+ (NSColor *)freeToAirColor {
	return [NSColor greenColor];
}
+ (NSColor *)encryptedColor {
	return [NSColor redColor];
}
+ (NSColor *)controlDataColor {
	return [NSColor grayColor];
}

@end