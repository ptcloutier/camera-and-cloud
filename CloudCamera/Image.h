//
//  Image.h
//  CloudCamera
//
//  Created by perrin cloutier on 11/9/16.
//  Copyright © 2016 ptcloutier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Image : NSObject

@property (nonatomic)NSString *author;
@property (nonatomic)NSString *imageKey;
@property (nonatomic)NSString *downloadURL;
@property (nonatomic)NSString *storageFile;
@property (nonatomic)NSNumber *likes;
@property (nonatomic)NSDate *dateCreated;
@property (nonatomic)NSMutableArray<NSString *> *comments;
- (instancetype)initWithAuthor:(NSString *)author imageKey:(NSString *)imageKey
                     downloadURL:(NSString *)downloadURL
                        comments:(NSMutableArray *)comments
                     storageFile:(NSString *)storageFile
                   dateCreated:(NSDate *)dateCreated
                        andLikes:(NSNumber *)likes;
@end
