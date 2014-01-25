//
//  TimelineVC.m
//  twitter
//
//  Created by Timothy Lee on 8/4/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "TimelineVC.h"
#import "TweetCell.h"
#import "ComposeViewController.h"

@interface TimelineVC ()

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, strong) UIImage *logo;

- (void)onSignOutButton;
- (void)reload;
- (void)onCompose;
@property (strong, nonatomic) IBOutlet TweetCell *tweetCell;

@end

@implementation TimelineVC
@synthesize tweetCell = _tweetCell;
@synthesize mytableView = _mytableView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Twitter";
        
        [self reload];
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
    UIImageView *imageview = [[UIImageView alloc] initWithImage: self.logo];
    imageview.frame = CGRectMake(0, 0, 40, 40);
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView.frame = CGRectMake(0, 0, 40, 40);
    self.navigationItem.titleView = imageview;
    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myButton addTarget:self action:@selector(onCompose)
       forControlEvents:UIControlEventTouchUpInside];
    myButton.frame = CGRectMake(0, 0, 40, 40);
    [myButton setBackgroundImage:[UIImage imageNamed:@"twitter-icons.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *composeBtn = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    self.navigationItem.rightBarButtonItem = composeBtn;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onSignOutButton)];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    //TweetCell *cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

    //Tweet *tweet = self.tweets[indexPath.row];
    //cell.textLabel.text = tweet.text;
    
    //return cell;
    
    TweetCell *cell = (TweetCell *)[tableView dequeueReusableCellWithIdentifier:[TweetCell reuseIdentifier]];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"TweetCell" owner:self options:nil];
        cell = _tweetCell;
        _tweetCell = nil;
    }
    if([self.tweets isEqual:nil]) {
        return cell;
    }
    Tweet *tweet = self.tweets[indexPath.row];
    
    cell.nameLabel.text = [tweet.user objectOrNilForKey:@"name"];
    [cell.nameLabel setFont:[UIFont boldSystemFontOfSize:12]];
    cell.idLabel.text = [@"@" stringByAppendingString:[tweet.user objectOrNilForKey:@"screen_name"]];
    cell.tweetsLabel.text = tweet.text;
    // pin label to top
    CGFloat rowHeight = [self heightForText:tweet.text];
    cell.tweetsLabel.frame = CGRectMake(0, 0, 251, rowHeight);
    
    NSString *timestamp =[tweet valueOrNilForKeyPath:@"created_at"];
    timestamp = [timestamp substringFromIndex:4];
    timestamp = [timestamp substringToIndex:6];
    cell.timestampLabel.text = timestamp;
    
    
    if(tweet.profile_picture == nil) {
        [self loadImage:indexPath];
    }
    else {
        cell.imageView.image = tweet.profile_picture;
    }
    cell.imageView.frame = CGRectMake(0, 0, 37, 37);
  
    return cell;
}

-(void) loadImage:(NSIndexPath *)indexPath
{
    Tweet *tweet = self.tweets[indexPath.row];
    NSString *imageUrl = @"http://pbs.twimg.com/profile_images/812112572/me___me_normal.jpg";
    if(tweet != nil) {
        imageUrl = [tweet.user objectForKey:@"profile_image_url"];
    }
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageUrl]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            //WARNING: is the cell still using the same data by this point??
            tweet.profile_picture = [UIImage imageWithData:data];
            [self.tableView reloadData];
        });
    });

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *defaultText = @"Posting from @apigee's API test console. It's like a command line for the Twitter API! #apitools";
    if(self.tweets != nil)
    {
        Tweet *tweet = self.tweets[indexPath.row];
        NSString *labelText = tweet.text;
        CGFloat height = [self heightForText:labelText];
        CGFloat minHeight = [self heightForText:defaultText];
        
        if(height < minHeight) {
            height = minHeight;
        }
        return height;
    } else
    {
        return [self heightForText:defaultText];
    }
}

- (CGFloat)heightForText:(NSString *)bodyText
{
    UIFont *cellFont = [UIFont systemFontOfSize:12];
    CGSize constraintSize = CGSizeMake(251, MAXFLOAT);
    CGSize labelSize = [bodyText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = labelSize.height + 30;
    //NSLog(@"height=%f", height);
    return height;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - Private methods

- (void)onSignOutButton {
    [User setCurrentUser:nil];
}
- (void)onCompose {
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

- (void)reload {
    [[TwitterClient instance] homeTimelineWithCount:20 sinceId:0 maxId:0 success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"%@", response);
        self.tweets = [Tweet tweetsWithArray:response];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Do nothing
    }];
}


@end
