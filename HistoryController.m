//
//  HistoryController.m
//  sunny
//
//  Created by dshen on 10/2/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//
#define COMMENT_LABEL_WIDTH 230
#define COMMENT_LABEL_MIN_HEIGHT 21
#define COMMENT_LABEL_PADDING 10

#import "HistoryController.h"
#import "AppDelegate.h"
#import "QuestionController.h"
#import "CEPubnub.h"
#import "CEPubnubDelegate.h"
#import "customCell.h"

@implementation HistoryController
@synthesize table, questionsArray, statusArray, questionIdArray, pointsCommittedArray, correctAnswerIdArray, committedAnswerIdArray, answersArray, answerIdArray;
#define kMinRetryInterval 5.0 //In seconds
#define kMinRetry -1

customCell *tempCustomCell;
BOOL allowPubNubUpdate=TRUE, missedUpdate=FALSE, justAnswered=FALSE;
CEPubnub *pubnub;
- (void)viewDidLoad {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    pubnub = [[CEPubnub alloc] initWithPublishKey:@"demo" subscribeKey:@"sub-25362e5c-13dc-11e2-a127-990cbc40176f" secretKey:nil   cipherKey:nil useSSL:NO];
    
    //subscribe to the game channel
    [pubnub setDelegate:self];
    NSString *subscribeToChannelString = [NSString stringWithFormat:@"sportsGame%d", appDelegate.sportsGameId];
    [pubnub subscribe:subscribeToChannelString];
    
    NSString *accessTokenGet = [@"?accessToken=" stringByAppendingString:[FBSession.activeSession accessToken]];
   
    //make call to get the user's points balance
    NSString *urlAsString1 = appDelegate.hostURL;
    urlAsString1 = [urlAsString1 stringByAppendingString:@"login/login"];
    urlAsString1 = [urlAsString1 stringByAppendingString:accessTokenGet];
    NSURL *url1 = [NSURL URLWithString:urlAsString1];
    NSMutableURLRequest *urlRequest1 = [NSMutableURLRequest requestWithURL:url1];
    
    [urlRequest1 setTimeoutInterval:30.0f];
    [urlRequest1 setHTTPMethod:@"GET"];
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest1 queue:queue1 completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            NSString *html1 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSString *points = [allDataDictionary objectForKey:@"pointsBalance"];
            [self performSelectorOnMainThread:@selector(updatePoints:) withObject:points waitUntilDone:YES];
            
        }
        else if ([data length]==0 && error == nil) {
            NSLog(@"Nothing was downloaded");
        } else if (error != nil) {
            NSLog(@"Error happened = %@", error);
        }
    }];
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    //set set our selected Index to -1 to indicate no cell will be expanded
    selectedIndex = -1;
    
    //reload data
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    //block interaction events
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    //add spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(300, 395);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    [spinner release];
    self.questionIdArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.questionsArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.statusArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.pointsCommittedArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.correctAnswerIdArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.committedAnswerIdArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.answersArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.answerIdArray = [[NSMutableArray alloc] initWithObjects:nil];
    
    NSString *urlAsString = appDelegate.hostURL;
    urlAsString = [urlAsString stringByAppendingString:@"questions/getSportsGameQuestions"];
    NSString *accessTokenGet = [@"?accessToken=" stringByAppendingString:[FBSession.activeSession accessToken]];
    NSString *sportsGameIdGet = [@"&sportsGameId=" stringByAppendingString:[NSString stringWithFormat:@"%d",appDelegate.sportsGameId]];
    NSString *gameIdGet = [@"&gameId=" stringByAppendingString:[NSString stringWithFormat:@"%d",appDelegate.gameId]];
    urlAsString = [urlAsString stringByAppendingString:accessTokenGet];
    urlAsString = [urlAsString stringByAppendingString:sportsGameIdGet];
    urlAsString = [urlAsString stringByAppendingString:gameIdGet];
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if ([data length] > 0 && error == nil) {
            data1=data;
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@" THIS IS WGHAT U NEED %@", html);
            NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSArray *questions = [allDataDictionary objectForKey:@"questions"];
            
            for (NSDictionary *diction in questions) {
                NSString *questionId = [diction objectForKey:@"id"];
                [self.questionIdArray addObject:questionId];
                NSString *name = [diction objectForKey:@"question"];
                [self.questionsArray addObject:name];
                NSString *status = [diction objectForKey:@"status"];
                [self.statusArray addObject:status];
                if ([diction objectForKey:@"correctAnswerId"] != nil) {
                    NSString *correctAnswerId = [diction objectForKey:@"correctAnswerId"];
                    [self.correctAnswerIdArray addObject:correctAnswerId];
                } else {
                    [self.correctAnswerIdArray addObject:@"no result yet"];
                }
                
                if ([[[diction objectForKey:@"committedAnswers"] objectForKey:@"userAnswer"]objectForKey:@"pointsCommitted"]!= nil) {
                    [self.pointsCommittedArray addObject:[[[diction objectForKey:@"committedAnswers"] objectForKey:@"userAnswer"]objectForKey:@"pointsCommitted"]];
                    [self.committedAnswerIdArray addObject:[[[diction objectForKey:@"committedAnswers"] objectForKey:@"userAnswer"]objectForKey:@"answerId"]];
                    
                } else {
                    [self.pointsCommittedArray addObject:@"0"];
                    [self.committedAnswerIdArray addObject:@"no user answer"];
                }
                
                    NSArray *answers = [diction objectForKey:@"answers"];
                    for (NSDictionary *diction1 in answers) {
                        NSString *a1 = [diction1 objectForKey:@"answer"];
                        [self.answersArray addObject:a1];
                        NSString *answerId = [diction1 objectForKey:@"id"];
                        [self.answerIdArray addObject:answerId];
                    }
                
                if ([self.answersArray count] != 0) {
                    [self.answersArray addObject:@"separator"];
                    [self.answerIdArray addObject:@"separator"];
                }
            }
            
            NSLog(@"%@", answersArray);
            NSLog(@"%@", answerIdArray);
            
            //reload data
            [spinner stopAnimating];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
        }
        else if ([data length]==0 && error == nil) {
            NSLog(@"Nothing was downloaded");
        } else if (error != nil) {
            NSLog(@"Error happened = %@", error);
        }
    }];
}

