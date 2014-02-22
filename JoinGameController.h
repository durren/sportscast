//
//  JoinGameController.h
//  sunny
//
//  Created by dshen on 10/12/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JoinGameController;
@class HistoryController;

@interface JoinGameController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UITableView *table1;
    NSMutableArray *sportsgamesArray;
    NSInteger *idArray;
    IBOutlet JoinGameController *joinGameController;
    IBOutlet HistoryController *historyController;

}
@property (nonatomic, retain) JoinGameController *joinGameController;
@property (nonatomic, retain) HistoryController *historyController;
@property (retain, nonatomic) IBOutlet UITableView *table1;
@property (nonatomic, retain) NSMutableArray *gamesArray;
@property (nonatomic, retain) NSMutableArray *gameIdArray;
@property (nonatomic, retain) NSMutableArray *sportsGameIdArray;

@end
