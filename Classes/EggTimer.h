//
//  EggTimer.h
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

#import <Foundation/NSTimer.h>
#import <CoreLocation/CoreLocation.h>

// The Average Weights, in grams of an Egg
extern const int kExtraLargeEggWt;
extern const int kLargeEggWt;
extern const int kMediumEggWt;

// Temperature in C for an Egg Yolk corresponding to Doneness
extern const int kSoftEggTemp;
extern const int kMediumEggTemp;
extern const int kHardEggTemp;

typedef enum doneNess {
  SoftBoiled, MediumBoiled, HardBoiled
} Doneness;

typedef enum eggSize {
  Medium, Large, ExtraLarge
} EggSize;

/*
 Model for an EggTimer.
 
 An EggTimer instance will act as a timer for cooking a batch of softboiled eggs.
 To use this class, 
 
 # Create an instance
 # If desired, set the level of |doneness| and the |eggsize| to be cooked.
 # Invoke the |startCooking| method the a class that implements the |EggTimerHandler| protocol.
 
 */
@class EggTimer;

@protocol EggTimerHandler <NSObject>
@required
// Called each second after the timer has started.
- (void)eggTimerTick:(EggTimer *) eggTimer;

// Called when the timer has completed.
- (void)eggTimerDone:(EggTimer *) eggTimer;

// Called when the Timer's Location has changed.
- (void)eggTimerMoved:(EggTimer *) eggTimer;
@end


@interface EggTimer : NSObject <CLLocationManagerDelegate> {

@private
  // Options
  BOOL useAltitude_;
  Doneness doneness_;
  EggSize eggSize_;
  
  // State
  long duration_;
  long timeRemaining_;
  long altInMtrs_;
  
  id theHandler_;
  NSTimer *theTimer_;
	CLLocationManager *locationManager_;
}

@property (retain) id <EggTimerHandler> theHandler;
@property BOOL useAltitude;
@property Doneness doneness;
@property EggSize eggSize;
@property (readonly) long duration;
@property (readonly) long timeRemaining;
@property (readonly) long altInMtrs;


// Start the timer to begin the cooking time. |handler| is retained and assigned
// to |theHandler_|. 
// Throws an exception if the timer has already started, or if |handler| is nil.
- (void) startCooking;

// Stops the timer if it has already started. |theHandler_| is released if the
// timer has begun.
- (void) stopCooking;
- (long) timeToCook;

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error;

@end

