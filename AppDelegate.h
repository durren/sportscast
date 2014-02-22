//
//  AppDelegate.h
//  sunny
//
//  Created by dshen on 9/24/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    NSInteger gameId;
    NSInteger sportsGameId;
    NSString *hostURL;
    NSString *userAnswerStatus;
    NSInteger questionIdFromHistoryTable;

}
extern NSString *const FBSessionStateChangedNotification;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) NSInteger gameId;
@property (nonatomic, assign) NSInteger sportsGameId; 
@property (readwrite, retain) NSString *hostURL; 
@property (readwrite, retain) NSString *userAnswerStatus;
@property (nonatomic, assign) NSInteger questionIdFromHistoryTable;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

- (void) closeSession;

@end

