//
//  HDHomeRunUnit.m
//  GaiaTV
//
//  Created by marcel on 10/30/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import "HDHomeRunUnit.h"

#import "HDHomeRunTuner.h";
#import "HDHomeRunControl.h";


@implementation HDHomeRunUnit

@synthesize unitId;
@synthesize ip;
@synthesize tuner;

- (NSString *)description {
	if ((description == nil) || ([description isEqualToString:@""])) {
		if (([self unitId] != 0) || ([self ip] != 0)) {
			return [NSString stringWithFormat:@"%@ (%@)", (([self unitId] == 0) ? @"[unknown]" : [NSString stringWithFormat:@"0x%04x", [self unitId]]), (([self ip] == 0) ? @"[unknown]" : [self ipAddress])];
		} else {
			return @"[unknown]";
		}
	} else {
		return description;
	}
}
- (void)setDescription:(NSString *)value {
	if (value != description) {
		[description release];
		[self willChangeValueForKey:@"description"];
		description = [[value copy] retain];		
		[self didChangeValueForKey:@"description"];
	}
}


+ (HDHomeRunUnit *)homeRunUnitWithID:(NSUInteger)lUnitId andIp:(NSUInteger)lIp {
	return [[[HDHomeRunUnit alloc] initWithID:lUnitId andIp:lIp] autorelease];
}
- (id)initWithID:(NSUInteger)lUnitId andIp:(NSUInteger)lIp {
	self = [super init];
	if (self != nil) {
		unitId = lUnitId;
		ip = lIp;
    description = nil;
    
		NSMutableArray *lTuner = [NSMutableArray array];
		[lTuner addObject:[HDHomeRunTuner homeRunTuner:0 onUnit:self]];
		[lTuner addObject:[HDHomeRunTuner homeRunTuner:1 onUnit:self]];
		tuner = [lTuner retain];
	}
	return self;
}
- (void)dealloc {
	[description release];
	[tuner release];

	[super dealloc];
}




- (HDHomeRunTuner *)findTunerById:(NSUInteger)lTunerId {
	NSArray *list = [self tuner];
	
	if (list == nil) return nil;
	
	NSEnumerator *arrayEnum = [list objectEnumerator];
	HDHomeRunTuner *currentTuner;
	
	while(currentTuner = [arrayEnum nextObject]) {
		if ([currentTuner tunerId] == lTunerId) {
			return currentTuner;
		}
	}
	
	return nil;
}



- (NSString *)value:(NSString *)identifier {
	HDHomeRunTuner *tunr;
	for(int i = 0; i < [tuner count]; i++) {
		tunr = [tuner objectAtIndex:i];
		if ([tunr isConnected]) {
			return [tunr value:identifier];
		}
	}
	return nil;
}
- (void)setValue:(NSString *)identifier WithData:(NSString *)data {
	HDHomeRunTuner *tunr;
	for(int i = 0; i < [tuner count]; i++) {
		tunr = [tuner objectAtIndex:i];
		if ([tunr isConnected]) {
			[tunr setValue:identifier WithData:data];
			break;
		}
	}
}



- (BOOL)isConnected {
	HDHomeRunTuner *tunr;
	for(int i = 0; i < [tuner count]; i++) {
		tunr = [tuner objectAtIndex:i];
		if ([tunr isConnected]) {
			return YES;
		}
	}
	return NO;
}


- (NSString *)target {
	return [self value:@"/ir/target"];
}
- (void)setTargetIp:(NSString *)lip AndPort:(NSString *)lport {
	[self setValue:@"/ir/target" WithData:[NSString stringWithFormat:@"%@:%@", lip, lport]];
}

- (NSString *)location {
	return [self value:@"/lineup/location"];
}
- (void)setLocationCountryCode:(NSString *)ccode AndPostalCode:(NSString *)pcode {
	[self setValue:@"/lineup/location" WithData:[NSString stringWithFormat:@"%@:%@", ccode, pcode]];
}
- (void)clearLocation {
	[self setValue:@"/lineup/location" WithData:@"disabled"];
}



- (NSString *)version {
	return [self value:@"/sys/version"];
}
- (NSString *)model {
	return [self value:@"/sys/model"];
}
- (NSString *)features {
	return [self value:@"/sys/features"];
}
- (NSString *)copyright {
	return [self value:@"/sys/copyright"];
}
- (NSString *)debugInfo {
	return [self value:@"/sys/debug"];
}



- (NSString *)supportedModulations {
// TODO: Cleanup
  //	NSArray *command = [NSArray arrayWithObjects:@"hdhomerun_config", [NSString stringWithFormat:@"%d", [self unitId]], @"get", @"help", nil];
//	NSString *response = [HDHomeRun executeCommand:command];
//	
//	if (response == nil) {
//		return nil;
//	} else {
//		
//		NSScanner *scanner = [NSScanner scannerWithString:response];
//		NSCharacterSet *newLineSet = [NSCharacterSet newlineCharacterSet];
//		NSString *part = [NSString string];
//		
//		BOOL result;
//		result = [scanner scanUpToString:@"Supported modulation types: " intoString:nil];
//		if (result == NO) return nil; 
//		result = [scanner scanString:@"Supported modulation types: " intoString:nil];
//		if (result == NO) return nil; 
//		result = [scanner scanUpToCharactersFromSet:newLineSet intoString:&part];
//		if (result == NO) return nil; 
//		
//		return part;
//	}	
  return [NSString string];  
}
- (NSString *)supportedChannelMaps {
// TODO: Cleanup
//	NSArray *command = [NSArray arrayWithObjects:@"hdhomerun_config", [NSString stringWithFormat:@"%d", [self unitId]], @"get", @"help", nil];
//	NSString *response = [HDHomeRun executeCommand:command];
//	
//	if (response == nil) {
//		return nil;
//	} else {
//		
//		NSScanner *scanner = [NSScanner scannerWithString:response];
//		NSCharacterSet *newLineSet = [NSCharacterSet newlineCharacterSet];
//		NSString *part = [NSString string];
//		
//		BOOL result;
//		result = [scanner scanUpToString:@"Supported channel maps: " intoString:nil];
//		if (result == NO) return nil; 
//		result = [scanner scanString:@"Supported channel maps: " intoString:nil];
//		if (result == NO) return nil; 
//		result = [scanner scanUpToCharactersFromSet:newLineSet intoString:&part];
//		if (result == NO) return nil; 
//		
//		return part;
//	}	
  return [NSString string];
}

- (NSString *)ipAddress {
  unsigned int ipPart1 = ([self ip] >> 24) & 0x0FF;
  unsigned int ipPart2 = ([self ip] >> 16) & 0x0FF;
  unsigned int ipPart3 = ([self ip] >> 8) & 0x0FF;
  unsigned int ipPart4 = [self ip] & 0x0FF;
  return [NSString stringWithFormat:@"%u.%u.%u.%u", ipPart1, ipPart2, ipPart3, ipPart4];
}

- (NSString *)unitIdHex {
  return [NSString stringWithFormat:@"0x%04x", [self unitId]];
}

@end