-(void) updatePoints:(NSString*) p {
    //still have to convert p to a string for some reason
    NSString* myNewString = [NSString stringWithFormat:@"%@", p];
    //self.pointsLabel.text = myNewString;
    [[self pointsLabel] setText:myNewString];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.questionsArray count];
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(customCell *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    customCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
    int resultsIn = 0;
    
    if (cell == nil) {
        //cell = [[[exerciseListUITableCell alloc] init] autorelease];
        
        NSArray * topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"customCell" owner:self options:nil];
        
        for(id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (customCell *)currentObject;
                break;
            }
        }
    }
    /*if (cell == nil) {
        cell = [[customCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }*/
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    cell.customTextLabel.text = [self.questionsArray objectAtIndex:indexPath.row];
    if ([[self.pointsCommittedArray objectAtIndex:indexPath.row] intValue] == 0 && [[self.statusArray objectAtIndex:indexPath.row] isEqualToString:@"ASKED"]) {
        resultsIn=2;
        //no points committed and status is ASKED (didn't answer question yet)
        cell.customDetailTextLabel.text = @"ANSWER ME!!";
        imgView.image = [UIImage imageNamed:@"greenlight.png"];
        cell.customImageView.image = imgView.image;
    } else if ([[self.pointsCommittedArray objectAtIndex:indexPath.row] intValue] == 0 && [(NSString *)[self.statusArray objectAtIndex:indexPath.row] isEqualToString:@"QUESTION_AMENDED"]) {
        //amended question with no answer yet
        cell.customDetailTextLabel.text = @"QUESTION AMENDED, ANSWER ME!";
        imgView.image = [UIImage imageNamed:@"greenlight.png"];
        cell.customImageView.image = imgView.image;
    } else if ([(NSString *)[self.statusArray objectAtIndex:indexPath.row] isEqualToString:@"ANSWERED"] && [[self.pointsCommittedArray objectAtIndex:indexPath.row] intValue] == 0) {
        //producer ANSWERED, but you did not answer
        resultsIn=1;
        cell.customDetailTextLabel.text = @"RESULTS IN, YOU DID NOT ANSWER";
        imgView.image = [UIImage imageNamed:@"OrangeMiss.png"];
        cell.customImageView.image = imgView.image;
    } else if ([(NSString *)[self.statusArray objectAtIndex:indexPath.row] isEqualToString:@"ANSWERED"]) {
        //producer ANSWERED, and you answered 
        resultsIn=1;
        if ([[self.committedAnswerIdArray objectAtIndex:indexPath.row] isEqualToNumber:[self.correctAnswerIdArray objectAtIndex:indexPath.row]]) {
            NSString *txtString = @"+";
            txtString = [txtString stringByAppendingString:[[self.pointsCommittedArray objectAtIndex:indexPath.row] stringValue]];
            cell.customDetailTextLabel.text = txtString;
            imgView.image = [UIImage imageNamed:@"greenCheckmark.png"];
        } else {
            NSString *txtString = @"-";
            txtString = [txtString stringByAppendingString:[[self.pointsCommittedArray objectAtIndex:indexPath.row] stringValue]];
            cell.customDetailTextLabel.text = txtString;
            imgView.image = [UIImage imageNamed:@"red_x.png"];
        }
        cell.customImageView.image = imgView.image;
    } else if ([(NSString *)[self.statusArray objectAtIndex:indexPath.row] isEqualToString:@"CLOSED"] && [[self.pointsCommittedArray objectAtIndex:indexPath.row] intValue] == 0) {
        //if the status is CLOSED and you didn't answer the question!
        cell.customDetailTextLabel.text = @"CLOSED, YOU DID NOT ANSWER";
        imgView.image = [UIImage imageNamed:@"redlight.png"];
        cell.customImageView.image = imgView.image;
    } else if ([(NSString *)[self.statusArray objectAtIndex:indexPath.row] isEqualToString:@"CLOSED"]) {
        //if the status is CLOSED
        cell.customDetailTextLabel.text = @"YOU ANSWERED, CLOSED";
        imgView.image = [UIImage imageNamed:@"hourglass.png"];
        cell.customImageView.image = imgView.image;
    } else if ([(NSString *)[self.statusArray objectAtIndex:indexPath.row] isEqualToString:@"ASKED"]) {
        //if the status is ASKED but the user has answered it
        cell.customDetailTextLabel.text = @"YOU ANSWERED";
        imgView.image = [UIImage imageNamed:@"hourglass.png"];
        cell.customImageView.image = imgView.image;
    } else {
        cell.customDetailTextLabel.text = [self.statusArray objectAtIndex:indexPath.row];
        //imgView.image = [UIImage imageNamed:@"greenlight.png"];
        //cell.customImageView.image = imgView.image;
    }
    
