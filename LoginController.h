//
//  LoginController.h
//  sunny
//
//  Created by dshen on 10/3/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QuestionController;
@class LoginController;
@class JoinGameController;

@interface LoginController : UIViewController {
    
    IBOutlet UIButton *authButton;
    IBOutlet UIButton *joinGamesBtn;
}
@property (retain, nonatomic) IBOutlet UIButton *authButton;
@property (nonatomic, retain) QuestionController *questionController;
@property (nonatomic, retain) LoginController *loginController;
@property (nonatomic, retain) NSString *deviceUdid;
@property (nonatomic, retain) NSString *fbAccessToken;
@property (retain, nonatomic) IBOutlet UIButton *joinGamesBtn;

- (IBAction)authButtonAction:(id)sender;
- (IBAction)joinGamesBtnAction:(id)sender;
+ (id)sharedManager;

@end



