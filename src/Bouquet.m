//
//  Bouquet.m
//  GaiaTV
//
//  Created by marcel on 10/29/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import "Bouquet.h"

#import "HDChannelAddress.h"

#import "Services.h"
#import "Channel.h"


@implementation Bouquet

@synthesize channels;

- (NSString *)description {
	if ((description == nil) || ([description isEqualToString:@""])) {
		return @"[unknown]";
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


+ (Bouquet *)bouquetListWithDescription:(NSString *)lDescription {
	return [[[Bouquet alloc] initWithDescription:lDescription] autorelease];
}
- (id)initWithDescription:(NSString *)lDescription {
	self = [super init];
	if (self != nil) {
		[self setDescription:lDescription];
		[self setChannels:[NSArray array]];
		
		[self activateObserving];
	}
	return self;
}
- (id)init {
	return [self initWithDescription:@"New Entry"];
}
- (void)dealloc {
	[self deactivateObserving];
	
	[description release];
	[channels release];
	
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [self initWithDescription:[coder decodeObjectForKey:@"description"]];
	if (self != nil) {
		[self setChannels:[coder decodeObjectForKey:@"channels"]];
		
		[self activateObserving];
	}
	return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[self description] forKey:@"description"];
	[coder encodeObject:[self channels] forKey:@"channels"];
}
- (id)copyWithZone:(NSZone *)zone {
    Bouquet *copy = [[self class] allocWithZone: zone];

	[copy initWithDescription:[self description]];

	[copy setChannels:[self channels]];
	
    return copy;
}

- (void)activateObserving {
	[self addObserver:self forKeyPath:@"channels" options:NSKeyValueObservingOptionNew context:NULL];
}
- (void)deactivateObserving {
	[self removeObserver:self forKeyPath:@"channels"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"channels"]) {
		[[Services sharedServices] informationUpdated];
    }
}

- (BOOL)isValid {
	BOOL result = YES;
	
	// Validate all channels
	NSEnumerator *channelEnum = [[self channels] objectEnumerator];
	Channel *currentChannel;
	while(currentChannel = [channelEnum nextObject]) {
		result = result && [currentChannel isValid];
	}
	
	return result;
}
- (BOOL)repair:(BOOL)force {
	BOOL result = YES;
	
	NSMutableArray *tempArray;
	
	NSEnumerator *channelEnum = [[self channels] objectEnumerator];
	Channel *currentChannel;
	while(currentChannel = [channelEnum nextObject]) {
		if (![currentChannel repair:force]) {
			if (force) {
				tempArray = [[self channels] mutableCopy];
				[tempArray removeObject:currentChannel];
				[self setChannels:tempArray];
			} else {
				result = NO;
			}
		}
	}
	
	return result;
}

@end