#pragma mark expand and do stuff row selected
    if(selectedIndex == indexPath.row && resultsIn==2)
    {
        
        CGFloat labelHeight = 300;
        cell.customDetailTextLabel.text= @"CHOOSE YOUR BET SIZE, THEN ANSWER";
        cell.customDetailTextLabel.frame = CGRectMake(cell.customDetailTextLabel.frame.origin.x,
                                                 cell.customDetailTextLabel.frame.origin.y,
                                                 cell.customDetailTextLabel.frame.size.width,
                                                 labelHeight);
        cell.sliderLabel.hidden=NO;
        cell.slider.hidden=NO;
        cell.betLabel.hidden=NO;
        [cell.slider addTarget:cell action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        [cell.slider setBackgroundColor:[UIColor whiteColor]];
        cell.slider.minimumValue = 1.0;
        cell.slider.maximumValue = 1000.0;
        cell.slider.continuous = YES;
        cell.slider.value = 500.0;
        [cell.cellview addSubview:cell.slider];
        [cell.cellview addSubview:cell.sliderLabel];
        
        NSInteger i=indexPath.row, j=0;
        while (i >= 1) {
            if ([[self.answersArray objectAtIndex:j] isEqualToString:@"separator"]) {
                i--;
            }
            j++;
        }
        if (j <= 2) {
            j=0;
        }
        NSLog(@"wa laaaa:   %@", [self.answersArray objectAtIndex:j]);
        NSLog(@"wa laaaa:   %@", [self.answersArray objectAtIndex:j+1]);
        NSLog(@"wa laaaa:   %@", [self.answerIdArray objectAtIndex:j]);
        NSLog(@"wa laaaa:   %@", [self.answerIdArray objectAtIndex:j+1]);
        
        float verticalPos=60.0f;
        while (![(NSString *)[self.answersArray objectAtIndex:j] isEqualToString:@"separator"]) {
            //NSLog(@"answer: %@", [self.answersArray objectAtIndex:self.answerOrderArrayPos]);
            UIButton* aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            aButton.frame = CGRectMake(50.0f, verticalPos, 200.0f, 37.0f);
            verticalPos += 40.0f;
            [aButton setTag:[[self.answerIdArray objectAtIndex:j] intValue]];
            [aButton setTitle:[self.answersArray objectAtIndex:j] forState:UIControlStateNormal];
            tempCustomCell = cell;
            [aButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.cellview addSubview:aButton];
            j++;
        }
        
        
        
    } else if (selectedIndex == indexPath.row && resultsIn==1) {
        CGFloat labelHeight = 300;
        cell.customDetailTextLabel.text= @"RESULTS OF THIS QUESTION";
        cell.customDetailTextLabel.frame = CGRectMake(cell.customDetailTextLabel.frame.origin.x,
                                                      cell.customDetailTextLabel.frame.origin.y,
                                                      cell.customDetailTextLabel.frame.size.width,
                                                      labelHeight);
        
    } else {
        //Otherwise just return the minimum height for the label.
        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x,
                                                 cell.textLabel.frame.origin.y,
                                                 cell.textLabel.frame.size.width,
                                                 COMMENT_LABEL_MIN_HEIGHT);
        
    }
    return cell;
}

