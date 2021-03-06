//
//  User.m
//  twitter
//
//  Created by Sabrina P Meng on 6/28/21.
//  Copyright © 2021 Emerson Malca. All rights reserved.
//

#import "User.h"

@implementation User

// Constructor for User class
- (instancetype)initWithDictionary:(NSDictionary *)dictionary; {
    self = [super init];
    if (self) {
        // Initializing User object
        self.name = dictionary[@"name"];
        self.screenName = dictionary[@"screen_name"];
        self.profilePicture = dictionary[@"profile_image_url_https"];
    }
    return self;
}

@end
