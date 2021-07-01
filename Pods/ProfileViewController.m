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

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self retrieveUserProfile];
}

- (void)retrieveUserProfile {
    [[APIManager shared] getUserProfileWithCompletion:^(NSDictionary *profileDict, NSError *error) {
        if (profileDict) {
            NSLog(@"%@", profileDict);
            
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
