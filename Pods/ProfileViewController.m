//
//  ProfileViewController.m
//  twitter
//
//  Created by Sabrina P Meng on 7/1/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "ProfileViewController.h"
#import "APIManager.h"
#import "Tweet.h"
#import "TweetProfileCell.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfTweetsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberFollowingLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberFollowersLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrayOfTweets;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setting table view delegate and data source
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Retrieve profile info
    [self retrieveUserProfile];
    
    // Load tweet data
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    // Refresh view whenever visited
    [self retrieveUserProfile];
    [self loadData];
}

- (void)retrieveUserProfile {
    // API request to get user profile info
    [[APIManager shared] getUserProfileWithCompletion:^(NSDictionary *profileDict, NSError *error) {
        if (profileDict) {
            // Nav title
            self.navigationItem.title = profileDict[@"name"];
            
            // User ID
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject: profileDict[@"id"] forKey:@"userID"];
            [userDefaults synchronize];
            
            // Profile picture
            NSString *URLString = profileDict[@"profile_image_url_https"];
            NSURL *url = [NSURL URLWithString:URLString];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            self.profilePictureView.image = [UIImage imageWithData:urlData];
            
            // Username
            self.usernameLabel.text = profileDict[@"name"];
            
            // Screen name
            self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", profileDict[@"screen_name"]];
            
            // Number of tweets
            self.numberOfTweetsLabel.text = [NSString stringWithFormat:@"%@ Tweets", profileDict[@"statuses_count"]];
            
            // Number following
            self.numberFollowingLabel.text = [NSString stringWithFormat:@"%@ Following", profileDict[@"friends_count"]];
            
            // Number of followers
            self.numberFollowersLabel.text = [NSString stringWithFormat:@"%@ Followers", profileDict[@"followers_count"]];
            
        } else {
            NSLog(@"ERROR: %@", error.localizedDescription);
        }
    }];
}

- (void)loadData {
    // API request to get user tweet info
    [[APIManager shared] getUserTimelineWithCompletion:^(NSArray *tweetArray, NSError *error) {
        if (tweetArray) {
            // Convert array of dictionaries to array of tweets
            self.arrayOfTweets = [Tweet tweetsWithArray:tweetArray];
            
            // Reloading data
            [self.tableView reloadData];
            
            NSLog(@"😎😎😎 Successfully loaded home timeline");
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // Table view dequeueing
    TweetProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetProfileCell"];
    
    // Get appropriate tweet and set text
    Tweet *tweet = self.arrayOfTweets[indexPath.row];
    
    // Updating cell attributes
    [cell setCell:tweet];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTweets.count;
}

@end
