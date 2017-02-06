//
//  DetailViewController.m
//  CloudCamera
//
//  Created by perrin cloutier on 11/17/16.
//  Copyright © 2016 ptcloutier. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateImageForLikesButton];
    self.authorLabel.text = self.currentImage.author;
    [self makeLikesLabel];
    self.tableView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = false;
    
    // we control the height of tableview cell by the height of the textlabel inside
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
}


- (void)viewDidAppear:(BOOL)animated{
    
    self.detailImage.image = self.imageToSet;
    self.dataManager = [DAO sharedManager];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.currentImage.comments.count;
}

 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = @"cell";
    CommentsCell *cell = (CommentsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CommentsCell alloc] init];
    }
     // Configure the cell...
    cell.comments.text = [NSString stringWithFormat:@"%@ - %@", self.currentImage.comments[indexPath.row], self.currentImage.author];

    return cell;
}


#pragma mark - Likes 


- (IBAction)tappedLike:(id)sender {
    
    NSLog(@"***** like tapped *****");
    [self likeOrDislike];
    if([self.currentImage.likes intValue] > 0){
        self.liked = true;
    }else{
        self.liked = false;
    }
    [self makeLikesLabel];
    [self.likesLabel sizeToFit];
    [self updateImageForLikesButton];
}


- (void)likeOrDislike {
    
    if(self.liked == false){
        self.currentImage.likes = [NSNumber numberWithInt:([self.currentImage.likes intValue]+1)];
        self.liked = true;
    }else{
      self.currentImage.likes = [NSNumber numberWithInt:([self.currentImage.likes intValue]-1)];
        self.liked = false;
    }
    [self.dataManager updateImageLikes:self.currentImage];
}


- (void)updateImageForLikesButton {
    
    if([self.currentImage.likes intValue] > 0){
        [self.likeButton setImage:[UIImage imageNamed:@"icn_like_active_optimized.png"] forState:UIControlStateNormal];
    }else{
        [self.likeButton setImage:[UIImage imageNamed:@"icn_like_inactive_optimized.png"] forState:UIControlStateNormal];
    }
}


- (void)makeLikesLabel {
    
    if([self.currentImage.likes isEqual:[NSNumber numberWithInt:1]]){
        self.likesLabel.text = [NSString stringWithFormat:@"   %@ like", self.currentImage.likes];
    }else{
        self.likesLabel.text = [NSString stringWithFormat:@"   %@ likes", self.currentImage.likes];
    }
}


#pragma mark - Comments

- (IBAction)tappedComment:(id)sender {
    
    NSString *title = NSLocalizedString(@"Leave a comment", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"Post", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        // Add the text field for text entry.
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // If you need to customize the text field, you can do so here.
    }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.currentImage.comments addObject:alertController.textFields[0].text];
        [self.tableView reloadData];
        [self.dataManager updateImageComments:self.currentImage];
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (IBAction)tappedOptions:(id)sender {
    
    NSString *deletePhotoTitle = NSLocalizedString(@"Delete Photo", nil);
    NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Create the actions.
    UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:deletePhotoTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.dataManager deleteImageWithImageKey:self.currentImage.imageKey andStorageFileName:self.currentImage.storageFile];
        [self.dataManager.images removeObject:self.currentImage];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
        // Add the actions.
    [alertController addAction:destructiveAction];
    [alertController addAction:otherAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
