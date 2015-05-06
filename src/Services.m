//
//  Services.m
//  GaiaTV
//
//  Created by marcel on 11/4/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import "Services.h"

#import "HDHomeRun.h"
#import "HDHomeRunUnit.h"
#import "HDHomeRunTuner.h"
#import "HDChannelAddress.h"

#import "Channel.h"
#import "Bouquet.h"


static Services *sharedServices = nil;

@implementation Services

+ (Services *)sharedServices {
	return sharedServices;
}
+ (void)setSharedServices:(Services *)value {
	if (value != sharedServices) {
		[value retain];
		[sharedServices release];
		[self willChangeValueForKey:@"sharedServices"];
		sharedServices = value;
		[self didChangeValueForKey:@"sharedServices"];
	}
}

+ (void)globalMessage:(NSString *)message {
	NSLog([NSString stringWithFormat:@"MESSAGE:%@", message]);
}


@synthesize bouquets;

- (NSString *)description {
	
	NSString *lBouquets = (([self bouquets] == nil) ? @"[unknown]" : [NSString stringWithFormat:@"%d", [[self bouquets] count]]);
	
	return [NSString stringWithFormat:@"Bouquets:%@", lBouquets];
}

- (void)informationUpdated {
	[self willChangeValueForKey:@"channels"];
	[self didChangeValueForKey:@"channels"];
	
	[self willChangeValueForKey:@"channelAddressesFromTuner"];
	[self didChangeValueForKey:@"channelAddressesFromTuner"];
	
	[self willChangeValueForKey:@"channelAddressesFromChannels"];
	[self didChangeValueForKey:@"channelAddressesFromChannels"];
}

- (NSArray *)channels {
	NSMutableArray *newList = [NSMutableArray array];
	
	NSEnumerator *bouquetsEnum = [bouquets objectEnumerator];
	Bouquet *bouquet;	
	while(bouquet = [bouquetsEnum nextObject]) {
		[newList addObjectsFromArray:[bouquet channels]];
	}
	
	return newList;
}
- (NSArray *)channelAddressesFromTuner {

	NSMutableArray *newList = [NSMutableArray array];
	
	NSEnumerator *unitsEnum = [[HDHomeRunControl sharedUnits] objectEnumerator];
	HDHomeRunUnit *unit;

	while(unit = [unitsEnum nextObject]) {
		
		NSEnumerator *tunerEnum = [[unit tuner] objectEnumerator];
		HDHomeRunTuner *tuner;
		
		while(tuner = [tunerEnum nextObject]) {
			[newList addObjectsFromArray:[tuner channelAddresses]];
		}		
	}
	
	return newList;
}
- (NSArray *)channelAddressesFromChannels {
	
	NSMutableArray *newList = [NSMutableArray array];
	
	NSEnumerator *bouquetsEnum = [[self bouquets] objectEnumerator];
	Bouquet *bouquet;
	
	while(bouquet = [bouquetsEnum nextObject]) {
		
		NSEnumerator *channelEnum = [[bouquet channels] objectEnumerator];
		Channel *channel;
		
		while(channel = [channelEnum nextObject]) {
			[newList addObjectsFromArray:[channel channelAddresses]];
		}		
	}
	
	return newList;
}


+ (Services *)services {
	return [[[Services alloc] init] autorelease];
}
- (id)init {
	self = [super init];
	if (self != nil) {
		[Services setSharedServices:self];
		[self setBouquets:[NSArray array]];
		
		[self activateObserving];
	}
	return self;
}
- (void)dealloc {
	[self deactivateObserving];

	[bouquets release];
	
	[super dealloc];
}

- (void)activateObserving {
	[self addObserver:self forKeyPath:@"bouquets" options:NSKeyValueObservingOptionNew context:NULL];
}
- (void)deactivateObserving {
	[self removeObserver:self forKeyPath:@"bouquets"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"bouquets"]) {
		[[Services sharedServices] informationUpdated];
    }
}

