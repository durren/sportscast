//
//  LoginController.m
//  sunny
//
//  Created by dshen on 10/3/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//

#import "LoginController.h"
#import "AppDelegate.h"
#import "QuestionController.h"
#import "ViewController.h"
#import "JoinGameController.h"

@interface LoginController ()

@end

@implementation LoginController
@synthesize questionController;
@synthesize loginController;
@synthesize deviceUdid;
@synthesize fbAccessToken;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

+ (id)sharedManager {
    static LoginController *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        fbAccessToken = [[NSString alloc] initWithString:@"Default Property Value"];
    }
    return self;
}

- (void)viewDidLoad
{
    
    self.joinGamesBtn.hidden=YES;
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    // Check the session for a cached token to show the proper authenticated
    // UI. However, since this is not user intitiated, do not show the login UX.
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:NO];
    appDelegate.hostURL=@"http://sportscast-sunny.appspot.com/";
    //appDelegate.hostURL=@"http://localhost:9000/";
    
	// Do any additional setup after loading the view.
    
    //get the UDID
    UIDevice *myDevice = [UIDevice currentDevice];
	NSString *deviceUDID = [myDevice uniqueIdentifier];
    NSLog(@"device id: %@", deviceUDID);
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_authButton release];
    [authButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLoginButton:nil];
    [authButton release];
    authButton = nil;
    [super viewDidUnload];
}

- (IBAction)authButtonAction:(id)sender {
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    // If the user is authenticated, log out when the button is clicked.
    // If the user is not authenticated, log in when the button is clicked.
    if (FBSession.activeSession.isOpen) {
        [appDelegate closeSession];
    } else {
        // The user has initiated a login, so call the openSession method
        // and show the login UX if necessary.
        [appDelegate openSessionWithAllowLoginUI:YES];
    }
    
    
}

- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        [self.authButton setTitle:@"Logout" forState:UIControlStateNormal];
        
        //GET THE UDID
        UIDevice *myDevice = [UIDevice currentDevice];
        NSString *deviceUDID = [myDevice uniqueIdentifier];
        
        NSString *deviceIdPost = [@"&deviceToken=" stringByAppendingString:deviceUDID];
        NSString *accessTokenPost = [@"?accessToken=" stringByAppendingString:[FBSession.activeSession accessToken]];
        NSLog(@"access token: %@", accessTokenPost);
        NSLog(@"device id: %@", deviceIdPost);
        self.deviceUdid = deviceIdPost;
        self.fbAccessToken = accessTokenPost;
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        NSString *urlAsString = appDelegate.hostURL;
        urlAsString = [urlAsString stringByAppendingString:@"login/registerIosDevice"];
        urlAsString = [urlAsString stringByAppendingString:accessTokenPost];
        urlAsString = [urlAsString stringByAppendingString:deviceIdPost];
        
        NSURL *url = [NSURL URLWithString:urlAsString];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:30.0f];
        [urlRequest setHTTPMethod:@"POST"];
        
        NSString *body = @"bodyParam1=BodyValue1";
        [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if ([data length] > 0 && error == nil) {
                NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            else if ([data length]==0 && error == nil) {
                NSLog(@"Nothing was downloaded");
            } else if (error != nil) {
                NSLog(@"Error happened = %@", error);
            }
    
        }];
        NSLog(@"logged in!!!!");
        self.joinGamesBtn.hidden=NO;
        
    } else {
        [self.authButton setTitle:@"Login" forState:UIControlStateNormal];
        self.joinGamesBtn.hidden=YES;
    }
}

- (IBAction)joinGamesBtnAction:(id)sender {
    //[self performSegueWithIdentifier:@"displayJoinGames" sender:self];
}


@end
