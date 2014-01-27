//
//  TweetViewController.m
//  twitter
//
//  Created by Sandip Patel on 1/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "TweetViewController.h"
#import "ComposeViewController.h"

@interface TweetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *favLabel;
- (void)onCompose;
@end

@implementation TweetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(self.logo == nil) {
        NSString *blueLogo = @"https://g.twimg.com/Twitter_logo_blue.png";
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: blueLogo]];
        self.logo = [UIImage imageWithData:data];
        
    }
    if([self.nameLabel.text isEqualToString:@"Label"]) {
        self.imageView.image = self.profile_picture;
        self.nameLabel.text = self.name;
        self.screenNameLabel.text = [@"@" stringByAppendingString:self.screen_name];
        [self.view reloadInputViews];
    }
    
    UIImageView *imageview = [[UIImageView alloc] initWithImage: self.logo];
    imageview.frame = CGRectMake(0, 0, 40, 40);
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView.frame = CGRectMake(0, 0, 40, 40);
    self.navigationItem.titleView = imageview;
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myButton addTarget:self action:@selector(onCompose)
       forControlEvents:UIControlEventTouchUpInside];
    myButton.frame = CGRectMake(0, 0, 40, 40);
    [myButton setBackgroundImage:[UIImage imageNamed:@"twitter-icons.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *composeBtn = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    self.navigationItem.rightBarButtonItem = composeBtn;
    self.favLabel.text = self.fav.stringValue;
    self.retweetLabel.text = self.retweets.stringValue;
    self.tweetLabel.text = self.tweetText;
}
- (void)onCompose
{
    ComposeViewController *viewController = [[ComposeViewController alloc] initWithNibName:@"ComposeViewController" bundle:nil];
    [[TwitterClient instance] currentUserWithSuccess:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"%@", response);
        NSDictionary *current_user = response;
        viewController.name = [current_user objectForKey:@"name"];
        viewController.screen_name = [current_user objectForKey:@"screen_name"];
        NSString *imageUrl = [current_user objectForKey:@"profile_image_url"];
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageUrl]];
            if ( data == nil )
                return;
            dispatch_async(dispatch_get_main_queue(), ^{
                //WARNING: is the cell still using the same data by this point??
                viewController.profile_picture = [UIImage imageWithData:data];
                [self.navigationController pushViewController:viewController animated:YES];
            });
            
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Do nothing
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
