//
//  DAO.m
//  CloudCamera
//
//  Created by perrin cloutier on 11/3/16.
//  Copyright © 2016 ptcloutier. All rights reserved.
//
#import "DAO.h"


@implementation DAO


+ (instancetype)sharedManager {
   
    // Returns Singleton, data access object
    static id dataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[self alloc] init];
    });
    return dataManager;
}


-(instancetype)init {
   
    self = [super init];
    if(self){
        _images = [[NSMutableArray alloc] init];
    }
    return self;
}


- (NSString *)userLogin {
    // user is me
    return kUSER_NAME;
}


#pragma mark - Upload Image


-(void)uploadImageToFirebaseStorageWithData:(NSData *)data {
    
    // Create unique identifier string for file name
    NSString *uniqueIdentifier = [[NSUUID UUID] UUIDString];

    FIRStorageReference *fileReference = [self createStorageReferenceWithUniqueIdentifier:uniqueIdentifier];
    
    // Upload the file to the path
    FIRStorageUploadTask *uploadTask = [fileReference putData:data metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
        if (error != nil) {
            NSLog(@"***** error : %@ *****", error);
        } else {
            // Metadata contains file metadata such as size, content-type, and download URL.
            NSURL *downloadURL = metadata.downloadURL;
            NSDate *dateCreated = metadata.timeCreated;
            NSDictionary *metadata = [self metadataWithURL:downloadURL dateCreated:dateCreated andFilename:uniqueIdentifier];
            [self postMetadata:metadata];
        }
    }];
    [uploadTask resume];
}


-(void)postMetadata:(NSDictionary *)metadata {
    
    // Interacting with Firebase Database with Firebase REST API
    NSString *URLString = [NSString stringWithFormat:@"%@.json",kDATABASE_REFERENCE];
    
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    
    // Create POST Request with metadata for image
    [manager POST:URLString parameters:metadata progress:nil success:^(NSURLSessionDataTask *task, id responseObject){
        NSLog(@"***** post metadata successful *****");
    }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              NSLog(@"***** error: %@ *****", error);
          }];
}


- (FIRStorageReference *)createStorageReferenceWithUniqueIdentifier:(NSString *)uniqueIdentifier {
    
    // Create Firebase storage reference
    FIRStorageReference *storageReference = [[FIRStorage storage] referenceForURL: kSTORAGE_REFERENCE];
    
    // Create reference to the images folder
    FIRStorageReference *imagesReference = [storageReference child:@"images"];
    
    // Create a reference to the file you want to upload
    FIRStorageReference *fileReference = [imagesReference child:[NSString stringWithFormat:@"%@", uniqueIdentifier]];
    return fileReference;
}


-(NSDictionary *)metadataWithURL:(NSURL *)downloadURL dateCreated:(NSDate *)dateCreated andFilename:(NSString *)storageFileName {
    
    // Set up the metadata attributes for the image
    NSMutableArray *comments = [[NSMutableArray alloc]init];
    
    NSNumber *likes = [NSNumber numberWithInteger:0];
    
    NSString *URLString = [downloadURL absoluteString];
    
    NSString *author = [self userLogin];
    
    // make a string value to store in the database for the NSDate object dateCreated
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd 'at' HH:mm:ss";
    NSString *dateCreatedString = [dateFormatter stringFromDate:dateCreated];
    
    NSDictionary *metadata = @{@"author" : author, @"downloadURL": URLString,@"comments":comments, @"likes": likes, @"storageFileName": storageFileName, @"dateCreated":dateCreatedString};
    return metadata;
}


- (AFHTTPSessionManager *)createAFHTTPSessionManager {
    
    // Set up manager, provides convenience methods for making HTTP requests
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    // Set up JSON Request serializer which serializes query string parameters for HTTP session request
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Set up JSON Response Serializer that validates and decodes JSON responses.
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    [manager setResponseSerializer:responseSerializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];

    return manager;
}




#pragma mark - Download