//do an action when selecting a particular row, in this case, load the question.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
    //The user is selecting the cell which is currently expanded
    //we want to minimize it back
    if(selectedIndex == indexPath.row)
    {
        allowPubNubUpdate=TRUE;
        selectedIndex = -1;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (missedUpdate == TRUE) {
            [self makeAjaxCall];
            missedUpdate = FALSE;
        } else if (justAnswered == TRUE) {
            [self makeAjaxCall];
            justAnswered = FALSE;
        }
        
        return;
    }
        
    //First we check if a cell is already expanded.
    //If it is we want to minimize make sure it is reloaded to minimize it back
    if(selectedIndex >= 0)
    {
        NSIndexPath *previousPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        selectedIndex = indexPath.row;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousPath] withRowAnimation:UITableViewRowAnimationFade];
    }
        
    //Finally set the selected index to the new selection and reload it to expand
    allowPubNubUpdate=FALSE;
    selectedIndex = indexPath.row;
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
}

#pragma mark table view expand functions
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //If this is the selected index we need to return the height of the cell
    //in relation to the label height otherwise we just return the minimum label height with padding
    if(selectedIndex == indexPath.row)
    {
        return 300 + COMMENT_LABEL_PADDING * 2;
    }
    else {
        return COMMENT_LABEL_MIN_HEIGHT + COMMENT_LABEL_PADDING * 2;
    }
}

