//
//  LeaderboardController.h
//  sunny
//
//  Created by dshen on 10/17/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import "CEPubnub.h"
#import "CEPubnubDelegate.h"

@interface LeaderboardController : UIViewController <UITableViewDataSource, UITableViewDelegate, CEPubnubDelegate> {

    IBOutlet UITableView *table;
}

@property (retain, nonatomic) IBOutlet UITableView *table;
@property (readwrite, retain) NSMutableArray *nameArray;
@property (readwrite, retain) NSMutableArray *pointsPlayedArray;
@property (readwrite, retain) NSMutableArray *pointsGainedArray;
@property (readwrite, retain) NSMutableArray *facebookUserIdArray;
@property (readwrite, retain) NSMutableArray *questionsAttemptedArray;
@property (readwrite, retain) NSMutableArray *questionsCorrectArray;

@end
