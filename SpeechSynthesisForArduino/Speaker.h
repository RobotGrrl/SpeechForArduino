//
//  Speaker.h
//  SpeechSynthesisForArduino
//
/*
 Speech for Arduino is licensed under the BSD 3-Clause License
 http://www.opensource.org/licenses/BSD-3-Clause
 
 Speech for Arduino Copyright (c) 2012, RobotGrrl.com. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

@class AppDelegate;

@interface Speaker : NSObject <NSSpeechSynthesizerDelegate> {
    
@private
    NSSpeechSynthesizer *synth;
    NSUserDefaults *userDefaults;
    AppDelegate *appDelegate;
    NSString *nextPhrase;
    BOOL phraseWaiting;
    BOOL debug;
}

@property (nonatomic, retain) NSSpeechSynthesizer *synth;
@property (nonatomic, retain) NSString *nextPhrase;

- (void) updateVoicePrefs;
- (void) speakPhrase:(NSString *)p;

@end
