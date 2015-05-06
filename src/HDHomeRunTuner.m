//
//  HDHomeRunTuner.m
//  GaiaTV
//
//  Created by marcel on 10/30/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import "HDHomeRunTuner.h"

#import "hdhomerun.h"

#import "HDHomeRunUnit.h"
#import "HDChannelAddress.h"
#import "HDVideoStatistic.h"


@implementation HDHomeRunTuner

@synthesize channelAddresses;

@synthesize unit;

@synthesize tunerId;
@synthesize lastChannelAddress;
@synthesize lastVideoStatistic;


+ (HDHomeRunTuner *)homeRunTuner:(NSInteger)lTunerId onUnit:(HDHomeRunUnit *)lUnit {
	return [[[HDHomeRunTuner alloc] initWithTuner:lTunerId onUnit:lUnit] autorelease];
}
- (id)initWithTuner:(NSInteger)lTunerId onUnit:(HDHomeRunUnit *)lUnit {
	self = [super init];
	if (self != nil) {
		[self setChannelAddresses:[NSArray array]];
		
		unit = lUnit; // No retain (not owner)
		
		tunerId = lTunerId;

		currentReceiverTask = nil;
		lastChannelAddress = nil;
		lastVideoStatistic = nil;
    
    
    // Create device (tuner) handler
    handler = hdhomerun_device_create([lUnit unitId], 0, lTunerId, NULL);
    if (!handler) {
      NSLog(@"Invalid device id: %d", [lUnit unitId]);
      hdhomerun_device_destroy(handler);
			handler = nil;
    }
    
    // Device ID check
    uint32_t device_id_requested = hdhomerun_device_get_device_id_requested(handler);
    if (!hdhomerun_discover_validate_device_id(device_id_requested)) {
      NSLog(@"Device id of found device not equal: %d != %d", [lUnit unitId], device_id_requested);
      hdhomerun_device_destroy(handler);
			handler = nil;
    }
    
    // Connect to device and check model.
    const char *model = hdhomerun_device_get_model_str(handler);
    if (!model) {
      NSLog(@"Unable to connect to device: %d", [lUnit unitId]);
      hdhomerun_device_destroy(handler);
			handler = nil;
    }
    
    // Set handler to tuner
    if (hdhomerun_device_set_tuner(handler, lTunerId) <= 0) {
      NSLog(@"Invalid tuner number: %d", lTunerId);
      hdhomerun_device_destroy(handler);
			handler = nil;
    }
    
	}
	return self;
}
- (void)dealloc {
	[self cancelData]; // Cancel any data
	
	unit = nil;

	[description release];
	[channelAddresses release];
	[currentReceiverTask release];
	[lastChannelAddress release];
	[lastVideoStatistic release];
  
  if (handler != nil) hdhomerun_device_destroy(handler);
  
	[super dealloc];
}



