//
//  Motus
//   Easily oppen Control Center from the bottom corners of your iPhone X.
//   By Simalary (Chris) & MidnightChips
//

#import <objc/runtime.h>

//Prefs
#define PLIST_PATH @"/Users/midnightchip/Documents/Dev/MotusPref/prefs/entry.plist" //Change to your entry.plist path. Include file extension.

inline bool GetPrefBool(NSString *key) {
return [[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] valueForKey:key] boolValue];
}

inline int GetPrefInt(NSString *key) {
return [[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] valueForKey:key] intValue];
}

inline float GetPrefFloat(NSString *key) {
return [[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] valueForKey:key] floatValue];
}
//End Prefs

//Respring function
@interface FBSystemService : NSObject

+(id)sharedInstance;
- (void)exitAndRelaunch:(bool)arg1;

@end

static void RespringDevice()
{
    [[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
}

%ctor
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)RespringDevice, CFSTR("com.simalary-midnightchips.auxiliumdevelopment.motusprefs/respring"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately); //Your Prefs Bundle + "/respring" (different form tweak bundle) See reference in /prefs/MotusPrefsRootListController.m
}
//End Respring




@interface CHMotusWindow : UIWindow
@end

@interface CHMotusView : UIView
@end

@interface SBControlCenterController
+(id)sharedInstance;
+(void)presentAnimated:(BOOL)arg1;
@end

@implementation CHMotusWindow
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIWindow *window in self.subviews) {
        if (!window.hidden && window.userInteractionEnabled && [window pointInside:[self convertPoint:point toView:window] withEvent:event])
            return YES;
    }
    return NO;
}
@end

@implementation CHMotusView
// -(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//     for (UIView *view in self.subviews) {
//         if (!view.hidden && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event])
//             return YES;
//     }
//     return NO;
// }
@end

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    float setNewWidth = GetPrefFloat(@"kWidth");
    float setNewAlpha = GetPrefFloat(@"kAlpha");
	UIWindow * screen = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen]bounds]];

	CHMotusView * rightView=[[CHMotusView alloc]initWithFrame:CGRectMake(screen.bounds.size.width, screen.bounds.size.height, - setNewWidth, - 150)];
    [rightView setBackgroundColor:[UIColor greenColor]];
    [rightView setAlpha: setNewAlpha];
    rightView.userInteractionEnabled = TRUE;

	CHMotusView * leftView=[[CHMotusView alloc]initWithFrame:CGRectMake(screen.bounds.origin.x, screen.bounds.size.height, setNewWidth, - 150)];
    [leftView setBackgroundColor:[UIColor greenColor]];
    [leftView setAlpha: setNewAlpha];
    leftView.userInteractionEnabled = TRUE;

	CHMotusWindow *window = [[CHMotusWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	window.windowLevel = 1005;
	[window setHidden:NO];
	[window setAlpha:1.0];
	[window setBackgroundColor:[UIColor clearColor]];
	[window addSubview:rightView];
	[window addSubview:leftView];

	UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRecognizer:)];
    rightRecognizer.direction=UISwipeGestureRecognizerDirectionUp;
    [rightView addGestureRecognizer:rightRecognizer];

	UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRecognizer:)];
    leftRecognizer.direction=UISwipeGestureRecognizerDirectionUp;
	[leftView addGestureRecognizer:leftRecognizer];
  %orig;

	/*UILabel *betaLabel;
    betaLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen.bounds.size.width / 2, screen.bounds.size.height - 35, 0, 0)];
    betaLabel.textColor = [UIColor whiteColor];
	betaLabel.backgroundColor = [UIColor redColor];
    betaLabel.textAlignment = NSTextAlignmentCenter;
    betaLabel.text = @"MOTUS BETA";
    betaLabel.font = [UIFont fontWithName:@".SFUIText" size:15];
    [betaLabel sizeToFit];
    [betaLabel setCenter:(CGPointMake(CGRectGetMidX(screen.bounds), betaLabel.center.y))];
	[window addSubview:betaLabel];*/

    //[upRecognizer release];

	//[[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject] addSubview:window];

}
%new
- (void) SwipeRecognizer:(UISwipeGestureRecognizer *)sender {
	[[%c(SBControlCenterController) sharedInstance] presentAnimated:TRUE];
}

%end
