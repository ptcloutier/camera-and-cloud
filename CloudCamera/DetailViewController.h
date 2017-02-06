//
//  DetailViewController.h
//  CloudCamera
//
//  Created by perrin cloutier on 11/17/16.
//  Copyright © 2016 ptcloutier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Image.h"
#import "DAO.h"
#import "CommentsCell.h"
 
@interface DetailViewController : UIViewController <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) BOOL liked;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *detailImage;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *likesLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *commentsButton;
@property (strong, nonatomic) IBOutlet UIButton *optionsButton;
@property (nonatomic, strong) DAO *dataManager;
@property (strong, nonatomic) Image *currentImage;
@property (strong, nonatomic) UIImage *imageToSet;
- (IBAction)tappedLike:(id)sender;
- (IBAction)tappedComment:(id)sender;
- (IBAction)tappedOptions:(id)sender;
 
@end