- (NSString *)description {
	if ((description == nil) || ([description isEqualToString:@""])) {
		if ([self tunerId] != -1) {
			return [NSString stringWithFormat:@"%d", [self tunerId]];
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






- (BOOL)isConnected {
	return (handler != nil);
}


- (BOOL)lock {
	char *ret_error;
	if (hdhomerun_device_tuner_lockkey_request(handler, &ret_error) <= 0) {
		if (ret_error) {
      NSLog(@"Failed to lock tuner: %s", ret_error);
		} else {
      NSLog(@"Failed to lock tuner: Unknown");
    }
		return NO;
	} else {
    return YES;
  }
}

- (BOOL)unlock {
  hdhomerun_device_tuner_lockkey_release(handler);
  return YES;
}


- (NSString *)value:(NSString *)identifier {
  char *ret_value;
  char *ret_error;
  
  if (hdhomerun_device_get_var(handler, [identifier cStringUsingEncoding:NSASCIIStringEncoding], &ret_value, &ret_error) < 0) {
    NSLog(@"Communication error sending request to hdhomerun device.");
  } else {
    if (ret_error) {
      NSLog(@"Error:%s", ret_error);
    } else {
      return [NSString stringWithFormat:@"%s", ret_value];
    }
  }
  
  return nil;
}
- (void)setValue:(NSString *)identifier WithData:(NSString *)data {
  char *ret_error;
  
  if (hdhomerun_device_set_var(handler, [identifier cStringUsingEncoding:NSASCIIStringEncoding], [data cStringUsingEncoding:NSASCIIStringEncoding], NULL, &ret_error) < 0) {
    NSLog(@"Communication error sending request to hdhomerun device.");
  } else {
    if (ret_error) {
      NSLog(@"Error:%s", ret_error);
    }
  }
}


- (NSString*)tunerValue:(NSString *)identifier {
  return [self value:[NSString stringWithFormat:@"/tuner%d/%@", [self tunerId], identifier]];
}
- (void)setTunerValue:(NSString *)identifier WithData:(NSString *)data {
  [self setValue:[NSString stringWithFormat:@"/tuner%d/%@", [self tunerId], identifier] WithData:data];
}


- (NSString *)channel {
	return [self tunerValue:@"channel"];
}
- (void)setChannelWithModulation:(NSString *)modulation AndFrequency:(NSUInteger)frequency {
	[self setTunerValue:@"channel" WithData:[NSString stringWithFormat:@"%@:%d", modulation, frequency]];
}
- (void)setChannelWithFrequency:(NSUInteger)frequency {
	[self setTunerValue:@"channel" WithData:[NSString stringWithFormat:@"auto:%d", frequency]];
}
- (void)clearChannel {
	[self setTunerValue:@"channel" WithData:@"none"];
}

- (ChannelMap)channelMap {
	return [HDHomeRunControl stringToChannelMap:[self tunerValue:@"channelmap"]];
}
- (void)setChannelMap:(ChannelMap)map {
	[self setChannelMapByString:[HDHomeRunControl channelMapToString:map]];
}
- (void)setChannelMapByString:(NSString *)map {
	[self setTunerValue:@"channelmap" WithData:map];
}

- (NSString *)getFilter {
	return [self tunerValue:@"filter"];
}
- (void)setFilter:(NSString *)filter {
	[self setTunerValue:@"filter" WithData:filter];
}
- (void)setFilterFrom:(NSUInteger)from AndFrequency:(NSUInteger)to {
	[self setTunerValue:@"filter" WithData:[NSString stringWithFormat:@"0x%04x-0x%04x", from, to]];
}

- (NSString *)program {
	return [self tunerValue:@"program"];
}
- (void)setProgram:(NSUInteger)prg {
	[self setTunerValue:@"program" WithData:[NSString stringWithFormat:@"%u", prg]];
}
- (void)setProgramWithMajor:(NSUInteger)major AndMinor:(NSUInteger)minor {
	[self setTunerValue:@"program" WithData:[NSString stringWithFormat:@"%u.%u", major, minor]];
}


- (NSString *)target {
	return [self tunerValue:@"target"];
}
- (void)setTargetIp:(NSString *)ip AndPort:(NSString *)port {
	[self setTunerValue:@"target" WithData:[NSString stringWithFormat:@"%@:%@", ip, port]];
}
- (void)setTarget:(NSString *)ltarget {
	[self setTunerValue:@"target" WithData:ltarget];
}
- (void)clearTarget {
  return [self setTarget:@"none"];
}


- (NSString *)channelGroup {
  const char *channelmap = [[HDHomeRunControl channelMapToString:[self channelMap]] cStringUsingEncoding:NSASCIIStringEncoding];
	const char *channelmap_scan_group = hdhomerun_channelmap_get_channelmap_scan_group(channelmap);
	if (!channelmap_scan_group) {
    NSLog(@"Failed to use channelmap to query channel group.");
    return nil;
	} else {
    return [NSString stringWithFormat:@"%s", channelmap_scan_group];
  }
}


- (NSString *)status {
	return [self tunerValue:@"status"];
}
- (NSString *)streamInfo {
	return [self tunerValue:@"streaminfo"];
}
- (NSString *)debugInfo {
	return [self tunerValue:@"debug"];
}

- (void)tuneToChannelAddress:(HDChannelAddress *)address {
  
  [self setChannelMap:[address channelMap]];
  [self setChannelWithFrequency:[address frequency]];
  [self setProgram:[address programNo]];

  [lastChannelAddress release];
  [self willChangeValueForKey:@"lastChannelAddress"];
  lastChannelAddress = [[address copy] retain];
  [self didChangeValueForKey:@"lastChannelAddress"];
}
- (void)clearTune {
  [self clearChannel];
}


- (BOOL)startStream {
	currentReceiverTask = [[[NSTask alloc] init] retain];
	return YES;
}

- (BOOL)saveDataTo:(NSString *)filename {
//	if (currentReceiverTask != nil) {
//		return NO;
//	}
//	
//	NSArray *args = [NSArray arrayWithObjects:@"hdhomerun_config", [NSString stringWithFormat:@"%d", [[self unit] unitId]], @"save", [NSString stringWithFormat:@"/tuner%d", [[self tunerId] intValue]], filename, nil];
//
//	NSTask *task = [[[NSTask alloc] init] retain];
//
//	[self willChangeValueForKey:@"currentReceiverTask"];
//	[self willChangeValueForKey:@"isReceiving"];
//	currentReceiverTask = task;
//	[self didChangeValueForKey:@"isReceiving"];
//	[self didChangeValueForKey:@"currentReceiverTask"];
//	
//	[task setLaunchPath:@"/usr/bin/env"];
//	[task setArguments:args];
//	
//	NSPipe *inputPipe = [NSPipe pipe];
//	[task setStandardOutput:inputPipe];
//	
//	NSFileHandle *fileHandle = [inputPipe fileHandleForReading];
//
//	[task launch];
//	[task waitUntilExit];
//	
//	NSString *incomingData = [[[NSString alloc] initWithData:[fileHandle availableData] encoding:NSASCIIStringEncoding] autorelease];
//
//	int status = [task terminationStatus];
//	
//	[self willChangeValueForKey:@"currentReceiverTask"];
//	[self willChangeValueForKey:@"isReceiving"];
//	currentReceiverTask = nil;
//	[self didChangeValueForKey:@"isReceiving"];
//	[self didChangeValueForKey:@"currentReceiverTask"];
//
//	[task release];
//
//	// Parse statistic
//	[lastVideoStatistic release];
//	[self willChangeValueForKey:@"lastVideoStatistic"];
//	lastVideoStatistic = [HDVideoStatistic videoStatisticWithString:incomingData];
//	[self didChangeValueForKey:@"lastVideoStatistic"];
//
//	return (status == 0);
  return YES;
}
- (BOOL)cancelData {
	if (currentReceiverTask != nil) {
		if ([currentReceiverTask isRunning]) {
			[currentReceiverTask terminate];
		}
		[self willChangeValueForKey:@"currentReceiverTask"];
		[self willChangeValueForKey:@"isReceiving"];
		currentReceiverTask = nil;
		[self didChangeValueForKey:@"isReceiving"];
		[self didChangeValueForKey:@"currentReceiverTask"];
		return YES;
	} else {
		return NO;
	}
}
- (BOOL)isReceiving {
	if (currentReceiverTask != nil) {
		return YES;
		return ([currentReceiverTask isRunning]);
	} else {
		return NO;
	}
}

- (BOOL)scanWithFilter:(NSInteger)filter {
  
  BOOL resultBool = YES;
  NSMutableArray *channelAddressList = [NSMutableArray array];
  
  if ([self lock]) {
    [self clearTarget];
      
    HDChannelAddress *channelAddress = [HDChannelAddress channelAddressWithTuner:self];
    
    const char* channelGroup = [[self channelGroup] cStringUsingEncoding:NSASCIIStringEncoding];
    if (hdhomerun_device_channelscan_init(handler, channelGroup) <= 0) {
      NSLog(@"Failed to initialize scan.");
      resultBool = NO;
      
    } else {
      
      int ret = 0;
      ChannelMap currChannelMap = [self channelMap];
      
      while (true) {
        struct hdhomerun_channelscan_result_t result;
        
        ret = hdhomerun_device_channelscan_advance(handler, &result);
        if (ret <= 0) break;
        
        NSLog(@"Scanning %lu (%s)", (unsigned long)result.frequency, result.channel_str);
        
        ret = hdhomerun_device_channelscan_detect(handler, &result);
        if (ret <= 0) break;
        
        NSLog(@"Lock %s (ss=%u snq=%u seq=%u)", result.status.lock_str, result.status.signal_strength, result.status.signal_to_noise_quality, result.status.symbol_error_quality);
        
        if (result.transport_stream_id_detected) NSLog(@"Transport Stream ID %u", result.transport_stream_id);
        
        int i;
        for (i = 0; i < result.program_count; i++) {
          struct hdhomerun_channelscan_program_t *program = &result.programs[i];
          NSLog(@"Program %s",program->program_str);
          
          [channelAddress setProgramNo:(NSUInteger)program->program_number];
          [channelAddress setProgramCode:[NSString stringWithFormat:@"%u.%u", program->virtual_major, program->virtual_minor]];
          [channelAddress setProgramName:[NSString stringWithFormat:@"%s", program->name]];
          
          if (program->type == HDHOMERUN_CHANNELSCAN_PROGRAM_NORMAL) {
            [channelAddress setChannelType:kHDFreeToAir];
            
          } else if (program->type == HDHOMERUN_CHANNELSCAN_PROGRAM_CONTROL) {
            [channelAddress setChannelType:kHDControlData];
            
          } else if (program->type == HDHOMERUN_CHANNELSCAN_PROGRAM_ENCRYPTED) {
            [channelAddress setChannelType:kHDEncrypted];
            
          } else {
            [channelAddress setChannelType:kHDUnknown];
          }
          
          [channelAddress setModulation:[NSString stringWithFormat:@"%s", result.status.lock_str]];
          [channelAddress setFrequency:(NSUInteger)result.frequency];
          [channelAddress setChannelMap:currChannelMap];
          
          [channelAddressList addObject:[channelAddress copy]]; // Get a copy of current address
          [channelAddress newUniqueId]; // Generate a new unique id for next address
        }
      }
      
      if (ret < 0) {
        NSLog(@"Communication error sending request to hdhomerun device.");
        resultBool = NO;
      }
    }
    
    [self unlock];
  }
  
	[self setChannelAddresses:channelAddressList];
  
  return resultBool;
}



- (NSString *)parseStatus:(NSString *)status FromGroup:(NSString *)group WithValue:(NSString *)value {
	NSScanner *scanner = [NSScanner scannerWithString:status];
	
	NSString *temp;
	NSString *result;
	
	[scanner scanUpToString:[NSString stringWithFormat:@"%@:", group] intoString:&temp];
	[scanner scanUpToString:[NSString stringWithFormat:@"%@=", value] intoString:&temp];
	[scanner scanString:[NSString stringWithFormat:@"%@=", value] intoString:&temp];
	[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&result];
	
	return result;
}

- (NSDictionary *)detailedStatus {
	NSString *statusText = [self debugInfo];
	
	NSMutableDictionary *dict;
	NSMutableDictionary *innerDict;
	
	innerDict = [NSMutableDictionary dictionary];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"tun" WithValue:@"ch"] forKey:@"channel"];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"tun" WithValue:@"lock"] forKey:@"modulation"];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"tun" WithValue:@"ss"] forKey:@"signal strength"];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"tun" WithValue:@"snq"] forKey:@"signal to noise quality"];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"tun" WithValue:@"seq"] forKey:@"symbol error quality"];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"tun" WithValue:@"dbg"] forKey:@"dbg"];
	[dict setObject:innerDict forKey:@"tuner"];
	
	innerDict = [NSMutableDictionary dictionary];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"dev" WithValue:@"resync"] forKey:@"resync"];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"dev" WithValue:@"overflow"] forKey:@"overflow"];
	[dict setObject:innerDict forKey:@"device"];
	
	innerDict = [NSMutableDictionary dictionary];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"ts" WithValue:@"bps"] forKey:@"bits per second"];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"ts" WithValue:@"ut"] forKey:@"utilization percentage"];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"ts" WithValue:@"te"] forKey:@"transport error counter"];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"ts" WithValue:@"miss"] forKey:@"missed packet counter"];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"ts" WithValue:@"crc"] forKey:@"crc error counter"];
	[dict setObject:innerDict forKey:@"transport stream"];
	
	innerDict = [NSMutableDictionary dictionary];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"flt" WithValue:@"bps"] forKey:@"bits per second"];
	[dict setObject:innerDict forKey:@"filter"];
	
	innerDict = [NSMutableDictionary dictionary];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"net" WithValue:@"pps"] forKey:@"packets per second"];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"net" WithValue:@"err"] forKey:@"dropped frames"];
	[innerDict setObject:[self parseStatus:statusText FromGroup:@"net" WithValue:@"stop"] forKey:@"reason for stopping"];
	[dict setObject:innerDict forKey:@"network"];
	
	return (NSDictionary *)dict;
}

@end