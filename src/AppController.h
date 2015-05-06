#import <Cocoa/Cocoa.h>

@class Services;
@class HDHomeRunTuner;
@class PreferencesController;


@interface AppController : NSObject {
	Services *services;
	HDHomeRunTuner *currentTuner;
	
	PreferencesController *preferencesWindow;
	NSMutableArray *tvVideoWindows;
}

@property(readwrite, assign) Services *services;
@property(readwrite, retain) HDHomeRunTuner *currentTuner;

- (IBAction)newTVClick:(id)sender;
- (IBAction)preferencesClick:(id)sender;

@end
