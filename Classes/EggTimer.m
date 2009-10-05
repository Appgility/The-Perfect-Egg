//
//  EggTimer.m
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

#import "EggTimer.h"
#import "math.h"

#pragma mark Constants and Definitions
// The Average Weights, in grams of an Egg
const int kExtraLargeEggWt = 67;
const int kLargeEggWt = 50;
const int kMediumEggWt = 42;

// Temperature in C for an Egg Yolk corresponding to Doneness
const int kSoftEggTemp = 62;
const int kMediumEggTemp = 64;
const int kHardEggTemp = 66;

@implementation EggTimer

#pragma mark properties
@synthesize theHandler = theHandler_;
@synthesize doneness = doneness_;
@synthesize eggSize = eggSize_;
@synthesize duration = duration_;
@synthesize timeRemaining = timeRemaining_;
@synthesize altInMtrs = altInMtrs_;
@synthesize useAltitude = useAltitude_;

- (void)setUseAltitude: (BOOL)newValue {
  
  if (newValue && useAltitude_ == FALSE) {
    if (locationManager_ == nil) {
      locationManager_ = [[[CLLocationManager alloc] init] autorelease];
      [locationManager_ retain];  // have the timer manage it.
      locationManager_.delegate = self;
      altInMtrs_ = locationManager_.location.altitude;
      locationManager_.distanceFilter = 1.0f;
      locationManager_.desiredAccuracy = kCLLocationAccuracyBest; 
    }
    [locationManager_ startUpdatingLocation];
  } else if (locationManager_ && newValue == FALSE) {
      [locationManager_ stopUpdatingLocation];
  }
  useAltitude_ = newValue;
}

- (void)setEggSize:(EggSize)size {
  eggSize_ = size;
  duration_ = [self timeToCook];
}

- (void)setDoneness:(Doneness)done {
  doneness_ = done;
  duration_ = [self timeToCook];
}

#pragma mark methods

- (void)startCooking {
  if (!theHandler_) return;
  
  // Set the |timeRemaining_| to the amount of cook time required.
  duration_ = [self timeToCook];
  timeRemaining_ = duration_;
  
  // Create and schedule |theTimer_|
  theTimer_ = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                               target:self 
                                             selector:@selector(timerFired) 
                                             userInfo:NULL 
                                              repeats:YES];}

- (void)stopCooking {
// Stop and release the timer, release the handler
  if (theTimer_) {
    [theTimer_ invalidate];
    theTimer_ = NULL; 
  }
  timeRemaining_ = 0;
}

- (void)timerFired {
  timeRemaining_ -= 1;
  [theHandler_ eggTimerTick:self];

  if (timeRemaining_ == 0) {
    // Cancel the timer and tell |theHandler_| we're done cooking.
    [theTimer_ invalidate];
    theTimer_ = NULL;
    [theHandler_ eggTimerDone:self];
    // Should I release the handler?
  }
}

- (long)timeToCook {
  // Assumption that eggs from fridge are 4 degrees C.
  static float eggTemp = 4.0;

  // This is a rough estimate: The boiling point of water drops by 0.3 C
  // for every 100m above See Level.
  long boilH2O = 100.0 - (altInMtrs_/100) * 0.3;
  long eggMass, yolkTemp;
  
  switch (eggSize_) {
    case Medium:
      eggMass = kMediumEggWt;
      break;
    case ExtraLarge:
      eggMass = kExtraLargeEggWt;
      break;
    case Large:
    default:
      eggMass = kLargeEggWt;
      break;
  }
  
  switch (doneness_) {
    case HardBoiled:
      yolkTemp = kHardEggTemp;
      break;
    case MediumBoiled:
      yolkTemp = kMediumEggTemp;
      break;
    case SoftBoiled:
    default:
      yolkTemp = kSoftEggTemp;
      break;
  }

  // Calculate the time to cook in minutes.
  // From: http://blog.khymos.org/2009/04/09/towards-the-perfect-soft-boiled-egg
  float minutesToCook = 0.451 * pow(eggMass, 2.0/3.0) * 
      log(0.76 * ((eggTemp - boilH2O)/(yolkTemp - boilH2O)));
    
  // Convert to seconds.
  long secondsToCook = (long)minutesToCook * 60 + 
            (minutesToCook - (long)minutesToCook) * 60;
  return secondsToCook;
}

#pragma mark CLController Protocol

// Handle the location manager update to get the current altitude in meters.
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
  altInMtrs_ = newLocation.altitude;
  duration_ = [self timeToCook];

  if (theHandler_) {
    [theHandler_ eggTimerMoved: self];    
  }
}

// If there's an error. It could be that the user refused to allow the function,
// in which case, |useAltitude_| is toggled off. In all cases the 
// |locationManager_| is stopped and altitude set to sea level.
- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
  switch ([error code]) {
    case kCLErrorDenied:
      useAltitude_ = FALSE;
    default:
      altInMtrs_ = 0;
      duration_ = [self timeToCook];
      [locationManager_ stopUpdatingLocation];  
      break;
  }
}


#pragma mark initalization

- (id)init {
  if (self = [super init]) {
    useAltitude_ = FALSE;
    eggSize_ = Large;
    doneness_ = SoftBoiled;
    duration_ = 180;
    
  }
  
  return self;
}

- (void) dealloc {
  [self stopCooking];
  [locationManager_ release];
  [super dealloc];
}
@end
