//
//  ImageCollectionViewController.h
//  CloudCamera
//
//  Created by perrin cloutier on 11/17/16.
//  Copyright © 2016 ptcloutier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Image.h"
#import "DAO.h"
#import "ImageCell.h"
#import "DetailViewController.h"


@interface ImageCollectionViewController : UIViewController<UICollectionViewDataSource, UIGestureRecognizerDelegate, UICollectionViewDelegate>

@property (nonatomic, strong) DAO *dataManager;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) DetailViewController *detailViewController;

@end
