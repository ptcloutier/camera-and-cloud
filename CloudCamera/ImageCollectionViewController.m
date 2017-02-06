//
//  ImageCollectionViewController.m
//  CloudCamera
//
//  Created by perrin cloutier on 11/17/16.
//  Copyright © 2016 ptcloutier. All rights reserved.
//

#import "ImageCollectionViewController.h"
#import "UIImageView+AFNetworking.h"


@implementation ImageCollectionViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.dataManager = [DAO sharedManager];
    
    // This notification tells the collectionview to reload data
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(registerForNotification:) name:@"refresh" object:nil];
    [self.dataManager populatePhotoArray];
}


-(void)viewWillAppear:(BOOL)animated {
    
    [self.dataManager populatePhotoArray];
    [self.collectionView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)registerForNotification:(NSNotification *)notification {
         
    if([notification.name isEqualToString:@"refresh"]){
        [self.collectionView reloadData];
    }
}


#pragma mark - UICollectionView 


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataManager.images.count;
}
     
     
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
         
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
         
    NSString *tempURL = (NSString*)[[self.dataManager.images objectAtIndex:indexPath.row]downloadURL];
    
    // Download image from cloud
    [cell.imageView setImageWithURLRequest:
     [NSURLRequest requestWithURL:[NSURL URLWithString:tempURL]]
                          placeholderImage:[UIImage imageNamed:@"color1"]
                                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage *image) {
                                       cell.imageView.image = image;
                                   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       NSLog(@"%@",error);
                                   }];
    // Display image in cell
    [cell.backgroundView addSubview:cell.imageView];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ImageCell *currentCell = (ImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    DetailViewController *detailViewController =  [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
    self.detailViewController = detailViewController;
    self.detailViewController.currentImage = [self.dataManager.images objectAtIndex:indexPath.row];
    self.detailViewController.imageToSet = currentCell.imageView.image;
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
