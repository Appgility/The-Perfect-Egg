//
//  Ringer.h
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

#import <Foundation/NSTimer.h>
#import <AudioToolbox/AudioToolbox.h>

// A |Ringer| is a class that will cause an SystemSound to play with a 2 second
// delay between repeats. The |Ringer| will repeat a specified number of times
// or until it is cancelled by a call to |hangup|.
@interface Ringer : NSObject {
@private
  NSTimer *theTimer_;
  SystemSoundID soundID_;
  
  int maxRings_;
  int rings_;
}

// Start ringing with the sound identified by |soundID| for |maxRings| or
// until a |hangup|. The caller has responsibility for disposing of the ring
// tone.
- (void) ring: (SystemSoundID)soundID: (int) maxRings;

// Stop ringing even if there are more |rings_| left.
- (void) hangup;

@end
