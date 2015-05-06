//
//  Channel.m
//  GaiaTV
//
//  Created by marcel on 10/29/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import "Channel.h"

#import "HDChannelAddress.h"
#import "HDHomeRunTuner.h"
#import "HDHomeRunUnit.h"

#import "Services.h";


@implementation Channel

@synthesize activated;
@synthesize channelAddresses;
@synthesize channelNo;

- (NSString *)description {
	if ((description == nil) || ([description isEqualToString:@""])) {
		if ([self channelNo] == -1) {
			return @"[unknown]";
		} else {
			return [NSString stringWithFormat:@"%d", [self channelNo]];
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


+ (Channel *)channelWithChannel:(NSInteger)lNumber {
	return [[[Channel alloc] initWithChannel:lNumber] autorelease];
}
- (id)initWithChannel:(NSInteger)lNumber {
	self = [super init];
	if (self != nil) {
		[self setActivated:YES];
		channelNo = lNumber;
		channelAddresses = [[NSArray array] retain];
		[self setDescription:[NSString string]];
		
		[self activateObserving];
	}
	return self;
}
- (id)init {
	return [self initWithChannel:[[Services sharedServices] getNewChannelNumberFrom:1 positive:YES]];
}
- (void)dealloc {
	[self deactivateObserving];
	
	[description release];
	[channelAddresses release];
	
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self != nil) {
		[self setActivated:[coder decodeBoolForKey:@"activated"]];
		[self setDescription:[coder decodeObjectForKey:@"description"]];
		channelNo = [coder decodeIntForKey:@"channelNo"];
		channelAddresses = [[NSArray array] retain];

		NSArray *addressList = [[coder decodeObjectForKey:@"addresses"] retain];
		NSMutableArray *tempArray;

		Services *services = [Services sharedServices];
		if (services != nil) {
			NSArray *availableChannelAddresses = [services channelAddressesFromTuner];

			NSEnumerator *addressEnum = [addressList objectEnumerator];
			NSString *currentAddressId;
			while(currentAddressId = [addressEnum nextObject]) {
				NSEnumerator *availableChannelAddressesEnum = [availableChannelAddresses objectEnumerator];
				HDChannelAddress *availableChannelAddress;
				while(availableChannelAddress = [availableChannelAddressesEnum nextObject]) {
					if ([[availableChannelAddress uniqueId] isEqualToString:currentAddressId]) {
						tempArray = [[self channelAddresses] mutableCopy];
						[tempArray addObject:availableChannelAddress];
						[self setChannelAddresses:tempArray];
						break;
					}
				}
			}
		}		
		
		[self activateObserving];
	}
	return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeBool:[self activated] forKey:@"activated"];
	[coder encodeObject:[self description] forKey:@"description"];
	[coder encodeInt:[self channelNo] forKey:@"channelNo"];
	
	NSMutableArray *addressList = [NSMutableArray array];
	NSEnumerator *addressEnum = [[self channelAddresses] objectEnumerator];
	HDChannelAddress *currentAddress;
	while(currentAddress = [addressEnum nextObject]) {
		[addressList addObject:[currentAddress uniqueId]];
	}
	[coder encodeObject:addressList forKey:@"addresses"];
}
- (id)copyWithZone:(NSZone *)zone {
    Channel *copy = [[self class] allocWithZone: zone];
	
	[copy initWithChannel:[self channelNo]];
	
	[copy setActivated:[self activated]];
	[copy setChannelAddresses:[self channelAddresses]];	
	[copy setDescription:[self description]];

    return copy;
}

- (void)activateObserving {
	[self addObserver:self forKeyPath:@"channelAddresses" options:NSKeyValueObservingOptionNew context:NULL];
}
- (void)deactivateObserving {
	[self removeObserver:self forKeyPath:@"channelAddresses"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"channelAddresses"]) {
		[[Services sharedServices] informationUpdated];
    }
}

