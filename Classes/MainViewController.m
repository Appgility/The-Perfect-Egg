//
//  MainViewController.m
//  The Perfect Egg
//
//  Created by Leopold ODonnell on 9/15/09.
//  Copyright (c) 2009 Appgility
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "MainViewController.h"
#import "MainView.h"
#import "FlipsideViewController.h"

@implementation MainViewController

/*
 The following are UIKit objects
 */
@synthesize timeRemainingLabel = timeRemainingLabel_;
@synthesize statusLabel = statusLabel_;
@synthesize altitudeLabel = altitudeLabel_;
@synthesize timeToCookLabel = timeToCookLabel_;

// The ringer object used to ring the alarm when cooking has completed.
@synthesize ringer = ringer_;

NSString *startTimingOnOpenKey_ = @"startTimingOnOpen";

#pragma mark View Update Methods

- (void)updateTimeRemaining {
  long secondsRemaining = theEggTimer_.timeRemaining;
  NSString *timeRemainingS = [NSString stringWithFormat: @"%d:%02d", 
                              secondsRemaining/60, secondsRemaining%60]; 
  
  timeRemainingLabel_.text = timeRemainingS;
}

- (void) updateAltitude {
  if (theEggTimer_.useAltitude) {
    altitudeLabel_.text = 
    [NSString stringWithFormat:@"Altitude: %d m", theEggTimer_.altInMtrs];
  }
  else {
    altitudeLabel_.text = 
    [NSString stringWithFormat:@"Altitude: OFF"];

  }
}

- (void) updateTimeToCook {
  int seconds = theEggTimer_.duration;
  NSString *timeToCookS = [NSString stringWithFormat: @"Cook Time: %d:%02d", 
                              seconds/60, seconds%60]; 
  
  timeToCookLabel_.text = timeToCookS;
}

#pragma mark Action Methods

- (IBAction)startTimer: (id) sender {
  if (theEggTimer_.timeRemaining == 0) {
    statusLabel_.text = [NSString stringWithFormat: @"Cooking"];
    [theEggTimer_ startCooking];
  }
}

- (IBAction)resetTimer: (id) sender {
  statusLabel_.text = [NSString stringWithFormat:@"Waiting To Boil"];
  [theEggTimer_ stopCooking];
  [self updateTimeRemaining];
}


#pragma mark EggTimerHandler Protocol Methods

- (void)eggTimerTick:(EggTimer *) eggTimer {
  [self updateTimeRemaining];    
}