-(void)populatePhotoArray{
    
    NSString *url = [NSString stringWithFormat:@"%@.json",kDATABASE_REFERENCE];
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    
    // Create GET Request to download image
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"***** populate photo array successful *****");
        
        NSDictionary *imageDict = (NSDictionary *)responseObject;
        NSMutableArray *tempImageKeyArray = [[NSMutableArray alloc]init];
        [self.images removeAllObjects];
        
        if ([imageDict respondsToSelector:@selector(allKeys)]){
            
            tempImageKeyArray = [imageDict.allKeys mutableCopy];
            
            for(NSString *imageKey in tempImageKeyArray){
                
                NSString *author = [[imageDict
                    objectForKey:imageKey]objectForKey:@"author"];
                NSString *downloadURL = [[imageDict objectForKey:imageKey]objectForKey:@"downloadURL"];
                NSString *storageFile = [[imageDict objectForKey:imageKey]objectForKey:@"storageFileName"];
                NSMutableArray *comments = [[NSMutableArray alloc] initWithArray:[[imageDict objectForKey:imageKey]objectForKey:@"comments"]];
                NSNumber *likes = [[imageDict objectForKey:imageKey]objectForKey:@"likes"];
                
                // Make an NSDate object from dateCreated  string value
                NSString *dateCreated = [[imageDict objectForKey:imageKey]objectForKey:@"dateCreated"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"yyyy-MM-dd 'at' HH:mm:ss";
                NSDate *dateFromString = [[NSDate alloc] init];
                dateFromString = [dateFormatter dateFromString:dateCreated];

                
                // Create Image object from metadata
                Image *image = [[Image alloc]initWithAuthor:author imageKey:imageKey downloadURL:downloadURL comments:comments storageFile:storageFile dateCreated:dateFromString andLikes:likes];
                
                if(![image.downloadURL isEqualToString:@""]){
                    [self.images addObject:image];
                }
                    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO];
                    [self.images sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"refresh" object:self];
        }
    }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"***** error: %@ *****", error);
         }];

}


- (void)updateImageLikes:(Image *)image {
   
    NSString *url = [NSString stringWithFormat:@"%@/%@.json", kDATABASE_REFERENCE, image.imageKey];
    NSDictionary *parametersDictionary = @{@"likes":(image.likes)};
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
  
    // Set up PATCH Request, creates and runs an 'NSURLSessionDataTask' with a `PATCH` request.
    [manager PATCH:url parameters:parametersDictionary success:^(NSURLSessionDataTask *task, id  responseObject) {
        NSLog(@"***** update likes successful ***** ");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"***** error: %@ *****", error);
    }];
}


- (void)updateImageComments:(Image *)image {
    
    NSString *url =[NSString stringWithFormat:@"%@/%@.json", kDATABASE_REFERENCE, image.imageKey];
    NSDictionary *parametersDictionary = @{@"comments":image.comments};
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    
    // Create PATCH Request
    [manager PATCH:url parameters:parametersDictionary success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"***** update image comments successful *****");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"***** error: %@ *****", error);
    }];
    
}


-(void)deleteImageWithImageKey:(NSString *)imageKey andStorageFileName:(NSString*)storageFile {
    
    NSString *url = [NSString stringWithFormat:@"%@/%@.json", kDATABASE_REFERENCE, imageKey];
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    
    //Creates and runs an `NSURLSessionDataTask` with a `DELETE` request
    [manager DELETE:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"success!");
        
        if(!self.storage ) {
            self.storageRef = [[FIRStorage storage] referenceForURL:kSTORAGE_REFERENCE];
        }
        NSString *storageFilePath = [NSString stringWithFormat:@"images/%@", storageFile];
        FIRStorageReference *deleteRef = [self.storageRef child:storageFilePath];
        
        // Delete the file
        [deleteRef deleteWithCompletion:^(NSError *error){
            if (error != nil) {
                // Uh-oh, an error occurred!
                NSLog(@"***** error: %@ ****", error.localizedDescription);
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

@end