- (BOOL)isValid {
	BOOL result = YES;
	
	NSEnumerator *addressEnum = [[self channelAddresses] objectEnumerator];
	HDChannelAddress *currentAddress;
	NSMutableArray *response = [NSMutableArray array];
	while(currentAddress = [addressEnum nextObject]) {
		result = result && [currentAddress isValidWithResponse:response];
	}

	// Write response messages
	NSEnumerator *responseEnum = [response objectEnumerator];
	NSString *responseText;
	while(responseText = [responseEnum nextObject]) {
		[Services globalMessage:responseText];
	}
	
	
	if ([self channelNo] == -1) {
		[Services globalMessage:[NSString stringWithFormat:@"Channel number for channel %@ is unknown.", self]];
		result = NO;
	}
	
	Services *services = [Services sharedServices];
	if (services != nil) {
		NSArray *tunerChannelAddresses = [services channelAddressesFromTuner];
		BOOL found;
		
		NSEnumerator *channelChannelAddressesEnum = [[self channelAddresses]  objectEnumerator];
		HDChannelAddress *channelChannelAddress;
		while(channelChannelAddress = [channelChannelAddressesEnum nextObject]) {
			found = NO;
			
			NSEnumerator *tunerChannelAddressesEnum = [tunerChannelAddresses objectEnumerator];
			HDChannelAddress *tunerChannelAddress;
			while(tunerChannelAddress = [tunerChannelAddressesEnum nextObject]) {
				if (tunerChannelAddress == channelChannelAddress) {
					found = YES;
				}
			}
			
			if (!found) {
				[Services globalMessage:[NSString stringWithFormat:@"Channel address %@ is not in tuner list.", tunerChannelAddress]];
				result = NO;
			}
		}
	}
	
	return result;
}
- (BOOL)repair:(BOOL)force {
	Services *services = [Services sharedServices];

	if ([self channelNo] == -1) {
		if (services == nil) {
			return NO;
		} else {
			[self setChannelNo:[services getNewChannelNumberFrom:1 positive:YES]];
		}
	}

	if (services != nil) {
		NSArray *tunerChannelAddresses = [services channelAddressesFromTuner];
		NSMutableArray *removeList = [NSMutableArray array];
		BOOL found;
		
		NSEnumerator *channelChannelAddressesEnum = [[self channelAddresses]  objectEnumerator];
		HDChannelAddress *channelChannelAddress;
		while(channelChannelAddress = [channelChannelAddressesEnum nextObject]) {
			found = NO;
			
			NSEnumerator *tunerChannelAddressesEnum = [tunerChannelAddresses objectEnumerator];
			HDChannelAddress *tunerChannelAddress;
			while(tunerChannelAddress = [tunerChannelAddressesEnum nextObject]) {
				if (tunerChannelAddress == channelChannelAddress) {
					found = YES;
				}
			}
			
			if (!found) {
				[removeList addObject:channelChannelAddress];
			}
		}
		
		[services removeChannelAddresses:removeList];
	}
	
	return YES;
}

- (HDChannelAddress *)getFirstChannelAddressForTuner:(HDHomeRunTuner *)lTuner {
	NSEnumerator *adressEnum = [[self channelAddresses] objectEnumerator];
	HDChannelAddress *currentAddress;
	while(currentAddress = [adressEnum nextObject]) {
		if ([currentAddress tuner] == lTuner) {
			return currentAddress;
		}
	}
	return nil;
}

- (BOOL)tuneOnTuner:(HDHomeRunTuner *)lTuner {
	HDChannelAddress *channelAddress = [self getFirstChannelAddressForTuner:lTuner];
	
	if (channelAddress == nil) {
		return NO;
		
	} else {
		return ([self tuneToChannelAddress:channelAddress] != nil);
	}
}
- (HDHomeRunTuner *)tuneToChannelAddress:(HDChannelAddress *)address {
	if (address == nil) {
		[Services globalMessage:@"Channel address is unknown."];
		return nil;
		
	} else {
		if ([address tuner] == nil) {
			[Services globalMessage:[NSString stringWithFormat:@"Tuner for address %@ is unknown.", address]];
			return nil;
			
		} else {
			if ([[address tuner] unit] == nil) {
				[Services globalMessage:[NSString stringWithFormat:@"Unit for address %@ is unknown.", address]];
				return nil;
				
			} else {
				if ([[[address tuner] unit] unitId] == -1) {
					[Services globalMessage:[NSString stringWithFormat:@"Unit-id for address %@ is unknown.", address]];
					return nil;
					
				} else {
					if ([[address tuner] isReceiving]) {
						if ([[address tuner] lastChannelAddress] == nil) {
							[Services globalMessage:[NSString stringWithFormat:@"Tuner %d on unit %@ is already receiving from null address.", [address tuner], [[address tuner] unit]]];
						} else {
							[Services globalMessage:[NSString stringWithFormat:@"Tuner %d on unit %@ is already receiving for address %@.", [address tuner], [[address tuner] unit], [[address tuner] lastChannelAddress]]];
						}
						return nil;
						
					} else { // Not receiving
						[[address tuner] cancelData];
						BOOL result =  [[address tuner] isReceiving];
            
            [[address tuner] tuneToChannelAddress:address];
						[[address tuner] startStream];
            
						if (result == NO) {
							[Services globalMessage:[NSString stringWithFormat:@"Tuner %d on unit %@ is already receiving for address %@.", [address tuner], [[address tuner] unit], [[address tuner] lastChannelAddress]]];
						}
						
						return [address tuner];						
					}
				}
			}
		}
	}
}

- (NSColor *)color {
	if ([self activated]) {
		return [NSColor greenColor];
	} else {
		return [NSColor redColor];
	}
}

@end
