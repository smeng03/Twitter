//
//  DetailsViewController.m
//  twitter
//
//  Created by Sabrina P Meng on 6/30/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "DetailsViewController.h"
#import "DateTools.h"
#import "APIManager.h"

@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweetLabel;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *replyLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *loveLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configuring text view, not scrollable and detects links
    self.tweetLabel.editable = NO;
    self.tweetLabel.dataDetectorTypes = UIDataDetectorTypeAll;
    
    // Setting nav bar title
    self.navigationItem.title = [NSString stringWithFormat:@"%@'s Tweet", self.tweet.user.name];
    
    // Setting UI attributes
    self.usernameLabel.text = self.tweet.user.name;
    self.tweetLabel.text = self.tweet.text;
    self.retweetLabel.text = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
    self.loveLabel.text = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
    self.replyLabel.text = [NSString stringWithFormat:@"%d", self.tweet.replyCount];
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", self.tweet.user.screenName];
    self.dateLabel.text = self.tweet.createdAtString;
    
    // Converting posted date to nice format and writing to UI
    NSString *postedDateString = self.tweet.origCreatedAtString;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"E MMM d HH:mm:ss Z y";
    NSDate *postedDate = [dateFormat dateFromString:postedDateString];
    self.dateLabel.text = postedDate.shortTimeAgoSinceNow;
    
    // Checks status of favorite
    if (self.tweet.favorited) {
        [self.likeButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
    } else {
        [self.likeButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
    }
    
    // Checks status of retweet
    if (self.tweet.retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
    }
    
    // Retrieve image and set image
    NSString *URLString = self.tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    self.profilePictureView.image = nil;
    self.profilePictureView.image = [UIImage imageWithData:urlData];
}

// Controls retweet button
- (IBAction)didTapRetweet:(id)sender {
    if (self.tweet.retweeted) {
        // Unretweeted, decrement, gray retweet button
        self.tweet.retweeted = false;
        self.tweet.retweetCount -= 1;
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
        
        // Post unretweet to server
        [[APIManager shared] unretweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
             if(error){
                  NSLog(@"Error unretweeting tweet: %@", error.localizedDescription);
             }
             else{
                 [self refreshData];
                 NSLog(@"Successfully unretweeted the following Tweet: %@", tweet.text);
             }
         }];
    } else {
        // Retweeted, increment, green retweet button
        self.tweet.retweeted = true;
        self.tweet.retweetCount += 1;
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
        
        // Post retweet to server
        [[APIManager shared] retweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
             if(error){
                  NSLog(@"Error retweeting tweet: %@", error.localizedDescription);
             }
             else{
                 [self refreshData];
                 NSLog(@"Successfully retweeted the following Tweet: %@", tweet.text);
             }
         }];
    }
}

// Controls favorite button
- (IBAction)didTapFavorite:(id)sender {
    if (self.tweet.favorited) {
        // Unfavorited, decrement, gray favorite button
        self.tweet.favorited = false;
        self.tweet.favoriteCount -= 1;
        [self.likeButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
        
        // Post unfavoriting to server
        [[APIManager shared] unfavorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
             if(error){
                  NSLog(@"Error unfavoriting tweet: %@", error.localizedDescription);
             }
             else{
                 [self refreshData];
                 NSLog(@"Successfully unfavorited the following Tweet: %@", tweet.text);
             }
        }];
    } else {
        // Favorited, increment, red favorite button
        self.tweet.favorited = true;
        self.tweet.favoriteCount += 1;
        [self.likeButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
        
        // Post favoriting to server
        [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
             if(error){
                  NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
             }
             else{
                 [self refreshData];
                 NSLog(@"Successfully favorited the following Tweet: %@", tweet.text);
             }
     }];
    }
}

-(void)refreshData {
    // Refreshes tweet cell data
    self.usernameLabel.text = self.tweet.user.screenName;
    self.tweetLabel.text = self.tweet.text;
    self.retweetLabel.text = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
    self.loveLabel.text = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
    self.replyLabel.text = [NSString stringWithFormat:@"%d", self.tweet.replyCount];
    
    // Retrieve image and set image
    NSString *URLString = self.tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    self.profilePictureView.image = nil;
    self.profilePictureView.image = [UIImage imageWithData:urlData];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
