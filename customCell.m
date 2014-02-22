//
//  customCell.m
//  sunny
//
//  Created by Durren Shen on 10/20/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//

#import "customCell.h"
#import "AppDelegate.h"

@implementation customCell
@synthesize sliderLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [customTextLabel release];
    [customDetailTextLabel release];
    [customImageView release];
    [cellview release];
    [_cellview release];
    [_betLabel release];
    [betLabel release];
    [super dealloc];
}

#pragma mark question functions
- (void)buttonClicked:(UIButton*)button
{
    //submit the answer to the server
    NSLog(@"AnswerId %ld clicked.", (long int)[button tag]);

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
