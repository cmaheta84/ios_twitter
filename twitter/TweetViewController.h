//
//  TweetViewController.h
//  twitter
//
//  Created by Sandip Patel on 1/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetViewController : UIViewController
@property (strong, nonatomic) NSString *tweetText;
@property (strong, nonatomic) NSNumber *fav;
@property (strong, nonatomic) NSNumber *retweets;
@property (nonatomic, strong) UIImage *logo;
@property (nonatomic, strong) UIImage *profile_picture;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screen_name;
@end
