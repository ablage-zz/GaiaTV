//
//  HDHomeRun.m
//  GaiaTV
//
//  Created by marcel on 10/30/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import "HDHomeRunControl.h"

#import "hdhomerun.h"
#import "HDHomeRunUnit.h"




static NSArray *sharedUnits = nil;

@implementation HDHomeRunControl

+ (NSArray *)sharedUnits {
	return sharedUnits;
}
+ (void)setSharedUnits:(NSArray *)value {
	if (value != sharedUnits) {
		[value retain];
		[sharedUnits release];
		[self willChangeValueForKey:@"sharedUnits"];
		sharedUnits = value;
		[self didChangeValueForKey:@"sharedUnits"];
	}
}


+ (HDHomeRunUnit *)findUnitById:(NSUInteger)lunitId {
	NSArray *list = [HDHomeRunControl sharedUnits];
	
	if (list == nil) return nil;
	
	NSEnumerator *arrayEnum = [list objectEnumerator];
	HDHomeRunUnit *currentUnit;
	
	while(currentUnit = [arrayEnum nextObject]) {
		if ([currentUnit unitId] == lunitId) {
			return currentUnit;
		}
	}
	
	return nil;
}
+ (HDHomeRunUnit *)findUnitByIp:(NSString *)lunitIp {
	NSArray *list = [HDHomeRunControl sharedUnits];
	
	if (list == nil) return nil;
	
	NSEnumerator *arrayEnum = [list objectEnumerator];
	HDHomeRunUnit *currentUnit;
	
	while(currentUnit = [arrayEnum nextObject]) {
		if ([[currentUnit ipAddress] isEqualToString:lunitIp]) {
			return currentUnit;
		}
	}
	
	return nil;
}




+ (NSString *)channelMapToString:(ChannelMap)map {
	NSString *result;
	
	switch (map) {
		case kUsBCast: result = @"us-bcast"; break;
		case kUsCable: result = @"us-cable"; break;
		case kUsHrc: result = @"us-hrc"; break;
		case kUsIrc: result = @"us-irc"; break;
			
		case kAuBCast: result = @"au-bcast"; break;
		case kAuCable: result = @"au-cable"; break;
			
		case kEuBCast: result = @"eu-bcast"; break;
		case kEuCable: result = @"eu-cable"; break;
			
		case kTwBCast: result = @"tw-bcast"; break;
		case kTwCable: result = @"tw-cable"; break;
			
		default: result = nil; break;
	}
	
	return result;
}
+ (ChannelMap)stringToChannelMap:(NSString *)map {
	if ([map isEqualToString:@"us-bcast"]) { return kUsBCast; }
	else if ([map isEqualToString:@"us-cable"]) { return kUsCable; }
	else if ([map isEqualToString:@"us-hrc"]) { return kUsHrc; }
	else if ([map isEqualToString:@"us-irc"]) { return kUsIrc; }
	
	else if ([map isEqualToString:@"au-bcast"]) { return kAuBCast; }
	else if ([map isEqualToString:@"au-cable"]) { return kAuCable; }
	
	else if ([map isEqualToString:@"eu-bcast"]) { return kEuBCast; }
	else if ([map isEqualToString:@"eu-cable"]) { return kEuCable; }
	
	else if ([map isEqualToString:@"tw-bcast"]) { return kTwBCast; }
	else if ([map isEqualToString:@"tw-cable"]) { return kTwCable; }
  
	else { return kChannelMapUnknown; }
}



+ (NSArray *)discover { // Example: hdhomerun device 10143D05 found at 192.168.1.100
  uint32_t targetIp = 0;
  
  // Discover
	struct hdhomerun_discover_device_t result_list[64];
	int count = hdhomerun_discover_find_devices_custom(targetIp, HDHOMERUN_DEVICE_TYPE_TUNER, HDHOMERUN_DEVICE_ID_WILDCARD, result_list, 64);
  
  // Error checking
	if (count < 0) {
		NSLog(@"Error sending discover request.");
		return nil;
	}
	if (count == 0) {
		NSLog(@"No devices found.");
		return nil;
	}
  
  // Save in list
  NSMutableArray* list = [NSMutableArray array];
  struct hdhomerun_discover_device_t *result;
  
	for (int i = 0; i < count; i++) {
		result = &result_list[i];
    [list addObject:[HDHomeRunUnit homeRunUnitWithID:result->device_id andIp:result->ip_addr]];
	}
  
	[HDHomeRunControl setSharedUnits:[NSArray arrayWithArray:list]];

  return [HDHomeRunControl sharedUnits];
}

@end