-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //We only don't want to allow selection on any cells which cannot be expanded
    //expand the cell if there the producer ANSWERED only
    //if ([(NSString *)[self.statusArray objectAtIndex:indexPath.row] isEqualToString:@"ANSWERED"]) {
    return indexPath;
    /*    NSLog(@"index path returned");
    }
    else {
        
        //ask a question
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.userAnswerStatus = @"nothing";
        //if you answered the question or the question was answered by the producer
        if ([(NSString *)[self.statusArray objectAtIndex:indexPath.row] isEqualToString:@"ASKED"] && [[self.pointsCommittedArray objectAtIndex:indexPath.row] intValue] > 0) {
            appDelegate.userAnswerStatus = @"YOU ANSWERED";
        } else if ([(NSString *)[self.statusArray objectAtIndex:indexPath.row] isEqualToString:@"ANSWERED"]) {
            appDelegate.userAnswerStatus = @"ANSWERED";
        }
        appDelegate.questionIdFromHistoryTable = [[self.questionIdArray objectAtIndex:indexPath.row] intValue];
        // Configure the new view controller here.
        
        [self performSegueWithIdentifier:@"historyToQuestion" sender:self];
        return nil;
    }*/
}

-(void) updateTable
{
    [table reloadData];
}

- (void)dealloc {
    [table release];
    [_pointsLabel release];
    [pointsLabel release];
    [pubnub unsubscribeFromAllChannels];
    [pubnub release];
    [super dealloc];
    NSLog(@"EXITED");
}
- (void)viewDidUnload {
    [table release];
    table = nil;
    [self setTable:nil];
    [self setPointsLabel:nil];
    [pointsLabel release];
    pointsLabel = nil;
    [super viewDidUnload];
}


#pragma mark pubnubbie functions
- (void)pubnub:(CEPubnub *)pubnub
subscriptionDidReceiveDictionary:(NSDictionary *)message
     onChannel:(NSString *)channel
{
    if (allowPubNubUpdate==TRUE) {
    /*[txt setText:[NSString stringWithFormat:@"sub on channel (dict) : %@ - received:\n %@", channel, message]];
    NSLog(@"Subscribe   %@",message);
    NSDictionary* disc=(NSDictionary*)message;
    for (NSString *key in [disc allKeys]) {
        NSString *val=(NSString *)[disc objectForKey:key];
        NSLog(@"%@-->   %@",key,val);
    }*/
    
    [self makeAjaxCall];
    } else {
        [self playTone];
        missedUpdate=TRUE;
        
    }
}

- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveArray:(NSArray *)message onChannel:(NSString *)channel{
    NSLog(@"Subscribe   %@",message);
}
- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveString:(NSString *)message onChannel:(NSString *)channel{
    NSLog(@"Subscribe   %@",message);
}

