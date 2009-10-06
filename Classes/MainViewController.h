//
//  MainViewController.h
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

#import "FlipsideViewController.h"
#import "EggTimer.h"
#import "Ringer.h"

#define DONENESS_KEY @"Doneness"
#define EGG_SIZE_KEY @"Egg Size"
#define USE_ALTITUDE_KEY @"Use Altitude"

@interface MainViewController : 
  UIViewController 
    <FlipsideViewControllerDelegate,  EggTimerHandler, UIAlertViewDelegate> {

  @private
    EggTimer *theEggTimer_;
    NSMutableDictionary *timerOptions_;
    NSString *timerOptionsFilePath_;
    BOOL startTimingOnOpen_;
    Ringer *ringer_;
    
    IBOutlet UILabel *timeRemainingLabel_;
    IBOutlet UILabel *statusLabel_;
    IBOutlet UILabel *altitudeLabel_;
    IBOutlet UILabel *timeToCookLabel_;
}


@property(nonatomic, retain) IBOutlet UILabel *timeRemainingLabel;
@property(nonatomic, retain) IBOutlet UILabel *statusLabel;
@property(nonatomic, retain) IBOutlet UILabel *altitudeLabel;
@property(nonatomic, retain) IBOutlet UILabel *timeToCookLabel;
@property(nonatomic, readonly) Ringer *ringer;

// Show the Options from the info button.
- (IBAction)showInfo;

// Begin timing the Egg from the start button. This does nothing if an egg is
// already being cooked.
- (IBAction)startTimer: (id) sender;

// Reset the timer from the reset button. This will cancel the current timer.
- (IBAction)resetTimer: (id) sender;

@end
