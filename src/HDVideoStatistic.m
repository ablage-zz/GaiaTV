//
//  HDVideoStatistic.m
//  GaiaTV
//
//  Created by marcel on 10/31/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import "HDVideoStatistic.h"


@implementation HDVideoStatistic

@synthesize packetsReceived;
@synthesize networkError;
@synthesize transportError;
@synthesize sequenceError;

- (NSString *)description {
	return [NSString stringWithFormat:@"Packets Received:%@ Network-Error:%@ Transport-Error:%@ Sequence-Error:%@", (([self packetsReceived] == nil) ? @"[unknown]" : [self packetsReceived]), (([self networkError] == nil) ? @"[unknown]" : [self networkError]), (([self transportError] == nil) ? @"[unknown]" : [self transportError]), (([self sequenceError] == nil) ? @"[unknown]" : [self sequenceError])];
}


+ (HDVideoStatistic *)videoStatisticWithString:(NSString *)stat {
	return [[[HDVideoStatistic alloc] initWithString:stat] autorelease];
}
- (id)initWithString:(NSString *)stat {
	self = [super init];
	if (self != nil) {
		packetsReceived = nil;
		networkError = nil;
		transportError = nil;
		sequenceError = nil;
		
		BOOL result = [self parseFromString:stat];
		if (result == NO) self = nil;
	}
	return self;
}
- (void)dealloc {
	[packetsReceived release];
	[networkError release];
	[transportError release];
	[sequenceError release];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
	HDVideoStatistic *copy = [[[self class] allocWithZone:zone] init];
	
	[copy setPacketsReceived:[self packetsReceived]];
	[copy setNetworkError:[self networkError]];
	[copy setTransportError:[self transportError]];
	[copy setSequenceError:[self sequenceError]];
	
	return copy;
}

- (BOOL)parseFromString:(NSString *)stat {
	NSScanner *scanner = [NSScanner scannerWithString:stat];
	NSCharacterSet *numericSet = [NSCharacterSet decimalDigitCharacterSet];
	
	long long longValue;
	BOOL result = NO;
	int counter = 0;
	
	// Example: 719707 packets received, 0 network errors, 0 transport errors, 0 sequence errors
	
	result = [scanner scanUpToCharactersFromSet:numericSet intoString:nil];
	if (result == YES) {
		result = [scanner scanLongLong:&longValue];
		if (result == YES) {
			result = [scanner scanString:@" packets received" intoString:nil];
			if (result == YES) {
				[self willChangeValueForKey:@"packetsReceived"];
				packetsReceived = [[NSNumber numberWithLongLong:longValue] retain];
				[self didChangeValueForKey:@"packetsReceived"];
				counter++;
			}
		}
	}

	result = [scanner scanUpToCharactersFromSet:numericSet intoString:nil];
	if (result == YES) {
		result = [scanner scanLongLong:&longValue];
		if (result == YES) {
			result = [scanner scanString:@" network errors" intoString:nil];
			if (result == YES) {
				[self willChangeValueForKey:@"networkError"];
				networkError = [[NSNumber numberWithLongLong:longValue] retain];
				[self didChangeValueForKey:@"networkError"];
				counter++;
			}
		}
	}

	result = [scanner scanUpToCharactersFromSet:numericSet intoString:nil];
	if (result == YES) {
		result = [scanner scanLongLong:&longValue];
		if (result == YES) {
			result = [scanner scanString:@" transport errors" intoString:nil];
			if (result == YES) {
				[self willChangeValueForKey:@"transportError"];
				transportError = [[NSNumber numberWithLongLong:longValue] retain];
				[self didChangeValueForKey:@"transportError"];
				counter++;
			}
		}
	}

	result = [scanner scanUpToCharactersFromSet:numericSet intoString:nil];
	if (result == YES) {
		result = [scanner scanLongLong:&longValue];
		if (result == YES) {
			result = [scanner scanString:@" sequence errors" intoString:nil];
			if (result == YES) {
				[self willChangeValueForKey:@"sequenceError"];
				sequenceError = [[NSNumber numberWithLongLong:longValue] retain];
				[self didChangeValueForKey:@"sequenceError"];
				counter++;
			}
		}
	}
	
	return (counter == 4);
}

@end