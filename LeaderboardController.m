//
//  LeaderboardController.m
//  sunny
//
//  Created by dshen on 10/17/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//

#import "LeaderboardController.h"
#import "AppDelegate.h"

@interface LeaderboardController ()

@end

@implementation LeaderboardController
@synthesize table, nameArray, pointsGainedArray, pointsPlayedArray, facebookUserIdArray, questionsAttemptedArray, questionsCorrectArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSString *subscribeToChannelString = [NSString stringWithFormat:@"sportsGame%d", appDelegate.sportsGameId];
    
    //add spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    [spinner release];
    self.nameArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.pointsPlayedArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.pointsGainedArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.facebookUserIdArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.questionsAttemptedArray = [[NSMutableArray alloc] initWithObjects:nil];
    self.questionsCorrectArray = [[NSMutableArray alloc] initWithObjects:nil];
    
    NSString *urlAsString = appDelegate.hostURL;
    urlAsString = [urlAsString stringByAppendingString:@"games/getGamePlayers"];
    NSString *accessTokenGet = [@"?accessToken=" stringByAppendingString:[FBSession.activeSession accessToken]];
    NSString *gameIdGet = [@"&gameId=" stringByAppendingString:[NSString stringWithFormat:@"%d",appDelegate.gameId]];
    urlAsString = [urlAsString stringByAppendingString:accessTokenGet];
    urlAsString = [urlAsString stringByAppendingString:gameIdGet];
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", html);
            //NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for (NSDictionary *diction in array) {
                NSString *pointsGained = [diction objectForKey:@"pointsGained"];
                [self.pointsGainedArray addObject:pointsGained];
                NSString *pointsPlayed = [diction objectForKey:@"pointsPlayed"];
                [self.pointsPlayedArray addObject:pointsPlayed];
                NSString *questionsAttempted = [diction objectForKey:@"questionsAttempted"];
                [self.questionsAttemptedArray addObject:questionsAttempted];
                NSString *questionsCorrect = [diction objectForKey:@"questionsCorrect"];
                [self.questionsCorrectArray addObject:questionsCorrect];
                [self.nameArray addObject:[[diction objectForKey:@"user"] objectForKey:@"name"]];
                [self.facebookUserIdArray addObject:[[diction objectForKey:@"user"] objectForKey:@"facebookUserId"]];
            }
            [spinner stopAnimating];
            //reload data, otherwise table won't load data after http call
            [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];

        }
        else if ([data length]==0 && error == nil) {
            NSLog(@"Nothing was downloaded");
        } else if (error != nil) {
            NSLog(@"Error happened = %@", error);
        }
    }];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateTable
{
    [table reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.nameArray count];
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    NSString *urlAsString1 = @"http://graph.facebook.com/";
    urlAsString1 = [urlAsString1 stringByAppendingString:[self.facebookUserIdArray objectAtIndex:indexPath.row]];
    urlAsString1 = [urlAsString1 stringByAppendingString:@"/picture"];
    NSString *rankAndName = [NSString stringWithFormat:@"#%d ",indexPath.row+1];
    rankAndName = [rankAndName stringByAppendingString:[NSString stringWithFormat:@"%@",[self.nameArray objectAtIndex:indexPath.row]]];
    cell.textLabel.text = rankAndName;
    NSString *correctDivAttempted = [NSString stringWithFormat:@"%@",[self.questionsCorrectArray objectAtIndex:indexPath.row]];
    correctDivAttempted = [correctDivAttempted stringByAppendingString:@"/"];
    correctDivAttempted = [correctDivAttempted stringByAppendingString:[NSString stringWithFormat:@"%@",[self.questionsAttemptedArray objectAtIndex:indexPath.row]]];
    NSInteger currentPoints = [[self.pointsGainedArray objectAtIndex:indexPath.row] intValue] - [[self.pointsPlayedArray objectAtIndex:indexPath.row] intValue];
    NSString *currentPointsString = [NSString stringWithFormat:@"Points: %d Accuracy: ",currentPoints];
    currentPointsString = [currentPointsString stringByAppendingString:correctDivAttempted];
    
    cell.detailTextLabel.text = currentPointsString;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    imgView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlAsString1]]];
    cell.imageView.image = imgView.image;
    
    NSLog(@"%@", urlAsString1);
    return cell;
}

//do an action when selecting a particular row
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//}

- (void)dealloc {
    [table release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTable:nil];
    [table release];
    table = nil;
    [super viewDidUnload];
}
@end
