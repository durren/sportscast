//
//  ViewController.m
//  sunny
//
//  Created by dshen on 9/24/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "UAirship.h"
#import "UAPush.h"
#import "UAAnalytics.h"
#import "QuestionController.h"

@interface ViewController () 
@end


@implementation ViewController
@synthesize mySwitch;
@synthesize mySwitch1;
@synthesize myLocationManager;
@synthesize items;
@synthesize sportsgamesArray, sportsgamesIdArray;
@synthesize table1;

CLLocationCoordinate2D coordinate;
@synthesize coordinate, title, subtitle;


- (void)viewDidLoad{
    sportsgamesArray = [[NSMutableArray alloc] initWithObjects:nil];
    sportsgamesIdArray = [[NSMutableArray alloc] initWithObjects:nil];
    
    UIDevice *myDevice = [UIDevice currentDevice];
    NSString *urlAsString = @"http://localhost:9000/games/list";
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
            NSArray *sportsGames = [allDataDictionary objectForKey:@"sportsGames"];
            
            for (NSDictionary *diction in sportsGames) {
                NSString *name = [diction objectForKey:@"name"];
                NSString *id = [diction objectForKey:@"id"];
                [self.sportsgamesArray addObject:name];
                [self.sportsgamesIdArray addObject:name];
                
                NSLog(@"string %@", name);
            }
            
            NSLog(@"my array = %@", sportsgamesArray);
            NSLog(@"games array items = %u", [sportsgamesArray count]);
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

#pragma mark - table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sportsgamesArray count];
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    cell.textLabel.text = [self.sportsgamesArray objectAtIndex:indexPath.row];
    
    return cell;
}

//do an action when selecting a particular row, in this case, create a game.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *accessTokenPost = [@"?accessToken=" stringByAppendingString:[FBSession.activeSession accessToken]];
    NSString *sportsGameId = [@"&sportsGameId=" stringByAppendingString:[self.sportsgamesIdArray objectAtIndex:indexPath.row]];
    
    NSString *urlAsString = @"http://localhost:9000/games/create";
    urlAsString = [urlAsString stringByAppendingString:accessTokenPost];
    urlAsString = [urlAsString stringByAppendingString:sportsGameId];
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
    NSString *body = @"bodyParam1=BodyValue1";
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
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
    
    //switch to question view controller
    //QuestionController *qc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionController"];
    //[self presentModalViewController:qc animated:YES];
    [self.tabBarController setSelectedIndex:4];
}

- (void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    //NSLog(@"Latitude = %f", newLocation.coordinate.latitude);
    //NSLog(@"Longitude = %f", newLocation.coordinate.longitude);
}

- (void) locationManager:(CLLocationManager *)manager
        didFailWithError:(NSError *)error {
    //failed to get user's location
}

- (void)viewDidUnload
{
    [table1 release];
    table1 = nil;
    [self setTable1:nil];
    [super viewDidUnload];
    self.myMapView = nil;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [UAirship land];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Updates the device token and registers the token with UA
    [[UAPush shared] registerDeviceToken:deviceToken];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void) updateTable
{
    [table1 reloadData];
}

- (void)dealloc {
    [super dealloc];
}
@end
