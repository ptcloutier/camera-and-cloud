//
//  PickerViewController.m
//  CloudCamera
//
//  Created by perrin cloutier on 11/3/16.
//  Copyright © 2016 ptcloutier. All rights reserved.
//

#import "PickerViewController.h"


@interface PickerViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) DAO *dataManager;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) IBOutlet UIButton *photoRollButton;
@property (nonatomic) NSMutableArray *capturedImages;
- (IBAction)showImagePickerForCamera:(id)sender;
- (IBAction)showImagePickerForPhotoRoll:(id)sender;

@end


@implementation PickerViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    DAO *dataManager = [DAO sharedManager];
    self.dataManager = dataManager;
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *noCameraAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
        [noCameraAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    }
}


- (IBAction)showImagePickerForCamera:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}


- (IBAction)showImagePickerForPhotoRoll:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}


#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // This method is called when an image has been chosen from the library or taken from the camera.
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    NSData *imgData = UIImageJPEGRepresentation(chosenImage, 1.0);
   
    [self.dataManager uploadImageToFirebaseStorageWithData:imgData];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:^{
     }];
}

@end
