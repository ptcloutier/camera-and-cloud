//
//  Image.m
//  CloudCamera
//
//  Created by perrin cloutier on 11/9/16.
//  Copyright © 2016 ptcloutier. All rights reserved.
//

#import "Image.h"

@implementation Image

-(instancetype)initWithAuthor:(NSString *)author
                     imageKey:(NSString *)imageKey
                    downloadURL:(NSString *)downloadURL
                       comments:(NSMutableArray *)comments
                    storageFile:(NSString *)storageFile
                  dateCreated:(NSDate *)dateCreated
                     andLikes:(NSNumber *)likes {
    self = [super init];
    if (self) {
        _author = author;
        _imageKey = imageKey;
        _downloadURL = downloadURL;
        _comments = comments;
        _storageFile = storageFile;
        _dateCreated = dateCreated;
        _likes = likes;
    }
    return self;
}
@end