- (void) makeAjaxCall {
    [self playTone];
    NSLog(@"sound");
    
    //block interaction events
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.questionIdArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.questionsArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.statusArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.pointsCommittedArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.correctAnswerIdArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.committedAnswerIdArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.answersArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.answerIdArray = [[NSMutableArray alloc] initWithObjects:nil];
    
    NSString *urlAsString = appDelegate.hostURL;
    urlAsString = [urlAsString stringByAppendingString:@"questions/getSportsGameQuestions"];
    NSString *accessTokenGet = [@"?accessToken=" stringByAppendingString:[FBSession.activeSession accessToken]];
    NSString *sportsGameIdGet = [@"&sportsGameId=" stringByAppendingString:[NSString stringWithFormat:@"%d",appDelegate.sportsGameId]];
    NSString *gameIdGet = [@"&gameId=" stringByAppendingString:[NSString stringWithFormat:@"%d",appDelegate.gameId]];
    urlAsString = [urlAsString stringByAppendingString:accessTokenGet];
    urlAsString = [urlAsString stringByAppendingString:sportsGameIdGet];
    urlAsString = [urlAsString stringByAppendingString:gameIdGet];
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"%@", html);
            NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSArray *questions = [allDataDictionary objectForKey:@"questions"];
            
            for (NSDictionary *diction in questions) {
                NSString *questionId = [diction objectForKey:@"id"];
                [self.questionIdArray addObject:questionId];
                NSString *name = [diction objectForKey:@"question"];
                [self.questionsArray addObject:name];
                NSString *status = [diction objectForKey:@"status"];
                [self.statusArray addObject:status];
                if ([diction objectForKey:@"correctAnswerId"] != nil) {
                    NSString *correctAnswerId = [diction objectForKey:@"correctAnswerId"];
                    [self.correctAnswerIdArray addObject:correctAnswerId];
                } else {
                    [self.correctAnswerIdArray addObject:@"no result yet"];
                }
                
                if ([[[diction objectForKey:@"committedAnswers"] objectForKey:@"userAnswer"]objectForKey:@"pointsCommitted"]!= nil) {
                    [self.pointsCommittedArray addObject:[[[diction objectForKey:@"committedAnswers"] objectForKey:@"userAnswer"]objectForKey:@"pointsCommitted"]];
                    [self.committedAnswerIdArray addObject:[[[diction objectForKey:@"committedAnswers"] objectForKey:@"userAnswer"]objectForKey:@"answerId"]];
                    
                } else {
                    [self.pointsCommittedArray addObject:@"0"];
                    [self.committedAnswerIdArray addObject:@"no user answer"];
                }
                
                NSArray *answers = [diction objectForKey:@"answers"];
                for (NSDictionary *diction1 in answers) {
                    NSString *a1 = [diction1 objectForKey:@"answer"];
                    [self.answersArray addObject:a1];
                    NSString *answerId = [diction1 objectForKey:@"id"];
                    [self.answerIdArray addObject:answerId];
                }
                
                if ([self.answersArray count] != 0) {
                    [self.answersArray addObject:@"separator"];
                    [self.answerIdArray addObject:@"separator"];
                }
            }
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            //reload data
            
            [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
            
        }
        else if ([data length]==0 && error == nil) {
            NSLog(@"Nothing was downloaded");
        } else if (error != nil) {
            NSLog(@"Error happened = %@", error);
        }
    }];
}

- (void) playTone {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue, ^(void) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *filePath;
        filePath = [mainBundle pathForResource:@"notification_tone" ofType:@"mp3"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData error:&error];
        if (self.audioPlayer != nil) {
            self.audioPlayer.delegate = self;
            if ([self.audioPlayer prepareToPlay] && [self.audioPlayer play]) {
                //started playing
            } else {
                //failed to play
            }
        } else {
            //failed to instantiate player
        }
    });
    NSLog(@"sound");
}

- (void)buttonClicked:(UIButton*)button
{
    //submit the answer to the server
    NSLog(@"AnswerId %ld clicked.", (long int)[button tag]);
    button.tintColor=[UIColor redColor];
 

    while([tempCustomCell.cellview.subviews count] > 1) {
        [[tempCustomCell.cellview.subviews lastObject] removeFromSuperview];
    }
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    //Send the answer by HTTP post
    NSString *accessTokenGet = [@"?accessToken=" stringByAppendingString:[FBSession.activeSession accessToken]];
    
    NSString *urlAsString = appDelegate.hostURL;
    urlAsString = [urlAsString stringByAppendingString:@"questions/commitAnswer"];
    urlAsString = [urlAsString stringByAppendingString:accessTokenGet];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&gameId=%d", appDelegate.gameId]];
    urlAsString = [urlAsString stringByAppendingString: [NSString stringWithFormat:@"&answerId=%d", [button tag]]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&points=%@", tempCustomCell.sliderLabel.text]];
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
    NSString *body = @"bodyParam1=BodyValue1";
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"sending answer POST: %@", urlAsString);
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
    justAnswered=TRUE;
    
}

@end