// Called when the timer has completed.
- (void)eggTimerDone:(EggTimer *) eggTimer {
  statusLabel_.text = [NSString stringWithFormat:@"Done - Time To Eat"];
  [self updateTimeRemaining];
  
  // Vibrate to indicate Completion
  // NB! No need to dispose of this sound.
  SystemSoundID soundID = kSystemSoundID_Vibrate;
  ringer_ = [Ringer alloc];
  [ringer_ ring: soundID :15];
  
  // Show an alert dialog to indicate Completion
  UIAlertView *doneCookin =
    [[UIAlertView alloc] initWithTitle: @"Perfect Egg" message:@"Done Cooking!"
                              delegate:self cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
  [doneCookin show];
  [doneCookin release];
}

- (void)eggTimerMoved:(EggTimer *)eggTimer {
  [self updateAltitude];
  [self updateTimeToCook];
}

#pragma mark Option Initialization 

- (void) initTimerOptionsFilePath {
  NSString *documentsDirectory =
  [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
  timerOptionsFilePath_ = [documentsDirectory stringByAppendingPathComponent:
                           @"flippingPrefs.plist"];
  [timerOptionsFilePath_ retain];
}

- (void) loadPrefs {
  // Get Application Settings Preferences
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  Boolean onOff = [defaults boolForKey:startTimingOnOpenKey_];

  // You must test to see if any defaults have been set by the user. If
  // not set them yourself in code. You only need to do it for one item.
  if (onOff == NO) {
    startTimingOnOpen_ = FALSE;
  }
  else {
    startTimingOnOpen_ = onOff;
  }

  // Get Info Settings Preferences
  if (timerOptionsFilePath_ == nil) {
    [self initTimerOptionsFilePath];
  }
  
  if ([[NSFileManager defaultManager] fileExistsAtPath: timerOptionsFilePath_]) {
    timerOptions_ = [[NSMutableDictionary alloc]
                     initWithContentsOfFile:timerOptionsFilePath_];
  }
  else {
    timerOptions_ = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [timerOptions_ setObject: [NSNumber numberWithInt: theEggTimer_.doneness]
                      forKey: DONENESS_KEY];
    [timerOptions_ setObject: [NSNumber numberWithInt: theEggTimer_.eggSize]
                      forKey: EGG_SIZE_KEY];
    [timerOptions_ setObject: [NSNumber numberWithBool: theEggTimer_.useAltitude]
                      forKey: USE_ALTITUDE_KEY];
  }

  // |theEggTimer_| must be created before this method. Update it with loaded
  // values.
  theEggTimer_.useAltitude = [[timerOptions_ objectForKey:USE_ALTITUDE_KEY] boolValue];
  theEggTimer_.doneness = [[timerOptions_ objectForKey:DONENESS_KEY] intValue];
  theEggTimer_.eggSize = [[timerOptions_ objectForKey:EGG_SIZE_KEY] intValue];  
}

- (void) savePrefs {
  [timerOptions_ setObject: [NSNumber numberWithInt: theEggTimer_.doneness]
                    forKey: DONENESS_KEY];
  [timerOptions_ setObject: [NSNumber numberWithInt: theEggTimer_.eggSize]
                    forKey: EGG_SIZE_KEY];
  [timerOptions_ setObject: [NSNumber numberWithBool: theEggTimer_.useAltitude]
                    forKey: USE_ALTITUDE_KEY];
  [timerOptions_ writeToFile:timerOptionsFilePath_ atomically:YES];
}

#pragma mark AlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView 
didDismissWithButtonIndex:(NSInteger)buttonIndex {
  MainViewController *c = (MainViewController*) alertView.delegate;
  [c.ringer hangup];
  [c.ringer release];
}
#pragma mark Framework View Management Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  theEggTimer_ = [[EggTimer alloc] init];
  theEggTimer_.theHandler = self;
  [self loadPrefs];
  [self updateTimeRemaining];
  [self updateAltitude];
  [self updateTimeToCook];
  // Start timing now if the |startTimingOnOpen_| option is set.
  if (startTimingOnOpen_) {
    [self startTimer:self];
  }
}


 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Let the user change orientations.
  return YES;
}


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
  // Get the values from the |controller|, update |timerOptions_| and the view.
  switch (controller.eggDonenessOption.selectedSegmentIndex) {
    case 0:
      theEggTimer_.doneness = SoftBoiled;
      break;
    case 1:
      theEggTimer_.doneness = MediumBoiled;
      break;
    case 2:
      theEggTimer_.doneness = HardBoiled;
      break;
    default:
      break;
  }

  switch (controller.eggSizeOption.selectedSegmentIndex) {
    case 0:
      theEggTimer_.eggSize = Medium;
      break;
    case 1:
      theEggTimer_.eggSize = Large;
      break;
    case 2:
      theEggTimer_.eggSize = ExtraLarge;
      break;
    default:
      break;
  }
  
  theEggTimer_.useAltitude = controller.useAltitudeOption.on;
  [self savePrefs];
	[self dismissModalViewControllerAnimated:YES];
  [self updateAltitude];
  [self updateTimeToCook];
}


- (IBAction)showInfo {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

	[self presentModalViewController:controller animated:YES];
  
  int segmentIndex;
  
  // Update the |controller| values here.
  switch (theEggTimer_.doneness) {
    case SoftBoiled:
      segmentIndex = 0;
      break;
    case MediumBoiled:
      segmentIndex = 1;
      break;
    case HardBoiled:
      segmentIndex = 2 ;
      break;
    default:
      break;
  }
  controller.eggDonenessOption.selectedSegmentIndex = segmentIndex;

  switch (theEggTimer_.eggSize) {
    case Medium:
      segmentIndex = 0;
      break;
      case Large:
      segmentIndex = 1;
        break;
      case ExtraLarge:
      segmentIndex = 2;
        break;
    default:
      break;
  }
  controller.eggSizeOption.selectedSegmentIndex = segmentIndex;
  
  controller.useAltitudeOption.on = theEggTimer_.useAltitude;
	[controller release];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [timeRemainingLabel_ release];
  [super dealloc];
}


@end
