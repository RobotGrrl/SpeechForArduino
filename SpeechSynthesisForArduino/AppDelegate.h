//
//  AppDelegate.h
//  SpeechSynthesisForArduino
//
/*
 
 Speech for Arduino is licensed under the BSD 3-Clause License
 http://www.opensource.org/licenses/BSD-3-Clause
 
 Speech for Arduino Copyright (c) 2012, RobotGrrl.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of the RobotGrrl.com nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import <Cocoa/Cocoa.h>
#import <Matatino/Matatino.h>
#import <ApplicationServices/ApplicationServices.h>

@class Speaker;

@interface AppDelegate : NSObject <NSApplicationDelegate, MatatinoDelegate> {
    
    // Vars
    Speaker *speaker;
    Matatino *arduino;
    NSUserDefaults *userDefaults;
    BOOL isConnected;

    // Window related
    NSWindow *_window;
    IBOutlet NSPopUpButton *serialSelectMenu;
    IBOutlet NSButton *connectButton;
    IBOutlet NSTextField *currentPhrase;
    IBOutlet NSButton *finishSpeaking;
    
    // Voice
    IBOutlet NSPopUpButton *voicesList;
    IBOutlet NSTextField *rateLabel;
    IBOutlet NSTextField *volumeLabel;
    IBOutlet NSSlider *rateSlider;
    IBOutlet NSSlider *volumeSlider;
    IBOutlet NSTextField *sayText;
    
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet NSButton *finishSpeaking;
@property (nonatomic, retain) NSTextField *currentPhrase;
@property (assign) BOOL isConnected;

// Meep
- (void) sendMessage:(NSString *)m;

// Buttons
- (IBAction) connectPressed:(id)sender;
- (IBAction) showPrefs:(id)sender;
- (IBAction) launchWebsite:(id)sender;

// Voices
- (void) updateVoicesDisplay;
- (void) saveVoices;
- (IBAction) sayPressed:(id)sender;
- (IBAction) voicesChanged:(id)sender;

@end
