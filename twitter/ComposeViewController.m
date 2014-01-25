//
//  ComposeViewController.m
//  twitter
//
//  Created by Sandip Patel on 1/25/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "ComposeViewController.h"
#import "TimelineVC.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;

@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;

- (void)onCancel;
- (void)onTweet;
@end

@implementation ComposeViewController

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
    if(self.logo == nil) {
        NSString *blueLogo = @"https://g.twimg.com/Twitter_logo_blue.png";
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: blueLogo]];
        self.logo = [UIImage imageWithData:data];
        
    }
    self.tweetTextView.delegate = self;
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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweet)];
    self.tweetTextView.textColor = [UIColor grayColor];
    self.tweetTextView.text = @"What is happening?";
    
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer: tapRec];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    NSRange range = NSMakeRange(0,1);
    self.tweetTextView.text = @"";
    [self.tweetTextView scrollRangeToVisible:range];
    //self.tweetTextView.frame = CGRectMake(self.tweetTextView.frame.origin.x, self.tweetTextView.frame.origin.y, self.tweetTextView.frame.size.width, self.tweetTextView.frame.size.height-320);
    //self.tweetTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 150, 0.0);
    return YES;
}

-(void)tap:(UITapGestureRecognizer *)tapRec{
    [[self view] endEditing: YES];
}

- (void) onCancel
{
    TimelineVC *timelineVC = [[TimelineVC alloc] init];
    [self.navigationController pushViewController:timelineVC animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //self.tweetTextView.frame = CGRectMake(self.tweetTextView.frame.origin.x, self.tweetTextView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height+320);
}

- (void) onTweet
{
    NSString *tweetText = self.tweetTextView.text;
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"\n" withString:@"%20"];
    [[TwitterClient instance] tweet:tweetText success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"%@", response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    self.tweetTextView.text = @"- What's Happening? ";
    [self.view endEditing:YES];
}

@end
