//
//  ProfileViewController.m
//  twitter
//
//  Created by Sabrina P Meng on 7/1/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "ProfileViewController.h"
#import "APIManager.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfTweetsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberFollowingLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberFollowersLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self retrieveUserProfile];
}

- (void)retrieveUserProfile {
    [[APIManager shared] getUserProfileWithCompletion:^(NSDictionary *profileDict, NSError *error) {
        if (profileDict) {
            // Nav title
            self.navigationItem.title = profileDict[@"name"];
            
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