- (BOOL)loadFromDisk {
	NSDictionary * rootObject;
	NSFileManager *fm = [NSFileManager defaultManager];
	
	NSMutableArray *tempArray;
	
	// Channel addresses
	NSString *channelAddressesFile = [NSString stringWithFormat:@"%@/ChannelAddresses.plist", [[NSBundle mainBundle] resourcePath]];
	if ([fm fileExistsAtPath:channelAddressesFile]) {
		rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:channelAddressesFile];
		if (rootObject == nil) {
			[Services globalMessage:@"Could not load channel-address-list from GaiaTV bundle."];
			return NO;
		} else {
			NSArray *loadedChannelAddresses = [rootObject valueForKey:@"channelAddresses"];
			
			NSEnumerator *unitsEnum = [[HDHomeRunControl sharedUnits] objectEnumerator];
			HDHomeRunUnit *unit;
			while(unit = [unitsEnum nextObject]) {
				NSEnumerator *tunerEnum = [[unit tuner] objectEnumerator];
				HDHomeRunTuner *tuner;
				while(tuner = [tunerEnum nextObject]) {
					NSEnumerator *channelAddressEnum = [loadedChannelAddresses objectEnumerator];
					HDChannelAddress *channelAddress;
					while(channelAddress = [channelAddressEnum nextObject]) {
						if ([channelAddress tuner] == tuner) {
							if (![[tuner channelAddresses] containsObject:channelAddress]) {
								tempArray = [[tuner channelAddresses] mutableCopy];
								[tempArray addObject:channelAddress];
								[tuner setChannelAddresses:tempArray];
							}
						}
					}
				}
			}
		}
	} else {
		[Services globalMessage:@"Could not find channel-address-list in GaiaTV bundle."];
		return NO;
	}

	// Bouquets
	NSString *bouquetsFolder = [NSString stringWithFormat:@"%@/.GaiaTV", NSHomeDirectory()];
	BOOL isDir = YES;
	if ([fm fileExistsAtPath:bouquetsFolder isDirectory:&isDir]) {

		NSString *bouquetsFile = [NSString stringWithFormat:@"%@/Bouquets.plist", bouquetsFolder];
		if ([fm fileExistsAtPath:bouquetsFile]) {
			rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:bouquetsFile];
			if (rootObject == nil) {
				[Services globalMessage:@"Could not load bouquets-list in private GaiaTV folder."];
				return NO;
			} else {
				[self setBouquets:[rootObject valueForKey:@"bouquets"]];

				// Load descriptions
				NSEnumerator *units1Enum = [[rootObject valueForKey:@"units"] objectEnumerator];
				NSMutableDictionary *unit1;
				while(unit1 = [units1Enum nextObject]) {
					NSString *unitDesc = [unit1 valueForKey:@"description"];
					NSNumber *unitId = [unit1 valueForKey:@"unitId"];
					
					NSEnumerator *tuner1Enum = [[unit1 valueForKey:@"tuner"] objectEnumerator];
					NSMutableDictionary *tuner1;
					while(tuner1 = [tuner1Enum nextObject]) {
						NSString *tunerDesc = [tuner1 valueForKey:@"description"];
						NSNumber *tunerId = [tuner1 valueForKey:@"tunerId"];
						
						NSEnumerator *units2Enum = [[HDHomeRunControl sharedUnits] objectEnumerator];
						HDHomeRunUnit *unit2;
						while(unit2 = [units2Enum nextObject]) {
							
							if ([unit2 unitId] == [unitId intValue]) {
								[unit2 setDescription:unitDesc];
							}

							NSEnumerator *tuner2Enum = [[unit2 tuner] objectEnumerator];
							HDHomeRunTuner *tuner2;
							while(tuner2 = [tuner2Enum nextObject]) {
								
								if ([tuner2 tunerId]  == [tunerId intValue]) {
									[tuner2 setDescription:tunerDesc];
								}
							}
						}
					}
				}
			}
		} else {
			[Services globalMessage:@"Could not find bouquets-list in private GaiaTV folder."];
			return NO;
		}
	} else {
		[Services globalMessage:@"Could not find private GaiaTV folder."];
		return NO;
	}
	
	return YES;
}
- (BOOL)saveToDisk {
	NSMutableDictionary *rootObject;
	NSFileManager *fm = [NSFileManager defaultManager];
    
	NSString *channelAddressesFile = [NSString stringWithFormat:@"%@/ChannelAddresses.plist", [[NSBundle mainBundle] resourcePath]];
	rootObject = [NSMutableDictionary dictionary];
	[rootObject setValue:[self channelAddressesFromTuner] forKey:@"channelAddresses"];
	if (![NSKeyedArchiver archiveRootObject: rootObject toFile:channelAddressesFile]) {
		[Services globalMessage:@"Could not save channel addresses to GaiaTV bundle."];
		return NO;
	}

	NSString *bouquetsFolder = [NSString stringWithFormat:@"%@/.GaiaTV", NSHomeDirectory()];
	BOOL isDir = YES;
	if (![fm fileExistsAtPath:bouquetsFolder isDirectory:&isDir]) {
		if (![fm createDirectoryAtPath:bouquetsFolder attributes:nil]) {
			[Services globalMessage:@"Could not create private GaiaTV folder."];
			return NO;
		}
	}
	NSString *bouquetsFile = [NSString stringWithFormat:@"%@/Bouquets.plist", bouquetsFolder];
	rootObject = [NSMutableDictionary dictionary];
	[rootObject setValue:[self bouquets] forKey:@"bouquets"];

	
	NSMutableArray *unitEntry = [NSMutableArray array];
	
	NSEnumerator *unitsEnum = [[HDHomeRunControl sharedUnits] objectEnumerator];
	HDHomeRunUnit *unit;
	while(unit = [unitsEnum nextObject]) {
		NSMutableArray *tunerEntry = [NSMutableArray array];
		
		NSEnumerator *tunerEnum = [[unit tuner] objectEnumerator];
		HDHomeRunTuner *tuner;
		while(tuner = [tunerEnum nextObject]) {
			NSMutableDictionary *newTuner = [NSMutableDictionary dictionary];
			[newTuner setValue:[tuner description] forKey:@"description"];
			[newTuner setValue:[NSNumber numberWithInt:[tuner tunerId]] forKey:@"tunerId"];
			
			[tunerEntry addObject:newTuner];
		}
		
		NSMutableDictionary *newUnit = [NSMutableDictionary dictionary];
		[newUnit setValue:tunerEntry forKey:@"tuner"];
		[newUnit setValue:[unit description] forKey:@"description"];
		[newUnit setValue:[NSNumber numberWithInt:[unit unitId]] forKey:@"unitId"];
		
		[unitEntry addObject:newUnit];
	}
	[rootObject setValue:unitEntry forKey:@"units"];	
	
	if (![NSKeyedArchiver archiveRootObject: rootObject toFile:bouquetsFile]) {
		[Services globalMessage:@"Could not save bouquets to private GaiaTV folder."];
		return NO;
	}
	
	return YES;
}

