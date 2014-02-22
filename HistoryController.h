//
//  HistoryController.h
//  sunny
//
//  Created by dshen on 10/2/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import "CEPubnub.h"
#import "CEPubnubDelegate.h"

@interface HistoryController : UIViewController <UITableViewDataSource, UITableViewDelegate, CEPubnubDelegate> {
    
    IBOutlet UITableView *table;
    IBOutlet UILabel *pointsLabel;
    NSInteger selectedIndex;
    NSData *data1;

}

@property (readwrite, retain) NSMutableArray *questionIdArray;
@property (readwrite, retain) NSMutableArray *questionsArray;
@property (readwrite, retain) NSMutableArray *correctAnswerIdArray;
@property (readwrite, retain) NSMutableArray *committedAnswerIdArray;
@property (readwrite, retain) NSMutableArray *pointsCommittedArray;
@property (readwrite, retain) NSMutableArray *answerIdArray;
@property (readwrite, retain) NSMutableArray *answersArray;

@property (readwrite, retain) NSMutableArray *statusArray;
@property (retain, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (retain, nonatomic) IBOutlet UILabel *pointsLabel;

@end
