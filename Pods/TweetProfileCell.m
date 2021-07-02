//
//  TweetProfileCell.m
//  twitter
//
//  Created by Sabrina P Meng on 7/1/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "TweetProfileCell.h"
#import "APIManager.h"
#import "DateTools.h"
#import <QuartzCore/QuartzCore.h>

@implementation TweetProfileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)refreshData {
    // Refreshes data in cell
    self.usernameLabel.text = self.tweet.user.name;
    self.tweetLabel.text = self.tweet.text;
    self.retweetLabel.text = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
    self.loveLabel.text = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
    self.replyLabel.text = [NSString stringWithFormat:@"%d", self.tweet.replyCount];
    
    // Retrieve image and set image
    NSString *URLString = self.tweet.user.profilePicture;
    [URLString stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    // Setting profile image
    self.profilePictureView.image = nil;
    self.profilePictureView.image = [UIImage imageWithData:urlData];
}

-(void)setCell:(Tweet *) tweet {
    // Writing in tweet info
    self.tweet = tweet;
    self.usernameLabel.text = tweet.user.name;
    self.tweetLabel.text = tweet.text;
    self.retweetLabel.text = [NSString stringWithFormat:@"%d", tweet.retweetCount];
    self.loveLabel.text = [NSString stringWithFormat:@"%d", tweet.favoriteCount];
    self.replyLabel.text = [NSString stringWithFormat:@"%d", tweet.replyCount];
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    self.dateLabel.text = tweet.createdAtString;
    
    // Converting posted date to nice format and writing to UI
    NSString *postedDateString = tweet.origCreatedAtString;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"E MMM d HH:mm:ss Z y";
    NSDate *postedDate = [dateFormat dateFromString:postedDateString];
    self.dateLabel.text = postedDate.shortTimeAgoSinceNow;
    
    // Checks status of favorite
    if (tweet.favorited) {
        [self.likeButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
    } else {
        [self.likeButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
    }
    
    // Checks status of retweet
    if (tweet.retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
    }
    
    // Retrieve media
    NSString *mediaURLString = tweet.media[0][@"media_url_https"];
    NSURL *mediaURL = [NSURL URLWithString:mediaURLString];
    NSData *mediaURLData = [NSData dataWithContentsOfURL:mediaURL];
    
    self.mediaView.image = nil;
    if (mediaURLData) {
        // CGFloat width = [UIScreen mainScreen].bounds.size.width;
        self.mediaView.image = [UIImage imageWithData:mediaURLData];
    }
    
    self.mediaView.layer.cornerRadius = 10;
    self.mediaView.clipsToBounds = YES;
    
    // Retrieve image and set image
    NSString *URLString = tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    self.profilePictureView.image = nil;
    self.profilePictureView.image = [UIImage imageWithData:urlData];
    self.mediaView.layer.cornerRadius = 5;
    self.mediaView.clipsToBounds = YES;
    
    // Selection style none to prevent highlighting of selected cell
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

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


@end
