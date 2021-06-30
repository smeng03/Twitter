//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "APIManager.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TweetCell.h"
#import "ComposeViewController.h"
#import "DateTools.h"
#import "DetailsViewController.h"

@interface TimelineViewController () <ComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrayOfTweets;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Assigning data source and delegate
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self loadData];
    
    // Pull to refresh setup
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

-(void)viewWillAppear:(BOOL)animated {
    [self loadData];
}

-(void)loadData {
    // Get timeline
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            [self.refreshControl endRefreshing];
            self.arrayOfTweets = tweets;
            
            // Reloading data
            [self.tableView reloadData];
            
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            /*
            for (NSDictionary *dictionary in tweets) {
                NSString *text = dictionary[@"text"];
                NSLog(@"%@", text);
            }
            */
            
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)triggerLogout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // Logging out and swtiching to login view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    
    // Clearing access tokens
    [[APIManager shared] logout];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    // Table view dequeueing
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    // Get appropriate tweet and set text
    Tweet *tweet = self.arrayOfTweets[indexPath.row];
    
    // Writing in tweet info
    cell.tweet = tweet;
    cell.usernameLabel.text = tweet.user.name;
    cell.tweetLabel.text = tweet.text;
    cell.retweetLabel.text = [NSString stringWithFormat:@"%d", tweet.retweetCount];
    cell.loveLabel.text = [NSString stringWithFormat:@"%d", tweet.favoriteCount];
    cell.replyLabel.text = [NSString stringWithFormat:@"%d", tweet.replyCount];
    cell.screenNameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    cell.dateLabel.text = tweet.createdAtString;
    
    // Configuring text view, not scrollable or editable and detects links
    cell.tweetLabel.editable = NO;
    cell.tweetLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    
    // Make text view tappable
    [cell.tweetLabel setUserInteractionEnabled:false];
    [cell.tweetLabel addGestureRecognizer:self.tapRecognizer];
    [cell.tweetLabel setSelectable:true];
    
    // Converting posted date to nice format and writing to UI
    NSString *postedDateString = tweet.origCreatedAtString;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"E MMM d HH:mm:ss Z y";
    NSDate *postedDate = [dateFormat dateFromString:postedDateString];
    cell.dateLabel.text = postedDate.shortTimeAgoSinceNow;
    
    // Checks status of favorite
    if (tweet.favorited) {
        [cell.likeButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
    } else {
        [cell.likeButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
    }
    
    // Checks status of retweet
    if (tweet.retweeted) {
        [cell.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
    } else {
        [cell.retweetButton setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
    }
    
    // Retrieve image and set image
    NSString *URLString = tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    cell.profilePictureView.image = nil;
    cell.profilePictureView.image = [UIImage imageWithData:urlData];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTweets.count;
}

-(void)didTweet:(Tweet *)tweet {
    [self.arrayOfTweets insertObject:tweet atIndex:0];
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Identify tapped cell
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    
    // Get movie corresponding to the cell
    Tweet *tweet = self.arrayOfTweets[indexPath.row];
    
    // Send information
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.tweet = tweet;
}

@end
