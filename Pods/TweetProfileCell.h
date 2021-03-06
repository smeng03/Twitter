//
//  TweetProfileCell.h
//  twitter
//
//  Created by Sabrina P Meng on 7/1/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

NS_ASSUME_NONNULL_BEGIN

@interface TweetProfileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mediaView;
@property (weak, nonatomic) IBOutlet UILabel *replyLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *loveLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) Tweet *tweet;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;


-(void)setCell:(Tweet *) tweet;

@end

NS_ASSUME_NONNULL_END
