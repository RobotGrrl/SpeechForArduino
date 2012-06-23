//
//  AppDelegate.m
//  SpeechSynthesisForArduino
//
/*
 Speech for Arduino is licensed under the BSD 3-Clause License
 http://www.opensource.org/licenses/BSD-3-Clause
 
 Speech for Arduino Copyright (c) 2012, RobotGrrl.com. All rights reserved.
 */

#import "AppDelegate.h"
#import "Speaker.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize finishSpeaking;
@synthesize currentPhrase;
@synthesize isConnected;

- (void)dealloc
{
    [speaker release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    // Init
    arduino = [[Matatino alloc] initWithDelegate:self];
    speaker = [[Speaker alloc] init];
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Debug
    [arduino setDebug:NO];
    
    // Setup the window
    [sayText setStringValue:@"Hello Arduino!"];
    [serialSelectMenu addItemsWithTitles:[arduino deviceNames]];
    [self updateVoicesDisplay];
    [speaker speakPhrase:[sayText stringValue]];
    
    NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
    NSRect windowFrame = [self.window frame];
    [self.window setFrame:NSMakeRect((visibleFrame.size.width - windowFrame.size.width) * 0.5,
                                     (visibleFrame.size.height - windowFrame.size.height) * (9.0/10.0),
                                     windowFrame.size.width, windowFrame.size.height) display:YES];
    
}

#pragma Buttons

- (IBAction) connectPressed:(id)sender {
    
    
    if(![arduino isConnected]) { // Pressing GO!
        
        if([arduino connect:[serialSelectMenu titleOfSelectedItem] withBaud:B115200]) {
            
            [speaker speakPhrase:@"Connected!"];
            isConnected = YES;
            
            [self setButtonsDisabled];
            //[self.window orderOut:self];
            
        } else {
            NSAlert *alert = [[[NSAlert alloc] init] autorelease];
            [alert setMessageText:@"Connection Error"];
            [alert setInformativeText:@"Connection failed to start"];
            [alert addButtonWithTitle:@"OK"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
        }
        
    } else { // Pressing Stop
        
        isConnected = NO;
        [arduino disconnect];
        [self setButtonsEnabled];
        
    }
    
}

- (IBAction) showPrefs:(id)sender {
    
    if([arduino isConnected]) { // Show the buttons as disabled
        [self setButtonsDisabled];
    } else { // Show the buttons as enabled
        [self setButtonsEnabled];
    }
    
    [self.window makeKeyAndOrderFront:self];
    
}

- (IBAction) launchWebsite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://appsforarduino.com/speech"]];
}

- (void) setButtonsEnabled {
    [serialSelectMenu setEnabled:YES];
    [connectButton setTitle:@"GO!"];
}

- (void) setButtonsDisabled {
    [serialSelectMenu setEnabled:NO];
    [connectButton setTitle:@"Stop"];
}

- (void) sendMessage:(NSString *)m {
    [arduino send:m];
    [arduino send:@" ~"];
}

#pragma mark Voices

- (void) updateVoicesDisplay {
    
    // Voices
    NSString *voiceName = [userDefaults objectForKey:@"Voice"];
    NSNumber *voiceRate = [userDefaults objectForKey:@"Rate"];
    NSNumber *voiceVol = [userDefaults objectForKey:@"Volume"];
    
    [rateLabel setStringValue:[NSString stringWithFormat:@"%f", [voiceRate floatValue]]];
    [volumeLabel setStringValue:[NSString stringWithFormat:@"%f", [voiceVol floatValue]]];
    [rateSlider setFloatValue:[voiceRate floatValue]];
    [volumeSlider setFloatValue:[voiceVol floatValue]];
    
    NSArray *allVoices = [NSSpeechSynthesizer availableVoices];
    
    for(int i=0; i<[allVoices count]; i++) {
        
        NSDictionary *currentVoice = [NSSpeechSynthesizer attributesForVoice:[allVoices objectAtIndex:i]];
        NSString *voiceEasyName = [currentVoice objectForKey:NSVoiceName];
        NSString *voicePathName = [currentVoice objectForKey:NSVoiceIdentifier];
        [voicesList addItemWithTitle:voiceEasyName];
    
        if([voicePathName isEqualToString:voiceName]) {
            [voicesList selectItemWithTitle:voiceEasyName];
        }
        
    }

    // ---
    
}

- (void) saveVoices {
    
    // Voice
    NSString *voiceName = [[NSSpeechSynthesizer availableVoices] objectAtIndex:[voicesList indexOfSelectedItem]];
    NSNumber *rateNum = [NSNumber numberWithDouble:[rateSlider doubleValue]];
    NSNumber *volNum = [NSNumber numberWithDouble:[volumeSlider doubleValue]];
    
    [userDefaults setObject:voiceName forKey:@"Voice"];
    [userDefaults setObject:rateNum forKey:@"Rate"];
    [userDefaults setObject:volNum forKey:@"Volume"];
    
}

- (IBAction) sayPressed:(id)sender {
    [speaker speakPhrase:[sayText stringValue]];
}

- (IBAction) voicesChanged:(id)sender {
        
    [self saveVoices];
    [self updateVoicesDisplay];
    [speaker updateVoicePrefs];
    if(![arduino isConnected]) [speaker speakPhrase:[sayText stringValue]];
    
}

#pragma mark - Arduino Delegate Methods

- (void) receivedString:(NSString *)rx {
    
    //NSLog(@"Received string: %@", rx);
    
    NSArray *dataArray = [[[NSArray alloc] initWithObjects:nil] autorelease];
    NSRange aRange = [rx rangeOfString:@"\r\n"];
    
    // Split the data (after checking that the data is good)
    // --> For some reason there is a bunch of garbled data
    //     that shows up after uploading a sketch to the 
    //     board, so we have to account for that
    if(aRange.location != NSNotFound) {
        dataArray = [rx componentsSeparatedByString:@"\r\n"];
    }
    
    // Make sure there's enough in the array
    if([dataArray count] > 0) {
        
        NSString *firstStr = [dataArray objectAtIndex:0];
        
        if([firstStr length] > 0) {
            [speaker speakPhrase:firstStr];
        }
         
    }
    
}

- (void) portAdded:(NSArray *)ports {
    
    for(NSString *portName in ports) {
        [serialSelectMenu addItemWithTitle:portName];
    }
    
}

- (void) portRemoved:(NSArray *)ports {
    
    for(NSString *portName in ports) {
        [serialSelectMenu removeItemWithTitle:portName];
    }
    
}

- (void) portClosed {
    
    [speaker speakPhrase:@"Ciao, Arduino"];
    
    [self setButtonsEnabled];
    [self.window makeKeyAndOrderFront:self];
    
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Disconnected"];
    [alert setInformativeText:@"Apparently the Arduino was disconnected!"];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
    
}



@end
