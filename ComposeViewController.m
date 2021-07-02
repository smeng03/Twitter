//
//  ComposeViewController.m
//  twitter
//
//  Created by Sabrina P Meng on 6/29/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"
#import "AppDelegate.h"

@interface ComposeViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *composeTextView;
@property (weak, nonatomic) IBOutlet UILabel *charLabel;
@property (strong, nonatomic) NSNumber *tweetLength;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initially no characters written
    self.charLabel.text = @"0/280";
    
    // Setting view controller as composeTextView delegate
    self.composeTextView.delegate = self;
    
    // Giving border, border color, and rounded corners to compose text view
    self.composeTextView.layer.cornerRadius = 8;
    self.composeTextView.layer.borderWidth = 0.5f;
    self.composeTextView.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (IBAction)closeCompose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)postTweet:(id)sender {
    // Getting length of composed tweet
    int tweetLength = [self.tweetLength intValue];
    if (tweetLength > 280) {
        // Display error if over limit
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Text Limit Exceeded" message:@"Your tweet must contain at most 280 characters."
            preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {}];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // Otherwise, make API call to post tweet
        [[APIManager shared]postStatusWithText:self.composeTextView.text completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error composing Tweet: %@", error.localizedDescription);
            }
            else{
                [self.delegate didTweet:tweet];
                [self dismissViewControllerAnimated:true completion:nil];
                NSLog(@"Compose Tweet Success!");
            }
        }];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    // Set the max character limit
    int characterLimit = 280;

    // Construct what the new text would be if we allowed the user's latest edit
    NSString *newText = [self.composeTextView.text stringByReplacingCharactersInRange:range withString:text];

    // Update character count label
    self.charLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)newText.length, characterLimit];
    self.tweetLength = [NSNumber numberWithInteger:newText.length];
    
    // Red letters if you are over limlit
    if (newText.length > characterLimit) {
        self.charLabel.textColor = [UIColor redColor];
    } else {
        self.charLabel.textColor = [UIColor systemGrayColor];
    }
    
    // I've decided to always allow users to edit but to display a warning and prevent posting if char limit exceeded
    return true;
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
