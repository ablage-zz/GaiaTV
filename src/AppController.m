#import "AppController.h"

#import "HDHomeRunControl.h"
#import "HDHomeRunUnit.h"
#import "HDHomeRunTuner.h"

#import "Services.h"
#import "PreferencesController.h";
#import "TvVideoController.h"
#import "Transformer.h"


@implementation AppController

@synthesize services;
@synthesize currentTuner;

- (id)init {
	self = [super init];
	if (self != nil) {
		[self setServices:nil];
		[self setCurrentTuner:nil];
		
		[HDHomeRunControl setSharedUnits:[HDHomeRunControl discover]];
		
		[self setServices:[Services services]];
		[[self services] loadFromDisk];
		
		// Windows
		preferencesWindow = nil;
		tvVideoWindows = [[NSMutableArray array] retain];
		
		// Add Transformer
		[NSValueTransformer setValueTransformer:(id)[[[NonNilAsBoolTransformer alloc] init] autorelease] forName:@"NonNilAsBoolTransformer"];
	}
	return self;
}
- (void)dealloc {
	// Windows
	[preferencesWindow release];
	[tvVideoWindows release];

	
	[HDHomeRunControl setSharedUnits:nil];
	[Services setSharedServices:nil];
	
	[services release];
	[currentTuner release];
	
	[super dealloc];
}

- (void)awakeFromNib {
	if ([[[self services] bouquets] count] == 0) {
		[self preferencesClick:self];
	} else {
		[self newTVClick:self];
	}
}

- (IBAction)newTVClick:(id)sender {
	TvVideoController *newController = [TvVideoController tvVideoController];
	[tvVideoWindows addObject:newController];
	[newController show];
}
- (IBAction)preferencesClick:(id)sender {
    if (preferencesWindow == nil) {
		preferencesWindow = [[PreferencesController preferencesController] retain];
	}
	[preferencesWindow show];
}

@end
