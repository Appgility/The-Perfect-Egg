//
//  Ringer.m
//  The Perfect Egg
//
//  Created by Leopold ODonnell on 10/5/09.
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

#import "Ringer.h"

@implementation Ringer

- (void) ring:(SystemSoundID)soundID :(int)maxRings {
  maxRings_ = maxRings;
  rings_ = 1;
  soundID_ = soundID;
  
  // Create and schedule |theTimer_|
  theTimer_ = [NSTimer scheduledTimerWithTimeInterval:2.0 
                                               target:self 
                                             selector:@selector(timerFired) 
                                             userInfo:NULL 
                                              repeats:YES];
  AudioServicesPlaySystemSound(soundID_);
}

- (void) hangup {
  rings_ = 0;
  if (theTimer_) {
    [theTimer_ invalidate];
  }
}

- (void)timerFired {
  // Ring
  AudioServicesPlaySystemSound (soundID_);

  // Test for completion
  if (maxRings_ != 0 && ++rings_ >= maxRings_) {
    // Cancel the timer and tell |theHandler_| we're done ringing.
    [theTimer_ invalidate];
    theTimer_ = nil;
    maxRings_ = rings_ = 0;
  }
  
}

@end
