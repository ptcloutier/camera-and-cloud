//
//  DAO.h
//  CloudCamera
//
//  Created by perrin cloutier on 11/3/16.
//  Copyright © 2016 ptcloutier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "Image.h"
@import Firebase;
#import "Constants.h"


@interface DAO : NSObject

@property (nonatomic)NSMutableArray *images;
@property (nonatomic)FIRStorage *storage;
@property (nonatomic)FIRStorageReference *storageRef;
@property (nonatomic)FIRStorageReference *stockPhotoRef;
@property (nonatomic)FIRStorageReference *imagesRef;
+ (instancetype)sharedManager;
- (void)populatePhotoArray;
- (void)uploadImageToFirebaseStorageWithData:(NSData*)imageData;
- (void)updateImageLikes:(Image *)image;
- (void)updateImageComments:(Image *)image;
- (void)deleteImageWithImageKey:(NSString*)imageKey
             andStorageFileName:(NSString*)storFile;
@end
