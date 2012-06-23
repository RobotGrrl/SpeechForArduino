//
//  Speaker.m
//  SpeechSynthesisForArduino
//
/*
 Speech for Arduino is licensed under the BSD 3-Clause License
 http://www.opensource.org/licenses/BSD-3-Clause
 
 Speech for Arduino Copyright (c) 2012, RobotGrrl.com. All rights reserved.
 */

#import "Speaker.h"
#import "AppDelegate.h"

@implementation Speaker

@synthesize synth, nextPhrase;


- (id) init {
        
    // Initialization code here.
    userDefaults = [NSUserDefaults standardUserDefaults];
    appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [[appDelegate currentPhrase] setStringValue:[NSString stringWithFormat:@"Currently not speaking"]];
    
    debug = NO;
    
    synth = [[NSSpeechSynthesizer alloc] initWithVoice:@"com.apple.speech.synthesis.voice.Alex"];
    [synth setDelegate:self];
    
    nextPhrase = [[NSString alloc] initWithString:@""];
    phraseWaiting = NO;
    
    int starts = [[userDefaults objectForKey:@"Starts"] intValue];
        
    BOOL testingHi = YES;
    if(testingHi) starts = 0;
        
    if(starts == 0) {
        
        NSString *defaultvoice = [NSSpeechSynthesizer defaultVoice];
        
        [userDefaults setObject:defaultvoice forKey:@"Voice"]; // @"com.apple.speech.synthesis.voice.Alex"
        [userDefaults setObject:[NSNumber numberWithFloat:170.0f] forKey:@"Rate"];
        [userDefaults setObject:[NSNumber numberWithFloat:75.0f] forKey:@"Volume"];
        [userDefaults setObject:[NSNumber numberWithInt:1] forKey:@"Starts"];
        
    }
    
    [self updateVoicePrefs];
    
    [super init];
    return self;
	
}

- (void) updateVoicePrefs {
    
    NSString *voice = [userDefaults objectForKey:@"Voice"];
    float rate = [[userDefaults objectForKey:@"Rate"] floatValue];
    float volume = [[userDefaults objectForKey:@"Volume"] floatValue];
    
    [synth setVoice:voice];
    [synth setRate:rate];
    [synth setVolume:(volume/100.0f)];
    
}

- (void) speakPhrase:(NSString *)p {
     
    if(p == nil) {
        //NSLog(@"Received bad string");
        return;
    }
    
    if([appDelegate.finishSpeaking state] == YES && [synth isSpeaking]) {
        self.nextPhrase = p;
        phraseWaiting = YES;
    } else {
        [[appDelegate currentPhrase] setStringValue:[NSString stringWithFormat:@"Currently speaking: %@", p]];
        [synth startSpeakingString:p];
        
        if(phraseWaiting == YES) {
            phraseWaiting = NO;
        }
        
    }
    
}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)success {
    
    if(debug) NSLog(@"finished speaking");
    
    if([appDelegate isConnected]) [appDelegate sendMessage:@"!"];
    
    if(phraseWaiting) {
        [self speakPhrase:self.nextPhrase];
    }
    
}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender willSpeakPhoneme:(short)phonemeOpcode {
    
    if(debug) NSLog(@"phoneme: %d", phonemeOpcode);
    if([appDelegate isConnected]) [appDelegate sendMessage:[NSString stringWithFormat:@"%d", phonemeOpcode]];
    
}

@end