- (BOOL)isValid {
	BOOL result = YES;
	
	// Validate all bouquets
	NSEnumerator *bouquetsEnum = [[self bouquets] objectEnumerator];
	Bouquet *currentBouquet;
	while(currentBouquet = [bouquetsEnum nextObject]) {
		result = result && [currentBouquet isValid];
	}
	
	// Get all channel addresses
	NSArray *localChannelAddresses = [self channelAddressesFromTuner];

	// Validate the unique ids
	NSEnumerator *address1Enum = [localChannelAddresses objectEnumerator];
	HDChannelAddress *address1;
	while(address1 = [address1Enum nextObject]) {
		NSEnumerator *address2Enum = [localChannelAddresses objectEnumerator];
		HDChannelAddress *address2;
		while(address2 = [address2Enum nextObject]) {
			if ((address1 != address2) && ([[address1 uniqueId] isEqualToString:[address2 uniqueId]])) {
				[Services globalMessage:[NSString stringWithFormat:@"Channel address is not unique with address %@.", address1]];
				result = NO;
			}
		}
	}
		
	return result;
}
- (BOOL)repair:(BOOL)force {
	BOOL result = YES;
	
	NSMutableArray *tempArray;
	
	// Validate all bouquets
	NSEnumerator *bouquetsEnum = [[self bouquets] objectEnumerator];
	Bouquet *currentBouquet;
	while(currentBouquet = [bouquetsEnum nextObject]) {
		if (![currentBouquet repair:force]) {
			if (force) {
				tempArray = [[self bouquets] mutableCopy];
				[tempArray removeObject:currentBouquet];
				[self setBouquets:tempArray];
			} else {
				result = NO;
			}
		}
	}
	
	// Get all channel addresses
	NSArray *localChannelAddresses = [self channelAddressesFromTuner];
	
	// Validate the unique ids
	NSEnumerator *address1Enum = [localChannelAddresses objectEnumerator];
	HDChannelAddress *address1;
	while(address1 = [address1Enum nextObject]) {
		NSEnumerator *address2Enum = [localChannelAddresses objectEnumerator];
		HDChannelAddress *address2;
		while(address2 = [address2Enum nextObject]) {
			if ((address1 != address2) && ([[address1 uniqueId] isEqualToString:[address2 uniqueId]])) {
				if (force) {
					[self removeChannelAddresses:[NSArray arrayWithObjects:address2, nil]];
					break;
				} else {
					result = NO;
				}
			}
		}
	}

	return result;
}
								   
