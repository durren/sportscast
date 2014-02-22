//
//  JoinGameController.m
//  sunny
//
//  Created by dshen on 10/12/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//

#import "JoinGameController.h"
#import "AppDelegate.h"
#import "HistoryController.h"

@interface JoinGameController ()

@end


@implementation JoinGameController
@synthesize gamesArray, gameIdArray, sportsGameIdArray, table1;

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
    gamesArray = [[NSMutableArray alloc] initWithObjects:nil];
    gameIdArray = [[NSMutableArray alloc] initWithObjects:nil];
    sportsGameIdArray = [[NSMutableArray alloc] initWithObjects:nil];
    
    UIDevice *myDevice = [UIDevice currentDevice];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *urlAsString = appDelegate.hostURL;
    urlAsString = [urlAsString stringByAppendingString:@"games/list"];
    NSString *deviceIdGet = [@"&deviceToken=" stringByAppendingString:[myDevice uniqueIdentifier]];
    NSString *accessTokenGet = [@"?accessToken=" stringByAppendingString:[FBSession.activeSession accessToken]];
    urlAsString = [urlAsString stringByAppendingString:accessTokenGet];
    urlAsString = [urlAsString stringByAppendingString:deviceIdGet];
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", html);
            
            NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *games = [allDataDictionary objectForKey:@"games"];
            
            for (NSDictionary *diction in games) {
                NSString *id = [diction objectForKey:@"id"];
                [self.gameIdArray addObject:id];
                [gamesArray addObject:[diction objectForKey:@"name"]];
                [sportsGameIdArray addObject:[[diction objectForKey:@"sportsGame"] objectForKey:@"id"]];
            }
            
            NSLog(@"my array = %@", gameIdArray);
            NSLog(@"games array items = %u", [gamesArray count]);
            
            //reload data
            [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
            
        }
        else if ([data length]==0 && error == nil) {
            NSLog(@"Nothing was downloaded");
        } else if (error != nil) {
            NSLog(@"Error happened = %@", error);
        }
    }];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [table1 release];
    [super dealloc];
}
- (void)viewDidUnload {
    [table1 release];
    table1 = nil;
    [self setTable1:nil];
    [super viewDidUnload];
}

-(void) updateTable
{
    [table1 reloadData];
}

#pragma mark - table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.gamesArray count];
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [self.gamesArray objectAtIndex:indexPath.row];

    return cell;
}

//do an action when selecting a particular row, in this case, join a game.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.gameId = [[self.gameIdArray objectAtIndex:indexPath.row] intValue];
    //NSLog(@"game id: %d",[[self.gameIdArray objectAtIndex:indexPath.row] intValue]);
    appDelegate.sportsGameId = [[self.sportsGameIdArray objectAtIndex:indexPath.row] intValue];
    
    [self performSegueWithIdentifier:@"goToHistoryFromJoinGame" sender:self];
}
@end
