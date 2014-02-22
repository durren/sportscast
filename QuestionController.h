//
//  QuestionController.h
//  sunny
//
//  Created by dshen on 10/2/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QuestionController : UIViewController {
    
    IBOutlet UITextView *question;
    IBOutlet UISlider *slider;
    IBOutlet UILabel *sliderLabel;
    IBOutlet UILabel *pointsLabel;
    
}
@property (nonatomic, strong) UILabel *label;
@property (retain, nonatomic) IBOutlet UITextView *question;
@property (readwrite, retain) NSMutableArray *questionsArray;
@property (retain, nonatomic) IBOutlet UILabel *sliderLabel;
@property (retain, nonatomic) IBOutlet UISlider *slider;
@property (retain, nonatomic) IBOutlet UILabel *pointsLabel;

@property (readwrite, retain) NSMutableArray *answersArray;
@property (readwrite, retain) NSMutableArray *answerIdArray;
@property (readwrite, retain) NSMutableArray *answerOrderArray;

@property (readwrite) NSInteger numQuestions;
@property (readwrite) NSInteger questionNumber;
@property (readwrite) NSInteger answerOrderArrayPos;
@property (readwrite, retain) NSString *answerIdToSend;
@property (readwrite, retain) NSString *points;

- (IBAction)sliderAction:(UISlider*)slider;

@end