- (BOOL)cleanup {
	[Services globalMessage:@"Starting Cleanup"];
	
	[Services globalMessage:@"Data validation..."];
	if (![self isValid]) {
		[Services globalMessage:@"Data is not valid; repairing..."];
		[self repair:YES];
		[Services globalMessage:@"Repaired"];
		
		[Services globalMessage:@"Data validation..."];
		if (![self isValid]) {
			[Services globalMessage:@"Data is not valid; cancel cleanuo"];
			return NO;
		}
	}
	[Services globalMessage:@"Data is valid"];
	return YES;
}

- (Bouquet *)getDefaultBouquet {
	NSEnumerator *bouquetsEnum = [[self bouquets] objectEnumerator];
	Bouquet *currentBouquet;
	
	NSMutableArray *tempArray;
	
	// Search in existing bouquets
	while(currentBouquet = [bouquetsEnum nextObject]) {
		if ([[currentBouquet description] isEqualToString:@"Default"]) {
			return currentBouquet;
		}
	}

	// Add a new Bouquets
	currentBouquet = [Bouquet bouquetListWithDescription:@"Default"];
	[self willChangeValueForKey:@"bouquets"];
	
	tempArray = [[self bouquets] mutableCopy];
	[tempArray addObject:currentBouquet];
	[self setBouquets:tempArray];
	[self didChangeValueForKey:@"bouquets"];
	
	return currentBouquet;
}

- (NSInteger)getNewChannelNumberFrom:(NSInteger)startIndex positive:(BOOL)positive {
	
	if (startIndex > 4999) startIndex = 4999;
	if (startIndex < 1) startIndex = 1;
	
	NSMutableArray *channels = [NSMutableArray array];
	
	// Get the channels
	NSEnumerator *bouquetsEnum = [[self bouquets] objectEnumerator];
	Bouquet *bouquet;
	while(bouquet = [bouquetsEnum nextObject]) {
		[channels addObjectsFromArray:[bouquet channels]];
	}
	
	
	NSInteger newNumber = startIndex;
	BOOL used;
	
	while(true) {
		used = NO;
		
		NSEnumerator *channelEnum = [channels objectEnumerator];
		Channel *currentChannel;
		while(currentChannel = [channelEnum nextObject]) {
			if ([currentChannel channelNo] == newNumber) {
				used = YES;
				break;
			}
		}
		
		if (!used) {
			return newNumber;
		} else {
			if (positive) {
				newNumber++;
				if (newNumber == 5000) newNumber = 1;
			} else {
				newNumber--;
				if (newNumber == 0) newNumber = 4999;
			}
		}
	}
}

