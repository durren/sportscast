//
//  QuestionController.m
//  sunny
//
//  Created by dshen on 10/2/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//

#import "QuestionController.h"
#import "AppDelegate.h"

@implementation QuestionController

@synthesize answerIdToSend;
@synthesize question;
@synthesize sliderLabel;
@synthesize label;
@synthesize numQuestions, questionNumber;
@synthesize questionsArray, answersArray, answerOrderArray, answerIdArray, answerOrderArrayPos, points;

- (void)viewDidLoad
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"%d  THIS IS THE QUESTION ID",appDelegate.questionIdFromHistoryTable);
    self.questionNumber = 0;
    self.answerOrderArrayPos = 0;
    self.questionsArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.answersArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.answerIdArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.answerOrderArray = [[NSMutableArray alloc] initWithObjects:nil];
    
    NSString *urlAsString = appDelegate.hostURL;
    urlAsString = [urlAsString stringByAppendingString:@"questions/getSportsGameQuestions"];
    NSString *accessTokenGet = [@"?accessToken=" stringByAppendingString:[FBSession.activeSession accessToken]];
    NSString *sportsGameIdGet = [@"&sportsGameId=" stringByAppendingString:[NSString stringWithFormat:@"%d",appDelegate.sportsGameId]];
    urlAsString = [urlAsString stringByAppendingString:accessTokenGet];
    urlAsString = [urlAsString stringByAppendingString:sportsGameIdGet];
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSArray *questions = [allDataDictionary objectForKey:@"questions"];
            
            for (NSDictionary *diction in questions) {
                NSString *name = [diction objectForKey:@"question"];
                NSString *questionId = [diction objectForKey:@"id"];
                
                if (appDelegate.questionIdFromHistoryTable == [questionId integerValue]) {
                    if ([[diction objectForKey:@"status"]isEqualToString:@"ASKED"]) {
                        [self.questionsArray addObject:name];
                
                        NSArray *answers = [diction objectForKey:@"answers"];
                        for (NSDictionary *diction1 in answers) {
                            NSString *a1 = [diction1 objectForKey:@"answer"];
                            [self.answersArray addObject:a1];
                            NSString *answerId = [diction1 objectForKey:@"id"];
                            [self.answerIdArray addObject:answerId];
                        }
                    }
                    if ([self.answersArray count] != 0) {
                        [self.answersArray addObject:@"separator"];
                        [self.answerIdArray addObject:@"separator"];
                    }
                }

            }
            
            
            
            NSLog(@"my questions = %@", self.questionsArray);
            self.numQuestions = [self.questionsArray count];
            
            //need to run a piece of UIKit code whle working on different thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self processQnA];
            });
            NSLog(@"my answers = %@", self.answersArray);

        }
        else if ([data length]==0 && error == nil) {
            NSLog(@"Nothing was downloaded");
        } else if (error != nil) {
            NSLog(@"Error happened = %@", error);
        }
    }];
    
    
        
    
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
            NSLog(@"response: %@", html1);
            NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

            points = [allDataDictionary objectForKey:@"pointsBalance"];
            [self performSelectorOnMainThread:@selector(updatePoints:) withObject:points waitUntilDone:YES];
            
        }
        else if ([data length]==0 && error == nil) {
            NSLog(@"Nothing was downloaded");
        } else if (error != nil) {
            NSLog(@"Error happened = %@", error);
        }
    }];
    NSLog(@"POINTS BALANCE1: %@", points);
    
    
    [super viewDidLoad];
}

-(void) updatePoints:(NSString*) p {
    //still have to convert p to a string for some reason
    NSString* myNewString = [NSString stringWithFormat:@"%@", p];
    //self.pointsLabel.text = myNewString;
    [[self pointsLabel] setText:myNewString];
}

- (void)dealloc {

    [sliderLabel release];
    [_slider release];
    [slider release];
    [_pointsLabel release];
    [pointsLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [question release];
    question = nil;
    [self setQuestion:nil];
    [sliderLabel release];
    sliderLabel = nil;
    [self setSliderLabel:nil];
    [self setSlider:nil];
    [slider release];
    slider = nil;
    [self setPointsLabel:nil];
    [pointsLabel release];
    pointsLabel = nil;
    [super viewDidUnload];
}


-(void)processQnA {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"user answer status %@", appDelegate.userAnswerStatus);
    
    if ([appDelegate.userAnswerStatus isEqualToString:@"ANSWERED"]) {
        question.text = @"here are the results!!";
    } else if (self.answerOrderArrayPos+3 > [self.answersArray count] || [appDelegate.userAnswerStatus isEqualToString:@"YOU ANSWERED"]) {
        question.text = @"Wait for the result of this question...";
    } else {
        // As long as there are unanswered questions, keep asking the question and displaying the answers
        
        self.question.text=[self.questionsArray objectAtIndex:self.questionNumber];
        questionNumber++;
        
        NSLog(@"answer array order pos %d", self.answerOrderArrayPos);
        if (self.answerOrderArrayPos > [self.answersArray count]) {
            //no questions and answers
            
        } else {
            if (answerOrderArrayPos != 0)
            {
                answerOrderArrayPos++;
            }
            float verticalPos=140.0f;
            while(![[self.answersArray objectAtIndex:self.answerOrderArrayPos] isEqualToString:@"separator"]) {
                
                //NSLog(@"answer: %@", [self.answersArray objectAtIndex:self.answerOrderArrayPos]);
                UIButton* aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                aButton.frame = CGRectMake(50.0f, verticalPos, 200.0f, 37.0f);
                verticalPos += 40.0f;
                [aButton setTag:[[self.answerIdArray objectAtIndex:self.answerOrderArrayPos] intValue]];
                [aButton setTitle:[self.answersArray objectAtIndex:self.answerOrderArrayPos] forState:UIControlStateNormal];
                [aButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:aButton];
                
                //add bet slider
                [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
                [slider setBackgroundColor:[UIColor whiteColor]];
                slider.minimumValue = 0.0;
                slider.maximumValue = 1000.0;
                slider.continuous = YES;
                slider.value = 500.0;
                [self.view addSubview:slider];
                [self.view addSubview:sliderLabel];
                answerOrderArrayPos++;
            }
        }
    }
;
}

- (void)buttonClicked:(UIButton*)button
{
    //submit the answer to the server
    NSLog(@"AnswerId %ld clicked.", (long int)[button tag]);
    while([self.view.subviews count] > 2) {
        [[self.view.subviews lastObject] removeFromSuperview];
    }
    [self processQnA];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    //Send the answer by HTTP post
    NSString *accessTokenGet = [@"?accessToken=" stringByAppendingString:[FBSession.activeSession accessToken]];
    
    NSString *urlAsString = appDelegate.hostURL;
    urlAsString = [urlAsString stringByAppendingString:@"questions/commitAnswer"];
    urlAsString = [urlAsString stringByAppendingString:accessTokenGet];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&gameId=%d", appDelegate.gameId]];
    urlAsString = [urlAsString stringByAppendingString: [NSString stringWithFormat:@"&answerId=%d", [button tag]]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&points=%@", self.sliderLabel.text]];
    
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
    
}


- (IBAction)sliderAction:(UISlider*)slider {
    int discreteValue = roundl([slider value]); // Rounds float to an integer
    [slider setValue:(float)discreteValue]; // Sets your slider to this value
    sliderLabel.text = [NSString stringWithFormat:@"%1.0f",slider.value];
}

@end