- (BOOL)addChannelAddresses:(NSArray *)addresses andRemoveOld:(BOOL)removeOld onTuner:(HDHomeRunTuner *)lTuner {

	NSMutableArray *tempArray;
	NSMutableArray *newAddresses = [addresses mutableCopy];
	
	// Remove new channel addresses with unknown unique ids
	NSEnumerator *newAddressEnum = [newAddresses objectEnumerator];
	HDChannelAddress *currentNewChannelAddress;
	while(currentNewChannelAddress = [newAddressEnum nextObject]) {
		if ([currentNewChannelAddress uniqueId] == nil) {
			[newAddresses removeObject:currentNewChannelAddress];
		}
	}
	
	NSArray *usedAddressChannels = [self channelAddressesFromChannels];
	
	// Remove same addresses
	newAddressEnum = [newAddresses objectEnumerator];
	while(currentNewChannelAddress = [newAddressEnum nextObject]) {
		NSEnumerator *channelAddressEnum = [usedAddressChannels objectEnumerator];
		HDChannelAddress* channelAddress;
		while(channelAddress = [channelAddressEnum nextObject]) {
			if (([channelAddress tuner] == [currentNewChannelAddress tuner]) && (([channelAddress tuner] == lTuner) || (lTuner == nil)) && ([channelAddress isSimilar:currentNewChannelAddress])) {
				[newAddresses removeObject:currentNewChannelAddress];
			}
		}
	}
	
	BOOL added = NO;

	// Add to similar address in channel
	NSMutableArray *justAdded = [NSMutableArray array];
	NSEnumerator *bouquetsEnum = [[self bouquets] objectEnumerator];
	Bouquet *bouquet;
	while(bouquet = [bouquetsEnum nextObject]) {
		NSEnumerator *channelEnum = [[bouquet channels] objectEnumerator];
		Channel* channel;
		while(channel = [channelEnum nextObject]) {
			NSEnumerator *channelAddressEnum = [[channel channelAddresses] objectEnumerator];
			HDChannelAddress* channelAddress;
			while(channelAddress = [channelAddressEnum nextObject]) {
				newAddressEnum = [newAddresses objectEnumerator];
				while(currentNewChannelAddress = [newAddressEnum nextObject]) {
					if ([channelAddress isSimilar:currentNewChannelAddress]) {
						
						tempArray = [[channel channelAddresses] mutableCopy];
						[tempArray addObject:currentNewChannelAddress];
						[channel setChannelAddresses:tempArray];

						[justAdded addObject:currentNewChannelAddress];
						[newAddresses removeObject:currentNewChannelAddress];
						
						added = YES;
						break;
					}
				}
			}
		}
	}

	// Remove unused entries from tuner
	if (removeOld) {
		newAddressEnum = [justAdded objectEnumerator];
		while(currentNewChannelAddress = [newAddressEnum nextObject]) {
			bouquetsEnum = [[self bouquets] objectEnumerator];
			while(bouquet = [bouquetsEnum nextObject]) {
				NSEnumerator *channelEnum = [[bouquet channels] objectEnumerator];
				Channel* channel;
				while(channel = [channelEnum nextObject]) {
					NSEnumerator *channelAddressEnum = [[channel channelAddresses] objectEnumerator];
					HDChannelAddress* channelAddress;
					while(channelAddress = [channelAddressEnum nextObject]) {
						if ((currentNewChannelAddress != channelAddress) && ([channelAddress tuner] == [currentNewChannelAddress tuner]) && (([channelAddress tuner] == lTuner) || (lTuner == nil)) && ([channelAddress isSimilar:currentNewChannelAddress])) {
							tempArray = [[channel channelAddresses] mutableCopy];
							[tempArray removeObject:channelAddress];
							[channel setChannelAddresses:tempArray];
						}
					}
				}
			}
		}
	}
	
	
	// Prepare to add new channels
	Channel *newChannel;
	Bouquet *defaultBouquets = [self getDefaultBouquet];
	
	// Add new channels
	newAddressEnum = [newAddresses objectEnumerator];
	while(currentNewChannelAddress = [newAddressEnum nextObject]) {
		newChannel = [Channel channelWithChannel:[self getNewChannelNumberFrom:1 positive:YES]];
		
		tempArray = [[newChannel channelAddresses] mutableCopy];
		[tempArray addObject:currentNewChannelAddress];
		[newChannel setChannelAddresses:tempArray];

		tempArray = [[defaultBouquets channels] mutableCopy];
		[tempArray addObject:newChannel];
		[defaultBouquets setChannels:tempArray];

		added = YES;
	}
	
	return added;
}
- (BOOL)removeChannelAddresses:(NSArray *)addresses {
	
	NSMutableArray *remAddresses = [addresses mutableCopy];
	
	NSMutableArray *tempArray;
	
	// Remove from lists
	NSEnumerator *removeAddressEnum = [remAddresses objectEnumerator];
	HDChannelAddress *currentRemoveChannelAddress;
	BOOL removed = NO;
	
	while(currentRemoveChannelAddress = [removeAddressEnum nextObject]) {
		removed = YES;
		
		// Tuner remove
		NSEnumerator *unitsEnum = [[HDHomeRunControl sharedUnits] objectEnumerator];
		HDHomeRunUnit *unit;
		while(unit = [unitsEnum nextObject]) {
			NSEnumerator *tunerEnum = [[unit tuner] objectEnumerator];
			HDHomeRunTuner *tuner;
			while(tuner = [tunerEnum nextObject]) {
				if ([[tuner channelAddresses] containsObject:currentRemoveChannelAddress]) {
					tempArray = [[tuner channelAddresses] mutableCopy];
					[tempArray removeObject:currentRemoveChannelAddress];
					[tuner setChannelAddresses:tempArray];
				}
			}
		}
		
		// Bouquets lists
		NSEnumerator *bouquetsEnum = [[self bouquets] objectEnumerator];
		Bouquet *bouquet;
		while(bouquet = [bouquetsEnum nextObject]) {
			NSEnumerator *channelEnum = [[bouquet channels] objectEnumerator];
			Channel *channel;
			while(channel = [channelEnum nextObject]) {
				if ([[channel channelAddresses] containsObject:currentRemoveChannelAddress]) {
					tempArray = [[channel channelAddresses] mutableCopy];
					[tempArray removeObject:currentRemoveChannelAddress];
					[channel setChannelAddresses:tempArray];
				}
			}
		}
	}
	
	return removed;
}

@end
